#!/bin/bash
set -e

# Default output file
IMAGE_FILE="kitten.img"
IMAGE_SIZE_MB=256
BOOT_PART_SIZE_MB=128
TEMP_BOOT_IMG="boot.vfat"

# Required tools
REQUIRED_TOOLS=("dd" "mcopy" "mformat" "cpio" "make" "git" "aarch64-linux-gnu-gcc" "arm-none-eabi-gcc" "bison" "flex")

# Linux specific check for partitioning tool
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v sgdisk &> /dev/null; then
        PART_TOOL="sgdisk"
    elif command -v parted &> /dev/null; then
        PART_TOOL="parted"
    else
        echo "Error: Neither 'sgdisk' nor 'parted' found. Please install 'gdisk' or 'parted'."
        exit 1
    fi
else
    # Fallback/Error for non-Linux if user tries (though user said Linux host)
    echo "Warning: This script is optimized for Linux. Using parted as fallback."
    PART_TOOL="parted"
fi

# Check for required tools
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Error: Required tool '$tool' is not installed."
        echo "For 'arm-none-eabi-gcc', install package 'gcc-arm-none-eabi' or similar."
        exit 1
    fi
done

# Check for DTB (User provided)
DTB="rk3399-rockpro64.dtb"
if [ ! -f "$DTB" ]; then
    echo "Error: $DTB not found in current directory. Please provide it."
    exit 1
fi

# -----------------------------------------------------------------------------
# 1. Build ARM Trusted Firmware (to get bl31.elf)
# -----------------------------------------------------------------------------
ATF_DIR="arm-trusted-firmware"
if [ ! -d "$ATF_DIR" ]; then
    echo "Cloning ARM Trusted Firmware..."
    # Using v2.9 tag for stability
    git clone --depth 1 --branch v2.9 https://github.com/ARM-software/arm-trusted-firmware.git "$ATF_DIR"
fi

if [ ! -f "$ATF_DIR/build/rk3399/release/bl31/bl31.elf" ]; then
    echo "Building ATF (BL31)..."
    pushd "$ATF_DIR"
    # Clean just in case
    # make distclean
    # Note: RK3399 needs Cortex-M0 compiler for PMU firmware.
    make CROSS_COMPILE=aarch64-linux-gnu- M0_CROSS_COMPILE=arm-none-eabi- PLAT=rk3399 bl31 -j$(nproc)
    popd
fi

BL31_ELF=$(realpath "$ATF_DIR/build/rk3399/release/bl31/bl31.elf")
if [ ! -f "$BL31_ELF" ]; then
    echo "Error: BL31 build failed. $BL31_ELF not found."
    exit 1
fi
echo "BL31: $BL31_ELF"

# -----------------------------------------------------------------------------
# 2. Build U-Boot (generating idbloader.img and u-boot.itb)
# -----------------------------------------------------------------------------
UBOOT_DIR="u-boot"
if [ ! -d "$UBOOT_DIR" ]; then
    echo "Cloning U-Boot..."
    git clone --depth 1 https://github.com/u-boot/u-boot.git "$UBOOT_DIR"
fi

IDBLOADER_BUILD="$UBOOT_DIR/idbloader.img"
UBOOT_ITB_BUILD="$UBOOT_DIR/u-boot.itb"

if [ ! -f "$IDBLOADER_BUILD" ] || [ ! -f "$UBOOT_ITB_BUILD" ]; then
    echo "Building U-Boot..."
    pushd "$UBOOT_DIR"
    # Configure for RockPro64
    make rockpro64-rk3399_defconfig
    
    # Patch config to force low memory placement of FDT/Initrd
    # This prevents the kernel from failing to map the FDT if it looks in limited initial page tables.
    echo 'CONFIG_PREBOOT="setenv fdt_high 0x1f000000; setenv initrd_high 0x1f000000"' >> .config
    
    # Build
    # We must explicitly pass BL31 env var
    BL31="$BL31_ELF" make CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
    popd
fi

# Copy artifacts to root for consistency
cp "$IDBLOADER_BUILD" idbloader.img
cp "$UBOOT_ITB_BUILD" u-boot.itb

if [ ! -f "idbloader.img" ] || [ ! -f "u-boot.itb" ]; then
    echo "Error: U-Boot build did not produce expected images."
    exit 1
fi

# -----------------------------------------------------------------------------
# 3. Build Kernel and Init Task
# -----------------------------------------------------------------------------
KERNEL="vmlwk.bin"
INIT_TASK="init_task"
INITRD="initrd.img"

if [ ! -f "$KERNEL" ] || [ ! -f "$INIT_TASK" ]; then
    echo "Building kernel and init_task..."
    make -j$(nproc)
    if [ ! -f "$KERNEL" ]; then
        echo "Error: Kernel build failed (vmlwk.bin missing)."
        exit 1
    fi
     if [ ! -f "$INIT_TASK" ]; then
        echo "Error: init_task build failed."
        exit 1
    fi
fi

# Create Initrd
echo "Creating initrd from $INIT_TASK..."
mkdir -p initrd_staging
cp "$INIT_TASK" initrd_staging/init
chmod +x initrd_staging/init
(cd initrd_staging && find . | cpio -o -H newc > "../$INITRD")
rm -rf initrd_staging

# -----------------------------------------------------------------------------
# 4. Create Disk Image
# -----------------------------------------------------------------------------
echo "Creating blank image file ($IMAGE_SIZE_MB MB)..."
dd if=/dev/zero of="$IMAGE_FILE" bs=1M count="$IMAGE_SIZE_MB" status=none

# Create partition table (GPT)
echo "Creating partition table..."
if [ "$PART_TOOL" == "sgdisk" ]; then
    sgdisk -Z "$IMAGE_FILE" > /dev/null
    # Partition 1: Boot (FAT32), starts at 16MB (32768 sectors)
    sgdisk -n 1:32768:+${BOOT_PART_SIZE_MB}M -t 1:8300 -c 1:"kitten-boot" "$IMAGE_FILE"
elif [ "$PART_TOOL" == "parted" ]; then
    parted -s "$IMAGE_FILE" mklabel gpt
    parted -s "$IMAGE_FILE" mkpart primary ext4 16MB $(($BOOT_PART_SIZE_MB + 16))MB
    parted -s "$IMAGE_FILE" name 1 kitten-boot
fi

# Create filesystem image
echo "Creating filesystem image..."
dd if=/dev/zero of="$TEMP_BOOT_IMG" bs=1M count="$BOOT_PART_SIZE_MB" status=none
mformat -i "$TEMP_BOOT_IMG" -F ::

# Config
EXTLINUX_CONF="extlinux.conf"
mkdir -p extlinux
cat > "$EXTLINUX_CONF" <<EOF
LABEL kitten
    MENU LABEL Kitten Kernel
    LINUX /vmlwk.bin
    INITRD /initrd.img
    FDT /rk3399-rockpro64.dtb
    APPEND console=ttyS2,1500000n8 root=/dev/ram0 rw init=/init
EOF

# Create uEnv.txt to enforce fdt_high/initrd_high (Double tap)
cat > uEnv.txt <<EOF
fdt_high=0x1f000000
initrd_high=0x1f000000
EOF

# Copy file
mcopy -i "$TEMP_BOOT_IMG" "$KERNEL" ::vmlwk.bin
mcopy -i "$TEMP_BOOT_IMG" "$DTB" ::rk3399-rockpro64.dtb
mcopy -i "$TEMP_BOOT_IMG" "$INITRD" ::initrd.img
mcopy -i "$TEMP_BOOT_IMG" uEnv.txt ::uEnv.txt
rm uEnv.txt
mmd -i "$TEMP_BOOT_IMG" ::extlinux
mcopy -i "$TEMP_BOOT_IMG" "$EXTLINUX_CONF" ::extlinux/extlinux.conf
rm "$EXTLINUX_CONF"
rmdir extlinux

# Flash Bootloaders
echo "Writing bootloaders..."
# idbloader.img at sector 64
dd if="idbloader.img" of="$IMAGE_FILE" seek=64 conv=notrunc status=none
# u-boot.itb at sector 16384
dd if="u-boot.itb" of="$IMAGE_FILE" seek=16384 conv=notrunc status=none

# Flash Boot Partition
# Offset: 16MB (16777216 bytes)
START_OFFSET=$((16 * 1024 * 1024))
echo "Writing partition content at offset $START_OFFSET..."
dd if="$TEMP_BOOT_IMG" of="$IMAGE_FILE" bs=1 seek=$START_OFFSET conv=notrunc status=none

# Cleanup contents?
rm "$TEMP_BOOT_IMG"

echo "Done! Image created: $IMAGE_FILE"
echo "To flash: sudo dd if=$IMAGE_FILE of=/dev/sdX bs=4M status=progress"
