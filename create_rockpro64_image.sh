#!/bin/bash
set -e

# Default output file
IMAGE_FILE="kitten.img"
IMAGE_SIZE_MB=256
BOOT_PART_SIZE_MB=128
TEMP_BOOT_IMG="boot.vfat"

# Required tools
REQUIRED_TOOLS=("dd" "mcopy" "mformat" "curl" "cpio" "make")

# Linux specific check
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
    echo "Warning: This script is optimized for Linux. Adjusting..."
    PART_TOOL="parted" # Try parted as it's often available
    # macOS 'gpt' logic removed as requested.
fi

# Check for required tools
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Error: Required tool '$tool' is not installed."
        exit 1
    fi
done

# Artifacts
IDBLOADER="idbloader.img"
UBOOT="u-boot.itb"
DTB="rk3399-rockpro64.dtb"
KERNEL="vmlwk.bin"
INIT_TASK="init_task"
INITRD="initrd.img"

# URLs
BASE_URL="https://gitlab.manjaro.org/manjaro-arm/packages/core/uboot-rockpro64/-/raw/master"
# Known working DTB location or try Manjaro's
DTB_URL="https://gitlab.manjaro.org/manjaro-arm/packages/core/linux-rockchip/-/raw/master/arch/arm64/boot/dts/rockchip/rk3399-rockpro64.dtb"

download_if_missing() {
    local file=$1
    local url=$2
    if [ ! -f "$file" ]; then
        echo "Downloading $file..."
        echo "URL: $url"
        curl -L -o "$file" "$url" || {
            echo "Error: Failed to download $file"
            rm -f "$file"
            exit 1
        }
    else
        echo "Found $file"
    fi
}

download_if_missing "$IDBLOADER" "$BASE_URL/idbloader.img"
download_if_missing "$UBOOT" "$BASE_URL/u-boot.itb"

if [ ! -f "$DTB" ]; then
    # Try to copy from local build if exists
    if [ -f "devicetrees/rk3399-rockpro64.dtb" ]; then
        cp "devicetrees/rk3399-rockpro64.dtb" .
        echo "Using local DTB."
    else
        echo "DTB not found locally. Downloading..."
        # Try finding a valid URL. Manjaro's raw link might change.
        # We'll try a few known ones.
        # Note: linux-aarch64 package is another candidate.
        curl -L -o "$DTB" "https://gitlab.manjaro.org/manjaro-arm/packages/core/linux-rockchip/-/raw/master/arch/arm64/boot/dts/rockchip/rk3399-rockpro64.dtb" || \
        curl -L -o "$DTB" "https://raw.githubusercontent.com/torvalds/linux/master/arch/arm64/boot/dts/rockchip/rk3399-rockpro64.dts" || { # This is source, not blob!
             echo "Error: Could not download DTB binary. Please provide rk3399-rockpro64.dtb."
             rm -f "$DTB"
             exit 1
        }
        # Check if we accidentally downloaded source
        if file "$DTB" | grep -q "text"; then
             echo "Error: Downloaded DTB appears to be text (source?). Please provide compiled rk3399-rockpro64.dtb."
             rm -f "$DTB"
             exit 1
        fi
    fi
fi

# Build Kernel and Init Task
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

# Create blank image file
echo "Creating blank image file ($IMAGE_SIZE_MB MB)..."
dd if=/dev/zero of="$IMAGE_FILE" bs=1M count="$IMAGE_SIZE_MB" status=none

# Create partition table (GPT)
echo "Creating partition table..."
if [ "$PART_TOOL" == "sgdisk" ]; then
    # Sector 64: Start of GAP for bootloaders
    # First partition starts at 16MB (sector 32768)
    # 16MB is standard start for Rockchip to avoid overwriting u-boot at 8MB or 16384 sectors?
    # Actually u-boot.itb is at 16384 (8MB).
    # So partition should start after that. 
    # 16MB (32768 sectors) is safe.
    sgdisk -Z "$IMAGE_FILE" > /dev/null # Zap
    sgdisk -n 1:32768:+${BOOT_PART_SIZE_MB}M -t 1:8300 -c 1:"kitten-boot" "$IMAGE_FILE"
elif [ "$PART_TOOL" == "parted" ]; then
    parted -s "$IMAGE_FILE" mklabel gpt
    # Parted takes MB/GB. 16MB start.
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

# Copy file
mcopy -i "$TEMP_BOOT_IMG" "$KERNEL" ::vmlwk.bin
mcopy -i "$TEMP_BOOT_IMG" "$DTB" ::rk3399-rockpro64.dtb
mcopy -i "$TEMP_BOOT_IMG" "$INITRD" ::initrd.img
mmd -i "$TEMP_BOOT_IMG" ::extlinux
mcopy -i "$TEMP_BOOT_IMG" "$EXTLINUX_CONF" ::extlinux/extlinux.conf
rm "$EXTLINUX_CONF"
rmdir extlinux

# Flash Bootloaders
echo "Writing bootloaders..."
# idbloader.img at sector 64
dd if="$IDBLOADER" of="$IMAGE_FILE" seek=64 conv=notrunc status=none
# u-boot.itb at sector 16384
dd if="$UBOOT" of="$IMAGE_FILE" seek=16384 conv=notrunc status=none

# Flash Boot Partition
# We need to write the filesystem content into the partition we created.
# Offset: 16MB (16777216 bytes)
START_OFFSET=$((16 * 1024 * 1024))
echo "Writing partition content at offset $START_OFFSET..."
dd if="$TEMP_BOOT_IMG" of="$IMAGE_FILE" bs=1 seek=$START_OFFSET conv=notrunc status=none

# Cleanup
rm "$TEMP_BOOT_IMG"
# Keep downloaded artifacts
# rm "$INITRD"

echo "Done! Image created: $IMAGE_FILE"
echo "To flash: sudo dd if=$IMAGE_FILE of=/dev/sdX bs=4M status=progress"
