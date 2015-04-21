
cseg		segment	public 'code'

PUBLIC		DRAW_SPRT16,UNDRAW_SPRT16,write_text
public		prchar,head_16,level_16,ptxt_16
public		head,strength_bar,ptxt
public		head_cont,level_cont,ptxt_cont,make_tabtan

extrn		enter_chunk: near, stack_base: word

assume		cs: cseg, ds: dseg

include ddeqfile

d_scrn_w	equ	144	;width of dummy screen.

tanmac	macro	adr
	mov	es:[di+adr],Ax
	mov	es:[di+adr+2],dx
	endm

cgamac	macro	lhs
	mov	es:[di+lhs],dx
	mov	es:[di+lhs+2000h],dx
	endm
mac2	macro	ofs
	mov	byte ptr es:[di+ofs],128+64
	mov	byte ptr es:[di+2000h+ofs],128+64
	endm
silly	macro
local	lab
	shL	ax,1
	shL	ax,1	;make room !
	shl	dl,1
	jnc	lab
	or	aL,3
lab:
	endm
subshifty	macro
local labl
	shl	ax,1
	shl	ax,1
	shl	ax,1
	shl	ax,1	;make room !!!!
	shl	dl,1
	jnc	labl
	or	al,15 
labl:
	endm

shifty	macro
;do all the hard work !
	subshifty
	subshifty
	subshifty
	subshifty
	xchg	al,ah
	stosw
	endm

head:
head_cont:
	ret	; never should be called but in case !

strength_bar:
	add	ax,3
	shr	ax,1
	shr	ax,1
	cmp	ax,5
	jb	nchq
	mov	ax,5
nchq:
	jmp	word ptr [jumptab+18]
level_cont:
;	
	mov	bp,ax	;have bp the count
;a count
	mov	dx,5555h	;all pixels colour cyan
	cmp	cx,i_p+r_p
	je	itsbl
	shl	dx,1	;make em red !
itsbl:
	add	di,di	;*2 to charc boundarys
	add	di,80*94
	mov	bx,di
	push	es
	mov	ax,0b800h
	mov	es,ax
;do 5 characters only colour when bp>0 ?
	mov	cx,6
	cmp	bp,0
	jne	cws
	mov	dx,0
cws:
	or	dl,128+64
cgachlp:
;each charac block = 1 words .
	cgamac	0
	cgamac	80
	cgamac	160
	cgamac	240
	dec	bp
	ja	aardvark
	mov	dx,128+64	;now just black characters
aardvark:	
	add	di,2	;on a character
	loop	cgachlp
;now put above and below lines on
	mov	di,bx	;restore di
	sub	di,80-2000h;pixel above !
	mov	ax,-1
	mov	cx,5
	rep	stosw
	mov	byte ptr es:[di],128+64
	
	mov	di,bx
	add	di,80*4
	mov	cx,5
	rep	stosw
	mov	byte ptr es:[di],128+64
	pop	es
	ret

eol_cg:
	pop	dx
	pop	bx
	pop	es
	ret

ptxt:
	jmp	word ptr [jumptab+20]
ptxt_cont:

;text print routine for graphics modes
	;si points to text in ds
	;dl,dh = x,y of byte ? coords ? 0-39/0-199
;addr = y*80+x
;cga y coord only even ones
	push	es
	push	bx
	push	dx
	and	dh,254
	mov	al,dh	;y fool
	xor	ah,ah
	shl	ax,1
	shl	ax,1
	shl	ax,1;*16
	mov	bx,ax
	shl	ax,1;*32
	shl	ax,1;*64
	add	ax,bx
	xor	dh,dh
	add	ax,dx
	add	ax,dx	;2*x due 2 ega limitations !
	mov	di,ax	;dest
	mov	ax,0b800h
	mov	es,ax
;must get a bit map and expand to 4 colour !?
	MOV	BP,OFFSET CHAR_MAP
chc:
	lodsb
	or	al,al
	jz	eol_cg	
	push	di	;??
	mov	bx,bp
	sub	al,32
	xor	ah,ah
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	bx,ax
	xchg	bx,si
	mov	cx,4
bloop:
	lodsb
	mov	dl,al
;from byte create a word	
	rept 8
	silly
	endm
	XCHG	AL,AH
	stosw	;store the onverted word
	add	di,2000h-2
	lodsb
	mov	dl,al
;from byte create a word	
	rept	8
	silly	;8 timesa
	endm
	XCHG	AL,AH
	stosw	;store the onverted word
	add	di,80-2002h
	loop	bloopx
	mov	si,bx
;update di !
	pop	di
	add	di,2
	jmp	chc
bloopx:
	jmp	bloop
head_16:
	push	ds
	push	es
	push	bp
	mov	bx,0b800h
	mov	es,bx
	shl	di,1
	shl	di,1	;*4 for true addr?
	add	di,160*46
	mov	cx,16
	cli
	mov	sp_s,sp	;save the stack /pointer/segment
	mov	bx,ss
	mov	ss_s,bx
;have to disable the interrputs shit shit shit shit
	cmp	ax,2
	jne	ovway16
	mov	sp,[walk_dr_0f]
	mov	ax,[walk_dr_0f+2]
	mov	ss,ax
	mov	bx,32768+512
	jmp	lowd
ovway16:
	mov	sp,[walk_dr_0f]
	add	sp,576	;skip the 3 wide sprite
	mov	ax,[walk_dr_0f+2]
	mov	ss,ax
	mov	bx,32768+256
lowd:	lds	ax,[dum_ptr]	;get to the lut!
	;rem frame is 5 bytes wide and 48 long !
headlp16:
	REPT 8	;=16 pixels divvy !
	pop	ax
	mov	bl,al
	mov	al,ds:[bx]
	mov	bl,ah
	mov	ah,ds:[bx]
	stosW
	endm
	ADD	DI,2000H-16
	jns	skin
;cmp	di,32768
;jb	skin
	sub	di,32768-160
skin:	loop	headlp16
	mov	ax,seg dseg
	mov	ds,ax 
	mov	ax,ss_s
	mov	ss,ax
	mov	sp,sp_s
	sti
	pop	bp
	pop	es
	pop	ds
	ret

level_16:
;print the level indicator for a Tandy Screen layout.
	push	es
	mov	dx,cx
	shl	cx,1	
	shl	cx,1	
	shl	cx,1	
	shl	cx,1	
	or	dx,cx	;2*!
	mov	dl,dh	;4 pixels of colour !
	shl	di,1
	shl	di,1
	add	di,47*160
	mov	Cx,0b800h
	mov	es,Cx
	push	di
	mov	cx,6	;
	mov	bp,ax	;the count of filled chars
	or	bp,bp
	jnz	chtanlp
	mov	dx,0	; char is blank
chtanlp:
	mov	Ax,dx
	or	Ax,240	;assumes low/high store !
	tanmac	0
	tanmac	8192
	tanmac	16384
	tanmac	24576
	tanmac	0+160
	tanmac	8192+160
	tanmac	16384+160
	tanmac	24576+160
	add	di,4
	dec	bp
	ja	llll
	xor	dx,dx
llll:
	loop	chtanlp
	pop	di
	push	di
	sub	di,160-24576
	MOV	AX,-1	;STORE WHITE 
	mov	cx,10
	rep	stosw
	mov	byte ptr es:[di],240
	pop	di
	add	di,160*2
	mov	cx,10
	rep	stosw
	mov	byte ptr es:[di],240
	pop	es
	ret
eol_16:
	pop	dx
	pop	bx
	pop	es
	ret
ptxt_16:
;Tandy Text print routine ! 
;si points to text in ds
;dl,dh = x,y of byte ? coords ? 0-39/0-199
;addr = y*80+x
;cga y coord only even ones
	push	es
	push	bx
	push	dx
	mov	al,dh	;y fool
	xor	ah,ah
	shr	dh,1
	shr	dh,1
	and	al,252	;lose bottom two bits then *4 !
	add	al,dh	;+original value !
	adc	ah,0	;*5
	shl	ax,1	;*10
	shl	ax,1	;*20
	shl	ax,1	;*40
	xor	dh,dh
	add	ax,dx	;add here so the *4 is carried out
	shl	ax,1	;*80
	shl	ax,1	;*160
	mov	di,ax	;dest
	mov	ax,0b800h
	mov	es,ax
;must get a bit map and expand to 4 colour !?
	MOV	BP,OFFSET CHAR_MAP
chc16:
	lodsb
	or	al,al
	jz	eol_16	
	push	di	;??
	mov	bx,bp
	sub	al,32
	xor	ah,ah
	shl	ax,1
	shl	ax,1
	shl	ax,1
	add	bx,ax
	xchg	bx,si
	mov	cx,2
blp:
	lodsb
	mov	dl,al
;from byte create a word	
	shifty
	shifty
	add	di,8192-4
	lodsb
	mov	dl,al
	shifty
	shifty
	add	di,8192-4
	lodsb
	mov	dl,al
	shifty
	shifty
	add	di,8192-4
	lodsb
	mov	dl,al
	shifty
	shifty
	add	di,160-4-24576
	loop	bloop16
	mov	si,bx
;update di !
	pop	di
	add	di,4
	jmp	chc16
bloop16:
	jmp	blp


make_tabtan:
; make the flip table for Tandy version.

	if	vers eq vga

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
	mov	al,cl
	and	al,15
	shl	al,1
	shl	al,1
	shl	al,1
	shl	al,1
	shr	ah,1
	shr	ah,1
	shr	ah,1
	shr	ah,1
	and	ah,15
	or	al,ah
	stosb
	inc	cx
	cmp	cx,256
	jne	mk_lp

	pop	es
	pop	ds

	endif

	ret

flip_spr:

	if	vers eq vga

;	Sprite version no recolouring and no shifting
;	BUT that flips the sprite horizontally
;	oh good grief
	push	bp
	push	cx
	push	dx
	push	di
	push	bx
	push	ds
	push	es

	mov	ax,ss_save
	mov	ds,ax	;ds is the sprite data dippo !
	mov	ax,seg new_spr
	mov	es,ax
	mov	di,offset new_spr	;4k for the sprite ?
;destination of new sprite.
	mov	bx,offset flip_tab	;try this one !
	mov	es:spr_rows,dx
	cmp	dx,0
	jz	yanvrnw
	jcxz	yanvrnw
	inc	cx
	shr	cx,1	;i think theres a reason for this ?
	mov	bp,cx
	shl	bp,1
	shl	bp,1	;4 bytes per x col
row_lp:	add	di,bp	;move to right of this row ?!
	push	cx
byte_lp:sub	di,4
	lodsw
	mov	bl,al
	mov	al,es:[bx]
	mov	bl,ah
	mov	ah,es:[bx]
	xchg	al,ah
	mov	es:[di+2],ax
	lodsw
	mov	bl,ah
	mov	ah,es:[bx]
	mov	bl,al
	mov	al,es:[bx]
	xchg	al,ah
	mov	es:[di],ax
	loop	byte_lp
	pop	cx
	add	di,bp	;make up for last times subtractions ?!?
	dec	es:spr_rows
	jne	row_lp
yanvrnw:
	pop	es	;no reason ? so why bother >
	pop	ds
	mov	ax,seg new_spr
	mov	ss_save,ax
	mov	si,offset new_spr	;
	mov	data_ptr,si
	pop	bx
	pop	di
	pop	dx
	pop	cx
	pop	bp

	endif

	ret


;***************************************************************************
;		The Tandy sprite routine
;		think ill change this a bit so non-recolour
;		sprites dont need a null colour table.
;***************************************************************************


draw_sprt16:
		mov	di, offset sprt_x
		mov     cx,7
		rep     movsw
		push	si
;si is pointer to sprite data table (why is it pushed).
;1 get a screen_addr
		push	es
		mov	bled_bkgd_ptr,48000	;dummy value for no spr
		call	setup_sprt
	jp_c	offscreen
		MOV	CX,sprt_cols
		MOV	DX,sprt_rows
		MOV	SI,save_ptr
		MOV	bled_bkgd_ptr,di	;save for restbackground.
		mov	si,data_ptr

;********************************************
;	cx=sprt_cols	|  dx=row_loop
;********************************************

		test	flip_dir,left	;direction,left
		jz	no_flip
		call	flip_spr
no_flip:
		MOV	SI,save_ptr	;er ?
		CLI	;DISABLE INTERRUPTS
		mov	ax,ss
		XCHG	ax,SS_SAVE	;save SS and load sprite segment
		mov	ss,ax
		xchg	sp,sp_save
		MOV	SP,data_ptr	;get sprite data addr

	MOV	BP,COLR_MAP	;the recolor map hopefully !
;PUT DATA ES:DI INTO BUFFSEG !
	MOV	AX,SEG save_area
	MOV	ES,AX
	lds	ax,dum_ptr
	MOV	DS:[32768+1024+0],CX	;sprt_cols variable !
	MOV	DS:[32768+1024+2],DX	;row_loop counter
	mov	bx,32768	;this points to mask table !
		mov	dx,d_scrn_w/2
		sub	DX,CX
		SHL	DX,1	;subtract for back one
		MOV	DS:[32768+1024+4],DX
		cmp	bp,-1	;65535 denotes no recolour nesc
		jp_e	no_recol_vers
ROW_LOOP:	MOV	CX,DS:[32768+1024+0]	;sprt_cols
COL_LOOP:	mov	ax,Ds:[di]
		mov	ES:[SI],ax	;buffer the screen !
		add	si,2
		POP	DX	;get data !
		XCHG	BP,BX
		MOV	BL,DL
		MOV	DL,DS:[BX]
		MOV	BL,DH
		MOV	DH,DS:[BX]
		XCHG	BP,BX
		MOV	BL,DL
		AND	AL,DS:[BX]
		MOV	BL,DH
		AND	AH,DS:[BX]
		OR	AX,DX
		MOV	DS:[DI],AX
		ADD	DI,2
;STOSW	;put to screen ! SHITE !
		and	di,32767
		LOOP	COL_LOOP		
		add	DI,DS:[32768+1024+4]	;back due to words alr mved
		and	di,32767
		DEC	WORD PTR DS:[32768+1024+2]	;inefficient or what !
		JNE	ROW_LOOP	;inefficient or what !
		mov	ax,seg dseg
		mov	ds,ax
		mov	ax,ss_save
		mov	ss,ax
		mov	sp,sp_save
		sti
offscreen:
		POP	ES
		pop	di
		mov	si,offset bled_x
		mov	cx,9
	rep	movsw
		ret
;
;	Tandy routine seems to do 1 word ie 4 pixels at a time.
;	Should mean I can Jiff loop ? by factor of 1 ?

no_recol_vers:
	mov	bp,2	;how many free registers do I have !
ROW_LOOPx:	MOV	CX,DS:[32768+1024+0]	;sprt_cols
COL_LOOPx:	mov	ax,Ds:[di]	;
		mov	ES:[SI],ax	;buffer the screen !
		add	si,bp		;holds the value 2 !
		POP	DX	;get data ! 
		MOV	BL,DL		;
		AND	AL,DS:[BX]	;
		MOV	BL,DH		;
		AND	AH,DS:[BX]	; creating the mask !
		OR	AX,DX		;
		MOV	DS:[DI],AX	;
		ADD	DI,bp		; holds the value 2
		and	di,32767	; nb no=need check odd bounds
					; as 4 pix Tandy = 1 word .
					; min on scrolling etc !!
		LOOP	COL_LOOPx

		add	DI,DS:[32768+1024+4]	;back due to words alr mved
		and	di,32767
		DEC	WORD PTR DS:[32768+1024+2]	;inefficient or what !
		JNE	ROW_LOOPx	;inefficient or what !

		mov	ax,seg dseg
		mov	ds,ax
		mov	ax,ss_save
		mov	ss,ax
		mov	sp,sp_save
		sti
		POP	ES
		pop	di
		mov	si,offset bled_x
		mov	cx,9
	rep	movsw
		ret

undraw_sprt16:
		mov	di, offset sprt_cols
		add	si,4
		mov	cx,14
		rep	movsw
		push	es
		mov	si,save_ptr
		mov	di,bled_bkgd_ptr
		cmp	di,48000
		je	nospr
		les	ax,dum_ptr
		MOV	bx,sprt_rows
		MOV	CX,sprt_cols
		mov	ax,d_scrn_w
		mul	bx	;sprt_rows*d_scrn_w
		add	ax,di
		jns	quickdel
	MOV	BP,CX
	MOV	AX,SEG save_area
	MOV	DS,AX	;USE THE NEW BUFFER SEGMENT !
		mov	dx,d_scrn_w/2
		sub	dx,cx
		shl	dx,1
row_lupe:
		MOV	CX,BP
col_lupe:	movsW
		and	di,32767
		loop	col_lupe
		add	di,dx
		and	di,32767
		dec	bx
		jne	row_lupe
		mov	ax,seg dseg
		mov	ds,ax
nospr:		pop	es
		ret
quickdel:	;doesnt need to bleed
	MOV	AX,SEG save_area
	MOV	DS,AX
	MOV	BP,CX
		mov	dx,d_scrn_w/2
		sub	dx,cx
		shl	dx,1
row_lupeq:
		MOV	CX,BP
	rep	movsw
		add	di,dx
	;	and	di,32767
		dec	bx
		jne	row_lupeq
		mov	ax,seg dseg
		mov	ds,ax
		pop	es
		ret

setup_sprt:
;just gets address and returns in ES:DI

	test	flip_dir,left
	jz	not_face_left
	mov	al,spr_l_offs	;[bx+6]	;offset of sprt
	cbw			; -ve 
	shl	ax,1
	sub	sprt_x,ax	;lose last one
;add	ax,sprt_cols	;making new offset
;neg	ax	;want new -ve offset
;sar	ax,1	;good grief
	mov	ax,sprt_cols
;shr	ax,1
	sub	sprt_x,ax	;christ
not_face_left:
		mov	bx,sprt_x
		mov	cx,bx
		add	cx,8
		JS	OFFSCRN
		CMP	BX,60
		JG	OFFSCRN
		add	bx,window_topleft
		sub	bx,offset dummy_scrn
		shl	bx,1	;from cga to Tandy = *2
		mov	ax,sprt_y
		mov	cx,ax
		add	cx,sprt_rows
		JS	OFFSCRN
		CMP	AX,176
		JG	OFFSCRN
		mov	cX,d_scrn_w
		Imul	cX	;offset
		add	ax,bx	;screen addr !
		and	ax,32767
		MOV	DI,AX
		les	ax,dum_ptr
		clc
		ret
offscrn:	stc
		ret

;put text on screen at X,Y	dl,dh
;text at DS:SI
;all regs preserved
write_text:
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	mov	bh,0	;page 0
	mov	bl,3	;colour 3 and ored
	mov	cx,1
	mov	ah,2
	int	16	;move cursor to start of text !
chlp:
	lodsb
	cmp	al,0
	je	endtxt
	call	prchar	;put indiv char to scrn and update cursor ! 
	jmp	chlp
endtxt:
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret
prchar:
;machine dependant routine !
	mov	ah,14
	int	16
	ret

cseg		ends

buff_seg	segment public	'data'

extrn		save_area:word	;probably not used 
extrn		new_spr:word,flip_tab:word
extrn	spr_rows:word
buff_seg	ends

dseg		segment	public 'data'

extrn		bled_x:word, bled_y:word, bled_cols:word
extrn		bled_rows:word, sprt_table:word, ss_save:word
extrn		sprt_x:word,sprt_y:word,sprt_cols:word
extrn		sprt_rows:word,data_ptr:word,colr_map:word
extrn		save_ptr:word,bled_bkgd_ptr:word
extrn		dum_ptr:dword
extrn		dummy_scrn:word
extrn		ss_save:word
extrn		jumptab:word

sp_save		dw	0
ss_s		dw	0
sp_s		dw	0
		
extrn		window_topleft: word, window_top: word, window_left: word
extrn		scroll_flag: byte,sixteencol :byte
EXTRN		JUMPTAB:WORD,CHAR_MAP:WORD,player1_data:word
extrn		walk_dr_0f:word
extrn		player2_table:word
extrn		identity_table:word,flip_dir:word,spr_l_offs:byte
dseg		ends

end

