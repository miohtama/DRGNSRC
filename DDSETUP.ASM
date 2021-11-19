
cseg		segment	public 'code'

assume		cs: cseg, ds: dseg

include		ddeqfile

public		set_up, death, find_walkable,renum_chrs
public		set_vga

extrn		load:near, rect_offscrn:near, get_surface:near
extrn		grabeither:near,rl_william:near,rl_bigbos:near
extrn		rl_linda:near,reload:near,cvertx:near
extrn		disp_scrn:near,ptxt:near,load_error:near

miss5_frig:
; make things a hole !
	pushall
	mov	cx,20
	mov	si,4008+offset chr_map
ch_lp1:
	mov	ah,[si]
	and	ah,81h	;mask out chr but none else
	or	ah,36	;place the newchr in
	mov	[si],ah
	add	si,2
	loop	ch_lp1
	mov	cx,22
	mov	si,4190+offset chr_map
ch_lp2:
	mov	ah,[si]
	and	ah,81h	;mask out chr but none else
	or	ah,36	;place the newchr in
	mov	[si],ah
	add	si,2
	loop	ch_lp2

	mov	cx,24
	mov	si,4372+offset chr_map
ch_lp3:
	mov	ah,[si]
	and	ah,81h	;mask out chr but none else
	or	ah,36	;place the newchr in
	mov	[si],ah
	add	si,2
	loop	ch_lp3

	mov	cx,26+16
	mov	si,4554+offset chr_map
ch_lp4:
	mov	ah,[si]
	and	ah,81h	;mask out chr but none else
	or	ah,36	;place the newchr in
	mov	[si],ah
	add	si,2
	loop	ch_lp4

	mov	cx,28+14
	mov	si,4736+offset chr_map
ch_lp5:
	mov	ah,[si]
	and	ah,81h	;mask out chr but none else
	or	ah,36	;place the newchr in
	mov	[si],ah
	add	si,2
	loop	ch_lp5

	popall
	ret

set_up:
	MOV	AX,SEG DSEG
	MOV	DS,AX	;WHAT A LAUGH !
		call	empty_p_tab
		call	setup_w_tab

	mov	al,mission
	xor	ah,ah		; mission is 1 to 5 i reckon.
	call	disp_scrn	; shows those fucking nintendo scrns!
	mov	al,mission
	xor	ah,ah
	call	nint_text	; that crappy stupid text !

		mov	bl, mission
		shl	bl, 1
		xor	bh, bh
		add	bx, offset mission_table-2
		mov	bx, [bx]

		push	bx
		cmp	[sixteencol],0	;sixteencolours ?
		jp_e	nsix
	cmp	sixteencol,3	; vga version
	jp_e	vga_ld
	load_m2	dumvar,[bx+49],g_disc
	cmp	sixteencol,1
	jne	no_cv_1
	pushall
	mov	ax,seg dumvar
	mov	es,ax
	mov	di,offset dumvar
	mov	cx,30720	;just how long is the file
	call	cvertx
	popall
no_cv_1:	cmp	mission,4
		jp_e	othrstf		;no second block for level 4
		load_m2	dm2,[bx+51],g_disc
	cmp	sixteencol,1
	jne	no_cv_2
	pushall
	mov	ax,seg dm2
	mov	es,ax
	mov	di,offset dm2
	mov	cx,30720	;just how long is the file
	call	cvertx
	popall
no_cv_2:
;NEED CONVERSION CODE HERE WHEN TANDY VERSION IS COMPLETED.
	jmp	othrstf	;skip other loading !
vga_ld:
		load_m2	dumvar,[bx+53],g_disc
		cmp	mission,4
		je	othrstf		;no second block for level 4
		load_m2	dm2,[bx+55],g_disc

		jmp	othrstf	;skip other loading !

nsix:
		load_m2	chr_blocks,[bx],g_disc
		load_m2	chr_block2,[bx+47],g_disc
othrstf:

		pop	bx
;DOES ZE LOADING OF CHR_MAP CRASH IT ?
		push	bx
rty:
		mov	start_seg,seg chr_map
		mov	start_offset,offset chr_map -4	;lose those bytes !
		mov	ax, [bx+2]
		mov	file_name, ax
		call	load
	cmp	errfl,0
	je	nay_err
	mov	ax,g_disc
	call	load_error
	jmp	rty
nay_err:

	cmp	mission,5
	jne	not_zis
	call	miss5_frig
not_zis:
		pop	bx

		push	bx
		load_m2	hat_map, [bx+4] , g_disc
		pop	bx

	mov	ax, [bx+6]
	mov	map_width, ax
	mov	ax, [bx+8]
	mov	map_right, ax	;what the hell is map right

		mov	ax, [bx+10]
		mov	map_bottom, ax

		mov	ax, [bx+12]
		mov	posn_in_map, ax
		mov	ax, [bx+14]
		mov	scrn_left, ax
		mov	ax, [bx+16]
		mov	scrn_top, ax

		mov	ax, [bx+18]
		mov	word ptr person_table + 8, ax	; map_x of player 1
		mov	ax, [bx+20]
		mov	word ptr person_table + 10, ax	; map_y of player 1
		mov	ax, [bx+22]
		mov	word ptr person_table + 8 + per_list_size, ax	; pl2x
		mov	ax, [bx+24]
		mov	word ptr person_table + 10 + per_list_size, ax	; pl2y
		mov	al, [bx+26]
		mov	person_table + 3, al	; height of player 1
		mov	al, [bx+27]
		mov	person_table + 3 + per_list_size, al	; h, player 2

		mov	ax, [bx+28]
		mov	trigger_point, ax
		mov	ax, [bx+30]
		mov	limit_ptr, ax

		mov	ax, [bx+32]
		mov	door_map_x, ax
		mov	ax, [bx+34]
		mov	door_map_y, ax
		mov	ax, [bx+36]
		mov	door_trigger, ax
		mov	al, [bx+38]

		mov	opened, al
		mov	al, [bx+39]
		mov	closing, al
		mov	al, [bx+40]
		mov	closed, al
		mov	ax, [bx+41]
		mov	rect_rows, ax

		mov	ax, [bx+43]
		mov	min_plane, ax
		mov	ax, [bx+45]
		mov	max_plane, ax

		mov	window_topleft, offset dummy_scrn
		mov	window_top, 0
		mov	window_left, 0
		mov	posn_in_chr, 0
		mov	limit_flag, 1
		mov	cycle, 0
		mov	furthest_reachd, 0

		mov	bl, mission
		shl	bl, 1
		xor	bh, bh
		add	bx, offset timetable - 2
		mov	ax, [bx]
		mov	timer, ax

		mov	rect_cols, 0
		call	rect_offscrn
		mov	door_state, 0
		mov	wall_state, 0

		mov	cx,2
		mov	si,offset person_table
;if this player is dead then make sure I don't make him standing.
rset_plyer:
		cmp	byte ptr [si+2],being_dead
		je	dont_unkill
		mov	byte ptr [si+2], standing
dont_unkill:
		mov	byte ptr [si+4], down+right
		mov	byte ptr [si+5], 20
		mov	word ptr [si+6], -1
		mov	word ptr [si+18], nawt_lad
		add	si,per_list_size
		loop	rset_plyer

	call	reload	; Checks wether we need to reload 
			; if so it loads in the req file.
if RELEASE_BUILD
public loc_5a6f
loc_5a6f:	; called from ddpanel.asm in dragon.exe
endif
	cmp	[sixteencol],0
	jne	noncga
;cmp	mission, 3
;je	green_palette
;cmp	mission, 4
;je	green_palette
		mov	ax, 5
		int	16
		ret
noncga:
		mov	ax,[gmode]
		int	16
	cmp	sixteencol,3
	jne	no_c_pal
	pushall

	mov	dx,offset vga_col_table
	call	set_vga

	call	vga_cls

	popall
no_c_pal:
		ret

vga_cls:
	mov	ax,0a000h
	mov	es,ax
	xor	di,di

	mov	cx,8192	;number of words for 2 whole screens

	mov	dx,3c4h
	mov	ax,0e02h
	out	dx,ax	;set up sequencer.
	mov	ax,65535	;err ? affect em all ?
rep	stosw

	ret

renum_chrs:
	ret
set_vga:
	mov	ax,seg pal_tab
	mov	es,ax
	mov	bx,0
	mov	cx,16	;err?
	mov	ax,1012h	;func 10h sub-func 12h
	int	16		; set the colour registers
	mov	dx,offset pal_tab
	mov	ax,1002h	;set the palette registers !
	int	16
	ret

;green_palette:	mov	ax, 4
;int	16
;mov	ah, 11
;mov	bx, 100h
;int	16
;ret

empty_p_tab:	mov	si, offset person_table + 2 * per_list_size
		mov	cx, 5
empty_pt_loop:	mov	byte ptr [si+2], being_dead
		add	si, per_list_size
		loop	empty_pt_loop
		ret


setup_w_tab:	mov	bl, mission
		shl	bl, 1
		xor	bh, bh
		add	bx, offset wepup_table-2
		mov	si, [bx]
		mov	di, offset weapon_table
		mov	cx, 3 * wep_list_size
		rep	movsw
		ret

bill_death:
		cmp	strength, 0
		jp_ne	no_death

		cmp	frame_no, offset bidie_r_8	;p_null_0
		je	kill_bill
		cmp	action,bidye
		jp_e	no_death	;already dying !

		mov	action,bidye	;set off dying
		mov	frame_no,-1
		ret	;hmm hmm hmm ? safe at this as when bill is dead
kill_bill:
		mov	action,being_dead	;kill so we can fin level
		ret			

death:		cmp	name_, player1
		je	player_death
		cmp	name_, player2
		je	player_death
		cmp	type_, bill
		je	bill_death
		cmp	strength, 0
		jne	no_death
		cmp	frame_no, offset getup_r_0
		je	enemy_death
		cmp	frame_no, offset getup_l_0
		jne	no_death
enemy_death:
		mov	action, being_dead
no_death:
		ret

player_death:	cmp	action, being_dead
		je	lives_down
		cmp	strength, 0
		jg	no_death
		cmp	action, standing
		je	player_collapse
		cmp	action, walking
		je	player_collapse
		cmp	frame_no, offset p_null_0
		jne	no_death
		mov	action, being_dead
lives_down:	cmp	name_, player2
		je	player2_death
		sub	pl1_lives, 1
		adc	pl1_lives, 0
		jmp	reincarnate
player2_death:	sub	pl2_lives, 1
		adc	pl2_lives, 0
reincarnate:	jc	try_restart
		mov	action, getting_up
		mov	frame_no, -1
		mov	strength, 20
		call	find_walkable
		ret
player_collapse:mov	action, collapsing
		mov	frame_no, -1
		ret
try_restart:	cmp	credits, 0
		je	no_rst
		cmp	name_, player2
		je	pl2_rst
		cmp	keybd+fire_j, 0
		je	new_pl1
		cmp	keybd+fire_jk, 0
		je	new_pl1
no_rst:		ret
pl2_rst:	cmp	keybd+fire_k, 0
		je	new_pl2
		ret
new_pl1:	mov	pl1_lives, 2
		mov	pl1_score, 0
		jmp	over_npl2
new_pl2:	mov	pl2_lives, 2
		mov	pl2_score, 0
over_npl2:	mov	strength, 20
		mov	action, getting_up
		mov	frame_no, -1
		dec	credits
		call	find_walkable
		mov	bl, mission
		shl	bl, 1
		xor	bh, bh
		add	bx, offset timetable - 2
		mov	ax, [bx]
		mov	timer, ax
		ret

find_walkable:	mov	ax, scrn_left
		add	ax, 25
		cmp	name_, player1
		je	skip_fw
		add	ax, 10
skip_fw:	mov	test_map_x, ax
		mov	ax, scrn_top
		add	ax, 20
		mov	test_map_y, ax
		mov	bx, 1		; line length in steps
		mov	dx, 4		; step length in map units
	mov	test_height,1	;?
spiral_loop:
		mov	cx, bx
line_loop_1:	push	bx
		push	cx
		push	dx
		call	get_surface
;border	10
		pop	dx
		pop	cx
		pop	bx
		cmp	byte ptr attribute,0	; walkable 0 attr is garys walkable all over
		je	found_it
		add	test_map_x, dx
		loop	line_loop_1

		mov	cx, bx
line_loop_2:	push	bx
		push	cx
		push	dx
		call	get_surface
;border	10
		pop	dx
		pop	cx
		pop	bx
		cmp	byte ptr attribute,0		; walkable
		je	found_it
		add	test_map_y, dx
		loop	line_loop_2

		inc	bx
		neg	dx
		jmp	spiral_loop

found_it:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	al, level
		mov	height, al
		ret


nint_text:
;	print some bloody text onto the screen.
;	for those fucking nintendo scrns.
;	ax = mission .

	pushall
	shl	ax,1
	shl	ax,1
	mov	bx,offset text_tables
	add	bx,ax		;index into the tables
	push	bx
	mov	si,[bx]		;address of first text message

	mov	dx,2+140*256
	call	ptxt
	pop	bx
	mov	si,[bx+2]
	mov	dx,2+160*256
	call	ptxt

	popall
	ret

cseg		ends

extrn	chr_blocks:byte
chr_block2	equ	chr_blocks+15360	;secondary load address

dseg		segment	public 'data'
extrn	test_height:byte,errfl:word
extrn		mission:byte,  chr_map:word, hat_map:word
extrn		start_seg:word, start_offset:word, file_name:word
extrn		map_width:word, map_right:word, map_bottom:word
extrn		posn_in_map:word, scrn_left:word, scrn_top:word
extrn		person_table:byte, trigger_point:word, limit_ptr:word
extrn		trigger_table_1:word, limit_table_1:word
extrn		trigger_table_2:word, limit_table_2:word
extrn		trigger_table_3:word, limit_table_3:word
extrn		trigger_table_4:word, limit_table_4:word
extrn		trigger_table_5:word, limit_table_5:word
extrn		sprt_table:word, weapon_table:word, door_trigger:word
extrn		door_map_x:word, door_map_y:word, opened:byte, closing:byte
extrn		closed:byte, rect_cols:word, rect_rows:word, door_state:byte
extrn		wall_state:byte, min_plane:word, max_plane:word
extrn		linda_file1:byte, boss_file1:byte, strength:byte, keybd:byte
extrn		map_x:word, map_y:word, height:byte, name_:byte, action:byte,type_:byte
extrn		test_map_x:word, test_map_y:word, attribute:byte, level:byte,reduced_attr:byte
extrn		frame_no:word, credits:word, pl1_lives:word, pl2_lives:word
extrn		getup_r_0:word, getup_l_0:word, p_null_0:word, cycle:word
extrn		window_topleft:word, window_top:word, window_left:word
extrn		posn_in_chr:word, furthest_reachd:word, limit_flag:byte
extrn		dummy_scrn:byte, timer:word, pl1_score:word, pl2_score:word
extrn		null_0:word,flame_0:word

extrn		gmode:word,sixteencol:byte,screen:word,bidie_r_8:word
extrn		vga_col_table:byte,g_disc:word

mission_table	dw	offset mission1_data
		dw	offset mission2_data
		dw	offset mission3_data
		dw	offset mission4_data
		dw	offset mission5_data

mission1_data	dw	offset chr_file_1	; chr blocks
		dw	offset map_file_1	; chr map
		dw	offset hat_file_1	; hat map
		dw	190, 364, 79		; map_width, _right, _bottom
		dw	offset chr_map+(2*190)	; posn_in_map
		dw	0,8			; scrn_left, scrn_top
		dw	10,60 , 20,60		; pl1 (x,y),  pl2 (x,y)
		db	4, 4			; pl1 hght,  pl2 hght
		dw	offset trigger_table_1	; trigger_point
		dw	offset limit_table_1	; limit pointer
		dw	190, 24, 190		; door_map_x, _map_y, _trigger
		db	8, 24, 29		; opened, closing, closed
		dw	64			; rect_rows
		dw	0,80			; min, max sprt planes
		dw	offset chr_file_1a
		dw	offset chr_lv1_1
		dw	offset chr_lv1_2
		dw	offset chr_lv1_1v
		dw	offset chr_lv1_2v

mission2_data	dw	offset chr_file_2
		dw	offset map_file_2
		dw	offset hat_file_2
		dw	168, 320, 123
		dw	offset chr_map+(20*168)
		dw	0, 80
		dw	10, 120, 20, 120
		db	4, 4
		dw	offset trigger_table_2, offset limit_table_2
		dw	272, 44, 280	;door map x/y,_trigger
		db	13, 20, 30	;opened,closing,closed
		dw	74		;rect_rows
		dw	0, 150
		dw	offset chr_file_2a
		dw	offset chr_lv2_1
		dw	offset chr_lv2_2
		dw	offset chr_lv2_1v
		dw	offset chr_lv2_2v


mission3_data	dw	offset chr_file_3
		dw	offset map_file_3
		dw	offset hat_file_3
		dw	292, 567, 68
		dw	offset chr_map + 5 * 292
		dw	0, 20
		dw	10, 60, 20, 60
		db	4, 4
		dw	offset trigger_table_3, offset limit_table_3
		dw	150, 12, 150
		db	8, 24, 29
		dw	64
		dw	20, 76	;68 ?
		dw	offset chr_file_3a
		dw	offset chr_lv3_1
		dw	offset chr_lv3_2
		dw	offset chr_lv3_1v
		dw	offset chr_lv3_2v


mission4_data	dw	offset chr_file_4
		dw	offset map_file_4
		dw	offset hat_file_4
		dw	80, 159-16, 80
		dw	offset chr_map + 2 * 80
		dw	0, 8
		dw	40, 40, 50, 40
		db	12,12
		dw	offset trigger_table_4, offset limit_table_4
		dw	118, 4, 120	;m_x ,m_y , trigger/(override trigg?)
		db	6, 24, 27
		dw	90	;just gets bigger and bigger ...!
		dw	40, 120
		dw	offset chr_file_4a
		dw	offset chr_lv4_1
		dw	offset chr_lv4_2	;no real file !
		dw	offset chr_lv4_1v
		dw	offset chr_lv4_2v


mission5_data	dw	offset chr_file_5
		dw	offset map_file_5
		dw	offset hat_file_5
		dw	182, 356, 108
		dw	offset chr_map + 2 * 182
		dw	0, 8
		dw	10, 30, 20, 30
		db	88, 88
		dw	offset trigger_table_5, offset limit_table_5
		dw	484, 16, 490
		db	5, 24, 26
		dw	80
		dw	0, 208
		dw	offset chr_file_5a
		dw	offset chr_lv5_1
		dw	offset chr_lv5_2
		dw	offset chr_lv5_1v
		dw	offset chr_lv5_2v


wepup_table	dw	offset mission1_weps
		dw	offset mission2_weps
		dw	offset mission3_weps
		dw	offset mission4_weps
		dw	offset mission5_weps

mission1_weps	db	whip, ?, nonexistent, ?
		dw	-1, ?, ?, ?, ?, offset sprt_table+224, 4 * per_list_size + offset person_table

		db	club, ?, stationary, 4
		dw	-1, 250, 60, 0, 0, offset sprt_table+256, nobody	;5 * per_list_size + offset person_table
; will give to a captain I reckon eventually.
		db	crate, ?, stationary, 4
		dw	-1, 50, 70, 0, 0, offset sprt_table+288, nobody

		db	whip, ?, nonexistent, ?
		dw	-1, ?, ?, ?, ?, offset sprt_table+384, 4*per_list_size+offset person_table

		db	knife, ?, stationary, 4
		dw	-1, 280, 65, 0, 0, offset sprt_table+352, nobody
	
		db	?, ?, nonexistent, ?
		dw	?, ?, ?, ?, ?, offset sprt_table+384, nobody

;	Used As The Thumb .

mission2_weps	db	tnt, 50, stationary, 4	;it explodes pretty quickly
		dw	-1, 40, 111, 0, 0, offset sprt_table+224, nobody

		db	club, ?, stationary, 4
		dw	-1, 30, 115, 0, 0, offset sprt_table+256, nobody	;5 * per_list_size + offset person_table

		db	rock, ?, stationary, 4
		dw	-1, 90, 115, 0, 0, offset sprt_table+288, nobody

		db	knife, ?, stationary, 53
		dw	-1, 243, 63, 0, 0, offset sprt_table+320, nobody

		db	whip, ?, nonexistent, ?
		dw	-1, ?, ?, ?, ?, offset sprt_table+352, nobody	;4 * per_list_size + offset person_table

		db	?, ?, nonexistent, ?
		dw	?, ?, ?, ?, ?, offset sprt_table+384, nobody

mission3_weps	db	club, ?, stationary, 4
		dw	-1, 90, 50, 0, 0, offset sprt_table+224, nobody

		db	barrel, ?, stationary, 4
		dw	-1, 100, 45, 0, 0, offset sprt_table+256, nobody

		db	whip, ?, nonexistent, ?
		dw	-1, ?, ?, ?, ?, offset sprt_table+288, 5 * per_list_size + offset person_table

		db	club, ?, stationary, 4
		dw	-1, 450, 50, 0, 0, offset sprt_table+320, nobody

;	two weapons only that are not used ( not enough I think for the combine)
;	excellent !
		db	specwep, ?, stationary, 4
		dw	-1, 152, 26, 0, 0, offset sprt_table+352, nobody

		db	rock, ?, nonexistent, 4
		dw	-1, 700, 30, 0, 0, offset sprt_table+384, nobody

mission4_weps	db	tnt, 250, nonexistent, 4
		dw	-1, 130, 80, 0, 0, offset sprt_table+224, nobody

		db	rock, ?, nonexistent, 56
		dw	-1, 190, 30, 0, 0, offset sprt_table+256, nobody

		db	rock, ?, nonexistent, 56
		dw	-1, 200, 35, 0, 0, offset sprt_table+288, nobody

		db	?, ?, nonexistent, ?
		dw	?, ?, ?, ?, ?, offset sprt_table+320, nobody

		db	?, ?, nonexistent, ?
		dw	?, ?, ?, ?, ?, offset sprt_table+352, nobody

		db	?, ?, nonexistent, ?
		dw	?, ?, ?, ?, ?, offset sprt_table+384, nobody

mission5_weps	db	specwep, ?, stationary, 88
		dw	offset flame_0, 8, 16, 0, 0, offset sprt_table+224, nobody
		db	specwep, ?, stationary, 88
		dw	offset flame_0, 60, 16, 0, 0, offset sprt_table+256, nobody
; these special weapons are	1. flames
;				2. stabbers
;				3. stones
;				4. wall
;	The weapons have been rearranged considerably due to the bloody walls !
		db	club, ?, nonexistent, ?
		dw	-1, ?, ?, ?, ?, offset sprt_table+288, nobody	;2 * per_list_size + offset person_table
		db	rock, ?, nonexistent, 88
		dw	-1, 170, 40, -1, 400, offset sprt_table+320, nobody
		db	rock, ?, nonexistent, 88
		dw	-1, 180, 40, -1, 400, offset sprt_table+352, nobody
; the y_velocity when rolling is used as a timer ?!
		db	?, ?, nonexistent, ?
		dw	?, ?, ?, ?, ?, offset sprt_table+384, nobody

chr_file_1	db	"level11.cpc",0
chr_file_1a	db	"level12.cpc",0	;must change this!
chr_file_2	db	"level21.cpc",0
chr_file_2a	db	"level22.cpc",0	;must change this!
chr_file_3	db	"level31.cpc",0
chr_file_3a	db	"level32.cpc",0	;must change this!
chr_file_4	db	"level41.cpc",0
chr_file_4a	db	"level42.cpc",0	;must change this!
chr_file_5	db	"level51.cpc",0
chr_file_5a	db	"level52.cpc",0	;must change this!


map_file_1	db	"level1.map",0
map_file_2	db	"level2.map", 0
map_file_3	db	"level3.map", 0
map_file_4	db	"level4.map", 0
map_file_5	db	"level5.map", 0

hat_file_1	db	"level1.hat", 0
hat_file_2	db	"level2.hat", 0
hat_file_3	db	"level3.hat", 0
hat_file_4	db	"level4.hat", 0
hat_file_5	db	"level5.hat", 0

chr_lv1_1	db	"level11.cpe",0
chr_lv1_2	db	"level12.cpe",0
chr_lv2_1	db	"level21.cpe",0
chr_lv2_2	db	"level22.cpe",0
chr_lv3_1	db	"level31.cpe",0
chr_lv3_2	db	"level32.cpe",0
chr_lv4_1	db	"level41.cpe",0
chr_lv4_2	db	"level42.cpe",0	;shouldnt be such a file though
chr_lv5_1	db	"level51.cpe",0
chr_lv5_2	db	"level52.cpe",0

chr_lv1_1v	db	"level11.cpv",0
chr_lv1_2v	db	"level12.cpv",0
chr_lv2_1v	db	"level21.cpv",0
chr_lv2_2v	db	"level22.cpv",0
chr_lv3_1v	db	"level31.cpv",0
chr_lv3_2v	db	"level32.cpv",0
chr_lv4_1v	db	"level41.cpv",0
chr_lv4_2v	db	"level42.cpv",0	;shouldnt be such a file though
chr_lv5_1v	db	"level51.cpv",0
chr_lv5_2v	db	"level52.cpv",0

timetable	dw	71, 71, 91, 51, 91

pal_tab		db	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0
; good grief this is bloody silly !

text_tables	dw	level_1_a,level_1_b	;0 mission shouldnt be used.
		dw	level_1_a,level_1_b
		dw	level_2_a,level_2_b
		dw	level_3_a,level_3_b
		dw	level_4_a,level_4_b
		dw	level_5_a,level_5_b

level_1_a	db	"Billy and Jimmy Lee pursue the killers",0
level_1_b	db	"  of Billy's girlfriend , Marian.",0
level_2_a	db	34,"They're hiding in that factory !",34,0
level_2_b	db	0
level_3_a	db	"The pursuit moves out of the city .",0
level_3_b	db	0
level_4_a	db	"    ",34,"Quick , up the mountain !",34,0
level_4_b	db	0
level_5_a	db	"The Double Dragons have gained entry",0
level_5_b	db	"      to the enemy's base.",0

dseg		ends

lin_seg		segment public 'data'
extrn		lin_dat:word
lin_seg		ends

wil_seg		segment public 'data'
extrn		wil_dat:word
wil_seg		ends

flidseg segment public 'zzzz'
extrn	dumvar:word
dm2	equ	dumvar+30720

flidseg	 ends

end
