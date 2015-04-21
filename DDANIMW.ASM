
assume		ds:dseg

dseg		segment	public 'data'

include		ddaddres.asm

right	equ	1
left	equ	2

public		club_heldr, club_heldl ,whip_held_r, whip_held_l, barrel_stat, crate_stat
public		w_frame_0_table, club_stat, whip_stat, tnt_stat, knife_stat
public		tnt_thrown_r_7, tnt_thrown_l_7, barrel_held_r, barrel_held_l
public		knife_thrn_r_7, knife_thrn_l_7, crate_held_r, crate_held_l
public		rock_held, blowup_0, splat_0, null_0, splash_0, flame_0
public		thumb_0,smash_1_0,stone_0,stone_1,stab_0,stab_1
public		platf_0,smash_5_0,stab_2x,wall_0,stab_1f
public		gunfire_0

public		club_0f,bale_0
public		null_0f,wepend

w_frame_0_table	dw	?, ?, ?, ?, ?, ?, ?		; nonexistent

		dw	offset club_stat
		dw	offset whip_stat
		dw	offset knife_stat
		dw	offset tnt_stat
		dw	offset barrel_stat
		dw	offset crate_stat
		dw	offset rock_stat

		dw	offset club_drop
		dw	offset whip_drop
		dw	offset knife_drop
		dw	offset tnt_drop
		dw	offset barrel_drop
		dw	offset crate_drop
		dw	offset rock_drop

		dw	?				; right-handed moves
		dw	?
		dw	offset knife_thrn_r_0
		dw	offset tnt_thrown_r_0
		dw	offset barrel_roll_r_0
		dw	offset crate_slide
		dw	offset rock_slide_r_0

		dw	offset club_used_r_0
		dw	offset whip_used_r_0
		dw	offset knife_used_r_0
		dw	offset tnt_used_r_0
		dw	?
		dw	?
		dw	?

		dw	offset club_heldr
		dw	offset whip_held_r
		dw	offset knife_held
		dw	offset tnt_held
		dw	offset barrel_held_r
		dw	offset crate_held_r
		dw	offset rock_held

		dw	?
		dw	?
		dw	?
		dw	?
		dw	offset barrel_pkp_r_0
		dw	offset crate_pkp_r_0
		dw	offset rock_pkp_0

;	MIKE ASSUMED 56 gap between starts of these two tables

		dw	?				; left-handed moves
		dw	?
		dw	offset knife_thrn_l_0
		dw	offset tnt_thrown_l_0
		dw	offset barrel_roll_l_0
		dw	offset crate_slide
		dw	offset rock_slide_l_0

		dw	offset club_used_l_0
		dw	offset whip_used_l_0
		dw	offset knife_used_l_0
		dw	offset tnt_used_l_0
		dw	?
		dw	?
		dw	?

		dw	offset club_heldl
		dw	offset whip_held_l
		dw	offset knife_held
		dw	offset tnt_held
		dw	offset barrel_held_l
		dw	offset crate_held_l
		dw	offset rock_held

		dw	?
		dw	?
		dw	?
		dw	?
		dw	offset barrel_pkp_l_0
		dw	offset crate_pkp_l_0
		dw	offset rock_pkp_0




null_0		dw	offset null_0f, offset null_0

club_stat	dw	offset club_3f, offset club_stat	,right
whip_stat	dw	offset whip_1f, offset whip_stat	,right
knife_stat	dw	offset knife_2f, offset knife_stat	,right
tnt_stat	dw	offset tnt_2f, offset tnt_stat		,right
barrel_stat	dw	offset barrel_3f, offset barrel_stat	,right
crate_stat	dw	offset crate_0f, offset crate_stat	,right
rock_stat	dw	offset rock_0f, offset rock_stat	,right


club_drop	dw	offset club_4f, offset club_drop	,right
whip_drop	dw	offset whip_2f, offset whip_drop	,right
knife_drop	dw	offset knife_1f, offset knife_drop	,right
tnt_drop	dw	offset tnt_1f, offset tnt_drop		,right
barrel_drop	dw	offset barrel_3f, offset barrel_drop	,right
crate_drop	dw	offset crate_1f, offset crate_drop	,right
rock_drop	dw	offset rock_0f, offset rock_drop	,right


knife_thrn_r_0	dw	offset knife_0f, offset knife_thrn_r_1	,right
knife_thrn_r_1	dw	offset knife_1f, offset knife_thrn_r_2	,right
knife_thrn_r_2	dw	offset knife_2f, offset knife_thrn_r_3	,right
knife_thrn_r_3	dw	offset knife_3f, offset knife_thrn_r_4	,right
knife_thrn_r_4	dw	offset knife_4f, offset knife_thrn_r_5	,right
knife_thrn_r_5	dw	offset knife_5f, offset knife_thrn_r_6	,right
knife_thrn_r_6	dw	offset knife_6f, offset knife_thrn_r_7	,right
knife_thrn_r_7	dw	offset knife_7f, offset knife_thrn_r_0	,right

knife_thrn_l_0	dw	offset knife_0f, offset knife_thrn_l_1	,left
knife_thrn_l_1	dw	offset knife_7f, offset knife_thrn_l_2	,left
knife_thrn_l_2	dw	offset knife_6f, offset knife_thrn_l_3	,left
knife_thrn_l_3	dw	offset knife_5f, offset knife_thrn_l_4	,left
knife_thrn_l_4	dw	offset knife_4f, offset knife_thrn_l_5	,left
knife_thrn_l_5	dw	offset knife_3f, offset knife_thrn_l_6	,left
knife_thrn_l_6	dw	offset knife_2f, offset knife_thrn_l_7	,left
knife_thrn_l_7	dw	offset knife_1f, offset knife_thrn_l_0	,left

tnt_thrown_r_0	dw	offset tnt_0f, offset tnt_thrown_r_1	,right
tnt_thrown_r_1	dw	offset tnt_1f, offset tnt_thrown_r_7	,right
tnt_thrown_r_7	dw	offset tnt_2f, offset tnt_thrown_r_0	,right

tnt_thrown_l_0	dw	offset tnt_0f, offset tnt_thrown_l_1	,left
tnt_thrown_l_1	dw	offset tnt_1f, offset tnt_thrown_l_7	,left
tnt_thrown_l_7	dw	offset tnt_2f, offset tnt_thrown_l_0	,left

barrel_roll_r_0 dw	offset barrel_3f, offset barrel_roll_r_1	,right
barrel_roll_r_1 dw	offset barrel_3f, offset barrel_roll_r_0	,left

barrel_roll_l_0 dw	offset barrel_3f, offset barrel_roll_l_1	,left
barrel_roll_l_1 dw	offset barrel_3f, offset barrel_roll_l_0	,right

crate_slide	dw	offset crate_0f, offset crate_slide	,right

rock_slide_r_0	dw	offset rock_0f, offset rock_slide_r_1	,right
rock_slide_r_1	dw	offset rock_1f, offset rock_slide_r_2	,left
rock_slide_r_2	dw	offset rock_1f, offset rock_slide_r_0	,right

rock_slide_l_0	dw	offset rock_0f, offset rock_slide_l_1	,left
rock_slide_l_1	dw	offset rock_1f, offset rock_slide_l_2	,right
rock_slide_l_2	dw	offset rock_1f, offset rock_slide_l_0	,left

club_used_r_0	dw	offset club_3f, offset club_used_r_1	,left
club_used_r_1	dw	offset null_0f, offset club_used_r_2	,right
club_used_r_2	dw	offset club_3f, offset club_used_r_3	,right
club_used_r_3	dw	offset club_2f, offset club_heldr	,right

club_used_l_0	dw	offset club_3f, offset club_used_l_1	,right
club_used_l_1	dw	offset null_0f, offset club_used_l_2	,left
club_used_l_2	dw	offset club_3f, offset club_used_l_3	,left
club_used_l_3	dw	offset club_2f, offset club_heldl	,left

whip_used_r_0	dw	offset whip_3f, offset whip_used_r_1	,right
whip_used_r_1	dw	offset whip_1f, offset whip_used_r_2	,right
whip_used_r_2	dw	offset whip_2f, offset whip_used_r_3	,right
whip_used_r_3	dw	offset whip_2f, offset whip_held_r	,right

whip_used_l_0	dw	offset whip_3f, offset whip_used_l_1	,left
whip_used_l_1	dw	offset whip_1f, offset whip_used_l_2	,left
whip_used_l_2	dw	offset whip_2f, offset whip_used_l_3	,left
whip_used_l_3	dw	offset whip_2f, offset whip_held_r	,left

knife_used_r_0	dw	offset knife_0f, offset knife_used_r_1	,right
knife_used_r_1	dw	offset knife_1f, offset knife_thrn_r_7	,right

knife_used_l_0	dw	offset knife_0f, offset knife_used_l_1	,left
knife_used_l_1	dw	offset knife_1f, offset knife_thrn_l_7	,left

tnt_used_r_0	dw	offset tnt_0f, offset tnt_used_r_1	,right
tnt_used_r_1	dw	offset tnt_1f, offset tnt_thrown_r_7	,right

tnt_used_l_0	dw	offset tnt_0f, offset tnt_used_l_1	,left
tnt_used_l_1	dw	offset tnt_1f, offset tnt_thrown_l_7	,left


club_heldr	dw	offset club_4f, offset club_heldr	,right
club_heldl	dw	offset club_4f, offset club_heldl	,left
whip_held_r	dw	offset whip_0f, offset whip_held_r	,right
whip_held_l	dw	offset whip_0f, offset whip_held_l	,left
knife_held	dw	offset knife_0f, offset knife_held	,right
tnt_held	dw	offset tnt_0f, offset tnt_held		,right
barrel_held_r	dw	offset barrel_3f, offset barrel_held_r	,right
barrel_held_l	dw	offset barrel_3f, offset barrel_held_l	,left
crate_held_r	dw	offset crate_0f, offset crate_held_r	,right
crate_held_l	dw	offset crate_1f, offset crate_held_l	,left
rock_held	dw	offset rock_0f, offset rock_held	,right


barrel_pkp_r_0	dw	offset barrel_3f, offset barrel_pkp_r_1	,right
barrel_pkp_r_1	dw	offset barrel_3f, offset barrel_pkp_r_2	,right
barrel_pkp_r_2	dw	offset barrel_0f, offset barrel_held_r	,right

barrel_pkp_l_0	dw	offset barrel_3f, offset barrel_pkp_l_1	,left
barrel_pkp_l_1	dw	offset barrel_3f, offset barrel_pkp_l_2	,left
barrel_pkp_l_2	dw	offset barrel_0f, offset barrel_held_l	,left

crate_pkp_r_0	dw	offset crate_0f, offset crate_pkp_r_1	,right
crate_pkp_r_1	dw	offset crate_1f, offset crate_pkp_r_2	,right
crate_pkp_r_2	dw	offset crate_2f, offset crate_held_r	,right

crate_pkp_l_0	dw	offset crate_0f, offset crate_pkp_l_1	,left
crate_pkp_l_1	dw	offset crate_1f, offset crate_pkp_l_2	,left
crate_pkp_l_2	dw	offset crate_2f, offset crate_held_l	,left

rock_pkp_0	dw	offset rock_0f, offset rock_pkp_1	,right
rock_pkp_1	dw	offset rock_0f, offset rock_pkp_2	,right
rock_pkp_2	dw	offset rock_0f, offset rock_held	,right

thumb_0		dw	offset thumb_0f, offset thumb_1	,right
thumb_1		dw	offset thumb_0f, offset thumb_2	,right
thumb_2		dw	offset thumb_0f, offset thumb_3	,right
thumb_3		dw	offset null_0f, offset thumb_4	,right
thumb_4		dw	offset null_0f, offset thumb_5	,right
thumb_5		dw	offset null_0f, offset thumb_0	,right

;	kill this rubbish eventually !
splash_0	dw	offset splash_0f, offset splash_1	,right
splash_1	dw	offset splash_1f, offset splash_2	,right
splash_2	dw	offset splash_2f, offset null_0	,right

splat_0		dw	offset splat_0f, offset splat_1	,right
splat_1		dw	offset splat_0f, offset null_0	,right
;think theres no splat in ddii??

flame_0		dw	offset flame_0f, offset flame_1	,right
;flame_1a	dw	offset null_0f,offset flame_1		,right
flame_1		dw	offset flame_1f, offset flame_2	,right
;flame_2a	dw	offset null_0f,offset flame_2		,right
flame_2		dw	offset flame_2f, offset flame_0	,right
;flame_0a	dw	offset null_0f,offset flame_0		,right

blowup_0	dw	offset blowup_0f, offset blowup_1	,right
blowup_1	dw	offset blowup_0f, offset blowup_2	,left
blowup_2	dw	offset blowup_1f, offset blowup_3	,right
blowup_3	dw	offset blowup_2f, offset blowup_4	,left
blowup_4	dw	offset blowup_2f, offset null_0		,right

smash_1_0	dw	offset smash_1_0f,offset smash_1_1	,right
smash_1_1	dw	offset smash_1_0f,offset smash_1_2	,right
smash_1_2	dw	offset smash_1_0f,offset smash_1_3	,right
smash_1_3	dw	offset smash_1_0f,offset smash_1_4	,right
smash_1_4	dw	offset smash_1_1f,offset smash_1_5	,right
smash_1_5	dw	offset smash_1_2f,offset null_0		,right

platf_0		dw	offset platf_0f,offset platf_0	,right

smash_5_0	dw	offset smash_5_0f,offset smash_5_0	,right
smash_5_1	dw	offset smash_5_1f,offset smash_5_2	,right
smash_5_2	dw	offset smash_5_2f,offset null_0		,right

gunfire_0	dw	offset blowup_0f, offset gunfire_1	,right
gunfire_1	dw	offset blowup_0f, offset gunfire_2	,right
gunfire_2	dw	offset blowup_0f, offset gunfire_3	,right
gunfire_3	dw	offset blowup_0f, offset gunfire_4	,right
gunfire_4	dw	offset blowup_0f, offset gunfire_5	,right
gunfire_5	dw	offset blowup_0f, offset null_0		,right

bale_0		dw	offset bale_0f,offset bale_0	,right	; right ?
wall_0		dw	offset wall_0f, offset wall_0	,right	;?

stone_0		dw	offset stone_1f,offset stone_0a	,right
stone_0a	dw	offset stone_0f,offset stone_0b	,right
stone_0b	dw	offset stone_1f,offset null_0	,right

stone_1		dw	offset null_0f,offset stone_1a	,right
stone_1a	dw	offset stone_1f,offset stone_1b	,right
stone_1b	dw	offset null_0f,offset null_0	,right

stab_0		dw	offset stab_0f,offset stab_01	,right
stab_01		dw	offset stab_0f,offset stab_0a	,right
stab_0a		dw	offset stab_1f,offset stab_0a1	,right
stab_0a1	dw	offset stab_1f,offset stab_2x	,right
stab_2x		dw	offset stab_0f,offset stab_2x	,right

				; the small animation needs restarting !

stab_1		dw	offset null_0f,offset stab_11	,right
stab_11		dw	offset null_0f,offset stab_1a	,right
stab_1a		dw	offset stab_0f,offset stab_1a1	,right
stab_1a1	dw	offset stab_0f,offset stab_1b	,right
stab_1b		dw	offset null_0f,offset null_0	,right


even

null_0f		dw	we_hand_0
		db	2, 2, -100,-100	;ah I think that'uns a brill frig!

wall_0f		dw	we_wall_0
		db	12,40,0,0

stab_0f		dw	we_stab_0
		db	12,28,-10,0
stab_1f		dw	we_stab_1
		db	10,22,-8,0

stone_0f	dw	we_stone_0
		db	10,38,0,0
stone_1f	dw	we_stone_1
		db	10,38,0,0

bale_0f		dw	we_bale_0
		db	8,64,0,8	;move down 

club_0f		dw	we_spade_0
		db	8, 12, -4, -8
club_1f		dw	we_spade_1
		db	8,14,-4,-10
club_2f		dw	we_spade_2
		db	6,12,-3,-8
club_3f		dw	we_spade_3
		db	8,10,-4,-6
club_4f		dw	we_spade_4
		db	4,32,-2,-8	;quick frig?
club_5f		dw	we_spade_5
		db	8,20,-4,-16
club_6f		dw	we_spade_6
		db	8,20,-4,-16

whip_0f		dw	we_chain_0
		db	4, 18, -2, -12	;moved right a bit
whip_1f		dw	we_chain_1
		db	8, 20, -3, -16
whip_2f		dw	we_chain_2
		db	6, 34, -3, -16
whip_3f		dw	we_chain_3
		db	4, 42, -3, -16

crate_0f	dw	we_crate_0
		db	10, 34, -4, -30
crate_1f	dw	we_crate_1
		db	8, 44, -3, -40
crate_2f	dw	we_crate_2
		db	10, 42, -4, -38
crate_3f	dw	we_crate_3
		db	8,44, -3, -40

knife_0f	dw	we_knife_0
		db	4, 16, -2, -10
knife_1f	dw	we_knife_1
		db	4, 16, -3, -10
knife_2f	dw	we_knife_2
		db	4, 10, -3, -5
knife_3f	dw	we_knife_3
		db	4, 16, -3, -10
knife_4f	dw	we_knife_4	;mega frigg !
		db	4, 16, -3, -10
knife_5f	dw	we_knife_5
		db	4, 16, -3, -10
knife_6f	dw	we_knife_6
		db	4, 10, -3, -5
knife_7f	dw	we_knife_7
		db	4, 16, -3, -10


barrel_0f	dw	we_log_0			;make this the log
		db	12, 32, -6, -28;
;barrel_1f	dw	we_log_0
;db	12,42,-6,-38
;barrel_2f	dw	we_log_0
;db	8,48,-4,-44
barrel_3f	dw	we_log_3
		db	8,40,-4,-36

rock_0f		dw	we_ball_0
		db	8,32,-4,-28
rock_1f		dw	we_ball_1
		db	8,32,-4,-28

tnt_0f		dw	we_gren_0
		db	4,8,-1,-4
tnt_1f		dw	we_gren_1
		db	4,8,-1,-4
tnt_2f		dw	we_gren_2
		db	4,8,-1,-4

thumb_0f	dw	we_hand_0
		db	10, 24, -5, -18

splash_0f	dw	16080
		db	8, 24, -3, -18
splash_1f	dw	16464
		db	10, 40, -4, -30
splash_2f	dw	17264
		db	12, 46, -5, -33

splat_0f	dw	we_hand_0
		db	2, 2, -100, -100

flame_0f	dw	we_flame_0
		db	6, 34, -4, -34
flame_1f	dw	we_flame_1
		db	6, 28, -4, -28
flame_2f	dw	we_flame_2
		db	6, 26, -4, -26

;

blowup_0f	dw	we_explo_0
		db	8, 26, -4, -16
blowup_1f	dw	we_explo_1
		db	8, 28, -4, -18
blowup_2f	dw	we_explo_2
		db	8, 22, -4, -12

smash_1_0f	dw	23740
		db	8,64,-3,-60
smash_1_1f	dw	24764
		db	12,64,-3,-60
smash_1_2f	dw	26300
		db	12,54,-3,-50

platf_0f	dw	27596
		db	18,34,-3,-30


smash_5_0f	dw	29972
		db	12,72,-3,-68
smash_5_1f	dw	31700
		db	12,72,-3,-68
smash_5_2f	dw	33428
		db	8,52,-3,-48

wepend	label	word

dseg		ends

wep_seg		segment	public 'data'
extrn		weapon_data:byte
wep_seg		ends

end
