
cseg		segment	public 'code'


assume		cs:cseg, ds:dseg

public		new_weapons, frame_weapons, animate_weapons, near_weapon

extrn		get_surface:near, x_vel_from_dir:near, nocdown_detect:near
extrn		drop_his_weapon:near, pull_person:near, put_person:near
extrn		get_frame:near, next_frame:near, hurt_em:near
extrn		bounce_snd:near, splat_snd:near, knife_snd:near

include		ddeqfile



new_weapons:	mov	si, offset weapon_table
next_wep_nww:	cmp	byte ptr [si+2], nonexistent
		je	weapon_done_nww
		push	si
		call	pull_weapon

		call	w_get_action

		pop	si
		push	si
		call	put_weapon
		pop	si
weapon_done_nww:add	si, wep_list_size
		cmp	si, offset weapon_table + 6 * wep_list_size
		jne	next_wep_nww
		ret



frame_weapons:	mov	si, offset weapon_table
next_wep_fw:	cmp	byte ptr [si+2], nonexistent
		je	weapon_done_fw
		push	si
		call	pull_weapon

		call	w_get_frame

		pop	si
		push	si
		call	put_weapon
		pop	si
weapon_done_fw:	add	si, wep_list_size
		cmp	si, offset weapon_table + 6 * wep_list_size
		jne	next_wep_fw
		ret



animate_weapons:mov	si, offset weapon_table
next_wep_aw:	cmp	byte ptr [si+2], nonexistent
		je	weapon_done_aw
		push	si
		call	pull_weapon

		cmp	w_name, knife
		jne	not_a_knife
		cmp	w_action, travelling
		jne	not_tnt
		jmp	ok_to_animate
not_a_knife:	cmp	w_name, tnt
		jne	not_tnt
		cmp	w_action, dropping
		je	ok_to_animate
		cmp	w_action, stationary
		je	ok_to_animate
not_tnt:	test	cycle, 1
		jz	no_animate
ok_to_animate:	call	w_next_frame
		pop	si
		push	si
		call	put_weapon
no_animate:	pop	si
weapon_done_aw:	add	si, wep_list_size
		cmp	si, offset weapon_table + 6 * wep_list_size
		jne	next_wep_aw
exit_aw:	ret



pull_weapon:	mov	di, offset w_name
		mov	cx, wep_list_size/2
		rep	movsw
		ret



put_weapon:	mov	di, si
		mov	si, offset w_name
		mov	cx, wep_list_size/2
		rep	movsw
		ret




near_weapon:	mov	si, offset weapon_table
		
next_wep_nrw:	cmp	word ptr [si+16], nobody
		jne	not_near_wep
		cmp	byte ptr [si+2], nonexistent
		je	not_near_wep
		cmp	byte ptr [si], specwep
		je	not_near_wep
		call	near_ht_wep
		jnc	not_near_wep
		call	near_x_wep
		jnc	not_near_wep
		call	near_plane_wep
		jnc	not_near_wep
		ret

not_near_wep:	add	si, wep_list_size
		cmp	si, offset weapon_table + 6 * wep_list_size
		jb	next_wep_nrw
		clc
		ret



near_x_wep:	mov	ax, [si+6]
		sub	ax, map_x
		cmp	ax, -4
		jl	not_nr_x_wep
		cmp	ax, 4
		jg	not_nr_x_wep
		stc
		ret
not_nr_x_wep:	clc
		ret



near_ht_wep:	mov	al, [si+3]
		cmp	al, height
		je	nr_ht_wep
	inc	al
	cmp	al,height
	je	nr_ht_wep
	sub	al,2
	cmp	al,height
	je	nr_ht_wep
		clc
		ret
nr_ht_wep:	stc
		ret



near_plane_wep:	mov	al, [si+3]
		sub	al, height
		cbw
		add	ax, [si+8]
		sub	ax, map_y
		cmp	ax, -2
		jl	not_nr_pl_wep
		cmp	ax, 2
		jg	not_nr_pl_wep
		stc
		ret
not_nr_pl_wep:	clc
		ret




w_get_frame:	cmp	w_frame_no, -1		; test for new action
		jne	w_old_action
		call	w_get_1st_frame

w_old_action:	mov	bx, w_frame_no
		mov	bx, [bx]		; figure addr
		mov	si, w_sprt_index
		mov	ax, [bx]
		mov	[si+8], ax		; data ptr
		mov	ax, [bx+2]		; cols, rows
		mov	dl, ah
		cbw
		mov	[si+4], ax		; cols
		mov	al, dl
		cbw
		mov	[si+6], ax		; rows
		mov	ax, [bx+4]		; x-, y-offsets
		mov	dl, ah
		cbw
		add	ax, w_map_x
		sub	ax, scrn_left
		mov	[si], ax		; x-offset
		mov	al, dl
		cbw
		mov	dx, w_map_y
		sub	dx, scrn_top
		shl	dx, 1
		shl	dx, 1
		add	ax, dx
		mov	[si+2], ax		; y-offset
	push	ax
	mov	ax,[colrmap_table]
		mov	word ptr [si+10],ax	; offset identity_table
	pop	ax
		ret


w_get_1st_frame:mov	al, w_action
		mov	ah, 7				; # weapon types
		mul	ah
		add	al, w_name
		cbw
		add	ax, offset w_frame_0_table
		mov	bx, ax
		cmp	w_action, travelling
		jl	ok_wg1f
		cmp	w_bearer, nobody
		je	no_bearer
		mov	si, w_bearer
		test	byte ptr [si+4], left
		jz	ok_wg1f
		add	bx, 56
		jmp	ok_wg1f
no_bearer:	cmp	w_x_vel, -1
		jne	ok_wg1f
		add	bx, 56
ok_wg1f:	mov	ax, [bx]
		mov	w_frame_no, ax
		ret




w_next_frame:	mov	bx, w_frame_no
		mov	ax, [bx+2]
		mov	w_frame_no, ax
exit_wnf:	ret




w_get_action:	jmptab	w_name, w_name_table

w_name_table:	dw	offset club_action
		dw	offset whip_action
		dw	offset knife_action
		dw	offset tnt_action
		dw	offset barrel_action
		dw	offset crate_action
		dw	offset rock_action
		dw	offset special_action


club_action:	jmptab	w_action, club_table
whip_action:	jmptab	w_action, whip_table
knife_action:	jmptab	w_action, knife_table
tnt_action:	jmptab	w_action, tnt_table
barrel_action:	jmptab	w_action, barrel_table
crate_action:	jmptab	w_action, crate_table
rock_action:	jmptab	w_action, rock_table
special_action:	ret


club_table:	dw	offset no_change
		dw	offset no_change
		dw	offset sml_wep_drop
		dw	?
		dw	offset club_used
		dw	offset disp_s_weapon
		dw	offset no_change


whip_table:	dw	offset no_change
		dw	offset no_change
		dw	offset sml_wep_drop
		dw	?
		dw	offset whip_used
		dw	offset disp_s_weapon
		dw	offset no_change


knife_table:	dw	offset no_change
		dw	offset no_change
		dw	offset sml_wep_drop
		dw	offset knife_flying
		dw	offset knife_used
		dw	offset disp_s_weapon
		dw	offset no_change


tnt_table:	dw	offset no_change
		dw	offset burn_fuse
		dw	offset sml_wep_drop
		dw	offset sml_wep_drop
		dw	offset tnt_used
		dw	offset burn_fuse
		dw	offset burn_fuse


barrel_table:	dw	offset no_change
		dw	offset no_change
		dw	offset big_wep_drop
		dw	offset barrel_rolling
		dw	?
		dw	offset disp_b_weapon
		dw	offset barrel_pickup


crate_table:	dw	offset no_change
		dw	offset no_change
		dw	big_wep_drop
		dw	offset barrel_rolling
		dw	?; offset bw_used
		dw	offset disp_b_weapon
		dw	offset crate_pickup


rock_table:	dw	offset no_change
		dw	offset no_change
		dw	big_wep_drop
		dw	offset barrel_rolling
		dw	?; offset bw_used
		dw	offset disp_b_weapon
		dw	offset rock_pickup


no_change:	ret




club_used:	cmp	w_frame_no, offset club_heldr
		je	after_wu
		cmp	w_frame_no, offset club_heldl
		jne	exit_cu
		mov	w_action, being_carried
exit_cu:	jmp	disp_s_weapon


whip_used:	cmp	w_frame_no, offset whip_held_r
		je	after_wu
		cmp	w_frame_no, offset whip_held_l
		jne	exit_wu
after_wu:	mov	w_action, being_carried
exit_wu:	jmp	disp_s_weapon



knife_used:	cmp	w_frame_no, offset knife_thrn_r_7
		je	after_ku
		cmp	w_frame_no, offset knife_thrn_l_7
		jne	exit_ku
after_ku:	mov	w_action, travelling
		mov	bx, w_bearer
		mov	al, [bx+4]
		call	x_vel_from_dir
		mov	w_x_vel, ax
		shl	ax, 1
		shl	ax, 1
		add	w_map_x, ax
		add	w_map_y, 3
		sub	w_height, 3
		mov	w_bearer, nobody
		mov	word ptr [bx+18], nawt_lad
		ret
exit_ku:	jmp	disp_s_weapon



knife_flying:	mov	ax, w_map_x
		mov	test_map_x, ax
		mov	ax, w_map_y
		mov	test_map_y, ax
		mov	al, w_height
		mov	test_height, al
		mov	cx, 3
k_tracking:	mov	ax, w_x_vel
		add	test_map_x, ax
		push	ax
		call	get_surface
		pop	ax
		cmp	byte ptr reduced_attr, fallable
		jne	fly_bounce
		loop	k_tracking	;what the hell is this ?

fly_fly:	mov	ax, test_map_x
		mov	w_map_x, ax
		call	big_hit_detect
		cmp	w_frame_no, offset null_0
		jne	exit_ff
		mov	w_action, nonexistent
exit_ff:	ret

fly_bounce:	call	knife_snd
		mov	ax, test_map_x
		mov	w_map_x, ax
fly_bounce_1:	mov	w_action, dropping
		mov	w_frame_no, -1
		neg	w_x_vel
		mov	w_y_vel, -2
		ret


kill_knife:	mov	w_action, nonexistent
		ret


tnt_used:	cmp	w_frame_no, offset tnt_thrown_r_7
		je	after_tu
		cmp	w_frame_no, offset tnt_thrown_l_7
		jne	exit_tu
after_tu:	mov	w_action, dropping
		mov	w_y_vel, -3
		mov	bx, w_bearer
		mov	al, [bx+4]
		call	x_vel_from_dir
		mov	dx, ax
		shl	ax, 1
		add	ax, dx
		mov	w_x_vel, ax
		mov	w_bearer, nobody
		mov	word ptr [bx+18], nawt_lad
		mov	w_fuse, fuse_length
		ret
exit_tu:	jmp	disp_s_weapon



burn_fuse:	dec	w_fuse
		jg	no_blow
		jz	start_blowup
		call	big_hit_detect
		cmp	w_fuse, -5
		jne	exit_bf
		mov	w_action, nonexistent
exit_bf:	ret
start_blowup:	mov	w_frame_no, offset blowup_0
		mov	w_x_vel, 0
		mov	w_y_vel, 0
		mov	w_action, stationary
		call	big_hit_detect
		call	bounce_snd
		ret
no_blow:	cmp	w_action, being_carried
		je	disp_s_weapon
		ret



bw_used:	mov	w_action, dropping
		ret




barrel_pickup:	cmp	w_frame_no, offset barrel_held_r
		je	after_pb
		cmp	w_frame_no, offset barrel_held_l
		jne	exit_bp
after_pb:	mov	w_action, being_carried
		jmp	disp_b_weapon
exit_bp:	jmp	disp_s_weapon




crate_pickup:	cmp	w_frame_no, offset crate_held_r
		je	after_pc
		cmp	w_frame_no, offset crate_held_l
		jne	exit_cp
after_pc:	mov	w_action, being_carried
		jmp	disp_b_weapon
exit_cp:	jmp	disp_s_weapon




rock_pickup:	cmp	w_frame_no, offset rock_held
		jne	exit_rp
		mov	w_action, being_carried
		jmp	disp_b_weapon
exit_rp:	jmp	disp_s_weapon




disp_s_weapon:	mov	bx, w_bearer
		mov	si, [bx+6]		; frame_no of bearer
		mov	ax, [si+4]		; packed disps of weapon
		mov	dl, ah
		cbw
		mov	cx, ax			; x disp
		mov	al, dl
		cbw
		mov	dx, ax			; y disp
		mov	ax, [bx+8]		; map_x of bearer
		add	ax, cx
		mov	w_map_x, ax
		mov	ax, [bx+10]		; map_y of bearer
		add	ax, dx
		mov	w_map_y, ax
		mov	al, [bx+3]		; height of bearer
		sub	al, dl
		mov	w_height, al
		ret



disp_b_weapon:	mov	bx, w_bearer
		mov	ax, [bx+8]		; map_x of bearer
		add	ax, bw_x_disp
		mov	w_map_x, ax
		mov	ax, [bx+10]		; map_y of bearer
		add	ax, bw_y_disp
		mov	w_map_y, ax
		mov	al, [bx+3]		; height of bearer
		sub	al, bw_y_disp
		mov	w_height, al
		ret




sml_wep_drop:	mov	ax, w_y_vel
		and	ax, ax
		jz	s_y_vel_zero
		jl	s_y_vel_neg
s_y_vel_pos:	mov	dx, 1
		jmp	s_normalized
s_y_vel_neg:	mov	dx, -1
		neg	ax
		jmp	s_normalized
s_y_vel_zero:	xor	dx, dx
s_normalized:	mov	cx, ax
		mov	ax, w_map_x
		add	ax, w_x_vel
		mov	test_map_x, ax
		mov	ax, w_map_y
		mov	test_map_y, ax
		mov	al, w_height
		mov	test_height, al

s_tracking:	add	test_map_y, dx
		sub	test_height, dl
		push	dx
		call	get_surface
;border	15
		pop	dx
		cmp	byte ptr reduced_attr, fallable
		je	s_cont_tracking
		cmp	byte ptr reduced_attr, background
		je	sml_bounce
		cmp	byte ptr reduced_attr, outside_map
		je	sml_out
		and	dx, dx
		jge	sml_land
		jmp	s_cont_tracking
sml_bounce:	neg	w_x_vel
s_cont_tracking:jcxz	s_drop_drop
		loop	s_tracking

s_drop_drop:	mov	ax, test_map_x
		mov	w_map_x, ax
		mov	ax, test_map_y
		mov	w_map_y, ax
		mov	al, test_height
		mov	w_height, al
		inc	w_y_vel
		ret

sml_land:	mov	ax, test_map_x
		mov	w_map_x, ax
		mov	ax, test_map_y
		mov	w_map_y, ax
		mov	al, test_height
		mov	w_height, al
		mov	w_action, stationary
		mov	w_frame_no, -1
		mov	w_x_vel, 0
		ret

sml_out:	mov	w_action, nonexistent
		ret




big_wep_drop:	call	big_hit_detect
		mov	ax, w_y_vel
		and	ax, ax
		jz	b_y_vel_zero
		jl	b_y_vel_neg
b_y_vel_pos:	mov	dx, 1
		jmp	b_normalized
b_y_vel_neg:	mov	dx, -1
		neg	ax
		jmp	b_normalized
b_y_vel_zero:	xor	dx, dx
b_normalized:	mov	cx, ax
		mov	ax, w_map_x
		add	ax, w_x_vel
		mov	test_map_x, ax
		mov	ax, w_map_y
		mov	test_map_y, ax
		mov	al, w_height
		mov	test_height, al
		call	big_hit_detect

b_tracking:	add	test_map_y, dx
		sub	test_height, dl
		push	dx
		call	get_surface
;border	15
		pop	dx
		cmp	byte ptr reduced_attr, fallable
		je	b_cont_tracking
		cmp	byte ptr reduced_attr, background
		je	big_bounce
		cmp	byte ptr reduced_attr, outside_map
		je	big_out
		and	dx, dx
		jge	big_land
		jmp	b_cont_tracking
big_bounce:	neg	w_x_vel
b_cont_tracking:jcxz	b_drop_drop
		loop	b_tracking

b_drop_drop:	mov	ax, test_map_x
		mov	w_map_x, ax
		mov	ax, test_map_y
		mov	w_map_y, ax
		mov	al, test_height
		mov	w_height, al
		inc	w_y_vel
		ret

big_land:	mov	ax, test_map_x
		mov	w_map_x, ax
		mov	ax, test_map_y
		mov	w_map_y, ax
		mov	al, test_height
		mov	w_height, al
		call	bounce_snd
		neg	w_y_vel
		add	w_y_vel, 2
		jge	bl_roll
		ret
bl_roll:	mov	w_action, travelling
		mov	w_frame_no, -1
		mov	w_y_vel, 10		; use as counter
		ret

big_out:	mov	w_action, nonexistent
		ret




barrel_rolling:	call	big_hit_detect
		mov	ax, w_map_x
		add	ax, w_x_vel
		mov	test_map_x, ax
		mov	ax, w_map_y
		mov	test_map_y, ax
		mov	al, w_height
		mov	test_height, al
		call	big_hit_detect
		call	get_surface
;border	15
		cmp	byte ptr reduced_attr, walkable
		je	roll_roll
		cmp	byte ptr reduced_attr, fallable
		je	roll_drop

roll_bounce:	mov	ax, test_map_x
		mov	w_map_x, ax
		neg	w_x_vel
		dec	w_y_vel
		jz	roll_stop
		ret

roll_roll:	mov	ax, test_map_x
		mov	w_map_x, ax
		mov	al, level
		mov	w_height, al
		dec	w_y_vel
		jz	roll_stop
		ret

roll_stop:	mov	w_action, stationary
		mov	w_frame_no, -1
		ret

roll_drop:	mov	ax, test_map_x
		mov	w_map_x, ax
		mov	w_y_vel, 0
		mov	w_action, dropping
		mov	w_frame_no, -1
		ret


big_hit_detect:	mov	si, offset person_table

next_per_bhd:	cmp	byte ptr [si], nobody
		jne	over_bhd_0
		jmp	no_big_hit
over_bhd_0:	cmp	byte ptr [si+2], throwing_rock
		jne	over_bhd_1
		jmp	no_big_hit
over_bhd_1:	cmp	byte ptr [si+2], kicking_rock
		jne	over_bhd_2
		jmp	no_big_hit
over_bhd_2:	mov	bx, [si+6]
		cmp	bx, -1
		jne	over_bhd_3
		jmp	no_big_hit
over_bhd_3:	test	byte ptr [bx+6], 2
		jnz	over_bhd_4
		jmp	no_big_hit
over_bhd_4:	call	w_near_y
		jc	over_bhd_5
		jmp	no_big_hit
over_bhd_5:	call	w_near_plane
		jc	over_bhd_6
		jmp	no_big_hit
over_bhd_6:	call	w_near_x
		jc	over_bhd_7
		jmp	no_big_hit
over_bhd_7:
		call	tnt_str_loss
		cmp	byte ptr w_name, knife
		jne	no_knife_hit
		cmp	byte ptr [si+2], kicking
		jne	knife_hit
		call	knife_snd
		mov	al, [si+4]
		call	x_vel_from_dir
		mov	dx, w_x_vel
		add	dx, ax
		jnz	knife_hit
		shl	ax, 1
		shl	ax, 1
		add	w_map_x, ax
		call	fly_bounce_1
		jmp	no_big_hit
knife_hit:	mov	w_frame_no, offset splat_0
		mov	w_x_vel, 0
		sub	byte ptr [si+5], 10
		call	splat_snd
no_knife_hit:	push	si
		call	pull_person
		mov	action, flying_back
		add	height, 3
		sub	map_y, 3
		mov	frame_no, -1
		mov	y_vel, -2
		mov	ax, w_x_vel
		mov	x_vel, ax
		call	get_frame
		call	next_frame
		sub	strength, 2
		jge	str_pos
		mov	strength, 0
str_pos:	pop	si
		mov	dx, si
		call	put_person
		mov	si, dx
		call	drop_his_weapon

no_big_hit:	add	si, per_list_size
		cmp	si, offset person_table + 7 * per_list_size
		jnb	over_bhd
		jmp	next_per_bhd
over_bhd:	ret


tnt_str_loss:	cmp	w_name, tnt
		jne	exit_tsl
		sub	byte ptr [si+5], 10
exit_tsl:	ret



w_near_x:	mov	ax, [si+8]
		sub	ax, w_map_x
		cmp	ax, -3
		jl	w_not_near_x
		cmp	ax, 3
		jg	w_not_near_x
		stc
		ret
w_not_near_x:	clc
		ret




w_near_y:	mov	ax, [si+10]
		sub	ax, w_map_y
		cmp	ax, -5
		jl	w_not_near_y
		cmp	ax, 10
		jg	w_not_near_y
		stc
		ret
w_not_near_y:	clc
		ret




w_near_plane:	mov	al, [si+3]
		sub	al, w_height
		cbw
		add	ax, [si+10]
		sub	ax, w_map_y
		cmp	ax, -1
		jl	w_not_near_pln
		cmp	ax, 1
		jg	w_not_near_pln
		stc
		ret
w_not_near_pln:	clc
		ret




cseg		ends




dseg		segment	public 'data'

extrn		club_heldr:word,club_heldl:word , barrel_stat:word, w_frame_0_table:word
extrn		identity_table:byte, person_table:byte, strength:byte
extrn		sprt_table:word, save_area:word
extrn	 	scrn_left:word, scrn_top:word, level:byte
extrn		map_x:word, map_y:word, height:byte, reduced_attr:byte
extrn		test_map_x:word, test_map_y:word, test_height:byte
extrn		whip_held_r:word, whip_held_l:word, club_stat:word
extrn		whip_stat:word, tnt_stat:word, tnt_thrown_r_7:word
extrn		tnt_thrown_l_7:word, cycle:word, name_:word
extrn		barrel_held_r:word, barrel_held_l:word
extrn		x_vel:word, y_vel:word, frame_no:word, action:byte
extrn		knife_stat:word, crate_stat:word, blowup_0:word, splat_0:word
extrn		knife_thrn_r_7:word, knife_thrn_l_7:word, null_0:word
extrn		crate_held_r:word, crate_held_l:word, rock_held:word
extrn		colrmap_table:word
public		weapon_table, w_map_y, w_height


w_name		db	?; 0
w_fuse		db	?; 1
w_action	db	?; 2
w_height	db	?; 3
w_frame_no	dw	?; 4
w_map_x		dw	?; 6
w_map_y		dw	?; 8
w_x_vel		dw	?; 10
w_y_vel		dw	?; 12
w_sprt_index	dw	?; 14
w_bearer	dw	?; 16

weapon_table	db	6*18 dup (?)

dseg		ends


end
