cseg		segment	public 'code'

assume		cs: cseg, ds: dseg

public		get_action, get_surface, nocdown_detect, drop_his_weapon
public		knock_over, hit_kneeing, hurt_em, score_it, hit_in_air

extrn		x_vel_from_dir:near, test_snd:near
extrn		hit_snd:near, thud_snd:near, linda_snd:near, will_snd:near
extrn		colaps_snd:near, whip_snd:near, thumb_snd:near, splash_snd:near
extrn		splat_snd:near, bounce_snd:near

extrn		pnum:near

include		ddeqfile

get_action:	
;pushall	
;mov	dx,100*256
;mov	cx,5
;mov	al,action
;xor	ah,ah
;call	pnum	;okay then print the f***er

;border	6	;change !

;popall
	mov	al,action
;and	al,62	;mask man !
	jmptab	al,action_table	;action, action_table
	
	
action_table:	dw	offset null_action	; dead
		dw	offset walk
		dw	offset punch
		dw	offset kick
		dw	offset jump_kick
		dw	offset turn_kick
		dw	offset elbow
		dw	offset head_butt
		dw	offset swing_club
		dw	offset use_whip
		dw	offset jump
		dw	offset null_action	; throw knife
		dw	offset null_action	; throw rock
		dw	offset climb
		dw	offset fall
		dw	offset collapse
		dw	offset null_action	; get up
		dw	offset null_action	;kneeing
		dw	offset null_action	; pick up small
		dw	offset null_action	; pick up large
		dw	offset null_action	; take punch
		dw	offset null_action	; stand
		dw	offset null_action	; lie
		dw	offset null_action	; throw man
		dw	offset be_thrown
		dw	offset fly_back
		dw	offset fly_side
		dw	offset hold_up		; hold up
		dw	offset null_action	; hu_stand
		dw	offset null_action	; be kneed
		dw	offset null_action	; kick rock
		dw	offset run		; running (cartwheel)
		dw	offset null_action	; 64 bill dying ?
		dw	offset null_action	; 66	specwep ?
		dw	offset birth_action	; 68


birth_action:
;	might do summat but not for now !
	ret


;dw	offset cart		;the cartwheel

run:		mov	ax, map_x
		add	ax, x_vel
		add	ax, x_vel	;goes twice as fast !
		mov	test_map_x, ax
		mov	ax, map_y
	mov	y_vel,0		;must zero !;add	ax, y_vel
		mov	test_map_y, ax
		mov	al, height
		mov	test_height, al
		call	get_surface
		cmp	byte ptr reduced_attr, walkable
		je	run_run
		cmp	byte ptr reduced_attr, climbable
		je	run_climb
;cmp	byte ptr reduced_attr, fallable
;je	run_fall
no_run:		ret

run_run:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	al, level
		mov	height, al
		mov	bx, frame_no
		test	byte ptr [bx+6], 1
		jnz	run_hit
		ret
run_hit:	cmp	bx,-1
		je	exit_rh
		call	nocdown_detect
;call	hurt_detect

exit_rh:	ret

;run_fall:	mov	ax, test_map_x
;	mov	map_x, ax
;	mov	ax, test_map_y
;	mov	map_y, ax
;	mov	action, falling
;	mov	frame_no,-1
;	call	drop_own_weapon
;	ret

run_climb:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	action, climbing
		mov	frame_no, -1
		ret

;this carting is ignoring the collision detection.
cart:		mov	ax, map_x
		add	ax, x_vel
		add	ax, x_vel	;goes twice as fast !
		mov	test_map_x, ax
		mov	ax, map_y
	mov	y_vel,0		;must zero !;add	ax, y_vel
		mov	test_map_y, ax
		mov	al, height
		mov	test_height, al
		call	get_surface
		cmp	byte ptr reduced_attr, walkable
		je	cart_cart
		cmp	byte ptr reduced_attr, climbable
		je	cart_climb
;cmp	byte ptr reduced_attr, fallable
;je	cart_fall
no_cart:	ret

;cart_fall:	mov	ax, test_map_x
;mov	map_x, ax
;mov	ax, test_map_y
;mov	map_y, ax
;mov	action, falling
;mov	frame_no,-1
;call	drop_own_weapon
;ret

cart_climb:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	action, climbing
		mov	frame_no, -1
		ret
cart_cart:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	al, level
		mov	height, al

		ret

walk:		mov	ax, map_x
		add	ax, x_vel
		mov	test_map_x, ax
		mov	ax, map_y
		add	ax, y_vel
		mov	test_map_y, ax
		mov	al, height
		mov	test_height, al
		call	get_surface
		cmp	byte ptr reduced_attr, walkable
		je	walk_walk
		cmp	byte ptr reduced_attr, climbable
		je	walk_climb
		cmp	byte ptr reduced_attr, fallable
		je	walk_fall_test
no_walk:	ret

walk_walk:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	al, level
		mov	height, al
		ret

walk_fall_test:	; attempt a simple frig for checking out the climbable thing
		mov	ax, map_x
		add	ax, x_vel
		mov	test_map_x, ax
		mov	ax, map_y
		add	ax, y_vel
		mov	test_map_y, ax
		mov	al, height
	sub	al,1	;check a bit lower ?
		mov	test_height, al
		call	get_surface
	cmp	byte ptr reduced_attr, climbable
		jne	walk_fall
	sub	height,1	;er ?
	jmp	walk_climb
; or continue to fallable ?

walk_fall:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	action, falling
		mov	frame_no,-1
		call	drop_own_weapon
		ret

walk_climb:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	action, climbing
		mov	frame_no, -1
		ret


punch:		mov	bx, frame_no
		test	byte ptr [bx+6], 1
		jnz	punch_hit
		ret
punch_hit:	cmp	bx, -1
		je	exit_ph
		call	hurt_detect
exit_ph:	ret


kick:		mov	bx, frame_no
		test	byte ptr [bx+6], 1
		jnz	kick_hit
		ret
kick_hit:	cmp	bx, -1
		je	exit_kh
	cmp	type_,player1	; players1/2 and ropers ( type_ correct?)
	jne	no_player_frigg
	xor	direction , left+right
		call	hurt_detect
	xor	direction , left+right
;	This is done as a player kick is a backwards kick !
;	The turn kick will be changed to the whirlwind job.

exit_kh:	ret
no_player_frigg:
	call	hurt_detect
	ret

elbow:		mov	bx, frame_no
		test	byte ptr [bx+6], 1
		jnz	elbow_hit
		ret
elbow_hit:	cmp	bx, -1
		je	exit_eh
		call	nocdown_detect
exit_eh:	ret


head_butt:	mov	bx, frame_no
		test	byte ptr [bx+6], 1
		jnz	head_butt_hit
		ret
head_butt_hit:	cmp	bx, -1
		je	exit_hbh
		call	nocdown_detect
exit_hbh:	ret


swing_club:	mov	bx, frame_no
		test	byte ptr [bx+6], 1
		jnz	club_hit
		ret
club_hit:	cmp	bx, -1
		je	exit_ch
		call	nocdown_detect
exit_ch:	ret


use_whip:	mov	bx, frame_no
		test	byte ptr [bx+6], 1
		jnz	whip_hit
		ret
whip_hit:	cmp	bx, -1
		je	exit_wh
		call	hurt_detect
exit_wh:	ret


turn_kick:	mov	ax, map_x
		mov	test_map_x, ax
		mov	ax, map_y
		add	ax, y_vel
		mov	test_map_y, ax
		mov	al, height
		sub	al, byte ptr y_vel
		mov	test_height, al
		call	get_surface
		cmp	byte ptr reduced_attr, walkable
		jne	tk_tk
		xor	byte ptr direction, left+right	   ; reverse direction
		jmp	jump_land

tk_tk:		mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	al, test_height
		mov	height, al
		inc	y_vel
		mov	bx, frame_no
		test	byte ptr [bx+6], 1
		jnz	tk_hit
		ret

tk_hit:		cmp	bx, -1
		je	exit_tkh
		call	nocdown_detect
exit_tkh:	ret


jump:
jump_kick:	mov	ax, y_vel
		and	ax, ax
		jz	j_y_vel_zero
		jl	j_y_vel_neg
j_y_vel_pos:	mov	dx, 1
		jmp	j_normalized
j_y_vel_neg:	mov	dx, -1
		neg	ax
		jmp	j_normalized
j_y_vel_zero:	xor	dx, dx
j_normalized:	mov	cx, ax
		mov	ax, map_x
		add	ax, x_vel
		mov	test_map_x, ax
		mov	ax, map_y
		mov	test_map_y, ax
		mov	al, height
		mov	test_height, al

j_tracking:	add	test_map_y, dx
		sub	test_height, dl
		push	dx
		call	get_surface
		pop	dx
		cmp	byte ptr reduced_attr, fallable
		je	j_cont_tracking
		cmp	byte ptr reduced_attr, background
		je	jump_bounce
		cmp	byte ptr reduced_attr, outside_map
		je	jump_die
		cmp	dx, 0
		jge	jump_land
		jmp	j_cont_tracking
jump_bounce:	mov	ax, test_map_x
		sub	ax, x_vel
		mov	test_map_x, ax
;mov	x_vel, 0	; ye hah ! that'l fix it.
j_cont_tracking:jcxz	jump_jump
		loop	j_tracking

jump_jump:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	al, test_height
		mov	height, al
		inc	y_vel
		cmp	action, jump_kicking
		je	jk_test
		ret
jk_test:	mov	bx, frame_no
		test	byte ptr [bx+6], 1
		jnz	jk_hit
		ret
jk_hit:		cmp	bx, -1
		je	exit_jkh
		call	nocdown_detect
exit_jkh:	ret

jump_die:	mov	action, being_dead
		ret

jump_land:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	al, level
		mov	height, al
		mov	action, standing
		mov	frame_no, -1
		mov	x_vel, 0
		mov	y_vel, 0
		call	hit_snd
		ret



fall:		mov	ax, y_vel
		and	ax, ax
		jz	f_y_vel_zero
f_y_vel_pos:	mov	dx, 1
		jmp	f_normalized
f_y_vel_zero:	xor	dx, dx
f_normalized:	mov	cx, ax
		mov	ax, map_x
		add	ax, x_vel
		mov	test_map_x, ax
		mov	ax, map_y
		mov	test_map_y, ax
		mov	al, height
		mov	test_height, al

f_tracking:	add	test_map_y, dx
		sub	test_height, dl
		push	dx
		call	get_surface
		pop	dx
		cmp	byte ptr reduced_attr, fallable
		je	f_cont_tracking
		cmp	byte ptr reduced_attr, outside_map
		je	fall_die
		cmp	byte ptr reduced_attr, background
		jne	fall_land
fall_bounce:	neg	x_vel
f_cont_tracking:jcxz	fall_fall
		loop	f_tracking

fall_fall:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	al, test_height
		mov	height, al
		inc	y_vel
		ret

fall_die:	mov	action, being_dead
		ret


fall_land:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	al, test_height
		mov	height, al
		call	hit_snd
		cmp	byte ptr y_vel, too_high
		jge	fall_crunch
		mov	action, getting_up
		mov	frame_no, -1
		ret

fall_crunch:	mov	action, lying
		mov	frame_no, -1
		xor	byte ptr direction, left+right
		call	thud_snd
		ret



collapse:	call	drop_own_weapon
		cmp	frame_no, offset colaps_r_0
		je	colsnd
		cmp	frame_no, offset colaps_l_0
		je	colsnd
		ret
colsnd:		jmp	colaps_snd



fly_back:
fly_side:
be_thrown:	mov	ax, y_vel
		and	ax, ax
		jz	fb_y_vel_zero
		jl	fb_y_vel_neg
fb_y_vel_pos:	mov	dx, 1
		jmp	fb_normalized
fb_y_vel_neg:	mov	dx, -1
		neg	ax
		jmp	fb_normalized
fb_y_vel_zero:	xor	dx, dx
fb_normalized:	mov	cx, ax
		mov	ax, map_x
		add	ax, x_vel
		mov	test_map_x, ax
		mov	ax, map_y
		mov	test_map_y, ax
		mov	al, height
		mov	test_height, al

fb_tracking:	add	test_map_y, dx
		sub	test_height, dl
		push	dx
		call	get_surface
		pop	dx
		cmp	byte ptr reduced_attr, fallable
		je	fb_cont_trcking
		cmp	byte ptr reduced_attr, background
		je	fb_bounce
		cmp	byte ptr reduced_attr, outside_map
		je	fb_die
		and	dx, dx
		jge	fb_land
		jmp	fb_cont_trcking
fb_bounce:	neg	x_vel
fb_cont_trcking:jcxz	fb_fb
		loop	fb_tracking

fb_fb:		mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	al, test_height
		mov	height, al
		inc	y_vel
		ret

fb_die:	mov	action, being_dead
		ret

fb_land:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	al, test_height
		mov	height, al
		mov	action, lying
		mov	frame_no, -1
		call	thud_snd
		ret



climb:		mov	ax, map_x
		add	ax, x_vel
		mov	test_map_x, ax
		mov	ax, map_y
		add	ax, y_vel
		mov	test_map_y, ax
		mov	al, height
		sub	al, byte ptr y_vel;subtract from height to go up?
		mov	test_height, al
		call	get_surface
		cmp	byte ptr reduced_attr, climbable
		je	climb_climb
		cmp	byte ptr reduced_attr, walkable
		je	climb_walk
;CMP	byte ptr reduced_attr,fallable
;je	climb_walk

no_climb:	ret

climb_climb:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	al, test_height
		mov	height, al
		ret

climb_walk:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	al, level
		mov	height, al
		mov	action, walking
		mov	frame_no, -1
		ret


hold_up:	mov	ax, map_x
		add	ax, x_vel
		mov	test_map_x, ax
		mov	ax, map_y
		add	ax, y_vel
		mov	test_map_y, ax
		mov	al, height
		mov	test_height, al
		call	get_surface
		cmp	byte ptr reduced_attr, walkable
		je	hu_hu
		cmp	byte ptr reduced_attr, fallable
		je	hu_fall

no_hu:		ret

hu_hu:		mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	al, level
		mov	height, al
		ret

hu_fall:	mov	ax, test_map_x
		mov	map_x, ax
		mov	ax, test_map_y
		mov	map_y, ax
		mov	action, falling
		mov	frame_no, -1
		call	drop_own_weapon
		ret


null_action:	;	********	mov	x_vel, 0
		;	********	mov	y_vel, 0
		ret


above_map:	mov	byte ptr reduced_attr, fallable
	pop	cx
		ret
off_map:	mov	byte ptr reduced_attr, background	;outside_map
	pop	cx		; hmm cant see it making any difference ?
		ret		; or am I going to just screw up the holes
off_rite:		; it appears this causes whole 
	pop	cx
	mov	byte ptr reduced_attr,background	; make things stop.
							; or bounce etc
	ret
off_map_frgs:
;	try to fix the bug is it this ?
	mov	cx,map_bottom
	add	cx,12	;far off the bottom ?
	cmp	ax,cx
	jg	off_bot
	mov	byte ptr reduced_attr, background	;outside_map
	pop	cx		; hmm cant see it making any difference ?
	ret			; or am I going to just screw up the holes

off_bot:
	mov	byte ptr reduced_attr,outside_map
	pop	cx
	ret

get_surface:	
	push	cx
	mov	bx,seg chr_map
	mov	ds,bx	;shouldnt be nesc but you never know ?
		mov	bx, test_map_x
		cmp	bx, 0
		jl	off_map
		cmp	bx, map_right
		jg	off_rite
		shr	bx,1
		and	bl,0feh	; div 4 indexed to words
		mov	ax,test_map_y
		cmp	ax,0
		jl	above_map
		cmp	ax,map_bottom
		jg	off_map_frgs
		
		shr	ax,1
		shr	ax,1	;/4
		push	dx		; if necessary to save
		mul	map_width	;does mul do a trap ? 
		pop	dx
		add	bx,ax
		mov	ah,[bx+offset chr_map]	;attr from char_map NO+4 as already taken care of
;	pushall
;	cmp	si,offset person_table	;hmm
;	jne	no_pr
;	mov	ax,bx	;print the offset into map!
;	mov	dx,16*256
;	mov	cx,4
;;call	pnum	; reduced attr
;no_pr:
;	popall
		and	ah,07eh	;mask out rest of data.
		shr	bx,1	;next is byte map
		mov	al,[bx+offset hat_map]		;the height map
; reduce attribute & update level	( hmm hat-map ?? dmm shite )
; this following stuff is from garys code
	mov	cx,test_map_x
	and	cx,3			; only want 0-3
	mov	dx,test_map_y
	and	dx,3			;0-3
	shl	dx,1
	shl	dx,1
; to get correct table = bx+attr*32 ( ah = attr*2)
	mov	bl,ah
	xor	bh,bh
	shl	bx,1
	shl	bx,1
	shl	bx,1
	shl	bx,1	;=attr*32
	add	bx,offset attr_tabs	;attributes/+16 height modifiers
	add	bx,cx	;x
	add	bx,dx	;y*4
; bx points to attr
	mov	svd,ah	;before the doings
	mov	svd2,al
	mov	ah,[bx]
	mov	cl,[bx+16]
;shr	cl,1	;I think these are halves anyway ?
	add	al,cl	;add to height the height modifier

	mov	bx,offset cvert_attr
	xchg	al,ah
	xlat		;convert to mikes reduced attributes
	xchg	al,ah	; one must hope mike DOES NOT USE 
			; non-reduced attributes in any code !

	cmp	si,offset person_table	;hmm
	jne	not_pl1

	pushall

;mov	al,ah
;xor	ah,ah
;mov	dx,25*256
;mov	cx,3
;call	pnum	; reduced attr
;mov	al,test_height
;xor	ah,ah
;mov	dx,24*256
;mov	cx,3	; test height
;call	pnum
;	mov	al,svd
;	xor	ah,ah
;	mov	dx,32*256
;	mov	cx,3
;	call	pnum	;attribute !?
;	pop	ax

;xor	ah,ah
;mov	dx,40*256
;mov	cx,3
;call	pnum	;level thats been found !
;mov	ax,test_map_x
;mov	cx,3	;3 digits i believe
;mov	dx,256*48
;call	pnum
;mov	ax,test_map_y
;mov	cx,3	;3 digits i believe
;mov	dx,256*56
;call	pnum
;mov	al,svd2
;xor	ah,ah
;mov	cx,3	;3 digits i believe
;mov	dx,256*58
;call	pnum
	popall
not_pl1:

	cmp	byte ptr mission,3	;level 3?
	jne	not_ze_frg
	cmp	word ptr test_map_x,288
	jl	not_ze_frg
	cmp	word ptr test_map_y,48
	jg	not_ze_frg
	cmp	word ptr test_map_x,322
	jg	not_ze_frg
	mov	byte ptr reduced_attr,background
	mov	byte ptr attribute,2	;wall ?
	mov	level,90	;a nice high height to make sure ?
	pop	cx
	ret

not_ze_frg:
;border	13	;must be this !
;	cmp.w d2,d5
;	bcs .higher ;fallable
;	cmp	al,240
;	ja	hole	; that would be -ve on 2s complement.
;	or	al,al	; but have to be silly as there are some high heights
;	jz	hole
	mov	byte ptr attribute,ah	;must put attrr sommeshere!
	cmp	al,0
	jle	hole	;COULD CAUSE BUG OF HEIGHTS > 127
	cmp	al,test_height
	jc	fallx
;cmp	ah,background
;jne	nnnn
	mov	level,al	;nah surely not !
;nnnn:
;jne	errr
	mov	byte ptr reduced_attr,ah
	pop	cx
	ret
hole:	pop	cx
	mov	ah,outside_map
	mov	byte ptr reduced_attr,ah
	ret
errr:	mov	ah,background
	mov	byte ptr reduced_attr,ah
	pop	cx
	ret
	
fallx:
;mov	al,test_height	;is it to fix like this
	cmp	ah,outside_map
	je	exitt
	mov	ah,fallable
exitt:	mov	al,test_height
	mov	level,al	;i think but it seems daft
	mov	byte ptr reduced_attr,ah
;mov	level,al
	pop	cx
	ret

;	move.b (a2),d7	;attribute
;	moveq.l #0,d6
;	move.b (a3),d6	;height modifier
;	add.w d6,d5
;	;beq .zero_height
;	cmp.w d2,d5
;	bcs .higher ;fallable
;	bne .error
;.;exit	movem.l (sp)+,d0-d6/a0-a6
;	rts
;.zero_height
;	moveq.l #5,d7	;Enter Dead bastard sequence
;	bra .exit
;.error	moveq.l #2,d7
;	bra .exit
;	;not.w $ff8240
;	;bra .error
;.higher
;	cmp.b #5,d7
;	beq.s .exit
;.fallable
;	moveq.l #1,d7
;	bra .exit

;attr_table:	dw	offset reduce_walk
;		dw	offset reduce_br_diag
;		dw	offset reduce_tl_diag
;		dw	offset reduce_tr_diag
;		dw	offset reduce_bl_diag
;		dw	offset reduce_bkgd
;		dw	offset reduce_l_vert
;		dw	offset reduce_r_vert
;		dw	offset reduce_door
;		dw	offset reduce_ladder
;		dw	offset reduce_mesh
;		dw	offset reduce_falloff
;		dw	offset reduce_fall_in
;		dw	offset reduce_special
;
;reduce_walk:
;reduce_special:
;		mov	reduced_attr, walkable
;		ret
;
;reduce_br_diag:	mov	dl, byte ptr test_map_x
;		mov	dh, byte ptr test_map_y
;		not	dl
;		and	dx, 0303h
;		cmp	dl, dh
;		jle	reduce_walk
;		jmp	reduce_l_vert
;
;reduce_tl_diag:	mov	dl, byte ptr test_map_x
;		mov	dh, byte ptr test_map_y
;		not	dl
;		and	dx, 0303h
;		cmp	dl, dh
;		jge	reduce_walk
;		jmp	reduce_falloff
;
;reduce_tr_diag:	mov	dl, byte ptr test_map_x
;		mov	dh, byte ptr test_map_y
;		and	dx, 0303h
;		cmp	dl, dh
;		jge	reduce_walk
;		jmp	reduce_falloff
;
;reduce_bl_diag:	mov	dl, byte ptr test_map_x
;		mov	dh, byte ptr test_map_y
;		and	dx, 0303h
;		cmp	dl, dh
;		jle	reduce_walk
;		jmp	reduce_r_vert
;
;reduce_falloff:
;reduce_fall_in:
;		mov	reduced_attr, fallable
;		ret
;
;reduce_bkgd:
;reduce_door:
;		mov	dh, byte ptr test_map_y
;		not	dh
;		and	dh, 3
;		add	al, dh
;		mov	level, al
;		cmp	al, test_height
;		jl	reduce_falloff
;		mov	reduced_attr, background
;		ret
;
;reduce_l_vert:	mov	dl, byte ptr test_map_x
;		mov	dh, byte ptr test_map_y
;		not	dh
;		and	dx, 0303h
;		sub	dh, dl
;		add	al, dh
;		mov	level, al
;		cmp	al, test_height
;		jl	reduce_falloff
;		mov	reduced_attr, background
;		ret
;
;reduce_r_vert:	mov	dl, byte ptr test_map_x
;		mov	dh, byte ptr test_map_y
;		and	dx, 0303h
;		sub	dl, dh
;		add	al, dl
;		mov	level, al
;		cmp	al, test_height
;		jl	reduce_falloff
;		mov	reduced_attr, background
;		ret
;
;reduce_ladder:
;reduce_mesh:
;		mov	dh, byte ptr test_map_y
;		not	dh
;		and	dh, 3
;		add	al, dh
;		mov	level, al
;		cmp	al, test_height
;		jl	reduce_falloff
;		mov	reduced_attr, climbable
;		ret



hurt_detect:	mov	si, offset person_table

next_per_hd:	mov	al, [si+2]
		cmp	al, being_dead
		je	no_hurt
;cmp	al, weapact
;je	no_hurt
		mov	al, [si]
		cmp	al, name_
		je	no_hurt
		mov	bx, [si+6]
		cmp	bx, -1
		je	no_hurt
		test	byte ptr [bx+6], 2
		jz	no_hurt
		call	near_y
		jnc	no_hurt
		call	near_plane
		jnc	no_hurt
		call	near_x
		jnc	no_hurt
		call	hit_kneeing
		call	hit_in_air
		jc	no_hurt
		mov	byte ptr [si+2], taking_punch
		mov	word ptr [si+6], -1
		call	drop_his_weapon
		call	score_it
		mov	al, 1
		call	hurt_em
		call	hit_snd
no_hurt:	add	si, per_list_size
		cmp	name_, player1
		je	test_all_hurt
		cmp	name_, player2
		je	test_all_hurt
		cmp	si, offset person_table + 2 * per_list_size
		jb	next_per_hd
		ret		
test_all_hurt:	cmp	si, offset person_table + 7 * per_list_size
		jb	next_per_hd
		ret




nocdown_detect:	mov	si, offset person_table

next_per_nd:	mov	al, [si+2]
		cmp	al, being_dead
		je	no_nocdown
		mov	al, [si]
		cmp	al, nobody
		je	no_nocdown
		cmp	al, name_
		je	no_nocdown
		mov	bx, [si+6]
		cmp	bx, -1
		je	no_nocdown
		test	byte ptr [bx+6], 2
		jz	no_nocdown
		call	near_y
		jnc	no_nocdown
		call	near_plane
		jnc	no_nocdown
		call	near_x
		jnc	no_nocdown
		
		call	hit_kneeing
		call	knock_over
		mov	al, direction
		cmp	action, elbowing		;backward moves
		je	swap_dir
		cmp	action, turn_kicking		;backward move ?
		jne	no_swap
swap_dir:	xor	al, left+right
no_swap:	call	x_vel_from_dir
		mov	[si+12], ax			; x_vel
		call	drop_his_weapon
		call	score_it
		mov	al, 3
		call	hurt_em

no_nocdown:	add	si, per_list_size
		cmp	name_, player1
		je	test_all_nocd
		cmp	name_, player2
		je	test_all_nocd
		cmp	si, offset person_table + 2 * per_list_size
		jb	next_per_nd
		ret		
test_all_nocd:	cmp	si, offset person_table + 7 * per_list_size
		jb	next_per_nd
		ret



knock_over:	cmp	byte ptr [si+2], flying_back
		je	exit_ko
		cmp	byte ptr [si+2], lying
		je	exit_ko
		cmp	byte ptr [si+2], getting_up
		je	exit_ko
		cmp	byte ptr [si+2], collapsing
		je	exit_ko
		cmp	byte ptr [si+2], bidye	;frig for bill dying
		je	exit_ko
		call	hit_in_air
		jc	exit_ko
		add	byte ptr [si+3], 3		; height
		sub	word ptr [si+10], 3		; map_y
		mov	word ptr [si+14], -2		; y_vel
		mov	al, direction
		call	x_vel_from_dir
		mov	[si+12], ax			; x_vel
		mov	byte ptr [si+2], flying_back	; action
		mov	word ptr [si+6], -1		; frame_no
		cmp	byte ptr [si], linda
		je	lin_yelp
		call	will_snd
		ret
lin_yelp:	call	linda_snd
exit_ko:	ret



hit_kneeing:	cmp	byte ptr [si+2], kneeing
		jne	exit_hk
		mov	bx, [si+18]			; chap being kneed
		mov	word ptr [si+18], nawt_lad
		mov	byte ptr [bx+2], standing
		mov	word ptr [bx+6], -1
exit_hk:	ret




hit_in_air:	mov	al, [si+2]
		cmp	al, jumping
		je	yes_hia
		cmp	al, jump_kicking
		je	yes_hia
		cmp	al, turn_kicking
		je	yes_hia
		clc
		ret
yes_hia:	mov	byte ptr [si+2], flying_back
		mov	word ptr [si+6], -1
		call	drop_his_weapon
		stc
		ret


near_x:		mov	ax, [si+8]
		sub	ax, map_x
		mov	dx, ax
		mov	al, direction
		and	al, 3
		dec	al
		add	al, action
		cbw
		shl	ax, 1
		add	ax, offset range_tab - 8
	cmp	action,62	;running/cartwheel
	jne	not_cart
	sub	ax,offset range_tab -8
	add	ax,offset cart_tab_f
not_cart:	mov	bx, ax
		mov	al, [bx]
		cbw
		cmp	dx, ax
		jl	not_near_x
		mov	al, [bx+1]
		cbw
		cmp	dx, ax
		jg	not_near_x
		cmp	action,	punching		; kicking
		jne	no_knee
		cmp	weapon_held, nawt_lad
		jne	no_knee
		mov	al, [si+1]
	cmp	al,captain	;allow for captain to be got !
	je	er_knee
		cmp	al, williams
		jg	no_knee			; can only knee ropers or williams
er_knee:
		cmp	name_, player1		; might change ?
		je	over_knee_1
		cmp	name_, player2
		jne	no_knee
over_knee_1:	mov	al, [si+2]
		cmp	al, standing
		je	over_knee_2
		cmp	al, walking
		jne	no_knee
over_knee_2:	mov	al, direction
		and	al, [si+4]
		and	al, 3
		jnz	no_knee	;must be facing each other.
		cmp	dx, -4
		jl	no_knee
		cmp	dx, 4
		jg	no_knee
		mov	action, kneeing
		mov	frame_no, -1
		mov	weapon_held, si
		mov	byte ptr [si+2], being_kneed
		mov	word ptr [si+6], -1
		call	drop_his_weapon
		jmp	not_near_x
no_knee:	stc
		ret
not_near_x:	clc
		ret




near_y:		mov	ax, [si+10]
		sub	ax, map_y
		cmp	ax, -12
		jl	not_near_y
		cmp	ax, 5
		jg	not_near_y
		stc
		ret
not_near_y:	clc
		ret




near_plane:	mov	al, [si+3]
		sub	al, height
		cbw
		add	ax, [si+10]
		sub	ax, map_y
		cmp	ax, -1
		jl	not_near_plane
		cmp	ax, 1
		jg	not_near_plane
		stc
		ret
not_near_plane:	clc
		ret




drop_own_weapon:mov	bx, weapon_held
		cmp	bx, nawt_lad
		je	exit_dow
		mov	weapon_held, nawt_lad
		mov	word ptr [bx+16], nobody	; w_bearer
		mov	byte ptr [bx+2], dropping	; w_action
		mov	word ptr [bx+4], -1		; w_frame_no
		mov	word ptr [bx+12], -2		; w_y_vel
		mov	al, direction
		call	x_vel_from_dir
		mov	[bx+10], ax			; w_x_vel
exit_dow:	ret



drop_his_weapon:mov	ax, [si+18]
		mov	bx, ax
		cmp	bx, nawt_lad
		je	exit_dhw
		mov	word ptr [si+18], nawt_lad
		mov	word ptr [bx+16], nobody	; w_bearer
		mov	byte ptr [bx+2], dropping	; w_action
		mov	word ptr [bx+4], -1		; w_frame_no
		mov	word ptr [bx+12], -2		; w_y_vel
		mov	al, [si+4]
		call	x_vel_from_dir
		mov	[bx+10], ax			; w_x_vel
exit_dhw:	ret



score_it:	
	call	git_score	;
		cmp	name_, player1
		je	score_pl1
		cmp	name_, player2
		je	score_pl2
		ret
score_pl1:	add	pl1_score, ax
		mov	ax, pl1_score
		cmp	ax, hi_score
		jle	exit_si
		mov	hi_score, ax
		ret
score_pl2:	add	pl2_score, ax
		mov	ax, pl2_score
		cmp	ax, hi_score
		jle	exit_si
		mov	hi_score, ax
exit_si:	ret

git_score:
; using the byte code action
	mov	bl,action
	xor	bh,bh
	mov	ax,[bx+offset score_table]
	ret

hurt_em:	sub	byte ptr [si+5], al
		jge	str_pos
		mov	byte ptr [si+5], 0
str_pos:	test	byte ptr [si+5], 11b
		jnz	exit_he
		call	knock_over
exit_he:	ret



cseg		ends


dseg		segment	public 'data'


extrn		start_seg:word, start_offset:word, file_name:word
extrn		chr_map:word, chr_blocks:byte, sprt_table:word
extrn		keybd:byte, map_width:word, ss_save:word, colaps_l_0:word
extrn		scrn_top:word, scrn_left:word, colaps_r_0:word,type_:byte
extrn		name_:byte, action:byte, frame_no:word, map_x:word, map_y:word
extrn		height:byte, test_map_x:word, test_map_y:word
extrn		test_height:byte, x_vel:word, y_vel:word
extrn		controls:byte, direction:byte, level:byte, attribute:byte
extrn		reduced_attr:byte, walk_dr_0:word, walk_dl_0:word
extrn		hat_map:word, sprt_index:word, person_table:byte
extrn		weapon_held:word, map_right:word, map_bottom:word
extrn		pl1_score:word, pl2_score:word, hi_score:word
extrn	mission:byte

svd	db	0
svd2	db	0


score_table	label	word	; One byte per action. rem *10 value
		dw	0	;dead
		dw	0	;walk
		dw	5	;punch
		dw	10	;back kick
		dw	20	;jumpkick
		dw	20	;turnkick convert to hurricane
		dw	16	;elbowing
		dw	0	;no headbutt
		dw	20	;club swinging
		dw	20	;whipping
		dw	0	;jumping
		dw	50	;throwing knife
		dw	20	;thrw rock
; lets hope no bigger numbers are used !

range_tab	db	2, 10, -10, -2		; punch
		db	2, 10, -10, -2		; kick
		db	-3, 10, -10, 3		; jk
		db	-12, -0, 0, 12		; tk getting bit silly ?!
		db	-5, -1, 1, 5		; elbo
		db	1, 5, -5, -1		; hbutt
		db	2, 12, -12, -2		; club
		db	1, 11, -11, -1		; whip
cart_tab_f	db	4, 10,-10,-4		; cart !
even

cvert_attr	db	walkable,fallable,background,climbable
		db	walkable,outside_map		;hmmm
;		db	woz special		; ? conv was causing problem
attr_tabs	label byte
;	0=walkable 1=fallable 2=wall 3=climbable 4=conveyor 5=die bastard(hole)
;
;	block 0

	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0

	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
;block1
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2

	db 3,3,3,3
	db 2,2,2,2
	db 1,1,1,1
	db 0,0,0,0
;block 2
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2

	db 3,4,5,6
	db 2,3,4,5
	db 1,2,3,4
	db 0,1,2,3
;block 3
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2

	db 3,3,4,5
	db 2,2,3,4
	db 1,1,2,3
	db 0,0,1,2
;block 4
	db 0,0,2,2
	db 0,0,0,2
	db 0,0,0,0
	db 0,0,0,0

	db 0,0,0,1
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
;block 5
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2
	db 0,2,2,2

	db 2,3,4,5
	db 1,2,3,4
	db 0,1,2,3
	db 0,0,1,2
;block 6
	db 2,2,0,0
	db 2,2,2,0
	db 2,2,2,2
	db 2,2,2,2

	db 3,4,5,5
	db 2,3,4,5
	db 1,2,3,4
	db 0,1,2,3
;block 7
	db 2,2,2,2
	db 2,2,2,2
	db 0,0,0,0
	db 0,0,0,0

	db 1,1,1,1
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
;block 8
	db 0,0,0,0
	db 0,0,0,0
	db 2,2,2,2
	db 2,2,2,2

	db 2,2,2,2
	db 2,2,2,2
	db 1,1,1,1
	db 0,0,0,0
;block 9
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
	db 2,0,0,0

	db 1,1,1,1
	db 1,1,1,1
	db 1,1,1,1
	db 0,1,1,1
;block 10
	db 3,3,3,3
	db 3,3,3,3
	db 3,3,3,3
	db 3,3,3,3

	db 3,3,3,3
	db 2,2,2,2
	db 1,1,1,1
	db 0,0,0,0
;block 11
	db 3,3,3,3
	db 3,3,3,3
	db 0,0,0,0
	db 0,0,0,0

	db 1,1,1,1
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
;block 12
	db 0,0,0,0
	db 0,0,0,0
	db 3,3,3,3
	db 3,3,3,3

	db 2,2,2,2
	db 2,2,2,2
	db 1,1,1,1
	db 0,0,0,0
;block 13
	db 2,2,2,2
	db 0,2,2,2
	db 0,0,2,2
	db 0,0,0,2

	db 0,1,2,3
	db 0,0,1,2
	db 0,0,0,1
	db 0,0,0,0
;block 14
	db 0,0,0,0
	db 2,0,0,0
	db 2,2,0,0
	db 2,2,2,0

	db 3,3,3,3
	db 2,3,3,3
	db 1,2,3,3
	db 0,1,2,3
;block 15
	db 2,0,0,0
	db 2,2,0,0
	db 2,2,2,0
	db 2,2,2,2

	db 3,4,4,4
	db 2,3,4,4
	db 1,2,3,4
	db 0,1,2,3
;block 16
	db 0,2,2,2
	db 0,0,2,2
	db 0,0,0,2
	db 0,0,0,0

	db 0,0,1,2
	db 0,0,0,1
	db 0,0,0,0
	db 0,0,0,0
;block 17
	db 2,0,0,0
	db 2,2,0,0
	db 2,2,2,2
	db 2,2,2,2

	db 3,4,4,4
	db 2,3,4,4
	db 1,2,3,3
	db 0,1,2,2
;block 18
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2

	db 3,4,5,5
	db 2,3,4,4
	db 1,2,3,3
	db 0,1,2,2
;block 19
	db 0,2,2,2
	db 0,0,2,2
	db 0,0,0,0
	db 0,0,0,0

	db 0,0,1,1
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
;block 20
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2

	db 3,3,3,4
	db 2,2,2,3
	db 1,1,1,2
	db 0,0,0,1
;block 21
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2

	db 3,4,4,4
	db 2,3,3,3
	db 1,2,2,2
	db 0,1,1,1
;block 22
	db 0,0,2,2
	db 0,0,0,2
	db 2,2,2,2
	db 2,2,2,2

	db 2,2,2,4
	db 2,2,2,3
	db 1,1,1,2
	db 0,0,0,1
;block 23
	db 2,2,2,2
	db 2,2,2,2
	db 0,0,0,2
	db 0,0,0,0

	db 1,1,1,2
	db 0,0,0,1
	db 0,0,0,0
	db 0,0,0,0
;block 24
	db 0,0,0,2
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0

	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
;block 25
	db 2,2,2,0
	db 2,2,2,2
	db 0,2,2,2
	db 0,0,2,2

	db 1,2,3,4
	db 0,1,2,3
	db 0,0,1,2
	db 0,0,0,1
;block 26
	db 0,0,0,0
	db 0,0,0,0
	db 2,0,0,0
	db 2,2,0,0

	db 2,2,2,2
	db 2,2,2,2
	db 1,2,2,2
	db 0,1,2,2
;block 27
	db 2,2,2,2
	db 2,2,2,2
	db 0,2,2,2
	db 0,0,2,2

	db 1,2,3,3
	db 0,1,2,2
	db 0,0,1,1
	db 0,0,0,0
;block 28
	db 2,2,2,2
	db 2,2,2,2
	db 0,0,0,0
	db 2,0,0,0

	db 2,2,2,2
	db 1,1,1,1
	db 1,1,1,1
	db 0,1,1,1
;block 29
	db 2,2,2,2
	db 2,2,2,2
	db 0,0,2,2
	db 0,0,0,2

	db 1,1,2,3
	db 0,0,1,2
	db 0,0,0,1
	db 0,0,0,0
;block 30
	db 2,2,2,2
	db 0,2,2,2
	db 2,2,2,2
	db 2,2,2,2

	db 2,3,3,3
	db 2,2,2,2
	db 1,1,1,1
	db 0,0,0,0
;block 31
	db 2,2,0,0
	db 2,2,2,0
	db 2,2,2,2
	db 2,2,2,2

	db 3,3,4,4
	db 2,2,3,4
	db 1,1,2,3
	db 0,0,1,2
;block 32
	db 2,4,4,4
	db 2,2,4,4
	db 2,2,2,4
	db 2,2,2,2

	db 3,4,4,4
	db 2,3,4,4
	db 1,2,3,4
	db 0,1,2,3
;block 33
	db 4,4,4,4
	db 4,4,4,4
	db 4,4,4,4
	db 4,4,4,4

	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
;block 34
	db 4,4,4,5
	db 4,4,4,4
	db 4,4,4,4
	db 4,4,4,4

	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
	db 0,0,0,0
;block 35
	db 5,5,5,5
	db 5,5,5,5
	db 4,5,5,5
	db 4,4,5,5

	db 1,2,3,4
	db 0,1,2,3
	db 0,0,1,2
	db 0,0,0,1
;block 36
	db 5,5,5,5
	db 5,5,5,5
	db 5,5,5,5
	db 5,5,5,5
	
	db 3,4,5,6
	db 2,3,4,5
	db 1,2,3,4
	db 0,1,2,3
;block 37
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2
	db 0,2,2,2
	
	db 2,3,3,3
	db 1,2,2,2
	db 0,1,1,1
	db 0,0,0,0
;block 38
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2

	db 6,5,4,3
	db 5,4,3,2
	db 4,3,2,1
	db 3,2,1,0
;block 39
	db 2,2,2,2
	db 2,2,2,2
	db 2,2,2,2
	db 0,2,2,2

	db 2,3,3,3
	db 1,2,2,2
	db 0,1,1,1
	db 0,0,0,0


dseg		ends

end
