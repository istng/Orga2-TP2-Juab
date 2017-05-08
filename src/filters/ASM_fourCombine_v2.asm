global ASM_fourCombine_v2
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




ASM_fourCombine_v2:
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


  ; Nos preparamos para ciclar
  mov rcx,r13; rcx = srcw
  ;mov rsi,r8 ; rsi <-- puntero al 1er cuadrante
  ;mov rdx,r9 ; rcx <-- puntero al 2do cuadrante

  .ciclo_columnas:
  call ordenar_v2; ordenamos 8 filas
  add rdi,16  ; avanzamos el puntero en 4 pixeles (32 bytes)
  add r8,8 ; avanzamos el puntero del 1er cuadrante en 4 pixeles (16 bytes)
  add r9,8 ; avanzamos el puntero del 2do cuadrante en 4 pixeles (16 bytes)
  add r10,8 ; avanzamos el puntero del 3er cuadrante en 4 pixeles (16 bytes)
  add r11,8 ; avanzamos el puntero del 4to cuadrante en 4 pixeles (16 bytes)
  cmp rcx,8 ;
  je .seguir; si eran las ultimas 4 terminamos
  sub rcx,3 ; ya recorrimos 4 columnas
  loop .ciclo_columnas;

  .seguir:
  add r8,r13
  add r9,r13
  add r10,r13
  add r11,r13


  pop rcx; recuperamos el indice de filas
  sub rcx,2; lo decrementamos en 2 pues recorrimos 2 filas
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
global ordenar_v2
ordenar_v2:

movdqu xmm0,[rdi] ;            xmm0 = | p4 | p3 | p2 | p1 |
movdqu xmm1,[rdi + r14] ;      xmm1 = | p8 | p7 | p6 | p5 |

pshufd xmm0,xmm0,11011000b; xmm0 = | p4 | p2 | p3 | p1 |
pshufd xmm1,xmm1,11011000b; xmm1 = | p8 | p6 | p7 | p5 |

movq [r8],xmm0
movq [r10],xmm1
pshufd  xmm0,xmm0,01001110b; xmm0 = | p3 | p1 | p4 | p2 |
pshufd  xmm1,xmm1,01001110b; xmm0 = | p7 | p5 | p8 | p6 |

movq [r9],xmm0
movq [r11],xmm1

ret
;------------------------------------------------
