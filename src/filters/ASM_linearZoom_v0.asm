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

    ; Stack frame
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; r10 puntero [i,j] de dst
    ; r11 puntero [i+1,j] de dst
    ; r12 puntero [i,j] de src
    ; r13 puntero [i+1,j] de src
    ; r14d índice para iterar en los pixeles de una fila de src
    ; r15d índice para iterar en las filas de src
    ; ebx cantidad de pixeles de una fila de src que se procesan dentro del ciclo
    ; xmm15 zeros

    mov r10, rcx
    mov r13, rdi
    mov r14, 0
    mov r15, 0
    pxor xmm15, xmm15
    
    ; Fila inferior de la imagen
    mov r11, r8
    sal r11, 2
    add r11, rcx ; puntero a la siguiente fila del dest
    mov ebx, esi
    sub ebx, 2 ; los ultimos cuatro pixeles de la fila se tratan de forma separada

    .ciclo_fila_inferior:
    cmp r14d, ebx ; vemos si ya se recorrieron todos los elementos de las dos filas menos los dos últimos
    jnb .ciclo_fila_inferior_fin

    movdqu xmm0, [r13]
    movdqu xmm1, xmm0
    movdqu xmm2, xmm0

    psrldq xmm2, PIXEL_SIZE ; el pixel 2 y 3 quedan en la posicion 1 y 2
    punpcklbw xmm1, xmm15 ; xmm1 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpcklbw xmm2, xmm15 ; xmm2 = 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A | 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A
    paddw xmm1, xmm2
    psraw xmm1, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm1, xmm1
    insertps xmm0, xmm0, 01100000b ; muevo el segundo pixel a la tercera posición
    insertps xmm0, xmm1, 00010000b ; muevo el nuevo segundo pixel
    insertps xmm0, xmm1, 01110000b ; muevo el nuevo cuarto pixel
    
    movdqu [r10], xmm0
    movdqu [r11], xmm0
    
    add r14d, 2 ; avanza 2 columnas en el source
    add r13, 8 ; avanza 8 bytes en el source
    add r10, 16 ; avanza 16 bytes en el dest
    add r11, 16 ; avanza 16 bytes en la siguiente fila del dest
    jmp .ciclo_fila_inferior
    
    ; Ultimas dos columnas de la fila infeior
    .ciclo_fila_inferior_fin:
    sub r13, 8 ; se necesita retroceder por la forma en que accede, ahora necesita los últimos pixeles
    movdqu xmm0, [r13]
    movdqu xmm1, xmm0
    movdqu xmm2, xmm0

    psrldq xmm2, PIXEL_SIZE ; el pixel 4 quedan en la posicion 3
    punpckhbw xmm1, xmm15 ; xmm1 = 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A | 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A
    punpckhbw xmm2, xmm15 ; xmm2 = 0 | --- | 0 | --- | 0 | --- | 0 | --- | 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A
    paddw xmm1, xmm2
    psraw xmm1, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm1, xmm1
    insertps xmm0, xmm0, 10000000b ; el tercer pixel va a la primera posición
    insertps xmm0, xmm0, 11100000b ; el cuarto pixel va a la tercera posición
    insertps xmm0, xmm1, 00010000b ; se mueve el nuevo segundo pixel
    
    movdqu [r10], xmm0
    movdqu [r11], xmm0

    add r13, 16 ; avanza 16 bytes en el source
    add r10, 16 ; avanza 16 bytes en el dest
    add r11, 16 ; avanza 16 bytes en la siguiente fila del dest


    ; comienza el ciclo principal(recorrer filas) del algoritmo
    inc r15d ; la primera fila del source ya s recorrio
    mov r12, rdi ; anterior fila en el source
    .ciclo_filas:
    cmp r15d, edx
    jnb .ciclo_filas_fin

    mov r10, r11
    mov r11, r8
    sal r11, 2
    add r11, r10 ; puntero a la siguiente fila del dest

    ; comienza el ciclo secundario(recorrer columnas) del algoritmo
    mov r14d, 0

    .ciclo_columnas:
    cmp r14d, ebx ; vemos si ya se recorrieron todos los elementos de las dos filas menos los dos últimos
    jnb .ciclo_columnas_fin

    movdqu xmm0, [r13]
    movdqu xmm3, [r12]
    movdqu xmm1, xmm0
    movdqu xmm2, xmm0
    movdqu xmm4, xmm3
    movdqu xmm5, xmm3

    ; Fila 2
    psrldq xmm2, PIXEL_SIZE ; el pixel 2 y 3 quedan en la posicion 1 y 2
    punpcklbw xmm1, xmm15 ; xmm1 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpcklbw xmm2, xmm15 ; xmm2 = 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A | 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A
    movdqu xmm6, xmm1 ; conservo los primeros dos pixeles
    paddw xmm1, xmm2
    movdqu xmm2, xmm1 ; conservo el resultado intermedio
    psraw xmm1, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm1, xmm1
    insertps xmm0, xmm0, 01100000b ; muevo el segundo pixel a la tercera posición
    insertps xmm0, xmm1, 00010000b ; muevo el nuevo segundo pixel
    insertps xmm0, xmm1, 01110000b ; muevo el nuevo cuarto pixel

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
    movdqu [r11], xmm0

    add r14d, 2 ; avanza 2 columnas en el source
    add r13, 8 ; avanza 8 bytes la siguiente fila del source
    add r12, 8 ; avanza 8 bytes en el source
    add r10, 16 ; avanza 16 bytes en el dest
    add r11, 16 ; avanza 16 bytes en la siguiente fila del dest
    jmp .ciclo_columnas

    .ciclo_columnas_fin:
    ; Se procesan los ultimos cuatro pixeles de la imagen dest
    sub r13, 8 ; se necesita retroceder por la forma en que accede, ahora necesita los últimos pixeles
    sub r12, 8
    movdqu xmm0, [r13]
    movdqu xmm3, [r12]
    movdqu xmm1, xmm0
    movdqu xmm2, xmm0
    movdqu xmm4, xmm3
    movdqu xmm5, xmm3

    ; Fila 2
    psrldq xmm2, PIXEL_SIZE ; el pixel 4 quedan en la posicion 3
    punpckhbw xmm1, xmm15 ; xmm1 = 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A | 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A
    punpckhbw xmm2, xmm15 ; xmm2 = 0 | --- | 0 | --- | 0 | --- | 0 | --- | 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A
    movdqu xmm6, xmm1 ; conservo los últmos dos pixeles
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

    movdqu [r10], xmm6
    movdqu [r11], xmm0

    add r13, 16 ; avanza 8 bytes la siguiente fila del source
    add r12, 16 ; avanza 8 bytes en el source
    add r10, 16 ; avanza 16 bytes en el dest
    add r11, 16 ; avanza 16 bytes en la siguiente fila del dest

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