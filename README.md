# R_Kernel

## Booloader

### Memory

```bash
; Bootloader for R_Kernel
; This bootloader is loaded by BIOS and sets up the environment for the kernel.
; It switches to protected mode, loads the kernel from disk, and jumps to it.

; Memory layout after:
;       0x0------------------------------------
;          | interrupt vector table (1 kB)    |
;     0x400|----------------------------------|
;          | BIOS data area (256 bytes)       |
;     0x500|----------------------------------|
;          |                                  |
;    0x7c00|----------------------------------|
;          | loaded boot sector (512 bytes)   |
;    0x7e00|----------------------------------|
;          | free (638 kB)                    |
;    0x9000|             Stack                |
;   0x9fc00|----------------------------------|
;          | extended BIOS data area (639 kB) |
;   0xA0000|----------------------------------|
;          | video memory (128 kB)            |
;   0xC0000|----------------------------------|
;          | BIOS (256 kB)                    |
;  0x100000|----------------------------------|


; After loading the kernel:
; The available space is about 0x9000 - 0x1000 = 0x8000 = 32 KB. Because we can overloaded bios
;          |                                  |
;    0x1000|       kernel entry               |
;          |                                  |
;          |                                  |
;    0x9000|       kernel stack               |
;   0xA0000|----------------------------------|
;          | video memory (128 kB)            |
;   0xC0000|----------------------------------|
```


## Rust

1. First switch to nightly mode in project folder

```bash
rustup override set nightly

# For objcopy for bin
rustup component add llvm-tools-preview
cargo install cargo-binutils


rust-objcopy r_kernel -O binary kernel.bin

```

2. Building

```bash
cargo build --target x86_64-r_os.json

```


## NASM

```bash
# Compilation
nasm -f bin bootloader.asm -o bootloader.bin


# Img creation
dd if=bootloader.bin of=bootdisk.img bs=512 count=1 conv=notrunc


# Running Bootloader
kvm -drive format=raw,file=bootloader.bin -cpu host,-svm

# Running OS
kvm -drive format=raw,file=output/r_os.bin -cpu host,-svm

# Disassembly
ndisasm -o 0x7c00 r_os.bin 

```


## Links

[bootloader wiki](https://github.com/lukearend/x86-bootloader)
