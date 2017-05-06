global ASM_linearZoom_mem_alineada
extern C_linearZoom

%define PIXEL_SIZE 4
%define PIXEL_SIZE_IN_BITS 32

ASM_linearZoom_mem_alineada:
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

    ; Implementacion memoria alineada
    ; El algoritmo es el mismo que en la implementacion de referencia.
    ; En cada iteracion, se accede a 10 pixeles de src y se guardan 16 pixeles del dst (5 y 8 de de dos fila consecutivas respectivamente)
    ; Del src, se carga a [i,j] alineados y [i,j+1] desalineados (4 pixeles por vez).

    ; Stack frame
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; r10 puntero [i,j] de dst
    ; r11 distancia entre filas de dst
    ; r12 puntero [i,j] de src
    ; r13 distancia entre filas de src
    ; r14d índice para iterar en los pixeles de una fila de src
    ; r15d índice para iterar en las filas de src
    ; rax puntero [i+n,j] de dst, n = {0,1}
    ; rbx puntero [i+n,j] de src, n = {0,1}
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
    ;sar esi, 1 ; cantidad de iteraciones en columnas de src (se avanza 2 pixeles por iteración)

    ; Fila inferior de la imagen
    mov r14d, 4 ; los ultimos cuatro pixeles de la fila se tratan de forma separada

    .ciclo_fila_inferior:
    cmp r14d, esi ; vemos si ya se recorrieron todos los elementos de las dos filas menos los 4 últimos
    jnb .ciclo_fila_inferior_fin

    movdqa xmm0, [r12]
    mov rbx, r12
    add rbx, 4 ; avanzo un pixel
    movdqu xmm3, [rbx]
    movdqa xmm1, xmm0
    movdqa xmm2, xmm0
    movdqu xmm4, xmm3

    punpcklbw xmm1, xmm15 ; xmm1 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpckhbw xmm2, xmm15 ; xmm2 = 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A | 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A
    punpcklbw xmm3, xmm15 ; xmm3 = 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A | 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A
    punpckhbw xmm4, xmm15 ; xmm4 = 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A | 0 | P3R | 0 | P3G | 0 | P3B | 0 | P1A
    paddw xmm1, xmm3
    paddw xmm2, xmm4
    psraw xmm1, 1 ; shift, divide en dos la suma de los pixeles
    psraw xmm2, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm1, xmm1
    packuswb xmm2, xmm2
    pshufd xmm5, xmm0, 11111010b ; se mueven los pixeles para que quede una posicion entre ello
    pshufd xmm0, xmm0, 01010000b ; se mueven los pixeles para que quede una posicion entre ello
    insertps xmm0, xmm1, 00010000b ; muevo el segundo pixel
    insertps xmm0, xmm1, 01110000b ; muevo el cuarto pixel
    insertps xmm5, xmm2, 00010000b ; muevo el sexto pixel
    insertps xmm5, xmm2, 01110000b ; muevo el octavo pixel
    
    movdqa [r10], xmm0
    mov rax, r10
    add rax, r11 ; siguiente fila
    movdqa [rax], xmm0
    add r10, 16
    movdqa [r10], xmm5
    add rax, 16
    movdqa [rax], xmm5
    
    add r14d, 4 ; avanza 4 columnas en el source
    add r12, 16 ; avanza 16 bytes en el source
    add r10, 16 ; avanza 16 bytes en el dest
    jmp .ciclo_fila_inferior
    
    ; Ultimas dos columnas de la fila infeior
    .ciclo_fila_inferior_fin:
    ;sub r12, 8 ; se necesita retroceder por la forma en que accede, ahora necesita los últimos pixeles
    movdqa xmm0, [r12]
    movdqa xmm1, xmm0
    movdqa xmm2, xmm0
    movdqa xmm3, xmm0
    movdqa xmm5, xmm0
    
    psrldq xmm3, PIXEL_SIZE ; el pixel 4 quedan en la posicion 3
    movdqa xmm4, xmm3
    punpcklbw xmm1, xmm15 ; xmm1 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpckhbw xmm2, xmm15 ; xmm2 = 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A | 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A
    punpcklbw xmm3, xmm15 ; xmm3 = 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A | 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A
    punpckhbw xmm4, xmm15 ; xmm4 = 0 | --- | 0 | --- | 0 | --- | 0 | --- | 0 | P3R | 0 | P3G | 0 | P3B | 0 | P1A
    paddw xmm1, xmm3
    paddw xmm2, xmm4
    psraw xmm1, 1 ; shift, divide en dos la suma de los pixeles
    psraw xmm2, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm1, xmm1
    packuswb xmm2, xmm2

    pshufd xmm5, xmm0, 11111010b ; se mueven los pixeles para que quede una posicion entre ello
    pshufd xmm0, xmm0, 01010000b ; se mueven los pixeles para que quede una posicion entre ello
    insertps xmm0, xmm1, 00010000b ; muevo el segundo pixel
    insertps xmm0, xmm1, 01110000b ; muevo el cuarto pixel
    insertps xmm5, xmm2, 00010000b ; muevo el sexto pixel
    
    movdqa [r10], xmm0
    mov rax, r10
    add rax, r11 ; siguiente fila
    movdqa [rax], xmm0
    add r10, 16
    movdqa [r10], xmm5
    add rax, 16
    movdqa [rax], xmm5

    add r12, 16 ; avanza 16 bytes en el source
    add r10, 16 ; avanza 16 bytes en el dest



    ; comienza el ciclo principal(recorrer filas) del algoritmo
    inc r15d ; la primera fila del source ya se recorrio
    mov r12, rdi ; primera fila en el source
    .ciclo_filas:
    cmp r15d, edx
    jnb .ciclo_filas_fin

    ; comienza el ciclo secundario(recorrer columnas) del algoritmo
    add r10, r11 ; avanza una fila
    mov r14d, 4

    .ciclo_columnas:
    cmp r14d, esi ; vemos si ya se recorrieron todos los elementos de las dos filas menos los 4 últimos
    jnb .ciclo_columnas_fin

    movdqa xmm3, [r12]
    mov rbx, r12
    add rbx, r13 ; siguiente fila
    movdqa xmm0, [rbx]
    add r12, 4
    movdqu xmm7, [r12]
    add rbx, 4
    movdqu xmm8, [rbx]
    movdqu xmm1, xmm0
    movdqu xmm2, xmm0
    movdqu xmm4, xmm3
    movdqu xmm5, xmm3
    movdqu xmm9, xmm7
    movdqu xmm10, xmm7
    movdqu xmm11, xmm8
    movdqu xmm12, xmm8

    ; Fila 2
    punpcklbw xmm1, xmm15 ; xmm1 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpckhbw xmm2, xmm15 ; xmm2 = 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A | 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A
    punpcklbw xmm11, xmm15 ; xmm11 = 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A | 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A
    punpckhbw xmm12, xmm15 ; xmm12 = 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A | 0 | P3R | 0 | P3G | 0 | P3B | 0 | P1A
    movdqu xmm6, xmm1 ; conservo los primeros dos pixeles
    movdqu xmm13, xmm2 ; conservo los ultimos dos pixeles
    paddw xmm1, xmm11
    paddw xmm2, xmm12
    movdqu xmm11, xmm1 ; conservo el resultado intermedio
    movdqu xmm12, xmm2 ; conservo el resultado intermedio
    psraw xmm1, 1 ; shift, divide en dos la suma de los pixeles
    psraw xmm2, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm1, xmm1
    packuswb xmm2, xmm2
    pshufd xmm14, xmm0, 11111010b ; se mueven los pixeles para que quede una posicion entre ello
    pshufd xmm0, xmm0, 01010000b ; se mueven los pixeles para que quede una posicion entre ello
    insertps xmm0, xmm1, 00010000b ; muevo el segundo pixel
    insertps xmm0, xmm1, 01110000b ; muevo el cuarto pixel
    insertps xmm14, xmm2, 00010000b ; muevo el sexto pixel
    insertps xmm14, xmm2, 01110000b ; muevo el octavo pixel


    ; Fila 1
    ;psrldq xmm5, PIXEL_SIZE ; el pixel 2 y 3 quedan en la posicion 1 y 2
    punpcklbw xmm4, xmm15 ; xmm4 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpckhbw xmm5, xmm15 ; xmm9 = 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A | 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A
    punpcklbw xmm9, xmm15 ; xmm5 = 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A | 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A
    punpckhbw xmm10, xmm15 ; xmm10 = 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A | 0 | P3R | 0 | P3G | 0 | P3B | 0 | P1A

    paddw xmm6, xmm4 ; X | - | X | -
    paddw xmm13, xmm5 ; X | - | X | -
    psraw xmm6, 1 ; shift, divide en dos la suma de los pixeles
    psraw xmm13, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm6, xmm6
    packuswb xmm13, xmm13

    paddw xmm4, xmm9 
    paddw xmm5, xmm10

    paddw xmm4, xmm11 ; - | X | - | X 
    paddw xmm5, xmm12 ; - | X | - | X 
    psraw xmm4, 2 ; shift, divide en cuatro la suma de los pixeles
    psraw xmm5, 2 ; shift, divide en cuatro la suma de los pixeles

    packuswb xmm4, xmm4
    packuswb xmm5, xmm5

    pshufd xmm6, xmm6, 01010000b ; se mueven los pixeles para que quede una posicion entre ello
    pshufd xmm13, xmm13, 01010000b ; se mueven los pixeles para que quede una posicion entre ello

    insertps xmm6, xmm4, 00010000b ; muevo el segundo pixel
    insertps xmm6, xmm4, 01110000b ; muevo el cuarto pixel
    insertps xmm13, xmm5, 00010000b ; muevo el sexto pixel
    insertps xmm13, xmm5, 01110000b ; muevo el octavo pixel


    movdqa [r10], xmm6
    mov rax, r10
    add rax, r11 ; siguiente columna
    movdqa [rax], xmm0
    add r10, 16
    movdqa [r10], xmm13
    add rax, 16
    movdqa [rax], xmm14

    add r14d, 4 ; avanza 4 columnas en el source
    add r12, 12 ; avanza 12 bytes en el source, se avanzo 4 al principio del ciclo
    add r10, 16 ; avanza 16 bytes en el dest
    jmp .ciclo_columnas



    .ciclo_columnas_fin:
    ; Se procesan los ultimos 8 pixeles de la imagen dest
    ;sub r12, 8 ; se necesita retroceder por la forma en que accede, ahora necesita los últimos pixeles

    movdqa xmm3, [r12]
    mov rbx, r12
    add rbx, r13 ; siguiente fila
    movdqa xmm0, [rbx]
    movdqu xmm1, xmm0
    movdqu xmm2, xmm0
    movdqu xmm4, xmm3
    movdqu xmm5, xmm3

    movdqu xmm7, xmm3
    psrldq xmm7, PIXEL_SIZE ; el pixel 4 quedan en la posicion 3
    movdqu xmm9, xmm7
    movdqu xmm10, xmm7

    movdqu xmm8, xmm0
    psrldq xmm8, PIXEL_SIZE ; el pixel 4 quedan en la posicion 3
    movdqu xmm11, xmm8
    movdqu xmm12, xmm8

    ; Fila 2
    punpcklbw xmm1, xmm15 ; xmm1 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpckhbw xmm2, xmm15 ; xmm2 = 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A | 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A
    punpcklbw xmm11, xmm15 ; xmm11 = 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A | 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A
    punpckhbw xmm12, xmm15 ; xmm12 = 0 | P4R | 0 | P4G | 0 | P4B | 0 | P4A | 0 | P3R | 0 | P3G | 0 | P3B | 0 | P1A
    movdqu xmm6, xmm1 ; conservo los primeros dos pixeles
    movdqu xmm13, xmm2 ; conservo los ultimos dos pixeles
    paddw xmm1, xmm11
    paddw xmm2, xmm12
    movdqu xmm11, xmm1 ; conservo el resultado intermedio
    movdqu xmm12, xmm2 ; conservo el resultado intermedio
    psraw xmm1, 1 ; shift, divide en dos la suma de los pixeles
    psraw xmm2, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm1, xmm1
    packuswb xmm2, xmm2
    pshufd xmm14, xmm0, 11111010b ; se mueven los pixeles para que quede una posicion entre ello
    pshufd xmm0, xmm0, 01010000b ; se mueven los pixeles para que quede una posicion entre ello
    insertps xmm0, xmm1, 00010000b ; muevo el segundo pixel
    insertps xmm0, xmm1, 01110000b ; muevo el cuarto pixel
    insertps xmm14, xmm2, 00010000b ; muevo el sexto pixel


    ; Fila 1
    ;psrldq xmm5, PIXEL_SIZE ; el pixel 2 y 3 quedan en la posicion 1 y 2
    punpcklbw xmm4, xmm15 ; xmm4 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpckhbw xmm5, xmm15 ; xmm9 = 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A | 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A
    punpcklbw xmm9, xmm15 ; xmm5 = 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A | 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A
    punpckhbw xmm10, xmm15 ; xmm10 = 0 | --- | 0 | --- | 0 | --- | 0 | --- | 0 | P3R | 0 | P3G | 0 | P3B | 0 | P1A


    paddw xmm6, xmm4 ; X | - | X | -
    paddw xmm13, xmm5 ; X | - | X | -
    psraw xmm6, 1 ; shift, divide en dos la suma de los pixeles
    psraw xmm13, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm6, xmm6
    packuswb xmm13, xmm13

    paddw xmm4, xmm9 
    paddw xmm5, xmm10

    paddw xmm4, xmm11 ; - | X | - | X 
    paddw xmm5, xmm12 ; - | X | - | X 
    psraw xmm4, 2 ; shift, divide en cuatro la suma de los pixeles
    psraw xmm5, 2 ; shift, divide en cuatro la suma de los pixeles

    packuswb xmm4, xmm4
    packuswb xmm5, xmm5

    pshufd xmm6, xmm6, 01010000b ; se mueven los pixeles para que quede una posicion entre ello
    pshufd xmm13, xmm13, 01010000b ; se mueven los pixeles para que quede una posicion entre ello

    insertps xmm6, xmm4, 00010000b ; muevo el segundo pixel
    insertps xmm6, xmm4, 01110000b ; muevo el cuarto pixel
    insertps xmm13, xmm5, 00010000b ; muevo el sexto pixel

    movdqa [r10], xmm6
    mov rax, r10
    add rax, r11 ; siguiente columna
    movdqa [rax], xmm0
    add r10, 16
    movdqa [r10], xmm13
    add rax, 16
    movdqa [rax], xmm14

    add r12, 16 ; avanza 12 bytes en el source, se avanzo 4 al principio del ciclo
    add r10, 16 ; avanza 16 bytes en el dest

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