#!/bin/bash

set -e

RUST_KERNEL="r_kernel"

kvm -drive format=raw,file=output/bootimage-$RUST_KERNEL.bin -cpu host,-svm -d int
