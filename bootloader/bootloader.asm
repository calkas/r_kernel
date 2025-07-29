; Bootloader for R_Kernel
; This bootloader is loaded by BIOS and sets up the environment for the kernel.
; It switches to protected mode, loads the kernel from disk, and jumps to it.

; Memory layout after booting:
;0x100000|----------------------------------|
;        | BIOS (256 kB)                    |
; 0xC0000|----------------------------------|
;        | video memory (128 kB)            |
; 0xA0000|----------------------------------|
;        | extended BIOS data area (639 kB) |
; 0x9fc00|----------------------------------|
;        | free (638 kB)                    |
;  0x7e00|----------------------------------|
;        | loaded boot sector (512 bytes)   |
;  0x7c00|----------------------------------|
;        |                                  |
;   0x500|----------------------------------|
;        | BIOS data area (256 bytes)       |
;   0x400|----------------------------------|
;        | interrupt vector table (1 kB)    |
;     0x0------------------------------------


[org 0x7C00]
[BITS 16]
OS_OFFSET_ADDRESS equ 0x1000 ; Offset where the kernel will be loaded 0x7C00 + 0x1000 = 0x8C00
start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    ; Set up the stack
    mov sp, 0x9000 ; 0x0000×16 + 0x9000 = 0x9000
    sti

    call load_kernel
    call welcome_msg
    call switch_to_protected_mode


; Include GDT setup
%include "gdt_32bit.asm"

load_kernel:
    ; Set OS entry: 0x0000:0x1000 = 0x1000
    mov bx, OS_OFFSET_ADDRESS

    ; INT 13h - read sector
    mov ah, 0x02        ; Function: read
    mov al, 1           ; Number of sectors
    mov ch, 0           ; Cylinder
    mov cl, 2           ; Sector (must be > 0)
    mov dh, 0           ; Head
    mov dl, 0x80        ; Hard disk
    int 0x13
    jc load_error       ; If error, jump to message
    ret

switch_to_protected_mode:
    cli
    ; Load GDT
    lgdt [gdt_descriptor]

    ; Enter protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump to 32-bit code
    jmp CODE_SEGMENT:protected_mode_entry


welcome_msg:
    mov si, w_msg
    call print
    ret

load_error:
    mov si, error_msg
    call print
    jmp $

print:
    mov ah, 0x0E
.next:
    lodsb
    or al, al
    jz .done
    int 0x10
    jmp .next
.done:
    ret

error_msg db "INT 13h load error!", 0
w_msg db "Loading kernel...", 0

; -------------------------------
; Protected Mode
; -------------------------------
[BITS 32]
protected_mode_entry:
    mov ax, DATA_SEGMENT
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov ebp, 0x90000
    mov esp, ebp

    ; Jump to the kernel entry point
    jmp CODE_SEGMENT:OS_OFFSET_ADDRESS

.hang:
    cli
    hlt
    jmp .hang

; Fill 512 bytes - padding
times 510 - ($ - $$) db 0
dw 0xAA55
