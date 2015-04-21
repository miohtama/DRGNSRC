
;	1.	Enemy low energy.
;	2.	Enemy full energy.

vvv equ 2

cseg		segment	public 'code'

assume		cs:cseg, ds:dseg

include		ddeqfile

public		stage_control,are_all_dead

extrn		return:near, set_up:near, init_dummy:near, main_loop:near
extrn		bonus:near, entry:near, ptxt:near, drop_his_weapon:near
extrn		end_game:near, scroll_right:near, scroll_down:near
extrn		thumb_snd:near,	disp_scrn:near	,pnum:near , bbw_reload:near

stage_control:
;BORDER	12

;mov	ax,thmbflag
;mov	cx,3
;mov	dx,120*256
;call	pnum


	cmp	thmbflag,255	;use the newly devised thumb flag!
	jne	no_thmb	;???

;	if theres a thumb then keep it in the top right side of the screen.

	mov	ax, scrn_left
	add	ax, 50
	mov	word ptr weapon_table + 6 + 5 * wep_list_size, ax
	mov	ax, scrn_top
	add	ax, 8
	mov	word ptr weapon_table + 8 + 5 * wep_list_size, ax
	mov	bx,max_plane
	sub	bx,ax	;calcualte a height for it that is max pos
	sub	bx,10
	and	bx,127
	mov	byte ptr weapon_table + 3 + 5 * wep_list_size,bl

no_thmb:	
		call	test_new_limit
;cmp	fight_flag, 1
;jne	cont_sc
;mov	byte ptr weapon_table + 2 + 5 * wep_list_size, nonexistent
;cmp	byte ptr person_table + 2, being_dead
;jp_e	pl2_win
;cmp	byte ptr person_table + 2 + per_list_size, being_dead
;jp_e	pl1_win
cont_sc:
		cmp	lo_x_limit, 999
		je	next_mission
		call	test_trigger
		cmp	word ptr weapon_table + 4 + 5 * wep_list_size, offset thumb_0
		jne	cont_sc2
		cmp	byte ptr weapon_table + 2 + 5 * wep_list_size, nonexistent
		je	cont_sc2
		call	thumb_snd
cont_sc2:

; ************************************************************

	cmp	cheat_mode,0
	je	no_ch_modes

		mov	bx, offset keybd + 2	;DELETE THIS
missn_key_loop:	cmp	byte ptr [bx], 0	;
		je	new_mission		;
		inc	bx			;
		cmp	bx, offset keybd + 7	;
		jb	missn_key_loop		;DOWN TO HERE !
no_ch_modes:
		ret

new_mission:	sub	bx, offset keybd + 1	;DELETE ZIS !
		mov	mission, bl		;AND ALSO THIS !
		dec	mission			;UNT THIS !
;
; code to restart the game at another mission by typing 1-5
; ************************************************************

next_mission:
	mov	word ptr [frig_limit2],480	; oh hell fire christ (etc)
	mov	word ptr [8+frig_limit2],480
	mov	word ptr [16+frig_limit2],480
	mov	word ptr [frig_limit2-8],480	; oh hell fire christ (etc)
	mov	word ptr [frig_limit2-16],480
	mov	word ptr [frig_limit2-24],480	;reset to 480
;mov	word ptr [frig_limit5],600
;mov	word ptr [frig_limit5+8],600	; move ghosts back
		inc	mission
		cmp	mission, 6	;
		jp_e	finish		;end_game;jumps here when BBW is dead.

		call	bonus
		call	set_up
		call	init_dummy
		pop	ax	;pull off return address
		jmp	main_loop

;pl1_win:
;		mov	fight_flag, 1
;		cmp	byte ptr person_table + 2, being_dead
;		jne	win_1
;		jmp	end_game
;win_1:
;		mov	si, offset person_table
;		jmp	finish
;
;pl2_win:	mov	fight_flag, 1
;		cmp	byte ptr person_table + 2 + per_list_size, being_dead
;		jne	win_2;
;		jmp	end_game
;win_2:		mov	si, offset person_table + per_list_size
;		jmp	finish

fight:
;		mov	si, offset person_table
;		cmp	byte ptr [si+2], being_dead
;		je	pl2_win
;		cmp	byte ptr [si+2+per_list_size], being_dead
;		je	pl1_win
;		dec	mission
;		mov	fight_flag, 1
;		mov	timer, 20
;		mov	credits, 0
;		sub	limit_ptr, 16
;		mov	limit_flag, 1
;		mov	pl1_lives, 0
;		mov	pl2_lives, 0
;
;		call	drop_his_weapon
;		mov	byte ptr [si+2], standing
;		mov	byte ptr [si+3], 4
;		mov	byte ptr [si+4], down+right
;		mov	byte ptr [si+5], 20
;		mov	word ptr [si+6], -1
;		mov	word ptr [si+8], 480
;		mov	word ptr [si+10], 45
;		mov	word ptr [si+12], 0
;		mov	word ptr [si+14], 0
;
;		add	si, per_list_size
;		call	drop_his_weapon
;		mov	byte ptr [si+2], standing
;		mov	byte ptr [si+4], down+right
;		mov	byte ptr [si+5], 20
;		mov	word ptr [si+6], -1
;		mov	word ptr [si+8], 500
;		mov	word ptr [si+10], 45
;		mov	word ptr [si+12], 0
;		mov	word ptr [si+14], 0
;
;		mov	si, offset fight_text1
;		mov	dx, 15+80*256
;		call	ptxt
;		mov	si, offset fight_text2
;		mov	dx, 10+96*256
;		call	ptxt
;		pause	20
;
;		pop	ax
;		jmp	main_loop

finish:
;	mov	byte ptr [si+2], lying		; to immobilise
;	mov	byte ptr [si+3], 3
;	mov	word ptr [si+6], offset walk_dl_1
;	mov	word ptr [si+8], 460	; move directly to 
;	mov	word ptr [si+10], 47	; kiss position
;	call	drop_his_weapon		; throw away any club

;	push	si
;	mov	al,cutie_state
;	xor	ah,ah
;	mov	cx,3	;3 digits
;	mov	dx,8*256	;scrn position
;	call	pnum
;	mov	ax,scrn_left
;	mov	dx,16*256
;	mov	cx,4
;	call	pnum
;	mov	ax,scrn_top
;	mov	dx,16*256+20
;	mov	cx,4
;	call	pnum
;	pop	si

;	cmp	scrn_left, 420
;	jle	no_rt_scrl
;	call	scroll_right
;	cmp	scrn_top, 15
;	jle	no_dn_scrl
;	call	scroll_down
;no_dn_scrl:	ret
;no_rt_scrl:	cmp	scrn_top, 15
;	jle	reached_cutie
;	call	scroll_down
;	ret

reached_cutie:	
;call	anim_cutie
;cmp	cutie_state, 60
;je	goto_end
;ret	; no more cutie when reached the ghosts are dead so lets finish
goto_end:	mov	si, offset the_end
		mov	dx, 16+80*256
		call	ptxt
		pause	10
	
	mov	ax,6
	call	disp_scrn
	pause	30

		jmp	entry

test_trigger:	

;	hmm if limit_flag=0 only ?

	cmp	limit_flag,0
	jne	exit_tt	;if not zero then must be waiting for all to die??

		mov	bx, trigger_point
		mov	ax, furthest_reachd
		cmp	ax, [bx]
		jl	exit_tt

	cmp	bx,offset frig_limit5+8	;put second ghost up
	jne	not_ze_ghost
	mov	rchd_ghst,1	;?
not_ze_ghost:
		mov	si, [bx+2]
		mov	di, [bx+4]
		call	create_person
		mov	di, [di + 18 - per_list_size]
		cmp     di, -1
		je	no_wepup
		mov	byte ptr [di+2], being_carried
no_wepup:	mov	di, 5 * wep_list_size + offset weapon_table
		call	load_wep
	mov	thmbflag,0	;no thumb !
		add	trigger_point, 8
		mov	ax, [bx+6]
		mov	limit_flag, ax
exit_tt:	ret


test_new_limit:	
		cmp	limit_flag,0
		je	exit_tnl	;er ? does this work?
		call	are_all_dead
		jnz	exit_tnl		; ret if not all enemies dead
		mov	si,limit_ptr
		mov	di,offset lo_x_limit
		movsw
		movsw
		movsw
		movsw
		mov	limit_ptr, si
	mov	ax,limit_flag	;Here we are reading the old limit flag
		mov	limit_flag, 0
	cmp	ax,2
	je	no_hand	;all because david's added another limit type !
	cmp	ax,3	;
	je	reset_door	; Set to 3 when chars where made alive
				; This frig however will only work for lev 2

		mov	si, 5 * wep_list_size + offset weapon_table
		call	save_wep
		mov	byte ptr weapon_table + 5 * wep_list_size, club
		mov	byte ptr weapon_table + 2 + 5 * wep_list_size, stationary
		mov	byte ptr weapon_table + 3 + 5 * wep_list_size, 126	;20 ?
		mov	word ptr weapon_table + 4 + 5 * wep_list_size, offset thumb_0
		mov	ax, scrn_left
		add	ax, 50
		mov	word ptr weapon_table + 6 + 5 * wep_list_size, ax
		mov	ax, scrn_top
		add	ax, 8
		mov	word ptr weapon_table + 8 + 5 * wep_list_size, ax
	mov	bx,max_plane
	sub	bx,ax	;calcualte a height for it that is max pos
	dec	bx	;make sure !
	and	bx,127
	mov	byte ptr weapon_table + 3 + 5 * wep_list_size,bl

	mov	thmbflag,255	;make flag !
no_hand:
exit_tnl:	
;border	0
		ret

reset_door:
	mov	door_state,0
	mov	door_map_x,272
;	take out for a bit
;	Only works for level2 door.
	mov	word ptr [frig_limit2],270	; oh hell fire christ (etc)
	mov	word ptr [8+frig_limit2],270
	mov	word ptr [16+frig_limit2],270

	ret

find_null_enemy:
		mov	di, offset person_table + 2 * per_list_size
		mov	cx, 5
try_next_en_fne:cmp	byte ptr [di+2], being_dead
		je	exit_fne
		add	di, per_list_size
		loop	try_next_en_fne
		mov	di, offset person_table + 2 * per_list_size ; in case!
exit_fne:	ret



create_person:	
	if	vers	eq cga
		cmp	byte ptr [si] , big_boss_willy
		jne	no_willy
		call	bbw_reload
no_willy:	; its another reload for cga version only
	endif
		mov	cx, per_list_size / 2 - 2
		rep	movsw
;cmp	cheat_mode,0	;are we cheating
;je	no_cheats
;mov	byte ptr [di-per_list_size+9],2		;er ??
;no_cheats:
		mov	si, offset person_table + 8
		cmp	byte ptr person_table + 2, being_dead
		jne	att_pl1
		add	si, per_list_size
att_pl1:	movsw
		movsw
		ret

are_all_dead:	mov	di, offset person_table + 2 * per_list_size
		mov	cx, 5
try_next_en_aad:
		cmp	byte ptr [di+2], being_dead
		je	tis_dead
		cmp	byte ptr [di+2], weapact
		jne	exit_aad	;not weapon(background)/or dead
tis_dead:
		add	di, per_list_size
		loop	try_next_en_aad
		test	ax, 0			; set Z flag
exit_aad:	ret

save_wep:	mov	di, offset wep_save
		mov	cx, wep_list_size / 2
		rep	movsw
		ret

load_wep:	mov	si, offset wep_save
		mov	cx, wep_list_size / 2
		rep	movsw
		ret
; but cutie is not 4*wep_list_size ????????????????

anim_cutie:
;	mov	si, offset weapon_table + 4 * wep_list_size
;MOV	BYTE PTR [SI+2],STATIONARY	;MY FRIGG !
; this surely cant be making at crash ?

;	push	si
;	mov	al,cutie_state
;	xor	ah,ah
;	mov	cx,3	;3 digits
;	mov	dx,32*256	;scrn position
;	call	pnum
;	pop	si

;		inc	cutie_state
;		cmp	cutie_state, 6
;		jle	cut_drop
;		cmp	cutie_state, 12
;		jle	cut_land
;		cmp	cutie_state, 39
;		jle	cut_walk
;		cmp	cutie_state, 40
;		jle	cut_kiss
		ret
cut_drop:
;		mov	word ptr [si+4], offset cutie_dp
;		mov	ax, word ptr [si+12]
;		inc	word ptr [si+12]
;		add	word ptr [si+8], ax
;		sub	byte ptr [si+3], al
		ret
cut_land:
;		mov	byte ptr [si+3], 4
;		mov	word ptr [si+4], offset cutie_ld
		ret
cut_walk:
;		inc	word ptr [si+6]
;		mov	cx, 10000
cut_del:
;		loop	cut_del
		ret
cut_kiss:
;		mov	word ptr [si+4], offset cutie_k0
;		add	word ptr [si+6], 2
		ret

cseg		ends

dseg		segment	public 'data'

public		mission, lo_x_limit, hi_x_limit, lo_y_limit, hi_y_limit
public		trigger_point, trigger_table_1, trigger_table_2, cutie_state
public		trigger_table_3, trigger_table_4, trigger_table_5
public		limit_flag, limit_ptr, limit_table_1, limit_table_2
public		limit_table_3, limit_table_4, limit_table_5, fight_flag

extrn		person_table:byte, sprt_table:word, weapon_table:byte
extrn		map_right:word, window_topleft:word, window_top:word
extrn		window_left:word, dummy_scrn:word, keybd:byte, cycle:word
extrn		max_x:word, thumb_0:word, scrn_top:word, scrn_left:word
extrn		furthest_reachd:word, posn_in_chr:word, null_0:word
extrn		timer:word, pl1_lives:word, pl2_lives:word, credits:word
extrn		walk_dl_1:word
extrn		max_plane:word,cheat_mode:word
extrn		door_state:word,door_map_x:word
extrn		comb1_l:word,comb1_c:word,comb2_l:word,comb2_c:word
extrn		rchd_ghst:word,p_null_0:word

thmbflag	dw	0	;non to start!
public		frig_limit2,frig_limit5

mission		db	5
fight_flag	db	0
cutie_state	db	0

lo_x_limit	dw	?
hi_x_limit	dw	?
lo_y_limit	dw	?
hi_y_limit	dw	?

trigger_point	dw	offset trigger_table_1
limit_ptr	dw	offset limit_table_1
limit_flag	dw	1

wep_save	db	wep_list_size dup (?)


		; *** LEVEL 1 ***
		; *** WAS 95 ****


	if	vvv eq 1

v8	equ	2
v12	equ	2
v16	equ	2
v24	equ	2
v32	equ	4
v36	equ	4
v40	equ	4
v50	equ	4
	else
v8 	equ	10
v12	equ	12
v16	equ	18
v24	equ	24
v32	equ	32
v36	equ	36
v40	equ	40
v50	equ	50
	endif


	if	vers eq vga


limit_table_1   dw      0, 15,         	12, 40
		dw	40, 65,		12, 40
		dw	80, 140,	12, 40
		dw	180, 220,	12, 40
		dw	270, 332,	12, 40

		dw	999, 999,	8, 40


trigger_table_1	dw	0,	offset williams_1_1,	2 * per_list_size + offset person_table, 0
		dw	0,	offset williams_1_2,	3 * per_list_size + offset person_table, 0
		dw	35,	offset linda_1_1,	4 * per_list_size + offset person_table, 1

		dw	83,	offset williams_1_3,	2 * per_list_size + offset person_table, 0
		dw	85,	offset williams_1_4,	3 * per_list_size + offset person_table, 0
		dw	82,	offset williams_1_5,	4 * per_list_size + offset person_table, 2
		dw	125,	offset williams_1_6,	2 * per_list_size + offset person_table, 0
		dw	132,	offset abobo_1_1,	3 * per_list_size + offset person_table, 0
		dw	134,	offset williams_1_7,	4 * per_list_size + offset person_table, 1

		dw	200,	offset williams_1_8,	2 * per_list_size + offset person_table, 0
		dw	201,	offset williams_1_9,	3 * per_list_size + offset person_table, 0
		dw	210,	offset linda_1_2,	4 * per_list_size + offset person_table, 0
		dw	211,	offset linda_1_3,	5 * per_list_size + offset person_table, 2
		dw	270,	offset williams_1_10,	2 * per_list_size + offset person_table, 0
		dw	270,	offset williams_1_11,	3 * per_list_size + offset person_table, 0
		dw	300,	offset abobo_1_2,	4 * per_list_size + offset person_table, 1

		dw	1000			; end-of-list


williams_1_1	db	williams_A, williams , walking, 4, down+left,v8
		dw	-1, 65, 60, 0, 0, offset sprt_table + 64, nawt_lad
williams_1_2	db	williams_A, williams, walking, 4, down+left,v8
		dw	-1, 60, 68, 0, 0, offset sprt_table + 96, nawt_lad
linda_1_1	db	linda, linda, walking, 4, down+left, v8
		dw	-1, 0, 70, 0, 0, offset sprt_table + 128, offset weapon_table

williams_1_3	db	captain, captain, walking, 4, down+left, v8
		dw	-1, 113, 62, 0, 0, offset sprt_table + 64, nawt_lad
williams_1_4	db	captainA, captain, walking, 4, down+right, v8
		dw	-1, 115, 70, 0, 0, offset sprt_table + 96, nawt_lad
williams_1_5	db	captainB,captain, walking, 4, down+left, v8
		dw	-1, 117, 65, 0, 0, offset sprt_table + 128, nawt_lad
williams_1_6	db	captainC, captain, walking, 4, down+left, v8
		dw	-1, 165, 70, 0, 0, offset sprt_table + 64, nawt_lad	;wep_list_size + offset weapon_table
abobo_1_1	db	abobo, abobo, walking, 4, down+left, v16
		dw	-1, 170, 70, 0, 0, offset sprt_table + 128, nawt_lad
williams_1_7	db	captainA, captain, walking, 4, down+left, v8
		dw	-1, 165, 66, 0, 0, offset sprt_table + 96, nawt_lad

linda_1_2	db	linda, linda, walking, 4, down+left, v8
		dw	-1, 250, 60, 0, 0, offset sprt_table + 64, 3*wep_list_size + offset weapon_table
williams_1_8	db	captainB, captain, walking, 4, down+left, v8
		dw	-1, 270, 65, 0, 0, offset sprt_table + 96, nawt_lad
williams_1_9	db	williams_B, williams, walking, 4, down+left, v8
		dw	-1, 260, 75, 0, 0, offset sprt_table + 128, nawt_lad
linda_1_3	db	linda, linda, walking, 4, down+left, v12
		dw	-1, 260, 70, 0, 0, offset sprt_table + 160,nawt_lad 		;offset weapon_table MAKE KNIFE
williams_1_10	db	williams_B, williams, walking, 4, down+left, v12
		dw	-1, 300, 70, 0, 0, offset sprt_table + 64, nawt_lad
williams_1_11	db	williams, williams, walking, 4, down+left, v12
		dw	-1, 300, 70, 0, 0, offset sprt_table + 96, nawt_lad
abobo_1_2	db	abobo_A, bill, walking, 4, down+left, v24
		dw	-1, 355, 70, 0, 0, offset sprt_table + 128, nawt_lad



		; *** LEVEL 2 ***
		; *** was 45

limit_table_2   dw      0, 50,         0, 124-40
		dw	50, 140,	0, 124-40
		dw	100, 300,	0, 124-40
		dw	105, 300,	0, 124-40
		dw	111, 300,	0, 124-40
		dw	111, 300,	0, 124-40	;grief?
;dw	111, 300,	0, 124-40

		dw	999, 999,	0, 124-40


trigger_table_2	label	word
		dw	0,	offset wigfod_2_1,	2 * per_list_size + offset person_table, 0
		dw	30,	offset linda_2_1 ,	3 * per_list_size + offset person_table, 0
		dw	30,	offset linda_2_2 ,	4 * per_list_size + offset person_table, 2

		dw	104,	offset williams_2_1,	2 * per_list_size + offset person_table, 0
		dw	102,	offset captain_2_1,	3 * per_list_size + offset person_table, 0
		dw	124,	offset williams_2_2,	4 * per_list_size + offset person_table, 0
		dw	126,	offset williams_2_3,	5 * per_list_size + offset person_table, 1

		dw	220,	offset linda_2_3,	2 * per_list_size + offset person_table, 0
		dw	226,	offset williams_2_4,	3 * per_list_size + offset person_table, 0
		dw	228,	offset captain_2_2,	4 * per_list_size + offset person_table, 2

		dw	400,	offset linda_2_4,	2 * per_list_size + offset person_table, 0
		dw	400,	offset linda_2_5,	3 * per_list_size + offset person_table, 0
		dw	400,	offset captain_2_3,	4 * per_list_size + offset person_table, 0	;3
frig_limit2	label	word
		dw	480,	offset williams_2_5,	2 * per_list_size + offset person_table, 0
		dw	480,	offset captain_2_4,	3 * per_list_size + offset person_table, 0
		dw	480,	offset linda_2_6,	4 * per_list_size + offset person_table, 2

		dw	200,	offset abobo_2_1,	5 * per_list_size + offset person_table, 1

		dw	1000			; end-of-list

wigfod_2_1	db	abobo_A, abobo, walking, 4, down+left,v16	;a big dave
		dw	-1,13, 109, 0, 0, offset sprt_table + 128, nawt_lad
linda_2_1	db	linda, linda, walking, 4, down+left, v16
		dw	-1, 110, 122, 0, 0, offset sprt_table + 96,nawt_lad	; 4 * wep_list_size + offset weapon_table
linda_2_2	db	linda, linda, walking, 4, down+left, v16
		dw	-1, 110, 115, 0, 0, offset sprt_table + 64,nawt_lad	; 4 * wep_list_size + offset weapon_table

williams_2_1	db	williams_C, williams, jumping, 16, down+left,v12
		dw	-1, 128, 100, -1, -5, offset sprt_table + 64, nawt_lad
captain_2_1	db	captainB, captain, jumping, 16, down+left, v12
		dw	-1, 125, 96, -1, -5, offset sprt_table + 96, nawt_lad
williams_2_2	db	williams, williams, jumping, 28, down+left, v12
		dw	-1, 152, 84, -1, -3, offset sprt_table + 128, nawt_lad
williams_2_3	db	williams_A, williams, jumping,28, down+left, v12
		dw	-1, 160, 80, -1, -6, offset sprt_table + 160, nawt_lad

;	Now for those on top level .

linda_2_3	db	linda, linda, walking, 53, down+left, v16
		dw	-1, 243, 63, 0, 0, offset sprt_table + 64,nawt_lad	; 4 * wep_list_size + offset weapon_table
williams_2_4	db	williams_A, williams, walking, 53, down+left,v12
		dw	-1, 254, 75, 0, 0, offset sprt_table + 96, nawt_lad
captain_2_2	db	captainA, captain, walking, 53, down+left, v12
		dw	-1, 251, 64, 0, 0, offset sprt_table + 128, nawt_lad

linda_2_4	db	linda, linda, being_dead, 53, down+left, v16
		dw	-1, 268, 67, 0, 0, offset sprt_table + 64,nawt_lad	; 4 * wep_list_size + offset weapon_table
linda_2_5	db	linda, linda, being_dead, 53, down+left, v16
		dw	-1, 270, 67, 0, 0, offset sprt_table + 96,nawt_lad	; 4 * wep_list_size + offset weapon_table
captain_2_3	db	captainA, captain, being_dead, 53, down+left, v16
		dw	-1, 266, 67, 0, 0, offset sprt_table + 128, nawt_lad

williams_2_5	db	williams_B, williams, being_dead, 53, down+left, v12
		dw	-1, 268, 67, 0, 0, offset sprt_table + 64,nawt_lad	; wep_list_size + offset weapon_table
linda_2_6	db	linda, linda, being_dead, 53, down+left, v12
		dw	-1, 270, 67, 0, 0, offset sprt_table + 96,nawt_lad	; 4 * wep_list_size + offset weapon_table
captain_2_4	db	captainA, captain, being_dead, 53, down+left, v12
		dw	-1, 266, 67, 0, 0, offset sprt_table + 128, nawt_lad

abobo_2_1	db	fatty, fatty, walking, 53, down+left, v24
		dw	-1, 310, 76, 0, 0, offset sprt_table + 160, nawt_lad

		; *** LEVEL 3 ***
		; *** was 120

limit_table_3   dw      0, 16,		0, 28	;8 first lot b d why not 28
		dw	30, 60,		0, 28	;8 2nd + linda
		dw	30, 95,		0, 28	;
		dw	70, 200,	0, 28	;

		dw	170,260,	0,28	;the 1st combine stop
		dw	200,278,	0,28	;when roper is on ?

; use these scroll points to stop player seeing that combine has been lost

		dw	314,355,	0,28	;enemys after roper

		dw	320, 540,	0, 28	;all the 6 !
		dw	430, 540,	0, 28	;the bills

 		dw	999, 999,	0, 28


trigger_table_3	label	word
		dw	0,	offset dave_3_1,	2 * per_list_size + offset person_table, 0
		dw	0,	offset cart_3_1,	3 * per_list_size + offset person_table, 0
		dw	20,	offset capt_3_1,	4 * per_list_size + offset person_table, 0
		dw	20,	offset capt_3_2,	5 * per_list_size + offset person_table, 1
	
		dw	68,	offset cart_3_2,	2 * per_list_size + offset person_table, 0
		dw	69,	offset cart_3_3,	3 * per_list_size + offset person_table, 0
		dw	73,	offset capt_3_3,	4 * per_list_size + offset person_table, 0
		dw	75,	offset linda_3_1,	5 * per_list_size + offset person_table, 0
		dw	80,	offset capt_3_4,	6 * per_list_size + offset person_table, 1


		dw	126,	offset cart_3_4,	2 * per_list_size + offset person_table, 0
		dw	126,	offset cart_3_5,	3 * per_list_size + offset person_table, 0
		dw	132,	offset capt_3_5,	4 * per_list_size + offset person_table, 0
		dw	135,	offset capt_3_6,	5 * per_list_size + offset person_table, 2

		dw	176,	offset capt_3_7,	2 * per_list_size + offset person_table, 0
		dw	196,	offset cart_3_6,	3 * per_list_size + offset person_table, 0
		dw	196,	offset cart_3_7,	4 * per_list_size + offset person_table, 1

		dw	260,	offset	combine_3_1,	3 * per_list_size + offset person_table, 0
		dw	260,	offset	combine_3_2,	4 * per_list_size + offset person_table, 0
		dw	260,	offset	combine_3_3,	5 * per_list_size + offset person_table, 0
		dw	260,	offset	combine_3_4,	6 * per_list_size + offset person_table, 0

		dw	292,	offset capt_3_8,	2 * per_list_size + offset person_table, 1
 
		dw	316,	offset roper_3_1,	2 * per_list_size + offset person_table, 2

		dw	364,	offset cart_3_8,	2 * per_list_size + offset person_table ,0
		dw	370,	offset cart_3_9,	3 * per_list_size + offset person_table ,0
		dw	368,	offset cart_3_10,	4 * per_list_size + offset person_table ,2

		dw	420,	offset capt_3_9,	2 * per_list_size + offset person_table ,0
		dw	432,	offset capt_3_10,	3 * per_list_size + offset person_table ,0
		dw	426,	offset capt_3_11,	4 * per_list_size + offset person_table ,0
		dw	450,	offset roper_3_2,	5 * per_list_size + offset person_table ,0
		dw	450,	offset roper_3_3,	6 * per_list_size + offset person_table ,2

		dw	500,	offset bill_3_1,	2 * per_list_size +offset person_table ,0
		dw	501,	offset bill_3_2,	3 * per_list_size +offset person_table ,2

		dw	1000	;end here

dave_3_1	db	abobo, abobo, walking, 4, down+left, v16
		dw	-1, 14, 40, 0, 0, offset sprt_table + 64, nawt_lad	;offset weapon_table
cart_3_1	db	williams_B, williams, walking, 4, down+left, 16;v16
		dw	-1, 12, 45, 0, 0, offset sprt_table + 96, nawt_lad
capt_3_1	db	captain, captain, walking, 4, down+left, v16
		dw	-1, 72, 55, 0, 0, offset sprt_table + 160, nawt_lad
capt_3_2	db	captainA, captain, walking, 4, down+left, v16
		dw	-1, 72, 60, 0, 0, offset sprt_table + 128, nawt_lad

cart_3_2	db	williams_A, williams, walking, 4, down+left, v16
		dw	-1, 105, 55, 0, 0, offset sprt_table + 64, nawt_lad
cart_3_3	db	williams_B, williams, walking, 4, down+left, v16
		dw	-1, 107, 60, 0, 0, offset sprt_table + 96, nawt_lad
capt_3_3	db	captainB, captain, walking, 4, down+left, v16
		dw	-1, 108, 60, 0, 0, offset sprt_table + 128, nawt_lad
linda_3_1	db	linda, linda, walking, 4, down+left, v24
		dw	-1, 110, 47, 0, 0, offset sprt_table + 160, 2*wep_list_size + offset weapon_table
capt_3_4	db	captain, captain, walking, 4, down+left, v16
		dw	-1, 120, 55, 0, 0, offset sprt_table + 192, nawt_lad

cart_3_4	db	williams_A, williams, walking, 4, down+left, v16
		dw	-1, 141, 44, 0, 0, offset sprt_table + 64, nawt_lad
cart_3_5	db	williams_B, williams, walking, 4, down+left, v16
		dw	-1, 147, 50, 0, 0, offset sprt_table + 96, nawt_lad
capt_3_5	db	captain, captain, walking, 4, down+left, v16
		dw	-1, 150, 60, 0, 0, offset sprt_table + 128, nawt_lad
capt_3_6	db	captainB, captain, walking, 4, down+left, v16
		dw	-1, 152, 55, 0, 0, offset sprt_table + 160, nawt_lad

capt_3_7	db	captainB, captain, jump_kicking, 8, down+left, v16
		dw	-1, 157, 40, 1, -4, offset sprt_table + 64, nawt_lad
cart_3_6	db	williams_A, williams, jumping, 8, down+left, v16
		dw	-1, 195, 40, 1, -6, offset sprt_table + 96, nawt_lad
cart_3_7	db	williams_B, williams, jump_kicking, 8, down+left, v16
		dw	-1, 195, 40, -1, -5, offset sprt_table + 128, nawt_lad


capt_3_8	db	captainC,captain , jump_kicking ,16 , down+left ,v16
		dw	-1,304,48-12 ,-1,-4 ,offset sprt_table + 64,nawt_lad

;	player1 so that offset on definition is just zero 

combine_3_1	db	wepon , wepon , weapact , 4 , down+right , 100 ;hope that I cant hit it !
		dw	offset comb1_l ,290 ,48 ,0,0, offset sprt_table + 96 ,nawt_lad
combine_3_2	db	wepon , wepon , weapact , 4 , down+right , 100 ;hope that I cant hit it !
		dw	offset comb1_c ,302 ,48 ,0,0, offset sprt_table + 128 ,nawt_lad
combine_3_3	db	wepon , wepon , weapact , 4 , down+right , 100 ;hope that I cant hit it !
		dw	offset comb1_c ,310 ,48 ,0,0, offset sprt_table + 160 ,nawt_lad
combine_3_4	db	wepon , wepon , weapact , 4 , down+left , 100 ;hope that I cant hit it !
		dw	offset comb1_l ,318 ,48 ,0,0, offset sprt_table + 192 ,nawt_lad	;flip this one

;	The combine WILL HAVE TO fit in 4 sprites
;	the 4 is so that the blade is quite small in memory
;	But also not so wide as too make me need a bleeding sprite routine !

roper_3_1	db	roper,roper , walking , 4  ,down+left ,v16
		dw	-1,344,44 , 0,0 ,offset sprt_table+64 ,nawt_lad

cart_3_8	db	williams_C, williams, walking, 4, down+left, v16
		dw	-1, 387, 50, 0, 0, offset sprt_table + 64, nawt_lad
cart_3_9	db	williams_A, williams, walking, 4, down+left, v16
		dw	-1, 385, 54, 0, 0, offset sprt_table + 96, nawt_lad
cart_3_10	db	williams_B, williams, walking, 4, down+left, v16
		dw	-1, 390, 60, 0, 0, offset sprt_table + 128, nawt_lad

capt_3_9	db	captainC,captain , walking ,4 , down+left ,v16
		dw	-1,450,44 ,0 ,0 ,offset sprt_table + 64,nawt_lad
capt_3_10	db	captainA,captain , walking ,4 , down+left ,v16
		dw	-1,458,44 ,0 ,0 ,offset sprt_table + 96,nawt_lad
capt_3_11	db	captainB,captain , walking ,4 , down+left ,v16
		dw	-1,448,44 ,0 ,0 ,offset sprt_table + 128,nawt_lad
roper_3_2	db	roper,roper , walking , 4  ,down+left ,v16
		dw	-1,470,44 , 0,0 ,offset sprt_table+160,nawt_lad
roper_3_3	db	roper,roper , walking , 4  ,down+left ,v16
		dw	-1,470,44 , 0,0 ,offset sprt_table+192 ,nawt_lad

bill_3_1	db	abobo_A, bill, walking, 4, down+left, v24
		dw	-1, 530, 50, 0, 0, offset sprt_table + 160, nawt_lad
bill_3_2	db	abobo, bill, walking, 4, down+left, v32
		dw	-1, 530, 60, 0, 0, offset sprt_table + 192, nawt_lad



		; LEVEL 4
		; *** was 30

limit_table_4   dw      0, 120,        0, 56

		dw	999, 999,	0, 20


trigger_table_4	dw	0,	offset wigfod_4_1,	2 * per_list_size + offset person_table, 0	;put it at 2
		dw	120,	offset wigfod_4_2,	3 * per_list_size + offset person_table, 0	; next 4 in case of too big !
		dw	120,	offset wigfod_4_3,	4 * per_list_size + offset person_table, 0
		dw	120,	offset lowry_4_1,	5 * per_list_size + offset person_table, 1
;	lowry comes from the door ( hopefully when only 1 wigfod is left ?)
		dw	1000			; end-of-list


wigfod_4_1	db	abobo, abobo, walking, 48, down+left, v32
		dw	-1, 74, 34, 0, 0, offset sprt_table + 64, nawt_lad
wigfod_4_2	db	abobo_A, abobo, walking, 48, down+left, v32
		dw	-1, 140, 32, 0, 0, offset sprt_table + 128, nawt_lad
wigfod_4_3	db	abobo_A, abobo, walking, 48, down+left, v24
		dw	-1, 140, 50, 0, 0, offset sprt_table + 160, nawt_lad

lowry_4_1	db	lowry, lowry, being_dead, 48, down+left, v32
		dw	-1, 120, 32, 0, 0, offset sprt_table + 192, nawt_lad

		; LEVEL 5
		; *** was 230

limit_table_5   dw      0, 70,       0, 16	;need to create a new kill
		dw	170, 200,	20, 68	; routine that destroys
		dw	260, 270,	16, 68	; when off scroll_limits?!
		dw	260, 300,	16, 68	; when off scroll_limits?!
		dw	260, 300,	16, 68	; when off scroll_limits?!
						; ? and off screen ?
		dw	999, 999,	16, 68


trigger_table_5	dw	0,	offset dave_5_1,	2 * per_list_size + offset person_table, 0
		dw	50,	offset cartwheel_5_1,	3 * per_list_size + offset person_table, 0
		dw	90,	offset lowry_5_1,	4 * per_list_size + offset person_table, 0
		dw	90,	offset lowry_5_2,	5 * per_list_size + offset person_table, 1

		dw	196,	offset cartwheel_5_2,	2 * per_list_size + offset person_table, 0
		dw	196,	offset cartwheel_5_3,	3 * per_list_size + offset person_table, 0
		dw	228,	offset bill_5_1,	4 * per_list_size + offset person_table, 0
		dw	247,	offset bill_5_2,	5 * per_list_size + offset person_table, 2

		dw	300,	offset fatty_5_1,	2 * per_list_size + offset person_table, 0
		dw	300,	offset dave_5_2,	3 * per_list_size + offset person_table, 0
		dw	300,	offset fatty_5_2,	4 * per_list_size + offset person_table, 2
		dw	330,	offset roper_5_1,	2 * per_list_size + offset person_table, 0
		dw	330,	offset lowry_5_3,	3 * per_list_size + offset person_table, 0
		dw	330,	offset lowry_5_4,	4 * per_list_size + offset person_table, 0
		dw	330,	offset bb_willy,	5 * per_list_size + offset person_table, 2
frig_limit5 label word
		dw	300,	offset ghost_5_1,	2 * per_list_size + offset person_table, 0
		dw	300,	offset ghost_5_2,	3 * per_list_size + offset person_table, 2
; hmm i cant remember how the ghosts appear they might as well just appear from thin air !
 
		dw	1000			; end-of-list


dave_5_1	db	abobo, abobo, walking, 88, down+left,v24
		dw	-1, 52, 28, 0, 0, offset sprt_table + 64, nawt_lad
cartwheel_5_1	db	williams_A, williams, walking, 88, down+left,v24
		dw	-1, 92, 30, 0, 0, offset sprt_table + 96, nawt_lad
lowry_5_1	db	lowry, lowry, walking, 88, down+left, v24
		dw	-1, 112, 36, 0, 0, offset sprt_table + 128, nawt_lad
lowry_5_2	db	lowry, lowry, walking, 88, down+left,v24
		dw	-1, 118, 34, 0, 0, offset sprt_table + 160, nawt_lad

;	use a scroll stop to force the killing of these before continueing
;	then balls ,spearman , blocks !

;	uh oh these dont want a horizontal scroll atall they need a vertical 
;	one as well oh shite man ! best I can do aint much good either?

cartwheel_5_2	db	williams_C, williams, walking, 32, down+left,v32
		dw	-1, 236, 100, 0, 0, offset sprt_table + 64, nawt_lad
cartwheel_5_3	db	williams, williams, walking, 32, down+left , v32
		dw	-1, 180, 100, 0, 0, offset sprt_table + 96, nawt_lad

bill_5_1	db	bill, bill, walking, 32, down+left,v32
		dw	-1, 228, 100, 0, 0, offset sprt_table + 128 ,nawt_lad
bill_5_2	db	bill, bill, walking, 32, down+left,v32
		dw	-1, 247, 100, 0, 0, offset sprt_table + 192, nawt_lad

;	The next are in the end part of the level.

fatty_5_1	db	fatty, fatty, walking, 32, down+left,v24
		dw	-1, 330, 80, 0, 0, offset sprt_table + 160, nawt_lad
dave_5_2	db	abobo, abobo, walking, 32, down+left,v32
		dw	-1, 330, 85, 0, 0, offset sprt_table + 128, nawt_lad
fatty_5_2	db	fatty, fatty, walking, 32, down+left,v32
		dw	-1, 320, 80, 0, 0, offset sprt_table + 192, nawt_lad

lowry_5_3	db	lowry, lowry, walking, 32, down+left,v32
		dw	-1, 340, 80, 0, 0, offset sprt_table + 64, nawt_lad
roper_5_1	db	roper, player1, jump_kicking, 32, down+left,v32
		dw	-1, 350, 90, -1, 4, offset sprt_table + 128, nawt_lad
lowry_5_4	db	lowry, lowry, jumping, 32, down+left,v32
		dw	-1, 350, 96, -1, 5, offset sprt_table + 160, nawt_lad
bb_willy	db	big_boss_willy, big_boss_willy, walking, 32, down+left,v40
		dw	-1, 340, 87, 0, 0, offset sprt_table + 192, nawt_lad

ghost_5_1	db	ghost, ghost, birth, 32, down+left,v50
		dw	-1, 305, 90, 0, 0, offset sprt_table + 64, nawt_lad
; errrm only two if there are two players though !
ghost_5_2	db	ghost, ghost, birth, 32, down+left,v50
		dw	-1, 328, 90, 0, 0, offset sprt_table + 96, nawt_lad


	else

limit_table_1   dw      0, 15,         	12, 40
		dw	40, 65,		12, 40
		dw	80, 140,	12, 40
		dw	180, 220,	12, 40
		dw	270, 332,	12, 40

		dw	999, 999,	8, 40


trigger_table_1	dw	0,	offset williams_1_1,	2 * per_list_size + offset person_table, 0
		dw	0,	offset williams_1_2,	3 * per_list_size + offset person_table, 0
		dw	35,	offset linda_1_1,	4 * per_list_size + offset person_table, 1

		dw	83,	offset williams_1_3,	2 * per_list_size + offset person_table, 0
		dw	85,	offset williams_1_4,	3 * per_list_size + offset person_table, 0
		dw	82,	offset williams_1_5,	4 * per_list_size + offset person_table, 2
		dw	125,	offset williams_1_6,	2 * per_list_size + offset person_table, 0
		dw	132,	offset abobo_1_1,	3 * per_list_size + offset person_table, 0
		dw	134,	offset williams_1_7,	4 * per_list_size + offset person_table, 1

		dw	200,	offset williams_1_8,	2 * per_list_size + offset person_table, 0
		dw	201,	offset williams_1_9,	3 * per_list_size + offset person_table, 0
		dw	210,	offset linda_1_2,	4 * per_list_size + offset person_table, 0
		dw	211,	offset linda_1_3,	5 * per_list_size + offset person_table, 2
		dw	270,	offset williams_1_10,	2 * per_list_size + offset person_table, 0
		dw	270,	offset williams_1_11,	3 * per_list_size + offset person_table, 0
		dw	300,	offset abobo_1_2,	4 * per_list_size + offset person_table, 1

		dw	1000			; end-of-list


williams_1_1	db	williams_A, williams , walking, 4, down+left,v8
		dw	-1, 65, 60, 0, 0, offset sprt_table + 64, nawt_lad
williams_1_2	db	williams_B, williams, walking, 4, down+left,v8
		dw	-1, 60, 68, 0, 0, offset sprt_table + 96, nawt_lad
linda_1_1	db	williams, williams, walking, 4, down+left, v8
		dw	-1, 0, 70, 0, 0, offset sprt_table + 128, offset weapon_table

williams_1_3	db	williams_A, williams, walking, 4, down+left, v8
		dw	-1, 113, 62, 0, 0, offset sprt_table + 64, nawt_lad
williams_1_4	db	williams_B, williams, walking, 4, down+right, v8
		dw	-1, 115, 70, 0, 0, offset sprt_table + 96, nawt_lad
williams_1_5	db	williams,williams, walking, 4, down+left, v8
		dw	-1, 117, 65, 0, 0, offset sprt_table + 128, nawt_lad
williams_1_6	db	williams_A, williams, walking, 4, down+left, v8
		dw	-1, 165, 70, 0, 0, offset sprt_table + 64, nawt_lad	;wep_list_size + offset weapon_table
abobo_1_1	db	williams , williams, walking, 4, down+left, v16
		dw	-1, 170, 70, 0, 0, offset sprt_table + 128, nawt_lad
williams_1_7	db	williams_B, williams, walking, 4, down+left, v16
		dw	-1, 165, 66, 0, 0, offset sprt_table + 96, nawt_lad

linda_1_2	db	williams, williams, walking, 4, down+left, v12
		dw	-1, 250, 60, 0, 0, offset sprt_table + 64, 3*wep_list_size + offset weapon_table
williams_1_8	db	williams_A, williams, walking, 4, down+left, v12
		dw	-1, 270, 65, 0, 0, offset sprt_table + 96, nawt_lad
williams_1_9	db	williams_B, williams, walking, 4, down+left, v12
		dw	-1, 260, 75, 0, 0, offset sprt_table + 128, nawt_lad
linda_1_3	db	williams_A, williams, walking, 4, down+left, v12
		dw	-1, 260, 70, 0, 0, offset sprt_table + 160,nawt_lad 		;offset weapon_table MAKE KNIFE
williams_1_10	db	williams_B, williams, walking, 4, down+left, v8
		dw	-1, 300, 70, 0, 0, offset sprt_table + 64, nawt_lad
williams_1_11	db	williams, williams, walking, 4, down+left, v8
		dw	-1, 300, 70, 0, 0, offset sprt_table + 96, nawt_lad
abobo_1_2	db	williams_A, williams, walking, 4, down+left, v24
		dw	-1, 355, 70, 0, 0, offset sprt_table + 128, nawt_lad

; that last one seems a bit of a bugger to work out ?
; let it be a williams and wait for the complaint


		; *** LEVEL 2 ***
		; *** was 45

limit_table_2   dw      0, 50,         0, 124-40
		dw	50, 140,	0, 124-40
		dw	100, 300,	0, 124-40
		dw	105, 300,	0, 124-40
		dw	111, 300,	0, 124-40
		dw	111, 300,	0, 124-40	;grief?
;dw	111, 300,	0, 124-40

		dw	999, 999,	0, 124-40


trigger_table_2	label	word
		dw	0,	offset wigfod_2_1,	2 * per_list_size + offset person_table, 0
		dw	30,	offset linda_2_1 ,	3 * per_list_size + offset person_table, 0
		dw	30,	offset linda_2_2 ,	4 * per_list_size + offset person_table, 2

		dw	104,	offset williams_2_1,	2 * per_list_size + offset person_table, 0
		dw	102,	offset captain_2_1,	3 * per_list_size + offset person_table, 0
		dw	124,	offset williams_2_2,	4 * per_list_size + offset person_table, 0
		dw	126,	offset williams_2_3,	5 * per_list_size + offset person_table, 1

		dw	220,	offset linda_2_3,	2 * per_list_size + offset person_table, 0
		dw	226,	offset williams_2_4,	3 * per_list_size + offset person_table, 0
		dw	228,	offset captain_2_2,	4 * per_list_size + offset person_table, 2

		dw	400,	offset linda_2_4,	2 * per_list_size + offset person_table, 0
		dw	400,	offset linda_2_5,	3 * per_list_size + offset person_table, 0
		dw	400,	offset captain_2_3,	4 * per_list_size + offset person_table, 0	;3
frig_limit2	label	word
		dw	480,	offset williams_2_5,	2 * per_list_size + offset person_table, 0
		dw	480,	offset captain_2_4,	3 * per_list_size + offset person_table, 0
		dw	480,	offset linda_2_6,	4 * per_list_size + offset person_table, 2

		dw	200,	offset abobo_2_1,	5 * per_list_size + offset person_table, 1

		dw	1000			; end-of-list

wigfod_2_1	db	williams_A, williams, walking, 4, down+left,v16	;a big dave
		dw	-1,13, 109, 0, 0, offset sprt_table + 128, nawt_lad
linda_2_1	db	williams_B, williams, walking, 4, down+left, v16
		dw	-1, 110, 122, 0, 0, offset sprt_table + 96,nawt_lad	; 4 * wep_list_size + offset weapon_table
linda_2_2	db	williams, williams, walking, 4, down+left, v16
		dw	-1, 110, 115, 0, 0, offset sprt_table + 64,nawt_lad	; 4 * wep_list_size + offset weapon_table

williams_2_1	db	williams_C, williams, jumping, 16, down+left,v12
		dw	-1, 128, 100, -1, -5, offset sprt_table + 64, nawt_lad
captain_2_1	db	williams_B, williams, jumping, 16, down+left, v12
		dw	-1, 125, 96, -1, -5, offset sprt_table + 96, nawt_lad
williams_2_2	db	williams, williams, jumping, 28, down+left, v12
		dw	-1, 152, 84, -1, -3, offset sprt_table + 128, nawt_lad
williams_2_3	db	williams_A, williams, jumping,28, down+left, v12
		dw	-1, 160, 80, -1, -6, offset sprt_table + 160, nawt_lad

;	Now for those on top level .

linda_2_3	db	williams_C, williams, walking, 53, down+left, v16
		dw	-1, 243, 63, 0, 0, offset sprt_table + 64,nawt_lad	; 4 * wep_list_size + offset weapon_table
williams_2_4	db	williams_A, williams, walking, 53, down+left,v12
		dw	-1, 254, 75, 0, 0, offset sprt_table + 96, nawt_lad
captain_2_2	db	williams, williams, walking, 53, down+left, v12
		dw	-1, 251, 64, 0, 0, offset sprt_table + 128, nawt_lad

linda_2_4	db	williams_C, williams, being_dead, 53, down+left, v16
		dw	-1, 268, 67, 0, 0, offset sprt_table + 64,nawt_lad	; 4 * wep_list_size + offset weapon_table
linda_2_5	db	williams_B, williams, being_dead, 53, down+left, v16
		dw	-1, 270, 67, 0, 0, offset sprt_table + 96,nawt_lad	; 4 * wep_list_size + offset weapon_table
captain_2_3	db	williams_A, williams, being_dead, 53, down+left, v16
		dw	-1, 266, 67, 0, 0, offset sprt_table + 128, nawt_lad

williams_2_5	db	williams_B, williams, being_dead, 53, down+left, v12
		dw	-1, 268, 67, 0, 0, offset sprt_table + 64,nawt_lad	; wep_list_size + offset weapon_table
linda_2_6	db	williams_A, williams, being_dead, 53, down+left, v16
		dw	-1, 270, 67, 0, 0, offset sprt_table + 96,nawt_lad	; 4 * wep_list_size + offset weapon_table
captain_2_4	db	williams, williams, being_dead, 53, down+left, v16
		dw	-1, 266, 67, 0, 0, offset sprt_table + 128, nawt_lad

abobo_2_1	db	williams, williams, walking, 53, down+left, v24
		dw	-1, 310, 76, 0, 0, offset sprt_table + 160, nawt_lad

		; *** LEVEL 3 ***
		; *** was 120

limit_table_3   dw      0, 16,		0, 28	;8 first lot b d
		dw	30, 60,		0, 28	;8 2nd + linda
		dw	30, 95,		0, 28	;
		dw	70, 200,	0, 28	;

		dw	170,260,	0,28	;the 1st combine stop
		dw	200,278,	0,28	;when roper is on ?

; use these scroll points to stop player seeing that combine has been lost

		dw	314,355,	0,28	;enemys after roper

		dw	320, 540,	0, 28	;all the 6 !
		dw	430, 540,	0, 28	;the bills

 		dw	999, 999,	0, 28


trigger_table_3	label	word
		dw	0,	offset dave_3_1,	2 * per_list_size + offset person_table, 0
		dw	0,	offset cart_3_1,	3 * per_list_size + offset person_table, 0
		dw	20,	offset capt_3_1,	4 * per_list_size + offset person_table, 0
		dw	20,	offset capt_3_2,	5 * per_list_size + offset person_table, 1
	
		dw	68,	offset cart_3_2,	2 * per_list_size + offset person_table, 0
		dw	69,	offset cart_3_3,	3 * per_list_size + offset person_table, 0
		dw	73,	offset capt_3_3,	4 * per_list_size + offset person_table, 0
		dw	75,	offset linda_3_1,	5 * per_list_size + offset person_table, 0
		dw	80,	offset capt_3_4,	6 * per_list_size + offset person_table, 1


		dw	126,	offset cart_3_4,	2 * per_list_size + offset person_table, 0
		dw	126,	offset cart_3_5,	3 * per_list_size + offset person_table, 0
		dw	132,	offset capt_3_5,	4 * per_list_size + offset person_table, 0
		dw	135,	offset capt_3_6,	5 * per_list_size + offset person_table, 2

		dw	176,	offset capt_3_7,	2 * per_list_size + offset person_table, 0
		dw	196,	offset cart_3_6,	3 * per_list_size + offset person_table, 0
		dw	196,	offset cart_3_7,	4 * per_list_size + offset person_table, 1

		dw	260,	offset	combine_3_1,	3 * per_list_size + offset person_table, 0
		dw	260,	offset	combine_3_2,	4 * per_list_size + offset person_table, 0
		dw	260,	offset	combine_3_3,	5 * per_list_size + offset person_table, 0
		dw	260,	offset	combine_3_4,	6 * per_list_size + offset person_table, 0

		dw	292,	offset capt_3_8,	2 * per_list_size + offset person_table, 1
 
		dw	316,	offset roper_3_1,	2 * per_list_size + offset person_table, 2

		dw	364,	offset cart_3_8,	2 * per_list_size + offset person_table ,0
		dw	370,	offset cart_3_9,	3 * per_list_size + offset person_table ,0
		dw	368,	offset cart_3_10,	4 * per_list_size + offset person_table ,2

		dw	420,	offset capt_3_9,	2 * per_list_size + offset person_table ,0
		dw	432,	offset capt_3_10,	3 * per_list_size + offset person_table ,0
		dw	426,	offset capt_3_11,	4 * per_list_size + offset person_table ,0
		dw	450,	offset roper_3_2,	5 * per_list_size + offset person_table ,0
		dw	450,	offset roper_3_3,	6 * per_list_size + offset person_table ,2

		dw	500,	offset bill_3_1,	2 * per_list_size +offset person_table ,0
		dw	501,	offset bill_3_2,	3 * per_list_size +offset person_table ,2

		dw	1000	;end here
; could we have different sprites nah it means weapon changes

dave_3_1	db	williams_A, williams, walking, 4, down+left, v16
		dw	-1, 14, 40, 0, 0, offset sprt_table + 64, nawt_lad	;offset weapon_table
cart_3_1	db	williams_B, williams, walking, 4, down+left, 16;v16
		dw	-1, 12, 45, 0, 0, offset sprt_table + 96, nawt_lad
capt_3_1	db	williams, williams, walking, 4, down+left, 16;v16
		dw	-1, 72, 55, 0, 0, offset sprt_table + 160, nawt_lad
capt_3_2	db	williams_C, williams, walking, 4, down+left, 16;v16
		dw	-1, 72, 60, 0, 0, offset sprt_table + 128, nawt_lad

cart_3_2	db	williams_A, williams, walking, 4, down+left, v16
		dw	-1, 105, 55, 0, 0, offset sprt_table + 64, nawt_lad
cart_3_3	db	williams_B, williams, walking, 4, down+left, v16
		dw	-1, 107, 60, 0, 0, offset sprt_table + 96, nawt_lad
capt_3_3	db	williams, williams, walking, 4, down+left, v16
		dw	-1, 108, 60, 0, 0, offset sprt_table + 128, nawt_lad
linda_3_1	db	williams_C, williams, walking, 4, down+left, v24
		dw	-1, 110, 47, 0, 0, offset sprt_table + 160, 2*wep_list_size + offset weapon_table
capt_3_4	db	williams, williams, walking, 4, down+left, v16
		dw	-1, 120, 55, 0, 0, offset sprt_table + 192, nawt_lad

cart_3_4	db	williams_A, williams, walking, 4, down+left, v16
		dw	-1, 141, 44, 0, 0, offset sprt_table + 64, nawt_lad
cart_3_5	db	williams_B, williams, walking, 4, down+left, v16
		dw	-1, 147, 50, 0, 0, offset sprt_table + 96, nawt_lad
capt_3_5	db	williams_C, williams, walking, 4, down+left, v16
		dw	-1, 150, 60, 0, 0, offset sprt_table + 128, nawt_lad
capt_3_6	db	williams_A, williams, walking, 4, down+left, v16
		dw	-1, 152, 55, 0, 0, offset sprt_table + 160, nawt_lad

capt_3_7	db	williams_C, williams, jump_kicking, 8, down+left, v16
		dw	-1, 157, 40, 1, -4, offset sprt_table + 64, nawt_lad
cart_3_6	db	williams_A, williams, jumping, 8, down+left, v16
		dw	-1, 195, 40, 1, -6, offset sprt_table + 96, nawt_lad
cart_3_7	db	williams_B, williams, jump_kicking, 8, down+left, v16
		dw	-1, 195, 40, -1, -5, offset sprt_table + 128, nawt_lad


capt_3_8	db	williams,williams , jump_kicking ,16 , down+left ,v16
		dw	-1,304,48-12 ,-1,-4 ,offset sprt_table + 64,nawt_lad

;	player1 so that offset on definition is just zero 

combine_3_1	db	wepon , wepon , weapact , 4 , down+right , 100 ;hope that I cant hit it !
		dw	offset comb1_l ,290 ,48 ,0,0, offset sprt_table + 96 ,nawt_lad
combine_3_2	db	wepon , wepon , weapact , 4 , down+right , 100 ;hope that I cant hit it !
		dw	offset comb1_c ,302 ,48 ,0,0, offset sprt_table + 128 ,nawt_lad
combine_3_3	db	wepon , wepon , weapact , 4 , down+right , 100 ;hope that I cant hit it !
		dw	offset comb1_c ,310 ,48 ,0,0, offset sprt_table + 160 ,nawt_lad
combine_3_4	db	wepon , wepon , weapact , 4 , down+left , 100 ;hope that I cant hit it !
		dw	offset comb1_l ,318 ,48 ,0,0, offset sprt_table + 192 ,nawt_lad	;flip this one

;	The combine WILL HAVE TO fit in 4 sprites
;	the 4 is so that the blade is quite small in memory
;	But also not so wide as too make me need a bleeding sprite routine !

roper_3_1	db	roper,roper , walking , 4  ,down+left ,v16
		dw	-1,344,44 , 0,0 ,offset sprt_table+64 ,nawt_lad

cart_3_8	db	williams_C, williams, walking, 4, down+left, v16
		dw	-1, 387, 50, 0, 0, offset sprt_table + 64, nawt_lad
cart_3_9	db	williams_A, williams, walking, 4, down+left, v16
		dw	-1, 385, 54, 0, 0, offset sprt_table + 96, nawt_lad
cart_3_10	db	williams_B, williams, walking, 4, down+left, v16
		dw	-1, 390, 60, 0, 0, offset sprt_table + 128, nawt_lad

capt_3_9	db	williams_C ,williams , walking ,4 , down+left ,v16
		dw	-1,450,44 ,0 ,0 ,offset sprt_table + 64,nawt_lad
capt_3_10	db	williams_B ,williams , walking ,4 , down+left ,v16
		dw	-1,458,44 ,0 ,0 ,offset sprt_table + 96,nawt_lad
capt_3_11	db	williams_A ,williams , walking ,4 , down+left ,v16
		dw	-1,448,44 ,0 ,0 ,offset sprt_table + 128,nawt_lad
roper_3_2	db	roper,roper , walking , 4  ,down+left ,v16
		dw	-1,470,44 , 0,0 ,offset sprt_table+160,nawt_lad
roper_3_3	db	roper,roper , walking , 4  ,down+left ,v16
		dw	-1,470,44 , 0,0 ,offset sprt_table+192 ,nawt_lad

bill_3_1	db	roper, roper, walking, 4, down+left, v16
		dw	-1, 530, 50, 0, 0, offset sprt_table + 160, nawt_lad
bill_3_2	db	williams_A, williams, walking, 4, down+left, v16
		dw	-1, 530, 60, 0, 0, offset sprt_table + 192, nawt_lad



		; LEVEL 4
		; *** was 30

limit_table_4   dw      0, 120,        0, 56

		dw	999, 999,	0, 20


trigger_table_4	dw	0,	offset wigfod_4_1,	2 * per_list_size + offset person_table, 0	;put it at 2
		dw	120,	offset wigfod_4_2,	3 * per_list_size + offset person_table, 0	; next 4 in case of too big !
		dw	120,	offset wigfod_4_3,	4 * per_list_size + offset person_table, 0
		dw	120,	offset lowry_4_1,	5 * per_list_size + offset person_table, 1
;	lowry comes from the door ( hopefully when only 1 wigfod is left ?)
		dw	1000			; end-of-list

;	for level 4 load up lowry instead.


wigfod_4_1	db	lowry , lowry, walking, 48, down+left, v32
		dw	-1, 74, 34, 0, 0, offset sprt_table + 64, nawt_lad
wigfod_4_2	db	lowry , lowry, walking, 48, down+left, v32
		dw	-1, 140, 32, 0, 0, offset sprt_table + 128, nawt_lad
wigfod_4_3	db	lowry , lowry, walking, 48, down+left, v24
		dw	-1, 140, 50, 0, 0, offset sprt_table + 160, nawt_lad

lowry_4_1	db	lowry, lowry, being_dead, 48, down+left, v32
		dw	-1, 120, 32, 0, 0, offset sprt_table + 192, nawt_lad

		; LEVEL 5
		; *** was 230

limit_table_5   dw      0, 70,       0, 16	;need to create a new kill
		dw	170, 200,	20, 68	; routine that destroys
		dw	260, 270,	16, 68	; when off scroll_limits?!
		dw	260, 300,	16, 68	; when off scroll_limits?!
		dw	260, 300,	16, 68	; when off scroll_limits?!
		dw	260, 300,	16, 68	; extra limit coz bbw m-load
						; ? and off screen ?
		dw	999, 999,	16, 68


trigger_table_5	dw	0,	offset dave_5_1,	2 * per_list_size + offset person_table, 0
		dw	50,	offset cartwheel_5_1,	3 * per_list_size + offset person_table, 0
		dw	90,	offset lowry_5_1,	4 * per_list_size + offset person_table, 0
		dw	90,	offset lowry_5_2,	5 * per_list_size + offset person_table, 1

		dw	194,	offset cartwheel_5_2,	2 * per_list_size + offset person_table, 0
		dw	194,	offset cartwheel_5_3,	3 * per_list_size + offset person_table, 0
		dw	228,	offset bill_5_1,	4 * per_list_size + offset person_table, 0
		dw	247,	offset bill_5_2,	5 * per_list_size + offset person_table, 2

		dw	300,	offset fatty_5_1,	2 * per_list_size + offset person_table, 0
		dw	300,	offset dave_5_2,	3 * per_list_size + offset person_table, 0
		dw	300,	offset fatty_5_2,	4 * per_list_size + offset person_table, 2
		dw	330,	offset roper_5_1,	2 * per_list_size + offset person_table, 0
		dw	330,	offset lowry_5_3,	3 * per_list_size + offset person_table, 0
		dw	330,	offset lowry_5_4,	4 * per_list_size + offset person_table, 2
;	This time bbw appears after the other baddies have died.
		dw	330,	offset bb_willy,	5 * per_list_size + offset person_table, 2
frig_limit5 label word
		dw	300,	offset ghost_5_1,	2 * per_list_size + offset person_table, 0
		dw	300,	offset ghost_5_2,	3 * per_list_size + offset person_table, 2
; hmm i cant remember how the ghosts appear they might as well just appear from thin air !
 
		dw	1000			; end-of-list


dave_5_1	db	williams, williams, walking, 88, down+left,v24
		dw	-1, 52, 28, 0, 0, offset sprt_table + 64, nawt_lad
cartwheel_5_1	db	williams_C, williams, walking, 88, down+left,v24
		dw	-1, 92, 30, 0, 0, offset sprt_table + 96, nawt_lad
lowry_5_1	db	williams_B, williams, walking, 88, down+left, v24
		dw	-1, 112, 36, 0, 0, offset sprt_table + 128, nawt_lad
lowry_5_2	db	williams_A, williams, walking, 88, down+left,v24
		dw	-1, 118, 34, 0, 0, offset sprt_table + 160, nawt_lad

;	use a scroll stop to force the killing of these before continueing
;	then balls ,spearman , blocks !

;	uh oh these dont want a horizontal scroll atall they need a vertical 
;	one as well oh shite man ! best I can do aint much good either?

cartwheel_5_2	db	williams_C, williams, walking, 32, down+left,v32
		dw	-1, 236, 100, 0, 0, offset sprt_table + 64, nawt_lad
cartwheel_5_3	db	williams, williams, walking, 32, down+left , v32
		dw	-1, 180, 100, 0, 0, offset sprt_table + 96, nawt_lad

bill_5_1	db	williams_A, williams, walking, 32, down+left,v32
		dw	-1, 228, 100, 0, 0, offset sprt_table + 128 ,nawt_lad
bill_5_2	db	williams_B, williams, walking, 32, down+left,v32
		dw	-1, 247, 100, 0, 0, offset sprt_table + 192, nawt_lad

;	The next are in the end part of the level.
;	next we will have a reload and have lowrys from now
;	which causes a major problem !! with bbw !!

fatty_5_1	db	lowry, lowry, walking, 32, down+left,v24
		dw	-1, 330, 80, 0, 0, offset sprt_table + 160, nawt_lad
dave_5_2	db	roper, roper, walking, 32, down+left,v32
		dw	-1, 330, 85, 0, 0, offset sprt_table + 128, nawt_lad
fatty_5_2	db	lowry, lowry, walking, 32, down+left,v32
		dw	-1, 320, 80, 0, 0, offset sprt_table + 192, nawt_lad

lowry_5_3	db	lowry, lowry, jump_kicking, 32, down+left,v32
		dw	-1, 348, 100, -1, -4, offset sprt_table + 64, nawt_lad
roper_5_1	db	roper, player1, jumping, 32, down+left,v32
		dw	-1, 350, 90, -1, -4, offset sprt_table + 128, nawt_lad
lowry_5_4	db	lowry, lowry, jump_kicking, 32, down+left,v32
		dw	-1, 350, 96, -1, -5, offset sprt_table + 160, nawt_lad
;	need to have a reload HERE !!
bb_willy	db	big_boss_willy, big_boss_willy, walking, 32, down+left,v40
		dw	-1, 280, 104, 0, 0, offset sprt_table + 192, nawt_lad
; make willy apear on the left hand side hopefully just off screen.?

ghost_5_1	db	ghost, ghost, birth, 32, down+left,v50
		dw	-1, 305, 90, 0, 0, offset sprt_table + 64, nawt_lad
; errrm only two if there are two players though !
ghost_5_2	db	ghost, ghost, birth, 32, down+left,v50
		dw	-1, 328, 90, 0, 0, offset sprt_table + 96, nawt_lad

	endif

; then the ghosts and then thats it !!!!!!!!!

the_end		db	"THE END", 0
fight_text1	db	"LETS FIGHT", 0
fight_text2	db	"PLAYER 1 VS PLAYER 2", 0

dseg		ends

end
