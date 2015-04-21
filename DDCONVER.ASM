
cseg		segment	public 'code'

assume		cs: cseg, ds: dseg
public		options,load_tan,load_ega,load_cga,load_vga
public		reload,level5_reload,cvert,cvertx,bbw_reload

extrn		load:near,set_up:near,write_text:near
extrn		enemy1_rout : near , player1_rout: near , player2_rout:near
extrn		babobo_rout : near , enemy2_rout : near , enemy3_rout :near
extrn		gabobo_rout : near , roper_rout  : near
extrn		vgaplayer2_rout:near,vgaroper_rout:near,vgaghost_rout:near
extrn		decomp:near,insert_disk1:near
extrn		goal_snd:near
extrn		ptxt_cont:near,load_error:near

EXTRN		UNDRAW_CONT:NEAR,DRAW_CONT:NEAR
EXTRN		SCROLLU_CONT:NEAR,SCROLLD_CONT:NEAR
EXTRN		SCROLLL_CONT:NEAR,SCROLLR_CONT:NEAR
EXTRN		DOWNLOAD_CONT:NEAR,INIT_CONT:NEAR
EXTRN		UNDRAW_SPRT16:NEAR,DRAW_SPRT16:NEAR
EXTRN		SCROLL_U16:NEAR,SCROLL_D16:NEAR
EXTRN		SCROLL_L16:NEAR,SCROLL_R16:NEAR
EXTRN		DOWN_LOAD16:NEAR,INIT_DUMMY16:NEAR
EXTRN		UNDRAW_SPRTEGA:NEAR,DRAW_SPRTEGA:NEAR
EXTRN		SCROLL_UEGA:NEAR,SCROLL_DEGA:NEAR
EXTRN		SCROLL_LEGA:NEAR,SCROLL_REGA:NEAR
EXTRN		DOWN_LOADEGA:NEAR,INIT_DUMMYEGA:NEAR
extrn		head_ega:near,level_ega:near,ptxt_ega:near
extrn		head_16:near,level_16:near,ptxt_16:near
extrn		head_cont:near,level_cont:near,ptxt_cont:near
extrn		init_sticks:near

include		ddeqfile

convrt	macro	addr,leng

	push	ds
	push	es
	push	si
	push	di

	mov	ax,seg addr
	mov	es,ax
	mov	di,offset addr
	mov	cx,leng
	call	cv_data

	pop	di
	pop	si
	pop	es
	pop	ds
	endm


multi_load	macro	cnt,dest
	local	no_lod,n_err,retrys
	pushall
	mov	ax,[bx+cnt]	;the pntr to file needed
	cmp	ax,[cnt+offset in_memory]	;check what is in !
	je	no_lod	;if the same then dont load it !
	mov	word ptr [cnt+offset in_memory],ax	;store this !
	add	ax,si	;si is base of the table
	mov	bx,ax	;now to get offset of file_name
	mov	start_seg,seg dest
	mov	start_offset,offset dest
retrys:
	push	bx
	mov	bx,[bx]
	mov	file_name,bx	;read from correct file_name table
	call	load
	pop	bx	; it points to the files list

	cmp	errfl,0
	je	n_err
	mov	ax,g_disc
	call	load_error
	jmp	retrys
n_err:
	cmp	sixteencol,1	;is it tandy version
	jne	no_lod
	mov	ax,seg dest
	mov	es,ax
	mov	di,offset dest
	mov	cx,len		;use the fact delzw has the length !!!
	call	cvert	;just call the bloody routine !
no_lod:	popall

	endm

; must find out the lengths of all the files that must be loaded !

level5_reload:
;	fix this by calling the level  , 6 !

	mov	mission,6
	call	reload
	mov	mission,5
	ret

bbw_reload:
	mov	mission,7
	call	reload		;load up the big boss willy .
	mov	mission,5
	ret

reload:
;	the reloading of the sprite data after every level

	pushall
	
	mov	bl,mission
	sub	bl,1	;make it 0-4 not 1-5
	xor	bh,bh
	shl	bx,1	;index to words ! One assumes that level has changed
;	also does it go 0-4 or 1-5 ???
	mov	bx,[bx+offset level_files]	;point to file data
	mov	si,offset cgafiles
	cmp	sixteencol,0
	je	not_16
	mov	si,offset vgafiles
	cmp	sixteencol,3
	je	not_16	;( rename its vga )
	mov	si,offset egafiles
not_16:

	if	vers eq vga
	multi_load	0,lin_dat
	multi_load	2,wil_dat
	multi_load	4,capt_dat
;multi_load	6,abo_dat	; no need for dave he is always in.
	multi_load	8,bill_dat
	multi_load	10,wep_dat
	else
	multi_load	0,wil_dat
	multi_load	2,wep_dat
	endif

	popall
	ret


LOAD_TAN:

	if	vers eq vga

	pushall
	mov	ax,seg dseg
	mov	ds,ax
	load_m	char_map , chset_file , g_disc	;binary no need to convert.
	load_mtan  big_chars , chf_ega , g_disc	;graphics so convert
	load_mtan  abo_dat , abobo_eg1 , g_disc	;convert first
	load_mtan  pl1_dat1 , player1_ega1 , g_disc	;convert first
;call	insert_disk1	; 
	mov	g_disc,2	;ega graphics disc

	MOV	AX,SEG DSEG
	MOV	ES,AX
	MOV	DS,AX

	les	di,dum_ptr
	MOV	di,32768	;posn for lut of colour and mask ?
	xor	dx,dx
	mov	cx,256
mask_lupe:
	xor	ax,ax
	test	dX,15
	JZ	LAV1
	MOV	AX,15
LAV1:	TEST	DX,240	;test top 4 bits
	JZ	LAV2	;all zero so leave
	or	ax,240
lav2:	not	ax
	stosb
	inc	dx
	loop	mask_lupe
	mov	di,32768+256
	mov	bx,offset pl2_tab	;
	call	convert
	mov	di,32768+512
	mov	bx,offset roper_tab	;
	call	convert
	mov	di,32768+768
	mov	bx,offset ghost_tab
	call	convert

	mov	ax,seg dseg
	mov	es,ax
	mov	ds,ax
	mov	di,offset colrmap_table
	mov	ax,-1
	stosw	;0-player1	?
	stosw	;1	;williams
	stosw	;2	;abobo
	stosw 	;3	;Linda
	stosw	;4	;Big Boss Willie
	mov	ax,offset pl2_recol
	stosw	;5	player2
	mov	ax,-1
	stosw	;6	wil_a
	stosw	;7	wil_b
	stosw	;8	wil_c
	stosw	;9	abobo_a
	stosw	;10	abobo_b
	mov	ax,offset roper_recol
	stosw	;11	roper Shite	; how can it kock stuffup then ??
	mov	ax,-1
	stosw	;12	captain	
	stosw	;13	bill
	stosw	;14	lowry
	stosw	;15	cap_A
	stosw	;16	cap_b
	stosw	;17	cap_c
	stosw	;18	fatty
	stosw	;19	weapons

	mov	ax,offset ghost_recol
	stosw	;20	roper_b/ghost !

	call	change_jmps
	mov	ax,seg dseg
	mov	ds,ax
	MOV	[GMODE],9
	call	downloadtable
	popall

	endif

	RET

LOAD_EGA:

	if	vers eq vga

	pushall
	mov	ax,seg dseg
	mov	ds,ax
	load_m	char_map, chset_file , g_disc
	load_m	big_chars, chf_ega , g_disc
	load_m  abo_dat	   , abobo_eg1 , g_disc
	load_m	pl1_dat1   ,  player1_ega1 , g_disc
;call	insert_disk1
	mov	g_disc,2	;ega graphics disc is now wanted !

	mov	ax,seg dseg
	mov	es,ax
	mov	ds,ax
	mov	di,offset colrmap_table
	mov	ax,offset cs:player1_rout
	stosw	;0-player1	?
;mov	ax,offset cs:player1_rout
	stosw	;1	;williams
;mov	ax,offset cs:player1_rout
	stosw	;2	;abobo
;mov	ax,offset cs:player1_rout
	stosw 	;3	;Linda
;mov	ax,offset cs:player1_rout
	stosw	;4	;Big Boss Willie
	mov	ax,offset cs:player2_rout
	stosw	;5	player2
	mov	ax,offset cs:player1_rout	;enemy1_rout
	stosw	;6	wil_a
;mov	ax,offset cs:enemy2_rout
	stosw	;7	wil_b
;mov	ax,offset cs:enemy3_rout
	stosw	;8	wil_c
;mov	ax,offset cs:babobo_rout
	stosw	;9	abobo_a
;mov	ax,offset cs:gabobo_rout
	stosw	;10	abobo_b
	mov	ax,offset cs:roper_rout	;oh hell roper  !?!
	stosw	;11	roper Shite	; how can it kock stuffup then ??
	mov	ax,offset cs:player1_rout	;enemy1_rout
	stosw	;12	captain	
	stosw	;13	bill
	stosw	;14	lowry
	stosw	;15	cap_A
	stosw	;16	cap_b
	stosw	;17	cap_c
	stosw	;18	fatty
	stosw	;19	weapons

	mov	ax,offset cs:babobo_rout
	stosw	;20	roper_b/ghost !

	call	change_jmps
	mov	ax,seg dseg
	mov	ds,ax
	MOV	[GMODE],13
	call	downloadtable
	popall

	endif

	RET

LOAD_VGA:

	if	vers eq vga

	pushall
	mov	ax,seg dseg
	mov	ds,ax
	load_m	char_map, chset_file , g_disc
	load_m	big_chars, chf_vga , g_disc
	load_m	pl1_dat1   ,  player1_vga1 , g_disc

;call	insert_disk1
	mov	g_disc,3	;vga grafix disc now wanted
	load_m	abo_dat	   ,  abobo_vg1 , g_disc

	mov	ax,seg dseg
	mov	es,ax
	mov	ds,ax
	mov	di,offset colrmap_table
	mov	ax,offset cs:player1_rout
	stosw	;0-player1	?
;mov	ax,offset cs:player1_rout
	stosw	;1	;williams
;mov	ax,offset cs:player1_rout
	stosw	;2	;abobo
;mov	ax,offset cs:player1_rout
	stosw 	;3	;Linda
;mov	ax,offset cs:player1_rout
	stosw	;4	;Big Boss Willie
	mov	ax,offset cs:vgaplayer2_rout
	stosw	;5	player2
	mov	ax,offset cs:player1_rout	;enemy1_rout
	stosw	;6	wil_a
;mov	ax,offset cs:enemy2_rout
	stosw	;7	wil_b
;mov	ax,offset cs:enemy3_rout
	stosw	;8	wil_c
;mov	ax,offset cs:babobo_rout
	stosw	;9	abobo_a
;mov	ax,offset cs:gabobo_rout
	stosw	;10	abobo_b
	mov	ax,offset cs:vgaroper_rout	;oh hell roper  !?!
	stosw	;11	roper Shite	; how can it kock stuffup then ??
	mov	ax,offset cs:player1_rout	;enemy1_rout
	stosw	;12	captain	
	stosw	;13	bill
	stosw	;14	lowry
	stosw	;15	cap_A
	stosw	;16	cap_b
	stosw	;17	cap_c
	stosw	;18	fatty
	stosw	;19	weapons
;mov	ax,offset cs:vgaghost_rout
	stosw	;20	roper_b/ghost !	vga ghost is recoloured and moved !

	call	change_jmps
	mov	ax,seg dseg
	mov	ds,ax
	MOV	[GMODE],13	;is actually the same mode!
	call	downloadtable
	popall

	endif

	RET

LOAD_CGA:
	pushall
	mov	ax,seg dseg
	mov	ds,ax

	if	vers eq cga
;call	insert_disk1	; all on same disc again.	
	endif			; only change disc if its the cga version
;border	10
	load_m	big_chars , chf_cga , g_disc
;border	1
	load_m	char_map , chset_file , g_disc
	load_m	pl1_dat1 , player1_file1 , g_disc	; problem easier.

	if	vers eq vga	;only on this version !
	load_m	abo_dat , abobo_file1 , g_disc	; problem easier.
	endif

	mov	g_disc,1	;cga grafix

	popall
	mov	ax,seg dseg
	mov	ds,ax
	MOV	[GMODE],5
	RET

cvert:
; convert at es:di cx word of ega data to Tandy
; ega is ---- 1 byte of consec. red/green/blue/intensity
	shr	cx,1
	shr	cx,1
plains:	mov	bx,es:[di+2]
	mov	dx,es:[di]
	xchg	bh,dl
	xchg	bl,dh
	rept	2
		rept	4
		shl	dl,1
		rcl	ax,1
		shl	dh,1
		rcl	ax,1
		shl	bl,1
		rcl	ax,1
		shl	bh,1
		rcl	ax,1
		endm
	xchg	al,ah
	stosw
	endm
	loop	playnes
	ret
playnes:jmp	plains

cvertx:
	push	ds
	lds	si,dum_ptr	; point to the dummy screen.
	shr	cx,1
	shr	cx,1
;shr	cx,1	;/2
;shr	cx,1	;4
	shr	cx,1	;8
	shr	cx,1	;16
	shr	cx,1	;32
	shr	cx,1	;64
	shr	cx,1	;128	;hmm divide into chites ?
ch_lp:
	call	a_chite
	add	di,128	;move source to next chite !
	loop	ch_lp
	pop	ds
	ret

a_chite:
	push	si
	push	cx
	push	di
;	first shift the memory and save it to ds:si
;	then move using movsw back to es:[di]
	mov	cx,32	;number of 8 pix quads
plainsx:
	mov	dl,es:[di+96]
	mov	dh,es:[di+64]	; hmm ? swapped what I think is green/red !
	mov	bl,es:[di+32]	; and now swapped i/b
	mov	bh,es:[di]
	add	di,1
	rept	2
	rept	4
	shl	dl,1
	rcl	ax,1
	shl	dh,1
	rcl	ax,1
	shl	bl,1
	rcl	ax,1
	shl	bh,1
	rcl	ax,1
	endm
	xchg	al,ah
	mov	ds:[si],ax
	add	si,2
	endm
;inc	si		;add	si,1
	loop	playnesx
	mov	cx,64
	sub	di,32
	sub	si,128
rep	movsw	;store back !
	pop	di
	pop	cx
	pop	si
	ret
playnesx:jmp	plainsx


convert:
	xor	dx,dx
	mov	cx,256
CT_lupe:
	MOV	AX,DX
	AND	AX,15	;low colour
	xlat
	mov	bp,ax
	mov	ax,dx
	shr	ax,1
	shr	ax,1
	shr	ax,1
	shr	ax,1;/16
	and	ax,15
	xlat
	shl	ax,1
	shl	ax,1
	shl	ax,1
	shl	ax,1
	or	ax,bp
	stosb
	inc	dx
	loop	CT_lupe
	ret

OPTIONS:
;choose the display adapter and get flag
;SIXTEENCOL
;	1-cga
;	2-Tandy 16 colour
;	3-EGA version.
;	4-VGA version.
;
	if	vers eq vga

		mov	si,offset dd_mess
		mov	dx,8*256+20
		call	write_text

		mov	si,offset cga_card
		mov	dx,12*256+20
		call	write_text

		mov	si,offset tandy_1000
		mov	dx,14*256+20
		call	write_text

		mov	si,offset ega_card
		mov	dx,16*256+20
		call	write_text

		mov	si,offset vga_card
		mov	dx,18*256+20
		call	write_text

rep2:
	mov	ah,0
	int	22	;wait for key	
	
	cmp	al,49		; kill so that only EGA version
	je	cga_chose	;
	cmp	al,50		; can be chosen.
	je	tan_chose	;
	cmp	al,51
	je	ega_chose
	cmp	al,52
	je	vga_chose
	jmp	rep2

	else

	jmp	cga_chose

	endif


tan_chose:
	mov     byte ptr sixteencol,1
	jmp	contrls
cga_chose:
	mov     byte ptr sixteencol,0
	jmp	contrls
ega_chose:
	mov     byte ptr sixteencol,2
	jmp	contrls
vga_chose:
	mov     byte ptr sixteencol,3
	jmp	contrls


contrls:
;	Now this selects if a jostick card is needed by the user

	mov	ax,2
	int	16	;clear screen

	mov	si,offset joy_mess
	mov	dx,12*256+12
	call	write_text

	mov	si,offset key_mess
	mov	dx,16*256+12
	call	write_text
try_chse:
	mov	ah,0
	int	22	;read a key message
	cmp	al,"J"
	je	joy_choose
	cmp	al,"j"
	je	joy_choose
	cmp	al,"k"
	je	key_choose	;no joystick
	cmp	al,"K"
	je	key_choose	;no joystick
	
	jmp	try_chse


joy_choose:
	mov	nojoyflag,0
	call	init_sticks
	ret

key_choose:
	ret	;no change default is none.

CHANGE_JMPS:
;change the jump table for 16 colour game
	mov	ax,seg dseg
	mov	ds,ax
	mov	es,ax
	cmp	sixteencol,0
	je	nsc
	mov	bx,offset zetables
	mov	al,sixteencol
	xor	ah,ah
	shl	ax,1	;*2 due to words
	add	bx,ax
	mov	si,[bx]		;load the table value

	MOV	DI,OFFSET jumptab
	MOV	CX,11	;11 0-20 !
REP	MOVSW
NSC:
	RET

downloadtable:
;download the secondary animation table data !
; move bytes from tabstart1 to walk_dr_0f
; until tabend1

	push	ds
	push	es

	mov	ax,seg walk_dr_0f
	mov	ds,ax
	mov	si,offset walk_dr_0f
	mov	di,offset lastfrm1
	call	doub_sub

	mov	ax,seg p_null_0f	;colaps_l_1f
	mov	ds,ax
	mov	si,offset p_null_0f	;colaps_l_1f
	mov	di,offset lastfrm2
	call	doub_sub

	mov	ax,seg null_0f
	mov	ds,ax
	mov	si,offset null_0f
	mov	di,offset wepend

daveslabel:
	shl	word ptr [si],1
	add	si,6	;why make weapons different (how daft !)
	cmp	si,di
	jl	daveslabel

	pop	es
	pop	ds
	ret

doub_sub:
;down load from ds:si to es:di cx=tabend
	shl	word ptr [si],1
	add	si,8
	cmp	si,di
	jne	doub_sub
	ret


cseg		ends


extrn		pl1_dat1:word,wil_dat:word
extrn		lin_dat:word,abo_dat:word,wep_dat:word
extrn		capt_dat:word,bill_dat:word,errfl:word

extrn		mask_tabtan:word,pl2_recol:word,roper_recol:word,ghost_recol:word
; addresses of the new recolour table addresses ( in dummy segment )

dseg		segment	public 'data'

public		jumptab,vga_col_table

extrn		lastfrm1:word,lastfrm2:word,wepend:word
extrn		mission:byte,nojoyflag:word

extrn		club_0f:word,colaps_l_1f:word,walk_dr_0f:word
extrn		p_null_0f:word,null_0f:word
extrn		file_name:word,gmode:word
extrn		chr_blocks:word,chite_ptr:dword,dum_ptr:dword
extrn		start_seg:word,start_offset:word
extrn		sixteencol:byte,colrmap_table:word
extrn		char_map:word
extrn		screen:word,big_chars:word,g_disc:word

extrn	len:word		;used by save and set by LOAD

joy_mess	db	" J  : Joystick.",0
key_mess	db	" K  : Keyboard.",0

williams_eg1	db	"cartwhl.cpe",0
williams_vg1	db	"cartwhl.cpv",0
williams_file1	db	"cartwhl.cpc",0
linda_eg1	db	"bitch.cpe",0
linda_vg1	db	"bitch.cpv",0
linda_file1	db	"bitch.cpc",0
abobo_eg1	db	"bigdave.cpe",0
abobo_vg1	db	"bigdave.cpv",0
abobo_file1	db	"bigdave.cpc",0
player1_ega1	db	"player.cpe",0
player1_vga1	db	"player.cpv",0
player1_file1	db	"player.cpc",0
chset_file	db	"CHARSET.BIN",0
chf_vga		db	"chars.cpv",0
chf_ega		db	"chars.cpe",0
chf_cga		db	"chars.cpc",0
weapons_file1	db	"weapons.cpc",0
weapon_ega1	db	"weapons.cpe",0
weapon_vga1	db	"weapons.cpv",0
wep5_vga	db	"lvl5.cpv",0
wep5_ega	db	"lvl5.cpe",0
wep5_cga	db	"lvl5.cpc",0
wep3_ega	db	"lvl3.cpe",0
wep3_cga	db	"lvl3.cpc",0
wep3_vga	db	"lvl3.cpv",0
boss_file1	db	"bbw.cpc",0
boss_eg1	db	"bbw.cpe",0
boss_vg1	db	"bbw.cpv",0
captain_vga	db	"captain.cpv",0
captain_ega	db	"captain.cpe",0
captain_cga	db	"captain.cpc",0	
bill_vga	db	"bill.cpv",0
bill_ega	db	"bill.cpe",0
bill_cga	db	"bill.cpc",0	
fat_cga		db	"fatty.cpc",0
fat_ega		db	"fatty.cpe",0
fat_vga		db	"fatty.cpv",0
lowry_cga	db	"lowry.cpc",0
lowry_ega	db	"lowry.cpe",0
lowry_vga	db	"lowry.cpv",0

;hmm need some sort of reload data and data held to signify which baddies
; are currently in memory.
;
;	those will need to be equates

;	Possible filenames

lin_file	equ	0	;indexes into the f_name table
wil_file	equ	2
cap_file	equ	4
dav_file	equ	6
bil_file	equ	8
fat_file	equ	10
bbw_file	equ	12
low_file	equ	14
wep_file	equ	16
lvl3_file	equ	18
lvl5_file	equ	20

egafiles	label	word	;a list of multiload type files (baddies)
		dw	offset	linda_eg1
		dw	offset	williams_eg1
		dw	offset	captain_ega
		dw	offset	abobo_eg1
		dw	offset	bill_ega
		dw	offset	fat_ega
		dw	offset	boss_eg1
		dw	offset	lowry_ega
		dw	offset	weapon_ega1
		dw	offset	wep3_ega
		dw	offset	wep5_ega

vgafiles	label	word	;a list of multiload type files (baddies)
		dw	offset	linda_vg1
		dw	offset	williams_vg1
		dw	offset	captain_vga
		dw	offset	abobo_vg1
		dw	offset	bill_vga
		dw	offset	fat_vga
		dw	offset	boss_vg1
		dw	offset	lowry_vga
		dw	offset	weapon_vga1
		dw	offset	wep3_vga
		dw	offset	wep5_vga

cgafiles	label	word
		dw	offset	linda_file1
		dw	offset	williams_file1
		dw	offset	captain_cga
		dw	offset	abobo_file1
		dw	offset	bill_cga
		dw	offset	fat_cga
		dw	offset	boss_file1
		dw	offset	lowry_cga
		dw	offset	weapons_file1
		dw	offset	wep3_cga
		dw	offset	wep5_cga

;	data for linda seg , wil_seg , cap seg , abobo seg , bill seg

in_memory	dw	-1,-1,-1,-1,-1,

level_files	dw	lev1_fls,lev2_fls,lev3_fls,lev4_fls,lev5_fls,lev6_fls,lev7_fls
;	call the reload level6 ? just for simplicity
; need never multi load big dave !! just load at the start on all vers.
; could move linda as well ?!

	if	vers eq vga
lev1_fls	dw	lin_file , wil_file , cap_file , dav_file , bil_file ,wep_file
lev2_fls	dw	lin_file , wil_file , cap_file , dav_file , fat_file ,wep_file
lev3_fls	dw	lin_file , wil_file , cap_file , dav_file , bil_file ,lvl3_file
lev4_fls	dw	lin_file , wil_file , low_file , dav_file , bil_file ,wep_file	;dont need one really!
lev5_fls	dw	lin_file , wil_file , low_file , dav_file , bil_file ,lvl5_file
lev6_fls	dw	lin_file , bbw_file , low_file , dav_file , fat_file ,lvl5_file
lev7_fls	dw	lin_file , bbw_file , low_file , dav_file , fat_file ,lvl5_file
	else
lev1_fls	dw	wil_file , wep_file
lev2_fls	dw	wil_file , wep_file
lev3_fls	dw	wil_file , lvl3_file
lev4_fls	dw	low_file , wep_file	;dont need one really!
lev5_fls	dw	wil_file , lvl5_file
lev6_fls	dw	low_file , lvl5_file
lev7_fls	dw	bbw_file , lvl5_file	; for multiload lvl5 !
	endif

;	level 5 needs to load bbw over williams || fatty over bill

pl2_tab		DB	0,8,2,3		;  colour 0,1,2,3   become
		db	4,5,6,7		;  colour 4,5,6,7   become
		db	8,7,10,11 	; colour 8,9,10,11  become
		db	12,13,14,15	;colour 12,13,14,15 become
;	makes the blues into greys.
roper_tab	DB	0,2,2,3		;  colour 0,1,2,3   become
		db	4,5,6,7		;  colour 4,5,6,7   become
		db	8,10,10,11	; colour 8,9,10,11  become
		db	12,13,14,15	;colour 12,13,14,15 become
; 	makes the blues into greens.
ghost_tab	DB	0,5,2,3		;  colour 0,1,2,3   become
		db	4,5,5,7		;  colour 4,5,6,7   become
		db	8,13,10,11	; colour 8,9,10,11  become
		db	12,13,14,15	;colour 12,13,14,15 become
;	makes the blues into magentas.

dd_mess		db	"Double Dragon II ",0

cga_card	db	"1: CGA  4 colours . ",0
tandy_1000	db	"2: Tandy 1000 16 colours .",0
ega_card        db      "3: EGA  16 Colours .",0
vga_card        db      "4: VGA  16 Colours Extended Pallette .",0

zetables	dw	jumptab,jtab16,jtabega,jtabvga


JUMPTAB	DW	OFFSET UNDRAW_CONT	;0
	DW	OFFSET DRAW_CONT	;2
	DW	OFFSET SCROLLU_CONT	;4
	DW	OFFSET SCROLLD_CONT	;6
	DW	OFFSET SCROLLL_CONT	;8
	DW	OFFSET SCROLLR_CONT	;10
	DW	OFFSET DOWNLOAD_CONT	;12
	DW	OFFSET INIT_CONT	;14
	dw	offset head_cont	;16
	dw	offset level_cont	;18
	dw	offset ptxt_cont	;20

JTAB16	label	word

	DW	OFFSET UNDRAW_SPRT16
	DW	OFFSET DRAW_SPRT16
	DW	OFFSET SCROLL_U16
	DW	OFFSET SCROLL_D16
	DW	OFFSET SCROLL_L16
	DW	OFFSET SCROLL_R16
	DW	OFFSET DOWN_LOAD16
	DW	OFFSET INIT_DUMMY16
	dw	offset head_16	;16
	dw	offset level_16	;18
	dw	offset ptxt_16	;20

JTABEGA	label	word

	if	vers eq vga
	DW	OFFSET UNDRAW_SPRTEGA
	DW	OFFSET DRAW_SPRTEGA
	DW	OFFSET SCROLL_UEGA
	DW	OFFSET SCROLL_DEGA
	DW	OFFSET SCROLL_LEGA
	DW	OFFSET SCROLL_REGA
	DW	OFFSET DOWN_LOADEGA
	DW	OFFSET INIT_DUMMYEGA
	dw	offset head_ega	;16
	dw	offset level_ega	;18
	dw	offset ptxt_ega	;20
	endif

JTABVGA	label	word

	if	vers eq vga
	DW	OFFSET UNDRAW_SPRTEGA	;its the new one !
	DW	OFFSET DRAW_SPRTEGA	; mainly t'same
	DW	OFFSET SCROLL_UEGA	;
	DW	OFFSET SCROLL_DEGA	;
	DW	OFFSET SCROLL_LEGA	;
	DW	OFFSET SCROLL_REGA	;
	DW	OFFSET DOWN_LOADEGA	;
	DW	OFFSET INIT_DUMMYEGA	;
	dw	offset head_ega		;16 
	dw	offset level_ega	;18 probably only one thats different !
	dw	offset ptxt_ega		;20

	endif

pal	macro r,g,b
	db	r*4,g*4,b*4
	endm

vga_col_table	label	byte
;	 the list of stuff for the palette
;	I suppose every time the mode is set up I need to change this!

	pal	0,0,0	; very funny indeed hah fucking hah
	pal	0,12,0
	pal	0,6,0
	pal	8,8,14
	pal	6,6,15
	pal	14,8,8
	pal	14,12,0
	pal	15,0,0
	pal	8,4,2
	pal	6,0,0
	pal	14,12,12
	pal	8,8,10
	pal	4,4,8
	pal	2,2,4
	pal	0,0,0
;pal	15,0,15	;!!!! ahahah !

	db	48,32,12	;15	thats a guess as it changes level to level

dseg		ends

end

