
global ASM_maxCloser_cache



;RDI <-- SRC
;RSI <-- SRCW
;RDX <-- SRCH
;RCX <-- DST
;R8 <-- dstw
;R9 <-- dsth
;XMM0 <--- VAL



ASM_maxCloser_cache:
push rbp
mov rbp,rsp
push rbx

push r12
push r13
push r14
push r15

movdqu xmm1,xmm0; xmm1 = | ??? | ??? | ??? | val |
movdqu xmm2,xmm0; xmm2 = | ??? | ??? | ??? | val |
shufps xmm1,xmm2, 0 ; xmm1 = | val | val | val | val |  ******CONSULTAR SI ESTA BIEN !!!!!
movdqu xmm4,xmm1; guardamos el registro con los valores en xmm4

mov r12,rdi ;r12 <-- SRC
mov r13,rsi ;r13 <-- SRCW = cantidad de columnas
mov r14,rdx ;r14 <-- SRCH = cantida de filas
mov r15,rcx ;r15 <-- DST

mov rax,r13; rax <-- srcw
inc rax; rax = srcw + 1
mov qword rdx,12;
mul rdx ; rax = 12*(srcw+1) ; rax <-- offset_primero_Kernel
mov r8,rax ; **** R8 = offset_primero_Kernel ****


xor r10,r10
xor r11,r11
mov r10,r13;r10 = srcw;
mov r11,r14;r11 = srch;
sub r10,3 ; r10 = borde derecha
sub r11,3 ; r11 = borde superior

xor rdx,rdx
mov rax,rsi; rax = srcw
mov r9,10; rdx = 10;
div r9; rax = rax/10 ||| rdx = rax mod 10

mov rcx,rax; rcx = rax mod 10 == numero de lineas
mov rbp,rcx;
xor rcx,rcx

.ciclo_linea:
cmp rcx,rbp; si llegamos al final terminamos
je .ultimaLinea;
push rcx

;/*vamos a guardarnos el indice_line*16 en rdx*/
mov rax,rcx; rax = indice
mov rdx,10; rdx = 10
mul rdx; rax = 10*rdx
mov rdx,rax; rdx = indice_linea*10

xor rcx,rcx; rcx = 0;

  .ciclo_filas:
  cmp rcx,r14;
  je .siguienteLinea;
  push rdx; pusheamos a la pila el indice_linea*10
  push rcx; pusheamos i
  mov rcx,0; rcx <--- tamaño de la linea de cache
    .ciclo_colunas:
    ; El pixel que tenemos que darle a ASM_kernelValues = src + 4*i*srcw +  4*j - offset_primero_Kernel
    ; Donde j tendria que ser = indice_linea*16 + j
    cmp rcx,10;
    jg .fin_columnas
    mov rdi,r12 ; rdi = src
    mov rax,r13 ; rax = srcw
    pop r9;  r9 = i
    mul r9;  rax = i*srcw
    xor rdx,rdx
    pop rdx; rdx = indice_linea*16
    push rdx
    push r9
    add rdx,rcx; /**** RDX = indice_linea*10+j ****/
    add rax,rdx; rax = i*srcw + indice_linea*10+j
    sal rax,2; rax = 4* (i*srcw + indice_linea*10+j)
    push rax;guardamos el desplazamiento actual
    add rdi,rax; rdi = src + 4*i*srcw +  4*(indice_linea*10 + j)
    jmp .esBorde;
    .noLoEs:
    ; TODO: arreglar esBorde
    sub rdi,r8; rdi = src + 4*i*srcw + 4*j - offset_primero_Kernel
    mov rsi,r13; rsi = srcw
    push rcx; guardamos el contador
    call ASM_kernelValues;
    jmp .pixel
    .seguir:
    inc rcx;/* rcx = j  + 1 */
    jmp .ciclo_colunas;

  .fin_columnas:
  pop rcx; rcx = j
  pop rdx; sacamos de la pila en indice que habia antes
  inc rcx; i = i + 1
  jmp .ciclo_filas;

.siguienteLinea:
pop rcx; rcx = indice_linea
inc rcx; indice_linea = indice_linea + 1
jmp .ciclo_linea


;/***** Procesamos la ultima Linea *****/
.ultimaLinea:


xor rdx,rdx
mov rax,r13; rax = srcw
mov r9,10; rdx = 10;
div r9; rax = rax/10 ||| rdx = rax mod 10
mov rbp,rdx; rdx <-- ancho columna restante

cmp rbp,0;
je .fin;

mov rdx,10; rdx = 10
mul rdx; rax = 10*rdx
mov rdx,rax; rdx = indice_linea*10


xor rcx,rcx
  .ciclo_filas2:
  cmp rcx,r14;
  je .fin;
  push rdx; pusheamos a la pila el indice_linea*16
  push rcx; pusheamos i
  mov rcx,0; rcx <--- 0
    .ciclo_colunas2:
    ; El pixel que tenemos que darle a ASM_kernelValues = src + 4*i*srcw +  4*j - offset_primero_Kernel
    ; Donde j tendria que ser = indice_linea*16 + j
    cmp rcx,rbp;
    jg .fin_columnas2
    mov rdi,r12 ; rdi = src
    mov rax,r13 ; rax = srcw
    pop r9;  r9 = i
    mul r9;  rax = i*srcw
    xor rdx,rdx
    pop rdx; rdx = indice_linea*16
    push rdx
    push r9
    add rdx,rcx; /**** RDX = indice_linea*10+j ****/
    add rax,rdx; rax = i*srcw + indice_linea*10+j
    sal rax,2; rax = 4* (i*srcw + indice_linea*10+j)
    push rax;guardamos el desplazamiento actual
    add rdi,rax; rdi = src + 4*i*srcw +  4*(indice_linea*10 + j)
    jmp .esBorde2;
    .noLoEs2:
    ; TODO: arreglar esBorde
    sub rdi,r8; rdi = src + 4*i*srcw + 4*j - offset_primero_Kernel
    mov rsi,r13; rsi = srcw
    push rcx; guardamos el contador
    call ASM_kernelValues;
    jmp .pixel2
    .seguir2:
    inc rcx;/* rcx = j  + 1 */
    jmp .ciclo_colunas2;

  .fin_columnas2:
  pop rcx; rcx = j
  pop rdx; sacamos de la pila en indice que habia antes
  inc rcx; i = i + 1
  jmp .ciclo_filas2;





.pixel:
pop rcx; recuperamos el contador de las columnas (j)
pop rax; recuperamos el desplazamiento del pixel actual
pxor xmm2,xmm2       ; xmm0 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
punpcklbw xmm0,xmm2  ; xmm0 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | maxR | 0 | maxG | 0 | maxB | 0 | basura |
punpcklwd xmm0,xmm2  ; xmm0 = | 0 | 0 | 0 | maxR | 0 | 0 | 0 | maxG | 0 | 0 | 0 | maxB | 0 | 0 | 0 | basura |
cvtdq2ps xmm0,xmm0   ; xmm0 = | float_sp(maxR) | float_sp(maxG) | float_sp(maxB) | 0.00000000000000000 |
mulps xmm0,xmm4      ; xmm0 = |    maxR*val    |    maxg*val    |    maxB*val    | 0.00000000000000000 |
pxor xmm1,xmm1       ; xmm1 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
movd xmm1,[r12+rax]  ; xmm1 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | R | G | B | A |
punpcklbw xmm1,xmm2  ; xmm1 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | R | 0 | G | 0 | B | 0 | A |
punpcklwd xmm1,xmm2  ; xmm1 = | 0 | 0 | 0 | R | 0 | 0 | 0 | G | 0 | 0 | 0 | B | 0 | 0 | 0 | A |
cvtdq2ps xmm1,xmm1   ; xmm1 = |  float_sp(R)  |   float_sp(G) |  float_sp(B)  |  float_sp(A)  |
movups xmm2,xmm1     ; xmm2 = |  float_sp(R)  |   float_sp(G) |  float_sp(B)  |  float_sp(A)  |
mulps xmm2,xmm4      ; xmm2 = |     R*val     |     G*val     |      B*val    |     A*val     | aca son todos floats
subps xmm1,xmm2      ; xmm1 = |   R*(1-val)   |   G*(1-val)   |   B*(1-val)   |   A*(1-val)   |
addps xmm0,xmm1      ; xmm0 = |   R*(1-val) +  maxR*val    |   G*(1-val) +  maxG*val    |  B*(1-val) + maxB*val    |  A*(1-val) |
cvtps2dq xmm0,xmm0   ; xmm0 = |   R*(1-val) +  maxR*val    |   G*(1-val) +  maxG*val    |  B*(1-val) + maxB*val    |  A*(1-val) | EN DWORD TRUNCADOS
;psrld xmm0,1         ; xmm0 = |  0000000000000000000000    |   R*(1-val) +  maxR*val    |  G*(1-val) +  maxG*val   |  B*(1-val) + maxB*val  |
pshufd xmm0,xmm0,00111001b; xmm0 = |  A*(1-val)   |   R*(1-val) +  maxR*val    |  G*(1-val) +  maxG*val   |  B*(1-val) + maxB*val  |
pxor xmm1,xmm1       ; xmm1 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
packusdw xmm0,xmm1   ; xmm0 = | 0000 | 0000 |  0000 |  0000 | R*(1-val) +  maxR*val|G*(1-val) +  maxG*val|B*(1-val) + maxB*val|  A*(1-val) | **EN UNSIGNED WORDS
packuswb xmm0,xmm0   ; xmm0 = | 0 | 0 | 0 | 0 | R | G | B | basura  | 0 | 0 | 0 | 0 | R | G | B | basura |
mov byte sil,[r12 + rax];
mov byte [r15 + rax],sil ; ponemos en la imagen(dst) el primer pixel (A) que lo dejamos igual
movd [r15 + rax + 1], xmm0 ; ponemos en la imagen(dst) los pixeles R,G y B
jmp .seguir;

.pixel2:
pop rcx; recuperamos el contador de las columnas (j)
pop rax; recuperamos el desplazamiento del pixel actual
pxor xmm2,xmm2       ; xmm0 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
punpcklbw xmm0,xmm2  ; xmm0 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | maxR | 0 | maxG | 0 | maxB | 0 | basura |
punpcklwd xmm0,xmm2  ; xmm0 = | 0 | 0 | 0 | maxR | 0 | 0 | 0 | maxG | 0 | 0 | 0 | maxB | 0 | 0 | 0 | basura |
cvtdq2ps xmm0,xmm0   ; xmm0 = | float_sp(maxR) | float_sp(maxG) | float_sp(maxB) | 0.00000000000000000 |
mulps xmm0,xmm4      ; xmm0 = |    maxR*val    |    maxg*val    |    maxB*val    | 0.00000000000000000 |
pxor xmm1,xmm1       ; xmm1 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
movd xmm1,[r12+rax]  ; xmm1 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | R | G | B | A |
punpcklbw xmm1,xmm2  ; xmm1 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | R | 0 | G | 0 | B | 0 | A |
punpcklwd xmm1,xmm2  ; xmm1 = | 0 | 0 | 0 | R | 0 | 0 | 0 | G | 0 | 0 | 0 | B | 0 | 0 | 0 | A |
cvtdq2ps xmm1,xmm1   ; xmm1 = |  float_sp(R)  |   float_sp(G) |  float_sp(B)  |  float_sp(A)  |
movups xmm2,xmm1     ; xmm2 = |  float_sp(R)  |   float_sp(G) |  float_sp(B)  |  float_sp(A)  |
mulps xmm2,xmm4      ; xmm2 = |     R*val     |     G*val     |      B*val    |     A*val     | aca son todos floats
subps xmm1,xmm2      ; xmm1 = |   R*(1-val)   |   G*(1-val)   |   B*(1-val)   |   A*(1-val)   |
addps xmm0,xmm1      ; xmm0 = |   R*(1-val) +  maxR*val    |   G*(1-val) +  maxG*val    |  B*(1-val) + maxB*val    |  A*(1-val) |
cvtps2dq xmm0,xmm0   ; xmm0 = |   R*(1-val) +  maxR*val    |   G*(1-val) +  maxG*val    |  B*(1-val) + maxB*val    |  A*(1-val) | EN DWORD TRUNCADOS
;psrld xmm0,1         ; xmm0 = |  0000000000000000000000    |   R*(1-val) +  maxR*val    |  G*(1-val) +  maxG*val   |  B*(1-val) + maxB*val  |
pshufd xmm0,xmm0,00111001b; xmm0 = |  A*(1-val)   |   R*(1-val) +  maxR*val    |  G*(1-val) +  maxG*val   |  B*(1-val) + maxB*val  |
pxor xmm1,xmm1       ; xmm1 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
packusdw xmm0,xmm1   ; xmm0 = | 0000 | 0000 |  0000 |  0000 | R*(1-val) +  maxR*val|G*(1-val) +  maxG*val|B*(1-val) + maxB*val|  A*(1-val) | **EN UNSIGNED WORDS
packuswb xmm0,xmm0   ; xmm0 = | 0 | 0 | 0 | 0 | R | G | B | basura  | 0 | 0 | 0 | 0 | R | G | B | basura |
mov byte sil,[r12 + rax];
mov byte [r15 + rax],sil ; ponemos en la imagen(dst) el primer pixel (A) que lo dejamos igual
movd [r15 + rax + 1], xmm0 ; ponemos en la imagen(dst) los pixeles R,G y B
jmp .seguir2;




.esBorde:
;r9 <-- indice filas
;rcx<-- indice de columnas
;en la pila tenemos el rax con el desplazamiento al pixel actual

cmp r9,3;
jb .loEs;
cmp r9,r11;
jae .loEs;
cmp rdx,3;
jb .loEs;
cmp rdx,r10;
jae .loEs;

jmp .noLoEs;

.esBorde2:
;r9 <-- indice filas
;rcx<-- indice de columnas
;en la pila tenemos el rax con el desplazamiento al pixel actual

cmp r9,3;
jb .loEs2;
cmp r9,r11;
jae .loEs2;
cmp rdx,3;
jb .loEs2;
cmp rdx,r10;
jae .loEs2;

jmp .noLoEs2;



.loEs:
pop rax;
mov dword [r15+rax],0xFFFFFFFF;
jmp .seguir;

.loEs2:
pop rax;
mov dword [r15+rax],0xFFFFFFFF;
jmp .seguir2;

.fin:
pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret








;|********************************************************|

;ASM_kernelValues : calcula el valor del los maximos del kernel para las 3 componentes, dejando estos en el regstro xmm1

;Parametros:
;RDI <-- SRC_PIXEL
;RSI <-- SRCW == tamaño de la fila

%define tam_kernel 6
; definimos el tamaño asi por que el kernel va de src_pixel+0 a src_pixel+6

;El puntero que recibe como parametro es al primer pixel del kernel.
;src
; |
; ∀
;|  p11  |  p12  |  p13  |  p14  |  p15  |  p16  |  p17  |
;|  p21  |  p22  |  p23  |  p24  |  p25  |  p26  |  p27  |
;|  p31  |  p32  |  p33  |  p34  |  p35  |  p36  |  p37  |
;|  p41  |  p42  |  p43  | <p44> |  p45  |  p46  |  p47  |
;|  p51  |  p52  |  p53  |  p54  |  p55  |  p56  |  p57  |
;|  p61  |  p62  |  p63  |  p64  |  p65  |  p66  |  p67  |
;|  p71  |  p72  |  p73  |  p74  |  p75  |  p76  |  p77  |


ASM_kernelValues:

push r12
push r13
push r14
push r15

mov r12,rdi ; guardamos el puntero al pixel incial del kernel
mov r13,rsi ; guardamos el tamaño de la fila (el pixeles)

;shl r13,2 ; shifteamos 2 bits a la derecha el tamaño de la fila para obtener su tamaño en pixeles
mov qword rcx,tam_kernel ; contador <-- 6 == cantidad de filas del kernel

movdqu xmm0,[r12]; xmm0 = | p11 | p12 | p13 | p14 |    <-- inicializamos el maximo en xmm0 con los primeros pixeles del kernel


; En el ciclo recorremos el kernel por filas:
; Dada una fila j: 1) cargamos sus primeros 4 pixeles en xmm1
;                  2) cargamos sus ultimos 4 pixeles en xmm2 ( notar que cargamos 2 veces el 4to pero no importa por que el maximo no va a variar)
;                  3) obtenemos los maximos entre ambos
;                  4) obtenemos los maximos entre estos ultimos (los del paso 3) y los maximos hasta el momento
;                  5) ciclamos

; xmm0 = |max4|max3|max2|max1|

 .ciclo:
  mov rax,rcx; rax = j (indice fila)
  mul r13;  rax = indice * tam fila (en bytes) = puntero a la fila que tenemos que comparar ahora
  movdqu xmm1,[r12 + rax*4]  ;            xmm1 = | pi4 | pi3 | pi2 | pi1 |
  movdqu xmm2,[r12 + rax*4 + 12];         xmm2 = | pi7 | pi6 | pi5 | pi4 |
  pmaxub xmm1,xmm2 ;              xmm1 = | max (pj4,max4) | max (pj3,max3) | max (pj2,max2) | max (pj1,max1) |
  pmaxub xmm0,xmm1 ;             xmm0 = | max (pj4,pj7,max4) | max (pj3,pj6,max3) | max (pj2,pj5,max2) | max (pj1,pj4,max1) |
  dec rcx;
  cmp rcx,0;
  jge .ciclo;





; ahora tenemos que :
; xmm0 = | max4 | max4 | max2 | max1 | <--- posibles maximos , tenemos que encontrar de estos el maximo para cada pixel

movdqu xmm1,xmm0            ; xmm1 = | max4 | max3 | max2 | max1 |
pshufd xmm2,xmm0,00001110b  ; xmm2 = | max1 | max1 | max4 | max3 |
pmaxub xmm1,xmm2            ; xmm1 = | ???? | ???? | max(max4,max2)| max(max3,max1) |
;movdqu xmm2,xmm1            ; xmm2 = | ???? | ???? | max(max4,max2)| max(max3,max1) |
pshufd xmm2,xmm1,01010101b; xmm2 = | max(max4,max2) | max(max4,max2) | max(max4,max2) | max(max4,max2) |  ***** shifteamos 2 words a la derecha
pmaxub xmm1,xmm2 ; xmm1 = | ???? | ???? | ???? | max {max1,max2,max3,max4}|
xor r14,r14 ;      r14 = | 0 | 0 | 0 | 0 |
movd r14d,xmm1 ;    r14 = | R | G | B | A |
pxor xmm0,xmm0 ;  xmm0 = | 0000 | 0000 | 0000 | 0000 |
movq xmm0,r14   ; xmm0 = | 0000 | 0000 | 0000 | max {max1,max2,max3,max4}|

; notar que como las comparaciones las hicimos por bytes ahora tenemos que :
; xmm0 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | maxR | maxG | maxB | basura |

pop r15
pop r14
pop r13
pop r12

ret
