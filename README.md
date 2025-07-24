# R_Kernel


## Rust

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
