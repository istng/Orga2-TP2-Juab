global ASM_fourCombine
extern C_fourCombine

;RDI <--src
;RSI <--srcw
;RDX <-- srch
;rcx <-- dst

;  _________________________________________
; |                   |                    |
; |   1er Cuadrante   |   2do Cuadrante    |
; |________________________________________|
; |                   |                    |
; |   3er Cuadrante   |   4to Cuadrante    |
; |___________________|____________________|


; 1er Cuadrante = dst
; 2do Cuadrante = dst + 4*1/2 srcw
; 3er Cuadrante = dst + 1/2*srch*4*srcw
; 4to Cuadrante = dst + (4*srcw) * (1/2*srch) + 4*1/2*srcw



ASM_fourCombine:
push r12;
push r13
push r14
push r15

mov r12,rdi; r12 = src
mov r13,rsi; r13 = srcw <-- ancho de la imagen en pixels
mov r14,rsi; r14 = srcw
sal r14,2  ; r14 = 4*srcw <--- ancho de la imagen en bytes
mov r15,rdx

mov r8,rcx; R8 <-- 1er Cuadrante

mov r9,rsi; R9 = srcw
sal r9,1 ;  R9 = 2*srcw = 4*1/2*srcw
add r9,rcx; r9 <--2do Cuadrante

mov rax,r15; rax = srch
sar rax,1;   rax = 1/2 * srch
mul r14;     rax = (4*srcw) * (1/2*srch)
mov r10,rax; r10 = (4*srcw) * (1/2*srch)
add r10,rcx ;r10 = dst + (4*srcw) * (1/2*srch) <---- 3er Cuadrante
mov r11,rax ;r11 = (4*srcw) * (1/2*srch)
add r11,r9 ; r11 = dst + (4*srcw) * (1/2*srch) + 4*1/2*srcw  <--- 4to Cuadrante

; Nota: durante todo el ciclo tenemos en rdi el pixel fuente, este puntero lo movemos
; en cada ciclo interno pero como no tocamos ese registro en ningun otro momento esta
; todo bien.


mov rcx,r15; rcx = cantidad de filas
.ciclo_filas:
cmp rcx,0
je .fin;
push rcx; guardamos rcx;

  ;******************************
  ;**********Fila Par ***********
  ;******************************
  .filaPar:
  ; Nos preparamos para ciclar
  mov rcx,r13; rcx = srcw
  mov rsi,r8 ; rsi <-- puntero al 1er cuadrante
  mov rdx,r9 ; rcx <-- puntero al 2do cuadrante

  .ciclo_columnasPar:
  cmp rcx,4; nos fijamos si estabamos en las ultimas 4 columnas
  jle .ultimas4Pares;
  call ordenar; ordenamos 8 filas
  add rdi,32 ; avanzamos el puntero en 8 pixeles (32 bytes)
  add rsi,16 ; avanzamos el puntero del 1er cuadrante en 4 pixeles (16 bytes)
  add rdx,16 ; avanzamos el puntero del 2do cuadrante en 4 pixeles (16 bytes)
  cmp rcx,8 ;
  je .seguirPar; si eran las ultimas 8 terminamos
  sub rcx,7 ; ya recorrimos 8 columnas
  loop .ciclo_columnasPar;

  .ultimas4Pares:
  call ordenar4;
  add rdi,16; avanzamos el puntero en 4 pixeles (16 bytes)

  .seguirPar:
  add r8,r14
  add r9,r14

  ;******************************
  ;**********Fila Par ***********
  ;******************************
  .filaImpar:
  ; Nos preparamos para ciclar
  mov rcx,r13; rcx = srcw
  mov rsi,r10 ; rsi <-- puntero al 1er cuadrante
  mov rdx,r11 ; rcx <-- puntero al 2do cuadrante

  .ciclo_columnasImpar:
  cmp rcx,4; nos fijamos si estabamos en las ultimas 4 columnas
  jle .ultimas4Impares;
  call ordenar; ordenamos 8 filas
  add rdi,32 ; avanzamos el puntero en 8 pixeles (32 bytes)
  add rsi,16 ; avanzamos el puntero del 1er cuadrante en 4 pixeles (16 bytes)
  add rdx,16 ; avanzamos el puntero del 2do cuadrante en 4 pixeles (16 bytes)
  cmp rcx,8 ;
  je .seguirImpar; si eran las ultimas 8 terminamos
  sub rcx,7 ; ya recorrimos 8 columnas
  loop .ciclo_columnasImpar;

  .ultimas4Impares:
  call ordenar4;
  add rdi,16; avanzamos el puntero en 4 pixeles (16 bytes)

  .seguirImpar:
  add r10,r14;
  add r11,r14;
  pop rcx; recuperamos el indice de filas
  sub rcx,2; lo decrementamos en 2
  jmp .ciclo_filas;


.fin:
pop r15
pop r14
pop r13
pop r12
ret


;-----------------------------------------------------


;RDI <-- puntero a los pixeles del src
;RSI <-- puntero al primer cuadrante
;RDX <-- puntero al segundo cuadrante
global ordenar4
ordenar4:

movdqu xmm0,[rdi] ;         xmm0 = | p4 | p3 | p2 | p1 |
pshufd xmm0,xmm0,11011000b; xmm0 = | p4 | p2 | p3 | p1 |
movq [rsi],xmm0;
pshufd xmm0,xmm0,01001110b;  xmm0 = | p4 | p4 | p4 | p2 |
movq [rdx],xmm0;
ret
;------------------------------------------------


;-----------------------------------------------------


;RDI <-- puntero a los pixeles del src
;RSI <-- puntero al primer cuadrante
;RDX <-- puntero al segundo cuadrante
global ordenar
ordenar:

movdqu xmm0,[rdi] ;         xmm0 = | p4 | p3 | p2 | p1 |
movdqu xmm1,[rdi + 16] ;    xmm1 = | p8 | p7 | p6 | p5 |

pshufd xmm0,xmm0,11011000b; xmm0 = | p4 | p2 | p3 | p1 |
pshufd xmm1,xmm1,10001101b; xmm1 = | p7 | p5 | p8 | p6 |

pblendw xmm2,xmm0,00001111b; xmm2 = | ?? | ?? | p3 | p1 |
pblendw xmm2,xmm1,11110000b; xmm2 = | p7 | p5 | p3 | p1 |

pblendw xmm1,xmm0,11110000b; xmm1 = | p4 | p2 | p8 | p6 |
pshufd  xmm1,xmm1,01001110b; xmm1 = | p8 | p6 | p4 | p2 |

movdqu [rsi],xmm2;
movdqu [rdx],xmm1;
ret
;------------------------------------------------
