
;
;should be all ega handling routines for the game !
;

cseg		segment	public 'code'

PUBLIC		INIT_DUMMYega,DOWN_LOADega,SCROLL_Uega
public		sCROLL_Dega,SCROLL_Rega,SCROLL_Lega
public		head_ega,level_ega,ptxt_ega
PUBLIC		pnum,pscore
public		cvttxt,big_num

extrn		ptxt:near,strength_bar:near,head:near

assume		cs: cseg, ds: dseg
d_scrn_w	equ	36	;144/4
gap		equ	6	;24/4

include	ddeqfile

;       fuckin ace 8086 programming discovery !!
;rep	movs	byte ptr es:[si],byte ptr es:[di]
;       fuckin ace 8086 programming discovery !!

cvert	macro
; change from si being code to being address

	xchg	ax,si
	xchg	al,ah
	and	ah,1
	shl	ax,1	;2
	shl	ax,1	;4
	shl	ax,1	;8
	shl	ax,1	;16
	shl	ax,1	;32
	shl	ax,1	;64
	shl	ax,1	;128
	xchg	ax,si
;mov	si,512	;is there anybody there !
	endm

put_ch_plane:
	rept	15
	movsw
	add	di,bx
	endm
	movsw
	ret
put_ch_planew:
	AND	DI,CX	;?
	rept	15
	movsw	;dont need to check within byte ! phew !
	add	di,bx
	and	di,cx
	endm
	movsw
	ret
	
put_chiteega:
;get chite from address in SI and place at DI on screen.
;si points to chite di points to posn in dummy screen 0-8192
	push	es
	push	ds
	push	bx
; cvert	;already been done !
;assume ds points to dseg
	les	ax,dum_ptr
	lds	ax,chite_ptr
	mov	bx,d_scrn_w-2
	mov	bp,di		;store posn !
	cmp	di,8192-d_scrn_w*16
	ja	ch_wrap		;if chite needs wrap check then do so !
	call	put_ch_plane
	mov	di,bp
	mov	ax,es
	add	ax,8192/16
	mov	es,ax
	call	put_ch_plane
	mov	di,bp	;restore posn
	mov	ax,es
	add	ax,8192/16
	mov	es,ax
	call	put_ch_plane
	mov	di,bp	;restore posn
	mov	ax,es
	add	ax,8192/16
	mov	es,ax
	call	put_ch_plane
	pop	bx
	pop	ds
	pop	es
;grief should be 64 words now moved
	ret
ch_wrap:
	push	cx
	mov	cx,8191
	call	put_ch_planew
	mov	di,bp
	mov	ax,es
	add	ax,8192/16
	mov	es,ax
	call	put_ch_planew
	mov	di,bp	;restore posn
	mov	ax,es
	add	ax,8192/16
	mov	es,ax
	call	put_ch_planew
	mov	di,bp	;restore posn
	mov	ax,es
	add	ax,8192/16
	mov	es,ax
	call	put_ch_planew
	pop	cx
	pop	bx
	pop	ds
	pop	es
;grief should be 64 words now moved
	ret

head_ega:
	ret	;in case it gets called !

ptxt_ega:
;text print routine for graphics modes
	;si points to text in ds
	;dl,dh = x,y of byte ? coords ? 0-79/0-199
;addr = y*40+x

;ega version piece oh piss !
	push	es
	mov	ax,bscrn
	xor	ah,2	;flip screens ? DELETE LATER ! err why delete??
	mov	ax,0a000h	;one here !
	mov	es,ax	;destin of altering screen
;that ensures data always goes to back screen ! IE INVISIBLE !

	push	dx
	push	bx
	mov	al,dh
	xor	ah,ah
	shl	ax,1
	shl	ax,1
	shl	ax,1	;*8
	mov	bx,ax
	shl	ax,1
	shl	ax,1	;*32
	add	ax,bx	;*40
	xor	dh,dh
	add	ax,dx
	mov	di,ax	;= screen address
;set ega to write to ALL planes at once !
;could have colour choice via this line
; for effing vga black is now colour 14 ! 
	mov	colr,15	;!
	cmp	sixteencol,3
	jne	not_vg
	mov	colr,10	;white is 10 not 15
not_vg:	
	mov	ax,0f02h
	mov	dx,3c4h
	out	dx,ax	; set the sequencer reg. write mode is 0 ?
	mov	dx,3ceh	;controller
	mov	ax,0a05h
	out	dx,ax	;write mode 2 read mode 1
	mov	ax,03h	;er rmw bits
	out	dx,ax
	mov	ax,0007h
	out	dx,ax	;'dont care' for all colours

	push	bp
	mov	bp,offset char_map	;must reload each time
ech_lupe:
	mov	bx,bp	;must reload each time
	lodsb
;read character
	or	al,al
	jp_z	eol
	sub	al,32	;data starts at space but is cont from then
	xor	ah,ah
	shl	ax,1
	shl	ax,1
	shl	ax,1	;*8
	add	bx,ax
	push	si
	mov	si,bx
;	change the text routine to mask in the text I reckon !
;	 I hope that 1. will impress Nick 2. sort out the black problem !
;	note dx = 3c4h	hence is set up okay.

	mov	bl,colr
	xor	bh,bh
	mov	al,8	;mask register

	rept	7
	mov	ah,[si]
	inc	si
	out	dx,ax
	and	es:[di],bl	;byte !
;out	dx,ax
	and	es:[di+8192],bl
	not	ah
	out	dx,ax
	and	es:[di],bh
;out	dx,ax
	and	es:[di+8192],bh
	add	di,40
	endm

	mov	ah,[si]
	out	dx,ax
	and	es:[di],bl	;byte !
;out	dx,ax
	and	es:[di+8192],bl
	not	ah
	out	dx,ax
	and	es:[di],bh
;out	dx,ax
	and	es:[di+8192],bh
	sub	di,40*7-1
	pop	si

	jmp	ech_lupe
;@@@@@@@@@@@@@@@@@@@@@@@
eol:

	mov	ax,5
	out	dx,ax
	mov	ax,3
	out	dx,ax
	mov	ax,0ff08h
	out	dx,ax
	mov	ax,0f07h
	out	dx,ax	;some defaults

	pop	bp
	pop	bx
	pop	dx
	pop	es
	ret
level_ega:
;draw the level or strength bar for a particular player
; Entry ax=strength 0-160
;       di=x coord of the bar (characters)
;	cx=colour red or blue
;	set up using r_p/b_p/b_p/i_p
;	draw characters of colour then overlay with grid.
;	crikey will need diff colours if vga ! cor!

	cld
	push	es
	push	cx
	push	ax
	add	di,40*188	;posn at bottom of screen
	mov	bp,di
	mov	ax,bscrn
	mov	es,ax
	write	r_p+g_p+b_p+i_p ;white
	cmp	sixteencol,3
	jp_e	vga_level

	mov	al,128	;left most pixel
	mov	cx,6	;one more than blocks
grid_lp:
	stosb	;writes to correct bit plane !
xx=39
	rept	7
	mov	es:[di+xx],al
xx=xx+40
	endm		
	loop	grid_lp
	mov	di,bp
	sub	di,40	;on line above grid
	mov	ax,-1
	stosw
	stosw
	stosb	;=5 characters	
	mov	byte ptr es:[di],128
	add	di,40*9-5
	stosw
	stosw
	stosb
	mov	byte ptr es:[di],128
	mov	di,bp
	pop	cx	;get count
	pop	ax	; then colour gone into ah
	or	cx,cx	;is count zero ?
	je	nochar 
;now select colour for ega

	mov	al,2	;write to planes 
	mov	dx,3c4h
	out	dx,ax

	mov	ax,-1	;set all pixels
chblcklp:
	stosb	;writes to correct bit plane !
xx=39
	rept	7
	mov	es:[di+xx],al
xx=xx+40
	endm		
	loop	chblcklp
;thats the characters done now the grid
nochar:
	pop	es
	ret

vga_level:
;	Its a vga version only colours
;	background = 14
;	lhs one wants to be 12
;	rhs one wants to be 11
;	white is colour 10

	mov	ax,0402h	;i think that is totally wrong !
	mov	dx,3c4h
	out	dx,ax

	sub	di,1
	mov	al,254	;right most pixel now !

	stosb	;writes to correct bit plane !
xx=39
	rept	7
	mov	es:[di+xx],al
xx=xx+40
	endm		

	mov	ax,0f02h	;i think that is totally wrong !
	mov	dx,3c4h
	out	dx,ax
; clear out all the fucking shit 
	mov	cx,5
	mov	al,0	;or 255 cant think off hand !
alpxv:
	stosb	;writes to correct bit plane !
xx=39
	rept	7
	mov	es:[di+xx],al
xx=xx+40
	endm		
	loop	alpxv

	mov	ax,0402h	;i think that is totally wrong !
	mov	dx,3c4h
	out	dx,ax

	mov	al,127	;128	;left most pixel
;add	di,5
	stosb	;writes to correct bit plane !
xx=39
	rept	7
	mov	es:[di+xx],al
xx=xx+40
	endm		

	mov	di,bp
	sub	di,40	;on line above grid
	mov	ax,0	;-1
	stosw
	stosw
	stosb	;=5 characters	
	mov	byte ptr es:[di],127
	add	di,40*9-5
	stosw
	stosw
	stosb
	mov	byte ptr es:[di],127
	mov	di,bp
	pop	cx	;get count
	pop	ax	; then colour gone into ah
;	need to set indiv blocks , 
	mov	al,11
	cmp	ah,(i_p+r_p)/256
	jne	label57
	mov	al,12
label57:
	mov	ah,al
	mov	al,2	;write to planes 
	mov	dx,3c4h
	out	dx,ax

	mov	bp,5
	sub	bp,cx	;this is number of colour blocks
	mov	cx,5	;6 blocks wide
	mov	al,255	;do the rest of the pixels
;cmp	cx,bp
;jne	yetanotherlabel
;mov	ax,0e02h		;make it black man !
;out	dx,ax
;mov	al,255	;er ?
;yetanotherlabel:
chblcklpv:
	cmp	cx,bp
	jne	anotherlabel
	mov	ax,0e02h		;make it black man !
	out	dx,ax
	mov	al,255	;er ?
anotherlabel:
	mov	ah,byte ptr es:[di]	;set latches
	stosb	;writes to correct bit plane 
xx=39
	rept	7
	mov	ah,byte ptr es:[di+xx]	;set latches
	mov	es:[di+xx],al
xx=xx+40
	endm		
	loop	chblcklpv
nocharv:
	mov	ax,0ff08h	;change the mask
	mov	dx,3c4h
	out	dx,ax
	pop	es
	ret



INIT_DUMMYega:
	push	ds
	push	es
	push	bp
	push	bx
	
	mov	ax,seg dseg
	mov	ds,ax
	mov	ax,map_width
	shl	ax,1
	shl	ax,1
	add	ax,map_width
	shl	ax,1
	mov	map_width10,ax
	
	les	ax,dum_ptr
	xor	di,di
	mov	ax,di
	mov	cx,16384
rep	stosw	;first blank the screen !
	mov	ax,window_topleft
	sub	ax,offset dummy_scrn
	shr	ax,1
	sub	ax,d_scrn_w*16+2
	and	ax,8191
	mov	di,ax
	mov	chite_topleft,ax
;	mov	di,8192-d_scrn_w*16-2
;	mov	chite_topleft,di
	
	mov	bx,posn_in_map
	sub	bx,2
	sub	bx,map_width
	mov	cx,12
next_idega:	
	push	cx
	push	di
	call	disp_rowega
	add	bx,map_width
	pop	di
	pop	cx
	add	di,36*16
	and	di,8191
	loop	next_idega

	pop	bx
	pop	bp
	pop	es
	pop	ds
	ret


;puts 17 chites on to a row pointed to by di 
disp_rowega:
;rept	16
	mov	cx,16
ch_lp_a:
	push	cx
	mov	si,[bx]
	cvert
	add	bx,2
	push	di
	call	put_chiteega
	pop	di
	add	di,2
	and	di,8191
	pop	cx
	loop	ch_lp_a
;endm

;this assembles into a LOT of code !!  
;	not any more !!

	mov	si,[bx]
	cvert
	call	put_chiteega
	sub	bx,32	;restore effect of 16 incrememnts
	ret
disp_colega:
	push	bx
	sub	bx,map_width
	rept	11
	mov	si,[bx]
	cvert
	add	bx,map_width
	push	di
	call	put_chiteega
	pop	di
	add	di,d_scrn_w*16
	and	di,8191
	endm
	mov	si,[bx]
	cvert
	call	put_chiteega
	pop	bx
	ret
SCROLL_Uega:
		inc	scrn_top
		mov	ax,window_topleft
		add	ax,8*d_scrn_w
		sub	ax,offset dummy_scrn
		and	ax,16383
		add	ax,offset dummy_scrn
		mov	window_topleft,ax
;add	window_topleft,8*d_scrn_w	;oh eck !
;add	window_top,4
;cmp	window_top,176
;jl	over_u1
;sub	window_topleft,16384
;sub	window_top,176
over_u1:	add	posn_in_chr,16
		cmp	posn_in_chr,64
		jl	u_n_sc
		sub	posn_in_chr,64
		mov	bx,posn_in_map
		add	bx,map_width
		mov	posn_in_map,bx
		add	bx,map_width10
		mov	di,chite_topleft
		add	di,d_scrn_w*16
		and	di,8191
		mov	chite_topleft,di
		add	di,d_scrn_w*16*11
		and	di,8191
		sub	bx,2
		call	disp_rowega
u_n_sc:		mov	scroll_flag,1
		RET
scroll_dega:	dec	scrn_top
		mov	ax,window_topleft
		sub	ax,8*d_scrn_w
		sub	ax,offset dummy_scrn
		and	ax,16383
		add	ax,offset dummy_scrn
		mov	window_topleft,ax
;sub	window_topleft,8*d_scrn_w	;oh eck !
;sub	window_top,4
;JGE	OVERD_1
;ADD	WINDOW_TOPLEFT,16384	;length of buffer 
;add	window_top,176
overd_1:	sub	posn_in_chr,16
		jge	no_u_chite
		add	posn_in_chr,64
		sub	chite_topleft,16*d_scrn_w;up a chite 
		and	chite_topleft,8191
		mov	di,chite_topleft
		mov	bx,posn_in_map
		sub	bx,map_width
		mov	posn_in_map,bx
		sub	bx,2
		sub	bx,map_width
		call	disp_rowega
no_u_chite:	mov	scroll_flag,1
		RET
scroll_rega:
		dec	scrn_left
		mov	ax,window_topleft
		dec	ax
		sub	ax,offset dummy_scrn
		and	ax,16383
		add	ax,offset dummy_scrn
		mov	window_topleft,ax
;dec	window_topleft
;dec	window_left
;jge	over_sr1
;mov	window_left,59
;dec	window_top
;jge	over_sr1
;mov	window_topleft,offset dummy_scrn+16383		
;mov	window_top,175
over_sr1:
		mov	ax,window_topleft
		sub	ax,offset dummy_scrn
		test	ax,3
		jnz	n_l_c
		mov	di,chite_topleft
		sub	di,2
		and	di,8191
		mov	chite_topleft,di
		sub	posn_in_map,2
		mov	bx,posn_in_map
		sub	bx,2
		call	disp_colega
n_l_c:
		mov	scroll_flag,1
		ret
scroll_lega:
		inc	scrn_left
		push	window_topleft
		mov	ax,window_topleft
		inc	ax
		sub	ax,offset dummy_scrn
		and	ax,16383
		add	ax,offset dummy_scrn
		mov	window_topleft,ax

;inc	window_topleft
;inc	window_left
;cmp	window_left,60
;jl	over_sl1
;mov	window_left,0
;inc	window_top
;cmp	window_top,176
;jl	over_sl1
;mov	window_topleft,offset dummy_scrn
;mov	window_top,0
over_sl1:
		pop	ax
		test	ax,3	;every 4 bytes do a chite ?
;this is as screen is an assummed cga format ?
		jnz	no_lc
		mov	di,chite_topleft
		add	di,2	;real address !
		and	di,8191
		mov	chite_topleft,di
		add	di,d_scrn_w-gap
		and	di,8191
		mov	bx,posn_in_map
		add	bx,30	;15 characters to the right !
		call	disp_colega
		add	posn_in_map,2
no_lc: 
		mov	scroll_flag,1
		ret
		
; E.G.A download !
;flips screen downloading to.  
; In order to lessen the flicker 
; 
;Even though  scrolling is at 8 pixels
;being ega alignment is odd and even !
down_loadega:

	push	ds
	push	es
	push	bp
	push	bx
	push	dx

	not	flag

	mov	ax,0a000h
	mov	bx,32
	cmp	flag,0
	jne	as
	mov	ax,0a200h
	mov	bx,0
as:	mov	bscrn,ax
	mov	es,ax	;destin of altering screen
	mov	dx,3d4h
	mov	al,12
	out	dx,al
	mov	al,bl
	inc	dx
	out	dx,al
;ES pnts to write screen.displayed screen is also decided
;now download by doing each seperate bit plane
	mov	ax,5
	mov	dx,3ceh
	out	dx,ax	;write mode 0 move to screen

	mov	ax,window_topleft
	sub	ax,offset dummy_scrn
	shr	ax,1	;scroll half as accurate as cga !!!
	mov	si,ax	;si=0-8192 = start of dummy !

	lds	ax,dum_ptr	;point ds to dummy scrn
	mov	bp,ds

	mov	dx,3dah
w_fly:
	in	al,dx
	test	al,8
	jz	w_fly	;may have to wait until not fly_back.
w_n_fly:
	in	al,dx
	test	al,8
	jnz	w_n_fly	;waiting for not flyback as well .
			; is this source of problem??

;mov	si,0	;zero-ise the screen offset

	push	si
;mov	word ptr ds:[8191],-1
	write	r_p
	call	a_plane
	pop	si
	add	bp,8192/16
	mov	ds,bp

	push	si
	write	g_p
;mov	word ptr ds:[8191],-1
	call	a_plane
	add	bp,8192/16
	mov	ds,bp
	pop	si

	push	si
	write	b_p
;mov	word ptr ds:[8191],-1
	call	a_plane
	add	bp,8192/16
	mov	ds,bp
	pop	si

	write	i_p
;mov	word ptr ds:[8191],255
	call	a_plane

	border	0

	pop	dx
	pop	bx
	pop	bp
	pop	es
	pop	ds
	ret	
a_plane:
;a simpler routine for the download !
	mov	di,40*20+5
	mov	dx,160
wrplp:
	cmp	si,8192-d_scrn_w
	jae	awrapl
	mov	cx,15
rep	movsw
	add	si,gap
	add	di,40-30
	dec	dx
	jne	wrplp
	ret
awrapl:
	mov	cx,30
sllp:
	movsb
	and	si,8191
	loop	sllp
	dec	dx
	jz	rearlu
	add	di,40-30
	add	si,gap
	and	si,8191	;i think its needed ? 
wrplpx:
	mov	cx,15
rep	movsw
	add	si,gap
	and	si,8191
	add	di,40-30
	dec	dx
	jne	wrplpx
rearlu:
	ret	



big_ega:

	mov	ax,0a000h
	mov	es,ax
	mov	ax,seg big_chars
	mov	ds,ax
	
	mov	al,dh
	xor	ah,ah
	shl	ax,1
	shl	ax,1
	shl	ax,1;*8
	mov	di,ax
	shl	ax,1;
	shl	ax,1;*32
	xor	dh,dh
	add	ax,dx	;2*x due 2 ega limitations !
	add	di,ax	;dest
	mov	ax,5
	mov	dx,3ceh
	out	dx,ax	;write mode 0 move to screen

ch_lpe:
	lodsb	;load character
	or	al,al
	jnz	nuvchare
eofsh:
	jmp	eofchars
nuvchare:
;	got a char !
;	what is it ?
	cmp	al,255
	jp_e	time_vare

	cmp	al,32
	jne	norra_sp3
	push	si
	mov	si,offset sp_frigg
	jmp	space_here3
norra_sp3:
	sub	al,48
	jc	eofsh	;less than 48 ! ERROR
	cmp	al,9
	ja	eofsh	;more then 58 error
;	alright then do a character
	push	si
	xor	ah,ah
	shl	ax,1
	shl	ax,1	;*4
	shl	ax,1
	shl	ax,1
	shl	ax,1
	shl	ax,1	;*64
	mov	si,offset big_chars
	add	si,ax
space_here3:
vv=0
qq=0
	write	r_p
	rept	16
	mov	al,[si+qq]
	mov	es:[di+vv],al
	mov	es:[di+vv+2000h],al
	vv=vv+40
	qq=qq+4
	endm

	write	g_p
vv=0
qq=1
	rept	16
	mov	al,[si+qq]
	mov	es:[di+vv],al
	mov	es:[di+vv+2000H],al
	vv=vv+40
	qq=qq+4
	endm

	write	b_p
vv=0
qq=2
	rept	16
	mov	al,[si+qq]
	mov	es:[di+vv],al
	mov	es:[di+vv+2000H],al
	vv=vv+40
	qq=qq+4
	endm
	write	i_p
vv=0
qq=3
	rept	16
	mov	al,[si+qq]
	mov	es:[di+vv],al
	mov	es:[di+vv+2000H],al
	vv=vv+40
	qq=qq+4
	endm
	
	pop	si
	add	di,1
	jmp	ch_lpe

a_planex:
	push	si
	push	di
	push	cx
	mov	cx,16
alp_1:
	mov	al,[si]
	mov	es:[di],al
	mov	es:[di+2000h],al
	mov	al,[si+4]
	mov	es:[di+1],al
	mov	es:[di+2000h+1],al
	mov	al,[si+8]
	mov	es:[di+2],al
	mov	es:[di+2000h+2],al
	mov	al,[si+12]
	mov	es:[di+3],al
	mov	es:[di+2000h+3],al
	add	si,16
	add	di,40
	loop	alp_1
	pop	cx
	pop	di
	pop	si
	ret

time_vare:
	push	si

	mov	si,640+offset big_chars
	write	r_p
	call	a_planex
	inc	si

	write	g_p
	call	a_planex
	inc	si
	write	b_p
	call	a_planex
	inc	si
	write	i_p
	call	a_planex
	inc	si

	pop	si

	ret

bgtan:
	mov	ax,0b800h
	mov	es,ax
	
	mov	al,dh	;y value
	xor	ah,ah
	shr	ax,1	
	shr	ax,1	; div 4
; *160 + 8192 * y and 3
;mov	bh,dh
;and	bx,3*256	; y and 3 * 256
; must mul by 32 yet
	shl	ax,1	;*2 
	mov	bx,ax	;store *2
	shl	ax,1	;*4	32 = 128/4
	shl	ax,1	;*8 
	add	ax,bx	; hmm now mul by er 32 *10
	shl	ax,1
	shl	ax,1
	shl	ax,1
	shl	ax,1	; * 32 !

	xor	dh,dh	;clear out y address
	shl	dx,1
	shl	dx,1	; * 4 er ? think so ?
	mov	di,dx
	add	di,ax	; destination.

ch_lpt:
	lodsb	;load character
	or	al,al
	jp_z	eofchars
;	got a char !
;	what is it ?
	cmp	al,255
	jp_e	time_vart

	cmp	al,32
	jne	norra_sp2
	push	si
	mov	si,offset sp_frigg
	jmp	space_here2
norra_sp2:

	sub	al,48
	jp_c	eofchars	;less than 48 ! ERROR
	cmp	al,9
	jp_a	eofchars	;more then 58 error
;	alright then do a character
	push	si
	xor	ah,ah
	shl	ax,1
	shl	ax,1	;*4
	shl	ax,1
	shl	ax,1
	shl	ax,1
	shl	ax,1	;*64	 index character data.
	mov	si,offset big_chars
	add	si,ax
space_here2:
;	NO	ACCOUNT TAKEN OVER WHICH LINE STARTED ON
;	MUST ALWAYS BE ON l mod 4 = 0 !!!!!!!!1!!!!!!!!!
	
	rept	4
	movsw
	movsw
	add	di,8192-4
	movsw
	movsw
	add	di,8192-4
	movsw
	movsw
	add	di,8192-4
	movsw
	movsw
	sub	di,8192*3-156
;add	di,160
	endm

	pop	si
	add	di,4-160*4
	jmp	ch_lpt

time_vart:	;the slightly bigger thing that says time
	push	si
	mov	si,640+offset big_chars
	push	cx
	push	dx
	mov	dx,4
ti_lp:
	push	di

	rept	4
	local	no_t1
	mov	cx,8
	rep	movsw
	add	di,8192-16
;cmp	di,32768
	jns	no_t1	;> 32768 check
	sub	di,32768
no_t1:
	endm

	pop	di
	add	di,160
	dec	dx
	jp_ne	ti_lp
	pop	dx
	pop	cx
	pop	si
;	dont bother looping its just TIME

	ret

bgega:
	call	big_ega
	XOR	BSCRN,200H	;THIS GOES TO THE BACK SCREEN
	ret

big_num:
	XOR	BSCRN,200H
	cmp	byte ptr [si],255
	je	its_no_num
	push	ax
	call	cvttxt
	pop	ax
	and	ax,ax
	jnz	num_ps
	mov	byte ptr [number+8],"0"
num_ps:
	mov	byte ptr [number+9],0	;eol
its_no_num:
	cmp	sixteencol,2
	je	bgega
	cmp	sixteencol,1
	jp_e	bgtan
	cmp	sixteencol,3
	je	bgega
bgcga:
;	print the text (MUST BE CHARACTERS ONLY ?)
;	held at number
;	for TIME the code is a 255 !
;	DX = coords dh=y dx=x
;	SI = address of text
;

	mov	ax,0b800h
	mov	es,ax
	
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
	shl	dx,1
	add	ax,dx	;2*x due 2 ega limitations !
	mov	di,ax	;dest


ch_lp:
	lodsb	;load character
	or	al,al
	jp_z	eofchars
;	got a char !
;	what is it ?
	cmp	al,255
	jp_e	time_var

	cmp	al,32
	jne	norra_sp
	push	si
	mov	si,offset sp_frigg
	jmp	space_here
norra_sp:
	sub	al,48
	jp_c	eofchars	;less than 48 ! ERROR
	cmp	al,9
	jp_a	eofchars	;more then 58 error
;	alright then do a character
	push	si
	xor	ah,ah
	shl	ax,1
	shl	ax,1	;*4
	shl	ax,1
	shl	ax,1
	shl	ax,1	;*32
	mov	si,offset big_chars
	add	si,ax
space_here:
vv=0
	rept	8
	lodsw
	mov	es:[di+vv],ax
	lodsw
	mov	es:[di+8192+vv],ax
	vv=vv+80
	endm
	pop	si
	add	di,2
	jmp	ch_lp

time_var:	;the slightly bigger thing that says time
	push	si
	mov	si,320+offset big_chars
vv=0
	rept	8

	lodsw
	mov	es:[di+vv],ax
	lodsw
	mov	es:[di+vv+2],ax
	lodsw
	mov	es:[di+vv+4],ax
	lodsw
	mov	es:[di+vv+6],ax

	lodsw
	mov	es:[di+8192+vv],ax
	lodsw
	mov	es:[di+8194+vv],ax
	lodsw
	mov	es:[di+8196+vv],ax
	lodsw
	mov	es:[di+8198+vv],ax

	vv=vv+80
	endm
	pop	si
;	dont bother looping its just TIME
eofchars:
	ret



pscore:
	XOR	BSCRN,200H
	call	cvttxt
	mov	byte ptr [number+9],48	;ascii 0
	CALL	PTXT
	XOR	BSCRN,200H
	RET
pnum:
	XOR	BSCRN,200H
	push	ax
	call	cvttxt
	pop	ax
	and	ax,ax
	jnz	num_pos
	mov	byte ptr [number+8],"0"
num_pos:
	mov	byte ptr [number+9],0	;eol
	CALL	PTXT
	XOR	BSCRN,200H	;THIS GOES TO THE BACK SCREEN
	RET
	jmp	ptxt

cvttxt:
;special pnum appends a zero !
	push	dx
	push	cx	;strip value 
	mov	bx,ax
; convert cx,dx into a number for display
;4 bits at a time ?
	xor	ax,ax
	mov	word ptr [sum],ax
	mov	word ptr [sum+2],ax
	mov	word ptr [bcdval],ax
	mov	word ptr [bcdval+2],ax	;could be wrong ?
	mov	byte ptr [bcdval],1	;start the bcd at 1 2^0
	mov	cx,16	;digits (# 4 shifts !)
;number value in bx
dijits:
	shr	bx,1	;get bit value
	jnc	noadd	;a zero :- no addition !

	mov	al,byte ptr [bcdval]
	add	al,byte ptr [sum]
	daa	;put back to bcb !
	mov	byte ptr [sum],al	;2 digits
xx=1
	rept	3
	mov	al,byte ptr [bcdval+xx]
	adc	al,byte ptr [sum+xx]
	daa
	mov	byte ptr [sum+xx],al
	xx=xx+1
	endm
noadd:
	;double the bcd add value !
	mov	al,[bcdval]
	add	al,al
	daa	
	mov	[bcdval],al
xx=1
	rept	3
	mov	al,byte ptr [bcdval+xx]
	adc	al,al	;?
	daa
	mov	byte ptr [bcdval+xx],al
	xx=xx+1
	endm
	loop	dijits
;the number is now as packed decimal (no good !)
	mov	ax,seg dseg
	mov	es,ax	;just in case
	mov	di,offset number
	add	di,8	;maxmimum of digits  
	std	;dec on stosb ! 
;we need to split the packed decimal bits !
xx=0
	rept	4
	mov	bl,byte ptr [sum+xx]	;get each dual digit
	mov	al,bl
	and	al,15
	add	al,48
	stosb	;put low one 
	mov	al,bl
	shr	al,1
	shr	al,1
	shr	al,1
	shr	al,1
	add	al,48
	stosb	;put next one
xx=xx+1
	endm	
	cld	;shit	;???di should now be number-1 !
	inc	di	;??
	mov	si,di 	;!
squirrel:
	cmp	byte ptr ds:[di],48
	jne	noazero
	mov	byte ptr ds:[di],32
	inc	di
	jmp	squirrel
noazero:
	pop	cx
	add	si,8
	sub	si,cx	;??
	pop	dx
	ret
	
cseg		ends

dseg		segment	public 'data'

EXTRN	JUMPTAB:WORD,dum_ptr:dword,chite_ptr:dword
extrn	margin_buffer:word,char_map:word
extrn	dummy_scrn:word,chr_map:word,chr_blocks:word
extrn	window_topleft:word,window_top:word,window_left:word
extrn	posn_in_map:word,posn_in_chr:word,scrn_left:word,scrn_top:word
extrn	map_width:word,map_width10:word,chite_topleft:word,scroll_flag:byte
extrn	col:byte,sp_savedum:word,ss_savedum:word
extrn	timer:word,hi_score:word,big_chars:word

;extrn	bled_x:word, bled_y:word, bled_cols:word
;extrn	bled_rows:word, sprt_table:word, ss_save:word
;extrn	sprt_x:word,sprt_y:word,sprt_cols:word
;extrn	sprt_rows:word,data_ptr:word,colr_map:word
;extrn	save_area:word	;probably not used 
;extrn	save_ptr:word,bled_bkgd_ptr:word
;extrn	ss_save:word

extrn	sixteencol :byte,CHAR_MAP:WORD,player1_data:word
extrn	walk_dr_0f:word,walk_dr_0f:word,player2_table:word,identity_table:word
extrn	deljmptab:word
extrn	person_table:word

public	bscrn

sp_save		dw	0
ss_s		dw	0
sp_s		dw	0
flag	dw	0h	;displayed scrn sent to crtc.
number	db	"00000000",0,0,0
bscrn	dw	0a000h	;segment of other scrn
bcdval	db	0,0,0,0	;enough room for 8 digits of bcd
sum	db	0,0,0,0	;sum of the bcd parts 8 digit max !
colr	db	15
sp_frigg db 64 dup (0)	; shouldnt matter too much adding this to len of prg

dseg		ends

end
