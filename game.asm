; Racing Game - Second Stage Bootloader
; Two cars racing game with keyboard controls
; Red car: WASD, Blue car: Arrow keys

BITS 16
ORG 0x0000          ; Loaded at 0x0800:0x0000

start:
    ; Set up video mode
    mov ax, 0x13        ; 320x200 256-color VGA mode
    int 0x10

    ; Set up segments
    mov ax, 0x0800
    mov ds, ax
    mov es, ax
    
    ; Initialize game variables
    call init_game
    
    ; Main game loop
game_loop:
    call handle_input
    call update_cars
    call draw_screen
    call check_winner
    
    ; Small delay
    mov cx, 0x1000
delay_loop:
    loop delay_loop
    
    jmp game_loop

; Initialize game variables
init_game:
    ; Red car position (Player 1)
    mov word [red_car_x], 50
    mov word [red_car_y], 100
    mov word [red_car_lap], 0
    
    ; Blue car position (Player 2)
    mov word [blue_car_x], 50
    mov word [blue_car_y], 120
    mov word [blue_car_lap], 0
    
    ; Game state
    mov byte [game_over], 0
    
    ret

; Handle keyboard input
handle_input:
    ; Check if key is available
    mov ah, 0x01
    int 0x16
    jz .no_key
    
    ; Get key
    mov ah, 0x00
    int 0x16
    
    ; Check Red car controls (WASD)
    cmp al, 'w'
    je .red_up
    cmp al, 's'
    je .red_down
    cmp al, 'a'
    je .red_left
    cmp al, 'd'
    je .red_right
    
    ; Check Blue car controls (Arrow keys scan codes)
    cmp ah, 0x48        ; Up arrow
    je .blue_up
    cmp ah, 0x50        ; Down arrow
    je .blue_down
    cmp ah, 0x4B        ; Left arrow
    je .blue_left
    cmp ah, 0x4D        ; Right arrow
    je .blue_right
    
    ; ESC to exit
    cmp ah, 0x01
    je .exit_game
    
    jmp .no_key

.red_up:
    ; Calculate new position
    mov ax, [red_car_x]
    mov bx, [red_car_y]
    sub bx, 3               ; New Y position
    call check_track_collision
    cmp al, 1
    je .no_key              ; Collision detected, don't move
    sub word [red_car_y], 3
    jmp .no_key
    
.red_down:
    ; Calculate new position
    mov ax, [red_car_x]
    mov bx, [red_car_y]
    add bx, 3               ; New Y position
    call check_track_collision
    cmp al, 1
    je .no_key              ; Collision detected, don't move
    add word [red_car_y], 3
    jmp .no_key
    
.red_left:
    ; Calculate new position
    mov ax, [red_car_x]
    mov bx, [red_car_y]
    sub ax, 3               ; New X position
    call check_track_collision
    cmp al, 1
    je .no_key              ; Collision detected, don't move
    sub word [red_car_x], 3
    jmp .no_key
    
.red_right:
    ; Calculate new position
    mov ax, [red_car_x]
    mov bx, [red_car_y]
    add ax, 3               ; New X position
    call check_track_collision
    cmp al, 1
    je .no_key              ; Collision detected, don't move
    add word [red_car_x], 3
    jmp .no_key

.blue_up:
    ; Calculate new position
    mov ax, [blue_car_x]
    mov bx, [blue_car_y]
    sub bx, 3               ; New Y position
    call check_track_collision
    cmp al, 1
    je .no_key              ; Collision detected, don't move
    sub word [blue_car_y], 3
    jmp .no_key
    
.blue_down:
    ; Calculate new position
    mov ax, [blue_car_x]
    mov bx, [blue_car_y]
    add bx, 3               ; New Y position
    call check_track_collision
    cmp al, 1
    je .no_key              ; Collision detected, don't move
    add word [blue_car_y], 3
    jmp .no_key
    
.blue_left:
    ; Calculate new position
    mov ax, [blue_car_x]
    mov bx, [blue_car_y]
    sub ax, 3               ; New X position
    call check_track_collision
    cmp al, 1
    je .no_key              ; Collision detected, don't move
    sub word [blue_car_x], 3
    jmp .no_key
    
.blue_right:
    ; Calculate new position
    mov ax, [blue_car_x]
    mov bx, [blue_car_y]
    add ax, 3               ; New X position
    call check_track_collision
    cmp al, 1
    je .no_key              ; Collision detected, don't move
    add word [blue_car_x], 3
    jmp .no_key

.exit_game:
    ; Return to text mode and halt
    mov ax, 0x03
    int 0x10
    mov si, exit_msg
    call print_string
    cli
    hlt

.no_key:
    ret

; Update car positions and lap counting
update_cars:
    ; Check if red car crossed finish line
    mov ax, [red_car_x]
    cmp ax, 280
    jl .check_blue
    cmp word [red_car_y], 80
    jl .check_blue
    cmp word [red_car_y], 120
    jg .check_blue
    
    ; Red car crossed finish line
    inc word [red_car_lap]
    mov word [red_car_x], 50  ; Reset to start
    
.check_blue:
    ; Check if blue car crossed finish line
    mov ax, [blue_car_x]
    cmp ax, 280
    jl .done
    cmp word [blue_car_y], 80
    jl .done
    cmp word [blue_car_y], 120
    jg .done
    
    ; Blue car crossed finish line
    inc word [blue_car_lap]
    mov word [blue_car_x], 50  ; Reset to start
    
.done:
    ret

; Check for winner
check_winner:
    ; Check if either car completed 3 laps
    cmp word [red_car_lap], 3
    jge .red_wins
    cmp word [blue_car_lap], 3
    jge .blue_wins
    ret

.red_wins:
    mov byte [game_over], 1
    mov byte [winner], 1  ; Red wins
    ret

.blue_wins:
    mov byte [game_over], 1
    mov byte [winner], 2  ; Blue wins
    ret

; Draw the entire screen
draw_screen:
    ; Clear screen (black background)
    call clear_screen
    
    ; Draw track
    call draw_track
    
    ; Draw cars
    call draw_red_car
    call draw_blue_car
    
    ; Draw UI
    call draw_ui
    
    ; Check if game is over
    cmp byte [game_over], 1
    je .show_winner
    ret

.show_winner:
    call show_winner_screen
    ret

; Clear screen with black color
clear_screen:
    mov ax, 0xA000      ; VGA memory segment
    mov es, ax
    xor di, di          ; Start at beginning of video memory
    mov cx, 64000       ; 320*200 pixels
    mov al, 0           ; Black color
    rep stosb
    ret

; Draw the racing track
draw_track:
    mov ax, 0xA000
    mov es, ax
    
    ; Draw outer track boundary (white)
    ; Top horizontal line
    mov di, 20 * 320 + 20    ; y=20, x=20
    mov cx, 280
    mov al, 15              ; White color
.top_line:
    stosb
    loop .top_line
    
    ; Bottom horizontal line
    mov di, 170 * 320 + 20   ; y=170, x=20
    mov cx, 280
.bottom_line:
    stosb
    loop .bottom_line
    
    ; Left vertical line
    mov bx, 20              ; y counter
.left_line:
    mov di, bx
    imul di, 320
    add di, 20              ; x=20
    mov al, 15
    stosb
    inc bx
    cmp bx, 171
    jl .left_line
    
    ; Right vertical line
    mov bx, 20              ; y counter
.right_line:
    mov di, bx
    imul di, 320
    add di, 300             ; x=300
    mov al, 15
    stosb
    inc bx
    cmp bx, 171
    jl .right_line
    
    ; Draw inner track boundary (white)
    ; Top inner line
    mov di, 60 * 320 + 60
    mov cx, 200
.inner_top:
    stosb
    loop .inner_top
    
    ; Bottom inner line
    mov di, 130 * 320 + 60
    mov cx, 200
.inner_bottom:
    stosb
    loop .inner_bottom
    
    ; Left inner vertical
    mov bx, 60
.inner_left:
    mov di, bx
    imul di, 320
    add di, 60
    mov al, 15
    stosb
    inc bx
    cmp bx, 131
    jl .inner_left
    
    ; Right inner vertical
    mov bx, 60
.inner_right:
    mov di, bx
    imul di, 320
    add di, 260
    mov al, 15
    stosb
    inc bx
    cmp bx, 131
    jl .inner_right
    
    ; Draw start/finish line (yellow)
    mov bx, 80
.finish_line:
    mov di, bx
    imul di, 320
    add di, 280
    mov al, 14              ; Yellow
    stosb
    inc bx
    cmp bx, 121
    jl .finish_line
    
    ret

; Draw red car
draw_red_car:
    mov ax, 0xA000
    mov es, ax
    
    ; Calculate position in video memory
    mov ax, [red_car_y]
    imul ax, 320
    add ax, [red_car_x]
    mov di, ax
    
    ; Draw a simple 5x3 red car
    mov al, 4               ; Red color
    
    ; Row 1
    stosb
    stosb
    stosb
    stosb
    stosb
    
    ; Row 2
    add di, 320-5
    stosb
    stosb
    stosb
    stosb
    stosb
    
    ; Row 3
    add di, 320-5
    stosb
    stosb
    stosb
    stosb
    stosb
    
    ret

; Draw blue car
draw_blue_car:
    mov ax, 0xA000
    mov es, ax
    
    ; Calculate position in video memory
    mov ax, [blue_car_y]
    imul ax, 320
    add ax, [blue_car_x]
    mov di, ax
    
    ; Draw a simple 5x3 blue car
    mov al, 1               ; Blue color
    
    ; Row 1
    stosb
    stosb
    stosb
    stosb
    stosb
    
    ; Row 2
    add di, 320-5
    stosb
    stosb
    stosb
    stosb
    stosb
    
    ; Row 3
    add di, 320-5
    stosb
    stosb
    stosb
    stosb
    stosb
    
    ret

; Draw UI (lap counter)
draw_ui:
    ; This is a simplified UI - just pixel-based lap indicators
    mov ax, 0xA000
    mov es, ax
    
    ; Red car laps (top left)
    mov cx, [red_car_lap]
    mov bx, 0
.red_laps:
    cmp bx, cx
    jge .blue_laps_start
      ; Draw red dot for each lap
    ; Calculate position: (5 + bx * 10) * 320 + 10
    mov ax, bx
    mov dx, 10
    mul dx              ; ax = bx * 10
    add ax, 5           ; ax = 5 + bx * 10
    mov dx, 320
    mul dx              ; ax = (5 + bx * 10) * 320
    add ax, 10          ; ax = (5 + bx * 10) * 320 + 10
    mov di, ax
    mov al, 4               ; Red
    stosb
    stosb
    add di, 320-2
    stosb
    stosb
    
    inc bx
    jmp .red_laps

.blue_laps_start:
    ; Blue car laps (top right)
    mov cx, [blue_car_lap]
    mov bx, 0
.blue_laps:
    cmp bx, cx
    jge .ui_done
      ; Draw blue dot for each lap
    ; Calculate position: (5 + bx * 10) * 320 + 300
    mov ax, bx
    mov dx, 10
    mul dx              ; ax = bx * 10
    add ax, 5           ; ax = 5 + bx * 10
    mov dx, 320
    mul dx              ; ax = (5 + bx * 10) * 320
    add ax, 300         ; ax = (5 + bx * 10) * 320 + 300
    mov di, ax
    mov al, 1               ; Blue
    stosb
    stosb
    add di, 320-2
    stosb
    stosb
    
    inc bx
    jmp .blue_laps

.ui_done:
    ret

; Show winner screen
show_winner_screen:
    ; Clear center area
    mov ax, 0xA000
    mov es, ax
    
    ; Draw winner box
    mov bx, 80              ; Start y
.winner_box:
    mov di, bx
    imul di, 320
    add di, 100             ; x = 100
    mov cx, 120             ; width
    
    cmp byte [winner], 1
    je .red_winner_color
    mov al, 1               ; Blue background
    jmp .fill_line
.red_winner_color:
    mov al, 4               ; Red background
.fill_line:
    rep stosb
    inc bx
    cmp bx, 120
    jl .winner_box
      ret

; Check track collision function
; Input: AX = car X position, BX = car Y position (including car size 5x3)
; Output: AL = 1 if collision, 0 if no collision
check_track_collision:
    ; Check screen boundaries first
    cmp ax, 5               ; Left boundary (car is 5 pixels wide)
    jl .collision
    cmp ax, 315             ; Right boundary (320 - 5)
    jg .collision
    cmp bx, 5               ; Top boundary (car is 3 pixels tall)
    jl .collision
    cmp bx, 197             ; Bottom boundary (200 - 3)
    jg .collision
    
    ; Check outer track boundaries
    ; If car is inside outer boundary area (20-300 x, 20-170 y)
    cmp ax, 20
    jl .no_collision        ; Left of track
    cmp ax, 295             ; 300 - 5 (car width)
    jg .no_collision        ; Right of track
    cmp bx, 20
    jl .no_collision        ; Above track
    cmp bx, 167             ; 170 - 3 (car height)
    jg .no_collision        ; Below track
    
    ; Car is within outer boundaries, check if in track area
    ; Check if car is in the racing lane (between outer and inner boundaries)
    
    ; Top section of track (Y: 20-60)
    cmp bx, 57              ; 60 - 3 (car height)
    jg .check_bottom_section
    ; In top section, just check outer boundaries (already done above)
    jmp .no_collision
    
.check_bottom_section:
    ; Bottom section of track (Y: 130-170)
    cmp bx, 130
    jl .check_side_sections
    ; In bottom section, just check outer boundaries (already done above)
    jmp .no_collision
    
.check_side_sections:
    ; Middle section (Y: 60-130), check if in side corridors
    ; Left corridor (X: 20-60)
    cmp ax, 55              ; 60 - 5 (car width)
    jg .check_right_corridor
    jmp .no_collision
    
.check_right_corridor:
    ; Right corridor (X: 260-300)
    cmp ax, 260
    jl .collision           ; Car is in the inner area (blocked)
    jmp .no_collision
    
.collision:
    mov al, 1               ; Collision detected
    ret
    
.no_collision:
    mov al, 0               ; No collision
    ret

; Print string function (for text mode)
print_string:
    pusha
.print_loop:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    jmp .print_loop
.done:
    popa
    ret

; Game variables
red_car_x       dw 50
red_car_y       dw 100
red_car_lap     dw 0

blue_car_x      dw 50
blue_car_y      dw 120
blue_car_lap    dw 0

game_over       db 0
winner          db 0        ; 1 = red, 2 = blue

; Messages
exit_msg        db 'Game Over! Thanks for playing!', 0x0D, 0x0A, 0

; Pad the file to fill sectors as needed
times 2048 - ($-$$) db 0