
cseg		segment	public 'code'

assume		cs: cseg, ds: dseg, ss: sseg
extrn	set_vga:near
extrn		load:near, init_dummy:near, download_dummy:near
extrn		de_vice:near
extrn		undraw_sprt:near, draw_sprt:near, download:near
extrn		scroll_up:near, scroll_down:near
extrn		scroll_left:near, scroll_right:near
extrn		newivector:near, return:near, restore_int:near
extrn		pt_word:near, get_instr:near, get_action:near
EXTRN		NEW_WEAPONS:NEAR,DECOMP:NEAR,PANEL:NEAR
extrn		player1_rout:near,player2_rout:near
extrn		enemy1_rout:near,load_error:near

extrn		stage_control:near,frame_weapons:near,animate_weapons:near
extrn		new_weapons:near
extrn		renum_chrs:near
extrn		special_bkgds:near,draw_rect:near,undraw_rect:near
extrn		setup_colrs:near,undoor:near,options:near,death:near

extrn		head:near,strength_bar:near,ptxt:near,ptxt_cont:near
extrn		write_text:near,pnum:near,pscore:near
extrn		set_up:near,load_tan:near,load_ega:near,LOAD_CGA:NEAR
extrn	load_vga:near,make_tabtan:near,ptxt_ega:near

extrn	make_table:near,mk_mask:near,mk_flipc:near

public		pull_person, put_person, get_frame, next_frame,rand_num_gen
public		restart,main_loop,insert_disk1,entry,disp_scrn

;pnum a number : pscore appends a zero !

include         ddeqfile

load_screen	macro	filenme,adr
	mov	start_offset,offset adr
	mov	start_seg,seg adr
	mov	file_name,offset filenme
	call	load
	endm

wrte	macro	plane
		mov	dx,3c4h
		mov	ax,plane+2
		out	dx,ax
	endm



gstart:		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		mov	ax, sseg
		mov	ss, ax
		mov	sp, offset stack_base
		CLD
		mov	ax,2	;put into alpha mode 2
		int	16	;for initial question!

		call	options

	mov	g_disc,0	;main disc for the moment.

		MOV	WORD PTR [FREE_MEM],0
		MOV	WORD PTR [FREE_MEM+2],seg dumvar

		MOV	WORD PTR [chite_ptr],0 	
		MOV	WORD PTR [chite_ptr+2],seg dumvar
;leave room for two screens of data. 
		MOV	WORD PTR [dum_ptr],0
		mov	ax,seg chr_blocks
		mov	word ptr [dum_ptr+2],ax

	call	newivector

	mov	ax,5
	int	16	;go to cga screen !

	CMP	[SIXTEENCOL],0
	JNE	NLCGA
	CALL	LOAD_CGA
	call	setup_colrs	;only for a cga one ?
NLCGA:
	CMP	[SIXTEENCOL],1
	JNE	NLTAN
	CALL	LOAD_TAN
NLTAN:
	CMP	[SIXTEENCOL],2
	JNE	NLEGA
	CALL	LOAD_EGA
NLEGA:
	CMP	[SIXTEENCOL],3
	JNE	NLVGA
	CALL	LOAD_VGA	;cheat !
NLVGA:
entry:	;the game restart position.
	mov	ax,seg dseg
	mov	ds,ax
	mov	es,ax
	CLI
	mov	sp, offset stack_base
		cmp	[sixteencol],2
		jb	noctsp	;	got you , you little fucker !
	mov	ax,word ptr [dum_ptr+2]
	mov	ss,ax	;ah !I see ! so the ss is the base of the dum_scrn
			; and sp points to some safe area at top of screen.
	mov	sp,offset stack_frme
noctsp:
	STI
restart:
	mov	ax,seg dseg
	mov	ds,ax
	mov	es,ax

	mov	ax,0	;0 implies loader screen ?
	call	disp_scrn

;	mov	nojoyflag,0
;	mov	dx,201h
;	in	al,dx
;	cmp	al,255
;	jne	not255
;	mov	nojoyflag,-1
;not255:

warm_restart:	
		MOV     byte ptr AJF2,0  ;KILL THE STICKS
		MOV     byte ptr AJF1,0  ;SO THE BUTTON RESELECTS.
	mov	keybd+fire_j,1
	mov	keybd+fire_k,1

	mov	ax,5			; 5 credits still by no means easy !
	cmp	cheat_mode,0
	jne	no_cheat_creds
	xor	ax,ax
no_cheat_creds:
		mov     word ptr credits, ax	; ( clever !)
		mov     word ptr pl1_lives, 2
		mov     word ptr pl2_lives, 2
		mov     word ptr pl1_score, 0
		mov     word ptr pl2_score, 0
		mov     byte ptr mission, 1
		mov     byte ptr fight_flag, 0
		mov     byte ptr cutie_state, 0
		mov	word ptr person_table + 6, -1
		mov	word ptr person_table + 6 + per_list_size, -1
		mov	byte ptr person_table + 2, standing
		mov	byte ptr person_table + 2 + per_list_size, standing
		mov	byte ptr person_table + 4, down+right
		mov	byte ptr person_table + 4 + per_list_size, down+right
		mov	byte ptr person_table + 5, 20
		mov	byte ptr person_table + 5 + per_list_size, 20

wait_fire:		
		mov	bx,mess_ptr
		mov	si,[bx]
		mov	bx,[bx+2]
		mov	mess_ptr,bx
		mov	dx, 256*192

		cmp	sixteencol,3
		jne	not_vga
	mov	sixteencol,2
		call	ptxt_ega
	mov	sixteencol,3
		jmp	lbl69
not_vga:
		call	ptxt	;use this version !
lbl69:
		mov	cx, 8
wait_fire1:
	mov	bl,keybd+fire_k		;num kpad 0
	and	bl,keybd+fire_k2	;l
	and	bl,keybd+five_k		;num key pad 5
	and	bl,keybd+st_two		;2	
	and	bl,keybd+ret_k		;ret
	jz	start_dd2p

	mov	bl,keybd+fire_j		;s
	and	bl,keybd+st_one		;1
	and	bl,keybd+fire_jk	;joy fire !
	and	bl,keybd+space_k	;space
	jz	start_dd1p

		inc	ax
		pause	1	;as this is a w_fly the messages
		loop	wait_fire1	; are evenly timed across the range.

		jmp	wait_fire

start_dd1p:	mov	byte ptr person_table + 2 + per_list_size, being_dead
		mov	pl2_lives, 0
start_dd2p:	
		mov	seed, ax
		call	set_up
	;border	7	;dark white
		call	init_dummy

	;border	15	;bright red

	if	vers eq vga
	call	make_table
	call	mk_mask
	call	mk_flipc
	cmp	sixteencol,1
	jne	no_tandy1
	call	make_tabtan
no_tandy1:
	else
	call	mk_flipc	;flip table and mask table
	call	mk_mask
	endif

	mov	frame_count,0

;		********* MAIN LOOP *********
main_loop:
	mov	ax,seg dseg
	mov	ds,ax
	mov	es,ax

	mov	ax,30
	cmp	cheat_mode,0
	je	hang_on_a_bit

;	change cheat mode to give credits and not
;	a complete cheat as b4 !?

;cmp	byte ptr [ person_table+5 ] , 1
;jle	hang_on_a_bit			;some things must kill immediately
;mov	byte ptr [ person_table+5 ] , 20	;

	mov	ax,15	;not as much a slow down !
	
;	most of the game time is spent here !!
hang_on_a_bit:
	cmp	frame_count,ax	;slower slower and even slower !
	jl	hang_on_a_bit	;a similar clock !

no_slow_down:

	cmp	byte ptr [keybd+3bh],1
	je	no_pause
debounce1:
	cmp	byte ptr [keybd+3bh],1
	jne	debounce1
;	am pausing at this point !
;	and now the key has been released
cont_pause:
	cmp	byte ptr [keybd+3bh],1
	je	cont_pause

;debounce:
;cmp	byte ptr [keybd+3bh],1
;jne	debounce1

no_pause:
	MOV	FRAME_COUNT,0
		call	stage_control
		call	new_people
		call	frame_people
		call	new_weapons
		call	limit_horiz
		call	frame_weapons

		call	draw_new
		call	animate_people
		call	animate_weapons
		call	download_dummy	;nah !
		call	undraw_old
		call	undoor
		call	scroll_control
		call	panel
		call	special_bkgds
		inc	cycle
		call	rand_num_gen

	cmp	keybd + escape_k, 0
	je	exit

		jmp	main_loop

exit:		jmp	return
restartsh:	jmp	restart

;		******* SUBROUTINES *******

draw_new:	mov	ax,seg dseg
		mov	ds,ax
		mov	es,ax

		mov	dx, min_plane
		mov	di,offset orderlist
next_plane_dn:	
		mov	si, offset weapon_table;
next_wep_dn:	
		cmp	byte ptr [si+2], nonexistent
		je	w_no_draw_dn


no_holder:
;	er cant think at present
		mov	person_on,offset frgit	;4th byte is a right facer
okayd:
		mov	al, [si+3]		; height of weapon
		cbw
		add	ax, [si+8]		; add w_map_y to get plane dpth
		cmp	ax,dx
		jne	w_no_draw_dn

	mov	bx,[si+4]	;frame addr ?
	mov	ax,[bx+4]	;dir
	mov	flip_dir,ax	;save (for posterity !)
	mov	bx,[bx]	;addr of data
	mov	al,[bx+4]
	mov	spr_l_offs,al

		mov	ss_save,seg wep_dat
		push	si
		push	dx
		mov	si,[si+14]
		mov	ds:[di],si
		add	di,2	;save into the list !
		push	di
		call	draw_sprt
		pop	di
		pop	dx
		pop	si
w_no_draw_dn:	add	si, wep_list_size
		cmp	si, offset weapon_table + 6 * wep_list_size
		jB	next_wep_dn
	;border	7	;greybright red
		mov	si, offset person_table
next_per_dn:	

		cmp	byte ptr [si+2], being_dead
		jp_e	no_draw_dn
		mov	al, [si+3]		; height of person
		cbw
		add	ax, [si+10]		; add map_y to get plane depth
		cmp	ax, dx
		jne	no_draw_dn
	push	dx
		mov	al,[si+4]	;the direction is the dir
		xor	ah,ah
		mov	flip_dir,ax
		mov	bx, [si+6]

		mov	bx, [bx]
;	bx now points to 'sprite data' table
		mov	al,byte ptr [si+1]
		xor	ah,ah
		mov	bp,ax
		add	bx,ds:[bp+offset ds:sprt_cv_tab]

		mov	ax,[bx+2]	;the segment address !
	cmp	bp,ghost	;is it a ghost ! erm >
	jne	no_ghost
	cmp	sixteencol,3
	jne	no_ghost
	mov	ax,seg bill_dat
no_ghost:		; change segment to point to recoloured player.

	if	vers eq cga
; all baddies ie non wepon/player segments must be wil_seg !
	cmp	ax,seg pl1_dat1
	je	not_baddie	;all ropers and ghosts for this ver
	cmp	bp,ghost	;and player2
	cmp	bp,wepon
	je	not_baddie

	mov	ax,seg wil_dat
not_baddie:
	endif
		mov	ss_save, ax

		mov	al,[bx+6]
		mov	spr_l_offs,al
		push	si
		mov	si,[si+16]
		mov	ds:[di],si
		add	di,2
		push	di
	;border	8+1+2	;bright cyan
		call	draw_sprt
	;border	8+1+4	;magenta
		pop	di
		pop	si
	pop	dx
;NO_FIN_SPRITE:
no_draw_dn:	add	si, per_list_size
		cmp	si, offset person_table + 7 * per_list_size

		jp_b	next_per_dn

		inc	dx
		cmp	dx, max_plane
		ja	exit_dn
		jmp	next_plane_dn
exit_dn:	sub	di,2
		mov	orderpnt,di
		ret

undraw_old:	
		mov	di,orderpnt
		cmp	di,offset orderlist
		jae	nxtp
		ret
nxtp:
		mov	si,ds:[di]
		push	di
		call	undraw_sprt
		pop	di
		sub	di,2
		cmp	di,offset orderlist
		jae	nxtp
		ret		

new_people:	mov	si, offset person_table
next_per_np:	cmp	si, offset person_table + 2 * per_list_size
;jb	check_players
		jp_b	check_players
		cmp	byte ptr [si+2], being_dead
;je	person_done_np
		jp_e	person_done_np
check_players:	push	si
		call	pull_person	;hmm
		cmp	action, being_dead
		jp_e	death_test
;	border	1
		call	get_instr
;	border	2
		pop	si
		push	si
		cmp	si, offset person_table + 2 * per_list_size
		jp_ge	not_player
;	border	6
		call	limit_horiz
not_player:	
;	border	7
		call	get_action ;yes its HERE !!!!!(and it woz player !)
death_test:
	border	0	;black
		call	death
;	border	3	;cyan
still_alive:	pop	si
		push	si
		call	put_person
		pop	si
person_done_np:	add	si, per_list_size
		cmp	si, offset person_table + 7 * per_list_size
;jB	next_per_np
		jp_b	next_per_np
;	border	0;back to black
		ret

limit_horiz:	mov	ax, map_x
		sub	ax, scrn_left
		cmp	ax, push_left
		jge	ok_horiz_l
		cmp	x_vel, -1
		jne	ok_horiz_l
		mov	x_vel, 0
ok_horiz_l:	cmp	ax, push_right
		jle	ok_horiz_r
		cmp	x_vel, 1
		jne	ok_horiz_r
		mov	x_vel, 0
ok_horiz_r:	ret

frame_people:	mov	si, offset person_table
next_per_fp:	cmp	byte ptr [si+2], being_dead
		je	person_done_fp
		push	si
		call	pull_person

		call	get_frame

		pop	si
		push	si
		call	put_person
		pop	si
person_done_fp:	add	si, per_list_size
		cmp	si, offset person_table + 7 * per_list_size
		jne	next_per_fp
		ret

animate_people:	test	cycle, 1
		jz	exit_ap
		mov	si, offset person_table
next_per_ap:	cmp	byte ptr [si+2], being_dead
		je	person_done_ap
		push	si
		call	pull_person
		call	next_frame
		pop	si
		push	si
		call	put_person
		pop	si
person_done_ap:	add	si, per_list_size
		cmp	si, offset person_table + 7 * per_list_size
		jB	next_per_ap
exit_ap:	ret

pull_person:	
		mov	di, offset name_
		mov	cx, per_list_size/2
		rep	movsw
		ret
put_person:	
		mov	di, si
		mov	si, offset name_
		mov	cx, per_list_size/2
		rep	movsw
		ret

get_frame:	cmp	frame_no, -1		; test for new action
		jne	old_action
		call	get_1st_frame
old_action:	mov	bx, frame_no
		mov	bx, [bx]		; figure addr

	mov	al,type_
	xor	ah,ah
	mov	bp,ax
	add	bx,ds:[bp+offset ds:sprt_cv_tab]	;much better !

		mov	si, sprt_index
		mov	ax, [bx]
		mov	[si+8], ax		; data ptr
		mov	ax, [bx+4]		; cols, rows
		mov	dl, ah
		cbw
		mov	[si+4], ax		; cols
		mov	al, dl
		cbw
		mov	[si+6], ax		; rows
		mov	ax, [bx+6]		; x-, y-offsets
		mov	dl, ah
		cbw
		add	ax, map_x
		sub	ax, scrn_left
		mov	[si], ax		; x-offset
		mov	al, dl
		cbw
		mov	dx, map_y
		sub	dx, scrn_top
		shl	dx, 1
		shl	dx, 1
		add	ax, dx
		mov	[si+2], ax		; y-offset
		ldtab	[si+10], name_, colrmap_table
		ret

get_1st_frame:	mov	al, direction
		and	al, 3
		jnz	ok_g1f
		jmp	return
ok_g1f:		dec	ax			; quicker
		add	al, action
		cbw
		shl	ax, 1
		add	ax, offset frame_0_table
		mov	bx, ax
		mov	ax, [bx]
		test	byte ptr direction, up
		jz	down_frame
		cmp	action, walking
		je	up_frame
		cmp	action, holding_up
		je	up_frame
		jmp	down_frame
up_frame:	add	ax, 56
down_frame:	mov	frame_no, ax
		ret

next_frame:	mov	al, action
		cmp	al, standing
		je	exit_nf
		cmp	al, hu_standing
		je	exit_nf
		cmp	al, climbing
		jne	new_frame
		mov	ax, x_vel
		or	ax, y_vel
		jz	exit_nf
		cmp	y_vel, 1
		jne	new_frame
		mov	bx, frame_no
		mov	bx, [bx+2]
		mov	bx, [bx+2]
		jmp	got_frm_no
new_frame:	mov	bx, frame_no
got_frm_no:	mov	ax, [bx+2]
		mov	frame_no, ax
exit_nf:	ret

scroll_control:	call	minimax
		mov	lr_scroll, 0
		mov	ud_scroll, 0
		cmp	ax, push_right
		jl	ok_right
		inc	lr_scroll
		dec	bx
ok_right:	cmp	bx, push_left
		jg	ok_left
		dec	lr_scroll
ok_left:	cmp	cx, push_down
		jl	ok_down
		inc	ud_scroll
		dec	dx
ok_down:	cmp	dx, push_up
		jg	ok_up
		dec	ud_scroll
ok_up:		mov	ax, scrn_left
		cmp	lr_scroll, 0
		je	no_lr
		jl	right_scroll
		cmp	ax, hi_x_limit
		jge	no_lr
		call	scroll_left
		jmp	no_lr
right_scroll:	cmp	ax, lo_x_limit
		jle	no_lr
		call	scroll_right
no_lr:		mov	ax, scrn_top
		cmp	ud_scroll, 0
		je	no_ud
		jl	down_scroll
		cmp	ax, hi_y_limit
		jge	no_ud
		call	scroll_up
		jmp	no_ud
down_scroll:	cmp	ax, lo_y_limit
		jle	no_ud
		call	scroll_down
no_ud:		ret

minimax:	mov	ax, word ptr person_table+ 8
		mov	bx, word ptr person_table + 8 + per_list_size
		mov	cx, word ptr person_table + 10
		mov	dx, word ptr person_table + 10 + per_list_size
		cmp	byte ptr person_table + 2, being_dead
		jne	player1_alive
		mov	ax, bx
		mov	cx, dx
player1_alive:	cmp	byte ptr person_table + 2 + per_list_size, being_dead
		jne	player2_alive
		mov	bx, ax
		mov	dx, cx
player2_alive:	cmp	ax, bx
		jge	x_done
		xchg	ax, bx
x_done:		cmp	cx, dx
		jge	y_done
		xchg	cx, dx
y_done:		cmp	ax, furthest_reachd
		jle	set_min_max
		mov	furthest_reachd, ax
set_min_max:	sub	ax, scrn_left
		sub	bx, scrn_left
		sub	cx, scrn_top
		sub	dx, scrn_top
		mov	max_x, ax
		mov	min_x, bx
		mov	max_y, cx
		mov	min_y, dx
		ret

rand_num_gen:	mov	ax, seed
		and	ax, ax
		jz	seed_was_0
		mov	dx, 77
		mul	dx
		sub	ax, dx
		jnc	store_seed
		inc	ax
		jmp	store_seed
seed_was_0:	mov	ax, -77
store_seed:	mov	seed, ax
		ret

wait_fly:	mov	dx, 3dah
wait_0:		in	al, dx
		test	al, 8
		jnz	wait_0
wait_1:		in	al, dx
		test	al, 8
		jz	wait_1
		ret

;	hmm table of screens for each game type ax indexes which scrn



disp_scrn:
	pushall
	mov	bx,seg files_list
	mov	ds,bx
	mov	si,offset files_list
	mov	bl,sixteencol
	mov	bh,0
	shl	bx,1
	add	si,bx	;index into the first table
	mov	si,[si]	;now points to list of files
	shl	ax,1	;thats the file_name job
	add	si,ax	; now si points to the file name !
	mov	si,[si]
	pushall
rettt:
	mov	start_offset , offset chr_blocks
	mov	start_seg , seg chr_blocks
	mov	file_name , si
	call	load

	cmp	errfl,0
	je	no_errr
	mov	ax,g_disc
	call	load_error
	jmp	rettt

no_errr:
	popall
	cmp	[sixteencol],0
	jne	notcga

	mov	ax,4
	int	16

;load_m	chr_blocks,load_scrn_c	;have as raw format ?!
; what about in raw format for 
	mov	bit_planes,2	;nice one cyril
	call	show	;from here ?

	popall
	ret

notcga:
;
; load the ega screen and display it
; would like to have a raw format ega file ?
;
	cmp	sixteencol,3
	je	vga_scrn
	mov	ax,gmode
	int	16	;ega format screen
; would like if could use show from other code ?	
;load_m	chr_blocks,load_scrn_e

	mov	bit_planes,4
	call	show
	popall
	ret

vga_scrn:
	push	ax
	mov	ax,0dh
	int	16	;ega format screen
	pop	ax
	mov	dx,offset vga_col_table
	cmp	ax,0
	jne	not_load_scrn
	mov	dx,offset load_scrn_pal
not_load_scrn:
	cmp	ax,12	;stupido !
	jne	not_end_scrn
	mov	dx,offset end_scrn_pal
not_end_scrn:
	call	set_vga
;load_m	chr_blocks,load_scrn_v
	mov	bit_planes,4
	call	show
	popall
	ret

no_ch_dsk:	ret

insert_disk1:
;	cmp	sixteencol,0	; for cga now we need an insert 
;	je	no_ch_dsk	; disk message.

;		push    ds
;		mov     ah,1bh
;		int     21h
;		pop     ds	;WHATS THIS ??? MORE CODE OF GRAHAMS?
;		cmp     dx,354
;		jne     hardy
	mov	si,offset mess_tables
	xor	ax,ax
	mov	al,sixteencol
	shl	ax,1
	add	si,ax
	mov	si,[si]	; different messages for diff games !
		mov	dx, 8+256*18
		call	write_text
		mov	si,offset wait_sp_mess
		mov	dx, 10+256*22
		call	write_text
wait_space:	cmp	keybd+39h, 0
		jne	wait_space
hardy:
		ret


conv_cga:
; short subroutine to change ax/bx from
; bit plane format to the cga format
; when word is formed it is stosw 'd
	rept	2
	rept	8
	shr	bx,1
	rcr	ax,1
	shr	dx,1
	rcr	ax,1
	endm
	xchg	al,ah
	stosw
	endm
	ret

show:
; take the sprite_picture and show it on the screen
;convert from AMIGA format screen in buffer to an ega one in display memory
	push	ds
	push	es

	cmp	bit_planes,2	;2/4
	jne	sh_ega
	jmp	sh_cga
sh_ega:
	cmp	sixteencol,1	;is it Tandy ?
	jp_e	show_tandy
	mov	ax,0a000h
	mov	es,ax
	xor	di,di
	mov	ax,seg chr_blocks
	mov	ds,ax
	mov	si,offset chr_blocks
	mov	ax,5
	mov	dx,3ceh
	out	dx,ax
	cld

	xor	di,di
	mov	cx,4000
	wrte	r_p
	rep	movsw	;8000 bytes at a time
	add	si,192

	xor	di,di
	mov	cx,4000
	wrte	g_p
	rep	movsw
	add	si,192

	xor	di,di
	mov	cx,4000
	wrte	b_p
	rep	movsw
	add	si,192

	xor	di,di
	mov	cx,4000
	wrte	i_p
	rep	movsw
	add	si,192
	pop	es
	pop	ds
	ret

show_tandy:
;	4 bit planes shifted into Tandy !

	mov	ax,0b800h
	mov	es,ax
	xor	di,di
	mov	ax,seg chr_blocks
	mov	ds,ax
	mov	si,offset chr_blocks
	mov	cx,50	; 50 line quads deep

tan_lines:
	push	di
	call	a_t_line
	add	di,8192-160	;160 bytes wide
	call	a_t_line
	add	di,8192-160	;160 bytes wide
	call	a_t_line
	add	di,8192-160	;160 bytes wide
	call	a_t_line
;add	di,-24576	;160 bytes wide
	pop	di
	add	di,160
	loop	tan_lines

	pop	es
	pop	ds

	ret

a_t_line:
	push	cx
	mov	cx,40	;byte width of source !
l_loop_t:
	mov	bl,[si]
	mov	bh,[si+8192]
	mov	dl,[si+16384]
	mov	dh,[si+24576]
	inc	si	;need just one addition
	call	tan_shift
	mov	es:[di+2],ax	;! put onto the screen ( probably need atleast one exchange !)
	call	tan_shift
	mov	es:[di],ax	;! put onto the screen ( probably need atleast one exchange !)
	add	di,4
	loop	l_loop_t
	pop	cx

	ret

tan_shift:
	rept	4
	shr	bl,1
	rcr	ax,1
	shr	bh,1
	rcr	ax,1
	shr	dl,1
	rcr	ax,1
	shr	dh,1
	rcr	ax,1	; one pixel 1/4 word !
	endm
	xchg	al,ah
	ret
sh_cga:
	mov	ax,0b800h
	mov	es,ax
	mov	ax,seg chr_blocks
	mov	ds,ax
	xor	di,di

	mov	si,offset chr_blocks
	mov	cx,100	; 100 line pairs deep

line_loop:
	push	di
	push	cx
	mov	cx,20	;20 words wide input
word_loop:
	mov	bx,[si]
	mov	dx,[si+8192]
	call	conv_cga	;convert and put onto screen
	add	si,2
	loop	word_loop

	add	di,8192-80	;take away the 80 added in converting

	mov	cx,20	;20 words wide input
word_loopo:
	mov	bx,[si]
	mov	dx,[si+8192]
	add	si,2
	call	conv_cga	;convert and put onto screen
	loop	word_loopo
	pop	cx
	pop	di
	add	di,80
	loop	line_loop

	pop	es
	pop	ds
	ret



cseg		ends

sseg		segment	stack
public		stack_base
		db	250 dup (?)
stack_base	label	word
	db	0,0	;oh yeah !
sseg		ends

;dsanim		segment	public	'data'
;dsanim		ends	;so it goes before these segments !

dseg		segment	public 'data'
extrn		club_0f:word,colaps_l_1f:word
extrn		start_seg:word, start_offset:word, file_name:word
extrn		chr_map:word, sprt_table:byte
extrn		keybd:byte, ss_save:word, scrn_top:word, scrn_left:word
extrn		identity_table:byte, player2_table:byte, colrmap_table:word
extrn		player1_frames:word, smallguy_frames:word, bigbastd_frames:word
extrn		bitch_frames:word, frame_0_table:word, walk_dr_0:word
extrn		walk_dl_0:word, p_null_0:word
extrn		w_map_y:word, w_height:byte, save_area:byte, weapon_table:byte
extrn		lo_x_limit:word, hi_x_limit:word,cutie_state:byte
extrn		lo_y_limit:word, hi_y_limit:word,credits:word,fight_flag:byte
extrn		pl1_score:word, pl2_score:word,hi_score:word
extrn		pl1_lives:word, pl2_lives:word,vga_col_table:byte

extrn		window_topleft:word,window_top:word,window_left:word
extrn		posn_in_chr:word,dummy_scrn:word,mission:byte
extrn		chite_topleft:word,FRAME_COUNT:WORD,errfl:word,cheat_mode:word
EXTRN		AJF1:BYTE,AJF2:BYTE,FUDLR:BYTE,FUDLR_2:BYTE

public		hat_map, name_, type_, action, frame_no, map_x, map_y, height
public		test_map_x, test_map_y, test_height, x_vel, y_vel, seed
public		controls, direction, level, attribute, reduced_attr
public		sprt_index, person_table, weapon_held, cycle, map_width
public		map_right, map_bottom, target_x, target_y, max_x, min_x
public		min_plane, max_plane, furthest_reachd
public		strength,person_on

PUBLIC		FREE_MEM,DUM_PTR,chite_ptr
PUBLIC		char_map,big_chars,flip_dir,spr_l_offs
public		sixteencol,screen,gmode,nojoyflag,g_disc


flip_dir	dw	0	;the flip direction for spr routine .
spr_l_offs	db	0	;te he fixed the funny weapon thing .

;pl1_str	dw	0
;pl2_str	dw	0
nojoyflag	dw	-1	; default is no joystick

g_disc	dw	?

mess_tables	dw	offset diskcga
		dw	offset diskega
		dw	offset diskega
		dw	offset diskvga

diskcga	db	"Insert Main Disc         .",0
diskega	db	"Insert EGA graphics disc .",0
diskvga	db	"Insert VGA graphics disc .",0
wait_sp_mess	db	"THEN PRESS SPACE.",0

bit_planes	dw	?

SIXTEENCOL	DB	0	;flag for version !	
even
free_mem	DD	0	;use an LDS instruction !?  
DUM_PTR		DD	0	;32 bit ptr for dummy screen.

files_list	dw	offset cga_list	; cga version .
		dw	offset ega_list	; tandy version .
		dw	offset ega_list	; EGA version .
		dw	offset vga_list	; VGA version .

cga_list	dw	load_scrn_c
		dw	level_1_c
		dw	level_2_c
		dw	level_3_c
		dw	level_4_c
		dw	level_5_c
		dw	end_c

ega_list	dw	load_scrn_e
		dw	level_1_e
		dw	level_2_e
		dw	level_3_e
		dw	level_4_e
		dw	level_5_e
		dw	end_e

vga_list	dw	load_scrn_v
		dw	level_1_v
		dw	level_2_v
		dw	level_3_v
		dw	level_4_v
		dw	level_5_v
		dw	end_v

end_c		db	"endsc.cpc",0
end_e		db	"endsc.cpe",0
end_v		db	"endsc.cpv",0

level_1_c	db	"screen1.cpc",0
level_2_c	db	"screen2.cpc",0
level_3_c	db	"screen3.cpc",0
level_4_c	db	"screen4.cpc",0
level_5_c	db	"screen5.cpc",0

level_1_e	db	"screen1.cpe",0
level_2_e	db	"screen2.cpe",0
level_3_e	db	"screen3.cpe",0
level_4_e	db	"screen4.cpe",0
level_5_e	db	"screen5.cpe",0

level_1_v	db	"screen1.cpv",0
level_2_v	db	"screen2.cpv",0
level_3_v	db	"screen3.cpv",0
level_4_v	db	"screen4.cpv",0
level_5_v	db	"screen5.cpv",0

load_scrn_c	db	"titledd2.cpc",0
load_scrn_e	db	"titledd2.cpe",0
load_scrn_v	db	"titledd2.cpv",0	; eventually

pal	macro	rv,gv,bv
	db	rv*4,gv*4,bv*4
	endm

end_scrn_pal	label	byte
		pal	0,0,0
		pal	0,0,4
		pal	6,0,0
		pal	3,2,2
		pal	8,3,0
		pal	5,0,9
		pal	12,5,0
		pal	7,0,11
		pal	14,7,2
		pal	12,8,4
		pal	14,9,3
		pal	14,9,7
		pal	6,11,15
		pal	14,12,8
		pal	15,12,10
		pal	13,14,13

load_scrn_pal	label	byte

		pal	0,0,0
		pal	2,2,2
		pal	0,0,8
		pal	0,0,11
		pal	4,4,4
		pal	14,0,0
		pal	0,0,15
		pal	6,6,6
		pal	11,7,0
		pal	11,9,0
		pal	0,6,15
		pal	0,10,15
		pal	15,15,0
		pal	6,11,15
		pal	15,15,7
		pal	15,15,15

chite_ptr	dd	0
GMODE		DW	0
screen		dw	0	;variable in grabbin for an offset 
map_width	dw	196
map_right	dw	391
map_bottom	dw	51
orderpnt	dw	0

hat_map		dw	2604 dup (?)	;
;bloody hell it overran into the character set !!!

char_map	db	784 dup (?)	;space for character set.
big_chars	db	896 dup (?)	;room for the big characters

orderlist	dw	30 dup (?)	;10 weapons 10 people ?

mess_1_t	db	"    LICENSED FROM TRADEWEST , INC .     " , 0
mess_2_t	db	"  TM (C) 1989 AMERICAN TECHNOS , INC .  " , 0
mess_3_t	db	"  (C) 1989 VIRGIN MASTERTRONIC , INC .  " , 0
mess_4_t	db	"           ALL RIGHTS RESERVED .        " , 0
mess_5_t	db	"   DEVELOPMENT BY BINARY DESIGN LTD  .  " , 0
mess_6_t	db	"  CODING BY Dave Stead and Mike Day  .  " , 0
mess_7_t	db	"  GRAPHICS CONVERTED BY PICTURE ELEMENT " , 0

even

mess_ptr	dw	offset mess_1

mess_1		dw	offset mess_1_t , offset mess_2
mess_2		dw	offset mess_2_t , offset mess_3
mess_3		dw	offset mess_3_t , offset mess_4
mess_4		dw	offset mess_4_t , offset mess_5
mess_5		dw	offset mess_5_t , offset mess_6
mess_6		dw	offset mess_6_t , offset mess_7
mess_7		dw	offset mess_7_t , offset mess_1

chset_file	db	"charset.bin", 0


sprt_cv_tab	dw 0	;player1	equ	0	; names
		dw 8	;williams	equ	2	; CARTWHEEL
		dw 24	;abobo		equ	4	; DAVE
		dw 16	;linda		equ	6	; BITCH
		dw 32	;big_boss_willy	equ	8	; BOSS
		dw 0	;player2	equ	10
		dw 8	;williams_A	equ	12
		dw 8	;williams_B	equ	14
		dw 8	;williams_C	equ	16	; these are CARTWHEELS
		dw 24	;abobo_A	equ	18
		dw 24	;abobo_B	equ	20	;these are DAVES
		dw 0	;roper		equ	22	; ROPER
		dw 48	;captain	equ	24	;extra chappie ! what about captaina/b/c ?
		dw 40	;bill		equ	26	;another extra one !
		dw 64	;lowry	equ	28	;yet another one !
		dw 48	;captain	equ	30	;extra chappie ! what about captaina/b/c ?
		dw 48	;captain	equ	32	;extra chappie ! what about captaina/b/c ?
		dw 48	;captain	equ	34	;extra chappie ! what about captaina/b/c ?
		dw 56	;fatty ! mr creosote ( blimey lowry yet !)equ 36
		dw 0	; zero for weapons !Special stuff !
		dw 0	;roper_B	ghostie !

name_		db	?		; vars pulled out of array
type_		db	?
action		db	?
height		db	?
direction	db	?
strength	db	?
frame_no	dw	?
map_x		dw	?
map_y		dw	?
x_vel		dw	?
y_vel		dw	?
sprt_index	dw	?
weapon_held	dw	?
target_x	dw	?
target_y	dw	?

test_map_x	dw	?
test_map_y	dw	?
test_height	db	?
controls	db	0fh			; throwaway vars
level		db	?
attribute	db	?
reduced_attr	db	?
cycle		dw	0
seed		dw	0
min_x		dw	?
max_x		dw	?
min_y		dw	?
max_y		dw	?
furthest_reachd	dw	0
lr_scroll	db	?
ud_scroll	db	?
min_plane	dw	?
max_plane	dw	?
person_on	dw	?	;pointer saved which points to a person_table


frgit	db 20 dup (?)	;cheat weapon !

even
person_table	db	player1, player1, standing, 4, down+right, 255
		dw	offset walk_dl_0, 10, 45, 0, 0
		dw	offset sprt_table, nawt_lad, ?, ?

		db	player2, player1, standing, 4, down+right, 10
		dw	offset walk_dl_0, 40, 43, 0, 0
		dw	offset sprt_table+32, nawt_lad, ?, ?	;+32

		db	?, ?, being_dead, ?, ?, ?
		dw	9 dup (?)				;+64

		db	?, ?, being_dead, ?, ?, ?
		dw	9 dup (?)				;+96

		db	?, ?, being_dead, ?, ?, ?
		dw	9 dup (?)				;+128

		db	?, ?, being_dead, ?, ?, ?
		dw	9 dup (?)				;+160

		db	?, ?, being_dead, ?, ?, ?
		dw	9 dup (?)				;+192

extrn	msk_tab:byte

dseg		ends

buff_seg	segment	public 'data'
buff_seg	ends

;
;	If buffer segment overruns then corruption of player occurs
;

pl1_seg1	segment	public 'data'
public		pl1_dat1
res_mem		pl1_dat1 , 55656 ,27828
pl1_seg1	ends

wep_seg		segment public 'data'
public		wep_dat
res_mem		wep_dat , 16000 ,8000	;max about 15648
wep_seg		ends

abo_seg		segment public 'data'
public		abo_dat
res_mem		abo_dat , 26500 , 1
abo_seg		ends

lin_seg		segment public 'data'
public		lin_dat
res_mem		lin_dat , 15800 , 1
lin_seg		ends

bill_seg	segment public 'data'
public		bill_dat
res_mem		bill_dat , 31800 , 1
bill_seg	ends

capt_seg	segment public 'data'
public		capt_dat
res_mem		capt_dat , 29500 , 1
capt_seg	ends

wil_seg		segment public 'data'
public		wil_dat
res_mem		wil_dat , 34200 , 17100	;shine a light forgot any sprs !
wil_seg		ends

block_seg	segment	public 'data'
extrn	chr_blocks:byte
stack_frme	equ chr_blocks+33958	;that leaves 256 bytes for stack ?
block_seg	ends

flidseg segment public 'zzzz'
public	dumvar
dumvar		label word	;db	0
flidseg	 ends

end	gstart

