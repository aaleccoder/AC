; Racing Game - Second Stage Bootloader
; Juego de carreras de dos autos controlados por el mismo teclado
; Auto rojo: WASD, Auto azul: Flechas

BITS 16
ORG 0x0000          ; Cargado en 0x0800:0x0000

start:
    call show_warning_message
    ; Configura el modo de video VGA 320x200 256 colores
    mov ax, 0x13        ; 320x200 256-color VGA mode
    int 0x10

    ; Configura los segmentos de datos y extra
    mov ax, 0x0800
    mov ds, ax
    mov es, ax
    
    ; Inicializa las variables del juego
    call init_game
    
    ; Bucle principal del juego
game_loop:
    call handle_input        ; Lee y procesa la entrada del teclado
    call draw_screen         ; Dibuja todo en pantalla
    
    ; Pequeño retardo para controlar la velocidad
    mov cx, 0x1000
delay_loop:
    loop delay_loop
    
    jmp game_loop            ; Repite el bucle principal

; Inicializa variables del juego
init_game:
    ; Posición del auto rojo (Jugador 1) - Fila 1
    mov word [red_car_x], 10
    mov word [red_car_y], 55      ; Primera fila (entre Y=40 y Y=80)
    mov byte [red_car_lane], 0     ; Fila actual (0, 1, 2)
    
    ; Posición del auto azul (Jugador 2) - Fila 1
    mov word [blue_car_x], 10
    mov word [blue_car_y], 60      ; Primera fila, ligeramente más abajo
    mov byte [blue_car_lane], 0    ; Fila actual (0, 1, 2)
    
    ; Estado del juego
    mov byte [game_over], 0
    mov byte [winner], 0
    
    ret

; Rutina para manejar la entrada del teclado
handle_input:
    ; Verifica si hay una tecla disponible (sin esperar)
    mov ah, 0x01
    int 0x16
    jz .no_key
    
    ; Obtiene el código de la tecla y el scan code
    mov ah, 0x00
    int 0x16    ; Lógica de control para ambos autos
    ; WASD controla el auto rojo (arriba/abajo/izquierda/derecha)
    cmp al, 'w'
    je .red_up
    cmp al, 's'
    je .red_down
    cmp al, 'a'
    je .red_left
    cmp al, 'd'
    je .red_right
    
    ; Flechas controlan el auto azul (scan codes) (arriba/abajo/izquierda/derecha)
    cmp ah, 0x48        ; Flecha arriba
    je .blue_up
    cmp ah, 0x50        ; Flecha abajo
    je .blue_down
    cmp ah, 0x4B        ; Flecha izquierda
    je .blue_left
    cmp ah, 0x4D        ; Flecha derecha
    je .blue_right
      ; ESC para salir
    cmp ah, 0x01
    je .exit_game
    jmp .no_key

.red_up:
    ; Mueve el auto rojo hacia arriba
    mov ax, [red_car_y]
    sub ax, 3           ; Nueva posición Y
    ; Verifica límite superior según la fila actual
    mov bl, [red_car_lane]
    cmp bl, 0
    je .red_up_lane_0
    cmp bl, 1
    je .red_up_lane_1
    cmp bl, 2
    je .red_up_lane_2
    jmp .no_key

.red_up_lane_0:
    cmp ax, 42          ; Límite superior fila 0 (Y=40 + 2)
    jle .no_key
    ; Verifica colisión con obstáculos antes de moverse
    mov ax, [red_car_y]
    sub ax, 3           ; Nueva posición Y
    mov bx, [red_car_x] ; Posición X actual
    call check_red_collision
    cmp al, 1
    je .no_key
    sub word [red_car_y], 3
    jmp .no_key

.red_up_lane_1:
    cmp ax, 82          ; Límite superior fila 1 (Y=80 + 2)
    jle .no_key
    ; Verifica colisión con obstáculos antes de moverse
    mov ax, [red_car_y]
    sub ax, 3           ; Nueva posición Y
    mov bx, [red_car_x] ; Posición X actual
    call check_red_collision
    cmp al, 1
    je .no_key
    sub word [red_car_y], 3
    jmp .no_key

.red_up_lane_2:
    cmp ax, 132         ; Límite superior fila 2 (Y=130 + 2)
    jle .no_key
    ; Verifica colisión con obstáculos antes de moverse
    mov ax, [red_car_y]
    sub ax, 3           ; Nueva posición Y
    mov bx, [red_car_x] ; Posición X actual
    call check_red_collision
    cmp al, 1
    je .no_key
    sub word [red_car_y], 3
    jmp .no_key

.red_down:
    ; Mueve el auto rojo hacia abajo
    mov ax, [red_car_y]
    add ax, 3           ; Nueva posición Y
    ; Verifica límite inferior según la fila actual
    mov bl, [red_car_lane]
    cmp bl, 0
    je .red_down_lane_0
    cmp bl, 1
    je .red_down_lane_1
    cmp bl, 2
    je .red_down_lane_2
    jmp .no_key

.red_down_lane_0:
    cmp ax, 75          ; Límite inferior fila 0 (Y=80 - 5)
    jge .no_key
    ; Verifica colisión con obstáculos antes de moverse
    mov ax, [red_car_y]
    add ax, 3           ; Nueva posición Y
    mov bx, [red_car_x] ; Posición X actual
    call check_red_collision
    cmp al, 1
    je .no_key
    add word [red_car_y], 3
    jmp .no_key

.red_down_lane_1:
    cmp ax, 125         ; Límite inferior fila 1 (Y=130 - 5)
    jge .no_key
    ; Verifica colisión con obstáculos antes de moverse
    mov ax, [red_car_y]
    add ax, 3           ; Nueva posición Y
    mov bx, [red_car_x] ; Posición X actual
    call check_red_collision
    cmp al, 1
    je .no_key
    add word [red_car_y], 3
    jmp .no_key

.red_down_lane_2:
    cmp ax, 165         ; Límite inferior fila 2 (Y=170 - 5)
    jge .no_key
    ; Verifica colisión con obstáculos antes de moverse
    mov ax, [red_car_y]
    add ax, 3           ; Nueva posición Y
    mov bx, [red_car_x] ; Posición X actual
    call check_red_collision
    cmp al, 1
    je .no_key
    add word [red_car_y], 3
    jmp .no_key

.red_left:
    ; Mueve el auto rojo hacia la izquierda
    mov ax, [red_car_x]
    cmp ax, 10          ; Límite izquierdo
    jle .no_key
    ; Verifica colisión con obstáculos antes de moverse
    sub ax, 6           ; Nueva posición X
    mov bx, [red_car_y] ; Posición Y actual
    call check_red_collision_at_pos
    cmp al, 1
    je .no_key
    sub word [red_car_x], 6
    jmp .no_key
    
.red_right:
    ; Mueve el auto rojo hacia la derecha
    mov ax, [red_car_x]
    cmp ax, 305         ; Límite derecho (320-15 para el auto)
    jge .check_red_advance
    ; Verifica colisión con obstáculos antes de moverse
    add ax, 6           ; Nueva posición X
    mov bx, [red_car_y] ; Posición Y actual
    call check_red_collision_at_pos
    cmp al, 1
    je .no_key
    add word [red_car_x], 6
    jmp .no_key

.check_red_advance:
    ; El auto rojo llegó al final de la fila
    mov al, [red_car_lane]
    cmp al, 2           ; ¿Está en la última fila?
    je .red_wins
    
    ; Avanza a la siguiente fila
    inc byte [red_car_lane]
    mov word [red_car_x], 10    ; Reinicia en el lado izquierdo
    
    ; Calcula nueva posición Y basada en la fila
    mov al, [red_car_lane]
    cmp al, 1
    je .red_lane_1
    cmp al, 2
    je .red_lane_2
    jmp .no_key

.red_lane_1:
    mov word [red_car_y], 105     ; Segunda fila (entre Y=80 y Y=130)
    jmp .no_key
    
.red_lane_2:
    mov word [red_car_y], 145     ; Tercera fila (entre Y=130 y Y=170)
    jmp .no_key

.red_wins:
    ; El auto rojo ganó
    mov byte [game_over], 1
    mov byte [winner], 1        ; 1 = rojo ganó
    jmp .exit_game

.blue_up:
    ; Mueve el auto azul hacia arriba
    mov ax, [blue_car_y]
    ; Verifica límite superior según la fila actual
    mov bl, [blue_car_lane]
    cmp bl, 0
    je .blue_up_lane_0
    cmp bl, 1
    je .blue_up_lane_1
    cmp bl, 2
    je .blue_up_lane_2
    jmp .no_key

.blue_up_lane_0:
    cmp ax, 42          ; Límite superior fila 0 (Y=40 + 2)
    jle .no_key
    ; Verifica colisión con obstáculos antes de moverse
    mov ax, [blue_car_y]
    sub ax, 3           ; Nueva posición Y
    mov bx, [blue_car_x] ; Posición X actual
    call check_blue_collision
    cmp al, 1
    je .no_key
    sub word [blue_car_y], 3
    jmp .no_key

.blue_up_lane_1:
    cmp ax, 82          ; Límite superior fila 1 (Y=80 + 2)
    jle .no_key
    ; Verifica colisión con obstáculos antes de moverse
    mov ax, [blue_car_y]
    sub ax, 3           ; Nueva posición Y
    mov bx, [blue_car_x] ; Posición X actual
    call check_blue_collision
    cmp al, 1
    je .no_key
    sub word [blue_car_y], 3
    jmp .no_key

.blue_up_lane_2:
    cmp ax, 132         ; Límite superior fila 2 (Y=130 + 2)
    jle .no_key
    ; Verifica colisión con obstáculos antes de moverse
    mov ax, [blue_car_y]
    sub ax, 3           ; Nueva posición Y
    mov bx, [blue_car_x] ; Posición X actual
    call check_blue_collision
    cmp al, 1
    je .no_key
    sub word [blue_car_y], 3
    jmp .no_key

.blue_down:
    ; Mueve el auto azul hacia abajo
    mov ax, [blue_car_y]
    add ax, 3           ; Nueva posición Y
    ; Verifica límite inferior según la fila actual
    mov bl, [blue_car_lane]
    cmp bl, 0
    je .blue_down_lane_0
    cmp bl, 1
    je .blue_down_lane_1
    cmp bl, 2
    je .blue_down_lane_2
    jmp .no_key

.blue_down_lane_0:
    cmp ax, 75          ; Límite inferior fila 0 (Y=80 - 5)
    jge .no_key
    ; Verifica colisión con obstáculos antes de moverse
    mov ax, [blue_car_y]
    add ax, 3           ; Nueva posición Y
    mov bx, [blue_car_x] ; Posición X actual
    call check_blue_collision
    cmp al, 1
    je .no_key
    add word [blue_car_y], 3
    jmp .no_key

.blue_down_lane_1:
    cmp ax, 125         ; Límite inferior fila 1 (Y=130 - 5)
    jge .no_key
    ; Verifica colisión con obstáculos antes de moverse
    mov ax, [blue_car_y]
    add ax, 3           ; Nueva posición Y
    mov bx, [blue_car_x] ; Posición X actual
    call check_blue_collision
    cmp al, 1
    je .no_key
    add word [blue_car_y], 3
    jmp .no_key

.blue_down_lane_2:
    cmp ax, 165         ; Límite inferior fila 2 (Y=170 - 5)
    jge .no_key
    ; Verifica colisión con obstáculos antes de moverse
    mov ax, [blue_car_y]
    add ax, 3           ; Nueva posición Y
    mov bx, [blue_car_x] ; Posición X actual
    call check_blue_collision
    cmp al, 1
    je .no_key
    add word [blue_car_y], 3
    jmp .no_key

.blue_left:
    ; Mueve el auto azul hacia la izquierda
    mov ax, [blue_car_x]
    cmp ax, 10          ; Límite izquierdo
    jle .no_key
    ; Verifica colisión con obstáculos antes de moverse
    sub ax, 6           ; Nueva posición X
    mov bx, [blue_car_y] ; Posición Y actual
    call check_blue_collision_at_pos
    cmp al, 1
    je .no_key
    sub word [blue_car_x], 6
    jmp .no_key
    
.blue_right:
    ; Mueve el auto azul hacia la derecha
    mov ax, [blue_car_x]
    cmp ax, 305         ; Límite derecho (320-15 para el auto)
    jge .check_blue_advance
    ; Verifica colisión con obstáculos antes de moverse
    add ax, 6           ; Nueva posición X
    mov bx, [blue_car_y] ; Posición Y actual
    call check_blue_collision_at_pos
    cmp al, 1
    je .no_key
    add word [blue_car_x], 6
    jmp .no_key

.check_blue_advance:
    ; El auto azul llegó al final de la fila
    mov al, [blue_car_lane]
    cmp al, 2           ; ¿Está en la última fila?
    je .blue_wins
    
    ; Avanza a la siguiente fila
    inc byte [blue_car_lane]
    mov word [blue_car_x], 10   ; Reinicia en el lado izquierdo
    
    ; Calcula nueva posición Y basada en la fila
    mov al, [blue_car_lane]
    cmp al, 1
    je .blue_lane_1
    cmp al, 2
    je .blue_lane_2
    jmp .no_key

.blue_lane_1:
    mov word [blue_car_y], 110    ; Segunda fila, ligeramente más abajo que el rojo
    jmp .no_key
    
.blue_lane_2:
    mov word [blue_car_y], 150    ; Tercera fila, ligeramente más abajo que el rojo
    jmp .no_key

.blue_wins:
    ; El auto azul ganó
    mov byte [game_over], 1
    mov byte [winner], 2        ; 2 = azul ganó
    jmp .exit_game

.exit_game:
    ; Vuelve al modo texto y muestra mensaje de salida
    mov ax, 0x03
    int 0x10
    mov si, exit_msg
    call print_string
    cli
    hlt

.no_key:
    ret

; Dibuja toda la pantalla
; Borra pantalla, dibuja el circuito y los autos
draw_screen:
    ; Verifica si el juego terminó
    cmp byte [game_over], 1
    je .show_winner
    
    ; Borra pantalla (fondo negro)
    call clear_screen
    ; Dibuja instrucciones de controles
    call draw_instructions
    ; Dibuja el circuito (líneas blancas)
    call draw_track
    
    ; Dibuja los obstáculos
    call draw_obstacles
    
    ; Dibuja los autos
    call draw_red_car
    call draw_blue_car
    
    ret

.show_winner:
    call clear_screen
    
    ; Muestra mensaje de ganador
    mov al, [winner]
    cmp al, 1
    je .red_won
    cmp al, 2
    je .blue_won
    ret

.red_won:
    ; Dibuja mensaje "RED WINS!" en el centro
    mov di, 160*100 + 140  ; Centro aproximado
    mov al, 4              ; Color rojo
    call draw_win_message
    ret
    
.blue_won:
    ; Dibuja mensaje "BLUE WINS!" en el centro
    mov di, 160*100 + 140  ; Centro aproximado
    mov al, 1              ; Color azul
    call draw_win_message
    ret

; Borra la pantalla con color negro
clear_screen:
    mov ax, 0xA000      ; Segmento de memoria VGA
    mov es, ax
    xor di, di          ; Inicio de la memoria de video
    mov cx, 64000       ; 320*200 pixeles
    mov al, 0           ; Color negro
    rep stosb
    ret

; Dibuja el circuito con tres filas delimitadas por líneas blancas
draw_track:
    mov ax, 0xA000
    mov es, ax
    
    ; Dibuja líneas horizontales blancas para delimitar las filas
    mov al, 15          ; Color blanco
    
    ; Línea superior (Y=40)
    mov di, 40*320 + 5
    mov cx, 310
    rep stosb
    
    ; Línea entre fila 1 y 2 (Y=80)
    mov di, 80*320 + 5
    mov cx, 310
    rep stosb
    
    ; Línea entre fila 2 y 3 (Y=130)
    mov di, 130*320 + 5
    mov cx, 310
    rep stosb
    
    ; Línea inferior (Y=170)
    mov di, 170*320 + 5
    mov cx, 310
    rep stosb
      ; Dibuja líneas verticales en los extremos
    ; Línea izquierda (X=5) - línea VERTICAL real
    mov cx, 130         ; Altura total del circuito
    mov di, 40*320 + 5
.left_line:
    mov byte [es:di], 15
    add di, 320         ; Siguiente fila (movimiento vertical)
    loop .left_line
    
    ; Línea derecha (X=315) - línea VERTICAL real
    mov cx, 130
    mov di, 40*320 + 315
.right_line:
    mov byte [es:di], 15
    add di, 320         ; Siguiente fila (movimiento vertical)
    loop .right_line
    ret

; Dibuja todos los obstáculos como líneas blancas (varios verticales por fila, diferentes tamaños y posiciones)
draw_obstacles:
    mov ax, 0xA000
    mov es, ax

    ; === Fila 0: Y=52-68 (17px) ===
    ; Obstáculo 1: X=70, Y=52-68 (más corto, izquierda)
    mov cx, 17
    mov di, 52*320 + 70
.obs0_1:
    mov al, 15
    mov [es:di], al
    add di, 320
    loop .obs0_1

    ; Obstáculo 2: X=150, Y=50-70 (21px, centro)
    mov cx, 21
    mov di, 50*320 + 150
.obs0_2:
    mov al, 15
    mov [es:di], al
    add di, 320
    loop .obs0_2

    ; Obstáculo 3: X=230, Y=55-65 (11px, derecha)
    mov cx, 11
    mov di, 55*320 + 230
.obs0_3:
    mov al, 15
    mov [es:di], al
    add di, 320
    loop .obs0_3

    ; === Fila 1: Y=102-118 (17px) ===
    ; Obstáculo 1: X=110, Y=102-118 (más corto, izquierda)
    mov cx, 17
    mov di, 102*320 + 110
.obs1_1:
    mov al, 15
    mov [es:di], al
    add di, 320
    loop .obs1_1

    ; Obstáculo 2: X=170, Y=100-120 (21px, centro)
    mov cx, 21
    mov di, 100*320 + 170
.obs1_2:
    mov al, 15
    mov [es:di], al
    add di, 320
    loop .obs1_2

    ; Obstáculo 3: X=210, Y=105-115 (11px, derecha)
    mov cx, 11
    mov di, 105*320 + 210
.obs1_3:
    mov al, 15
    mov [es:di], al
    add di, 320
    loop .obs1_3

    ; === Fila 2: Y=148-162 (15px) ===
    ; Obstáculo 1: X=65, Y=148-162 (más corto, izquierda)
    mov cx, 15
    mov di, 148*320 + 65
.obs2_1:
    mov al, 15
    mov [es:di], al
    add di, 320
    loop .obs2_1

    ; Obstáculo 2: X=180, Y=145-165 (21px, centro)
    mov cx, 21
    mov di, 145*320 + 180
.obs2_2:
    mov al, 15
    mov [es:di], al
    add di, 320
    loop .obs2_2

    ; Obstáculo 3: X=250, Y=150-160 (11px, derecha)
    mov cx, 11
    mov di, 150*320 + 250
.obs2_3:
    mov al, 15
    mov [es:di], al
    add di, 320
    loop .obs2_3

    ret

; Funciones de detección de colisión simples
; Verifica colisión del auto rojo en su posición actual
; AX = Y actual, BX = X actual
; Retorna AL = 1 si hay colisión, 0 si no
check_red_collision:
    ; Verifica según la fila actual
    mov cl, [red_car_lane]
    cmp cl, 0
    je .check_lane_0
    cmp cl, 1
    je .check_lane_1
    cmp cl, 2
    je .check_lane_2
    mov al, 0
    ret

.check_lane_0:
    ; Obstáculo 1: X=70, Y=52-68 (considerando el tamaño del auto 5x3)
    cmp ax, 50
    jl .chk0_2
    cmp ax, 70
    jg .chk0_2
    cmp bx, 66          ; 70-4 (ancho del auto)
    jl .chk0_2
    cmp bx, 74          ; 70+4
    jle .col
.chk0_2:
    ; Obstáculo 2: X=150, Y=50-70 (considerando el tamaño del auto 5x3)
    cmp ax, 48
    jl .chk0_3
    cmp ax, 72
    jg .chk0_3
    cmp bx, 146         ; 150-4
    jl .chk0_3
    cmp bx, 154         ; 150+4
    jle .col
.chk0_3:
    ; Obstáculo 3: X=230, Y=55-65 (considerando el tamaño del auto 5x3)
    cmp ax, 53
    jl .no_collision_0
    cmp ax, 67
    jg .no_collision_0
    cmp bx, 226         ; 230-4
    jl .no_collision_0
    cmp bx, 234         ; 230+4
    jle .col
    jmp .no_collision_0

.col:
    mov al, 1
    ret

.check_lane_1:
    ; Obstáculo 1: X=110, Y=102-118 (considerando el tamaño del auto 5x3)
    cmp ax, 100
    jl .chk1_2
    cmp ax, 120
    jg .chk1_2
    cmp bx, 106         ; 110-4
    jl .chk1_2
    cmp bx, 114         ; 110+4
    jle .col
.chk1_2:
    ; Obstáculo 2: X=170, Y=100-120 (considerando el tamaño del auto 5x3)
    cmp ax, 98
    jl .chk1_3
    cmp ax, 122
    jg .chk1_3
    cmp bx, 166         ; 170-4
    jl .chk1_3
    cmp bx, 174         ; 170+4
    jle .col
.chk1_3:
    ; Obstáculo 3: X=210, Y=105-115 (considerando el tamaño del auto 5x3)
    cmp ax, 103
    jl .no_collision_1
    cmp ax, 117
    jg .no_collision_1
    cmp bx, 206         ; 210-4
    jl .no_collision_1
    cmp bx, 214         ; 210+4
    jle .col
    jmp .no_collision_1

.check_lane_2:
    ; Obstáculo 1: X=65, Y=148-162 (considerando el tamaño del auto 5x3)
    cmp ax, 146
    jl .chk2_2
    cmp ax, 164
    jg .chk2_2
    cmp bx, 61          ; 65-4
    jl .chk2_2
    cmp bx, 69          ; 65+4
    jle .col
.chk2_2:
    ; Obstáculo 2: X=180, Y=145-165 (considerando el tamaño del auto 5x3)
    cmp ax, 143
    jl .chk2_3
    cmp ax, 167
    jg .chk2_3
    cmp bx, 176         ; 180-4
    jl .chk2_3
    cmp bx, 184         ; 180+4
    jle .col
.chk2_3:
    ; Obstáculo 3: X=250, Y=150-160 (considerando el tamaño del auto 5x3)
    cmp ax, 148
    jl .no_collision_2
    cmp ax, 162
    jg .no_collision_2
    cmp bx, 246         ; 250-4
    jl .no_collision_2
    cmp bx, 254         ; 250+4
    jle .col
    jmp .no_collision_2

.no_collision_0:
.no_collision_1:
.no_collision_2:
    mov al, 0
    ret

; Verifica colisión del auto rojo en una posición específica
check_red_collision_at_pos:
    ; AX contiene la nueva X 
    ; BX contiene Y actual
    ; Necesitamos intercambiar para usar la función anterior correctamente
    ; La función expect AX=Y, BX=X
    xchg ax, bx     ; Ahora AX=Y, BX=X (como espera check_red_collision)
    call check_red_collision
    ret

; Verifica colisión del auto azul en su posición actual
; AX = Y actual, BX = X actual
; Retorna AL = 1 si hay colisión, 0 si no
check_blue_collision:
    ; Verifica según la fila actual
    mov cl, [blue_car_lane]
    cmp cl, 0
    je .check_lane_0_blue
    cmp cl, 1
    je .check_lane_1_blue
    cmp cl, 2
    je .check_lane_2_blue
    mov al, 0
    ret

.check_lane_0_blue:
    ; Obstáculo 1: X=70, Y=52-68 (considerando el tamaño del auto 5x3)
    cmp ax, 50
    jl .chk0_2_blue
    cmp ax, 70
    jg .chk0_2_blue
    cmp bx, 66          ; 70-4 (ancho del auto)
    jl .chk0_2_blue
    cmp bx, 74          ; 70+4
    jle .col_blue
.chk0_2_blue:
    ; Obstáculo 2: X=150, Y=50-70 (considerando el tamaño del auto 5x3)
    cmp ax, 48
    jl .chk0_3_blue
    cmp ax, 72
    jg .chk0_3_blue
    cmp bx, 146         ; 150-4
    jl .chk0_3_blue
    cmp bx, 154         ; 150+4
    jle .col_blue
.chk0_3_blue:
    ; Obstáculo 3: X=230, Y=55-65 (considerando el tamaño del auto 5x3)
    cmp ax, 53
    jl .no_collision_0_blue
    cmp ax, 67
    jg .no_collision_0_blue
    cmp bx, 226         ; 230-4
    jl .no_collision_0_blue
    cmp bx, 234         ; 230+4
    jle .col_blue
    jmp .no_collision_0_blue

.col_blue:
    mov al, 1
    ret

.check_lane_1_blue:
    ; Obstáculo 1: X=110, Y=102-118 (considerando el tamaño del auto 5x3)
    cmp ax, 100
    jl .chk1_2_blue
    cmp ax, 120
    jg .chk1_2_blue
    cmp bx, 106         ; 110-4
    jl .chk1_2_blue
    cmp bx, 114         ; 110+4
    jle .col_blue
.chk1_2_blue:
    ; Obstáculo 2: X=170, Y=100-120 (considerando el tamaño del auto 5x3)
    cmp ax, 98
    jl .chk1_3_blue
    cmp ax, 122
    jg .chk1_3_blue
    cmp bx, 166         ; 170-4
    jl .chk1_3_blue
    cmp bx, 174         ; 170+4
    jle .col_blue
.chk1_3_blue:
    ; Obstáculo 3: X=210, Y=105-115 (considerando el tamaño del auto 5x3)
    cmp ax, 103
    jl .no_collision_1_blue
    cmp ax, 117
    jg .no_collision_1_blue
    cmp bx, 206         ; 210-4
    jl .no_collision_1_blue
    cmp bx, 214         ; 210+4
    jle .col_blue
    jmp .no_collision_1_blue

.check_lane_2_blue:
    ; Obstáculo 1: X=65, Y=148-162 (considerando el tamaño del auto 5x3)
    cmp ax, 146
    jl .chk2_2_blue
    cmp ax, 164
    jg .chk2_2_blue
    cmp bx, 61          ; 65-4
    jl .chk2_2_blue
    cmp bx, 69          ; 65+4
    jle .col_blue
.chk2_2_blue:
    ; Obstáculo 2: X=180, Y=145-165 (considerando el tamaño del auto 5x3)
    cmp ax, 143
    jl .chk2_3_blue
    cmp ax, 167
    jg .chk2_3_blue
    cmp bx, 176         ; 180-4
    jl .chk2_3_blue
    cmp bx, 184         ; 180+4
    jle .col_blue
.chk2_3_blue:
    ; Obstáculo 3: X=250, Y=150-160 (considerando el tamaño del auto 5x3)
    cmp ax, 148
    jl .no_collision_2_blue
    cmp ax, 162
    jg .no_collision_2_blue
    cmp bx, 246         ; 250-4
    jl .no_collision_2_blue
    cmp bx, 254         ; 250+4
    jle .col_blue
    jmp .no_collision_2_blue

.no_collision_0_blue:
.no_collision_1_blue:
.no_collision_2_blue:
    mov al, 0
    ret

; Verifica colisión del auto azul en una posición específica
check_blue_collision_at_pos:
    ; AX contiene la nueva X 
    ; BX contiene Y actual
    ; Necesitamos intercambiar para usar la función anterior correctamente
    ; La función expect AX=Y, BX=X
    xchg ax, bx     ; Ahora AX=Y, BX=X (como espera check_blue_collision)
    call check_blue_collision
    ret

; Dibuja mensaje de victoria
draw_win_message:
    mov ax, 0xA000
    mov es, ax
    
    ; Dibuja un rectángulo simple para representar "WINS!"
    mov di, 160*100 + 140
    mov cx, 40          ; Ancho
    mov dx, 20          ; Alto
    
.draw_msg_loop:
    push cx
    push di
.draw_msg_row:
    mov [es:di], al
    inc di
    loop .draw_msg_row
    pop di
    pop cx
    add di, 320
    dec dx
    jnz .draw_msg_loop
    
    ret
    add di, 320
    dec dx
    jnz .draw_msg_loop
    
    ret

; Dibuja el auto rojo (5x3 pixeles)
draw_red_car:
    mov ax, 0xA000
    mov es, ax
    
    ; Calcula posición en memoria de video
    mov ax, [red_car_y]
    imul ax, 320
    add ax, [red_car_x]
    mov di, ax
    
    ; Dibuja el auto rojo (color 4)
    mov al, 4
    
    ; Fila 1
    stosb
    stosb
    stosb
    stosb
    stosb
    
    ; Fila 2
    add di, 320-5
    stosb
    stosb
    stosb
    stosb
    stosb
    
    ; Fila 3
    add di, 320-5
    stosb
    stosb
    stosb
    stosb
    stosb
    
    ret

; Dibuja el auto azul (5x3 pixeles)
draw_blue_car:
    mov ax, 0xA000
    mov es, ax
    
    ; Calcula posición en memoria de video
    mov ax, [blue_car_y]
    imul ax, 320
    add ax, [blue_car_x]
    mov di, ax
    
    ; Dibuja el auto azul (color 1)
    mov al, 1
    
    ; Fila 1
    stosb
    stosb
    stosb
    stosb
    stosb
    
    ; Fila 2
    add di, 320-5
    stosb
    stosb
    stosb
    stosb
    stosb
    
    ; Fila 3
    add di, 320-5
    stosb
    stosb
    stosb
    stosb
    stosb
    
    ret

; Imprime una cadena en modo texto
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

; === Mensaje de advertencia antes de iniciar el juego ===
show_warning_message:
    call clear_screen
    mov si, warning_msg
    call print_string
    ; Espera a que el usuario presione una tecla
    mov ah, 0x00
    int 0x16
    ret

; === Dibuja instrucciones de controles en pantalla ===
draw_instructions:
    pusha
    mov ax, 0xA000
    mov es, ax
    ; Imprime texto en la esquina superior izquierda (modo gráfico)
    ; Línea 1: "Rojo: WASD"
    mov si, instr_red
    mov di, 10
    call draw_text_graphic
    ; Línea 2: "Azul: Flechas"
    mov si, instr_blue
    mov di, 10+320*10
    call draw_text_graphic
    popa
    ret

; === Dibuja texto en modo gráfico (simple, sin fuente real) ===
draw_text_graphic:
    ; SI = puntero a string, DI = posición en memoria de video
    mov cx, 0
.draw_text_loop:
    lodsb
    or al, al
    jz .done
    mov byte [es:di], 15 ; Blanco
    inc di
    inc cx
    cmp cx, 40
    je .done
    jmp .draw_text_loop
.done:
    ret

; === Mensajes de instrucciones y advertencia ===
instr_red db 'Rojo: WASD', 0
instr_blue db 'Azul: Flechas', 0
warning_msg db 'No mantengas una tecla presionada,',0x0D,0x0A,'o el otro carro no se movera.',0x0D,0x0A,'Presiona cualquier tecla para comenzar...',0x0D,0x0A,0

; Variables del juego
red_car_x       dw 10       ; X auto rojo
red_car_y       dw 55       ; Y auto rojo
red_car_lane    db 0        ; Fila actual del auto rojo (0, 1, 2)

blue_car_x      dw 10       ; X auto azul
blue_car_y      dw 60       ; Y auto azul
blue_car_lane   db 0        ; Fila actual del auto azul (0, 1, 2)

game_over       db 0        ; Estado de fin de juego
winner          db 0        ; Ganador (1=rojo, 2=azul)

; Mensajes
exit_msg        db 'Game Over! Thanks for playing!', 0x0D, 0x0A, 0

; Rellena el archivo para ocupar tamaño fijo
times 4096 - ($-$$) db 0