[org 0]
[bits 16]

jmp 0x07c0:start    ; bootloader loading address by bios



start:
    mov ax, 0x7C0
    mov ds, ax      ; set data segment
    mov ax, 0xb800
    mov es, ax      ; set extra segment to use video memory address

    mov si, 0

.screenCleanLoop:
    mov byte[es:si], 0          ; printing letter in upper byte
    mov byte[es:si+1], 0x0A     ; setting data in lower byte

    add si, 2                   ; move a word

    cmp si, 80 * 25 * 2         ;screen full size

    jl .screenCleanLoop

    mov si, 0
    mov di, 0                   ;initialize

.messageLoop:
    mov cl, byte[si + MESSAGE1]     ;load string
    cmp cl,0                        ;check string end
    je .messageEnd
    mov byte[es:di], cl             ;copy string to video memory address

    add si, 1
    add di, 2

    jmp .messageLoop
	
.messageEnd:
    jmp $

MESSAGE1: db 'OSDEVELOP', 0

times 510-($-$$) db 0
dw 0xaa55                       ;bootloader footer signature