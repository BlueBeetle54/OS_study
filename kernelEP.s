[org 0x00]
[bits 16]

start:
    mov ax, 0x1000
    mov ds, ax
    mov es, ax                              ; set  0x10000 to segment value

    cli                                     ; set interupt disable
    lgdt [GDTR]

    mov eax, 0x4000003B                     ; disable paging, enable cache, disable cache write-through, disable write protection
    mov cr0, eax                            ; disable emulation, disable aliign check, set protected mode

    jmp dword 0x08:(protectedMode - $$ + 0x10000)


[bits 32]
protectedMode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax                              ; segment set
    mov esp, 0xFFFE
    mov ebp, 0xFFFE

    push (SWITCHSUCCESSMESSAGE - $$ + 0x10000)
    push 4
    push 0
    call printMessage
    add esp, 12

    jmp $

printMessage:                               ;cdecl (x, y, string)
    push ebp
    mov ebp, esp
    push esi
    push edi
    push eax
    push ecx
    push edx

    mov eax, dword[ebp + 12]
    mov esi, 160
    mul esi
    mov edi, eax

    mov eax, dword[ebp + 8]
    mov esi, 2
    mul esi
    add edi, eax

    mov esi, dword[ebp +16]

.messageLoop:
    mov cl, byte[esi]
    cmp cl, 0
    je .messageEnd
    mov byte[edi + 0xB8000], cl
    mov byte[edi + 0xB8000 + 1], 0x0f

    add esi, 1
    add edi, 2

    jmp .messageLoop

.messageEnd:
    pop edx
    pop ecx
    pop eax
    pop edi
    pop esi
    pop ebp
    ret

align 8, db 0
dw 0x0000

GDTR:
    dw GDTEND - GDT - 1
    dd (GDT - $$ + 0x10000)

GDT:
    NULLDESCRIPTOR:
        dw 0x0000
        dw 0x0000
        db 0x00
        db 0x00
        db 0x00
        db 0x00

    CODEDESCRIPTOR:
        dw 0xFFFF               ; limit [15:0]
        dw 0x0000               ; base [15:0]
        db 0x00                 ; base [23:16]
        db 0x9A                 ; P = 1, DPL = 0, code segment, exec/read
        db 0xCF                 ; g = 1, d = 1, l = 0, limit[19:16]
        db 0x00                 ; base [31:24]

    DATADESCRIPTOR:
        dw 0xFFFF               ; limit [15:0]
        dw 0x0000               ; base [15:0]
        db 0x00                 ; base [23:16]
        db 0x92                 ; P = 1, DPL = 0, data segment, read/write
        db 0xCF                 ; g = 1, d = 1, l = 0, limit[19:16]
        db 0x00                 ; base [31:24]

GDTEND:

SWITCHSUCCESSMESSAGE: db 'SWITCH TO PROTECTED MODE', 0

times 512 - ($ - $$) db 0x00
