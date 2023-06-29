%include "funcs.asm"


SECTION .bss
board       : resq 9              ; an array of size 9 that stores at what place the player or ai has set
boardPrint  : resq 9+2+3          ; holds the board in string format , the 9 is for all Cells , 2 for the new line and null character , the three for the newline character after 3 CELLS 
input       : resq 1              ; takes the location the player wants to place at or takes q for leaving
s           : resq 1

SECTION .data
START           db "You are player 1" , 0Ah , 0h
INFO            db "write a number between 1-9 for the place location or type q for input" , 0Ah , 0h
INVALID_INPUT   db "Invalid input! valid inputs are numbers between 1-9 and q for leaving" , 0Ah , 0h
BOARDCELLNNULL  db "Not empty" , 0Ah , 0h
PLAYER1_WON     db "Player1 has won!" , 0Ah , 0h
PLAYER2_WON     db "Player 2 has won!" , 0Ah , 0h

BOARD_CELL_ERR  db "Error in board" , 0Ah , 0h
BOARD_CELL_XDIV db " |"
BOARD_CELL_YDIV db "---"
NEXTLINE        db 0Ah , 0h

SECTION .text
global _start


_start:
    mov     edx , 144
    mov     ebx , 3
    mov     eax , 9
    call    srand



    call    rand
    mov     edx , 10
    idiv    edx



    call    initBoard       ; initialize the board
    mov     edx , START     ; output the starting notifcation
    call    sprint

    .GameLoop:
        call    printBoard
        mov     edx , INFO
        call    sprint
        call    CheckPlayer1Win
        .NoInput:
        ; get first player's input
        mov     edx , 1             ; read 1 byte
        mov     ecx , input         ; read to input
        call    gets                ; 

        ; check if input has been given , if no input has been given it will default to a New line Character(10)
        cmp     byte[input] , 10
        jle      .NoInput

        ; compare if valid input
        cmp     byte[input] , 'q'
        je      .end
        cmp     byte[input] , 49
        jl      .inv
        cmp     byte[input] , 57
        jg      .inv

        xor     edx , edx               ; make edx zero
        mov     dl , byte[input]        ; move the input into edx
        sub     edx , 49                ; remove the ascii index from the number
        cmp     byte[board+edx] , 0     ; check if the board at that place is zero
        je      .Player1Place           ; if it is empty let Player 1 place an x on that

        mov     edx , BOARDCELLNNULL    ; if the cell is not empty print that and get new input
        call    sprint
        jmp     .NoInput

        jmp     .GameLoop
    
    .Player1Place:                      ; takes the index(place location) index in edx
        mov     byte[board+edx] , 1
        jmp     .GameLoop
    
    .inv:
        mov     edx , INVALID_INPUT     ; print the string; invalid input
        call    sprint                  ; 
        jmp     .GameLoop
    
    .end:

    call    exit


; _____________
;| void initBoard () <>
initBoard:
    push    edx                     ; used for the pointer to the board
    push    ecx                     ; used for indexing the board
    mov     edx , board             ; move the pointer to the board into edx
    mov     ecx , 0                 ; set the index to zero at the beginning

    .loop:
        cmp     ecx , 8             ; if the index is bigger than nine all values have been init and this function can be left
        jg      .finished
        mov     byte[edx+ecx] , 0   ; set the value at edx+ecx to 0 , in c (array+index) = 0 === (edx+ecx) = 0
        inc     ecx                 ; incrise the index
        jmp     .loop
    
    .finished:
        ; restore the register
        pop     ecx
        pop     edx
        ret

; _________________
;| void printBoard () <> constructs the board print string and prints it
printBoard:
    push    edx                     ; pointer to the board
    push    ecx                     ; index for the board
    push    esi                     ; pointer to the board string

    mov     edx , board             ; put the board pointer in edx
    mov     ecx , 0                 ; set the index to zero at the beginning
    mov     esi , 0                 ; will be used for the board index since the boardString index wont work after the first row

    .loop:                          ; loops through all of the board cells
        mov     edx , board         ; move the board pointer to edx
        cmp     ecx , 10            ; if the index is bigger than 9 it means the whole board string has been costructed
        jg      .finished
        inc     ecx                 ; increase the board string index
        inc     esi                 ; increase the board index  

        ;cmp     ecx ,7
        cmp     ecx , 4
        je      .null
        ;cmp     ecx , 9
        cmp     ecx , 8
        je      .null
        ;cmp     ecx , 14
        cmp     ecx , 9
        je      .null

        .cont:                      ; continue here after printing th new line character
        

        cmp     byte[edx+esi-1] , 0   ; if the value is zero it means its a free cell
        je      .freeCell
        cmp     byte[edx+esi-1] , 1   ; if the value is 1 it means player 1 has placed in that cell
        je      .Player1Cell
        cmp     byte[edx+esi-1] , 2   ; if the value is 2 it means player 2 has placed in that cell
        je      .Player2Cell
        jg      .CERROR             ; if the value is bigger than 2 something has gone wrong

    .null:
        mov     byte [boardPrint+ecx-1] , 0Ah
        inc     ecx
        jmp     .cont
    .freeCell:
        mov     byte[boardPrint+ecx-1] , 'n'
        jmp     .loop
    .Player1Cell:
        mov     byte[boardPrint+ecx-1] , 'x'
        jmp     .loop
    .Player2Cell:
        mov     byte[boardPrint+ecx-1] , 'o'
        jmp     .loop
    .CERROR:
        mov     edx , BOARD_CELL_ERR
        call    sprint
        call    exit

    .finished:
        ;pop     esi
        mov     edx , NEXTLINE
        call    sprint
        ; print the string
        mov     byte[boardPrint+ecx+0] , 0Ah
        mov     byte[boardPrint+ecx+1] , 0h
        mov     edx , boardPrint
        call    sprint

        ; restore the register
        pop     esi
        pop     ecx
        pop     edx 

        ret


CheckPlayer1Win:
    push    edx                         ; stores the board pointer ( board is a array of size 9)
    push    ecx                         ; is the loop counter
    push    ebx                         ; is the index for checking the collums 
    push    esi                         ; is the index for checking the diagonals

    mov     edx , board                 ; move the board pointer to edx

    xor     ecx , ecx                   ; set ecx to 0
    mov     esi , edx                   ; set esi to the board pointer (esi is the index)
    .CheckRowsAndCollums:
        cmp     ecx , 2                 ; loop through CheckRowsAndCollums 3 timer
        jg      .RACEND

        mov     edx , board
        .rows:
            cmp     byte[esi] , 1
            jne     .colls
            cmp     byte[esi+1] , 1
            jne     .colls
            cmp     byte[esi+2] , 1
            jne     .colls
            jmp     .WON
        .colls:
            cmp     byte[edx+ecx] , 1
            jne     .loopEnd
            cmp     byte[edx+ecx+3] , 1
            jne     .loopEnd
            cmp     byte[edx+ecx+6] , 1
            jne     .loopEnd
            jmp     .WON

        .loopEnd:
            add     esi , 3
            inc     ebx
        inc     ecx
        jmp     .CheckRowsAndCollums

    .RACEND:
    xor     ecx , ecx
    xor     esi , esi
    mov     esi , 8
    add     esi , edx
    mov     ebx , edx
    .Diagonal:
        cmp     byte[edx+0] , 1
        jne     .D2
        cmp     byte[edx+4] , 1
        jne     .D2
        cmp     byte[edx+8] , 1
        jne     .D2
        jmp     .WON
    .D2:
        cmp     byte[edx+2] , 1
        jne     .end
        cmp     byte[edx+4] , 1
        jne     .end
        cmp     byte[edx+6] , 1
        jne     .end
        jmp     .WON
    
    .end:
        pop     esi
        pop     ebx
        pop     ecx
        pop     edx
        ret

    .WON:                           ; will be called if player 1 has won
        mov     edx , PLAYER1_WON   ; move the win message to edx
        call    sprint              ; print the message
        call    exit                ; exit the programm