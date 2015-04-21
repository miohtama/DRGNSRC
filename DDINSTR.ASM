cseg		segment	public 'code'

assume		cs: cseg, ds: dseg

public		get_instr, x_vel_from_dir

extrn		return:near, near_weapon:near, linda_instr:near
extrn		abobo_instr:near, williams_instr:near, roper_instr:near
extrn		williamsA_instr:near, williamsB_instr:near
extrn		williamsC_instr:near, boss_instr:near, knock_over:near
extrn		whip_snd:near
extrn		captain_instr:near,captainA_instr:near
extrn		captainB_instr:near,captainC_instr:near

include		ddeqfile

get_instr:	jmptab	name_, instr_table

instr_table:	dw	offset player1_instr
		dw	offset williams_instr
		dw	offset abobo_instr
		dw	offset linda_instr
		dw	offset boss_instr
		dw	offset player2_instr
		dw	offset williamsA_instr
		dw	offset williamsB_instr
		dw	offset williamsC_instr
		dw	offset abobo_instr
		dw	offset abobo_instr
		dw	offset roper_instr
		dw	offset captain_instr	;for captain !
		dw	offset abobo_instr	;for bill ! ( bit simple !)
		dw	offset williams_instr	;lowry (stickman)
		dw	offset captainA_instr
		dw	offset captainB_instr
		dw	offset captainC_instr
		dw	offset abobo_instr	;fatty is an abobo !
		dw	offset no_instr	;weapon
		dw	offset roper_instr	;at first for ghost

no_instr:
	ret

player1_instr:	call	joystick_fudlr
		jmp	player_instr

player2_instr:	call	keybd_fudlr

player_instr:	mov	di, weapon_held
		cmp	frame_no, offset hldup_dr_0
		je	freeze_hu
		cmp	frame_no, offset hldup_dl_0
		je	freeze_hu
		cmp	frame_no, offset walk_dr_0
		je	freeze
		cmp	frame_no, offset walk_dl_0
		jne	old_action
freeze:		mov	action, standing
		cmp	di, nawt_lad
		je	old_action
		cmp	byte ptr [di], barrel
		jl	old_action
freeze_hu:	mov	action, hu_standing
old_action:	mov	controls, al
		jmptab	action, control_table

control_table:	dw	offset no_ctrl			; dead
		dw	offset walk_ctrl
		dw	offset no_ctrl			; punch
		dw	offset no_ctrl			; kick
		dw	offset no_ctrl			; jump_kick
		dw	offset turnk_ctrl		; turn_kick
		dw	offset no_ctrl			; elbow
		dw	offset no_ctrl			; head_butt
		dw	offset no_ctrl			; swing_club
		dw	offset no_ctrl			; whip
		dw	offset no_ctrl			; jump
		dw	offset no_ctrl			; thrw_knife
		dw	offset no_ctrl			; throw_rock
		dw	offset climb_ctrl
		dw	offset no_ctrl			; fall
		dw	offset no_ctrl			; collapse
		dw	offset no_ctrl			; get_up
		dw	offset knee_ctrl
		dw	offset no_ctrl			; pick_up_s
		dw	offset no_ctrl			; pick_up_l
		dw	offset no_ctrl			; take_punch
		dw	offset stand_ctrl
		dw	offset no_ctrl			; lie
		dw	offset no_ctrl			; throw_man
		dw	offset no_ctrl			; be_thrown
		dw	offset no_ctrl			; fly_back
		dw	offset no_ctrl			; fly_side
		dw	offset hold_up_ctrl
		dw	offset hu_stand_ctrl
		dw	offset no_ctrl			; be_kneed
		dw	offset no_ctrl			; kick rock
		dw	offset no_ctrl			; running !
		dw	offset no_ctrl			; cartwheel
		dw	offset no_ctrl			; bill dye
		dw	offset no_ctrl			; weapact
		dw	offset no_ctrl			; birth

turnk_ctrl:
;	a simple turn kick should be able to be a whirlwind job
;	on arcade  the whirlwind would continue by itself.
;	cant think where I can have a flag for that???

	push	bx	;cant think an reason but in case !
	mov	bl , al	;save !
	xor	bl , direction
	and	bl , left+right
	jnz	ze_same	;er this seems a bit silly
	xor	direction , left+right		; must flip on the keys
ze_same:pop	bx				; so swap direction !

	ret			;	shall I put whipsnd on this ?

walk_ctrl:
stand_ctrl:	test	al, fire
		jz	walk_fire
		jmp	walk_no_fire
walk_fire:	mov	frame_no, -1
		test	al, up
		jnz	walk_no_jump
		mov	action, jumping
		mov	y_vel, jump_vel
		test	al, left
		jnz	walk_no_jl
		mov	x_vel, -1
		mov	direction, down+left
		ret
walk_no_jl:	test	al, right
		jnz	walk_no_jr
		mov	x_vel, 1
		mov	direction, down+right
walk_no_jr:	ret

no_direct:		; label for a null move.
		ret

walk_no_jump:
;	by here all jumps ( with up key pressed have been sorted )
		test	al, down
		jnz	walk_no_jkick
		not	al
		test	al, left+right
	jz	walk_tk		; no direct then do whirlwind
		and	al, 3
		and	al, direction
		jz	walk_no_jkick	;hopefully if in opp direct then
		mov	action, jump_kicking	; do backwards kick
		mov	y_vel, jk_vel
		mov	al, direction
		call	x_vel_from_dir
		mov	x_vel, ax
		ret
walk_tk:	mov	action, turn_kicking
		mov	y_vel, tk_vel
		ret
walk_butt:	mov	action, head_butting
		ret

walk_no_jkick:	
		test	al, left
		jz	walk_elbokick
		test	al, right
		jz	walk_elbokick
		cmp	weapon_held, nawt_lad
		je	walk_no_wep
		jmp	walk_use_wep
walk_no_wep:	call	near_weapon
		jnc	walk_no_pickup
		mov	weapon_held, si
		cmp	byte ptr [si], barrel
		jge	its_big
		mov	byte ptr [si+2], being_carried
		jmp	over_big
its_big:	mov	byte ptr [si+2], being_picked_up
over_big:	mov	word ptr [si+4], -1
		pop	dx
		pop	ax
		push	ax
		push	dx
		mov	[si+16], ax
		mov	frame_no, -1
		cmp	byte ptr [si], barrel
		jge	walk_pickup_l
		mov	action, picking_up_s
		ret
walk_pickup_l:	mov	action, picking_up_l
		ret

walk_no_pickup:	mov	action, punching
		ret
ordinary_kick:
		mov	action, kicking
		ret

walk_none:	; no move
		ret
walk_elbokick:
		mov	al,controls
		test	al, down	; now is down+left !?
		jz	ordinary_kick	; way to do a back kick
		mov	ah,al
		and	al, 3
		and	al, direction
	jz	walk_kick	;try out the kick barrel job
	mov	al,ah
		cmp	weapon_held, nawt_lad
		je	walk_elbow
		xor	byte ptr direction, left+right
		jmp	walk_use_wep
walk_elbow:	mov	action, elbowing
		ret
walk_kick:	call	near_weapon
		jnc	walk_none
		cmp	byte ptr [si], barrel
		jl	walk_none
		mov	action, kicking_rock
		mov	byte ptr [si+2], travelling
		mov	word ptr [si+4], -1
		mov	al, direction
		call	x_vel_from_dir
		mov	[si+10], ax
		mov	word ptr [si+12], 20
		ret

walk_use_wep:	cmp	byte ptr [di], club
		je	walk_club
		cmp	byte ptr [di], whip
		je	walk_whip
		cmp	byte ptr [di], knife
		je	walk_knife
		cmp	byte ptr [di], tnt
		je	walk_knife
walk_rock:	mov	action, throwing_rock
		ret
walk_club:	mov	action, club_swinging
		mov	byte ptr [di+2], being_used
		mov	word ptr [di+4], -1
		ret
walk_whip:	mov	action, whipping
		mov	byte ptr [di+2], being_used
		mov	word ptr [di+4], -1
		call	whip_snd
		ret
walk_knife:	mov	action, throwing_knife
		mov	byte ptr [di+2], being_used
		mov	word ptr [di+4], -1
		ret

walk_no_fire:	mov	x_vel, 0
		mov	y_vel, 0
		mov	ah, al
		xor	ah, 1fh
		jnz	walk_some_ctrl
		jmp	walk_no_ctrl
walk_some_ctrl:	mov	action, walking
		xor	ah, ah
		test	al, up
		jnz	walk_no_up
		add	ah, up
		mov	y_vel, -1
		jmp	walk_no_down
walk_no_up:	test	al, down
		jnz	walk_no_down
		add	ah, down
		mov	y_vel, 1
walk_no_down:	test	al, left
		jnz	walk_no_left
		add	ah, left
		mov	x_vel, -1
		jmp	walk_no_right
walk_no_left:	test	al, right
		jnz	walk_no_right
		add	ah, right
		mov	x_vel, 1
walk_no_right:	mov	al, ah
		and	al, 3			; left/right		
		jnz	new_lr_dir
		mov	al, direction
		and	al, 3
new_lr_dir:	and	ah, 12			; up/down
		jnz	new_ud_dir
		mov	ah, down
new_ud_dir:	or	al, ah

		xchg	direction, al
		cmp	al, direction
		je	walk_old_dir
		mov	frame_no, -1
walk_old_dir:	ret

walk_no_ctrl:	mov	action, standing
		ret


climb_ctrl:	mov	y_vel, 0
		mov	x_vel, 0
		test	al, up+left
		jz	climb_no_move
		test	al, up+right
		jz	climb_no_move
		test	al, down+left
		jz	climb_no_move
		test	al, down+right
		jz	climb_no_move
		test	al, up
		jnz	climb_no_up
		mov	y_vel, -1
		ret
climb_no_up:	test	al, down
		jnz	climb_no_move
		mov	y_vel, 1
climb_no_move:	ret




hu_stand_ctrl:
hold_up_ctrl:	test	al, fire
		jnz	hu_no_throw
		mov	action, throwing_rock
		mov	frame_no, -1
		mov	weapon_held, nawt_lad
		mov	word ptr [di+16], nobody	; w_bearer
		mov	byte ptr [di+2], dropping	; w_action
		mov	word ptr [di+12], -1		; w_y_vel
		mov	word ptr [di+4], -1		; w_frame_no
		mov	al, direction
		call	x_vel_from_dir
		mov	[di+10], ax			; w_x_vel
		ret

hu_no_throw:	mov	x_vel, 0
		mov	y_vel, 0
		mov	ah, al
		xor	ah, 1fh
		jnz	hu_some_ctrl
		jmp	hu_no_ctrl
hu_some_ctrl:	mov	action, holding_up
		xor	ah, ah
		test	al, up
		jnz	hu_no_up
		add	ah, up
		mov	y_vel, -1
		jmp	hu_no_down
hu_no_up:	test	al, down
		jnz	hu_no_down
		add	ah, down
		mov	y_vel, 1
hu_no_down:	test	al, left
		jnz	hu_no_left
		add	ah, left
		mov	x_vel, -1
		jmp	hu_no_right
hu_no_left:	test	al, right
		jnz	hu_no_right
		add	ah, right
		mov	x_vel, 1
hu_no_right:	mov	al, ah
		and	al, 3			; left/right		
		jnz	hu_new_lr_dir
		mov	al, direction
		and	al, 3
hu_new_lr_dir:	and	ah, 12			; up/down
		jnz	hu_new_ud_dir
		mov	ah, down
hu_new_ud_dir:	or	al, ah

		xchg	direction, al
		cmp	al, direction
		je	hu_old_dir
		mov	frame_no, -1
hu_old_dir:	ret

hu_no_ctrl:	mov	action, hu_standing
		ret




knee_ctrl:
		cmp	frame_no, offset knee_r_3
		je	knee_ctrl_ok
		cmp	frame_no, offset knee_l_3
		je	knee_ctrl_ok
		cmp	frame_no, offset knee_r_1
		je	knee_ctrl_ok
		cmp	frame_no, offset knee_l_1
		je	knee_ctrl_ok
		cmp	frame_no, offset knee_r_5
		je	knee_ctrl_ok
		cmp	frame_no, offset knee_l_5
		je	knee_ctrl_ok
		cmp	frame_no, offset knee_r_7
		je	knee_ctrl_ok
		cmp	frame_no, offset knee_l_7
		je	knee_ctrl_ok
		cmp	frame_no, offset knee_r_9
		je	knee_ctrl_ok
		cmp	frame_no, offset knee_l_9
		je	knee_ctrl_ok
		cmp	frame_no, offset knee_r_11
		je	knee_ctrl_ok
		cmp	frame_no, offset knee_l_11
		je	knee_ctrl_ok

		cmp	frame_no, offset knee_r_12
		jp_e	finish_kneeing
		cmp	frame_no, offset knee_l_12
		jp_e	finish_kneeing
;	automatic throw away! good grief what a frig
		jmp	exit_kc

knee_ctrl_ok:	mov	si, weapon_held
		not	al
		test	al, fire
		jz	knee_no_fire
		and	al, left+right
		jnz	over_kc
		jmp	exit_kc
over_kc:	and	al, direction
		jz	knee_throw
		mov	frame_no, -1
		mov	word ptr [si+6], -1
		mov	al, [si+5]
		sub	al, 1
		adc	al, 0
		mov	[si+5], al
		test	al, 111b
		jnz	exit_kc
		mov	action, standing
		mov	weapon_held, nawt_lad
		call	knock_over
		ret
knee_throw:	mov	action, throwing_man
		mov	frame_no, -1
		mov	weapon_held, nawt_lad
		xor	byte ptr direction, left+right
		mov	byte ptr [si+2], being_thrown
		mov	word ptr [si+6], -1
		mov	al, direction
		call	x_vel_from_dir
		shl	ax, 1
		mov	word ptr [si+12], ax
		mov	word ptr [si+14], -4
		ret
knee_no_fire:	and	al, left+right
		jz	exit_kc
		and	al, direction
		jnz	exit_kc
finish_kneeing:
		mov	si, weapon_held
		mov	action, walking
		mov	frame_no, -1
		mov	weapon_held, nawt_lad
		mov	byte ptr [si+2], standing
		mov	word ptr [si+6], -1
exit_kc:	ret


no_ctrl:	ret


;	this is the player 2 fudlr and now we have to add the keys
;	iop
;	kl;
;	<>?

keybd_fudlr:
	mov	al, keybd + fire_k
	and	al, keybd + fire_k2
	and	al, keybd + five_k
	and	al, keybd + ret_k
	mov	ah, al
	or	ah, fire_k_enable
	xor	al, 1
	mov	fire_k_enable, al
	shl	ah, 1
	mov	al, keybd + up_k
	and	al, keybd + up_k2
	and	al, keybd + ul_k
	and	al, keybd + ul_k2
	and	al, keybd + ur_k
	and	al, keybd + ur_k2

	or	ah, al
	shl	ah, 1
	mov	al, keybd + down_k
	and	al, keybd + down_k2
	and	al, keybd + dl_k
	and	al, keybd + dl_k2
	and	al, keybd + dr_k
	and	al, keybd + dr_k2

	or	ah, al
	shl	ah, 1
	mov	al, keybd + left_k
	and	al, keybd + left_k2
	and	al, keybd + dl_k
	and	al, keybd + dl_k2
	and	al, keybd + ul_k
	and	al, keybd + ul_k2

	or	ah, al
	shl	ah, 1
	mov	al, keybd + right_k
	and	al, keybd + right_k2
	and	al, keybd + dr_k
	and	al, keybd + dr_k2
	and	al, keybd + ur_k
	and	al, keybd + ur_k2
	or	al, ah

	cmp	nojoyflag,-1
	je	no_joy
	AND	AL,FUDLR	;THE JOYSTICK VARIETY
no_joy:
		ret
; should be renamed player 1 fudlr uses Amstrad
; joystick and keyboard though ! All for the STUPID YANKS IDEA OF GOOD KEYS !

joystick_fudlr:
		mov	al, keybd + fire_j
		and	al, keybd + fire_jk
		and	al, keybd + space_k
		mov	ah, al
		or	ah, fire_j_enable
		xor	al, 1
		mov	fire_j_enable, al
		shl	ah, 1
		mov	al, keybd + up_j
		and	al, keybd + up_jk
		and	al, keybd + ul_jk
		and	al, keybd + ur_jk

		or	ah, al
		shl	ah, 1
		mov	al, keybd + down_j
		and	al, keybd + down_jk
		and	al, keybd + dl_jk
		and	al, keybd + dr_jk

		or	ah, al
		shl	ah, 1
		mov	al, keybd + left_j
		and	al, keybd + left_jk
		and	al, keybd + dl_jk
		and	al, keybd + ul_jk

		or	ah, al
		shl	ah, 1
		mov	al, keybd + right_j
		and	al, keybd + right_jk
		and	al, keybd + dr_jk
		and	al, keybd + ur_jk
		or	al, ah

	cmp	nojoyflag,-1
	je	no_joy
	AND	AL,FUDLR_2	;THE JOYSTICK VARIETY
		ret

x_vel_from_dir:	and	ax, 3
		shl	ax, 1
		sub	ax, 3
		neg	ax
		ret




cseg		ends


dseg		segment	public 'data'

extrn		start_seg:word, start_offset:word, file_name:word
extrn		sprt_table:word
extrn		keybd:byte, map_width:word, ss_save:word
extrn		scrn_top:word, scrn_left:word,nojoyflag:word
extrn		name_:byte, action:byte, frame_no:word, map_x:word, map_y:word
extrn		height:byte, test_map_x:word, test_map_y:word
extrn		test_height:byte, x_vel:word, y_vel:word, weapon_held:word
extrn		controls:byte, direction:byte, level:byte
extrn		reduced_attr:byte, walk_dr_0:word, walk_dl_0:word
extrn		hat_map:word, hldup_dr_0:word, hldup_dl_0:word
extrn		knee_r_3:word, knee_l_3:word,knee_r_1:word, knee_l_1:word
extrn		knee_r_5:word, knee_l_5:word,knee_r_7:word, knee_l_7:word
extrn		knee_r_9:word, knee_l_9:word,knee_r_11:word, knee_l_11:word
extrn		knee_r_12:word, knee_l_12:word

EXTRN		FUDLR:BYTE,FUDLR_2:BYTE

fire_k_enable	db	0		; low asserted
fire_j_enable	db	0

;	none	,right		,left	,left+right		 ; 0-3
;	down	,down+right,down+left,down+left+right		 ; 4-7
;	up	,up+right	,up+left,up+left+right		 ; 8-11
;	up+down ,up+down+right  ,up+down+left,up+down+left+right ; 12-15
;
;	table of what to do with fire pressed ?

;movements	dw	no_direct,jmp_kick,jmp_kick,no_direct
;		dw	turnkick ,jmp_kick,ord_kick,no_kick
;		dw	jump,jump,jump,no_direct
;		dw	no_direct,jmp_kick,ord_kick,no_direct

;	actually I think thats pretty good !

dseg		ends
end
