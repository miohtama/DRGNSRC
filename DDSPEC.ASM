cseg		segment public 'code'

assume		cs:cseg, ds:dseg

include		ddeqfile

public		special_bkgds, undoor

extrn		draw_rect:near, undraw_rect:near, knock_over:near, hurt_em:near,drop_his_weapon:near
extrn		load_wep:near, save_wep:near, splash_snd:near, bounce_snd:near
extrn		rect_offscrn:near,set_vga:near
extrn	are_all_dead:near,level5_reload:near

extrn	pnum:near

special_bkgds:	
		mov	al, mission
		dec	al
		shl	al, 1
		jmptab	al, spec_bkgd_tab

spec_bkgd_tab:	dw	offset missn_1_spec
		dw	offset missn_2_spec
		dw	offset missn_3_spec
		dw	offset missn_4_spec
		dw	offset missn_5_spec




missn_1_spec:	
;call	missn1_door
;call	missn1_wall
		ret


;missn1_door:	
;		mov	al, door_state
;		and	al, al
;		jz	test_open_1
;		cmp	al, closed
;		jge	end_door_1
;		cmp	al, opened
;		jl	open_1
;		jg	no_popup_1
;		mov	byte ptr person_table + 2 + 3 * per_list_size, walking
;		mov	word ptr weapon_table + 4, -1
;no_popup_1:	cmp	al, closing
;		jl	draw_door_1
;
;close_1:	inc	door_map_x
;		sub	rect_cols, 2
;		jmp	draw_door_1
;
;open_1:		dec	door_map_x
;		add	rect_cols, 2
;
;draw_door_1:	mov	ax, door_map_x
;		sub	ax, scrn_left
;		mov	rect_x, ax
;		mov	ax, door_map_y
;		sub	ax, scrn_top
;		shl	ax, 1
;		shl	ax, 1
;		mov	rect_y, ax
;		call	draw_rect
;
;end_door_1:	ret
;
;test_open_1:	mov	ax, furthest_reachd
;		cmp	ax, door_trigger
;		jl	end_door_1
;		inc	door_state
;		ret
;
;
;missn1_wall:	mov	al, wall_state
;		and	al, al
;		jz	test_smash_1
;		cmp	al, 12
;		je	abo_out_1
;		jg	no_smash_1
;		inc	wall_state
;		cmp	wall_state, 9
;		jne	exit_m1w
;		call	bounce_snd
;exit_m1w:	ret
;abo_out_1:	inc	wall_state
;		inc	word ptr person_table + 10 + 4 * per_list_size
;		ret
;test_smash_1:	cmp	furthest_reachd, 224
;		jl	no_smash_1
;		inc	wall_state
;		mov	si, offset weapon_table + 4 * wep_list_size
;		mov	byte ptr [si], specwep
;		mov	byte ptr [si+2], stationary
;		mov	byte ptr [si+3], 8
;		mov	word ptr [si+4], offset smash_1_0
;		mov	word ptr [si+6], 239
;		mov	word ptr [si+8], 38
;		mov	word ptr [si+16], nobody
;no_smash_1:	ret




missn_2_spec:	call	missn2_door
		call	conv_belt	;just lose for moment.

		ret


missn2_door:
		mov	al, door_state
		and	al, al
		jz	test_open_2
		cmp	al, closed
		jge	end_door_2
		cmp	al, opened
		jl	open_2
		jg	no_popup_2
		mov	byte ptr person_table + 2 + 2 * per_list_size, walking
		mov	byte ptr person_table + 2 + 3 * per_list_size, walking
		mov	byte ptr person_table + 2 + 4 * per_list_size, walking
;mov	word ptr weapon_table + 4 + 4 * wep_list_size, -1
no_popup_2:
		cmp	al, closing
		jl	draw_door_2
		jg	close_2
		inc	word ptr person_table + 10 + 2 * per_list_size
		inc	word ptr person_table + 10 + 3 * per_list_size
		inc	word ptr person_table + 10 + 4 * per_list_size
close_2:
		inc	door_map_x
		dec	rect_cols
		jmp	draw_door_2
open_2:
		dec	door_map_x
		inc	rect_cols
draw_door_2:
		mov	ax, door_map_x
		sub	ax, scrn_left
		mov	rect_x, ax
		mov	ax, door_map_y
		sub	ax, scrn_top
		shl	ax, 1
		shl	ax, 1
		mov	rect_y, ax
		call	draw_rect
		ret
end_door_2:
;	The door has closed now .
; hence perhaps 3 should be set NOW 
		mov	limit_flag,3	;Fix it / 1 why doesnt roper appear.
		call	rect_offscrn
	ret

test_open_2:

		mov	ax, furthest_reachd
		cmp	ax, door_trigger
		jl	not_open_2
; first check that door has not been reached !
	call	are_all_dead
	jnz	not_open_2	; hold closed iff not all dead

	mov	word ptr [frig_limit2-8],270
	mov	word ptr [frig_limit2-16],270
	mov	word ptr [frig_limit2-24],270
	inc	door_state
not_open_2:
		ret


conv_belt:	test	byte ptr cycle, 1
		jz	no_convb_mov
		cmp	scrn_left, 240
		jl	no_convb_mov
		mov	si, offset person_table
per_convb_loop:	call	pmov_conv_belt
		add	si, per_list_size
		cmp	si, offset person_table + 7 * per_list_size
		jb	per_convb_loop
		mov	si, offset weapon_table
wep_convb_loop:	call	wmov_conv_belt
		add	si, wep_list_size
		cmp	si, offset weapon_table + 6 * wep_list_size
		jb	wep_convb_loop
no_convb_mov:	ret


pmov_conv_belt:	cmp	byte ptr [si+2], being_dead
		je	pnot_on_belt
		cmp	byte ptr [si+3], 57
		jne	pnot_on_belt
		mov	ax, [si+10]
		cmp	ax, 64
		jl	pnot_on_belt
		cmp	ax, 70
		jg	pnot_on_belt
		mov	ax, [si+8]
		cmp	ax, 290
		jl	pnot_on_belt
		cmp	ax, 310
		jg	pfall_off_belt
		inc	word ptr [si+8]
pnot_on_belt:	ret
pfall_off_belt:	mov	byte ptr [si+2], being_dead
		ret

wmov_conv_belt:	cmp	byte ptr [si+2], nonexistent
		je	wnot_on_belt
		cmp	byte ptr [si+3], 57
		jne	wnot_on_belt
		mov	ax, [si+8]
		cmp	ax, 64
		jl	wnot_on_belt
		cmp	ax, 70
		jg	wnot_on_belt
		mov	ax, [si+6]
		cmp	ax, 290
		jl	wnot_on_belt
		cmp	ax, 310
		jg	wfall_off_belt
		inc	word ptr [si+6]
wnot_on_belt:	ret
wfall_off_belt:	mov	byte ptr [si+2], nonexistent
		ret





missn_3_spec:	
	call	miss3_bale
	call	combine
;call	missn3_door
;cmp	sixteencol,0
;jne	nowater
;call	water
;nowater:
no_rch:
;	mov	si,offset person_table + 10+3 * per_list_size
;	mov	word ptr [ si ] , 44
;	mov	word ptr [ si + per_list_size ] , 44
;	mov	word ptr [ si + per_list_size * 2 ] , 44
;	mov	word ptr [ si + per_list_size * 3 ] , 44
	mov	word ptr combine_count,0	;a kind of null job !
	ret


combine:
	mov	ax,furthest_reachd
	cmp	ax,290
	jb	no_rch
	cmp	ax,330
	ja	no_rch

	cmp	byte ptr person_table +3 * per_list_size , wepon
	jne	no_rch	;only 1 action?
; moves when on screen ( not strictly correct)
	mov	ax,cycle
;shr	ax,1;shr	ax,1;and	ax,15	;er ?
	and	ax,63
	mov	bx,44	;top of animation
	cmp	ax,56
	jl	at_top	;combine is at top of screen
	add	bx,10	;top of anim 8+2?
	sub	ax,60	;-4 to 4
	js	no_neggin
	neg	ax	;-4 to 0 to -4 ?
no_neggin:
	shl	ax,1	;double this ! to speed up
	add	bx,ax	;44+8 -8/0/-8
at_top:
	mov	si,offset person_table + 10+ 3 * per_list_size
	mov	[ si ] , bx
	mov	[ si + per_list_size ] , bx
	mov	[ si + per_list_size * 2 ] , bx
	mov	[ si + per_list_size * 3 ] , bx
	mov	combine_count,bx	;for use by ddintel !
	mov	si,offset person_table + 6 + 3 * per_list_size

	cmp	bx,50
	ja	lrge
	mov	word ptr [si ],offset comb1_l
	mov	word ptr [si + per_list_size ],offset comb1_c
	mov	word ptr [si + per_list_size * 2 ],offset comb1_c
	mov	word ptr [si + per_list_size * 3 ],offset comb1_l

	mov	si,offset person_table + 8+ 3 * per_list_size
	mov	[si ],290
	mov	[si + per_list_size ],302
	mov	[si + per_list_size * 2 ],310
	mov	[si + per_list_size * 3 ],318

	ret
lrge:
	mov	word ptr [si ],offset comb2_l
	mov	word ptr [si + per_list_size ],offset comb2_c
	mov	word ptr [si + per_list_size * 2 ],offset comb2_c
	mov	word ptr [si + per_list_size * 3 ],offset comb2_l

	mov	si,offset person_table + 8+ 3 * per_list_size
	mov	[si ],288
	mov	[si + per_list_size ],302
	mov	[si + per_list_size * 2 ],310
	mov	[si + per_list_size * 3 ],320

;	At this position then the blades kill anything
;	the sprites we should check are the two players
;	and the two poss baddies

	mov	cx,288
	mov	dx,336
	mov	bl,3
	mov	bh,10	;have to jump quite high !
	mov	si,offset person_table
	call	coll_detect
	jnc	no_hit_pl1
	call	knock_over
	call	drop_his_weapon
	mov	al, 5
	call	hurt_em
no_hit_pl1:
	mov	si,offset person_table+per_list_size
	call	coll_detect
	jnc	no_hit_pl2
	call	knock_over
	call	drop_his_weapon
	mov	al, 5
	call	hurt_em
no_hit_pl2:
	mov	si,offset person_table+per_list_size*2
	call	coll_detect
	jnc	no_hit_baddie
	call	knock_over
	call	drop_his_weapon
	mov	al, 5
	call	hurt_em
no_hit_baddie:
	ret

miss3_bale:
; essentially hold the bale there for the moment
	mov	si, offset weapon_table + 4 * wep_list_size

	mov	ax,furthest_reachd
	cmp	ax,200
	ja	not_bales
	cmp	ax,176	;trigger point for captain
	jb	its_bale_1
	cmp	ax,196
	ja	kill_bales
;	Set the bale as the second position
;mov	byte ptr [si+3], 32	;height
	mov	word ptr [si+6], 192	;x
	mov	word ptr [si+8], 26	;y
not_yet:

not_bales:	;dont edit anything !
; leave all as the same
		ret
kill_bales:
		mov	byte ptr [si+2],nonexistent	;kill the bale
		ret
its_bale_1:
		mov	byte ptr [si], specwep
		mov	byte ptr [si+2], stationary
		mov	word ptr [si+4], offset	bale_0
		mov	word ptr [si+16], nobody
		ret



;	Was just the door Ill need to add the shooting star.

missn_4_spec:
	call	miss_4_door
	call	shooting_star
	ret

shooting_star:

	ret	;no star for the moment.


miss_4_door:	mov	al, door_state
		and	al, al
		jz	test_open_4
		cmp	al, closed
		jge	end_door_4
		cmp	al, opened
		jl	open_4
		jg	no_popup_4
		mov	byte ptr person_table + 2 + 5 * per_list_size, walking
		mov	limit_flag, 1
no_popup_4:	cmp	al, closing
		jl	draw_door_4

close_4:	add	door_map_x, 2
		sub	rect_cols, 4
		jmp	draw_door_4

open_4:		sub	door_map_x, 2
		add	rect_cols, 4

draw_door_4:	mov	ax, door_map_x
		sub	ax, scrn_left
		mov	rect_x, ax
		mov	ax, door_map_y
		sub	ax, scrn_top
		shl	ax, 1
		shl	ax, 1
		mov	rect_y, ax
		call	draw_rect

end_door_4:	ret

test_open_4:	mov	ax, furthest_reachd
		cmp	ax, door_trigger
		jl	end_door_4
		inc	door_state
		ret





missn_5_spec:	
;	call	flames
;		call	will_out
;		call	missn5_wall
;		call	missn5_door
;		call	cutie_spr
;	need to frig! in the ghosts and do a reload ?
;	for this level !
;
;call	lev5_hole

	call	load_up_willy
	call	lvl5_balls
	call	set_ghsts
	call	stabbers
	call	missn5_wall
;call	stones
noload:	ret

lvl5_balls:
	mov	ax,scrn_left
	cmp	ax,80
	jl	not_yet_balls
	mov	si,offset weapon_table + 3 * wep_list_size
	cmp	byte ptr [si+2],nonexistent
	jne	not_yet_balls
	mov	byte ptr [si+2],travelling
	mov	byte ptr [si+2+wep_list_size],travelling
not_yet_balls:
	ret

set_ghsts:
	cmp	rchd_ghst,0
	je	no_ghst
;just reached the ghost !
	mov	rchd_ghst,0

	mov	al,[person_table + 2]	;read player 1
	or	al,al
	jz	iz_dead
	mov	al,birth
iz_dead:
	mov	[person_table + 2 + 2 * per_list_size],al

	mov	al,[person_table + 2 + per_list_size ]	;read player 2
	or	al,al
	jz	iz_dead2
	mov	al,birth
iz_dead2:
	mov	[person_table + 2 + 3 * per_list_size],al	;alive at last !

	cmp	sixteencol,3
	jne	no_ghst

;	Special stuff when in VGA mode only.

; once ghosts are here change the background colours

	mov	dx,offset new_pallette	; for when the ghosts are on 
	call	set_vga

;	Also for VGA ghost data is copied and recoloured
;	placed into bill_seg ( and further )
;	but must also check this I think .
;	when loading spr stuff must frig it so seg is bill_seg 
;	not player !

	pushall

	mov	cx,55656/2
	mov	ax,seg pl1_dat1
	mov	ds,ax
	mov	si,offset pl1_dat1	;better be zero
	mov	ax,seg bill_dat
	mov	es,ax
	mov	di,offset bill_dat	;better be zero

	call	move_recolour

	popall

no_ghst:	ret

;	********************************************
move_recolour:
;	Take the data from ds:si and move to es:di
;	also recolour cx words long !
	push	cx
	push	di
rep	movsw		; move first
	pop	di
	pop	cx
;	do recolouring in-situ

	mov	ax,seg ghost_col_table
	mov	ds,ax	;I need some variables
; cx = number of words to convert
	shr	cx,1	;now = number of 4 byte clusters to convert
	mov	loop_var,cx	;in case I use cx !
	mov	bx,offset ghost_col_table

;	Replace shout1/2/3/4 by cx/dx

cvert_lp:
	mov	ax,es:[di]
	mov	word ptr shvar1,ax
	mov	ax,es:[di+2]
	mov	word ptr shvar3,ax
	xor	cx,cx
	xor	dx,dx
	rept	8	;8 pixels ?
	xor	ax,ax	;clear out man !
;call	get_a_pixel

	shl	shvar4,1
	rcl	al,1
	shl	shvar3,1
	rcl	al,1
	shl	shvar2,1
	rcl	al,1
	shl	shvar1,1
	rcl	al,1
	xlat
;call	store_a_pixel
	shr	al,1
	rcl	cl,1
	shr	al,1
	rcl	ch,1
	shr	al,1
	rcl	dl,1
	shr	al,1
	rcl	dh,1
	endm
	mov	ax,cx
	stosw
	mov	ax,dx
	stosw
	dec	loop_var
	jp_ne	cvert_lp

	ret

;********************************************

load_up_willy:

	mov	ax,scrn_left	;use scrn_left!
	cmp	ax,210	;from 250 any more than 200 I suppose
	jl	less_than
	cmp	reload_flg,0
	jp_ne	noload	;already done it !
	call	level5_reload

	mov	reload_flg,100	;!
	ret
less_than:
	mov	reload_flg,0	;<228 force flag to not loaded
	ret


;no_stones:
;	mov	stone_state,0	;clear em out !
;
;	ret

;stones:		mov	si, offset weapon_table + 3 * wep_list_size
;		cmp	furthest_reachd,195	;when we are at this position
;		jl	no_stones
;		cmp	scrn_top,28
;		jg	no_stones	;none if off bottom
;	if here then in the little rectangle that stones will
;	occur in.
;	1. are any stones being initiated
;		cmp	stone_state,0
;		jne	no_stones	;forget (coll_detect?) as stone
;					;is already here !

;	here we are when creating a new animated stone !
;	set up the two anim jobberies !
;	lets make a scroll barrier to moving left ?

;
;		mov	ax, min_x	; if player2 inited b4 here ?
;		add	ax, scrn_left
;		cmp	ax, 200
;		jl	move_stones
;		ret
;move_stones:	cmp	stone_state, 0
;		jne	cont_stone
;		test	seed, 111100b
;		jnz	exit_ms
;		inc	stone_state
;		mov	ax, seed
;		and	ax, 3
;		shl	ax, 1
;		shl	ax, 1
;		shl	ax, 1
;		shl	ax, 1
;		add	ax, 63
;		mov	word ptr [si+6], ax
;		add	ax, 4
;		mov	word ptr [si + 6 + wep_list_size], ax
;exit_ms:	ret;
;cont_stone:	mov	byte ptr [si+2], stationary
;		cmp	stone_state, 2
;		jne	skip_cs1
;		mov	byte ptr [si + 2 + wep_list_size], stationary
;skip_cs1:	cmp	stone_state, 3
;		jne	skip_cs2
;		mov	byte ptr [si + 2 + wep_list_size], nonexistent
;skip_cs2:	cmp	stone_state, 4
;		jne	skip_cs3
;		mov	byte ptr [si+2], nonexistent
;		mov	stone_state, -1
;skip_cs3:	inc	stone_state
;		call	stone_hit
;		ret
;i;nit_stones:	mov	byte ptr [si], specwep
;		mov	byte ptr [si+2], nonexistent
;		mov	byte ptr [si+3], 4
;		mov	word ptr [si+4], offset stone_0
;		mov	word ptr [si+8], 64
;		mov	word ptr [si+16], nobody
;		mov	byte ptr [si + wep_list_size], specwep
;		mov	byte ptr [si + 2 + wep_list_size], nonexistent
;		mov	byte ptr [si + 3 + wep_list_size], 4
;		mov	word ptr [si + 4 + wep_list_size], offset stone_0
;		mov	word ptr [si + 8 + wep_list_size], 68
;		mov	word ptr [si + 16 + wep_list_size], nobody
;		ret
;
;stone_hit:	mov	direction, down+left		; to knock 'em back
;		mov	ax, [si+6]
;		push	ax
;		mov	si, offset person_table
;		sub	ax, [si+8]
;		cmp	ax, 3
;		jg	no_st_hit_1
;		cmp	ax, -12
;		jl	no_st_hit_1
;		cmp	word ptr [si+10], 52
;		jl	no_st_hit_1
;		call	knock_over
;		mov	al, 5
;		call	hurt_em
;no_st_hit_1:	add	si, per_list_size
;		pop	ax
;		sub	ax, [si+8]
;		cmp	ax, 3
;		jg	no_st_hit_2
;		cmp	ax, -12
;		jl	no_st_hit_2
;		cmp	word ptr [si+10], 52
;		jl	no_st_hit_2
;		call	knock_over
;		mov	al, 5
;		call	hurt_em
no_st_hit_2:	ret

no_stab:
	ret
stabbers:	

; does the stabber fire the blobs ???
;	will more than likely leave that bit out I reckon.

	cmp	furthest_reachd,130
	jl	no_stab
	cmp	furthest_reachd,195
	ja	no_stab

; hmm what will turn into a stabber ?
; I think the flames would be best
; hopefully the flames will also do for the stones ?
; then the walls
;	run the stabber animation by off the game 'cycle'
;mov	ax,cycle
;and	ax,31	;?
;cmp	ax,0
;jne	no_stab	;dont do aought!
; set up the stabbers !
	mov	si, offset weapon_table
	mov	bx,[si+4]
	cmp	word ptr [bx],offset stab_1f	;is it that pointer !
	jne	no_stab_test

	mov	cx,128
	mov	dx,135
	mov	bl,84
	mov	bh,104
	mov	si,offset person_table
	call	coll_detect
	jnc	no_stab_pl1
	cmp	word ptr [si+10],38
	ja	no_stab_pl1
	call	knock_over
	mov	al, 3
	call	hurt_em
no_stab_pl1:
	mov	si,offset person_table+per_list_size
	call	coll_detect
	jnc	no_stab_pl2
	cmp	word ptr [si+10],38
	ja	no_stab_pl2
	call	knock_over
	mov	al, 3
	call	hurt_em
no_stab_pl2:
	jmp	no_stab	;forget the rest as anim hasnt finished !
no_stab_test:
	mov	si, offset weapon_table
	cmp	word ptr [si+6] ,8	;if xpos = 8 then still a flame
	je	okayanyway
	cmp	word ptr [si+4] , offset stab_2x
	jp_ne	no_stab	;animation hasnt finished yet so dont restart
	mov	ax,seed	; restart when finished
	xor	ax,cycle
	and	ax,7
	cmp	ax,3	;1/7 ?
	jp_a	no_stab
okayanyway:
	mov	ax,min_plane
		mov	byte ptr [si], specwep
		mov	byte ptr [si+2], stationary
		mov	byte ptr [si+3], al
		mov	word ptr [si+4], offset stab_0
		mov	word ptr [si+6], 147
		mov	word ptr [si+8], 15
		mov	word ptr [si+16], nobody
	add	si,wep_list_size
		mov	byte ptr [si], specwep
		mov	byte ptr [si+2], stationary
		mov	byte ptr [si+3], al
		mov	word ptr [si+4], offset stab_1
		mov	word ptr [si+6], 139
		mov	word ptr [si+8], 19
		mov	word ptr [si+16], nobody

		ret


will_out:	cmp	furthest_reachd, 202
		jl	will_still
		cmp	word ptr person_table + 10 + 3 * per_list_size, 58
		jne	exit_wo
		inc	word ptr person_table + 10 + 3 * per_list_size
exit_wo:	ret
will_still:	mov	word ptr person_table + 6 + 3 * per_list_size, offset walk_dr_0
		ret

nowall:		ret

missn5_wall:	
; just disapears when bill appears!
;	just one wall at a time ie when one dispears the other appears
;	also bill is created.

	cmp	scrn_top,28
	jl	nowall
	cmp	wall_state,2
	jae	kill_wall	;bloody silly !
	mov	wall_state,1
	mov	bx,220
	cmp	furthest_reachd,228
	jl	first_wall
	mov	bx,240
	cmp	furthest_reachd,246
	jl	first_wall
	mov	wall_state,2
	jmp	kill_wall

first_wall:
	mov	si, offset weapon_table + 3 * wep_list_size
	mov	ax,min_plane
		mov	byte ptr [si], specwep
		mov	byte ptr [si+2], stationary
		mov	byte ptr [si+3], al
		mov	word ptr [si+4], offset wall_0
		mov	word ptr [si+6], bx
		mov	word ptr [si+8], 80
		mov	word ptr [si+16], nobody
	add	si,wep_list_size
		mov	byte ptr [si], specwep
		mov	byte ptr [si+2], stationary
		mov	byte ptr [si+3], al
		mov	word ptr [si+4], offset wall_0
		mov	word ptr [si+6], bx
		mov	word ptr [si+8], 90
		mov	word ptr [si+16], nobody
; makes the balls wall as well !
; will need to destory this bit of wall when bill appears

		ret
kill_wall:
	mov	si, offset weapon_table + 3 * wep_list_size
	mov	byte ptr [si+2], nonexistent
	mov	byte ptr [si+2+wep_list_size], nonexistent
	ret

;mov	si, offset weapon_table + 4 * wep_list_size
;	mov	al, wall_state
;		and	al, al
;		jz	init_smash_5_1
;		cmp	al, 1
;		je	smash_go_5_1
;		cmp	al, 10
;		jl	cont_wall_5
;		jne	skip_m5w1
;		jmp	abo_5_1_out
;skip_m5w1:	cmp	al, 11
;		je	init_smash_5_2
;		cmp	al, 12
;		je	smash_go_5_2
;		cmp	al, 19
;		jl	cont_wall_5
;		jne	skip_m5w2
;		jmp	abo_5_2_out
;skip_m5w2:	ret

;init_smash_5_1:	cmp	furthest_reachd, 310
;		jne	no_smash_5
;		mov	byte ptr [si], specwep
;		mov	byte ptr [si+2], stationary
;		mov	byte ptr [si+3], 4
;		mov	word ptr [si+4], offset smash_5_0
;		mov	word ptr [si+6], 333
;		mov	word ptr [si+8], 51
;		mov	word ptr [si+16], nobody
;cont_wall_5:	inc	wall_state
;		ret

;init_smash_5_2:	cmp	furthest_reachd, 370
;		jnz	no_smash_5
;		mov	byte ptr [si], specwep
;		mov	byte ptr [si+2], stationary
;		mov	byte ptr [si+3], 4
;		mov	word ptr [si+4], offset smash_5_0
;		mov	word ptr [si+6], 385
;		mov	word ptr [si+8], 51
;		mov	word ptr [si+16], nobody
;		inc	wall_state
;no_smash_5:	ret
;
;smash_go_5_1:	cmp	furthest_reachd, 340
;		jnz	no_smash_5
;		add	word ptr [si+4], 4
;		inc	wall_state
;		call	bounce_snd
;		ret

;smash_go_5_2:	cmp	furthest_reachd, 380
;		jnz	no_smash_5
;		add	word ptr [si+4], 4
;		inc	wall_state
;		call	bounce_snd
;		ret
;
;abo_5_1_out:	inc	word ptr person_table + 10 + 2 * per_list_size
;		inc	wall_state
;		ret
;
;abo_5_2_out:	inc	word ptr person_table + 10 + 3 * per_list_size
;		inc	wall_state
;		ret




missn5_door:
		mov	al, door_state
		and	al, al
		jz	test_open_5
		cmp	al, closed
		jge	end_door_5
		cmp	al, opened
		jl	open_5
		jg	no_popup_5
		mov	byte ptr person_table + 2 + 6 * per_list_size, walking
no_popup_5:	cmp	al, closing
		jl	draw_door_5

close_5:	add	door_map_x, 2
		sub	rect_cols, 4
		jmp	draw_door_5

open_5:		sub	door_map_x, 2
		add	rect_cols, 4

draw_door_5:	mov	ax, door_map_x
		sub	ax, scrn_left
		mov	rect_x, ax
		mov	ax, door_map_y
		sub	ax, scrn_top
		shl	ax, 1
		shl	ax, 1
		mov	rect_y, ax
		call	draw_rect

end_door_5:	ret

test_open_5:	mov	ax, furthest_reachd
		cmp	ax, door_trigger
		jl	end_door_5
		inc	door_state
		ret



;cutie_spr:
;		cmp	cutie_state, 0
	;	jne	exit_cs
;		cmp	word ptr scrn_left, 370
;		jle	exit_cs
;		mov	si, offset weapon_table + 4 * wep_list_size
;		mov	byte ptr [si], specwep	; Hmm she's a weapon.
;		mov	byte ptr [si+2], stationary
;		mov	byte ptr [si+3], 16
;		mov	word ptr [si+4], offset cutie_td
;		mov	word ptr [si+6], 430
;		mov	word ptr [si+8], 32
;		mov	word ptr [si+10], 0
;		mov	word ptr [si+12], 0
;		mov	word ptr [si+16], nobody
	;	test	word ptr cycle, 1
	;	jz	gunf_on
	;	mov	byte ptr [si+2+wep_list_size], nonexistent
	;	jmp	exit_cs
gunf_on:;	mov	byte ptr [si+2+wep_list_size], stationary
exit_cs:	ret



undoor:		mov	al, door_state
		and	al, al
		jz	exit_undoor
		cmp	al, closed
		jge	exit_undoor
		call	undraw_rect
		inc	door_state
exit_undoor:	ret



coll_detect:
;	multi use collision routine
;	input	si - points to spr-data address
;	cx = lhs of detect	dx = rhs of detect
;	bl = min plane  bh max plane
;	to collide 	cx < xpos < dx
;			bl < plane < bh
;	output	:	carry set for collision
;		:	clear okay !
;	[si+3] = the plane.
;	[si+7] = x position.

	cmp	byte ptr [si+2] , being_dead
	je	no_hit	;we cannot hit a dead man !
	mov	ax,word ptr [si+8]
	cmp	ax,cx
	jl	no_hit
	cmp	ax,dx
	jg	no_hit
	mov	al,byte ptr [si+3]
	cmp	al,bl
	jl	no_hit
	cmp	al,bh
	jg	no_hit
	stc		;jolly japes a collision !
	ret
no_hit:			;it hasnt been hit so return same !
	clc
	ret

cseg		ends




dseg		segment public 'data'

public		door_state, door_map_x, door_map_y, door_trigger, wall_state
public		opened, closing, closed,combine_count

extrn		mission:byte, cycle:word, person_table:byte, weapon_table:byte
extrn		scrn_left:word, splash_0:word, p_splash_0:word, p_null_0:word
extrn		null_0:word, flame_0:word, rect_x:word, rect_y:word, map_x:word
extrn		rect_cols:word, scrn_top:word, max_x:word, smash_1_0:word
extrn		furthest_reachd:word, min_x:word, seed:word, stone_0:word
extrn		direction:byte, smash_5_0:word, walk_dr_0:word
extrn		limit_flag:word,  cutie_state:byte
extrn		sixteencol:byte,frig_limit2:word,bale_0:word
extrn		comb1_l:word,comb1_c:word,comb2_l:word,comb2_c:word
extrn		stone_0:word , stone_1:word , stab_1:word , stab_0:word
extrn	stab_2x:word,max_plane:word,min_plane:word,wall_0:word,stab_1f

public		rchd_ghst

rchd_ghst	dw	0	;a flag !

reload_flg	dw	?	;false
door_state	db	0
door_map_x	dw	?
door_map_y	dw	?
door_trigger	dw	?
opened		db	?
closing		db	?
closed		db	?

wall_state	db	0
stone_state	db	0
door_speed	dw	2	;is this used i dont think so !
combine_count	dw	0	;just for the record

shvar1	db	0
shvar2	db	0
shvar3	db	0
shvar4	db	0
shout1	db	0
shout2	db	0
shout3	db	0
shout4	db	0

loop_var	dw	0

ghost_col_table	label byte
	db	0	,1	,2	,3
	db	14	,3	,7	,7
	db	8	,9	,1	,1
	db	3	,7	,14	,15

stone_posns	dw	193,38
		dw	196,38
		dw	199,38
		dw	193,35
		dw	196,35
		dw	199,35
		dw	193,35
		dw	196,35
		dw	199,35		;just use 8 ?

stone_x	dw	0
stone_y	dw	0	;store the coords of this ere stone !

pal	macro	rv,gv,bv
	db	rv*4,gv*4,bv*4
	endm

new_pallette	label	byte
;	 the list of stuff for the palette
;	I suppose every time the mode is set up I need to change this!

	pal	0,0,0	; very funny indeed hah fucking hah
	pal	15,9,15		;changed for ghosts
	pal	0,6,0
	pal	13,7,13		;changed for ghosts
	pal	6,6,15
	pal	14,8,8
	pal	14,12,0
	pal	9,0,9		;changed for ghosts
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

pl1_seg1	segment	public	'data'
extrn	pl1_dat1:word
pl1_seg1	ends

bill_seg	segment	public	'data'
extrn	bill_dat:word
bill_seg	ends

end
