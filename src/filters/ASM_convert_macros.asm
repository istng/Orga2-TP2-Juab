%macro convertirRGB 0
	;XMM10-> valores ABGR en 32 vits, XMM11->constantes para YUV c1,c2,c3
	;R8D->constante de suma interna (antes del shift), R9D->constante de suma final
	movdqu xmm9, xmm10;		xmm9 = a|v|u|y
	psubd xmm9, xmm12;		xmm9 = a-0|v-128|u-128|y-16 (los renombro por si mismos: v=v-128...)
	pmulld xmm9, xmm11;		xmm9= a*1|v*c1|u*c2|y*c3
	movdqu xmm8, xmm9;		xmm8 = xmm9
	pslldq xmm8, 4;			xmm8 = 0|a|v*c1|u*c2
	paddd xmm9, xmm8;		xmm9 = ??|??|u*c2+v*c1|y*c3+u*c2
	pslldq xmm8, 4;			xmm8 = 0|0|a|v*c1
	paddd xmm9, xmm8;		xmm9 = ??|??|??|y*c3+u*c2+v*c1
	mov r8, 128
	pinsrd xmm8, r8d, 3;	xmm8 = 0|0|a|128
	paddd xmm9, xmm8;		xmm9 = ??|??|??|y*c3+u*c2+v*c1+128
	psrad xmm9, 8;			xmm9 = xmm9 >> 8
%endmacro

%macro convertirYUV 0
	;XMM10-> valores ABGR en 32 bits, XMM11->constantes para YUV c1,c2,c3
	;R8D->constante de suma interna (antes del shift), R9D->constante de suma final
	movdqu xmm9, xmm10;		xmm9 = a|b|g|r
	pmulld xmm9, xmm11;		xmm9 = 1*a|c1*b|c2*g|c3*r
	movdqu xmm8, xmm9;		xmm8 = xmm9
	pslldq xmm8, 4;			xmm8 = 0|1*a|c1*b|c2*g
	paddd xmm9, xmm8;		xmm9 = ??|??|??|c2*g+c3*r
	pslldq xmm8, 4;			xmm8 = 0|0|1*a|c1*b
	paddd xmm9, xmm8;		xmm9 = ??|??|??|c1*b+c2*g+c3*r
	pinsrd xmm8, r8d, 3
	paddd xmm9, xmm8;		xmm9 = ??|??|??|c1*b+c2*g+c3*r + r8d
	psrad xmm9, 8;			xmm9 = xmm9 >> 8
	pinsrd xmm8, r9d, 3
	paddd xmm9, xmm8;		xmm9 = ??|??|??|casiYUV + r9d
%endmacro

global ASM_convertYUVtoRGB_macros
global ASM_convertRGBtoYUV_macros
extern C_convertYUVtoRGB_defines
extern C_convertRGBtoYUV_defines

ASM_convertYUVtoRGB_macros:
	;RDI-> *src, ESI-> int32 srcw, EDX-> int32 srch, RCX-> *dst, R8D-> int32 dstw, R9D-> dsth
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	mov rbx, rdi
	mov r15, rcx

	;consigo srcw*srch:
	xor r12, r12
	xor r13, r13
	mov r12d, esi
	mov r13d, edx
	imul r12, r13;	r12: srcw*srch
	sal r12, 2;		r12 = 4*srcw*srch

	;preparo todas las constantes:
	;preparo B:
	xor r9, r9
	mov r9, 516
	pinsrd xmm7, r9d, 2
	mov r9, 298
	pinsrd xmm7, r9d, 3
	;xmm7 = 0|0|516|298

	;preparo U:
	xor r9, r9
	mov r9d, -208
	pinsrd xmm6, r9d, 1
	mov r9d, -100
	pinsrd xmm6, r9d, 2
	mov r9d, 298
	pinsrd xmm6, r9d, 3
	;xmm6 = 0|-208|-100|298

	;preparo Y:
	xor r9, r9
	mov r9d, 409
	pinsrd xmm5, r9d, 1
	mov r9d, 298
	pinsrd xmm5, r9d, 3
	;xmm5 = 1|25|129|66

	;preparo el sumador:
	xor r9, r9
	mov r9, 128
	pinsrd xmm12, r9d, 1
	pinsrd xmm12, r9d, 2
	mov r9, 16
	pinsrd xmm12, r9d, 3
	;xmm12 = 0|128|128|16


	.avanzar:
	movdqu xmm0, [rbx];		xmm0 = a0|v0|u0|y0|a1|v1|u1|y1|a2|v2|u2|y2|a3|v3|u3|y3
	
	;copio xmm0 para desempaquetar luego, y hago su mascara
	movdqu xmm1, xmm0
	movdqu xmm3, xmm0
	xorps xmm10, xmm10

	;desempaqueto xmm0 de byte a word:
	punpcklbw xmm1, xmm10;	xmm1 = a0|0|v0|0|u0|0|y0|0|a1|0|v1|0|u1|0|y1|0
	punpckhbw xmm3, xmm10;	xmm2 = a2|0|v2|0|u2|0|y2|0|a3|0|v3|0|u3|0|y3|0
	
	;desempaqueto xmm1 de word a double word:
	xorps xmm10, xmm10
	movdqu xmm2, xmm1
	punpcklwd xmm1, xmm10;	xmm1 = a0|v0|u0|y0
	punpckhwd xmm2, xmm10;	xmm2 = a1|v1|u1|y1

	;desempaqueto xmm3 de word a double word:
	xorps xmm10, xmm10
	movdqu xmm4, xmm3
	punpcklwd xmm3, xmm10;	xmm3 = a2|v2|u2|y2
	punpckhwd xmm4, xmm10;	xmm4 = a3|v3|u3|y3


	;**===========**
	;**|PARA XMM1|**
	;**===========**
		;===============
		;CONSEGUIMOS B0:
		;===============
		movdqu xmm10, xmm1
		movdqu xmm11, xmm7
		convertirRGB
		;tomo los valores obtenidos y los pego en xmm15:
		insertps xmm15, xmm1, 00000000b
		insertps xmm15, xmm9, 11010000b
	
		;===============
		;CONSEGUIMOS G0:
		;===============
		movdqu xmm10, xmm1
		movdqu xmm11, xmm6
		convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11100000b
	
		;===============
		;CONSEGUIMOS R0:
		;===============
		movdqu xmm10, xmm1
		movdqu xmm11, xmm5
		convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11110000b
	
		;devuelvo todo a xmm1:
		movdqu xmm1, xmm15


	;**===========**
	;**|PARA XMM2|**
	;**===========**
		;===============
		;CONSEGUIMOS B1:
		;===============
		movdqu xmm10, xmm2
		movdqu xmm11, xmm7
		convertirRGB
		;tomo los valores obtenidos y los pego en xmm0:
		insertps xmm15, xmm2, 00000000b
		insertps xmm15, xmm9, 11010000b
	
		;===============
		;CONSEGUIMOS G1:
		;===============
		movdqu xmm10, xmm2
		movdqu xmm11, xmm6
		convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11100000b
	
		;===============
		;CONSEGUIMOS R1:
		;===============
		movdqu xmm10, xmm2
		movdqu xmm11, xmm5
		convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11110000b

		;devuelvo todo a xmm2:
		movdqu xmm2, xmm15

	;**===========**
	;**|PARA XMM3|**
	;**===========**
		;===============
		;CONSEGUIMOS B2:
		;===============
		movdqu xmm10, xmm3
		movdqu xmm11, xmm7
		convertirRGB
		;tomo los valores obtenidos y los pego en xmm0:
		insertps xmm15, xmm3, 00000000b
		insertps xmm15, xmm9, 11010000b
	
		;===============
		;CONSEGUIMOS G2:
		;===============
		movdqu xmm10, xmm3
		movdqu xmm11, xmm6
		convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11100000b
	
		;===============
		;CONSEGUIMOS R2:
		;===============
		movdqu xmm10, xmm3
		movdqu xmm11, xmm5
		convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11110000b

		;devuelvo todo a xmm3:
		movdqu xmm3, xmm15

	;**===========**
	;**|PARA XMM4|**
	;**===========**
		;===============
		;CONSEGUIMOS B3:
		;===============
		movdqu xmm10, xmm4
		movdqu xmm11, xmm7
		convertirRGB
		;tomo los valores obtenidos y los pego en xmm0:
		insertps xmm15, xmm4, 00000000b
		insertps xmm15, xmm9, 11010000b
	
		;===============
		;CONSEGUIMOS G3:
		;===============
		movdqu xmm10, xmm4
		movdqu xmm11, xmm6
		convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11100000b
	
		;===============
		;CONSEGUIMOS R3:
		;===============
		movdqu xmm10, xmm4
		movdqu xmm11, xmm5
		convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11110000b

		;devuelvo todo a xmm4:
		movdqu xmm4, xmm15

		;=====================
		;SATURO Y REEMPAQUETO:
		;=====================

		;reempaqueto lo obtenido:
		packssdw xmm1, xmm2
		packssdw xmm3, xmm4

		packuswb xmm1, xmm3


		;===============
		;lo pego en dst:
		;===============
		movdqu [r15], xmm1



	;ya procese 16 componentes de pixel mas:
	sub r12, 16
	cmp r12, 0
	je .fin
	;avanzo en la imagen src y dst:
	lea rbx, [rbx + 16]
	lea r15, [r15 + 16]
	jmp .avanzar

	.fin:

	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
ret


ASM_convertRGBtoYUV_macros:
;RDI-> *src, ESI-> int32 srcw, EDX-> int32 srch, RCX-> *dst, R8D-> int32 dstw, R9D-> dsth
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	mov rbx, rdi
	mov r15, rcx

	;consigo srcw*srch:
	xor r12, r12
	xor r13, r13
	xor r12d, esi
	xor r13d, edx
	imul r12, r13;	r12: srcw*srch
	sal r12, 2;		r12 = 4*srcw*srch

	;preparo todas las constantes:
	;preparo V:
	xor r9, r9
	mov r9, -18
	pinsrd xmm7, r9d, 1
	mov r9, -94
	pinsrd xmm7, r9d, 2
	mov r9, 112
	pinsrd xmm7, r9d, 3
	;xmm7 = 1|-18|-94|112

	;preparo U:
	xor r9, r9
	mov r9d, 112
	pinsrd xmm6, r9d, 1
	mov r9d, -74
	pinsrd xmm6, r9d, 2
	mov r9d, -38
	pinsrd xmm6, r9d, 3
	;xmm6 = 1|112|-74|-38

	;preparo Y:
	xor r9, r9
	mov r9d, 25
	pinsrd xmm5, r9d, 1
	mov r9d, 129
	pinsrd xmm5, r9d, 2
	mov r9d, 66
	pinsrd xmm5, r9d, 3
	;xmm5 = 1|25|129|66


	.avanzar:
	movdqu xmm0, [rbx];		xmm0 = a0|b0|g0|r0|a1|b1|g1|r1|a2|b2|g2|r2|a3|b3|g3|r3
	
	;copio xmm0 para desempaquetar luego, y hago su mascara
	movdqu xmm1, xmm0
	movdqu xmm3, xmm0
	xorps xmm10, xmm10

	;desempaqueto xmm0 de byte a word:
	punpcklbw xmm1, xmm10;	xmm1 = a0|0|b0|0|g0|0|r0|0|a1|0|b1|0|g1|0|r1|0
	punpckhbw xmm3, xmm10;	xmm2 = a2|0|b2|0|g2|0|r2|0|a3|0|b3|0|g3|0|r3|0
	
	;desempaqueto xmm1 de word a double word:
	xorps xmm10, xmm10
	movdqu xmm2, xmm1
	punpcklwd xmm1, xmm10;	xmm1 = a0|b0|g0|r0
	punpckhwd xmm2, xmm10;	xmm2 = a1|b1|g1|r1

	;desempaqueto xmm3 de word a double word:
	xorps xmm10, xmm10
	movdqu xmm4, xmm3
	punpcklwd xmm3, xmm10;	xmm3 = a2|b2|g2|r2
	punpckhwd xmm4, xmm10;	xmm4 = a3|b3|g3|r3


	;**===========**
	;**|PARA XMM1|**
	;**===========**
		;===============
		;CONSEGUIMOS V0:
		;===============
		movdqu xmm10, xmm1
		movdqu xmm11, xmm7
		mov r8, 128
		mov r9, 128
		convertirYUV
		;tomo los valores obtenidos y los pego en xmm15:
		insertps xmm15, xmm1, 00000000b
		insertps xmm15, xmm9, 11010000b
	
		;===============
		;CONSEGUIMOS U0:
		;===============
		movdqu xmm10, xmm1
		movdqu xmm11, xmm6
		mov r8d, 128
		mov r9d, 128
		convertirYUV
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11100000b
	
		;===============
		;CONSEGUIMOS Y0:
		;===============
		movdqu xmm10, xmm1
		movdqu xmm11, xmm5
		mov r8d, 128
		mov r9d, 16
		convertirYUV
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11110000b
	
		;devuelvo todo a xmm1:
		movdqu xmm1, xmm15


	;**===========**
	;**|PARA XMM2|**
	;**===========**
		;===============
		;CONSEGUIMOS V1:
		;===============
		movdqu xmm10, xmm2
		movdqu xmm11, xmm7
		mov r9d, 128
		mov r8d, 128
		convertirYUV		
		;tomo los valores obtenidos y los pego en xmm0:
		insertps xmm15, xmm2, 00000000b
		insertps xmm15, xmm9, 11010000b
	
		;===============
		;CONSEGUIMOS U1:
		;===============
		movdqu xmm10, xmm2
		movdqu xmm11, xmm6
		mov r8d, 128
		mov r9d, 128
		convertirYUV
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11100000b
	
		;===============
		;CONSEGUIMOS Y1:
		;===============
		movdqu xmm10, xmm2
		movdqu xmm11, xmm5
		mov r8d, 128
		mov r9d, 16
		convertirYUV
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11110000b

		;devuelvo todo a xmm2:
		movdqu xmm2, xmm15

	;**===========**
	;**|PARA XMM3|**
	;**===========**
		;===============
		;CONSEGUIMOS V2:
		;===============
		movdqu xmm10, xmm3
		movdqu xmm11, xmm7
		mov r8d, 128
		mov r9d, 128
		convertirYUV		
		;tomo los valores obtenidos y los pego en xmm0:
		insertps xmm15, xmm3, 00000000b
		insertps xmm15, xmm9, 11010000b
	
		;===============
		;CONSEGUIMOS U2:
		;===============
		movdqu xmm10, xmm3
		movdqu xmm11, xmm6
		mov r8d, 128
		mov r9d, 128
		convertirYUV
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11100000b
	
		;===============
		;CONSEGUIMOS Y2:
		;===============
		movdqu xmm10, xmm3
		movdqu xmm11, xmm5
		mov r8d, 128
		mov r9d, 16
		convertirYUV	
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11110000b

		;devuelvo todo a xmm3:
		movdqu xmm3, xmm15

	;**===========**
	;**|PARA XMM4|**
	;**===========**
		;===============
		;CONSEGUIMOS V3:
		;===============
		movdqu xmm10, xmm4
		movdqu xmm11, xmm7
		mov r8d, 128
		mov r9d, 128
		convertirYUV
		;tomo los valores obtenidos y los pego en xmm0:
		insertps xmm15, xmm4, 00000000b
		insertps xmm15, xmm9, 11010000b
	
		;===============
		;CONSEGUIMOS U3:
		;===============
		movdqu xmm10, xmm4
		movdqu xmm11, xmm6
		mov r8d, 128
		mov r9d, 128
		convertirYUV	
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11100000b
	
		;===============
		;CONSEGUIMOS Y3:
		;===============
		movdqu xmm10, xmm4
		movdqu xmm11, xmm5
		mov r8d, 128
		mov r9d, 16
		convertirYUV	
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 11110000b

		;devuelvo todo a xmm4:
		movdqu xmm4, xmm15

		;=====================
		;SATURO Y REEMPAQUETO:
		;=====================

		;reempaqueto lo obtenido:
		packssdw xmm1, xmm2
		packssdw xmm3, xmm4

		packuswb xmm1, xmm3


		;===============
		;lo pego en dst:
		;===============
		movdqu [r15], xmm1



	;ya procese 16 componentes de pixel mas:
	sub r12, 16
	cmp r12, 0
	je .fin
	;avanzo en la imagen src y dst:
	lea rbx, [rbx + 16]
	lea r15, [r15 + 16]
	jmp .avanzar

	.fin:

	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
ret