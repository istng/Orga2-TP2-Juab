global ASM_linearZoom
extern C_linearZoom

%define PIXEL_SIZE 4
%define PIXEL_SIZE_IN_BITS 32

ASM_linearZoom:
    ; El filtro zoom aumenta el tamaño de la imagen realizando una interpolación lineal entre
    ; pixeles.
    ; rdi uint8_t* src
    ; rsi uint32_t srcw
    ; rdx uint32_t srch
    ; rcx uint8_t* dst
    ; r8 uint32_t dstw
    ; r9 uint32_t dsth
    
    ; En el formato BMP las lineas de la imagen se encuentran almacenadas de
    ; forma invertida. Es decir, en la primera fila de la matriz se encuentra la última lı́nea de la
    ; imagen, en la segunda fila se encuentra la anteúltima y ası́ sucesivamente.

    ; La ultima fila de la imagen es una copia de la anteúltima fila y 
    ; la ultima columna es una copia de la anteúltima columna

    ; El algoritmo primero calcula las dos ultimas filas de la imagen (las dos primeras en el formato BMP)
    ; El algoritmo calcula dos filas en cada iteración del ciclo principal
    ; Las dos últimas columnas de cada fila se calculan por separado, fuera del ciclo secundario
    ; que calcula los elementos de cada fila.

    ; ASM_linearZoom v2
    ; 1) loop unrolling: se duplica la cantidad de pixeles calculados en cada iteración (16 vs 8)
    ; 2) Accesos a memoria tempranos: los accesos a memoria se realizan lo más temprano posible -> queda para v3

    ; Stack frame
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; r9 rax puntero [i+n,j] de dst, n = {0,1,2,3}
    ; r10 puntero [i,j] de dst
    ; r11 distancia entre filas de dst
    ; r12 puntero [i,j] de src
    ; r13 distancia entre filas de src
    ; r14d índice para iterar en los pixeles de una fila de src
    ; r15d índice para iterar en las filas de src
    ; rax puntero [i+n,j] de dst, n = {0,1,2,3}
    ; ebx puntero [i+n,j] de src, n = {0,1}
    ; xmm15 zeros

    mov r10, rcx
    mov r11, 0
    mov r12, rdi
    mov r13, 0
    mov r14, 0
    mov r15, 0
    pxor xmm15, xmm15
    
    mov r11d, r8d
    sal r11, 2 ; distancia entre filas de dst en bytes
    mov r13d, esi
    sal r13, 2 ; distancia entre filas de src en bytes
    sar esi, 1 ; cantidad de iteraciones en columnas de src (se avanza 2 pixeles por iteración)


    ; Fila inferior de la imagen
    mov r14d, 1 ; los ultimos cuatro pixeles de la fila se tratan de forma separada

    .ciclo_fila_inferior:
    cmp r14d, esi ; vemos si ya se recorrieron todos los elementos de las dos filas menos los dos últimos
    jnb .ciclo_fila_inferior_fin

    movdqu xmm0, [r12]
    movdqu xmm1, xmm0
    movdqu xmm2, xmm0
    mov rbx, r12
    add rbx, r13 ; siguiente fila
    movdqu xmm3, [rbx]
    movdqu xmm4, xmm3
    movdqu xmm5, xmm3

    ; Fila 1/2
    psrldq xmm2, PIXEL_SIZE ; el pixel 2 y 3 quedan en la posicion 1 y 2
    punpcklbw xmm1, xmm15 ; xmm1 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpcklbw xmm2, xmm15 ; xmm2 = 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A | 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A
    movdqu xmm11, xmm1 ; conservo los primeros dos pixeles
    paddw xmm1, xmm2
    movdqu xmm2, xmm1
    psraw xmm1, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm1, xmm1
    insertps xmm0, xmm0, 01100000b ; muevo el segundo pixel a la tercera posición
    insertps xmm0, xmm1, 00010000b ; muevo el nuevo segundo pixel
    insertps xmm0, xmm1, 01110000b ; muevo el nuevo cuarto pixel
    
    ; Fila 4
    psrldq xmm5, PIXEL_SIZE ; el pixel 2 y 3 quedan en la posicion 1 y 2
    punpcklbw xmm4, xmm15 ; xmm1 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpcklbw xmm5, xmm15 ; xmm2 = 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A | 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A
    movdqu xmm6, xmm4 ; conservo los primeros dos pixeles
    paddw xmm4, xmm5
    movdqu xmm5, xmm4 ; conservo el resultado intermedio
    psraw xmm4, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm4, xmm4
    insertps xmm3, xmm3, 01100000b ; muevo el segundo pixel a la tercera posición
    insertps xmm3, xmm4, 00010000b ; muevo el nuevo segundo pixel
    insertps xmm3, xmm4, 01110000b ; muevo el nuevo cuarto pixel

    ; Fila 3
    paddw xmm11, xmm6 ; X | - | X | -
    psraw xmm11, 1 ; shift, divide en dos la suma de los pixeles
    paddw xmm2, xmm5 ; - | X | - | X 
    psraw xmm2, 2 ; shift, divide en cuatro la suma de los pixeles
    packuswb xmm11, xmm11
    packuswb xmm2, xmm2
    insertps xmm11, xmm11, 01100000b ; muevo el segundo pixel a la tercera posición
    insertps xmm11, xmm2, 00010000b ; muevo el nuevo segundo pixel
    insertps xmm11, xmm2, 01110000b ; muevo el nuevo cuarto pixel

    movdqu [r10], xmm0
    mov rax, r10
    add rax, r11 ; siguiente fila
    movdqu [rax], xmm0
    add rax, r11 ; siguiente fila
    movdqu [rax], xmm11
    add rax, r11 ; siguiente fila
    movdqu [rax], xmm3

    inc r14d ; avanza 2 columnas en el source
    add r12, 8 ; avanza 8 bytes en el source
    add r10, 16 ; avanza 16 bytes en el dest
    jmp .ciclo_fila_inferior
    

    ; Ultimas dos columnas de la fila infeior
    .ciclo_fila_inferior_fin:
    sub r12, 8 ; se necesita retroceder por la forma en que accede, ahora necesita los últimos pixeles
    movdqu xmm0, [r12]
    movdqu xmm1, xmm0
    movdqu xmm2, xmm0
    mov rbx, r12
    add rbx, r13 ; siguiente fila
    movdqu xmm7, [rbx]
    movdqu xmm8, xmm7
    movdqu xmm9, xmm7

    ; Fila 1/2
    psrldq xmm2, PIXEL_SIZE ; el pixel 4 quedan en la posicion 3
    punpckhbw xmm1, xmm15 ; xmm1 = 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A | 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A
    punpckhbw xmm2, xmm15 ; xmm2 = 0 | --- | 0 | --- | 0 | --- | 0 | --- | 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A
    movdqu xmm11, xmm1 ; conservo los primeros dos pixeles
    paddw xmm1, xmm2
    movdqu xmm2, xmm1
    psraw xmm1, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm1, xmm1
    insertps xmm0, xmm0, 10000000b ; el tercer pixel va a la primera posición
    insertps xmm0, xmm0, 11100000b ; el cuarto pixel va a la tercera posición
    insertps xmm0, xmm1, 00010000b ; se mueve el nuevo segundo pixel

    ; Fila 4
    psrldq xmm9, PIXEL_SIZE ; el pixel 2 y 3 quedan en la posicion 1 y 2
    punpckhbw xmm8, xmm15 ; xmm1 = 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A | 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A
    punpckhbw xmm9, xmm15 ; xmm2 = 0 | --- | 0 | --- | 0 | --- | 0 | --- | 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A
    movdqu xmm10, xmm8 ; conservo los primeros dos pixeles
    paddw xmm8, xmm9
    movdqu xmm9, xmm8 ; conservo el resultado intermedio
    psraw xmm8, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm8, xmm8
    insertps xmm7, xmm7, 10000000b ; el tercer pixel va a la primera posición
    insertps xmm7, xmm7, 11100000b ; el cuarto pixel va a la tercera posición
    insertps xmm7, xmm8, 00010000b ; se mueve el nuevo segundo pixel

    ; Fila 3
    paddw xmm11, xmm10 ; X | - | X | -
    psraw xmm11, 1 ; shift, divide en dos la suma de los pixeles
    paddw xmm2, xmm9 ; - | X | - | X 
    psraw xmm2, 2 ; shift, divide en cuatro la suma de los pixeles
    packuswb xmm11, xmm11
    packuswb xmm2, xmm2
    insertps xmm11, xmm11, 01100000b ; muevo el segundo pixel a la tercera posición
    insertps xmm11, xmm11, 01110000b ; muevo el segundo pixel a la cuarta posición
    insertps xmm11, xmm2, 00010000b ; muevo el nuevo segundo pixel 
    
    movdqu [r10], xmm0
    mov rax, r10
    add rax, r11 ; siguiente fila
    movdqu [rax], xmm0
    add rax, r11 ; siguiente fila
    movdqu [rax], xmm11
    add rax, r11 ; siguiente fila
    movdqu [rax], xmm7

    add r12, 16 ; avanza 16 bytes en el source
    add r10, 16 ; avanza 16 bytes en el dest



    ; comienza el ciclo principal(recorrer filas) del algoritmo
    inc r15d ; la primera fila del source ya se recorrio
    inc r15d
    mov r12, rdi ; primera fila en el source
    .ciclo_filas:
    cmp r15d, edx
    jnb .ciclo_filas_fin

    ; comienza el ciclo secundario(recorrer columnas) del algoritmo
    add r10, r11 ; avanza una fila en dest
    add r10, r11 ; avanza una fila en dest
    add r10, r11 ; avanza una fila en dest
    add r12, r13 ; avanza una fila en src
    mov r14d, 1

    .ciclo_columnas:
    cmp r14d, esi ; vemos si ya se recorrieron todos los elementos de las dos filas menos los dos últimos
    jnb .ciclo_columnas_fin

    movdqu xmm3, [r12]
    mov rbx, r12
    add rbx, r13 ; siguiente fila
    movdqu xmm0, [rbx]
    add rbx, r13 ; siguiente fila
    movdqu xmm7, [rbx]
    movdqu xmm1, xmm0
    movdqu xmm2, xmm0
    movdqu xmm4, xmm3
    movdqu xmm5, xmm3
    movdqu xmm8, xmm7
    movdqu xmm9, xmm7

    ; Fila 2
    psrldq xmm2, PIXEL_SIZE ; el pixel 2 y 3 quedan en la posicion 1 y 2
    punpcklbw xmm1, xmm15 ; xmm1 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpcklbw xmm2, xmm15 ; xmm2 = 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A | 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A
    movdqu xmm6, xmm1 ; conservo los primeros dos pixeles
    movdqu xmm11, xmm1
    paddw xmm1, xmm2
    movdqu xmm2, xmm1 ; conservo el resultado intermedio
    psraw xmm1, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm1, xmm1
    insertps xmm0, xmm0, 01100000b ; muevo el segundo pixel a la tercera posición
    insertps xmm0, xmm1, 00010000b ; muevo el nuevo segundo pixel
    insertps xmm0, xmm1, 01110000b ; muevo el nuevo cuarto pixel

    mov rax, r10
    add rax, r11 ; siguiente fila
    movdqu [rax], xmm0

    ; Fila 1
    psrldq xmm5, PIXEL_SIZE ; el pixel 2 y 3 quedan en la posicion 1 y 2
    punpcklbw xmm4, xmm15 ; xmm1 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpcklbw xmm5, xmm15 ; xmm2 = 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A | 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A
    paddw xmm6, xmm4 ; X | - | X | -
    psraw xmm6, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm6, xmm6
    paddw xmm4, xmm5 
    paddw xmm4, xmm2 ; - | X | - | X 
    psraw xmm4, 2 ; shift, divide en cuatro la suma de los pixeles
    packuswb xmm4, xmm4
    insertps xmm6, xmm6, 01100000b ; muevo el segundo pixel a la tercera posición
    insertps xmm6, xmm4, 00010000b ; muevo el nuevo segundo pixel
    insertps xmm6, xmm4, 01110000b ; muevo el nuevo cuarto pixel

    movdqu [r10], xmm6

    ; Fila 4
    psrldq xmm9, PIXEL_SIZE ; el pixel 2 y 3 quedan en la posicion 1 y 2
    punpcklbw xmm8, xmm15 ; xmm8 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpcklbw xmm9, xmm15 ; xmm9 = 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A | 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A
    movdqu xmm10, xmm8 ; conservo los primeros dos pixeles
    paddw xmm8, xmm9
    movdqu xmm9, xmm8 ; conservo el resultado intermedio
    psraw xmm8, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm8, xmm8
    insertps xmm7, xmm7, 01100000b ; muevo el segundo pixel a la tercera posición
    insertps xmm7, xmm8, 00010000b ; muevo el nuevo segundo pixel
    insertps xmm7, xmm8, 01110000b ; muevo el nuevo cuarto pixel

    add rax, r11 ; siguiente fila
    mov r9, rax
    add r9, r11
    movdqu [r9], xmm7

    ; Fila 3
    paddw xmm11, xmm10 ; X | - | X | -
    psraw xmm11, 1 ; shift, divide en dos la suma de los pixeles
    paddw xmm2, xmm9 ; - | X | - | X 
    psraw xmm2, 2 ; shift, divide en cuatro la suma de los pixeles
    packuswb xmm11, xmm11
    packuswb xmm2, xmm2
    insertps xmm11, xmm11, 01100000b ; muevo el segundo pixel a la tercera posición
    insertps xmm11, xmm2, 00010000b ; muevo el nuevo segundo pixel
    insertps xmm11, xmm2, 01110000b ; muevo el nuevo cuarto pixel

    movdqu [rax], xmm11


    inc r14d ; avanza 2 columnas en el source
    ;inc r14d
    add r12, 8 ; avanza 8 bytes en el source
    add r10, 16 ; avanza 16 bytes en el dest
    jmp .ciclo_columnas

    .ciclo_columnas_fin:
    ; Se procesan los ultimos cuatro pixeles de la imagen dest
    sub r12, 8 ; se necesita retroceder por la forma en que accede, ahora necesita los últimos pixeles
    movdqu xmm3, [r12]
    mov rbx, r12
    add rbx, r13 ; siguiente fila
    movdqu xmm0, [rbx]
    add rbx, r13 ; siguiente fila
    movdqu xmm7, [rbx]
    movdqu xmm1, xmm0
    movdqu xmm2, xmm0
    movdqu xmm4, xmm3
    movdqu xmm5, xmm3
    movdqu xmm8, xmm7
    movdqu xmm9, xmm7

    ; Fila 2
    psrldq xmm2, PIXEL_SIZE ; el pixel 4 quedan en la posicion 3
    punpckhbw xmm1, xmm15 ; xmm1 = 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A | 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A
    punpckhbw xmm2, xmm15 ; xmm2 = 0 | --- | 0 | --- | 0 | --- | 0 | --- | 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A
    movdqu xmm6, xmm1 ; conservo los últmos dos pixeles
    movdqu xmm11, xmm1
    paddw xmm1, xmm2
    movdqu xmm2, xmm1 ; conservo el resultado intermedio
    psraw xmm1, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm1, xmm1
    insertps xmm0, xmm0, 10000000b ; el tercer pixel va a la primera posición
    insertps xmm0, xmm0, 11100000b ; el cuarto pixel va a la tercera posición
    insertps xmm0, xmm1, 00010000b ; se mueve el nuevo segundo pixel

    ; Fila 1
    psrldq xmm5, PIXEL_SIZE ; el pixel 4 quedan en la posicion 3
    punpckhbw xmm4, xmm15 ; xmm1 = 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A | 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A
    punpckhbw xmm5, xmm15 ; xmm2 = 0 | --- | 0 | --- | 0 | --- | 0 | --- | 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A
    paddw xmm6, xmm4 ; X | - | X | -
    psraw xmm6, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm6, xmm6
    paddw xmm4, xmm5 
    paddw xmm4, xmm2 ; - | X | - | X 
    psraw xmm4, 2 ; shift, divide en cuatro la suma de los pixeles
    packuswb xmm4, xmm4
    insertps xmm6, xmm6, 01100000b ; muevo el segundo pixel a la tercera posición
    insertps xmm6, xmm6, 01110000b ; muevo el segundo pixel a la cuarta posición
    insertps xmm6, xmm4, 00010000b ; muevo el nuevo segundo pixel 

    ; Fila 4
    psrldq xmm9, PIXEL_SIZE ; el pixel 2 y 3 quedan en la posicion 1 y 2
    punpckhbw xmm8, xmm15 ; xmm1 = 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A | 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A
    punpckhbw xmm9, xmm15 ; xmm2 = 0 | --- | 0 | --- | 0 | --- | 0 | --- | 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A
    movdqu xmm10, xmm8 ; conservo los primeros dos pixeles
    paddw xmm8, xmm9
    movdqu xmm9, xmm8 ; conservo el resultado intermedio
    psraw xmm8, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm8, xmm8
    insertps xmm7, xmm7, 10000000b ; el tercer pixel va a la primera posición
    insertps xmm7, xmm7, 11100000b ; el cuarto pixel va a la tercera posición
    insertps xmm7, xmm8, 00010000b ; se mueve el nuevo segundo pixel

    ; Fila 3
    paddw xmm11, xmm10 ; X | - | X | -
    psraw xmm11, 1 ; shift, divide en dos la suma de los pixeles
    paddw xmm2, xmm9 ; - | X | - | X 
    psraw xmm2, 2 ; shift, divide en cuatro la suma de los pixeles
    packuswb xmm11, xmm11
    packuswb xmm2, xmm2
    insertps xmm11, xmm11, 01100000b ; muevo el segundo pixel a la tercera posición
    insertps xmm11, xmm11, 01110000b ; muevo el segundo pixel a la cuarta posición
    insertps xmm11, xmm2, 00010000b ; muevo el nuevo segundo pixel 


    movdqu [r10], xmm6
    mov rax, r10
    add rax, r11 ; siguiente fila
    movdqu [rax], xmm0
    add rax, r11 ; siguiente fila
    movdqu [rax], xmm11
    add rax, r11 ; siguiente fila
    movdqu [rax], xmm7

    add r12, 16 ; avanza 16 bytes en el source
    add r10, 16 ; avanza 16 bytes en el dest
    inc r15d
    inc r15d
    jmp .ciclo_filas
    .ciclo_filas_fin:

    ; Stack frame
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
ret