; compile with nasm -f elf funcs.asm , ld -m elf_i386 funcs
;
;

SECTION .bss
RandomNumberInfo : resb 3           ; [ a , b , seed ]

SECTION .text

; _____________________
;| int strlen (char*) <> calculatets the lenght of a nullterminated string
strlen:
    push    edx                     ; edx is the char* 
    mov     eax , 0                 ; eax is the return int
    
    .loop:
        cmp     byte[edx] , 0       ; check if edx is at the null character
        jz      .finished           ; if edx is at the null character the length has been calculated
        inc     eax                 ; incrise the lenght
        inc     edx                 ; incrise the string pointer
        jmp     .loop
    
    .finished:
        pop edx                     ; restore edx
        ret

; ___________________
;| void exit () <> exit the programm
exit:
    mov     eax , 1     ; syscall exit
    mov     ebx , 0     ; error code
    int     80h         ; invoke kernel


; ____________________
;| void sprint (char*) <> prints the string to the STDOUT
sprint:
    push    edx         ; edx is the string lenght
    push    ecx         ; ecx is for the char*
    push    eax         ; eax is for the write syscall
    push    ebx         ; ebx is for the write location

    mov     ecx , edx   ; put the char* into ecx
    ; get the lenght
    call    strlen
    mov     edx , eax   ; strlen takes the char* in edx and return the lenght in eax    

    mov     eax , 4     ; the write syscall
    mov     ebx , 1     ; the write location
    
    int     80h          ; invoke kernel

    ; restore register
    pop     ebx
    pop     eax
    pop     ecx
    pop     edx

    ret

; _________________
;| int gets( size_t , char* ) <> takes size_t ammount of byte's from STDIN and write's them to char* , eax returns 1 if input has been given
gets:   
    push    ecx         ; char*
    push    edx         ; size_t
    push    ebx         ; used for syscall argument
    push    eax         ; eax is the write syscall

    mov     eax , 3     ; read syscall
    mov     ebx , 0     ; read from STDIN

    int     80h         ; invoke kernel 

    pop     eax
    pop     ebx
    pop     edx
    pop     ecx
    ret


; ________________________
;| void rand() <> returns a random 32 bit number 
rand:
    mov     ax , [RandomNumberInfo]      ; a
    mul     DWORD[RandomNumberInfo+2]     ; seed
    add     ax , [RandomNumberInfo+1]    ; b
    mov     [RandomNumberInfo+2] , ax
    ret
; _____________
;| void srand(int a , int b , int seed) <> sets the infos for the Random number generation
srand:
    mov     [RandomNumberInfo+0] , dx
    mov     [RandomNumberInfo+1] , ax
    mov     [RandomNumberInfo+2] , bx
    ret