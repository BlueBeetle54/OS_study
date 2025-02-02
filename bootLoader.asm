[org 0]
[bits 16]

jmp 0x07c0:start

start:
    mov ax, 0x7C0
    mov ds, ax
    mov ax, 0xb800
    mov es, ax

    mov si, 0

.screenCleanLoop:
    mov byte[es:si], 0
    mov byte[es:si+1], 0x0A

    add si, 2

    cmp si, 80 * 25 * 2

    jl .screenCleanLoop

    mov si, 0
    mov di, 0

.messageLoop:
    mov cl, byte[si + MESSAGE1]
    cmp cl,0
    je .messageEnd
    mov byte[es:di], cl

    add si, 1
    add di, 2

    jmp .messageLoop
	
.messageEnd:
    jmp $

MESSAGE1: db 'OSDEVELOP', 0

times 510-($-$$) db 0
dw 0xaa55