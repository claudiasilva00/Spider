org 100h            ;trabalho feito por Pedro Barroso al 71134 e Claudia Silva al 70759

.data
define_scan_num
given db 0 
B DB 8 DUP(1,2,3,4,5,6,7,8,9,10,11,12,13)   ;bararalho default(104 cartas)
c1 db 20 dup(0)
c2 db 20 dup(0) 
c3 db 20 dup(0)
c4 db 20 dup(0)              ;colunas de jogo
c5 db 20 dup(0)
c6 db 20 dup(0)
c7 db 20 dup(0)
c8 db 20 dup(0)
c9 db 20 dup(0)
c10 db 20 dup(0)
c_move db 20 dup(0)
ask_many db 10,13,"quantas cartas quer pegar?(ENTER-Confirmar/SPACE-pedir cartas)$"
ask_from db 10,13,"de que coluna quer retirar?(ENTER-Confirmar/SPACE-pedir cartas)$"
ask_to db 10,13,"para que coluna quer colocar?(ENTER-Confirmar)$"
msg_move db "move:$"
invalid_move db "Jogada Invalida!$"
n db 0
i dw 0 
from dw 0
msg_invalid_input db "Input Invalido!$"
j db 0
msg_end_game db "VOCE GANHOU!!!!$"
receive_c dw 0
msg_all_given db "Nao pode pedir mais cartas!(5 pedidos maximo)$"  
msg_given db "Pedidos Restante:$"
enter_check db 0 
condition db 0
c db 3
r db 3
box_l1 db 201,205,205,205,205,205,187,36
box_lm db 186,36
box_le db 200,205,205,205,205,205,188,36 
box_c  dw 1


shuffle     Macro        ;baralha o array b (baralho por ordem default)                    
local baralhar,ultimas3
        mov     cx, 1000      
baralhar:
        lea     SI, B    ;coloca nas variaveis o primeiro valor do array do baralho
        lea     DI, B
        push    cx
        mov     ah, 2ch  ;pede horas do sistema
        int     21h
        mov     dh, 0
        add     si, dx    ;soma os cetesimos de segundo do relogio ao apontador no primeiro segmento do B(SI) 
        mov     al, [si]
        tempo             ;funcao para fazer tempo
        mov     ah, 2ch   ;pede horas do sistema
        int     21h
        mov     dh, 0
        add     di, dx    ;soma os cetesimos de segundo do relogio ao apontador no primeiro segmento do B(SI)
        mov     bl, [di]
        mov     [si], bl  ;troca os valores de memoria no segmentos
        mov     [di], al
        pop     cx 
        loop    baralhar
        mov     cx, 3
        lea     SI, B[101]
ultimas3:
        lea     DI, B        ;faz o mesmo mas para as ultimas 3 cartas 
        push    cx
        mov     ah, 2ch
        int     21h
        mov     dh, 0
        add     di, dx
        mov     al, [si]
        mov     bl, [di]
        mov     [si], bl
        mov     [di], al
        pop     cx
        inc     si
        loop ultimas3
endm 
                          
tempo   MACRO          ;faz tempo para que os valores do relogio se alterem
local l1
        mov     cx, 10000
l1:    
        loop    l1    
endm

read    MACRO
        mov     ax, 0
        mov     ah, 1
        int     21h
        mov     ah, 0        
endm

\n      MACRO           ;print um newl e um cret
local \n
        push    ax
        push    dx
        \n:
        mov     ah, 2
    	mov     dl, 10
    	int     21h
        mov     ah, 2
    	mov     dl, 13
    	int     21h 
    	pop     dx
    	pop     ax    
ENDM
	
Prt_b   MACRO               ;Printa um baralho (funcao teste)
local l1,l2,l3,carta10,carta11,carta12,\n_,n\n
        \n
        mov     cx, 104 
        lea     di, b
l1:
        mov     dl, [di]
        add     dl, 30h
        cmp     dl, 3Ah
        jne     carta10
        mov     dl, 'D'    
    	jmp     l2
carta10:
        cmp     dl, 3Bh
        jne     carta11
        mov     dl, 'J'
    	jmp     l2
carta11:
        cmp     dl, 3Ch
        jne     carta12
        mov     dl, 'Q'
    	jmp     l2
carta12:
        cmp     dl, 3Dh
        jne     l2
        mov     dl, 'K'
l2: 
        cmp     cx, 104
        je      n\n
        cmp     cx, 0
        je      n\n 
        mov     ax, cx
        mov     bl, 13
        div     bl 
        cmp     ah, 0
        je      \n_
n\n:   
        mov     ah, 2   
        int     21h       
l3:
        inc     di
        loop    l1       
\n_: 
        mov     n, dl
        \n
    	mov     dl, n
    	cmp     cx, 0
    	jne     n\n
ENDM

start_pos MACRO         ; coloca os valores do array 
local next_card,skip_sub,skip_inc

        mov     cx, 54
        lea     si, B    
        lea     di, c1
next_card:
        mov     al, [si]
        mov     [si], 0
        mov     [di], al
        mov     ax, cx      ;passa as cartas para as colunas de jogo(c1,c2...c10)
        mov     bl, 10
        div     bl
        cmp     ah, 5
        jne     skip_sub
        sub     di, 179
        jmp     skip_inc
skip_sub:
        mov     ax, 20
        add     di, ax
skip_inc:
        inc     si
        loop next_card 
ENDM

prt_c   MACRO           ;printa a mesa de jogo
local next_card,skip_sub,skip_goto,\n_rpt,skip_inc,carta10,carta1,carta1_,carta11,carta12
local l2,cartaNULL,newl,c_move_,skip_print_move,carta10_,carta11_,carta12_,l3,cartaNULL_       
        mov     cx, 30
\n_rpt:                  ;limpa o ecra
        \n
        loop    \n_rpt
        push    si
        push    di
        mov     cx, 200   
        lea     di, c1
next_card:
        mov     dl, [di]
        add     dl, 30h
        cmp     dl, 30h
        jne     cartaNULL   ;caso o valor seja 0 antes da soma de 30h (carta nula/se carta)
        mov     dl, 32      ;move dl<--32                         
        jmp     l2
cartaNULL:                 
        cmp     dl, 3Ah   
        jne     carta10     ;caso o valor seja 10 antes da soma de 30h (carta nula/se carta)
        mov     dl, 'D'     ;move dl<--D                         
        jmp     l2
carta10:
        cmp     dl, 3Bh     ;caso o valor seja 11 antes da soma de 30h (carta nula/se carta)
        jne     carta11     ;move <--J                                                       
        mov     dl, 'J'
    	jmp     l2
carta11:
        cmp     dl, 3Ch     ;caso o valor seja 12 antes da soma de 30h (carta nula/se carta)
        jne     carta12     ;move <--Q                                                       
        mov     dl, 'Q'
    	jmp     l2
carta12:
        cmp     dl, 3Dh     ;caso o valor seja 13 antes da soma de 30h (carta nula/se carta)
        jne     carta1      ;move <--K                                                       
        mov     dl, 'K'
carta1:
        cmp     dl, 31h     ;caso o valor seja 1 antes da soma de 30h (carta nula/se carta)
        jne     l2          ;move <--A                                                       
        mov     dl, 'A'
l2: 
        cmp     cx, 200
        jne     skip_goto
        goto    c r
skip_goto:
        mov     ah, 2       ;print dl
        int     21h
        space               ;printa espacos 
        mov     ax, cx
        mov     bl, 10
        div     bl
        cmp     cx, 200
        je      skip_sub
        cmp     ah, 1
        jne     skip_sub
        sub     di, 179
        add     r, 1
        goto    c r
        jmp     skip_inc
skip_sub:
        mov     ax, 20
        add     di, ax
skip_inc:
        inc     si 
        loop next_card
        mov     cx, i            ;i--> utilizado como contador de cartas que o jogador pegou numa jogada
        mov     bl, 1
        cmp     cx, 0            ;caso i seja 0 nao printa as cartas que o jogador pegou porque ainda nao o fez
        je      skip_print_move
        goto    71 1
        printf  msg_move
        lea     di, c_move
c_move_:                         ;printa as cartas que o jogador pegou das colunas 
        goto    76 bl
        mov     ah, 2
        mov     dl, [di]
        add     dl, 30h
        cmp     dl, 30h        
        jne     cartaNULL_
        mov     dl, 32    
        jmp     l3
cartaNULL_:
        cmp     dl, 3Ah
        jne     carta10_
        mov     dl, 'D'    
        jmp     l3
carta10_:
        cmp     dl, 3Bh
        jne     carta11_
        mov     dl, 'J'
    	jmp     l3
carta11_:
        cmp     dl, 3Ch
        jne     carta12_
        mov     dl, 'Q'
    	jmp     l3
carta12_:
        cmp     dl, 3Dh
        jne     carta1_
        mov     dl, 'K'
carta1_:
        cmp     dl, 31h
        jne     l3
        mov     dl, 'A'
l3:
        int     21h
        inc     di 
        inc     bl
        loop    c_move_
        goto    0 23
skip_print_move: 
        goto    60 24 
        printf  msg_given       ;print quantos pedidos o jogador ainda tem
        mov     dl, 5
        sub     dl, given
        add     dl, 30h
        mov     ah, 2
        int     21h
        print_box             ;print caixas colunas
        pop     di
        pop     si
ENDM
 
print_box MACRO     ; printa as caixas de cada coluna
local box_print,next_box,calc_box,skip_calc_box,make_0
        mov     cx, 10
        mov     c, 0
        mov     r, 2
        cmp     box_c,1
        je      skip_calc_box
next_box:
        add     c,7
        mov     r,2
skip_calc_box:
        goto    c r
        printf  box_l1 
        add     c,3
        goto    c r
        mov     ah, 2
        mov     dx, box_c
        add     dx, 30h
        cmp     dx, 3Ah
        jne     make_0
        mov     dx, 30h
make_0:
        int     21h
        sub     c,3
        inc     r
        push    cx
        mov     cx,20
box_print:
        goto    c r
        printf  box_lm
        add     c, 6
        goto    c r
        printf  box_lm 
        inc     r
        sub     c, 6
        loop    box_print
        pop     cx
        goto    c r
        printf  box_le
        inc     box_c
        loop    next_box
        mov     c,3
        mov     r,3
        mov     box_c,1
ENDM

space   MACRO          ;escreve espacos (utilizado do prt_c para espacar as colunas)
local again
        push    dx
        push    cx
        push    ax
        mov     cx, 6
again:
        mov     ah, 2
        mov     dl, 32   
        int     21h
        loop    again
        pop     ax
        pop     cx
        pop     dx
ENDM

goto    MACRO   col, row   ;move o cursor para a posicao col row (coluna linha)
        push    ax         
        push    bx
        push    dx
        mov     ah, 02h
        mov     dh, row
        mov     dl, col
        mov     bh, 0
        int     10h
        pop     dx
        pop     bx
        pop     ax
ENDM

ask     MACRO              ;pede 10 cartas do B para as colunas de jogo (1 por coluna)
local next_card,skip_sub,skip_inc,given_add,find_0,all_given,end_ask,found_0,skip_given 
        lea     si, B            
        lea     di, c1
        add     si, 54
        cmp     given, 5
        je      all_given
        mov     cl, given
        cmp     cx, 0
        je      skip_given
given_add:
        add     si, 10 
        loop    given_add
skip_given:
        mov     cx, 10
next_card:
        mov     al, [si]
        mov     [si], 0
        push    cx
        mov     cx, 20
        mov     bx, 0
find_0:
        cmp     [di], 0
        je      found_0
        inc     bx
        inc     di       
        loop    find_0
found_0:
        pop     cx
        mov     [di], al
        sub     di, bx
        mov     ax, 20
        add     di, ax
skip_inc:
        inc     si
        loop    next_card
        mov     al, given
        inc     al
        mov     given, al
        jmp     end_ask
all_given:
        goto    0 23
        printf  msg_all_given
        read         
end_ask:
        
ENDM

printf  MACRO   string   ;da print a uma string terminada com $
        push    ax
        push    dx
        mov     ah, 9
        lea     dx, string
        int     21h
        pop     dx
        pop     ax
ENDM

Move    MACRO            ;permite ao jogador fazer um movimento(se validado pela funcao check)
move_start:
        prt_c
        goto    0 24
        printf  ask_from
        call    scan_num   ;read coluna de envio
        mov     ax, cx                                                          
        cmp     cx, 32
        jne     skip_ask
        ask
        jmp     end_play
skip_ask:
        cmp     ax, 10
        jge     invalid_input_l1
        cmp     ax, 0                  ;limitacao de inputs a (0-9)
        jge     valid_input_l1
invalid_input_l1:    
        goto    0 23
        printf  msg_invalid_input
        read
        jmp     move_start
valid_input_l1:
        mov     cx, ax
        cmp     cx, 0
        lea     di, c10
        je      skip_set_pointer_send
        sub     cx, 1
        lea     di, c1
        cmp     cx, 0
        je      skip_set_pointer_send
set_pointer_send:
        add     di, 20
        loop    set_pointer_send
skip_set_pointer_send:
        mov     cx, 20
find_0_send:
        cmp     [di], 0
        je      skip_inc_send
        inc     di       
        loop    find_0_send
skip_inc_send:
        prt_c 
        goto    0 24
        printf  ask_many
        call    SCAN_NUM    ;read quantidade
        mov     ax, cx 
        cmp     cx, 32
        jne     skip_ask_1
        ask
        jmp     end_play
skip_ask_1:
        mov     condition, 0
        cmp     ax, 12
        jg      input_0                ;limitacao de inputs a (0-12)
        cmp     ax, 1
        jl      input_0
        jmp     valid_input_l2 
        input_0:   
        goto    0 23          
        printf  msg_invalid_input
        read
        jmp     skip_inc_send
valid_input_l2:                           
        mov     i, cx     ; i = quantidade de cartas movidas                  
found_0_send:
        sub     di, 1
        loop    found_0_send
        lea     si, c_move
        mov     cx, i
        mov     from, di
move_check:                
        mov     bx, [di]                    
        mov     [di], 0        ;mover cartas para a colona de verificacao (c_move)
        mov     [si], bx
        inc     di
        inc     si
        loop    move_check
read_recept: 
        prt_c
        goto    0 24 
        printf  ask_to
        call    SCAN_NUM    ;read coluna de rececao
        mov     ax, cx
        cmp     cx, 10
        jge     invalid_input_l3     ;limitacao de inputs a (0-9)
        cmp     cx, 0
        jge     valid_input_l3
invalid_input_l3:    
        goto    0 23
        printf  msg_invalid_input
        read
        jmp     read_recept
valid_input_l3:                           
        mov     cx, ax
        cmp     cx, 0
        lea     si, c10
        je      skip_set_pointer_receive
        sub     cx, 1
        lea     si, c1
        cmp     cx, 0
        je      skip_set_pointer_receive
set_pointer_receive:
        add     si, 20
        loop    set_pointer_receive
skip_set_pointer_receive:
        mov     cx, 20
find_0_receive:
        cmp     [si], 0
        je      skip_inc_receive
        inc     si       
        loop    find_0_receive
skip_inc_receive:
        mov     receive_c, cx
        mov     cx, i
        lea     di, c_move 
        check
        cmp     cx, 0 
        jne     move
        goto    0 23 
        printf  invalid_move
        mov     si, from
        mov     cx, i
        read
        mov     ax, cx
move:                
        mov     bx, [di]                
        mov     [di], 0
        mov     [si], bx
        inc     di
        inc     si
        loop    move            
end_play:
        mov     cx, 0
        mov     i, cx
        13cards
        cmp     j, 8
        je      end_game
        prt_c        
ENDM

check   MACRO         ;verifica se uma jogada e valida                   
local check_,ERROR,VALID,empty,empty_1_card           
        push    ax                            
        push    bx                            
        push    di                             
        push    si
        cmp     c_move[0], 0  ;caso o utilizador tentar mexer uma linha vazia
        je      ERROR
        mov     cx, i                                                        
        sub     si, 1
        mov     al, [si]                        
        mov     bl, [di] 
        cmp     receive_c, 20
        jne     check_
        mov     si, di
        inc     di
        sub     cx, 1
        cmp     i, 1           ;a jogada mover uma carta para um coluna vazia e sempre valida
        je      empty_1_card
        mov     al, [si]                        
        mov     bl, [di]                      
check_:                                 
        inc     bl                             
        cmp     al, bl                          
        jne     ERROR                          
        sub     bl, 1                           
        mov     al, bl                          
        inc     di                              
        mov     bl, [di]                       
        loop    check_
empty_1_card:
        mov     cx, i                          
        jmp     VALID                           
ERROR:                                  
        mov     cx, 0                         
VALID:                                  
        pop     si                              
        pop     di                              
        pop     bx                              
        pop     ax                              
ENDM

PUTC    MACRO   char     ;printa um caracter na posicao do cursor
    
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM

DEFINE_SCAN_NUM         MACRO     ;le numeros inteiros e espera por um enter
LOCAL make_minus, ten, next_digit, set_minus,firstc_bs,skip_mov
LOCAL too_big, backspace_checked, too_big2,skip_inc,skip_inc_l2
LOCAL stop_input, not_minus, skip_proc_scan_num,skip_inc_l1,checked_enter
LOCAL remove_not_digit, ok_AE_0, ok_digit, not_cr,skip,enter_error 

; protect from wrong definition location:
JMP     skip_proc_scan_num

SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        MOV     enter_check, 0
        MOV     condition, 0
        MOV     CX, 0

        ; reset flag:
        MOV     CS:make_minus, 0

next_digit:
        cmp     enter_check, 255
        jne     skip_mov 
        mov     enter_check, 0
skip_mov:
        MOV     condition, 0
        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h
        cmp     enter_check, 0
        jne     skip_inc_l1
        inc     condition     
skip_inc_l1:
        cmp     al, 8
        jne     skip_inc_l2
        inc     condition
skip_inc_l2:
        cmp condition, 2
        je firstc_bs
        ; and print it:
        MOV     AH, 0Eh
        INT     10h
firstc_bs:
             
        ; check for MINUS:
        CMP     AL, '-'
        JE      set_minus
        
        ; check for ENTER key:
        inc     enter_check
        CMP     AL, 13  ; carriage return?
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        sub     enter_check, 2
        PUTC    ' '                     ; clear position.
        PUTC    8                       ; backspace again.
        JMP     next_digit
backspace_checked:

        CMP     AL, 32
        JE      ok_digit
        ; allow only digits:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered not digit.
        PUTC    8       ; backspace again. 
        sub     enter_check, 1       
        JMP     next_digit ; wait for next input.       
ok_digit:


        ; multiply CX by 10 (first time the result is zero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; check if the number is too big
        ; (result should be 16 bits)
        CMP     DX, 0
        JNE     too_big

        ; convert from ASCII code:
        cmp     al, 32
        je      skip_sub
        SUB     AL, 30h
skip_sub:
        ; add AL to CX:
        MOV     AH, 0
        MOV     DX, CX      ; backup, in case the result will be too big.
        ADD     CX, AX
        JC      too_big2    ; jump if the number is too big.
        cmp     al, 32
        je      stop_input
        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX      ; restore the backuped value before add.
        MOV     DX, 0       ; DX was zero before backup!
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for Enter/Backspace.        
stop_input:     
        mov     condition, 0
        cmp     cx, 0
        jne     checked_enter
        inc     condition
        cmp     enter_check, 1
        jne     checked_enter
        inc     condition
        cmp     condition, 2
        je      enter_error
checked_enter:
        cmp     al, 32
        je      skip_inc
        cmp     ax, 0
        jne     skip_inc
enter_error:
        mov     cx, 0f0f0h
skip_inc:
        ; check flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; used as a flag.
ten             DW      10      ; used as multiplier.
SCAN_NUM        ENDP

skip_proc_scan_num:

DEFINE_SCAN_NUM         ENDM


13cards MACRO    ;verifica se 13 cartas foram alinhadas                        
local check_,FOUND,NOT_FOUND,move,delete,skip_bh_reset           
        push    ax                            
        push    bx                            
        push    di                             
        push    si
        mov     cx, 210                                                        
        lea     si, c1
        lea     di, c1
        inc     di                           
        mov     al, [si]                        
        mov     bl, [di]                        
check_:                                 
        sub     al, 1
        inc     bh                             
        cmp     al, bl
        je      skip_bh_reset
        mov     bh, 0
skip_bh_reset:                          
        inc     al
        cmp     bh, 12
        je      FOUND                           
        mov     al, bl                          
        inc     di                              
        mov     bl, [di]                       
        loop    check_                          
        jmp     NOT_FOUND                          
FOUND:                                  
        sub     di, 12
        lea     si, c_move
        mov     cx, 13
move:                
        mov     bx, [di]                
        mov     [di], 0
        mov     [si], bx
        inc     di
        inc     si
        loop    move
        mov     cx, 19
        lea     si, c_move
delete:
        mov     [si], 0
        inc     si
        loop    delete 
        add     j, 1                       
NOT_FOUND:                                  
        pop     si                              
        pop     di                              
        pop     bx                              
        pop     ax                              
ENDM


                                                
.code


shuffle
start_pos
next_move:
move 
jmp next_move
end_game:
mov cx, 50
print_end:
printf msg_end_game
loop print_end
ret

END