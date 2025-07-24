#!/bin/bash

# Define paths
ASM_FILE="bootloader/bootloader.asm"
BIN_FILE="bootloader/bootloader.bin"
IMG_FILE="bootloader/bootloader.img"
OUTPUT_DIR="output"


echo "==================== Start ===================="
if [ ! -f "$OUTPUT_DIR" ]; then
	rm -R "$OUTPUT_DIR"
fi
mkdir -p "$OUTPUT_DIR"

echo " -> Kernel compilation"
# Kernel compilation
#cargo clean
#cargo build

echo " -> Bootloader compilation"
# Compile the NASM bootloader
nasm -f bin "$ASM_FILE" -o "$BIN_FILE"

echo " -> Boot Image creation"
dd if="$BIN_FILE" of="$IMG_FILE" bs=512 count=1 conv=notrunc

# Copy the binary and img to the output directory
cp "$BIN_FILE" "$OUTPUT_DIR/"
cp "$IMG_FILE" "$OUTPUT_DIR/"

echo "==================== Done ===================="
