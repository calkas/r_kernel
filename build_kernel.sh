#!/bin/bash

set -e

# Define paths
OUTPUT_DIR="output"
RUST_KERNEL="r_kernel"
RUST_TARGET="x86_64_r_os"

echo "=============================================="
echo "=                  Start                     ="
echo "=============================================="
echo ""

# Clean output directory if it exists
if [ -d "$OUTPUT_DIR" ]; then
    rm -r "$OUTPUT_DIR"
fi

mkdir -p "$OUTPUT_DIR"

echo "Kernel compilation for target: $RUST_TARGET:"
cargo bootimage

echo "Displaying entry kernel address:"
nm -C "target/$RUST_TARGET/debug/$RUST_KERNEL" | grep -E -i --color '_start$'

echo "Copying kernel binary to output directory:"
BIN_FILE="target/$RUST_TARGET/debug/bootimage-$RUST_KERNEL.bin"
# Copy the binary and img to the output directory
cp "$BIN_FILE" "$OUTPUT_DIR/"

KERNEL_SIZE=$(stat -c%s "$OUTPUT_DIR/bootimage-$RUST_KERNEL.bin")
SECTORS=$(( (KERNEL_SIZE + 511) / 512 ))
echo "Kernel size: $KERNEL_SIZE bytes ($SECTORS sectors)"

echo ""
echo "=============================================="
echo "=                    Done                    ="
echo "=============================================="
