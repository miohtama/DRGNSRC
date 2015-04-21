
;
;should be all ega handling routines for the game !
;

cseg		segment	public 'code'
;put all the sprite routines in here (
extrn	pnum:near
public		draw_sprtega,undraw_sprtega
public		player1_rout,player2_rout,enemy1_rout,roper_rout
public		babobo_rout,gabobo_rout
public		enemy2_rout,enemy3_rout,enemy4_rout
public		make_table

public		vgaplayer2_rout,vgaghost_rout,vgaroper_rout

assume		cs:cseg, ds:dseg,es:buff_seg

d_scrn_w	equ	36	;144/4
gap		equ	6	;24/4

include	ddeqfile

;       fuckin ace 8086 programming discovery !!
;rep	movs	byte ptr es:[si],byte ptr es:[di]
;       fuckin ace 8086 programming discovery !!

shift	macro
		rept	4
		rcl	bx,1	;you cannot be serious adc ! why not rcl bx,1
		rcr	al,1
		rcl	bx,1
		rcr	ah,1
		rcl	bx,1
		rcr	dl,1
		rcl	bx,1
		rcr	dh,1
		endm
	rcl	bx,1	;???
	endm

ega_mac_2	macro
	mov	al,[bp+8192]	;10?
	mov	ah,[bp]	;load from screen;10?
	stosw	;buffer the screen !	;10?
	and	ax,bx			;3
	or	ax,cx	;2 bit planes at once;3
	mov	[bp+8192],al		;10
	mov	[bp],ah			;10
	mov	al,[bp+24576]		;10	
	mov	ah,[bp+16384]	;load from screen;10
	stosw	;buffer the scrn !	;10
	and	ax,bx			;3
	or	ax,dx	;2 bit planes at once;3
	mov	[bp+24576],al		;10
	mov	[bp+16384],ah		;10	=112
	endm

lowd_planes	macro
	lodsw
	mov	dx,ax
;xchg	cl,ch
	lodsw
	xchg	ah,dl
	xchg	al,dh
	mov	cx,ax
	endm	;must change this ?!

lowd_planesf	macro
	push	bx
	mov	bx,offset flip_tab
	lodsw
	mov	bl,al
	mov	dl,es:[bx]
	mov	bl,ah
	mov	dh,es:[bx]

	lodsw
	mov	bl,al
	mov	cl,es:[bx]
	mov	bl,ah
	mov	ch,es:[bx]

	pop	bx
	mov	ax,cx
	xchg	ch,dl
	mov	ax,cx	

;mov	ch,al
;xchg	ch,dl
;mov	ax,cx
;lodsw	;mov	dx,ax	;lodsw	;xchg	ah,dl	;mov	cx,ax
	endm	;must change this ?!

sp_ega_macf	macro
;	new version that fips the data first then saves to screen

	lowd_planesf
;flip_data
	or	ax,dx
	or	al,ah
	mov	bl,al
	mov	bh,bl
	not	bx
	ega_mac_2
	endm

cmask	macro
	mov	bx,cx
	or	bx,dx
	or	bl,bh
	mov	bh,bl
	not	bx
	endm

;simple non-recolouring routine

sp_ega_mac	macro	;a subrotuine ?!?!? never!!
;put a byte of ega sprite onto dummy
;
	lowd_planes
	or	ax,dx
	or	al,ah
	mov	bl,al
	mov	bh,bl
	not	bx
	ega_mac_2
	endm

;
;	player 2 recolouring code.
;
;	r-ch    g-cl   b-dh   i-dl
;	Change --bi	hmm could do --b- to r---	all blues to reds?
;	  to   r--i    

;	grey pl2 means --b- to ---i

sp_ega_macc2	macro	;recolours blue into red (eventually!) 

	lowd_planes	
;not	al	;assumes ax=cx/dx contain colour data
;not	dh	; ignore the al?
;and	ax,dx
;and	al,ah	;and off all planes
;not	dh	;restore the notting !	
; hmmm it isnt quite as easy as this is it? yellow=? g/b 
;xor	dl,dh	;change these bits	;good grief?
;xor	dh,dh	;for 0011 to 1001 want 0010 to 0001 ?

	not	dx
	not	al
	and	ax,dx
	and	al,ah	;created the mask thing
	not	dx	;restore!
	xor	dl,al	;swap intensity
	xor	ch,al	;swap blue
	mov	ax,cx
	not	dh
	not	al
	and	ax,dx
	and	al,ah
	not	dh
	xor	cl,al
	xor	dl,al
	xor	dh,al	; christ thats a lot 

	cmask
	ega_mac_2
	endm

recol_babobo	macro	; make this the ghost !!
;	changes colours to magenta
;	at first just the blue to magenta.

	not	al
	not	dh
	and	ah,dh
	and	al,ah
	not	dh
	xor	dh,al

	endm

recol_roper	macro
;	do the blue to green recolour !
;	recolour all blue to greens.??
	not	al
	not	dh
	and	ah,dh	;ignore dl ! ie intensity.
	and	al,ah	;chooses er dark blue
	xor	cl,al
	xor	ch,al
	not	dh	;mistake city !
; that should be it
	endm

;not	al	;red
;not	dh	;green
;and	ax,dx
;and	al,ah	;and off all planes
;not	dh	;restore the notting !	
;xor	ch,al	;change these bits
;xor	cl,al	;for 1001 to 0101
;bgri to  
;mov	ax,cx	
;not	ah	
;and	ax,dx	
;and	al,ah	;this for changing yellow to grey
;xor	cl,al
;xor	dh,al

recol_vgapl2	macro
;	blues to greys
;
	mov	ax,dx
	not	cl
	and	ah,cl
	and	al,ah
	not	cl
	xor	dh,al
	xor	cl,al
; that should be it
	endm

sp_ega_maccvg3	macro	;recolours blue into GREEN and yellow to grey
;put a byte of ega sprite onto dummy  for roper !
;may not use pop !!!!!
;	r-ch    g-cl   b-dh   i-dl
;				
;	Change r--i    
;	  to   -g-i
	lowd_planes
	recol_vgapl2
	cmask
	ega_mac_2
	endm

sp_ega_macc3	macro	;recolours blue into GREEN and yellow to grey
;put a byte of ega sprite onto dummy  for roper !
;may not use pop !!!!!
;	r-ch    g-cl   b-dh   i-dl
;				
;	Change r--i    
;	  to   -g-i
	lowd_planes
	recol_roper
	cmask
	ega_mac_2
	endm


recol_vgaghost	macro
;	do the blue to green recolour !
;	recolour all blue to greens.??
	mov	ax,dx
	not	cl
	and	ah,cl
	and	al,ah
	not	cl
	xor	dh,al
	xor	cl,al
; that should be it
	endm

sp_ega_maccvg4	macro	;recolours blue into GREEN and yellow to grey
;put a byte of ega sprite onto dummy  for roper !
;may not use pop !!!!!
;	r-ch    g-cl   b-dh   i-dl
;				
;	Change r--i    
;	  to   -g-i
	lowd_planes
	recol_vgaghost
	cmask
	ega_mac_2
	endm

recol_vgaroper	macro
;	110x to 100x	brill recolour this !
	mov	ax,dx
	not	cl
	and	al,cl
	and	al,ah
	not	cl
	xor	dh,al
; that should be it
	endm

sp_ega_maccvg5	macro	;recolours blue into GREEN and yellow to grey
;put a byte of ega sprite onto dummy  for roper !
;may not use pop !!!!!
;	r-ch    g-cl   b-dh   i-dl
;				
;	Change r--i    
;	  to   -g-i
	lowd_planes
	recol_vgaroper
	cmask
	ega_mac_2
	endm

sp_ega_macc4	macro	;recolours blue into red (eventually!) 
;put a byte of ega sprite onto dummy
;may not use pop !!!!!
;	r-ch   äg-cl   b-dh   i-dl
;				
;	Change r--i    
;	  to   -g-i
	lowd_planes
	recol_babobo
	cmask
	ega_mac_2
	endm
recol_gabobo	macro
;recolour routine for black abobo 
;now bright red to dark grey	dl 1 rest 0
;bgri  
	not	ax	;
	and	al,ah	;skip the intenstity !
	and	al,dh	;select ANY red
			;change to equiv green.
	xor	cl,al	;swap green (put to one )
	xor	dh,al	;kill the red implies light black
;change white  dark grey
;	b-cl    g-ch   r-dh   i-dl
;	1111 to 1110
	mov	ax,cx
	and	ax,dx
	and	al,ah
	xor	cl,al
	xor	ch,al
	xor	dh,al
	endm

sp_ega_macc5	macro	;recolours for green abobo
;put a byte of ega sprite onto dummy
;may not use pop !!!!!
;	r-ch    g-cl   b-dh   i-dl
;				
;	Change r--i    
;	  to   -g-i
	lowd_planes
	recol_gabobo
	cmask
	ega_mac_2
	endm

make_table:
; make the flip table
	push	ds
	push	es

	mov	ax,seg flip_tab
	mov	es,ax
	mov	cx,0
	mov	ax,offset flip_tab
	mov	di,ax	;big waste of memory to make sure on boundary
	cld
mk_lp:
	mov	ah,cl
	rept	8
	shl	ah,1
	rcr	al,1
	endm
	stosb
	inc	cx
	cmp	cx,256
	jne	mk_lp

	pop	es
	pop	ds
	ret

flip_spr:
;	Sprite version no recolouring and no shifting
;	BUT that flips the sprite horizontally
;	oh good grief
	push	bp
	push	cx
	push	dx
	push	di
	push	bx
	push	ds
	mov	ax,ss_save
	mov	ds,ax	;ds is the sprite data dippo !
	mov	di,offset new_spr	;4k for the sprite ?
;	use di=buff-area ?
;destination of new sprite.
	mov	bx,offset flip_tab	;try this one !
	mov	es:spr_rows,dx
	mov	bp,cx
	shl	bp,1
	shl	bp,1	;4 bytes per x col
row_lp:
	add	di,bp	;move to right of this row ?!
	push	cx
byte_lp:
	sub	di,4
	lodsw
	mov	bl,al
	mov	al,es:[bx]
	mov	bl,ah
	mov	ah,es:[bx]
	mov	es:[di],ax
	lodsw
	mov	bl,al
	mov	al,es:[bx]
	mov	bl,ah
	mov	ah,es:[bx]
	mov	es:[di+2],ax
	loop	byte_lp

	pop	cx
	add	di,bp	;make up for last times subtractions ?!?
	dec	es:spr_rows
	jne	row_lp
	pop	ds
	mov	ax,seg new_spr
	mov	ss_save,ax
	mov	si,offset new_spr	;will it ever work ??
	pop	bx
	pop	di
	pop	dx
	pop	cx
	pop	bp
;mov	si,di	; the sprite is in save area (hmm is that feasable?)
	ret

draw_sprtega:
		mov	di, offset sprt_x
		movsw
		movsw
		movsw
		movsw
		movsw
		movsw
		movsw
		push	si
;si is pointer to sprite data table (why is it pushed).
;1 get a screen_addr
		push	es
		mov	bled_bkgd_ptr,48000	;dummy value for no spr
;mov	si,person_on	;my setup doesnt use si
;mov	al,byte ptr [si+4]
;mov	ddd,al
		call	setup_sprt
	jNc	Noff
		JMP	OFFSCREEN
NOFF:		
		MOV	bled_bkgd_ptr,di	;save for restbackground.
		mov	bp,di	;this is WRONG !

		and	bp,8191

		MOV	di,save_ptr
		MOV	si,data_ptr	;get sprite data addr
		MOV	DX,sprt_rows
		MOV	CX,sprt_cols
	MOV	AX,SEG SAVE_AREA
	MOV	ES,AX
	mov	word ptr ES:[shftflg],0	;set up for shifting routine. 	
	mov	bx,colr_map	;in ega should be addr of spriterout 

	cmp	bx,offset player1_rout
	je	zz1
	cmp	bx,offset player2_rout
	je	zz1
	cmp	bx,offset roper_rout
	je	zz1
	cmp	bx,offset babobo_rout	; for ghosts !
	je	zz1
	cmp	bx,offset vgaplayer2_rout
	je	zz1
	cmp	bx,offset vgaroper_rout
	je	zz1
	cmp	bx,offset vgaghost_rout
	je	zz1

;cmp	bx,offset gabobo_rout
;je	zz1
	mov	bx,offset player1_rout	;dam I'd forgot this !
zz1:
;cmp	bx,offset player1_rout
;jne	okei	;frigg for the moment only shift for player1
;if shifted sprt_cols must be increased.

	test	word ptr sprt_x,1	;odd or even byte
	jz	okei
	add	sprt_cols,2	;hmmmm
	mov	word ptr ES:[shftflg],1	;set up for shifting routine. 	
okei:
	inc	cx	;
	shr	cx,1	;
;	******************************
;	cx=sprt_cols	|  dx=row_loop
;	******************************
	test	flip_dir,left	;direction,left
	jz	no_flip
;	
	call	flip_spr
no_flip:
	mov	ax,ss_save
	mov	ds,ax	;ds is the sprite data dippo !

	MOV	ES:[sp_cols],CX	;sprt_cols variable !
	MOV	ES:[rw_loop],DX	;row_loop counter
		mov	dx,d_scrn_w
		sub	DX,CX

	border	8+2
		; use bx thats been set earlier on !
		jmp	bx	;always use player_rout
player1_rout:	
		cmp	word ptr Es:[shftflg],1
		jne	nshif
		jmp	shiftrout
nshif:
		MOV	ES:[dl_var],DX
;cmp	word ptr es:[flip_flg],1
;jne	nflip	;christ sake !?
;jmp	flip_rout
nflip:
ROW_LOOP:
	MOV	ax,ES:[sp_cols]	;sprt_cols
	or	ax,ax
	jne	nt
	border	15
nt:
	mov	es:[col_lp],ax
COL_LOOP:
		sp_ega_mac	;long winded !
		inc	bp
		and	bp,8191	;move and WRAP 	
		dec	word ptr es:[col_lp]		;loop COL_LOOP		
	jne	col_loop	;interesting why crash ?
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JNE	ROW_LOOP	;inefficient or what !
		mov	ax,seg dseg
		mov	ds,ax
offscreen:
		POP	ES
		pop	di
	MOV	AX,SEG DSEG
	MOV	DS,AX
	mov	ax,sprt_x	;store for rebuffing
	mov	bled_x,ax
		mov	si,offset bled_x
		mov	cx,9
	rep	movsw
		ret
shiftrout:
;the player 1 shift routine
		MOV	ES:[dl_var],DX
ROW_LOOPs:	MOV	CX,ES:[sp_cols]	;sprt_cols
		mov	Es:[sh_cntr],cx	;put into loop counter
		mov	word ptr Es:[shiftn],0	;blank the shift in
COL_LOOPs:	lodsw
		mov	dx,ax
		lodsw	;shift here using 
	xchg	al,dh
	xchg	ah,dl
		mov	bx,Es:[shiftn]	;the shift thingy
		clc
		shift
;bx is the 4 pixels in 4 planes of shift
		mov	Es:[shiftn],bx
		mov	cx,ax
		or	ax,dx
		or	al,ah
		mov	bl,al
		mov	bh,bl
		not	bx
		ega_mac_2
		inc	bp
		and	bp,8191	;move and WRAP !
		dec	word ptr Es:[sh_cntr]
		je	skipjump
		jmp	col_loops
skipjump:
;the data here should be that which was shifted out from earlier
		mov	bx,Es:[shiftn]	;the shift thingy
		xor	ax,ax
		mov	dx,ax	;zero as all data here is shifted in.
;	clc	;should have been cleared by the zor
		shift	;shifts from bx into al/h and dl/h
;bx is the 4 pixels in 4 planes of shift
;	mov	Es:[shiftn],bx	;dont bother
;mov	ax,cx
		mov	cx,ax
		or	ax,dx
		or	al,ah
		mov	bl,al
		mov	bh,bl
		not	bx
		ega_mac_2
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JE	nrolp	;ROW_LOOPs	inefficient or what !
		jmp	row_loops
nrolp:		mov	ax,seg dseg
		mov	ds,ax
	jmp	offscreen
;	*****************************************************
;	*****************************************************

player2_rout:
	cmp	word ptr ES:[shftflg],1
	jp_e	shiftrout2
		MOV	ES:[dl_var],DX
ROW_LOOP2:	MOV	CX,ES:[sp_cols]	;sprt_cols
COL_LOOP2:
		push	cx
		sp_ega_macc2	;long winded !
		inc	bp
		and	bp,8191	;move and WRAP !
		pop	cx
		LOOP	COL_LOOP2
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JNE	ROW_LOOP2	;inefficient or what !
		mov	ax,seg dseg
		mov	ds,ax
	jmp	offscreen

;	*****************************************************

shiftrout2:	MOV	ES:[dl_var],DX
ROW_LOOPs2:	MOV	CX,ES:[sp_cols]	;sprt_cols
		mov	ES:[sh_cntr],cx	;put into loop counter
		mov	word ptr ES:[shiftn],0	;blank the shift in
COL_LOOPs2:	lodsw
		mov	dx,ax
		lodsw	;shift here using 
	xchg	al,dh	;	this just copied from other piece
	xchg	ah,dl	;
		mov	bx,ES:[shiftn]	;the shift thingy
		clc
		shift
;bx is the 4 pixels in 4 planes of shift
		mov	ES:[shiftn],bx
		mov	cx,ax

;	not	al	;assumes ax=cx/dx contain colour data
;	not	dh	
;	and	ax,dx
;	and	al,ah	;and off all planes
;	not	dh	;restore the notting !	
;	xor	ch,al	;change these bits
;	xor	dh,al	;for 0011 to 1001

	not	dx
	not	al
	and	ax,dx
	and	al,ah	;created the mask thing
	not	dx	;restore!
	xor	dl,al	;swap intensity
	xor	ch,al	;swap blue
	mov	ax,cx
	not	dh
	not	al
	and	ax,dx
	and	al,ah
	not	dh
	xor	cl,al
	xor	dl,al
	xor	dh,al	; christ thats a lot 

		cmask	;create mask macro
		ega_mac_2

		inc	bp
		and	bp,8191	;move and WRAP !
		dec	word ptr ES:[sh_cntr]
		je	skipjump2
		jmp	col_loops2
skipjump2:
;the data here should be that which was shifted out from earlier
		mov	bx,ES:[shiftn]	;the shift thingy
		xor	ax,ax
		mov	dx,ax	;zero as all data here is shifted in.
;	clc	;should have been cleared by the zor
		shift	;shifts from bx into al/h and dl/h
;bx is the 4 pixels in 4 planes of shift
;	mov	ES:[shiftn],bx	;dont bother
;mov	ax,cx
		mov	cx,ax
	not	al	;assumes ax=cx/dx contain colour data
	not	dh	
	and	ax,dx
	and	al,ah	;and off all planes
	not	dh	;restore the notting !	
	xor	ch,al	;change these bits
	xor	dh,al	;for 0011 to 1001

	cmask	;create mask macro
		ega_mac_2
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JE	nrolp2	;ROW_LOOPs	inefficient or what !
		jmp	row_loops2
nrolp2:		mov	ax,seg dseg
		mov	ds,ax
	jmp	offscreen

;	*****************************************************

enemy1_rout:
roper_rout:	;a recolouring routine for a badguy (recolour white to red?)
	cmp	word ptr ES:[shftflg],1
	je	shiftrout3	;DELETEDJune 19, 1989 caused bug 7:55 PM August 27, 1989
		MOV	ES:[dl_var],DX
ROW_LOOP3:	MOV	CX,ES:[sp_cols]	;sprt_cols
COL_LOOP3:
		push	cx
		sp_ega_macc3	;long winded !
		inc	bp
		and	bp,8191	;move and WRAP !
		pop	cx
		LOOP	COL_LOOP3
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JNE	ROW_LOOP3	;inefficient or what !
		mov	ax,seg dseg
		mov	ds,ax
	jmp	offscreen
shiftrout3:	MOV	ES:[dl_var],DX
ROW_LOOPs3:	MOV	CX,ES:[sp_cols]	;sprt_cols
		mov	ES:[sh_cntr],cx	;put into loop counter
		mov	word ptr ES:[shiftn],0	;blank the shift in
COL_LOOPs3:	lodsw
		mov	dx,ax
		lodsw	;shift here using 
	xchg	al,dh	;	this just copied from other piece
	xchg	ah,dl	;
		mov	bx,ES:[shiftn]	;the shift thingy
		clc
		shift
		mov	ES:[shiftn],bx
		mov	cx,ax
		recol_roper
		cmask	;create mask macro
		ega_mac_2
		inc	bp
		and	bp,8191	;move and WRAP !
		dec	word ptr ES:[sh_cntr]
		je	skipjump3
		jmp	col_loops3
skipjump3:
		mov	bx,ES:[shiftn]	;the shift thingy
		xor	ax,ax
		mov	dx,ax	;zero as all data here is shifted in.
		shift	;shifts from bx into al/h and dl/h
		mov	cx,ax
		recol_roper
		cmask	;create mask macro
		ega_mac_2
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JE	nrolp3	;ROW_LOOPs	inefficient or what !
		jmp	row_loops3
nrolp3:		mov	ax,seg dseg
		mov	ds,ax
	jmp	offscreen
vgaghost_rout:

vgaplayer2_rout:

	cmp	word ptr ES:[shftflg],1
	je	shiftroutvg4
		MOV	ES:[dl_var],DX
ROW_LOOPvg4:	MOV	CX,ES:[sp_cols]	;sprt_cols
COL_LOOPvg4:
		push	cx
		sp_ega_maccvg4	;long winded !
		inc	bp
		and	bp,8191	;move and WRAP !
		pop	cx
		LOOP	COL_LOOPvg4
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JNE	ROW_LOOPvg4	;inefficient or what !
		mov	ax,seg dseg
		mov	ds,ax
	jmp	offscreen

shiftroutvg4:	MOV	ES:[dl_var],DX
ROW_LOOPsvg4:	MOV	CX,ES:[sp_cols]	;sprt_cols
		mov	ES:[sh_cntr],cx	;put into loop counter
		mov	word ptr ES:[shiftn],0	;blank the shift in
COL_LOOPsvg4:	lodsw
		mov	dx,ax
		lodsw	;shift here using 
	xchg	al,dh	;	this just copied from other piece
	xchg	ah,dl	;
		mov	bx,ES:[shiftn]	;the shift thingy
		clc
		shift
		mov	ES:[shiftn],bx
		mov	cx,ax
		recol_vgaghost
		cmask	;create mask macro
		ega_mac_2
		inc	bp
		and	bp,8191	;move and WRAP !
		dec	word ptr ES:[sh_cntr]
		je	skipjumpvg4
		jmp	col_loopsvg4
skipjumpvg4:
		mov	bx,ES:[shiftn]	;the shift thingy
		xor	ax,ax
		mov	dx,ax	;zero as all data here is shifted in.
		shift	;shifts from bx into al/h and dl/h
		mov	cx,ax
		recol_vgaghost
		cmask	;create mask macro
		ega_mac_2
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JE	nrolpvg4	;ROW_LOOPs	inefficient or what !
		jmp	row_loopsvg4
nrolpvg4:	mov	ax,seg dseg
		mov	ds,ax
	jmp	offscreen


vgaroper_rout:

	cmp	word ptr ES:[shftflg],1
	je	shiftroutvg5
		MOV	ES:[dl_var],DX
ROW_LOOPvg5:	MOV	CX,ES:[sp_cols]	;sprt_cols
COL_LOOPvg5:
		push	cx
		sp_ega_maccvg5	;long winded !
		inc	bp
		and	bp,8191	;move and WRAP !
		pop	cx
		LOOP	COL_LOOPvg5
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JNE	ROW_LOOPvg5	;inefficient or what !
		mov	ax,seg dseg
		mov	ds,ax
	jmp	offscreen

shiftroutvg5:	MOV	ES:[dl_var],DX
ROW_LOOPsvg5:	MOV	CX,ES:[sp_cols]	;sprt_cols
		mov	ES:[sh_cntr],cx	;put into loop counter
		mov	word ptr ES:[shiftn],0	;blank the shift in
COL_LOOPsvg5:	lodsw
		mov	dx,ax
		lodsw	;shift here using 
	xchg	al,dh	;	this just copied from other piece
	xchg	ah,dl	;
		mov	bx,ES:[shiftn]	;the shift thingy
		clc
		shift
		mov	ES:[shiftn],bx
		mov	cx,ax
		recol_vgaroper
		cmask	;create mask macro
		ega_mac_2
		inc	bp
		and	bp,8191	;move and WRAP !
		dec	word ptr ES:[sh_cntr]
		je	skipjumpvg5
		jmp	col_loopsvg5
skipjumpvg5:
		mov	bx,ES:[shiftn]	;the shift thingy
		xor	ax,ax
		mov	dx,ax	;zero as all data here is shifted in.
		shift	;shifts from bx into al/h and dl/h
		mov	cx,ax
		recol_vgaroper
		cmask	;create mask macro
		ega_mac_2
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JE	nrolpvg5	;ROW_LOOPs	inefficient or what !
		jmp	row_loopsvg5
nrolpvg5:	mov	ax,seg dseg
		mov	ds,ax
	jmp	offscreen


;vgaplayer2_rout:
;	a new recolour routine
;	jeez needs much more fucking code as well !

	cmp	word ptr ES:[shftflg],1
	je	shiftroutvg3
		MOV	ES:[dl_var],DX
ROW_LOOPvg3:	MOV	CX,ES:[sp_cols]	;sprt_cols
COL_LOOPvg3:
		push	cx
		sp_ega_maccvg3	;long winded !
		inc	bp
		and	bp,8191	;move and WRAP !
		pop	cx
		LOOP	COL_LOOPvg3
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JNE	ROW_LOOPvg3	;inefficient or what !
		mov	ax,seg dseg
		mov	ds,ax
	jmp	offscreen

shiftroutvg3:	MOV	ES:[dl_var],DX
ROW_LOOPsvg3:	MOV	CX,ES:[sp_cols]	;sprt_cols
		mov	ES:[sh_cntr],cx	;put into loop counter
		mov	word ptr ES:[shiftn],0	;blank the shift in
COL_LOOPsvg3:	lodsw
		mov	dx,ax
		lodsw	;shift here using 
	xchg	al,dh	;	this just copied from other piece
	xchg	ah,dl	;
		mov	bx,ES:[shiftn]	;the shift thingy
		clc
		shift
		mov	ES:[shiftn],bx
		mov	cx,ax
		recol_vgapl2
		cmask	;create mask macro
		ega_mac_2
		inc	bp
		and	bp,8191	;move and WRAP !
		dec	word ptr ES:[sh_cntr]
		je	skipjumpvg3
		jmp	col_loopsvg3
skipjumpvg3:
		mov	bx,ES:[shiftn]	;the shift thingy
		xor	ax,ax
		mov	dx,ax	;zero as all data here is shifted in.
		shift	;shifts from bx into al/h and dl/h
		mov	cx,ax
		recol_vgapl2
		cmask	;create mask macro
		ega_mac_2
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JE	nrolpvg3	;ROW_LOOPs	inefficient or what !
		jmp	row_loopsvg3
nrolpvg3:		mov	ax,seg dseg
		mov	ds,ax
	jmp	offscreen



enemy4_rout:
enemy3_rout:
enemy2_rout:
babobo_rout:	;abobo becomes BLACK or rather dark red ?
	cmp	word ptr ES:[shftflg],1
	je	shiftrout4
		MOV	ES:[dl_var],DX
ROW_LOOP4:	MOV	CX,ES:[sp_cols]	;sprt_cols
COL_LOOP4:
		push	cx
		sp_ega_macc4	;long winded !
		inc	bp
		and	bp,8191	;move and WRAP !
		pop	cx
		LOOP	COL_LOOP4
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JNE	ROW_LOOP4	;inefficient or what !
		mov	ax,seg dseg
		mov	ds,ax
	jmp	offscreen
shiftrout4:	MOV	ES:[dl_var],DX
ROW_LOOPs4:	MOV	CX,ES:[sp_cols]	;sprt_cols
		mov	ES:[sh_cntr],cx	;put into loop counter
		mov	word ptr ES:[shiftn],0	;blank the shift in
COL_LOOPs4:	lodsw
		mov	dx,ax
		lodsw	;shift here using 
	xchg	al,dh	;	this just copied from other piece
	xchg	ah,dl	;
		mov	bx,ES:[shiftn]	;the shift thingy
		clc
		shift
		mov	ES:[shiftn],bx
		mov	cx,ax
		recol_babobo
		cmask
		ega_mac_2
		inc	bp
		and	bp,8191	;move and WRAP !
		dec	word ptr ES:[sh_cntr]
		je	skipjump4
		jmp	col_loops4
skipjump4:
		mov	bx,ES:[shiftn]	;the shift thingy
		xor	ax,ax
		mov	dx,ax	;zero as all data here is shifted in.
		shift	;shifts from bx into al/h and dl/h
		mov	cx,ax
		recol_babobo
		cmask	;create mask macro
		ega_mac_2
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JE	nrolp4	;ROW_LOOPs	inefficient or what !
		jmp	row_loops4
nrolp4:		mov	ax,seg dseg
		mov	ds,ax
	jmp	offscreen

gabobo_rout:	;abobo becomes green (urrrrgggghh )
	cmp	word ptr ES:[shftflg],1
	je	shiftrout5
		MOV	ES:[dl_var],DX
ROW_LOOP5:	MOV	CX,ES:[sp_cols]	;sprt_cols
COL_LOOP5:
		push	cx
		sp_ega_macc5	;long winded !
		inc	bp
		and	bp,8191	;move and WRAP !
		pop	cx
		LOOP	COL_LOOP5
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JNE	ROW_LOOP5	;inefficient or what !
		mov	ax,seg dseg
		mov	ds,ax
	jmp	offscreen
shiftrout5:	MOV	ES:[dl_var],DX
ROW_LOOPs5:	MOV	CX,ES:[sp_cols]	;sprt_cols
		mov	ES:[sh_cntr],cx	;put into loop counter
		mov	word ptr ES:[shiftn],0	;blank the shift in
COL_LOOPs5:	lodsw
		mov	dx,ax
		lodsw	;shift here using 
		mov	bx,ES:[shiftn]	;the shift thingy
		clc
		shift
		mov	ES:[shiftn],bx
		mov	cx,ax
		recol_gabobo
		cmask
		ega_mac_2
		inc	bp
		and	bp,8191	;move and WRAP !
		dec	word ptr ES:[sh_cntr]
		je	skipjump5
		jmp	col_loops5
skipjump5:
		mov	bx,ES:[shiftn]	;the shift thingy
		xor	ax,ax
		mov	dx,ax	;zero as all data here is shifted in.
		shift	;shifts from bx into al/h and dl/h
		mov	cx,ax
		recol_gabobo
		cmask	;create mask macro
		ega_mac_2
		add	bp,ES:[dl_var]	;back due to words alr mved
		and	bp,8191
		DEC	WORD PTR ES:[rw_loop]	;inefficient or what !
		JE	nrolp5	;ROW_LOOPs	inefficient or what !
		jmp	row_loops5
nrolp5:		mov	ax,seg dseg
		mov	ds,ax
		jmp	offscreen

setup_sprt:
;just gets address and returns in ES:DI

	test	flip_dir,left
	jz	not_face_left

;	wait up ! this data isnt here for a weapon its different !
;	hmm how can I flag that ?

	mov	al,spr_l_offs	;[bx+6]	;offset of sprt
	cbw			; -ve 
	shl	ax,1
	sub	sprt_x,ax	;lose last one
; I am assuming this has been used already to move sprite left ?
;add	ax,sprt_cols	;making new offset
;neg	ax	;want new -ve offset
;sar	ax,1	;good grief
	mov	ax,sprt_cols
;	shr	ax,1
	sub	sprt_x,ax	;christ

not_face_left:
		mov	bx,sprt_x
		mov	cx,bx
		add	cx,8
		JS	OFFSCRN
		CMP	BX,60
		JG	OFFSCRN
	mov	ax,window_topleft
	sub	ax,offset dummy_scrn
	and	al,254	;lose bottom of dummy_scrn NOW !
	add	bx,ax
	shr	bx,1	;Lose Sum Accuracy ????????? 
		mov	ax,sprt_y
		mov	cx,ax
		add	cx,sprt_rows
		JS	OFFSCRN
		CMP	AX,176
		JG	OFFSCRN
		shl	ax,1
		shl	ax,1
		mov	cx,ax
		shl	ax,1;8
		shl	ax,1;16Í
		shl	ax,1;32
		add	ax,cx;y*40
		add	ax,bx	;screen addr !
		and	ax,8191
		MOV	DI,AX
		les	ax,dum_ptr
		clc
		ret
offscrn:	stc
		ret
undraw_sprtega:
		mov	di, offset sprt_cols
		add	si,4
		mov	cx,14
		rep	movsw
		push	es
		mov	si,save_ptr
		mov	di,bled_bkgd_ptr
		cmp	di,48000
		je	nospr
		MOV	bx,sprt_cols
		inc	bx	;hmmm line ?
		test	word ptr bled_x,1
		jz	okeidoke
		add	bx,2	;extra cols2 = one byte
okeidoke:	and	bl,254	;/2 then *2 for table index
		add	bx,offset deljmptab
		mov	bx,[bx]	;load address here as dseg gets changed
		MOV	CX,sprt_rows
	LES	dx,dum_ptr	;Dx is dummy var check doesn't have value 
	MOV	AX,SEG SAVE_AREA
	MOV	DS,AX
	jmp	bx

;jump to the certain routine 

nospr:		pop	es
		ret
	
cseg		ends

if	vers eq vga

buff_seg	segment	page	public	'data'
public		flip_tab,new_spr,spr_rows
extrn		save_area:word	;probably not used 
; go back to the idea of flip tab being on a page boundary !

res_mem	   flip_tab  ,  256 , 1	;lets hope we are on a 256 byte boundary

res_mem	   new_spr   , 4096 , 1

sp_cols	dw	?
rw_loop	dw	?
col_lp	dw	?
dl_var	dw	?
sh_cntr	dw	?
shiftn	dw	?
shftflg	dw	?
flip_flg dw	?
spr_rows dw	?
; the actual flip table indexed via es: ?

buff_seg	ends

	else


buff_seg	segment	public	'data' ; forget page bound not needed
public		flip_tab,new_spr,spr_rows
extrn		save_area:word	;probably not used 
; go back to the idea of flip tab being on a page boundary !

flip_tab  label word	;lets hope we are on a 256 byte boundary

new_spr  label word

sp_cols	dw	?
rw_loop	dw	?
col_lp	dw	?
dl_var	dw	?
sh_cntr	dw	?
shiftn	dw	?
shftflg	dw	?
flip_flg dw	?
spr_rows dw	?
; the actual flip table indexed via es: ?

buff_seg	ends

	endif

dseg		segment	public 'data'
extrn	dummy_scrn:word,dum_ptr:dword,direction:byte
extrn	window_topleft:word,chite_topleft:word
extrn	bled_x:word, bled_y:word, bled_cols:word
extrn	bled_rows:word, sprt_table:word, ss_save:word
extrn	sprt_x:word,sprt_y:word,sprt_cols:word
extrn	sprt_rows:word,data_ptr:word,colr_map:word
extrn	save_ptr:word,bled_bkgd_ptr:word
extrn	ss_save:word
extrn	deljmptab:word
extrn	person_on:word
sp_save		dw	?
extrn		flip_dir:word , spr_l_offs:byte

dseg		ends
end
