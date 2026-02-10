#!/bin/bash
set -e

# Default output file
IMAGE_FILE="kitten.img"
IMAGE_SIZE_MB=256
BOOT_PART_SIZE_MB=128
TEMP_BOOT_IMG="boot.vfat"

# Required tools
REQUIRED_TOOLS=("dd" "hdiutil" "mcopy" "mformat" "gpt" "curl" "cpio")

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

# URLs for downloading if missing
# Using Manjaro ARM GitLab as a reliable source for standard boot blobs
BASE_URL="https://gitlab.manjaro.org/manjaro-arm/packages/core/uboot-rockpro64/-/raw/master"
# For DTB, we try to use one from a recent kernel build or similar. 
# Using a known working DTB source or assuming the user provides it if precise version matches kernel. 
# However, user said "just download them". I'll try to fetch a generic one.
# Alternative: https://github.com/manjaro-arm-kernels/linux-rockchip/raw/master/arch/arm64/boot/dts/rockchip/rk3399-rockpro64.dtb (URL might be stale)
# Let's use a backup location if Manjaro fails or just try one.
DTB_URL="https://gitlab.manjaro.org/manjaro-arm/packages/core/linux-rockchip/-/raw/master/arch/arm64/boot/dts/rockchip/rk3399-rockpro64.dtb" 
# Note: Manjaro structure changes. If this fails, we might need another source. 
# Fallback to a very generic one if possible.

download_if_missing() {
    local file=$1
    local url=$2
    if [ ! -f "$file" ]; then
        echo "Downloading $file..."
        curl -L -o "$file" "$url" || {
            echo "Error: Failed to download $file from $url"
            rm -f "$file"
            exit 1
        }
    else
        echo "Found $file"
    fi
}

download_if_missing "$IDBLOADER" "$BASE_URL/idbloader.img"
download_if_missing "$UBOOT" "$BASE_URL/u-boot.itb"

# Handling DTB download - URL is tricky. We'll try one, if it fails, warn user.
# Try to find a valid DTB url.
# Using a raw link from a stable kernel repo might be safer.
# https://github.com/torvalds/linux/blob/master/arch/arm64/boot/dts/rockchip/rk3399-rockpro64.dts is source.
# We need binary. 
# Let's try to see if 'kitten' build process produces it?
# kitten/devicetrees/ exists?
if [ ! -f "$DTB" ]; then
    if [ -f "devicetrees/rk3399-rockpro64.dtb" ]; then
        cp "devicetrees/rk3399-rockpro64.dtb" .
    else
        echo "DTB not found locally. Attempting download..."
        # Try a known location
        curl -L -o "$DTB" "https://github.com/midwan/manjaro-arm-tools-deploy/raw/master/arm-profiles/devices/rockpro64/rk3399-rockpro64.dtb" || \
        curl -L -o "$DTB" "https://gitlab.manjaro.org/manjaro-arm/packages/core/linux-rockchip/-/raw/master/arch/arm64/boot/dts/rockchip/rk3399-rockpro64.dtb" || {
            echo "Error: Could not download DTB. Please provide rk3399-rockpro64.dtb."
            exit 1
        }
    fi
fi

# Build Kernel and Init Task
if [ ! -f "$KERNEL" ] || [ ! -f "$INIT_TASK" ]; then
    echo "Building kernel and init_task..."
    make -j$(sysctl -n hw.ncpu)
    if [ ! -f "$KERNEL" ]; then
        echo "Error: Kernel build failed (vmlwk.bin missing)."
        exit 1
    fi
     if [ ! -f "$INIT_TASK" ]; then
        echo "Error: init_task build failed."
        exit 1
    fi
fi

# Create Initrd from init_task
echo "Creating initrd from $INIT_TASK..."
mkdir -p initrd_staging
cp "$INIT_TASK" initrd_staging/init
# Ensure executable
chmod +x initrd_staging/init
(cd initrd_staging && find . | cpio -o -H newc > "../$INITRD")
rm -rf initrd_staging

# Create blank image file
echo "Creating blank image file ($IMAGE_SIZE_MB MB)..."
dd if=/dev/zero of="$IMAGE_FILE" bs=1m count="$IMAGE_SIZE_MB" status=none

# Create boot partition image (FAT32)
echo "Creating boot partition image..."
dd if=/dev/zero of="$TEMP_BOOT_IMG" bs=1m count="$BOOT_PART_SIZE_MB" status=none
mformat -i "$TEMP_BOOT_IMG" -F ::

# Populate boot partition
echo "Populating boot partition..."
# Create extlinux directory and config
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

# Copy files using mcopy
mcopy -i "$TEMP_BOOT_IMG" "$KERNEL" ::vmlwk.bin
mcopy -i "$TEMP_BOOT_IMG" "$DTB" ::rk3399-rockpro64.dtb
mcopy -i "$TEMP_BOOT_IMG" "$INITRD" ::initrd.img
mmd -i "$TEMP_BOOT_IMG" ::extlinux
mcopy -i "$TEMP_BOOT_IMG" "$EXTLINUX_CONF" ::extlinux/extlinux.conf

# Clean up temp config file
rm "$EXTLINUX_CONF"
rmdir extlinux

# Attach disk image to create partition table
echo "Attaching disk image..."
DEVICE=$(hdiutil attach -nomount "$IMAGE_FILE" | awk '/\/dev\/disk/ {print $1}' | head -n 1) # Extract /dev/diskX
if [ -z "$DEVICE" ]; then
    echo "Error: Failed to attach image."
    exit 1
fi
echo "Attached as $DEVICE"

# Partition using GPT
echo "Partitioning..."
gpt create -f "$DEVICE"
# Add verify partition layout logic - ensure space for bootloaders
# Start partition at 32MB (sector 65536) to leave plenty of room
gpt add -b 65536 -s $(($BOOT_PART_SIZE_MB * 2048)) -t windows "$DEVICE"

# Detach to write bootloaders via file access (safer/easier than writing to raw device while gpt might have updated headers)
hdiutil detach "$DEVICE"

# Write bootloaders (idbloader at sec 64, uboot at sec 16384)
echo "Writing bootloaders..."
dd if="$IDBLOADER" of="$IMAGE_FILE" seek=64 conv=notrunc status=none
dd if="$UBOOT" of="$IMAGE_FILE" seek=16384 conv=notrunc status=none

# Write partition content
# Need to find the exact offset of the partition.
# 32MB = 32 * 1024 * 1024 bytes = 33554432
PART_OFFSET_BYTES=$((32 * 1024 * 1024))
echo "Writing filesystem to partition at offset $PART_OFFSET_BYTES..."
dd if="$TEMP_BOOT_IMG" of="$IMAGE_FILE" bs=1 seek=$PART_OFFSET_BYTES conv=notrunc status=none

# Cleanup
rm "$TEMP_BOOT_IMG"
rm -f "$INITRD" 
# Do not remove downloaded artifacts so subsequent runs are faster

echo "Done! Image created: $IMAGE_FILE"
