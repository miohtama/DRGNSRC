cseg		segment	public 'code'

assume		cs:cseg, ds:dseg

include		ddeqfile

public		linda_instr, abobo_instr, williams_instr, roper_instr
public		williamsA_instr, williamsB_instr, williamsC_instr
public		boss_instr,captainB_instr,captainC_instr
public		captain_instr,captainA_instr

extrn		x_vel_from_dir:near, rand_num_gen:near, get_surface:near
extrn		near_weapon:near, hurt_em:near, knock_over:near
extrn		drop_his_weapon:near, hit_in_air:near, hit_kneeing:near
extrn		whip_snd:near, gun_snd:near,hit_snd:near

extrn	pnum:near

addrp		macro
		pop	dx
		pop	cx
		pop	ax
		push	ax
		push	cx
		push	dx
		endm


linda_instr:	
		call	rand_num_gen
	xor	seed,7635	;hmm does this affect randomness
		call	frig_action
		call	new_target_lin
		call	home_lin
		call	attack_lin
		ret

abobo_instr:	cmp	frame_no, offset hldup_dr_0
		je	set_hu
		cmp	frame_no, offset hldup_dl_0
		jne	skip_hu
set_hu:		mov	action, holding_up
skip_hu:	call	rand_num_gen
	xor	seed,7635	;hmm does this affect randomness
		call	frig_action
		call	new_target_abo
		call	home_abo
		call	attack_abo
		ret

captainC_instr:	call	rand_num_gen	;each cap gets differing action
		xor	seed,60686
		mov	cyc_test,101b
		jmp	cp_instrs

captainB_instr:	call	rand_num_gen	; by getting a diff rand_run
		xor	seed,2818
		mov	cyc_test,110b
		jmp	cp_instrs

captainA_instr:	call	rand_num_gen	;	in seed
		xor	seed,61669
		mov	cyc_test,011b
		jmp	cp_instrs
captain_instr:	
		mov	cyc_test,100b
cp_instrs:
		cmp	frame_no, offset hldup_dr_0
		je	set_hux
		cmp	frame_no, offset hldup_dl_0
		jne	skip_hux
set_hux:	mov	action, holding_up
skip_hux:
	cmp	action,walking
	jne	no_jump
	cmp	combine_count,48
	jb	no_jump
	mov	action,jumping	;!
	mov	y_vel, jump_vel
	jmp	no_more_intel
no_jump:	;lets hope not too early !

		call	rand_num_gen
		xor	seed,20217	;hmm does this affect randomness
		call	frig_action
		call	new_target_cap
		call	home_cap
		call	attack_cap
no_more_intel:
		ret

williams_instr:	call	rand_num_gen
	xor	seed,7635	;hmm does this affect randomness
		call	frig_action
		call	new_target_wil
		call	home_wil
		call	attack_wil
		ret

williamsA_instr:call	rand_num_gen
	xor	seed,29821	;hmm does this affect randomness
		call	frig_action
		call	new_target_wilA
		call	home_wil
		call	attack_wil
		ret

williamsB_instr:call	rand_num_gen
	xor	seed,50034	;hmm does this affect randomness
		call	frig_action
		call	new_target_wilB
		call	home_wil
		call	attack_wil
		ret

williamsC_instr:call	rand_num_gen
	xor	seed,7902	;hmm does this affect randomness
		call	frig_action
		call	new_target_wilC
		call	home_wil
		call	attack_wil
		ret


roper_instr:	call	rand_num_gen
	cmp	action,walking
	jne	no_jump_rop
	cmp	combine_count,48
	jb	no_jump_rop
	mov	action,jumping	;!
	mov	y_vel, jump_vel
	jmp	no_more_intel
no_jump_rop:	;lets hope not too early !

	xor	seed,31797	;hmm does this affect randomness
		call	frig_action
		call	new_target_rop
		call	home_rop
		call	attack_rop
		ret


boss_instr:	call	rand_num_gen
	xor	seed,17902	;hmm does this affect randomness
		call	frig_action
		call	new_target_bos
		call	home_bos
		call	attack_bos
		ret



frig_action:	cmp	frame_no, offset walk_dr_0
		je	set_walking
		cmp	frame_no, offset walk_dl_0
		jne	continue_1
set_walking:	mov	action, walking
continue_1:	cmp	frame_no, offset clim_r_0
		je	set_climbing
		cmp	frame_no, offset clim_l_0
		jne	continue_2
set_climbing:	mov	action, climbing
continue_2:	ret


set_direction:	cmp	action, walking
		je	new_dir
		cmp	action, holding_up
		jne	old_dir
new_dir:	mov	bh, down+right
		mov	ax, map_x
		sub	ax, cx
		jle	ok_lr
		xor	bh, left+right
ok_lr:		mov	al, height
		cbw
		add	ax, map_y
		sub	ax, dx
		jle	ok_ud
		xor	bh, up+down
ok_ud:		cmp	bh, direction
		je	old_dir
		mov	direction, bh
		mov	frame_no, -1
; just created a newdirection for the walking
; shall i change here ?
old_dir:	mov	al, bl
		cbw
		mov	bx, ax
		ret

new_target_cap:	call	nearest_player
	mov	bp,cyc_test
	test	cycle,bp
;test	cycle, cyc_test	;1010b
		jnz	skip_nt
		jmp	new_target_gw
		ret


new_target_wil:	call	nearest_player
		test	cycle, 1011b
		jnz	skip_nt
		jmp	new_target_gen
skip_nt:	ret

new_target_wilA:call	nearest_player
		test	cycle, 111b
		jnz	skip_nt
		jmp	new_target_gw
		ret

new_target_wilB:call	nearest_player
		test	cycle, 111b
		jnz	skip_nt
		jmp	new_target_gw
		ret

new_target_wilC:call	nearest_player
		test	cycle, 1101b
		jnz	skip_nt
		jmp	new_target_gw
		ret


new_target_abo:	call	nearest_player
		test	cycle, 1110b
		jnz	skip_nt
		jmp	new_target_gen
		ret


new_target_lin:	call	nearest_player
		test	cycle, 10011b
		jnz	skip_nt
		jmp	new_target_gen
		ret


new_target_rop:	call	nearest_player
		test	cycle, 1010b
		jnz	skip_nt
		jmp	new_target_gen
		ret


new_target_bos:	call	nearest_player
		test	cycle, 101010b
		jnz	skip_nt
		jmp	new_target_gen
		ret


new_target_gen:	mov	ax, seed
		and	ax, 1111b
		sub	ax, 8
		pushf
		add	cx, ax
		popf
		call	sgn
		shl	ax, 1
		shl	ax, 1
		add	cx, ax
		test	seed, 1b
		jnz	no_rand_y_lin
		mov	ax, seed
		and	ax, 111b
		sub	ax, 4
		add	dx, ax
no_rand_y_lin:	mov	target_x, cx
		mov	target_y, dx
		test	seed, 11b
		jne	exit_ntg
		call	nearest_wep
exit_ntg:	ret

new_target_gw:	mov	ax, seed	;special for cartwheels !
		and	ax, 1111b
		sub	ax, 8
		pushf
		add	cx, ax
		popf
		call	sgn
		shl	ax, 1
		shl	ax, 1

	test	seed,1b
	jnz	no_cart_rm
	shl	ax,1
	shl	ax,1
	add	cx,ax
	shl	ax,1	;er +/-32
no_cart_rm:
		add	cx, ax
		test	seed, 1b
		jnz	no_rand_y_xx
		mov	ax, seed
		and	ax, 111b
		sub	ax, 4
		add	dx, ax
no_rand_y_xx:	mov	target_x, cx
		mov	target_y, dx
		test	seed, 11b
		jne	exit_ntgx
		call	nearest_wep
exit_ntgx:	
;		test	seed,1100b	;er 
;		jne	exit_ntgy
;	mov	ax,seed
;	and	ax,111b
;	shl	ax,1	;2
;	shl	ax,1
;	shl	ax,1	;8 = 64?
;	add	cx,40	;a long way ready for cart
;exit_ntgy:
		ret





nearest_player:	mov	ax, map_x
		sub	ax, person_table + 8
		call	abs_
		mov	bx, ax
		mov	ax, map_y
		sub	ax, person_table + 10
		call	abs_
		add	bx, ax
		mov	ax, map_x
		sub	ax, person_table + 8 + per_list_size
		call	abs_
		mov	cx, ax
		mov	ax, map_y
		sub	ax, person_table + 10 + per_list_size
		call	abs_
		add	cx, ax
		cmp	byte ptr person_table + 2, being_dead
		jne	pl1_alive
		mov	bx, 9999
pl1_alive:	cmp	byte ptr person_table + 2 + per_list_size, being_dead
		jne	pl2_alive
		mov	cx, 9999
pl2_alive:	
;mov	run_flag,0	;not running ?
		cmp	bx, cx		; bx / cx are the distances !
		jg	target_pl2
target_pl1:	mov	closest_player, player1
		mov	cx, person_table + 8
		mov	dl, byte ptr person_table + 3
		xor	dh, dh
		add	dx, person_table + 10
		jmp	face_target
target_pl2:	mov	closest_player, player2
		mov	bx, cx
		mov	cx, person_table + 8 + per_list_size
		mov	dl, byte ptr person_table + 3 + per_list_size
		xor	dh, dh
		add	dx, person_table + 10 + per_list_size
face_target:	call	set_direction
		ret



nearest_wep:	mov	si, offset weapon_table

next_wep:	cmp	byte ptr [si+2], stationary
		jne	skip_wep
		mov	al, height
		cmp	al, [si+3]
		jne	skip_wep
		mov	ax, map_x
		sub	ax, [si+6]
		call	abs_
		mov	dx, ax
		mov	ax, map_y
		sub	ax, [si+8]
		call	abs_
		add	ax, dx
		cmp	ax, bx
		jl	target_wep
skip_wep:	add	si, wep_list_size
		cmp	si, offset weapon_table + 6 * wep_list_size
		jne	next_wep
		ret
target_wep:	call	pickupable
		jnc	skip_wep
		mov	ax, [si+6]
		mov	al, [si+3]
		cbw
		add	target_x, ax
		mov	ax, [si+8]
		mov	target_y, ax
		ret

pickupable:	cmp	action, walking
		jne	no_p
		mov	al, [si]
		cmp	type_, linda
		je	linda_pickup
		cmp	type_, williams	;cartwheel
		je	linda_pickup
		cmp	type_, captain
		je	captain_pickup
		jmp	no_p

captain_pickup:
		cmp	al, barrel
		jge	yes_p		;GE barrel ! incs CRATE (and BALL)
		cmp	al, club	;well spade really !
		je	yes_p
;	cmp	al,knife
;	je	yes_p		;WHAT TO USE FOR CAPTAIN THROWING ??         
		jmp	no_p

linda_pickup:	
		cmp	al, whip
		je	yes_p
;	cmp	al,knife
;	je	yes_p
		jmp	no_p

no_p:		clc
		ret
yes_p:		stc
		ret




home_wil:
home_rop:
		cmp	action, climbing
		jne	home_lin
		mov	x_vel, 0
		mov	al, height
		cbw
		neg	ax
 		add	ax,target_y
		sub	ax,map_y
		call	sgn
		mov	y_vel, ax
		ret


home_lin:
home_abo:
home_bos:
home_cap:
;		cant climb so do this !

		cmp	action, walking
		je	home_in
		cmp	action, holding_up
		jne	exit_hl
home_in:	mov	ax, target_x
		sub	ax, map_x
		call	sgn
		mov	x_vel, ax
		add	ax, map_x
		mov	test_map_x, ax
		mov	al, height
		cbw
		neg	ax
 		add	ax, target_y
		sub	ax, map_y
		call	sgn
		mov	y_vel, ax
		add	ax, map_y
		mov	test_map_y, ax
		mov	al, height
		mov	test_height, al
		call	get_surface
		cmp	byte ptr reduced_attr, walkable
		jne	who_is_it
exit_hl:	ret
who_is_it:	
;jmp	no_move		;
		cmp	type_, williams
		jg	no_move
test_climb:	cmp	byte ptr reduced_attr, climbable
		je	exit_hl
		cmp	mission, 2
		jne	no_move
		mov	ax, target_y
		cmp	ax, map_y
		jg	exit_hl
no_move:	mov	x_vel, 0
		mov	y_vel, 0
		ret




attack_lin:	call	near_player
		jc	att_mov_lin
		call	near_weapon
		jc	pick_wep_lin
		ret
att_mov_lin:	cmp	action, walking
		jne	exit_al
		test	seed, 1001b
		jnz	exit_al
		mov	frame_no, -1
		cmp	weapon_held, nawt_lad
		je	lin_punch
		mov	action, whipping
		mov	si, weapon_held
		mov	byte ptr [si+2], being_used
		mov	word ptr [si+4], -1
		call	whip_snd
		ret
lin_punch:	mov	action, punching
		ret
pick_wep_lin:	call	pickupable
		jnc	exit_al
		mov	action, picking_up_s
		mov	frame_no, -1
		mov	weapon_held, si
		mov	byte ptr [si+2], being_carried
		mov	word ptr [si+4], -1
		addrp
		mov	word ptr [si+16], ax
exit_al:	ret

hit_player:
;	on this frame hit the player ! also 1/4 or dead player
;	throw player aside .
	call	hit_snd		;make a sound always !
	mov	si, offset person_table
	cmp	closest_player, player1
	je	abo_thrw_pl1
	add	si, per_list_size
abo_thrw_pl1:
	sub	byte ptr [si+5], 1	;lose just 1 2 is a bit much !
	jge	str_pos	;a fix for -ve strengths
	mov	byte ptr [si+5], 0
	jmp	auto_throw	;always throw away when <0 str
str_pos:
	test	seed,11100b	;? er hmm 1/4 ?
	jnz	no_throw_away	;1/8 chance to hold on to player !
auto_throw:
	mov	action,walking
	mov	frame_no,-1	;make bill walking again
	mov	byte ptr [si+2] , flying_side
	mov	word ptr [si+6] , -1; back to life !
	mov	al,direction	;reload it !
	call	x_vel_from_dir	; nb direction of bill
	shl	ax,1			;mega dangerous frig ! fast throw away !
	mov	word ptr [si+12] , ax	;ABOBOS CANNOT CARRY CRATES ETC !
	mov	word ptr [si+14] , -1	;fly into the air a bit  !
no_throw_away:
	ret	;do naught else for moment

attack_abo:
		cmp	frame_no,offset knee_r_3
		je	hit_player
		cmp	frame_no,offset knee_l_3
		je	hit_player
		call	near_player
		jc	att_mov_abo
		jmp	exit_aa	;forget all weapon shit
att_mov_abo:	
		test	seed, 1b
		jnz	exit_aa
		cmp	action, walking
		je	abo_punch
exit_aa:	ret

abo_punch:	mov	si, offset person_table
		cmp	closest_player, player1
		je	abo_hit_pl1
		add	si, per_list_size
abo_hit_pl1:
	mov	frame_no, -1
	cmp	type_,bill
	jne	no_try_grb
	test	seed,0011b
	jz	grab_player
no_try_grb:
		test	seed, 100100b
		jz	abo_slap
		mov	action, punching
		ret
abo_slap:	mov	action, kicking		; yet another frig
		ret
grab_player:		; bill grabs a player up si pnts to player data
	mov	al,[si+2]
;	Just check a few moves before doing the grab
;	 all other moves will be allowed to be 'grabbed'.
	cmp	al,being_dead
	je	no_try_grb
	cmp	al,collapsing
	je	no_try_grb
	cmp	al,lying
	je	no_try_grb
	cmp	al,weapact	
	je	no_try_grb

	mov	action , kneeing		;bills action
	mov	byte ptr [si+2] , weapact	; nullify player movement
	mov	word ptr [si+6] , offset grabbd_1; stop player moving
	mov	word ptr [si+12] , 0	;zero velocitys ; I hope !
	mov	word ptr [si+14] , 0	;zeroize.
	mov	ax,map_y
	mov	[si+10],ax
	mov	al,height	;give the player a posn same as the bill !
	mov	[si+3],al
	mov	al, direction
	xor	al,left+right	;swap direction
	mov	[si+4],al	;player faces the bill.
	call	drop_his_weapon	;drop players wep when grabbed.
	ret

dir_cart:		;code code even more bloody code


		mov	bh, right
	mov	x_vel,1		;	hmm hmm hmm
	mov	y_vel,0		; the camera never lies anymore cause theres
		mov	ax,map_x
		sub	ax,cx	;cx ?
		jle	ok_lrx
		xor	bh, left+right
		neg	word ptr x_vel
ok_lrx:
	call	abs_	;makes ax the abs of distance !
		cmp	bh,direction
		je	old_dirx
		mov	direction,bh
		mov	frame_no, -1	;hmm hmm hmm ?! means er get start of anim
old_dirx:
		xchg	ax,bx		;mov	al, bl
		cbw
		xchg	ax,bx		;mov	bx, ax
		ret

dist_x:
		mov	ax,map_x
		sub	ax,cx	;cx ?
		call	abs_
		ret

try_run:
;call	home_wil	;home ??? 
;call	set_direction	;as is walking then will set a direction

	call	nearest_player	;ha ! found a glitch
;test	seed,1000b	; and ?
;jz	not_run
		test	cycle,1001b
		jz	not_run
	cmp	x_vel,0
	je	not_run		;hmm hmm

	call	dist_x

	cmp	ax,30	;10 ?
	jl	not_run	;too near !
	cmp	ax,50
	jg	not_run	;too far !

	call	dir_cart	;fixes y_vels to zero	ax = abs distance 
;call	x_vel_from_dir	;Jees ! its bloody silly this 

	cmp	x_vel,0
	je	not_run		;hmm hmm
		mov	action,running	;attempt number one !
not_run:	
		ret

attack_wil:
		call	near_player
		jc	att_mov_wil
		call	near_weapon
		jc	pick_wep_wil
	cmp	type_,williams	; special frigg 
	jne	not_run		;it may be a lowry !
		cmp	action,walking
		je	try_run
		ret

att_mov_wil:	cmp	action, walking
		jne	exit_aw
		test	seed, 101b
		jnz	exit_aw
		mov	frame_no, -1
		cmp	weapon_held, nawt_lad
		je	wil_punch

		mov	si, weapon_held
		cmp	byte ptr [si],knife
		je	wil_knife
		mov	action, whipping
		mov	byte ptr [si+2], being_used
		mov	word ptr [si+4], -1
		ret
wil_knife:			;ignore for the moment !
		ret
wil_punch:	test	seed, 1010b
		jz	wil_jk
		mov	action, punching
		ret
wil_jk:		mov	action, jump_kicking
		mov	y_vel, jk_vel
		mov	al, direction
		call	x_vel_from_dir
		mov	x_vel, ax
		ret
pick_wep_wil:
		call	pickupable
		jnc	exit_aw
		mov	action, picking_up_s
		mov	frame_no, -1
		mov	weapon_held, si
		mov	byte ptr [si+2], being_carried
		mov	word ptr [si+4], -1
		addrp
		mov	word ptr [si+16], ax
exit_aw:	ret



attack_rop:	call	near_player
		jc	att_mov_rop
		ret
att_mov_rop:	cmp	action, walking
		jne	exit_ar
		mov	frame_no, -1
		test	seed,101b
		jz	rop_punch
		test	seed, 10b
		jz	rop_rev_move
;test	seed, 100b
;jz	rop_throw
;mov	action, head_butting
		ret
rop_throw:	ret
rop_rev_move:	xor	byte ptr direction, left+right
		test	seed, 100b
		jz	rop_elbow
		mov	action, turn_kicking
		mov	y_vel, tk_vel
		ret
rop_elbow:	mov	action, elbowing
		ret
rop_punch:	mov	action, punching
exit_ar:	ret



attack_bos:	cmp	action, walking
		jne	exit_ab
		call	near_player
		jc	bos_kick
		call	in_line
		jc	bos_fire
exit_ab:	cmp	action, punching
		jne	really_exit
		call	gun_snd
really_exit:	ret
bos_kick:	test	cycle, 1000b
		jnz	exit_ab
		mov	action, kicking
		mov	frame_no, -1
		ret
bos_fire:	test	seed, 101101b
		jnz	exit_ab
		mov	action, punching
		mov	frame_no, -1
		mov	si, offset weapon_table + 5 * wep_list_size
		mov	byte ptr [si], club
		mov	byte ptr [si+2], stationary
		mov	byte ptr [si+3], 12
		mov	word ptr [si+4], offset gunfire_0
		mov	al, direction
		call	x_vel_from_dir
		shl	ax, 1
		shl	ax, 1
		shl	ax, 1
		add	ax, map_x
		mov	word ptr [si+6], ax
		mov	ax, map_y
		sub	ax, 8
		mov	word ptr [si+8], ax
		mov	word ptr [si+16], nobody
		mov	si, offset person_table
		cmp	closest_player, player1
		je	shoot_pl1
		add	si, per_list_size
shoot_pl1:	call	hit_in_air
		call	hit_kneeing
		call	drop_his_weapon
		mov	al, 5
		call	hurt_em
		ret

;************************************************************

attack_cap:
		call	in_line
		jp_c	cap_throw
try_uther:
		call	near_player
		jp_c	att_mov_cap
		call	near_weapon
		jp_c	pick_wep_cap
		ret

pick_wep_cap:
	cmp	weapon_held,nawt_lad
	jne	exit_pwc
		call	pickupable
		jnc	exit_pwc
		cmp	al,club
		je	izzasmall
		mov	action, picking_up_l
		mov	frame_no, -1
		mov	weapon_held, si
		mov	byte ptr [si+2], being_picked_up
		mov	word ptr [si+4], -1
		addrp
		mov	word ptr [si+16], ax
exit_pwc:	ret

;		mov	action, picking_up_s
;		mov	frame_no, -1
;		mov	weapon_held, si
;		mov	byte ptr [si+2], being_carried
;		mov	word ptr [si+4], -1
;		addrp
;		mov	word ptr [si+16], ax
;exit_aw:	ret

izzasmall:	mov	action, picking_up_s
		mov	frame_no, -1
		mov	weapon_held, si
		mov	byte ptr [si+2], being_carried
		mov	word ptr [si+4], -1
		addrp
		mov	word ptr [si+16], ax
		ret

att_mov_cap:
		cmp	action, walking
		jne	exit_pwc
		test	seed, 101b	;less or more likely ????
		jnz	exit_pwc
		mov	frame_no, -1
		cmp	weapon_held, nawt_lad
		je	cap_punch
		mov	si, weapon_held
		cmp	byte ptr [si],knife
		je	cap_knife
		cmp	byte ptr [si],club
		jne	exit_cpth		;if not club then exit!
		mov	action, club_swinging	;bloody thumbs !
		mov	byte ptr [si+2], being_used
		mov	word ptr [si+4], -1
exit_cpth:
		ret
cap_throw:
		cmp	action,holding_up
		jp_ne	try_uther
		mov	action,throwing_rock
		mov	frame_no, -1
		mov	si,weapon_held
		mov	weapon_held, nawt_lad
		mov	word ptr [si+16], nobody
		mov	byte ptr [si+2], dropping
		mov	word ptr [si+4], -1
		mov	word ptr [si+12], -1
		mov	al, direction
		call	x_vel_from_dir	;hmm  AL ???
		mov	word ptr [si+10], ax
		ret


cap_knife:	;ignore for the moment !
		ret
cap_punch:	test	seed, 1010b
		jz	cap_jk
		mov	action, punching
		ret
cap_jk:	
		test	cycle, 10b
		jz	cap_rev_move
		mov	action, jump_kicking
		mov	y_vel, jk_vel
		mov	al, direction
		call	x_vel_from_dir
		mov	x_vel, ax
exit_acap:
		ret
cap_rev_move:
		xor	byte ptr direction, left+right
		mov	action, turn_kicking
		mov	y_vel, tk_vel
		ret

;************************************************************

near_player:	mov	ax, person_table + 8
		sub	ax, map_x
		call	abs_
	cmp	byte ptr person_table+2 ,being_dead
	je	try_nr_pl2
		cmp	ax, 3
		jl	try_nr_pl2
		cmp	ax, 7
		jg	try_nr_pl2
		mov	al, byte ptr person_table + 3
		sub	al, height
		cbw
		add	ax, person_table + 10
		sub	ax, map_y
		cmp	ax, -1
		jl	try_nr_pl2
		cmp	ax, 1
		jle	yes_np
try_nr_pl2:	mov	ax, person_table + 8 + per_list_size
		sub	ax, map_x
		call	abs_
	cmp	byte ptr person_table+2+per_list_size ,being_dead
	je	no_np	;if he is dead then do not attack !
		cmp	ax, 3
		jl	no_np
		cmp	ax, 7
		jg	no_np
		mov	al, byte ptr person_table + 3 + per_list_size
		sub	al, height
		cbw
		add	ax, person_table + 10 + per_list_size
		sub	ax, map_y
		cmp	ax, -1
		jl	no_np
		cmp	ax, 1
		jle	yes_np

no_np:		clc
		ret
yes_np:		stc
		ret

in_line:	mov	al, height
		cbw
		neg	ax
		add	ax, target_y
		sub	ax, map_y
		cmp	ax, -1
		jl	no_il
		cmp	ax, 1
		jle	yes_il

no_il:		clc
		ret
yes_il:		stc
		ret


sgn:		lahf				; returns sign of last
		rol	ax, 1			; result, in ax
		rol	ax, 1
		and	ax, 3
		dec	ax
		neg	ax
		ret


abs_:		and	ax, ax			; ax := abs (ax)
		jg	ax_pos
		neg	ax
ax_pos:		ret




cseg		ends




dseg		segment	public 'data'

extrn		person_table:word, map_x:word, map_y:word, x_vel:word
extrn		y_vel:word, height:byte, action:byte, frame_no:word
extrn		walk_dr_0:word, walk_dl_0:word, cycle:word, seed:word
extrn		direction:byte, clim_r_0:word, clim_l_0:word, mission:word
extrn		weapon_held:word, target_x:word, target_y:word, seed:word
extrn		test_map_x:word, test_map_y:word, test_height:byte
extrn		reduced_attr:byte, weapon_table:word, name_:byte, type_:byte
extrn		gunfire_0:word, hldup_dr_0:word, hldup_dl_0:word
extrn		combine_count:word,grabbd_1:word,knee_r_3:word,knee_l_3:word

closest_player	db	?
cyc_test	dw	?

dseg		ends


end
