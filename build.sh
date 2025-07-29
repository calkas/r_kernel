#!/bin/bash

set -e

# Define paths
ASM_FILE="bootloader/bootloader.asm"
BIN_FILE="bootloader/bootloader.bin"
IMG_FILE="bootloader/bootloader.img"
OUTPUT_DIR="output"
RUST_KERNEL="r_kernel"
RUST_TARGET="x86_64_r_os"

echo "==================== Start ===================="

# Clean output directory if it exists
if [ -d "$OUTPUT_DIR" ]; then
    rm -r "$OUTPUT_DIR"
fi

mkdir -p "$OUTPUT_DIR"

echo " -> Kernel compilation (release)"
cargo clean
cargo build --release --target "$RUST_TARGET.json"

echo " -> Stripping and converting kernel to raw binary"
rust-objcopy "target/$RUST_TARGET/release/$RUST_KERNEL" \
    --strip-all -O binary "$OUTPUT_DIR/kernel.bin"

echo " -> Displaying entry kernel address"
nm -C "target/$RUST_TARGET/release/$RUST_KERNEL" | grep -E '_start'

echo " -> Bootloader compilation"
nasm -f bin -I bootloader/ "$ASM_FILE" -o "$BIN_FILE"
if [ $? -ne 0 ]; then
    echo "Bootloader compilation failed!"
    exit 1
fi

echo " -> Boot Image creation"
dd if="$BIN_FILE" of="$IMG_FILE" bs=512 count=1 conv=notrunc

# Copy the binary and img to the output directory
cp "$BIN_FILE" "$OUTPUT_DIR/"
cp "$IMG_FILE" "$OUTPUT_DIR/"

rm -f "$BIN_FILE" "$IMG_FILE"

echo " -> Merging bootloader and kernel"
#truncate -s 512 "$OUTPUT_DIR/kernel.bin"
cat "$OUTPUT_DIR/bootloader.bin" "$OUTPUT_DIR/kernel.bin" > "$OUTPUT_DIR/r_os.bin"

#calculate number of sectors
BOOT_SIZE=$(stat -c%s "$OUTPUT_DIR/bootloader.bin")
echo " * Bootloader size: $BOOT_SIZE bytes"

KERNEL_SIZE=$(stat -c%s "$OUTPUT_DIR/kernel.bin")
SECTORS=$(( (KERNEL_SIZE + 511) / 512 ))
echo " * Kernel size: $KERNEL_SIZE bytes ($SECTORS sectors)"

OS_SIZE=$(stat -c%s "$OUTPUT_DIR/r_os.bin")
echo " * OS size: $OS_SIZE bytes"

echo "==================== Done ===================="
