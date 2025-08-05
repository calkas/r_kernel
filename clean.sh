#!/bin/bash

set -e

OUTPUT_DIR="output"

# Clean output directory if it exists
if [ -d "$OUTPUT_DIR" ]; then
    rm -r "$OUTPUT_DIR"
fi

cargo clean

echo "Cleaning done"
