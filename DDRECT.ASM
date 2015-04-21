cseg		segment	public 'code'

assume		cs: cseg, ds: dseg

public		draw_rect, undraw_rect, rect_offscrn

include		ddeqfile

draw_rectega:
;put a black block onto the screen and buffer the background
	push	ds
	push	es
	mov	ax,seg rect_x
	mov	ds,ax
	mov	es,ax
		mov	si, offset rect_x	; assume initial values for
		mov	di, offset bled_rect_x	; bled coords and sizes
		movsw
		movsw
		movsw
		movsw
		mov	di, offset rect_save_area
	mov	bx,rect_x
	cmp	bx,60
	ja	offscr
	add	bx,6
	js	offscr
;my simple left and right checking !
	shr	bx,1	;no shift or silly things like that !
	
	mov	cx,rect_y
	cmp	cx,160	;if below bottom offscreen !
	jge	offscr	;changed from ae ?to take care of sign ?
	add	cx,rect_rows	;bottom of thing where is it
	cmp	cx,0
	jl	offscr
	jmp	ok1
offscr:
	pop	es
	pop	ds
	mov	rect_bkgd_ptr,48000	;dummy OFFSCREEN value !
	jmp	rect_offscrn
	ret
ok1:
	mov	bx,rect_x
	shr	bx,1
	mov	ax,rect_y
	shl	ax,1
	shl	ax,1
	mov	cx,ax	;*36 =*32+*4
	shl	ax,1	;*8
	shl	ax,1	;*16
	shl	ax,1	;*32
	add	ax,cx	;ax=y*36
	add	ax,bx
;now rect_cols/2 wide rect_rows downwards !

	mov	bp,rect_rows
	mov	si, window_topleft
	sub	si,offset dummy_scrn	
	shr	si,1
	add	si,ax	;scrn top_left + posn of object
	and	si,8191
	mov	rect_bkgd_ptr,si
	mov	ax,seg rect_save_area
	mov	es,ax
	mov	di,offset rect_save_area
	mov	dx,rect_cols
	shr	dx,1
	jnz	no_rt
	pop	es
	pop	ds
	mov	rect_bkgd_ptr,48000
	ret
no_rt:
	mov	rbw_rect,dx
	mov	raw_rect,bp
	lds	bx,dum_ptr
sqloop:
	push	si
	mov	cx,dx	;reload rect cols
bloop:
	mov	al,[si]
	mov	ah,[si+8192]
	stosw	;buffer
	mov	al,[si+16384]
	mov	ah,[si+24576]
	stosw	;buffer
	mov	byte ptr [si],0	;black !
	mov	byte ptr [si+8192],0	;black !
	mov	byte ptr [si+16384],0	;black !
	mov	byte ptr [si+24576],0	;black !
	inc	si
	and	si,8191
	loop	bloop

	pop	si
	add	si,36
	and	si,8191
	dec	bp
	jge	sqloop
	pop	es
	pop	ds
	ret

	ret

draw_recttan:
;put a black block onto the screen and buffer the background
	push	ds
	push	es
		mov	si, offset rect_x	; assume initial values for
		mov	di, offset bled_rect_x	; bled coords and sizes
		movsw
		movsw
		movsw
		movsw
		mov	di, offset rect_save_area
	mov	bx,rect_x
	cmp	bx,60
	ja	offscrt
	add	bx,6
	js	offscrt
;my simple left and right checking !
	shr	bx,1	;no shift or silly things like that !
	
	mov	cx,rect_y
	cmp	cx,160	;if below bottom offscreen !
	jge	offscrt
	add	cx,rect_rows	;bottom of thing where is it
	cmp	cx,0
	jl	offscrt
	jmp	ok2
offscrt:
	pop	es
	pop	ds
	mov	rect_bkgd_ptr,48000	;dummy OFFSCREEN value !
	jmp	rect_offscrn
	ret
ok2:
	mov	bx,rect_x
	add	bx,bx	;*2 !
	mov	ax,rect_y
	shl	ax,1
	shl	ax,1
	mov	cx,ax	;*36 =*32+*4
	shl	ax,1	;*8
	shl	ax,1	;*16
	shl	ax,1	;*32
	add	ax,cx	;ax=y*36
	shl	ax,1
	shl	ax,1	;*144
	add	ax,bx	;offset within screen
;now rect_cols/2 wide rect_rows downwards !
	mov	bp,rect_rows
	mov	si, window_topleft
	sub	si,offset dummy_scrn	
	add	si,si
	add	si,ax	;scrn top_left + posn of object
	and	si,32767	;always an even address folks !
	mov	rect_bkgd_ptr,si
	mov	ax,seg rect_save_area
	mov	es,ax
	mov	di,offset rect_save_area
	mov	dx,rect_cols
;add	dx,dx	;*2 from cga to Tandy Nibbles !
	or	dx,dx
	jnz	no_rt2
	pop	es
	pop	ds
	mov	rect_bkgd_ptr,48000
	ret
no_rt2:
	mov	rbw_rect,dx
	mov	raw_rect,bp
	lds	bx,dum_ptr
sqloopt:
	push	si
	mov	cx,dx	;reload rect cols
bloopt:
	movsw		;buffer the screen
	mov	word ptr [si-2],0	;put the black
	and	si,32767	;or 6?
	loop	bloopt
	pop	si
	add	si,144
	and	si,32767
	dec	bp
	jge	sqloopt
	pop	es
	pop	ds
	ret

draw_rect:	
	mov	ax,seg rect_x
	mov	ds,ax
	mov	es,ax
		cmp	[sixteencol],1
		jne	ndr_rect
		jmp	draw_recttan
ndr_rect:
		cmp	[sixteencol],2
		jne	ndr_rect2
		jmp	draw_rectega
ndr_rect2:
		cmp	[sixteencol],3
		jne	ndr_rect3
		jmp	draw_rectega
ndr_rect3:
		call	setup_rect
		mov	dx, rbw_rect
		call	rect_main		; draw main part before wrap
		mov	cx, cbw_rect
		call	rect_wrap		; draw wrap-line part 1
		sub	si, 9600		; wraparound in dummy scrn
		mov	cx, caw_rect
		call	rect_wrap		; draw wrap-line part 2
		mov	ax, cbw_rect		; if wrap-line has been drawn
		or	ax, caw_rect		; then update bkgd ptr
		jz	over_dr
		sub	si, bled_rect_cols
		add	si, 60
over_dr:	mov	dx, raw_rect
		call	rect_main		; draw main part after wrap
		ret

rect_wrap:	jcxz	exit_rw
next_byte_rw:	xor	al, al
		xchg	al, [si]
		inc	si
		stosb
		loop	next_byte_rw
exit_rw:	ret

rect_main:	and	dx, dx
 		jz	exit_rm
next_row_rm:	mov	cx, bled_rect_cols
next_col_rm:	xor	al, al
		xchg	[si], al
		inc	si
		stosb
		loop	next_col_rm
		sub	si, bled_rect_cols
		add	si, 60
		dec	dx
		jnz	next_row_rm
exit_rm:	ret

undraw_rectega:
;take a block of data from the buffer and put to the dummy screen
	mov	di,rect_bkgd_ptr	;dummy OFFSCREEN value !
	cmp	di,48000
	jne	no_ret_ele
squit:
	jmp	rect_offscrn
	ret
no_ret_ele:
;mov	bp,bled_rect_rows
;add	bp,bp
	mov	bp,raw_rect
	mov	dx,rbw_rect	;bled_rect_cols
;shr	dx,1
	or	dx,dx
	jz	squit
	push	ds
	push	es
	les	bx,dum_ptr
	mov	ax,seg rect_save_area
	mov	ds,ax
	mov	si,offset rect_save_area
	and	di,8191	;in case a crap value has slipped thru'
ublll:	push	di
	mov	cx,dx
ubloop:	lodsw
	mov	es:[di],al
	mov	es:[di+8192],ah
	lodsw
	mov	es:[di+16384],al
	mov	es:[di+24576],ah
	inc	di
	and	di,8191
	loop	ubloop
	pop	di
	add	di,36
	and	di,8191
	dec	bp
	jge	ublll
	pop	es
	pop	ds
	ret

undraw_recttan:
;take a block of data from the buffer and put to the dummy screen
	mov	di,rect_bkgd_ptr	;dummy OFFSCREEN value !
	cmp	di,48000
	jne	no_ret_elez
squitz:
	jmp	rect_offscrn
	ret
no_ret_elez:
	mov	bp,raw_rect
	mov	dx,rbw_rect	;bled_rect_cols
	or	dx,dx
	jz	squitz
	push	ds
	push	es
	les	bx,dum_ptr
	mov	ax,seg rect_save_area
	mov	ds,ax
	mov	si,offset rect_save_area
	and	di,32767	;in case a crap value has slipped thru'
ublllt:	push	di
	mov	cx,dx
ubloopt:	
	movsw	;buffer a row ?
	and	di,32767
	loop	ubloopt
	pop	di
	add	di,144
	and	di,32767
	dec	bp
	jge	ublllt
	pop	es
	pop	ds
	ret

undraw_rect:	
	mov	ax,seg rect_x
	mov	ds,ax
	mov	es,ax
		cmp	[sixteencol],1
		jne	undr_rect
		jmp	undraw_recttan
undr_rect:
		cmp	[sixteencol],2
		jne	undr_rect2
		jmp	undraw_rectega
undr_rect2:
		cmp	[sixteencol],3
		jne	undr_rect3
		jmp	undraw_rectega
undr_rect3:
		mov	si, offset rect_save_area
		mov	di, rect_bkgd_ptr
		mov	dx, rbw_rect
		call	unrect_main		; undraw main part before wrap
		mov	cx, cbw_rect
		rep	movsb			; undraw wrap-line part 1
		sub	di, 9600		; wraparound in dummy scrn
		mov	cx, caw_rect
		rep	movsb			; undraw wrap-line part 2
		mov	ax, cbw_rect		; if wrap-line has been drawn
		or	ax, caw_rect		; then update bkgd ptr
		jz	over_ur
		sub	di, bled_rect_cols
		add	di, 60
over_ur:	mov	dx, raw_rect
		call	unrect_main		; undraw main part after wrap
exit_ur:	ret

unrect_main:	and	dx, dx
 		jz	exit_um
next_row_um:	mov	cx, bled_rect_cols
		rep	movsb
		sub	di, bled_rect_cols
		add	di, 60
		dec	dx
		jnz	next_row_um
exit_um:	ret

setup_rect:
		mov	si, offset rect_x	; assume initial values for
		mov	di, offset bled_rect_x	; bled coords and sizes
		movsw
		movsw
		movsw
		movsw
		mov	si, window_topleft
		mov	di, offset rect_save_area

test_above:	mov	ax, rect_y
		cmp	ax, 0			; all or part above scrn ?
		jge	over_sr2		; - no
		add	bled_rect_rows, ax	; - yes
		jg	over_sr1		; all above scrn ?
		jmp	rect_offscrn		; - yes
over_sr1:	mov	bled_rect_y, 0		; - no, bled rect at scrn top
		neg	ax
		mul	rect_cols
		shl	ax, 1
		jmp	test_left
over_sr2:	mov	dh, al
		xor	dl, dl
		shr	dx, 1
		shr	dx, 1
		shl	ax, 1
		shl	ax, 1
		add	si, dx			; top onscrn, update bkgd ptr
		sub	si, ax

test_below:	mov	ax, 160
		sub	ax, rect_y		; all below scrn ?
		jg	over_sr3		; - no
		jmp	rect_offscrn		; - yes
over_sr3:	cmp	ax, rect_rows		; part below scrn ?
		jge	test_left		; - no
		mov	bled_rect_rows, ax	; - yes
test_left:	mov	ax, rect_x
		cmp	ax, 0			; all or part left of scrn ?
		jge	over_sr5		; - no
		add	bled_rect_cols, ax	; - yes
		jg	over_sr4		; all left of scrn ?
		jmp	rect_offscrn		; - yes
over_sr4:	mov	bled_rect_x, 0		; - no, bled rect at scrn left
		shl	ax, 1
		jmp	ptrs_bled
over_sr5:	add	si, ax			; left onscrn, update bkgd ptr
test_right:	mov	ax, 60
		sub	ax, rect_x		; all right of scrn ?
		jg	over_sr6		; - no
		jmp	rect_offscrn		; - yes
over_sr6:	cmp	ax, rect_cols		; part right of scrn ?
		jge	ptrs_bled		; - no
		mov	bled_rect_cols, ax		; - yes
ptrs_bled:	mov	rect_bkgd_ptr, si	; store, for undrawing
		mov	ax, 60			; eval cols before wrap
		sub	ax, window_left
		sub	ax, bled_rect_x
		jge	over_sr7
		xor	ax, ax
over_sr7:	cmp	ax, bled_rect_cols
		jle	over_sr8
		mov	ax, bled_rect_cols
over_sr8:	mov	cbw_rect, ax
		neg	ax			; eval cols atfer wrap
		add	ax, bled_rect_cols
		mov	caw_rect, ax
		mov	ax, 159			; eval rows before wrap
		sub	ax, window_top
		sub	ax, bled_rect_y
		jge	over_sr9
		xor	ax, ax
over_sr9:	cmp	ax, bled_rect_rows
		jl	over_sr10
		mov	ax, bled_rect_rows
		mov	cbw_rect, 0		; if whole rect is one main
		mov	caw_rect, 0		; part then no wrap-line
over_sr10:	mov	rbw_rect, ax
		mov	ax, window_top		; eval rows after wrap
		add	ax, bled_rect_y
		add	ax, bled_rect_rows
		sub	ax, 160
		jge	over_sr11
		xor	ax, ax
over_sr11:	cmp	ax, bled_rect_rows
		jl	over_sr12
		mov	ax, bled_rect_rows
		mov	cbw_rect, 0		; if whole rect is one main
		mov	caw_rect, 0		; part then no wrap-line
over_sr12:	mov	raw_rect, ax
		ret

rect_offscrn:
		mov	ax,seg dseg
		mov	ds,ax
		xor	ax, ax
		mov	bled_rect_rows, 0
		mov	rbw_rect, ax
		mov	raw_rect, ax
		mov	cbw_rect, ax
		mov	caw_rect, ax
		ret

cseg		ends

dseg		segment	public 'data'
public		rect_x, rect_y, rect_cols, rect_rows
extrn		window_topleft:word, window_top:word, window_left:word
extrn		sixteencol:byte
extrn		dum_ptr:dword,dummy_scrn:word

rect_x		dw	?
rect_y		dw	?
rect_cols	dw	0
rect_rows	dw	74

bled_rect_x	dw	?
bled_rect_y	dw	?
bled_rect_cols	dw	?
bled_rect_rows	dw	?
cbw_rect	dw	?
caw_rect	dw	?
rbw_rect	dw	?
raw_rect	dw	?
rect_bkgd_ptr	dw	?

res_mem		rect_save_area,4096,2048

dseg		ends

end
