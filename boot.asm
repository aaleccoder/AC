; First Stage Bootloader - boot.asm
; This bootloader loads the second stage (game.asm) from disk and jumps to it

BITS 16             ; 16-bit real mode
ORG 0x7C00          ; BIOS loads boot sectors at this address

start:
    ; Set up segments and stack
    cli                 ; Disable interrupts during setup
    xor ax, ax          ; AX = 0
    mov ds, ax          ; Data segment = 0
    mov es, ax          ; Extra segment = 0
    mov ss, ax          ; Stack segment = 0
    mov sp, 0x7C00      ; Stack pointer just below bootloader
    sti                 ; Re-enable interrupts

    ; Save the boot drive number (passed in DL by BIOS)
    mov [boot_drive], dl

    ; Display loading message
    mov si, loading_msg
    call print_string

    ; Load the second stage from disk
    ; We'll load it to memory address 0x0800:0x0000 (0x8000 physical)
    mov ax, 0x0800      ; Segment where we'll load the game
    mov es, ax          ; ES = segment
    xor bx, bx          ; BX = offset (0)
    
    mov ah, 0x02        ; BIOS read sectors function
    mov al, 4           ; Number of sectors to read (adjust as needed)
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Start from sector 2 (sector 1 is the boot sector)
    mov dh, 0           ; Head 0
    mov dl, [boot_drive] ; Drive number
    int 0x13            ; Call BIOS disk service

    jc disk_error       ; Jump if carry flag is set (error)

    ; Jump to the loaded second stage
    mov si, success_msg
    call print_string
    
    ; Jump to second stage at 0x0800:0x0000
    jmp 0x0800:0x0000

disk_error:
    mov si, error_msg
    call print_string
    jmp hang

hang:
    hlt                 ; Halt the processor
    jmp hang            ; Infinite loop

; Print string function
; Input: SI = pointer to null-terminated string
print_string:
    pusha
.print_loop:
    lodsb               ; Load byte from DS:SI into AL and increment SI
    or al, al           ; Check if AL is 0 (end of string)
    jz .done            ; If zero, we're done
    mov ah, 0x0E        ; BIOS teletype function
    mov bh, 0           ; Page number
    mov bl, 0x07        ; Text attribute (light gray on black)
    int 0x10            ; Call BIOS video service
    jmp .print_loop
.done:
    popa
    ret

; Data section
boot_drive db 0
loading_msg db 'Loading Racing Game...', 0x0D, 0x0A, 0
success_msg db 'Starting Game!', 0x0D, 0x0A, 0
error_msg db 'Disk Error!', 0x0D, 0x0A, 0

; Pad to 510 bytes and add boot signature
times 510 - ($-$$) db 0
dw 0xAA55               ; Boot signature
