;Abdul-Rehman Naseer    23L-0787
;Mian Bilal Razzaq      23L-0812
[org 0x0100]
jmp welcome_new_game

;--------------------------------------------------------------------
; Game title and score etc...
;--------------------------------------------------------------------
game_title: db 'PAC-MAN', 0
score_text: db 'SCORE: ', 0
score_num: dw 0
score_num_win: dw 200
life_num : dw 3
level_text: db 'LEVEL: ', 0
level_num : dw 1
cursor_pos: dw 0  ; Stores cursor position to help in printing
direction_fitter: db 0
loose_life_text : db 'Loose-Life', 0 
game_over_text : db 'Game-Over',0
game_Win_text : db 'You-Won!',0
tick_counter: dw 0
ticks_per_action: dw 3 
tick_counter_PAC: dw 0
ticks_per_action_PAC: dw 0 
tick_counter_random: dw 0 
old_timer_offset: dw 0
old_timer_segment: dw 0
old_keyboard_offset: dw 0
old_keyboard_segment: dw 0
ghost_step_counter: db 0
; Additional data  for welcome screen
dev1_name:     db 'Abdul-Rehman Naseer (23L-0787)', 0
dev2_name:     db 'Mian Bilal Razzaq (23L-0812)', 0
welcome_msg:   db 'Press any key to start...', 0
;--------------------------------------------------------------------
; Ghost And PAC-MAN Data Structure
;--------------------------------------------------------------------

pacman_pos: dw 0x0880
pacman_dir: db 1
pacman_prev: dw 0x0720

ghost1_pos dw 0x0382    
ghost1_dir db 3          ; 0=up, 1=right, 2=down, 3=left
ghost1_prev dw 0x0720    ; Stores char/color under ghost (gray space)
ghost1_active db 1       ; 1=active
ghost1_color db 0x02     ; pink

ghost2_pos dw 0x0382     
ghost2_dir db 1
ghost2_prev dw 0x0720
ghost2_active db 0
ghost2_color db 0x02     

ghost3_pos dw 0x0382    
ghost3_dir db 1
ghost3_prev dw 0x0720
ghost3_active db 0
ghost3_color db 0x02     

ghost4_pos dw 0x0382   
ghost4_dir db 3
ghost4_prev dw 0x0720
ghost4_active db 0
ghost4_color db 0x02     

ghost_counter db 0       ; counts moves before releasing next ghost




;--------------------------------------------------------------------
; Map
;--------------------------------------------------------------------
row1: db '==========================================================================', 0
row2: db '||* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ||', 0
row3: db '||$====*____________ *====================*=========== ||*======*======$||', 0
row4: db '||* *  *|  _________| * * * * * * * * * * *            ||*  * * * * * * ||', 0
row5: db '||===||*| |* * * * * *_________*__________ ....   .... ||*_______*||====||', 0
row6: db '<====||*| |* <======|*|  __   |*|   __   | .@   @   @. ||*| === |*||=====>', 0
row7: db '       *| |* * * $| |*| |  |  |*|  |  |  | . . . . . . ||*|  ___|*        ', 0
row8: db '<====||*| |_______| |*| |__|  |*|  |__|  |             ||*| |___ *||=====>', 0
row9: db '||===||*|___________|*|_______|*|________|             ||*|_____|*||====||', 0
row10: db '||* * * * * * * * * * * * * * * * * * * * *<===---===> * * * * * * * * *||', 0
row11: db '||*====*================*^*===============*  *..||..* * =========*=====*||', 0
row12: db '||$ * * * * * * * * * * *^* * * * * * * * *||*  *C* *||* * * * * * * * $||', 0
row13: db '==========================================================================', 0
press_msg: db 'Press any key to Start...', 0

;--------------------------------------------------------------------
; PERMANENT-Map 
;--------------------------------------------------------------------
row21: db '==========================================================================', 0
row22: db '||* * * * * * * * * * * * * * * * $ * * * * * * * * * * * * * * * * * * ||', 0
row23: db '||$====*____________ *====================*=========== ||*======*======$||', 0
row24: db '||* *  *|  _________| * * * * * * * * * * *            ||*  * * * * * * ||', 0
row25: db '||===||*| |* * * * * *_________*__________ ....   .... ||*_______*||====||', 0
row26: db '<====||*| |* <======|*|  __   |*|   __   | . GHOSTS  . ||*| === |*||=====>', 0
row27: db '       *| |* * * $| |*| |  |  |$|  |  |  | . . . . . . ||*|  ___|*        ', 0
row28: db '<====||*| |_______| |*| |__|  |*|  |__|  |             ||*| |___ *||=====>', 0
row29: db '||===||*|___________|*|_______|*|________|             ||*|_____|*||====||', 0
row30: db '||* * * * * * * * * * * * * * * * * * * * *<===---===> * * * * * * * * *||', 0
row31: db '||*====*================*^*===============*  *..||..* * =========*=====*||', 0
row32: db '||$ * * * * * * * * * * *^* * * * * * * * *||* *C*  *||* * * * * * * * $||', 0
row33: db '==========================================================================', 0
p_press_msg: db 'Press S to Start New-Game...', 0

;--------------------------------------------------------------------
; subroutine to copy the Permanent Map in Map for new Game
;--------------------------------------------------------------------
copy_permanent_map:
    push es
    push ds
    push si
    push di
    push cx
    
    mov ax, cs
    mov ds, ax
    mov es, ax
    
    mov si, row21   
    mov di, row1    
    
    mov cx, 13
    
copy_row_loop:
    push cx
    mov cx, 82
    rep movsb
    pop cx
    
    loop copy_row_loop
    
    pop cx
    pop di
    pop si
    pop ds
    pop es
    ret

;--------------------------------------------------------------------
; subroutine to print life
;--------------------------------------------------------------------
print_life:
    push es
    push di
    push cx 
    push ax
    push bx
    
    mov ax, 0xB800
    mov es, ax
    xor di, di
    mov ah, 0x04
    mov al, 0x03
    
    mov cx, [life_num]
    jcxz .draw_empty
    rep stosw
    
.draw_empty:
    mov bx, 3
    sub bx, [life_num]
    jz .done
    
    mov cx, bx
    mov ah, 0x00
    mov al, ' '
    rep stosw
    
.done:
    pop bx
    pop ax
    pop cx
    pop di
    pop es
    ret


;--------------------------------------------------------------------
; Welcome Screen Subroutines
;--------------------------------------------------------------------
display_welcome_screen:
    pusha
    push es
    
    ;(clears screen)
    mov ax, 0x0003
    int 0x10

    ; Draw borders
    call draw_welcome_borders

    ; Print title (yellow)
    mov dh, 5
    mov dl, 36
    mov si, game_title
    mov bl, 0x0E
    call welcome_print_string_at

    ; Print developer names
    mov dh, 7
    mov dl, 25
    mov si, dev1_name
    mov bl, 0x0A
    call welcome_print_string_at

    mov dh, 8
    mov dl, 26
    mov si, dev2_name
    mov bl, 0x0B
    call welcome_print_string_at

    ; Print start message
    mov dh, 15
    mov dl, 28
    mov si, welcome_msg
    mov bl, 0x0E
    call welcome_print_string_at

    ; Wait for key and clear buffer
    mov ah, 0
    int 0x16        ; Wait for keypress
    mov ah, 0x0C    ; Flush buffer
    mov al, 0
    int 0x21
    
    pop es
    popa
    ret

draw_welcome_borders:
    pusha
    ; Top border
    mov cx, 80
    mov dl, 0
    mov dh, 0
    mov bl, 0x0E
draw_top_border:
    call welcome_set_cursor
    mov ah, 0x09
    mov al, '*'
    push cx
    mov cx, 1
    int 0x10
    pop cx
    inc dl
    loop draw_top_border

    ; Bottom border
    mov cx, 80
    mov dl, 0
    mov dh, 24
draw_bottom_border:
    call welcome_set_cursor
    mov ah, 0x09
    mov al, '*'
    push cx
    mov cx, 1
    int 0x10
    pop cx
    inc dl
    loop draw_bottom_border

    ; Side borders
    mov cx, 23
    mov dh, 1
draw_side_borders:
    mov dl, 0
    call welcome_set_cursor
    mov ah, 0x09
    mov al, '*'
    push cx
    mov cx, 1
    int 0x10
    mov dl, 79
    call welcome_set_cursor
    mov ah, 0x09
    mov al, '*'
    mov cx, 1
    int 0x10
    pop cx
    inc dh
    loop draw_side_borders
    popa
    ret

welcome_set_cursor:
    mov ah, 0x02
    mov bh, 0
    int 0x10
    ret

welcome_print_string_at:
    call welcome_set_cursor
    mov ah, 0x0E
.welcome_print_loop:
    lodsb
    test al, al
    jz .welcome_print_done
    int 0x10
    jmp .welcome_print_loop
.welcome_print_done:
    ret
;--------------------------------------------------------------------
; subroutine to clear the screen
;--------------------------------------------------------------------
clear_screen:
    push es
    push di
    push cx
    push ax
    
    mov ax, 0xB800
    mov es, ax
    xor di, di      
    
    mov ah, 0x00    
    mov al, ' '     
    mov cx, 2000
    
    rep stosw    

    mov word [cursor_pos], 0
    
    pop ax
    pop cx
    pop di
    pop es
    ret

;--------------------------------------------------------------------
; subroutine to set the cursor
;--------------------------------------------------------------------
set_cursor:
    push ax
    push bx
    
    mov al, 160
    mul dh          
    mov bx, ax
    mov ah,0
    mov al, dl
    shl al, 1       
    add bx, ax      
    
    mov [cursor_pos], bx
    
    pop bx
    pop ax
    ret

;--------------------------------------------------------------------
; subroutine to print the character
;--------------------------------------------------------------------
print_char:
    push es
    push di
    
    mov di, [cursor_pos]  
    mov cx, 0xB800
    mov es, cx
    
    mov ah, bl      
    stosw           

    mov [cursor_pos], di
    
    pop di
    pop es
    ret

;--------------------------------------------------------------------
; subroutine to print with the colors
;--------------------------------------------------------------------
print_colored_string:
    push si
    push ax
    
print_loop:
    lodsb           
    cmp al, 0       
    je print_done
    
    call print_char
    jmp print_loop
    
print_done:
    pop ax
    pop si
    ret

;--------------------------------------------------------------------
; subroutine to print the map
;--------------------------------------------------------------------
print_map_row:
    push si
    push ax
    push bx
    
char_loop:
    lodsb           
    cmp al, 0       
    je row_done
    
    mov bl, 0x0F    ; Default white
    
    cmp al, '*'     ; Dots
    je yellow
    cmp al, '|'     ; Walls
    je blue
    cmp al, '='     ; Walls
    je blue
    cmp al, '_'     ; Walls
    je blue
    cmp al, '-'     ; Walls
    je blue
    cmp al, '^'     ; Walls
    je blue
    cmp al, '.'     ; Walls
    je green
    cmp al, '@'     ; Ghosts
    je red
    cmp al, 'C'     ; Pac-Man
    je pink
    cmp al, '$'     ; Special dots
    je yellow
    
    jmp print_it
    
yellow:
    mov bl, 0x0E    
    jmp print_it
green:
    mov bl, 0x02    
    jmp print_it
blue:
    mov bl, 0x09    
    jmp print_it
pink:
    mov bl, 0x0D    
    jmp print_it
red:
    mov bl, 0x0C    
    
print_it:
    call print_char
    jmp char_loop
    
row_done:
    mov ax, [cursor_pos]
    xor dx, dx
    mov bx, 80 * 2
    div bx
    inc ax          
    mul bx          
    mov [cursor_pos], ax
    
    pop bx
    pop ax
    pop si
    ret

;--------------------------------------------------------------------
; Initialize Ghosts with Hardcoded Positions
;--------------------------------------------------------------------
init_ghosts:
    push es
    push di
    push ax
    
    ; Ghost 1 (always active)
    mov di, [ghost1_pos]
    call get_char_at_pos
    mov [ghost1_prev], ax
    
    ; Ghost 2 
    mov di, [ghost2_pos]
    call get_char_at_pos
    mov [ghost2_prev], ax
    
    ; Ghost 3 
    mov di, [ghost3_pos]
    call get_char_at_pos
    mov [ghost3_prev], ax
    
    ; Ghost 4 
    mov di, [ghost4_pos]
    call get_char_at_pos
    mov [ghost4_prev], ax
    
    mov byte [ghost_counter], 0
    
    pop ax
    pop di
    pop es
    ret

;--------------------------------------------------------------------
; Get Character at Position 
;--------------------------------------------------------------------
get_char_at_pos:
    push es
    mov ax, 0xB800
    mov es, ax
    mov ax, [es:di]
    pop es
    ret

;--------------------------------------------------------------------
; Move All Active Ghosts
;--------------------------------------------------------------------
move_ghosts:
    pusha
    
    inc byte [ghost_counter]
    cmp byte [ghost_counter], 20
    jb .move_active
    mov byte [ghost_counter], 0
    call release_ghost

.move_active:
    ; Move ghost1 (always active)
    mov di, [ghost1_pos]
    mov al, [ghost1_dir]
    mov bl, [ghost1_color]
    lea si, [ghost1_dir]
    lea bp, [ghost1_prev]
    call move_single_ghost
    mov [ghost1_pos], di
    
    
    cmp byte [ghost2_active], 1
    jne .ghost3
    mov di, [ghost2_pos]
    mov al, [ghost2_dir]
    mov bl, [ghost2_color]
    lea si, [ghost2_dir]
    lea bp, [ghost2_prev]
    call move_single_ghost
    mov [ghost2_pos], di

.ghost3:
    
    cmp byte [ghost3_active], 1
    jne .ghost4
    mov di, [ghost3_pos]
    mov al, [ghost3_dir]
    mov bl, [ghost3_color]
    lea si, [ghost3_dir]
    lea bp, [ghost3_prev]
    call move_single_ghost
    mov [ghost3_pos], di

.ghost4:
    
    cmp byte [ghost4_active], 1
    jne .done
    mov di, [ghost4_pos]
    mov al, [ghost4_dir]
    mov bl, [ghost4_color]
    lea si, [ghost4_dir]
    lea bp, [ghost4_prev]
    call move_single_ghost
    mov [ghost4_pos], di

.done:
    popa
    ret

;--------------------------------------------------------------------
; Move Single Ghost
;--------------------------------------------------------------------
move_single_ghost:
    push es
    push ax
    push bx
    push dx
    push cx
    mov ax, 0xB800
    mov es, ax
    push di
    mov di, [si-2]      
    mov ax, [bp]        
    mov [es:di], ax
    pop di
	inc byte[ghost_step_counter]
	mov al,7
	cmp byte[ghost_step_counter],al
	jne .keep_moving_forward
	mov byte[ghost_step_counter],0
	mov al,[si]
	dec al
	call try_move
    jnc .move_done
.keep_moving_forward:
    mov al, [si]        
    call try_move
    jnc .move_done
    call get_random_dir
    mov [si], al        
    call try_move
    jnc .move_done
    mov cx, 4           
    mov al, 0           
.try_all_directions:
    call try_move
    jnc .dir_found
    inc al              
    and al, 3   
    loop .try_all_directions
    jmp .move_done
.dir_found:
    mov [si], al        
.move_done:
    mov [si-2], di      
    call get_char_at_pos
    mov [bp], ax        
    mov al, '@'
    mov ah, bl          
    mov [es:di], ax
    pop cx
    pop dx
    pop bx
    pop ax
    pop es
    ret

;--------------------------------------------------------------------
; Rendom Direction
;--------------------------------------------------------------------


get_random_dir:
    push bx
    push cx
    mov bx, [tick_counter_random]
    add bx, [si-2]
    mov cl, [si]        
    add cl, 2
    and cl, 3           
    mov al, bl
    and al, 3           
    cmp al, cl
    jb .got_dir
    inc al 
	
.got_dir:
    and al, 3           
    pop cx
    pop bx
    ret

;--------------------------------------------------------------------
; Try Move in Specified Direction
;--------------------------------------------------------------------
try_move:
    push bx
    push si
    mov bx, di          
    cmp al, 0           
    je .up
    cmp al, 1           
    je .right
    cmp al, 2           
    je .down
    sub di, 2           
    jmp .check
.up:
    sub di, 160
    jmp .check
.right:
    add di, 2
    jmp .check
.down:
    add di, 160
.check:
    call is_valid_move
    jc .invalid         
    clc                 
    jmp .done
.invalid:
    mov di, bx          
    stc
.done:
    pop si
    pop bx
    ret
;--------------------------------------------------------------------
; Check if Move to DI is Valid
;--------------------------------------------------------------------
is_valid_move:
    push ax
    push bx
    cmp di, 0
    jl .bad_move
    cmp di, 3998
    jg .bad_move
    mov bx, 0xB800
    mov es, bx
    mov al, [es:di]
    cmp al, '@'
    je .bad_move
    cmp al, 'C'
    je .pacman_collision
    cmp al, ' '
    je .good_move
    cmp al, '*'
    je .good_move
    cmp al, '$'
    je .good_move
.bad_move:
    stc
    jmp .exit
.pacman_collision:
    call Handle_Collision
    jmp .exit
.good_move:
    clc
.exit:
    pop bx
    pop ax
    ret

;--------------------------------------------------------------------
; Handle Ghost-PacMan Collision
;--------------------------------------------------------------------
Handle_Collision:
    pusha
    push es
    
    mov ax, 0xB800
    mov es, ax
    mov di, [pacman_pos]
    mov word [es:di], 0x0720  
    
    
    dec word [life_num]
    jnz .reset_pacman_position  
    
    
    call Display_Game_Over
    jmp .exit

.reset_pacman_position:
    call print_life
    
    
    mov di, 3272  
    mov si, loose_life_text
    mov ah, 0x04            
.print_loop:
    lodsb
    cmp al, 0
    je .delay
    stosw
    jmp .print_loop

.delay:
    mov cx, 0xFFFF
.delay_loop:
    loop .delay_loop
    call ghost_delay
    call ghost_delay
	call ghost_delay
    call ghost_delay
	call ghost_delay
    call ghost_delay
    
    
    mov di, 3272
    mov cx, 10
    mov ax, 0x0720          
.clear_loop:
    stosw
    loop .clear_loop

    
    mov di, 0x0880          
    mov [pacman_pos], di
    mov word [pacman_prev], 0x0720  
    mov word [es:di], 0x0D43 

.exit:
    call print_life
    pop es
    popa
    ret

;--------------------------------------------------------------------
; Display Game Over Screen
;--------------------------------------------------------------------
Display_Game_Over:
    pusha
    push es
    call clear_screen
	call print_score_on_end_screen
	; Print start message
    mov dh, 23      
    mov dl, 26      
    call set_cursor
    mov si, press_msg
    mov bl, 0x0F    
    call print_colored_string
	
    mov ax, 0xB800
    mov es, ax
    mov di, 1992
    mov si, game_over_text
    mov ah, 0x04        
.print_loop:
    lodsb
    cmp al, 0
    je .done
    stosw
    jmp .print_loop


.done:
    mov ah, 0
    int 16h
    
    ; Return to main menu
    pop es
    popa
    jmp new_Game

;--------------------------------------------------------------------
; Display Game Win Screen
;--------------------------------------------------------------------
Display_Game_Win:
    pusha
    push es
    call clear_screen
	call print_score_on_end_screen
   
	
	; Print start message
    mov dh, 23      
    mov dl, 26      
    call set_cursor
    mov si, press_msg
    mov bl, 0x0F    
    call print_colored_string
	
    mov ax, 0xB800
    mov es, ax
    mov di, 1992
    mov si, game_Win_text
    mov ah, 0x02        
.print_loop:
    lodsb
    cmp al, 0
    je .done
    stosw
    jmp .print_loop
	
	

.done:
    mov ah, 0
    int 16h
    ; Return to main menu
    pop es
    popa
    jmp new_Game


;--------------------------------------------------------------------
; Release Next Inactive Ghost
;--------------------------------------------------------------------
release_ghost:
    cmp byte [ghost2_active], 0
    jne .try_ghost3
    mov byte [ghost2_active], 1
    ret
    
.try_ghost3:
    cmp byte [ghost3_active], 0
    jne .try_ghost4
    mov byte [ghost3_active], 1
    ret
    
.try_ghost4:
    cmp byte [ghost4_active], 0
    jne .done
    mov byte [ghost4_active], 1
    
.done:
    ret

;--------------------------------------------------------------------
; Ghost Delay Function
;--------------------------------------------------------------------
ghost_delay:
    push cx
    mov cx, 0xFFFF
delay_loop:
    loop delay_loop
	mov cx, 0xFFFF
delay_loop1:
    loop delay_loop1
	mov cx, 0xFFFF
delay_loop2:
    loop delay_loop2
	mov cx, 0xFFFF
delay_loop3:
    loop delay_loop3
	mov cx, 0xFFFF
delay_loop4:
    loop delay_loop4
	mov cx, 0xFFFF
delay_loop5:
    loop delay_loop5
	mov cx, 0xFFFF
delay_loop6:
    loop delay_loop6
	mov cx, 0xFFFF
delay_loop7:
    loop delay_loop7
	mov cx, 0xFFFF
delay_loop8:
    loop delay_loop8
	mov cx, 0xFFFF
delay_loop9:
    loop delay_loop9
    pop cx
    ret

;--------------------------------------------------------------------
; Key-Board Interupts Handling 
;--------------------------------------------------------------------
keyboard_handler:
    push ax
    push es
    in al, 0x60
    
    ; Check for key releases 
    test al, 0x80
    jnz .exit
    
    cmp al, 0x1F        ; 'S' key
    je .reset_game
    cmp al, 0x48        ; Up arrow
    je .up_pressed
    cmp al, 0x4B        ; Left arrow
    je .left_pressed
    cmp al, 0x4D        ; Right arrow
    je .right_pressed
    cmp al, 0x50        ; Down arrow
    je .down_pressed
    jmp .exit

.reset_game:
    mov al, 0x20
    out 0x20, al
    call terminate_program
    jmp .exit  

.up_pressed:
    mov byte [pacman_dir], 0
    jmp .exit
.left_pressed:
    mov byte [pacman_dir], 3
    jmp .exit
.right_pressed:
    mov byte [pacman_dir], 1
    jmp .exit
.down_pressed:
    mov byte [pacman_dir], 2

.exit:
    mov al, 0x20
    out 0x20, al
    pop es
    pop ax
    iret

;--------------------------------------------------------------------
; Print Ticks at End
;--------------------------------------------------------------------
print_ticks:
    push ax
	push dx
    push es
	push di
	mov ax,0xB800
	mov es,ax
	mov di,3996
	mov ah,09
	xor dx,dx
	mov dx, [tick_counter]
	mov al,dl
	add al,'0'
	stosw
	pop di
	pop es
	pop dx
	pop ax
	ret
	
	
;--------------------------------------------------------------------
; Timer Interupt Subroutine
;--------------------------------------------------------------------
timer_handler:
    pusha
    push ds
    push es
    mov ax, cs           ; Set up proper segment registers
    mov ds, ax
    inc word [tick_counter]
	inc word [tick_counter_PAC]
	inc word [tick_counter_random]
    mov al, 0x20
    out 0x20, al
	pop es
    pop ds
    popa
    iret
	
	
	
;--------------------------------------------------------------------
; Pac-Man Movement
;--------------------------------------------------------------------
	
	move_pacman:
    pusha
    push es
    mov ax, 0xB800
    mov es, ax
    mov di, [pacman_pos]
    mov ax, [pacman_prev]
    mov [es:di], ax
    mov al, [pacman_dir]
    mov bx, di
    cmp al, 0
    je .up
    cmp al, 1
    je .right
    cmp al, 2
    je .down
    sub di, 2
    jmp .check
.up:
    sub di, 160
    jmp .check
.right:
    add di, 2
    jmp .check
.down:
    add di, 160
.check:
    call is_valid_move_pacman
    jc .invalid
    jmp .valid
.invalid:
    mov di, bx
.valid:
    mov [pacman_pos], di
    call get_char_at_pos
    mov al, 'C'
    mov ah, 0x0D
    mov [es:di], ax
    pop es
    popa
    ret

is_valid_move_pacman:
    push ax
    push bx
    cmp di, 0
    jl .bad_move
    cmp di, 3998
    jg .bad_move
    mov bx, 0xB800
    mov es, bx
    mov al, [es:di]
    cmp al, ' '
    je .normal_move
    cmp al, '*'
    je .good_move
    cmp al, '$'
    je .best_move
.bad_move:
    stc
    jmp .exit
.normal_move:	
    add word[score_num],0
    call print_score_on_map
    clc
    jmp .exit
.good_move:
    add word[score_num],1
    call print_score_on_map
    clc
    jmp .exit
.best_move:
    add word[score_num],5
    call print_score_on_map
    clc
.exit:
    pop bx
    pop ax
    ret

;--------------------------------------------------------------------
;  Print score
;--------------------------------------------------------------------
print_score_on_end_screen:
    push dx
    push si
    push bx
    push ax
    push cx

    ; Set cursor to row 9, column 35
    mov dh, 9
    mov dl, 35
    call set_cursor

    mov si, score_text
    mov bl, 0x0F
    call print_colored_string

    ; Now print 4-digit score
    mov ax, [score_num]     
    mov cx, 1000
    call print_digit

    mov cx, 100
    call print_digit

    mov cx, 10
    call print_digit

    mov cx, 1
    call print_digit

    pop cx
    pop ax
    pop bx
    pop si
    pop dx
    ret


print_score_on_map:
    push dx
    push si
    push bx
    push ax
    push cx

    ; Set cursor to row 0, column 68
    mov dh, 0
    mov dl, 68
    call set_cursor

    mov si, score_text
    mov bl, 0x0F
    call print_colored_string

    ; Now print 4-digit score
    mov ax, [score_num]     
    mov cx, 1000
    call print_digit

    mov cx, 100
    call print_digit

    mov cx, 10
    call print_digit

    mov cx, 1
    call print_digit

    pop cx
    pop ax
    pop bx
    pop si
    pop dx
    ret

;----------------------------------------------------
; Helper subroutine to print a single digit
; AX = score value
; CX = divisor (1000, 100, 10, 1)
;----------------------------------------------------
print_digit:
    push ax
    xor dx, dx
    div cx              ; AX / CX
                        ; Quotient -> AL, Remainder -> DX

    add al, '0'         ; Convert quotient to ASCII
    mov bl, 0x0F
    call print_char

    mov ax, dx          ; Prepare remainder for next digit
    pop dx
    ret


;--------------------------------------------------------------------
;  Reset Game State
;--------------------------------------------------------------------
reset_game_state:
    ; Reset Pac-Man
    mov word [pacman_pos], 0x0880
    mov byte [pacman_dir], 2
    mov word [pacman_prev], 0x0720

    ; Reset Ghosts
    mov word [ghost1_pos], 0x0382
    mov byte [ghost1_dir], 3
    mov word [ghost1_prev], 0x0720
    mov byte [ghost1_active], 1

    mov word [ghost2_pos], 0x0382
    mov byte [ghost2_dir], 1
    mov word [ghost2_prev], 0x0720
    mov byte [ghost2_active], 0

    mov word [ghost3_pos], 0x0382
    mov byte [ghost3_dir], 1
    mov word [ghost3_prev], 0x0720
    mov byte [ghost3_active], 0

    mov word [ghost4_pos], 0x0382
    mov byte [ghost4_dir], 3
    mov word [ghost4_prev], 0x0720
    mov byte [ghost4_active], 0

    ; Reset game variables
    mov word [score_num], 0
    mov word [life_num], 3
    mov word [tick_counter], 0
    mov byte [ghost_counter], 0
    mov word [cursor_pos], 0  
    mov word [old_keyboard_offset], 0
	mov word [old_keyboard_segment], 0
	mov word [old_timer_offset], 0
	mov word [old_timer_segment], 0
	
	
	mov ax,0
	mov bx,0
	mov cx,0
	mov dx,0
	mov es,ax
	mov di,0
	mov si,0
    ; Clear the screen properly
    call clear_screen
    ret	
	
;--------------------------------------------------------------------
; Main Game Function
;--------------------------------------------------------------------
welcome_new_game:
    call display_welcome_screen
new_Game:
	call reset_game_state
    cli
    ; Save old interrupts
    xor ax, ax
    mov es, ax
    mov ax, [es:8*4]
    mov [old_timer_offset], ax
    mov ax, [es:8*4+2]
    mov [old_timer_segment], ax
    mov ax, [es:9*4]
    mov [old_keyboard_offset], ax
    mov ax, [es:9*4+2]
    mov [old_keyboard_segment], ax
    
    ; Install new interrupts
    mov word [es:8*4], timer_handler
    mov [es:8*4+2], cs
    mov word [es:9*4], keyboard_handler
    mov [es:9*4+2], cs
    sti

    
	
    
    call copy_permanent_map
start:
    call clear_screen
    call print_life
    
    ; Print game title
    mov dh, 0       
    mov dl, 36      
    call set_cursor
    mov si, game_title
    mov bl, 0x0E    
    call print_colored_string
    
	call print_score_on_map
        
    ; Print level
    mov dh, 20       
    mov dl, 0      
    call set_cursor
    mov si, level_text
    mov bl, 0x08
    call print_colored_string
    mov al, [level_num]
    add al,'0'
    mov bl, 0x08
    call print_char
    
    ; Print map
    mov dh, 2       
    mov dl, 0       
    call set_cursor
    
    mov si, row13
    call print_map_row
	
    mov si, row2
    call print_map_row
    mov si, row3
    call print_map_row
    mov si, row4
    call print_map_row
    mov si, row5
    call print_map_row
    mov si, row6
    call print_map_row
    mov si, row7
    call print_map_row
    mov si, row8
    call print_map_row
    mov si, row9
    call print_map_row
    mov si, row10
    call print_map_row
    mov si, row11
    call print_map_row
    mov si, row12
    call print_map_row
    mov si, row13
    call print_map_row
    
    ; Print start message
    mov dh, 23      
    mov dl, 26      
    call set_cursor
    mov si, press_msg
    mov bl, 0x0F    
    call print_colored_string
    ; Initialize ghosts
    call init_ghosts

; Main game loop
game_loop:
    call print_ticks
    mov ax, [ticks_per_action]
    cmp [tick_counter], ax
    jb game_loop 
	mov word [tick_counter], 0
	push ax
	mov ax,[score_num]
	cmp ax,[score_num_win]
	je win_win
	pop ax
    call move_ghosts
	mov ax, [ticks_per_action_PAC]
    cmp [tick_counter_PAC], ax
    jb game_loop
	mov word [tick_counter_PAC], 0
	call move_pacman 
    jmp game_loop
	
win_win:
call Display_Game_Win	
;--------------------------------------------------------------------
; Close the Program
;--------------------------------------------------------------------  
terminate_programe:
;--------------------------------------------------------------------
; Restore Original Timer
;--------------------------------------------------------------------  
 terminate_program:
    cli
    xor ax, ax
    mov es, ax
    ; Restore original timer interrupt
    mov bx, 8*4
    mov ax, [old_timer_offset]
    mov [es:bx], ax
    mov ax, [old_timer_segment]
    mov [es:bx+2], ax
    ; Restore original keyboard interrupt
    mov bx, 9*4
    mov ax, [old_keyboard_offset]
    mov [es:bx], ax
    mov ax, [old_keyboard_segment]
    mov [es:bx+2], ax
    sti
	mov ah, 0x0C
    mov al, 0
    int 0x21
	call reset_game_state
    jmp new_Game  ; Jump back to start instead of exiting
	
end_Game:	
    mov ax, 0x4c00
    int 0x21