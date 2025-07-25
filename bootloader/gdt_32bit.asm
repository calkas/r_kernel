; Global Descriptor Table (GDT):
;  - Entry 1 : First 8 bytes of the GDT should be 0                           [GDTR Offset + 0][Null]
;  - Entry 2 : The next 8 bytes will describe a code segment (kernel space)   [GDTR Offset + 8][Code Segment]
;  - Entry 3 : The next 8 bytes will describe a data segment (kernel space)   [GDTR Offset + 16][Data Segment]
gdt_start:
    dq 0x0000000000000000  ; Null descriptor 8 bytes
gdt_code:
    dq 0x00CF9A000000FFFF  ; Code segment descriptor (base=0, limit=4GB, present, executable, readable) 8 bytes
gdt_data:
    dq 0x00CF92000000FFFF  ; Data segment descriptor (base=0, limit=4GB, present, writable) 8 bytes
gdt_end:
    ;only to calculate the size of the GDT

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Limit of the GDT -> 24 - 1 = 23
    dd gdt_start                ; Base address of the GDT 32 bits

;pointers to the code and data segments
; [ descriptor index << 3 ] | [TI=0] | [RPL=0]
; 0x08 = 1 << 3 index 1 (gdt_code)
; 0x10 = 2 << 3 index 2 (gdt_data)
CODE_SEGMENT equ gdt_code - gdt_start ; 8  -> CODE_SEGMENT = 0x08
DATA_SEGMENT equ gdt_data - gdt_start ; 16 -> DATA_SEGMENT = 0x10
