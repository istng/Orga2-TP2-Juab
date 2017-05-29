global ASM_convertYUVtoRGB_phaddd
global ASM_convertRGBtoYUV_phaddd
extern C_convertYUVtoRGB_defines
extern C_convertRGBtoYUV_defines

ASM_convertYUVtoRGB_phaddd:
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
	xorps xmm7, xmm7
	xor r9, r9
	mov r9, 516
	pinsrd xmm7, r9d, 2
	mov r9, 298
	pinsrd xmm7, r9d, 3
	;xmm7 = 0|0|516|298

	;preparo U:
	xorps xmm6, xmm6
	xor r9, r9
	mov r9d, -208
	pinsrd xmm6, r9d, 1
	mov r9d, -100
	pinsrd xmm6, r9d, 2
	mov r9d, 298
	pinsrd xmm6, r9d, 3
	;xmm6 = 0|-208|-100|298

	;preparo Y:
	xorps xmm5, xmm5
	xor r9, r9
	mov r9d, 409
	pinsrd xmm5, r9d, 1
	mov r9d, 298
	pinsrd xmm5, r9d, 3
	;xmm5 = 1|25|129|66

	;preparo el sumador:
	xorps xmm12, xmm12
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
		call .convertirRGB
		;tomo los valores obtenidos y los pego en xmm15:
		insertps xmm15, xmm1, 00000000b
		insertps xmm15, xmm9, 00010000b
	
		;===============
		;CONSEGUIMOS G0:
		;===============
		movdqu xmm10, xmm1
		movdqu xmm11, xmm6
		call .convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00100000b
	
		;===============
		;CONSEGUIMOS R0:
		;===============
		movdqu xmm10, xmm1
		movdqu xmm11, xmm5
		call .convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00110000b
	
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
		call .convertirRGB
		;tomo los valores obtenidos y los pego en xmm0:
		insertps xmm15, xmm2, 00000000b
		insertps xmm15, xmm9, 00010000b
	
		;===============
		;CONSEGUIMOS G1:
		;===============
		movdqu xmm10, xmm2
		movdqu xmm11, xmm6
		call .convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00100000b
	
		;===============
		;CONSEGUIMOS R1:
		;===============
		movdqu xmm10, xmm2
		movdqu xmm11, xmm5
		call .convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00110000b

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
		call .convertirRGB
		;tomo los valores obtenidos y los pego en xmm0:
		insertps xmm15, xmm3, 00000000b
		insertps xmm15, xmm9, 00010000b
	
		;===============
		;CONSEGUIMOS G2:
		;===============
		movdqu xmm10, xmm3
		movdqu xmm11, xmm6
		call .convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00100000b
	
		;===============
		;CONSEGUIMOS R2:
		;===============
		movdqu xmm10, xmm3
		movdqu xmm11, xmm5
		call .convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00110000b

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
		call .convertirRGB
		;tomo los valores obtenidos y los pego en xmm0:
		insertps xmm15, xmm4, 00000000b
		insertps xmm15, xmm9, 00010000b
	
		;===============
		;CONSEGUIMOS G3:
		;===============
		movdqu xmm10, xmm4
		movdqu xmm11, xmm6
		call .convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00100000b
	
		;===============
		;CONSEGUIMOS R3:
		;===============
		movdqu xmm10, xmm4
		movdqu xmm11, xmm5
		call .convertirRGB
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00110000b

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

.convertirRGB:
	;XMM10-> valores ABGR en 32 vits, XMM11->constantes para YUV c1,c2,c3
	;R8D->constante de suma interna (antes del shift), R9D->constante de suma final
	movdqu xmm9, xmm10;		xmm9 = a|v|u|y
	psubd xmm9, xmm12;		xmm9 = a-0|v-128|u-128|y-16 (los renombro por si mismos: v=v-128...)
	pmulld xmm9, xmm11;		xmm9= a*0|v*c1|u*c2|y*c3
	xorps xmm8, xmm8
	phaddd xmm9, xmm8;		xmm9 = 0+v*c1|u*c2+y*c3|0|0
	phaddd xmm9, xmm8;		xmm9 = v*c1+u*c2+y*c3|0|0|0
	mov r8, 128
	pinsrd xmm8, r8d, 0
	paddd xmm9, xmm8;		xmm9 = v*c1+u*c2+y*c3+128|0|0|0
	psrad xmm9, 8;			xmm9 = xmm9 >> 8
ret


ASM_convertRGBtoYUV_phaddd:
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
	xorps xmm7, xmm7
	xor r9, r9
	mov r9, -18
	pinsrd xmm7, r9d, 1
	mov r9, -94
	pinsrd xmm7, r9d, 2
	mov r9, 112
	pinsrd xmm7, r9d, 3
	;xmm7 = 1|-18|-94|112

	;preparo U:
	xorps xmm6, xmm6
	xor r9, r9
	mov r9d, 112
	pinsrd xmm6, r9d, 1
	mov r9d, -74
	pinsrd xmm6, r9d, 2
	mov r9d, -38
	pinsrd xmm6, r9d, 3
	;xmm6 = 1|112|-74|-38

	;preparo Y:
	xorps xmm5, xmm5
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
		call .convertirYUV
		;tomo los valores obtenidos y los pego en xmm15:
		insertps xmm15, xmm1, 00000000b
		insertps xmm15, xmm9, 00010000b
	
		;===============
		;CONSEGUIMOS U0:
		;===============
		movdqu xmm10, xmm1
		movdqu xmm11, xmm6
		mov r8d, 128
		mov r9d, 128
		call .convertirYUV
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00100000b
	
		;===============
		;CONSEGUIMOS Y0:
		;===============
		movdqu xmm10, xmm1
		movdqu xmm11, xmm5
		mov r8d, 128
		mov r9d, 16
		call .convertirYUV
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00110000b
	
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
		call .convertirYUV		
		;tomo los valores obtenidos y los pego en xmm0:
		insertps xmm15, xmm2, 00000000b
		insertps xmm15, xmm9, 00010000b
	
		;===============
		;CONSEGUIMOS U1:
		;===============
		movdqu xmm10, xmm2
		movdqu xmm11, xmm6
		mov r8d, 128
		mov r9d, 128
		call .convertirYUV
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00100000b
	
		;===============
		;CONSEGUIMOS Y1:
		;===============
		movdqu xmm10, xmm2
		movdqu xmm11, xmm5
		mov r8d, 128
		mov r9d, 16
		call .convertirYUV
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00110000b

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
		call .convertirYUV		
		;tomo los valores obtenidos y los pego en xmm0:
		insertps xmm15, xmm3, 00000000b
		insertps xmm15, xmm9, 00010000b
	
		;===============
		;CONSEGUIMOS U2:
		;===============
		movdqu xmm10, xmm3
		movdqu xmm11, xmm6
		mov r8d, 128
		mov r9d, 128
		call .convertirYUV
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00100000b
	
		;===============
		;CONSEGUIMOS Y2:
		;===============
		movdqu xmm10, xmm3
		movdqu xmm11, xmm5
		mov r8d, 128
		mov r9d, 16
		call .convertirYUV	
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00110000b

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
		call .convertirYUV
		;tomo los valores obtenidos y los pego en xmm0:
		insertps xmm15, xmm4, 00000000b
		insertps xmm15, xmm9, 00010000b
	
		;===============
		;CONSEGUIMOS U3:
		;===============
		movdqu xmm10, xmm4
		movdqu xmm11, xmm6
		mov r8d, 128
		mov r9d, 128
		call .convertirYUV	
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00100000b
	
		;===============
		;CONSEGUIMOS Y3:
		;===============
		movdqu xmm10, xmm4
		movdqu xmm11, xmm5
		mov r8d, 128
		mov r9d, 16
		call .convertirYUV	
		;tomo el valor obtenido y lo pego en xmm15:
		insertps xmm15, xmm9, 00110000b

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

.convertirYUV:
	;XMM10-> valores ABGR en 32 bits, XMM11->constantes para YUV c1,c2,c3
	;R8D->constante de suma interna (antes del shift), R9D->constante de suma final
	movdqu xmm9, xmm10;		xmm9 = a|b|g|r
	pmulld xmm9, xmm11;		xmm9 = 0*a|c1*b|c2*g|c3*r
	xorps xmm8, xmm8
	phaddd xmm9, xmm8;		xmm9 = 0+c1*b|c2*g+c3*r|0|0
	phaddd xmm9, xmm8;		xmm9 = c1*b+c2*g+c3*r|0|0|0
	pinsrd xmm8, r8d, 0
	paddd xmm9, xmm8;		xmm9 = c1*b+c2*g+c3*r+r8d|0|0|0
	psrad xmm9, 8;			xmm9 = xmm9 >> 8
	pinsrd xmm8, r9d, 0
	paddd xmm9, xmm8;		xmm9 = casiYUV+r9d|??|??|??
ret