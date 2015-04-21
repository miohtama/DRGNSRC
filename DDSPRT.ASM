
cseg		segment	public 'code'

public		draw_sprt, undraw_sprt,undraw_cont,draw_cont
public		mk_mask,mk_flipc

extrn		enter_chunk: near, stack_base: word

assume		cs: cseg, ds: dseg

include		ddeqfile	;for left !

mk_mask:
	push	ds
	push	es

	mov	ax,seg msk_tab
	mov	ds,ax
	mov	es,ax

	mov	bx,offset msk_tab

	mov	cl,0
msk_lp:
	mov	al,cl
	xor	al,01010101b	;make a cyan 00
	mov	ah,al
	and	al,10101010b
	and	ah,01010101b
	mov	dx,ax	;copy this half
	shr	al,1
	shl	ah,1
	or	ax,dx	;or in the stuff
	or	al,ah	;now the other set ones
;not	al
	mov	ds:[bx],al	;put the data in
	inc	bx

	inc	cl
	cmp	cl,0
	jne	msk_lp

	pop	es
	pop	ds
	ret


mk_flipc:
	push	es
	push	ds

;
;	make the cga flip table
;
	mov	ax,seg flp_tab
	mov	ds,ax
	mov	es,ax
	mov	di,offset flp_tab

	mov	ch,0	;counter
fl_lp:
	mov	al,ch
	mov	ah,ch
	mov	bx,ax
	
	and	al,3
	and	ah,3*4
	and	bl,3*16
	and	bh,3*64

	mov	cl,6
	shr	bh,cl	; move 6 places right 
	shr	bl,1
	shr	bl,1	; move 2 places right
	shl	ah,1
	shl	ah,1	; move 2 places left
	shl	al,cl	; move 6 places left
	and	al,3*64
	and	ah,3*16
	and	bl,3*4
	and	bh,3

	or	ax,bx
	or	al,ah
	mov	[di],al
	inc	di
	inc	ch
	cmp	ch,0
	jne	fl_lp

	pop	ds
	pop	es
	ret


flip_spr:
	push	es
;push	bp
	push	si
	push	cx
	push	dx
	push	di
	push	bx
	push	ds

	mov	cx,sprt_cols
	mov	dx,sprt_rows
	mov	si,bp	;assume these have been set up !

	mov	ax,ss_save
	mov	es,ax	;ds is the sprite data dippo !
	mov	ax,seg new_spr
	mov	ds,ax	;in data segment

	mov	di,offset new_spr	;4k for the sprite ?
	mov	bx,offset flp_tab	;try this one !
	mov	spr_rows,dx
	mov	bp,cx
;shl	bp,1	;this IS REDICULOUS !!
	inc	cx
	shr	cx,1	; divide by two for this loop
row_lp:
	add	di,bp	;move to right of this row ?!
	push	cx
byte_lp:	; christ is it okay to lodsw ???
	sub	di,2
	mov	ax,es:[si]
	add	si,2	;crikey are all sprites even bytes wides
	xlat
	xchg	al,ah
	xlat
	mov	[di],ax
	loop	byte_lp		;hmmm can I extend this loop a bit
	pop	cx
	add	di,bp
	dec	spr_rows
	jne	row_lp
	pop	ds
	mov	ax,seg new_spr
	mov	ss_save,ax
	mov	si,offset new_spr	;
	mov	bp,si			;bp is at the moment the data_ptr
;mov	sp_save,si	;?doubt it but might as well try ?
	pop	bx
	pop	di
	pop	dx
	pop	cx
;pop	bp
	pop	si
	pop	es
	ret



draw_w		macro	disp
	mov	ax,[di+disp]
	mov	es:[si+disp],ax
	mov	dx,ax
	mov	ax,ss:[bp]
;mov	ax,1010101101010100b	; red then cyan
;xchg	al,ah	;try swapping here !
	add	bp,2
	mov	cx,ax
	xlat
	xchg	al,ah
	xlat
	xchg	al,ah	;ax=mask cx=data dx=screen
	and	cx,ax	;mask out cyan from data (forgot about that !)
	not	ax
	and	ax,dx
	or	ax,cx
	mov	[di+disp],ax

	endm


draw_b		macro	disp
	mov	al, [di+disp]
	mov	es:[si+disp], al
	mov	dl, al
	mov	ah,ss:[bp]
	inc	bp
	mov	al,ah
	xlat
	and	ah,al
	not	al
	and	al,dl
	or	al,ah
	mov	[di+disp],al
		endm


draw_ptrs	macro
		add	bp, skip_words	;MUST FIX SKIP WORDS !
		add	di, 60
		add	si, bled_cols	;must fix this annall!
		endm


draw_sprt:
		JMP	WORD PTR [JUMPTAB+2]
draw_cont:
	push	ds
		mov	di, offset sprt_x
		movsw
		movsw
		movsw
		movsw
		movsw
		movsw
		movsw
		push	si
;mov	si,person_on	;my setup doesnt use si
;mov	al,byte ptr [si+4]
;mov	al,0	;face only one direction
;mov	ddd,al
		call	setup_sprt
		push	es
		mov	ax, buff_seg
		mov	es, ax
		mov	cx, rows_b4_wrap
		call	draw_main		; draw main part before wrap
		mov	cx, cols_b4_wrap
		call	draw_wrap		; draw wrap-line part 1
		sub	di, 9600		; wraparound in dummy scrn
		mov	cx, cols_aftr_wrap
		call	draw_wrap		; draw wrap-line part 2
		mov	ax, cols_b4_wrap	; if wrap-line has been drawn
		or	ax, cols_aftr_wrap	; then update ptrs, ignoring
		jz	over_ds			; save ptr
		sub	di,bled_cols
		add	di,60
		mov	ax,skip_words
		add	sp_save, ax
over_ds:	mov	cx, rows_aftr_wrap
		call	draw_main		; draw main part after wrap
		pop	es
		pop	di
		mov	si, offset bled_x
	pop	ds
		movsw
		movsw
		movsw
		movsw
		movsw
		movsw
		movsw
		movsw
		movsw
exit_ds:	ret


draw_wrap:
		jcxz	exit_dw
		cli
		mov	ax, ss
		xchg	ax, ss_save
		mov	ss, ax
		xchg	sp, sp_save
	xchg	bp,sp	;oh christ oh christ
next_byte_dw:	
	mov	al,[di]
	mov	es:[si],al
	mov	dl,al
	mov	al,ss:[bp]
	inc	bp
	mov	ah,al
	xlat	;make the mask
	and	ah,al	;get rid of cyan
	not	al
	and	al,dl
	or	al,ah
	mov	ds:[di],al
	inc	di
	inc	si
	loop	next_byte_dw
	xchg	bp,sp	;hmmm city !!
		mov	ax, ss
		xchg	ax, ss_save
		mov	ss, ax
		xchg	sp, sp_save
		sti
exit_dw:	ret




draw_main:
		jcxz	exit_dm
		mov	bp, bled_cols
		shl	bp, 1
		add	bp, offset draw_jump_tabl - 2
		mov	dx, cs: [bp]		; index into jump table
		cli
		mov	ax, ss
		xchg	ax, ss_save
		mov	ss, ax
		xchg	sp, sp_save
	xchg	bp,sp	;make bp be the sprite pointer
	mov	loop_var,cx	;set up here !
		jmp	dx
restore_stack:	
	xchg	bp,sp	;forgot !
		xchg	sp, sp_save
		mov	ax, ss
		xchg	ax, ss_save
		mov	ss, ax
		sti
exit_dm:	ret




undraw_sprt:
		JMP	WORD PTR [JUMPTAB]
undraw_cont:

		mov	di, offset sprt_cols
		add	si, 4
		mov	cx, 14
		rep	movsw

		push	ds
		mov	ax, buff_seg
		mov	ds, ax
	mov	ax,seg save_ptr
	mov	es,ax		;check the set up
		mov	si, es:save_ptr
		mov	di, es:bled_bkgd_ptr
		mov	cx, es:rows_b4_wrap
		call	undraw_main		; undraw main part before wrap
		mov	cx, es:cols_b4_wrap
		rep	movsb			; undraw wrap-line part 1
		sub	di, 9600		; wraparound in dummy scrn
		mov	cx, es:cols_aftr_wrap
		rep	movsb			; undraw wrap-line part 2
		mov	ax, es:cols_b4_wrap	; if wrap-line has been drawn
		or	ax, es:cols_aftr_wrap	; then update bkgd ptr
		jz	over_us
		mov	ax, es:bled_cols
		sub	di, ax
		add	di, 60
over_us:	mov	cx, es:rows_aftr_wrap
		call	undraw_main		; undraw main part after wrap
		pop	ds
exit_us:	ret




undraw_main:
		jcxz	exit_um
		mov	bx, es:bled_cols
		shl	bx, 1
		add	bx, offset undw_jump_tabl - 2
		mov	ax, cs: [bx]		; index into jump table
		mov	dx, 60
		sub	dx, es:bled_cols
		jmp	ax
exit_um:	ret




setup_sprt:
		mov	si, offset sprt_x	; assume initial values for
		movsw				; bled coords, sizes and
		movsw				; data ptrs
		movsw
		movsw

	test	flip_dir,left
	jz	not_left_face
	mov	al,spr_l_offs		;[bx+6]	;offset of sprt
	cbw			; -ve 
	shl	ax,1
	sub	sprt_x,ax	;lose last one

;add	ax,sprt_cols	;making new offset
;neg	ax	;want new -ve offset
;sar	ax,1	;good grief
	mov	ax,sprt_cols
;shr	ax,1
	sub	sprt_x,ax	;christ
not_left_face:
		mov	bp,data_ptr
		mov	si,save_ptr
	test	flip_dir,left
	jz	n_l_f
	call	flip_spr	;address data-ptr in bp !
n_l_f:
		mov	di,window_topleft
		mov	bx,offset msk_tab 		;colr_map
test_above:	mov	ax, sprt_y
		cmp	ax, 0			; all or part above scrn ?
		jge	over_ss2		; - no
		add	bled_rows, ax		; - yes
		jg	over_ss1		; all above scrn ?
		jmp	sprt_offscrn		; - yes
over_ss1:	mov	bled_y, 0		; - no, bled sprt at scrn top
		neg	ax
		mul	sprt_cols
;shl	ax, 1	ha you little bastard
		add	bp, ax			; adjust sprt/mask data ptr
		jmp	test_left		; but leave bkgd ptr unchanged
over_ss2:	mov	dh, al
		xor	dl, dl
		shr	dx, 1
		shr	dx, 1
		shl	ax, 1
		shl	ax, 1
		add	di, dx			; top onscrn, update bkgd ptr
		sub	di, ax
test_below:	mov	ax, 160
		sub	ax, sprt_y		; all below scrn ?
		jg	over_ss3		; - no
		jmp	sprt_offscrn		; - yes
over_ss3:	cmp	ax, sprt_rows		; part below scrn ?
		jge	test_left		; - no
		mov	bled_rows, ax		; - yes
test_left:	mov	ax,sprt_x
		cmp	ax,0			; all or part left of scrn ?
		jge	over_ss5		; - no
		add	bled_cols,ax		; - yes
		jg	over_ss4		; all left of scrn ?
		jmp	sprt_offscrn		; - yes
over_ss4:	mov	bled_x,0		; - no, bled sprt at scrn left
;shl	ax,1
		sub	bp,ax			; adjust data ptr
		jmp	ptrs_bled		; but leave bkgd ptr unchanged
over_ss5:	add	di,ax			; left onscrn, update bkgd ptr
test_right:	mov	ax,60
		sub	ax,sprt_x		; all right of scrn ?
		jg	over_ss6		; - no
		jmp	sprt_offscrn		; - yes
over_ss6:	cmp	ax, sprt_cols		; part right of scrn ?
		jge	ptrs_bled		; - no
		mov	bled_cols, ax		; - yes
ptrs_bled:	mov	bled_bkgd_ptr, di	; store, for undrawing
		mov	sp_save, bp
		mov	ax,sprt_cols
		sub	ax,bled_cols
;shl	ax,1
		mov	skip_words, ax
		mov	ax,60			; eval cols before wrap
		sub	ax,window_left
		sub	ax,bled_x
		jge	over_ss7
		xor	ax,ax
over_ss7:	cmp	ax,bled_cols
		jle	over_ss8
		mov	ax,bled_cols
over_ss8:	mov	cols_b4_wrap, ax
		neg	ax			; eval cols atfer wrap
		add	ax, bled_cols
		mov	cols_aftr_wrap, ax
		mov	ax,159			; eval rows before wrap
		sub	ax,window_top
		sub	ax,bled_y
		jge	over_ss9
		xor	ax, ax
over_ss9:	cmp	ax, bled_rows
		jl	over_ss10
		mov	ax, bled_rows
		mov	cols_b4_wrap,0		; if whole sprt is one main
		mov	cols_aftr_wrap,0	; part then no wrap-line
over_ss10:	mov	rows_b4_wrap,ax
		mov	ax,window_top		; eval rows after wrap
		add	ax,bled_y
		add	ax,bled_rows
		sub	ax,160
		jge	over_ss11
		xor	ax,ax
over_ss11:	cmp	ax,bled_rows
		jl	over_ss12
		mov	ax, bled_rows
		mov	cols_b4_wrap,0		; if whole sprt is one main
		mov	cols_aftr_wrap, 0	; part then no wrap-line
over_ss12:	mov	rows_aftr_wrap, ax
		ret

sprt_offscrn:	xor	ax, ax
		mov	bled_rows, 0
		mov	rows_b4_wrap, ax
		mov	rows_aftr_wrap, ax
		mov	cols_b4_wrap, ax
		mov	cols_aftr_wrap, ax
		ret

draw_jump_tabl:	dw	offset draw_1_col
		dw	offset draw_2_cols
		dw	offset draw_3_cols
		dw	offset draw_4_cols
		dw	offset draw_5_cols
		dw	offset draw_6_cols
		dw	offset draw_7_cols
		dw	offset draw_8_cols
		dw	offset draw_9_cols
		dw	offset draw_10_cols
		dw	offset draw_11_cols
		dw	offset draw_12_cols
		dw	offset draw_13_cols
		dw	offset draw_14_cols
		dw	offset draw_15_cols
		dw	offset draw_16_cols
		dw	offset draw_17_cols
		dw	offset draw_18_cols
		dw	offset draw_19_cols
		dw	offset draw_20_cols
		dw	offset draw_21_cols
		dw	offset draw_22_cols
		dw	offset draw_23_cols

draw_1_col:
		draw_b	0
		draw_ptrs
		dec	word ptr loop_var
		jne	draw_1_col
		jmp	restore_stack

draw_2_cols:
		draw_w	0
		draw_ptrs
		dec	word ptr loop_var
		jne	draw_2_cols
		jmp	restore_stack

draw_3_cols:
		draw_w	0
		draw_b	2
		draw_ptrs
		dec	word ptr loop_var
		jne	draw_3_cols
		jmp	restore_stack

draw_4_cols:
		draw_w	0
		draw_w	2
		draw_ptrs
		dec	word ptr loop_var
		jne	draw_4_cols
		jmp	restore_stack

draw_5_cols:
		draw_w	0
		draw_w	2
		draw_b	4
		draw_ptrs
		dec	loop_var
		jne	draw_5_cols
		jmp	restore_stack

draw_6_cols:
		draw_w	0
		draw_w	2
		draw_w	4
		draw_ptrs
		dec	word ptr loop_var
		jne	draw_6_cols
		jmp	restore_stack

draw_7_cols:	
		draw_w	0
		draw_w	2
		draw_w	4
		draw_b	6
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d7c
		jmp	restore_stack
over_d7c:	jmp	draw_7_cols

draw_8_cols:	
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d8c
		jmp	restore_stack
over_d8c:	jmp	draw_8_cols

draw_9_cols:
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_b	8
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d9c
		jmp	restore_stack
over_d9c:	jmp	draw_9_cols

draw_10_cols:	
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_w	8
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d10c
		jmp	restore_stack
over_d10c:	jmp	draw_10_cols

draw_11_cols:	
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_w	8
		draw_b	10
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d11c
		jmp	restore_stack
over_d11c:	jmp	draw_11_cols

draw_12_cols:
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_w	8
		draw_w	10
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d12c
		jmp	restore_stack
over_d12c:	jmp	draw_12_cols

draw_13_cols:
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_w	8
		draw_w	10
		draw_b	12
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d13c
		jmp	restore_stack
over_d13c:	jmp	draw_13_cols

draw_14_cols:	
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_w	8
		draw_w	10
		draw_w	12
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d14c
		jmp	restore_stack
over_d14c:	jmp	draw_14_cols

draw_15_cols:	
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_w	8
		draw_w	10
		draw_w	12
		draw_b	14
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d15c
		jmp	restore_stack
over_d15c:	jmp	draw_15_cols

draw_16_cols:
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_w	8
		draw_w	10
		draw_w	12
		draw_w	14
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d16c
		jmp	restore_stack
over_d16c:	jmp	draw_16_cols

draw_17_cols:
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_w	8
		draw_w	10
		draw_w	12
		draw_w	14
		draw_b	16
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d17c
		jmp	restore_stack
over_d17c:	jmp	draw_17_cols



draw_18_cols:
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_w	8
		draw_w	10
		draw_w	12
		draw_w	14
		draw_w	16
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d18c
		jmp	restore_stack
over_d18c:	jmp	draw_18_cols

draw_19_cols:
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_w	8
		draw_w	10
		draw_w	12
		draw_w	14
		draw_w	16
		draw_b	18
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d19c
		jmp	restore_stack
over_d19c:	jmp	draw_19_cols


draw_20_cols:
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_w	8
		draw_w	10
		draw_w	12
		draw_w	14
		draw_w	16
		draw_w	18
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d20c
		jmp	restore_stack
over_d20c:	jmp	draw_20_cols

draw_21_cols:
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_w	8
		draw_w	10
		draw_w	12
		draw_w	14
		draw_w	16
		draw_w	18
		draw_b	20
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d21c
		jmp	restore_stack
over_d21c:	jmp	draw_21_cols

draw_22_cols:
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_w	8
		draw_w	10
		draw_w	12
		draw_w	14
		draw_w	16
		draw_w	18
		draw_w	20
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d22c
		jmp	restore_stack
over_d22c:	jmp	draw_22_cols

draw_23_cols:
		draw_w	0
		draw_w	2
		draw_w	4
		draw_w	6
		draw_w	8
		draw_w	10
		draw_w	12
		draw_w	14
		draw_w	16
		draw_w	18
		draw_w	20
		draw_b	22
		draw_ptrs
		dec	word ptr loop_var
		jne	over_d23c
		jmp	restore_stack
over_d23c:	jmp	draw_23_cols




undw_jump_tabl:	dw	offset undraw_1_col
		dw	offset undraw_2_cols
		dw	offset undraw_3_cols
		dw	offset undraw_4_cols
		dw	offset undraw_5_cols
		dw	offset undraw_6_cols
		dw	offset undraw_7_cols
		dw	offset undraw_8_cols
		dw	offset undraw_9_cols
		dw	offset undraw_10_cols
		dw	offset undraw_11_cols
		dw	offset undraw_12_cols
		dw	offset undraw_13_cols
		dw	offset undraw_14_cols
		dw	offset undraw_15_cols
		dw	offset undraw_16_cols
		dw	offset undraw_17_cols
		dw	offset undraw_18_cols
		dw	offset undraw_19_cols
		dw	offset undraw_20_cols
		dw	offset undraw_21_cols
		dw	offset undraw_22_cols
		dw	offset undraw_23_cols



undraw_1_col:	movsb
		add	di, dx
		loop	undraw_1_col
		jmp	exit_um

undraw_2_cols:	movsw
		add	di, dx
		loop	undraw_2_cols
		jmp	exit_um

undraw_3_cols:	movsw
		movsb
		add	di, dx
		loop	undraw_3_cols
		jmp	exit_um

undraw_4_cols:	movsw
		movsw
		add	di, dx
		loop	undraw_4_cols
		jmp	exit_um

undraw_5_cols:	movsw
		movsw
		movsb
		add	di, dx
		loop	undraw_5_cols
		jmp	exit_um

undraw_6_cols:	movsw
		movsw
		movsw
		add	di, dx
		loop	undraw_6_cols
		jmp	exit_um

undraw_7_cols:	movsw
		movsw
		movsw
		movsb
		add	di, dx
		loop	undraw_7_cols
		jmp	exit_um

undraw_8_cols:	movsw
		movsw
		movsw
		movsw
		add	di, dx
		loop	undraw_8_cols
		jmp	exit_um

undraw_9_cols:	movsw
		movsw
		movsw
		movsw
		movsb
		add	di, dx
		loop	undraw_9_cols
		jmp	exit_um

undraw_10_cols:
	mov	bx,cx
	mov	cx,5
	rep	movsw
	mov	cx,bx
		add	di, dx
		loop	undraw_10_cols
		jmp	exit_um

undraw_11_cols:	
	mov	bx,cx
	mov	cx,5
	rep	movsw
	mov	cx,bx
		movsb
		add	di, dx
		loop	undraw_11_cols
		jmp	exit_um

undraw_12_cols:
	mov	bx,cx
	mov	cx,6
	rep	movsw
	mov	cx,bx
		add	di, dx
		loop	undraw_12_cols
		jmp	exit_um

undraw_13_cols:
	mov	bx,cx
	mov	cx,6
	rep	movsw
	mov	cx,bx
		movsb
		add	di, dx
		loop	undraw_13_cols
		jmp	exit_um

undraw_14_cols:	
	mov	bx,cx
	mov	cx,7
	rep	movsw
	mov	cx,bx
		add	di, dx
		loop	undraw_14_cols
		jmp	exit_um

undraw_15_cols:
	mov	bx,cx
	mov	cx,7
	rep	movsw
	mov	cx,bx
		movsb
		add	di, dx
		loop	undraw_15_cols
		jmp	exit_um

undraw_16_cols:	
	mov	bx,cx
	mov	cx,8
	rep	movsw
	mov	cx,bx
		add	di, dx
		loop	undraw_16_cols
		jmp	exit_um

undraw_17_cols:	
	mov	bx,cx
	mov	cx,8
	rep	movsw
	mov	cx,bx
		movsb
		add	di, dx
		loop	undraw_17_cols
		jmp	exit_um

undraw_18_cols:	
	mov	bx,cx
	mov	cx,9
	rep	movsw
	mov	cx,bx
		add	di, dx
		loop	undraw_18_cols
		jmp	exit_um

undraw_19_cols:	
	mov	bx,cx
	mov	cx,9
	rep	movsw
	mov	cx,bx
		movsb
		add	di, dx
		loop	undraw_19_cols
		jmp	exit_um

undraw_20_cols:	
	mov	bx,cx
	mov	cx,10
	rep	movsw
	mov	cx,bx
		add	di, dx
		loop	undraw_20_cols
		jmp	exit_um

undraw_21_cols:
	mov	bx,cx
	mov	cx,10
	rep	movsw
	mov	cx,bx
		movsb
		add	di, dx
		loop	undraw_21_cols
		jmp	exit_um

undraw_22_cols:	
	mov	bx,cx
	mov	cx,11
	rep	movsw
	mov	cx,bx
		add	di, dx
		loop	undraw_22_cols
		jmp	exit_um

undraw_23_cols:
	mov	bx,cx
	mov	cx,11
	rep	movsw
	mov	cx,bx
		movsb
		add	di, dx
		loop	undraw_23_cols
		jmp	exit_um

cseg		ends

dseg		segment	page public 'data'

flp_tab		db	256 dup (?)	;placed on a 256 byte boundary !

public		bled_x, bled_y, bled_cols, bled_rows, sprt_table, ss_save
public		sprt_x, sprt_y, sprt_cols, sprt_rows, data_ptr, colr_map
PUBLIC		BLED_BKGD_PTR,SAVE_PTR,msk_tab

extrn		window_topleft: word, window_top: word, window_left: word
extrn		scroll_flag: byte,SIXTEENCOL:BYTE
EXTRN		JUMPTAB:WORD
extrn		person_on:word , flip_dir:word , spr_l_offs:byte


loop_var	dw	?

even
;	vers is either 1 : cga 2 : vga !
save_0	equ	offset save_area
save_1	equ	save_0+1200*vers
save_2	equ	save_1+1200*vers
save_3	equ	save_2+1600*vers
save_4	equ	save_3+1600*vers
save_5	equ	save_4+1600*vers
save_6	equ	save_5+2000*vers

save_7	equ	save_6+2000*vers
save_8	equ	save_7+400*vers	 ;	knives/balls/whips/spades
save_9	equ	save_8+400*vers	 ;	knives/balls/whips/spades
save_10	equ	save_9+400*vers	 ;	knives/balls/whips/spades
save_11	equ	save_10+680*vers ;	all
save_12	equ	save_11+680*vers ;	all !

save_end	equ	save_12+680*vers

sprt_table	dw  6 dup (?), save_0, 9 dup (?)	;pl1 1200
		dw  6 dup (?), save_1, 9 dup (?)	;pl2 1200
		dw  6 dup (?), save_2, 9 dup (?)	;    1600
		dw  6 dup (?), save_3, 9 dup (?)	;    1600
		dw  6 dup (?), save_4, 9 dup (?)	;    1600
		dw  6 dup (?), save_5, 9 dup (?)	;    2000
		dw  6 dup (?), save_6, 9 dup (?)	;    2000

		dw	6 dup (?), save_7, 9 dup (?)	;knifes or grenades only
		dw	6 dup (?), save_8, 9 dup (?)	;knifes or grenades only
		dw	6 dup (?), save_9, 9 dup (?)	;whips / spades
		dw	6 dup (?), save_10, 9 dup (?)	;whips / spades
		dw	6 dup (?), save_11, 9 dup (?)	;rocks/balls/crates
		dw	6 dup (?), save_12, 9 dup (?)	;rocks/balls/crates
;2000 bytes per object ?!
sprt_x		dw	?
sprt_y		dw	?
sprt_cols	dw	?
sprt_rows	dw	?
data_ptr	dw	?
colr_map	dw	?
save_ptr	dw	?

bled_x		dw	?
bled_y		dw	?
bled_cols	dw	?
bled_rows	dw	?
cols_b4_wrap	dw	?
cols_aftr_wrap	dw	?
rows_b4_wrap	dw	?
rows_aftr_wrap	dw	?
bled_bkgd_ptr	dw	?

skip_words	dw	?

sp_save		dw	?
ss_save		dw	?
spr_rows	dw	0

even

msk_tab	db	256 dup (?)

	db	20 dup (?) ; where didst that corruption come from
new_spr	db	2048 dup (?)	;this might be it.( or then again?)

dseg		ends

buff_seg	segment public 'data'
public		save_area

res_mem		save_area , 30400 , 15600

; have added 700 to both hopefully to stop corruption of VGA loading !
;	cga loading probs mean another extension !

buff_seg	ends

end
