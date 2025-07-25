# R_Kernel

## Booloader

### Memory

```bash

        | R_Kernel entry point             |
0x200000|----------------------------------|
        | free                             |
0x100000|----------------------------------|
        | BIOS (256 kB)                    |
 0xC0000|----------------------------------|
        | video memory (128 kB)            |
 0xA0000|----------------------------------|
        | extended BIOS data area (639 kB) |
 0x9fc00|----------------------------------|
        | free (638 kB)                    |
  0x7e00|----------------------------------|
        | loaded boot sector (512 bytes)   |
  0x7c00|----------------------------------|
        |                                  |
   0x500|----------------------------------|
        | BIOS data area (256 bytes)       |
   0x400|----------------------------------|
        | interrupt vector table (1 kB)    |
     0x0------------------------------------
```


## Rust

1. First switch to nightly mode in project folder

```bash
rustup override set nightly
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


# Running
kvm -drive format=raw,file=bootloader.bin -cpu host,-svm

```


## Links

[bootloader wiki](https://github.com/lukearend/x86-bootloader)
