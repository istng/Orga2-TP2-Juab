global ASM_linearZoom_tres_pasadas
extern C_linearZoom

%define PIXEL_SIZE 4
%define PIXEL_SIZE_IN_BITS 32

ASM_linearZoom_tres_pasadas:
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

    ; Esta implementación de zoomLineal realiza los siguientes pasos
    ; 1) Copia los pixeles del src a dst dejando libre un pixel alrededor de cada pixel copiado
    ; 2) En cada fila del dst que tiene pixeles copiados del src, calcula el pixel intermedio promediando el pixel anterior y el siguiente
    ; 3) Calcula los pixeles de las filas intermedias, promediando el pixel que se encuentra en la misma columna en la fila inferior y la superior


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
    ; rax puntero [i+n,j] de dst, n = {-1,1}
    ; rbx puntero [i+n,j] de dst, n = {-1,1}
    ; xmm15 zeros

    mov r10, rcx
    mov r12, rdi
    mov r14, 0
    mov r15, 0
    pxor xmm15, xmm15
    
    mov r11d, r8d
    sal r11, 2 ; distancia entre filas de dst en bytes
    mov r13d, esi
    sal r13, 2 ; distancia entre filas de src en bytes

    add r10, r11

    .ciclo_copiar_pixeles_recorrer_filas:
    cmp r15d, edx
    jnb .ciclo_copiar_pixeles_recorrer_filas_fin

    mov r14d, 0
    .ciclo_copiar_pixeles:
    cmp r14d, esi ; vemos si ya se recorrieron todos los elementos de la fila
    jnb .ciclo_copiar_pixeles_fin

    movdqa xmm0, [r12]
    pxor xmm1, xmm1
    pxor xmm2, xmm2
    insertps xmm1, xmm0, 00000000b ; el primero va a la primera posicion del destino
    insertps xmm1, xmm0, 01100000b ; el segundo va a la tercera posicion del destino
    insertps xmm2, xmm0, 10000000b ; el tercero va a la quinta posicion del destino
    insertps xmm2, xmm0, 11100000b ; el cuarto va a la septima posicion del destino

    movdqa [r10], xmm1
    add r10, 16 ; avanza 16 bytes en el dest
    movdqa [r10], xmm2
    add r10, 16 ; avanza 16 bytes en el dest
    add r12, 16 ; avanza 16 bytes en el source
    add r14d, 4 ; avanza 4 pixeles en el source
    jmp .ciclo_copiar_pixeles

    .ciclo_copiar_pixeles_fin:

    add r10, r11
    inc r15d
    jmp .ciclo_copiar_pixeles_recorrer_filas

    .ciclo_copiar_pixeles_recorrer_filas_fin:



    mov r10, rcx
    add r10, r11
    mov r15d, 0 ; se recorren la mitad de las filas de dst, es decir, la misma cantidad de filas que tiene src
    .ciclo_calcular_promedio_en_filas_con_pixeles_originales_recorrer_filas:
    cmp r15d, edx
    jnb .ciclo_calcular_promedio_en_filas_con_pixeles_originales_recorrer_filas_fin
    
    mov r14d, 2 ; los ultimos dos pixeles de la fila se tratan de forma separada
    .ciclo_calcular_promedio_en_filas_con_pixeles_originales:
    cmp r14d, r8d ; vemos si ya se recorrieron todos los elementos de la fila menos los dos últimos
    jnb .ciclo_calcular_promedio_en_filas_con_pixeles_originales_fin

    movdqu xmm0, [r10]
    movdqu xmm1, xmm0
    movdqu xmm2, xmm0
    punpcklbw xmm1, xmm15 ; xmm1 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpckhbw xmm2, xmm15 ; xmm2 = 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A | 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A
    paddw xmm1, xmm2
    psraw xmm1, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm1, xmm1
    insertps xmm0, xmm1, 00010000b ; muevo el nuevo segundo pixel

    movdqu [r10], xmm0
    add r10, 8 ; avanza 8 bytes en el dest
    add r14d, 2 ; avanza 2 pixeles en el dst
    jmp .ciclo_calcular_promedio_en_filas_con_pixeles_originales

    .ciclo_calcular_promedio_en_filas_con_pixeles_originales_fin:
    ; ultimos 2 pixeles de la fila
    movq xmm0, [r10]
    pshufd xmm0, xmm0, 00000000b ; copia el pixel 1 en la posicion 2
    movq [r10], xmm0
    add r10, 8 ; avanza 8 bytes en el dest

    add r10, r11 ; se saltea una fila
    inc r15d
    jmp .ciclo_calcular_promedio_en_filas_con_pixeles_originales_recorrer_filas
     
    .ciclo_calcular_promedio_en_filas_con_pixeles_originales_recorrer_filas_fin:


    mov r10, rcx
    mov r14d, 0
    .ciclo_copiar_ultima_fila:
    cmp r14d, r8d
    jnb .ciclo_copiar_ultima_fila_fin

    add r10, r11
    movdqa xmm0, [r10]
    sub r10, r11
    movdqa [r10], xmm0
    add r10, 16 ; avanza 16 bytes en el dest
    add r14d, 4 ; avanza 4 pixeles en el dst
    jmp .ciclo_copiar_ultima_fila

    .ciclo_copiar_ultima_fila_fin:



    mov r10, rcx
    add r10, r11
    add r10, r11
    mov r15d, 1 ; se recorren la mitad de las filas de dst, es decir, la misma cantidad de filas que tiene src
    .ciclo_calcular_promedio_en_filas_restantes_recorrer_filas:
    cmp r15d, edx
    jnb .ciclo_calcular_promedio_en_filas_restantes_recorrer_filas_fin
    
    mov r14d, 0 ; los ultimos dos pixeles de la fila se tratan de forma separada

    .ciclo_calcular_promedio_en_filas_restantes:
    cmp r14d, r8d ; vemos si ya se recorrieron todos los elementos de las dos filas menos los dos últimos
    jnb .ciclo_calcular_promedio_en_filas_restantes_fin

    mov rax, r10
    mov rbx, r10
    sub rax, r11
    add rbx, r11

    movdqa xmm0, [rax]
    movdqa xmm1, [rbx]
    movdqa xmm2, xmm0
    movdqa xmm3, xmm1

    punpcklbw xmm0, xmm15 ; xmm1 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpckhbw xmm2, xmm15 ; xmm2 = 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A | 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A
    punpcklbw xmm1, xmm15 ; xmm1 = 0 | P1R | 0 | P1G | 0 | P1B | 0 | P1A | 0 | P0R | 0 | P0G | 0 | P0B | 0 | P0A
    punpckhbw xmm3, xmm15 ; xmm2 = 0 | P3R | 0 | P3G | 0 | P3B | 0 | P3A | 0 | P2R | 0 | P2G | 0 | P2B | 0 | P2A
    paddw xmm0, xmm1
    paddw xmm2, xmm3
    psraw xmm0, 1 ; shift, divide en dos la suma de los pixeles
    psraw xmm2, 1 ; shift, divide en dos la suma de los pixeles
    packuswb xmm0, xmm0
    packuswb xmm2, xmm2
    insertps xmm0, xmm2, 00100000b ; muevo el nuevo tercer pixel
    insertps xmm0, xmm2, 01110000b ; muevo el nuevo cuarto pixel

    movdqa [r10], xmm0
    add r10, 16 ; avanza 8 bytes en el dest
    add r14d, 4 ; avanza 4 pixeles en el dst
    jmp .ciclo_calcular_promedio_en_filas_restantes

    .ciclo_calcular_promedio_en_filas_restantes_fin:

    ; ultimos 2 pixeles de la fila
    sub r10, 8 ; retrocede 2 pixeles para corregir el ultimo pixel de la fila
    movq xmm0, [r10]
    pshufd xmm0, xmm0, 00000101b ; copia el pixel 2 en la posicion 1
    movq [r10], xmm0
    add r10, 8

    add r10, r11 ; se saltea una fila
    inc r15d
    jmp .ciclo_calcular_promedio_en_filas_restantes_recorrer_filas

    .ciclo_calcular_promedio_en_filas_restantes_recorrer_filas_fin:

    ; Stack frame
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
ret