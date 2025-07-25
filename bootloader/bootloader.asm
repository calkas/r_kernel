; Bootloader for R_Kernel
; This bootloader is loaded by BIOS and sets up the environment for the kernel.
; It switches to protected mode, loads the kernel from disk, and jumps to it.

; Memory layout after booting:
;        | R_Kernel entry point             |
;0x200000|----------------------------------|
;        | free                             |
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

start:
    ; Set up the stack
    mov ax, 0x9000
    mov ss, ax
    mov sp, 0xFFFF

    ; Print welcome message
    mov si, welcome_msg
    call print

    ; Switch to protected mode
    call switch_to_protected_mode

    ; This point is never reached
    jmp $

; Include GDT setup
%include "gdt_32bit.asm"

switch_to_protected_mode:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Enable A20 line
    in al, 0x92
    or al, 0x02
    out 0x92, al

    ; Load GDT
    lgdt [gdt_descriptor]

    ; Enter protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump to 32-bit code
    jmp CODE_SEGMENT:protected_mode_entry

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

.hang:
    cli
    hlt
    jmp .hang

; -------------------------------
; BIOS Print Function
; -------------------------------
print:
    mov ah, 0x0E
.next:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .next
.done:
    ret

welcome_msg db "Load R_Kernel...", 0

; Boot sector padding
times 510 - ($ - $$) db 0
dw 0xAA55
