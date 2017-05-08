global ASM_fourCombine_unrolling
extern C_fourCombine_unrolling

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



;-----------------------------------------------------


;RDI <-- puntero a los pixeles del src
;RSI <-- puntero al primer cuadrante
;RDX <-- puntero al segundo cuadrante
%macro ordenar4 0
movdqu xmm0,[rdi] ;         xmm0 = | p4 | p3 | p2 | p1 |
pshufd xmm0,xmm0,11011000b; xmm0 = | p4 | p2 | p3 | p1 |
movq [rsi],xmm0;
pshufd xmm0,xmm0,01001110b;  xmm0 = | p4 | p4 | p4 | p2 |
movq [rdx],xmm0;
%endmacro
;------------------------------------------------




;-----------------------------------------------------


;RDI <-- puntero a los pixeles del src
;RSI <-- puntero al primer cuadrante
;RDX <-- puntero al segundo cuadrante
%macro ordenar8 0

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
%endmacro
;------------------------------------------------


;-----------------------------------------------------


;/***********Buscamos datos de Memoria *************/

;RDI <-- puntero a los pixeles del src
;RSI <-- puntero al primer cuadrante
;RDX <-- puntero al segundo cuadrante
%macro ordenar56 0

;TODO: CAMBIAR MOVDQU POR MOVDQA
movdqa xmm1,[rdi] ;         xmm0 = | p4 | p3 | p2 | p1 |
movdqa xmm2,[rdi + 16] ;    xmm1 = | p8 | p7 | p6 | p5 |
;-------------------------------------------------------
movdqa xmm3,[rdi + 32] ;    xmm1 = | p8 | p7 | p6 | p5 |
movdqa xmm4,[rdi + 48] ;    xmm1 = | p8 | p7 | p6 | p5 |
;-------------------------------------------------------
movdqa xmm5,[rdi + 64] ;    xmm1 = | p8 | p7 | p6 | p5 |
movdqa xmm6,[rdi + 80] ;    xmm1 = | p8 | p7 | p6 | p5 |
;-------------------------------------------------------
movdqa xmm7,[rdi + 96] ;    xmm1 = | p8 | p7 | p6 | p5 |
movdqa xmm8,[rdi + 112] ;    xmm1 = | p8 | p7 | p6 | p5 |
;-------------------------------------------------------
movdqa xmm9,[rdi + 128] ;    xmm1 = | p8 | p7 | p6 | p5 |
movdqa xmm10,[rdi + 144] ;    xmm1 = | p8 | p7 | p6 | p5 |
;-------------------------------------------------------
movdqa xmm11,[rdi + 160] ;    xmm1 = | p8 | p7 | p6 | p5 |
movdqa xmm12,[rdi + 176] ;    xmm1 = | p8 | p7 | p6 | p5 |
;-------------------------------------------------------
movdqa xmm13,[rdi + 192] ;    xmm1 = | p8 | p7 | p6 | p5 |
movdqa xmm14,[rdi + 208] ;    xmm1 = | p8 | p7 | p6 | p5 |
;-------------------------------------------------------



;/******************Procesamos******************/

;-------------------------------------------------------
movdqu xmm0,xmm1
pshufd xmm0,xmm0,11011000b; xmm0 = | p4 | p2 | p3 | p1 |
pshufd xmm2,xmm2,10001101b; xmm2 = | p7 | p5 | p8 | p6 |

pblendw xmm1,xmm0,00001111b; xmm1 = | ?? | ?? | p3 | p1 |
pblendw xmm1,xmm2,11110000b; xmm1 = | p7 | p5 | p3 | p1 |

pblendw xmm2,xmm0,11110000b; xmm2 = | p4 | p2 | p8 | p6 |
pshufd  xmm2,xmm2,01001110b; xmm2 = | p8 | p6 | p4 | p2 |
;-------------------------------------------------------
movdqu xmm0,xmm3
pshufd xmm0,xmm0,11011000b; xmm0 = | p4 | p2 | p3 | p1 |
pshufd xmm4,xmm4,10001101b; xmm4 = | p7 | p5 | p8 | p6 |

pblendw xmm3,xmm0,00001111b; xmm3 = | ?? | ?? | p3 | p1 |
pblendw xmm3,xmm4,11110000b; xmm1 = | p7 | p5 | p3 | p1 |

pblendw xmm4,xmm0,11110000b; xmm4 = | p4 | p2 | p8 | p6 |
pshufd  xmm4,xmm4,01001110b; xmm4 = | p8 | p6 | p4 | p2 |
;-------------------------------------------------------
movdqu xmm0,xmm5
pshufd xmm0,xmm0,11011000b; xmm0 = | p4 | p2 | p3 | p1 |
pshufd xmm6,xmm6,10001101b; xmm6 = | p7 | p5 | p8 | p6 |

pblendw xmm5,xmm0,00001111b; xmm5 = | ?? | ?? | p3 | p1 |
pblendw xmm5,xmm6,11110000b; xmm5 = | p7 | p5 | p3 | p1 |

pblendw xmm6,xmm0,11110000b; xmm6 = | p4 | p2 | p8 | p6 |
pshufd  xmm6,xmm6,01001110b; xmm6 = | p8 | p6 | p4 | p2 |
;-------------------------------------------------------
movdqu xmm0,xmm7
pshufd xmm0,xmm0,11011000b; xmm0 = | p4 | p2 | p3 | p1 |
pshufd xmm8,xmm8,10001101b; xmm8 = | p7 | p5 | p8 | p6 |

pblendw xmm7,xmm0,00001111b; xmm7 = | ?? | ?? | p3 | p1 |
pblendw xmm7,xmm8,11110000b; xmm7 = | p7 | p5 | p3 | p1 |

pblendw xmm8,xmm0,11110000b; xmm8 = | p4 | p2 | p8 | p6 |
pshufd  xmm8,xmm8,01001110b; xmm8 = | p8 | p6 | p4 | p2 |
;-------------------------------------------------------
movdqu xmm0,xmm9
pshufd xmm0,xmm0,11011000b; xmm0 = | p4 | p2 | p3 | p1 |
pshufd xmm10,xmm10,10001101b; xmm10 = | p7 | p5 | p8 | p6 |

pblendw xmm9,xmm0,00001111b; xmm9 = | ?? | ?? | p3 | p1 |
pblendw xmm9,xmm10,11110000b; xmm9 = | p7 | p5 | p3 | p1 |

pblendw xmm10,xmm0,11110000b; xmm10 = | p4 | p2 | p8 | p6 |
pshufd  xmm10,xmm10,01001110b; xmm10 = | p8 | p6 | p4 | p2 |
;-------------------------------------------------------
movdqu xmm0,xmm11
pshufd xmm0,xmm0,11011000b; xmm0 = | p4 | p2 | p3 | p1 |
pshufd xmm12,xmm12,10001101b; xmm12 = | p7 | p5 | p8 | p6 |

pblendw xmm11,xmm0,00001111b; xmm11 = | ?? | ?? | p3 | p1 |
pblendw xmm11,xmm12,11110000b; xmm11 = | p7 | p5 | p3 | p1 |

pblendw xmm12,xmm0,11110000b; xmm12 = | p4 | p2 | p8 | p6 |
pshufd  xmm12,xmm12,01001110b; xmm12 = | p8 | p6 | p4 | p2 |
;-------------------------------------------------------
movdqu xmm0,xmm13
pshufd xmm0,xmm0,11011000b; xmm0 = | p4 | p2 | p3 | p1 |
pshufd xmm14,xmm14,10001101b; xmm14 = | p7 | p5 | p8 | p6 |

pblendw xmm13,xmm0,00001111b; xmm13 = | ?? | ?? | p3 | p1 |
pblendw xmm13,xmm14,11110000b; xmm1 = | p7 | p5 | p3 | p1 |

pblendw xmm14,xmm0,11110000b; xmm14 = | p4 | p2 | p8 | p6 |
pshufd  xmm14,xmm14,01001110b; xmm14 = | p8 | p6 | p4 | p2 |
;-------------------------------------------------------



;/****************Escribimos en Memoria*****************/

movdqa [rsi],xmm1;
movdqa [rdx],xmm2;
;----------------------------------------------------
movdqa [rsi + 16],xmm3;
movdqa [rdx + 16],xmm4;
;----------------------------------------------------
movdqa [rsi + 32],xmm5;
movdqa [rdx + 32],xmm6;
;----------------------------------------------------
movdqa [rsi + 48],xmm7;
movdqa [rdx + 48],xmm8;
;----------------------------------------------------
movdqa [rsi + 64],xmm9;
movdqa [rdx + 64],xmm10;
;----------------------------------------------------
movdqa [rsi + 80],xmm11;
movdqa [rdx + 80],xmm12;
;----------------------------------------------------
movdqa [rsi + 96],xmm13;
movdqa [rdx + 96],xmm14;




%endmacro
;------------------------------------------------







ASM_fourCombine_unrolling:
push rbp
mov rbp,rsp
push rbx

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

; En esta version del codigo procesaremos 64 pixeles por ciclo


xor rdx,rdx
mov rax,r13; rax = srcw
mov rsi,56
div rsi; rax = srcw /64 || rdx = srcw mod 64
mov rbp,rax; rbp = srcw / 64
mov rbx,rdx; rdx = srcw mod 64

xor rcx,rcx;
.ciclo_filas:
cmp rcx,r15
je fin_fourCombine;
push rcx
  ;******************************
  ;**********Fila Par ***********
  ;******************************
  .filaPar:
  ; Nos preparamos para ciclar
  mov rcx,0; rcx = srcw
  mov rsi,r8 ; rsi <-- puntero al 1er cuadrante
  mov rdx,r9 ; rcx <-- puntero al 2do cuadrante
  .ciclo_columnasPar:
  cmp rcx,rbp
  je .seguirConParesRestantes


;/**** Procesamos 64 pixeles *****/
  ordenar56; ordenamos 8 pixeles
  add rdi,224; avanzamos el puntero en 8 pixeles (32 bytes)
  add rsi,112 ; avanzamos el puntero del 1er cuadrante en 4 pixeles (16 bytes)
  add rdx,112 ; avanzamos el puntero del 2do cuadrante en 4 pixeles (16 bytes)
  add rcx,1
  jmp .ciclo_columnasPar




  ;/*** lo que quedo seguro es multiplo de 4

  .seguirConParesRestantes:
  xor rcx,rcx; rcx = 0
  .cicloParesRestates:
    cmp rcx,rbx;
    jge .seguirConImpares
    ordenar4; ordenamos 4 pixels
    add rdi,16 ; avanzamos el puntero en 4 pixeles (32 bytes)
    add rsi,8 ; avanzamos el puntero del 1er cuadrante en 2 pixeles (16 bytes)
    add rdx,8 ; avanzamos el puntero del 2do cuadrante en 2 pixeles (16 bytes)
    add rcx,4 ; procesamos 4 pixeles
    jmp .cicloParesRestates

  .seguirConImpares:
  add r8,r14
  add r9,r14



  ;******************************
  ;**********Fila Impar *********
  ;******************************
  .filaImpar:
  ; Nos preparamos para ciclar
  mov rcx,0; rcx = srcw
  mov rsi,r10 ; rsi <-- puntero al 3er cuadrante
  mov rdx,r11 ; rcx <-- puntero al 4to cuadrante
  .ciclo_columnasImpar:
  cmp rcx,rbp
  je .seguirConImparesRestantes


;/**** Procesamos 64 pixeles *****/
  ordenar56; ordenamos 8 pixeles
  add rdi,224; avanzamos el puntero en 8 pixeles (32 bytes)
  add rsi,112 ; avanzamos el puntero del 1er cuadrante en 4 pixeles (16 bytes)
  add rdx,112 ; avanzamos el puntero del 2do cuadrante en 4 pixeles (16 bytes)
  add rcx,1
  jmp .ciclo_columnasImpar


  ;/*** lo que quedo seguro es multiplo de 4


  .seguirConImparesRestantes:
  xor rcx,rcx; rcx = 0

  .cicloImparesRestates:
    cmp rcx,rbx;
    jge .seguir
    ordenar4; ordenamos 4 pixels
    add rdi,16 ; avanzamos el puntero en 4 pixeles (32 bytes)
    add rsi,8 ; avanzamos el puntero del 3er cuadrante en 2 pixeles (16 bytes)
    add rdx,8 ; avanzamos el puntero del 4to cuadrante en 2 pixeles (16 bytes)
    add rcx,4
    jmp .cicloImparesRestates

.seguir:
add r10,r14
add r11,r14
pop rcx; recuperamos el indice de filas
add rcx,2; lo incrementamos en 2 pues recorrimos dos filas
jmp .ciclo_filas


fin_fourCombine:
pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret
