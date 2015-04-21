
cseg	segment	public	'code'


assume	cs:cseg,ds:dseg

d_scrn_w	equ	36

;undrawing for the ega card (at least)
;may as well waste lots of memory in order to save appr 18%+

delabyte	macro
		lodsw			;12
		mov	ES:[di],ah		;10
		mov	ES:[di+8192],al	;10
		lodsw			;12
		mov	ES:[di+16384],ah	;10
		mov	ES:[di+24576],al	;10
		inc	di		;2
		and	di,8191		;4	=70
		endm
delabyteb	macro
		lodsw			;12
		mov	ES:[di],ah		;10
		mov	ES:[di+8192],al	;10
		lodsw			;12
		mov	ES:[di+16384],ah	;10
		mov	ES:[di+24576],al	;10
		endm

;delaword	macro
;		lodsw			;12
;		mov	bx,ax		;2
;		lodsw			;12
;		mov	cx,ax		;2
;		lodsw			;12
;		mov	dx,ax		;2
;		lodsw			;12
;
;	xchg	bh,dh		;3
;	xchg	ah,ch		;3
;
;	mov	es:[di],bx		;17 ?
;	mov	es:[di+8192],cx		;17 ?
;	mov	es:[di+16384],dx	;17 ?
;	mov	es:[di+24576],ax	;10
;
;	add	di,2			;4
;	and	di,8191			;4
;
;	endm



delncols macro colums
local	start
start:

;rept	colums/2
;delaword
;endm
;if	(colums and 1) eq 1
;delabyeb
;endif
		rept	colums-1
		delabyte
		endm
		delabyteb

		sub	di,colums-d_scrn_w-1
		and	di,8191
		loop	start
		jmp	finoff
		endm
;for when the loop has to be indirect ?

delncolsl macro colums
local	start,lokal,lblx,lpb
start:
	push	dx
	mov	dx,cx
lpb:
	mov	cx,colums-1
lblx:
	delabyte
	loop	lblx
	delabyteb
	sub	di,colums-d_scrn_w-1
	and	di,8191
	dec	dx
	jnz	lokal
	pop	dx
	jmp	finoff
lokal:	jmp	lpb

	endm


finoff:
		mov	ax,seg dseg
		mov	ds,ax
		pop	es
		ret

d1col:
stx:		delabyteb
		sub	di,d_scrn_w
		and	di,8191
		loop	stx
		jmp	finoff

d2col:	delncols	2
d3col:	delncols	3
d4col:	delncols	4
d5col:	delncolsl	5
d6col:	delncolsl	6
d7col:	delncolsl	7
d8col:	delncolsl	8
d9col:	delncolsl	9
d10col:	delncolsl	10
d11col:	delncolsl	11
d12col:	delncolsl	12
d13col:	delncolsl	13
d14col:	delncolsl	14
d15col:	delncolsl	15
d16col:	delncolsl	16
d17col:	delncolsl	17
d18col:	delncolsl	18
d19col:	delncolsl	19



cseg	ends

dseg	segment	public	'data'
public	deljmptab

deljmptab	label	word
	dw	offset finoff	;for del 0 cols
	dw	offset d1col,offset d2col,offset d3col,offset d4col
	dw	offset d5col,offset d6col,offset d7col,offset d8col
	dw	offset d9col,offset d10col,offset d11col,offset d12col
	dw	offset d13col,offset d14col,offset d15col,offset d16col
	dw	offset d17col,offset d18col,offset d19col
	dw	offset finoff	;for del 0 cols
	dw	offset finoff	;for del 0 cols
	dw	offset finoff	;for del 0 cols

;hopefully no more than 20 will be needed ?	

dseg	ends

	end

