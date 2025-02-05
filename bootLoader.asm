[org 0]
[bits 16]

jmp 0x07c0:start    ; bootloader loading address by bios

TOTALSECTORCOUNT: dw 1   ;maximum sector of OS

start:
    mov ax, 0x7C0
    mov ds, ax      ; set data segment
    mov ax, 0xb800
    mov es, ax      ; set extra segment to use video memory address

    mov ax, 0x0000
    mov ss, ax      ; set stack segment
    mov sp, 0xFFFE  ; set stack pointer
    mov bp, 0xFFFE  ; set stack base pointer

    mov si, 0

.screenCleanLoop:
    mov byte[es:si], 0          ; printing letter in upper byte
    mov byte[es:si+1], 0x0A     ; setting data in lower byte

    add si, 2                   ; move a word

    cmp si, 80 * 25 * 2         ; screen full size
    jl .screenCleanLoop

    push MESSAGE1               ; printing message
    push 0                      ; set y
    push 0                      ; set x
    call printMessage
    add sp,6                    ; C-Declare Call(cdecl)

    push LOADINGMESSAGE
    push 1
    push 0
    call printMessage
    add sp,6

resetDisk:
    mov ax, 0                   ; service number 0(reset)
    mov dl, 0                   ; drive number 0
    int 0x13                    ; interupt BIOS
    jc handleDiskError          ; error control

    mov si, 0x1000              ; OS image copy address
    mov es, si
    mov bx, 0x0000              ; set segmentation lower address
    mov di, word[TOTALSECTORCOUNT]  ;set loop target

readData:
    cmp di, 0
    je readEnd
    sub di, 0x1                 ; copy loop checker

    mov ah, 0x02                ; BIOS service number(read sector)
    mov al, 0x1                 ; single sector
    mov ch, byte[TRACKNUMBER]
    mov cl, byte[SECTORNUMBER]
    mov dh, byte[HEADNUMBER]
    mov dl, 0x00                ; drive number(floppy)
    int 0x13
    jc handleDiskError

    add si, 0x0020
    mov es, si                  ; count read area and sync extra segment

    mov al, byte[SECTORNUMBER]
    add al, 0x01
    mov byte[SECTORNUMBER], al  ; count sector number
    cmp al, 19                  ; in floppy system, 18 sectors per track
    jl readData

    xor byte[HEADNUMBER], 0x01  ; in floppy system, head has 2 state
    mov byte[SECTORNUMBER], 0x01; sector number initialize
    cmp byte[HEADNUMBER], 0x00
    jne readData

    add byte[TRACKNUMBER], 0x01
    jmp readData

readEnd:
    push LOADINGCOMPLETEMESSAGE
    push 2
    push 20
    call printMessage
    add sp, 6

    jmp 0x1000:0x0000

handleDiskError:
    push DISKERRORMESSAGE
    push 2
    push 20
    call printMessage
    add sp, 6

    jmp $

printMessage:                       ; parameter(x, y, string)
    push bp
    mov bp, sp

    push es
    push si
    push di
    push ax
    push cx
    push dx

    mov ax, 0xb800
    mov es, ax                      ; video memory start address setting

    mov ax, word[bp + 6]            ; 2nd parameter
    mov si, 160                     ; byte per line(80 * 2)
    mul si
    mov di, ax                      ; set printing address

    mov ax, word[bp + 4]            ; 1st parameter
    mov si, 2
    mul si
    add di, ax                      ; set printing address

    mov si, word[bp + 8]            ; string address

.messageLoop:
    mov cl, byte[si]                ; load string
    cmp cl,0                        ; check string end
    je .messageEnd
    mov byte[es:di], cl             ; copy string to video memory address
    mov byte[es:di+1], 0x0f

    add si, 1
    add di, 2

    jmp .messageLoop

.messageEnd:
    pop dx
    pop cx
    pop ax
    pop di
    pop si
    pop es
    pop bp
    ret

MESSAGE1:               db 'OSDEVELOP', 0
DISKERRORMESSAGE:       db 'DISK ERROR', 0
LOADINGMESSAGE:         db 'OS IMAGE LOADING', 0
LOADINGCOMPLETEMESSAGE: db 'COMPLETE', 0

SECTORNUMBER: db 0x02
HEADNUMBER: db 0x00
TRACKNUMBER: db 0x00

times 510-($-$$) db 0
dw 0xaa55                       ; bootloader footer signature