[BITS 16]
[org 0x7c00]

_start:
    mov eax, 0xCAFEBABE
    ret

times 510 - ($ - $$) db 0
dw 0xAA55
