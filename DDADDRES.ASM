
;
;	A list of just addresses for the sprite tables
;

pl_walkd_0	equ	0			;y
pl_walkd_1	equ	pl_walkd_0+384		;y
pl_walkd_2	equ	pl_walkd_1+512		;y
pl_walkd_3	equ	pl_walkd_2+512		;y

pl_punch_0	equ	pl_walkd_3+384		;y
pl_punch_1	equ	pl_punch_0+640		;y
pl_punch_2	equ	pl_punch_1+1024		;y

pl_kickb_0	equ	pl_punch_2+640		;y
pl_kickb_1	equ	pl_kickb_0+448		;y

pl_turnk_0	equ	pl_kickb_1+756		;n
pl_turnk_1	equ	pl_turnk_0+580		;n use this ???
pl_turnk_2	equ	pl_turnk_1+560		;n main kick frame
pl_turnk_3	equ	pl_turnk_2+876		;n
pl_turnk_4	equ	pl_turnk_3+720		;n

pl_jmp_0	equ	pl_turnk_4+600		;y
pl_jmp_1	equ	pl_jmp_0+660		;y
pl_jmp_2	equ	pl_jmp_1+532		;y

scrn1	equ	10416			;10236!

;*****************************************


pl_elbow_0	equ	scrn1			;y
pl_elbow_1	equ	pl_elbow_0+372		;y
pl_tkpch_0	equ	pl_elbow_1+640		;y
;pl_tkpch_1	equ	pl_tkpch_0+512		;
pl_flybk_0	equ	pl_tkpch_0+512	;416	;y
pl_flysd_0	equ	pl_flybk_0+588		;y
pl_lie_0	equ	pl_flysd_0+476		;y
pl_die_0	equ	pl_lie_0+420		;y
pl_die_1	equ	pl_die_0+408		;y
pl_fall_0	equ	pl_die_1+420		;y
pl_walku_0	equ	pl_fall_0+300		;y
pl_walku_3	equ	pl_walku_0+496		;y

scrn2	equ	scrn1+5128

;*****************************************

pl_holdu_1	equ	scrn2			;y
pl_holdu_3	equ	pl_holdu_1+480		;y
pl_whip_0	equ	pl_holdu_3+480		;y
pl_whip_1	equ	pl_whip_0+720		;y
pl_whip_2	equ	pl_whip_1+496		;y
;pl_whip_3	equ	pl_whip_2+744		;
pl_clam_0	equ	pl_whip_2+744		;y
pl_clam_3	equ	pl_clam_0+512		;y
pl_getu_0	equ	pl_clam_3+384		;y
pl_holdd_0	equ	pl_getu_0+420		;y
pl_holdd_3	equ	pl_holdd_0+480		;y

scrn3	equ	scrn2+5196

;*****************************************

pl_flyk_0	equ	scrn3			;n
pl_flyk_1	equ	pl_flyk_0+448		;n
pl_flyk_2	equ	pl_flyk_1+480		;n
pl_flyk_3	equ	pl_flyk_2+432		;n
pl_flyk_4	equ	pl_flyk_3+832		;n
pl_throk_0	equ	pl_flyk_4+432		;y
pl_prok_0	equ	pl_throk_0+432		;y
pl_swing_0	equ	pl_prok_0+400		;y
pl_swing_1	equ	pl_swing_0+464		;y
pl_swing_2	equ	pl_swing_1+480		;y
pl_swing_3	equ	pl_swing_2+600		;y
;		pl_uppu_1	equ	pl_swing_3+496
pl_barrk_0	equ	pl_swing_3+496		;y
pl_barrk_1	equ	pl_barrk_0+600		;y
pl_grbil_1	equ	pl_barrk_1+448		;y
;		pl_grbil_2	equ	pl_grbil_1+544

;******************************************
;	Now the Linda addresses		;
;******************************************


li_walkd_0	equ	0
li_walkd_1	equ	744/2
li_walkd_2	equ	li_walkd_1+744/2
li_walkd_3	equ	li_walkd_2+744/2
li_whip_0	equ	li_walkd_3+744/2
li_whip_1	equ	li_whip_0+1488/2
li_whip_2	equ	li_whip_1+992/2
li_punch_0	equ	li_whip_2+992/2
li_walku_0	equ	li_punch_0+992/2
li_walku_2	equ	li_walku_0+992/2
li_tkpch_0	equ	li_walku_2+992/2
li_getu_0	equ	li_tkpch_0+992/2
li_punch_1	equ	li_getu_0+736/2
li_lie_0	equ	li_punch_1+1736/2
li_fall_0	equ	li_lie_0+784/2
li_flysd_0	equ	li_fall_0+840/2


;****************************************
;		Now CartWheel		*
;****************************************


ca_walkd_0	equ	0
ca_walkd_1	equ	512
ca_walkd_2	equ	1024
ca_walkd_3	equ	1024+512
ca_punch_0	equ	ca_walkd_3+512
ca_punch_1	equ	ca_punch_0+496
ca_punch_2	equ	ca_punch_1+840
;		ca_punch_3	equ	ca_punch_2+960/2
ca_run_0	equ	ca_punch_2+480
ca_run_1	equ	ca_run_0+464
ca_run_2	equ	ca_run_1+720
ca_run_3	equ	ca_run_2+620
ca_run_4	equ	ca_run_3+744
ca_jmp_0	equ	ca_run_4+720
;		ca_uppu_0	equ	ca_jmp_0+1008/2
;		ca_uppu_1	equ	ca_uppu_0+960/2
;		ca_punch_4	equ	ca_uppu_1+1392/2
;		ca_walku_0	equ	ca_punch_4+1200/2
ca_walku_1	equ	ca_jmp_0+504		;walku_0+1024/2
;		ca_walku_2	equ	ca_walku_1+1024/2
ca_walku_3	equ	ca_walku_1+1024/2
;		ca_punch_5	equ	ca_walku_3+512

cascrn1	equ	8660

;********************************************

ca_cart_0	equ	cascrn1
ca_cart_1	equ	ca_cart_0+952
ca_cart_2	equ	ca_cart_1+1064
ca_jk_0		equ	ca_cart_2+924
ca_lie_0	equ	ca_jk_0+560
ca_flysd_0	equ	ca_lie_0+512
ca_fall_0	equ	ca_flysd_0+644
;			ca_whip_0	equ	ca_fall_0+952/2
ca_whip_1	equ	ca_fall_0+476
ca_whip_2	equ	ca_whip_1+720
ca_whip_3	equ	ca_whip_2+496
;			ca_whip_4	equ	ca_whip_3+1160/2
ca_tkpch_0	equ	ca_whip_3+580

cascrn2 equ 8660+7344


ca_clim_0	equ	cascrn2
ca_clim_1	equ	ca_clim_0+528

;********************************************
;
;		Big DAVES STUFF !
;********************************************


da_walkd_0	equ	0
da_walkd_1	equ	640
da_walkd_2	equ	640*2
da_walkd_3	equ	640*3
da_walku_1	equ	da_walkd_3+640
da_walku_2	equ	da_walku_1+640
;		da_kick_0	equ	
;		da_kick_1	equ	da_kick_0+936
da_kick_2	equ	da_walku_2+640
da_kick_3	equ	da_kick_2+1120
da_tkpch_1	equ	da_kick_3+1092

dascrn1	equ	6712		;8584

;			da_punch_0	equ	dascrn1
da_punch_1	equ	dascrn1			;	da_punch_0+760
da_punch_2	equ	da_punch_1+1440
;			da_punch_3	equ	da_punch_2+780
da_slap_0	equ	da_punch_2+780		;	da_punch_3+1404
da_slap_1	equ	da_slap_0+984
da_lie_0	equ	da_slap_1+912
da_getu_0	equ	da_lie_0+800
;			da_flysd_0	equ	da_getu_0+624
da_fall_0	equ	da_getu_0+624		;	da_flysd_0+1160
;	960	=	6500	13212

;************************************************
;						*
;		Battling Bill			*
;************************************************


bi_walk_0	equ	0
bi_walk_1	equ	960
bi_walk_2	equ	bi_walk_1+960
bi_walk_3	equ	bi_walk_2+960
;		bi_kick_0	equ	bi_walk_3+960
bi_kick_1	equ	bi_walk_3+960		;	bi_kick_0+800
bi_kick_2	equ	bi_kick_1+800
;		bi_dunno	equ	bi_kick_2+1120
;		bi_punch_0	equ	bi_dunno+868
bi_punch_1	equ	bi_kick_2+1120		;	bi_punch_0+960
bi_punch_2	equ	bi_punch_1+912
bi_getup_0	equ	bi_punch_2+1368

;************************************************

biscrn1	equ	8616

;************************************************

bi_pch_0	equ	biscrn1
;		bi_pch_1	equ	bi_pch_0+1148
;		bi_pch_2	equ	bi_pch_1+1148
bi_pch_3	equ	bi_pch_0+1148		;	bi_pch_2+1248
;		bi_pch_4	equ	bi_pch_3+1248
bi_flysd_0	equ	bi_pch_3+1248		;	bi_pch_4+1092
;		bi_fall_0	equ	bi_flysd_0+1008
bi_lie_0	equ	bi_flysd_0+1008		;	bi_fall_0+800

;************************************************

biscrn2	equ	biscrn1+4160

;************************************************

bi_dye_0	equ	biscrn2
;	bi_dye_1	equ	bi_dye_0+1584
;	bi_dye_2	equ	bi_dye_1+1584
bi_dye_3	equ	bi_dye_0+1584			;	bi_dye_2+1476
;	bi_dye_4	equ	bi_dye_3+1188
;	bi_dye_5	equ	bi_dye_4+704
bi_dye_6	equ	bi_dye_3+1188			;	bi_dye_5+448
;	bi_dye_7	equ	bi_dye_6+352


;************************************************
;	Weapon addresses
;************************************************

we_ball_0		equ	0
we_ball_1		equ	we_ball_0+256
we_hand_0		equ	we_BALL_1+256

;	LEVEL 5 animations follow ****************
we_flame_0		equ	we_hand_0+240
we_flame_1		equ	we_flame_0+204
we_flame_2		equ	we_flame_1+168	;length 156

we_stab_0		equ	we_flame_2+156
we_stab_1		equ	we_stab_0+336	;5*22 is now 6 * 28
we_stone_0		equ	we_stab_1+220
we_stone_1		equ	we_stone_0+380
we_wall_0		equ	we_stone_1+380	 ; len 576

;	************* end of animations **************

;	finish	+156
;	HAND AND BALL ARE USED IN LEVEL5 SO PUT AT THE START

we_knife_0		equ	WE_HAND_0+240
we_knife_1		equ	we_knife_0+64
we_knife_2		equ	we_knife_1+64
we_knife_3		equ	we_knife_2+40
we_knife_4		equ	we_knife_3+64
we_knife_5		equ	we_knife_4+64	;made a bit bigger
we_knife_6		equ	we_knife_5+40
we_knife_7		equ	we_knife_6+64	;MAX 64

we_crate_0		equ	we_knife_7+64
we_crate_1		equ	we_crate_0+340
we_crate_2		equ	we_crate_1+352
we_crate_3		equ	we_crate_2+420	;MAX 420

we_chain_0		equ	we_crate_3+272
we_chain_1		equ	we_chain_0+72
we_chain_2		equ	we_chain_1+160
we_chain_3		equ	we_chain_2+204	;MAX 204

we_gren_0		equ	we_CHAIN_3+168
we_gren_1		equ	we_gren_0+32
we_gren_2		equ	we_gren_1+32

we_spade_0		equ	we_gren_2+32
we_spade_1		equ	we_spade_0+96
we_spade_2		equ	we_spade_1+112
we_spade_3		equ	we_spade_2+72
we_spade_4		equ	we_spade_3+80
we_spade_5		equ	we_spade_4+128
we_spade_6		equ	we_spade_5+160

we_explo_0	equ	we_spade_6+160
we_explo_1	equ	we_explo_0+208
we_explo_2	equ	we_explo_1+224

we_log_0		equ	we_explo_2+176
we_log_3		equ	we_log_0+384

;	THATS IT FOR JUST STRAIGHT WEAPONS
;	THE NEXT ARE ANIMATIONS AND WILL NEED TO BE INDEXED FROM SOMETHING

we_bale_0		equ	WE_LOG_3+320
we_comb1_l	equ	we_bale_0+512
we_comb1_c	equ	we_comb1_l+384
we_comb2_l	equ	we_comb1_c+256
we_comb2_c	equ	we_comb2_l+456	;LEN 608
we_smoke_0	equ	we_comb2_c+608
we_smoke_1	equ	we_smoke_0+56	;132 long

;********************************************************
;							*
;		The Captains frames			*
;							*
;********************************************************

cp_walkd_0	equ	0
cp_walkd_1	equ	cp_walkd_0+384
cp_walkd_2	equ	cp_walkd_1+512
cp_walkd_3	equ	cp_walkd_2+512

cp_walku_1	equ	cp_walkd_3+512
cp_walku_3	equ	cp_walku_1+512
cp_kickb_1	equ	cp_walku_3+512
cp_punch_0	equ	cp_kickb_1+812
cp_punch_1	equ	cp_punch_0+868
cp_punch_2	equ	cp_punch_1+496
cp_kickb_0	equ	cp_punch_2+496
cp_flysd_0	equ	cp_kickb_0+480
cp_fall_0	equ	cp_flysd_0+672
cp_lie_0	equ	cp_fall_0+504
cp_holdd_0	equ	cp_lie_0+476
cp_holdd_2	equ	cp_holdd_0+480
cp_pickb_0	equ	cp_holdd_2+480

cp_scrn1	equ	9188

cp_holdu_0	equ	cp_scrn1
cp_holdu_2	equ	cp_holdu_0+496
cp_tkpch_0	equ	cp_holdu_2+496
cp_throk_1	equ	cp_tkpch_0+512
cp_jmp_0	equ	cp_throk_1+448
cp_jk_0		equ	cp_jmp_0+528
cp_getu_0	equ	cp_jk_0+616
cp_swing_0	equ	cp_getu_0+368
cp_swing_1	equ	cp_swing_0+496
cp_swing_2	equ	cp_swing_1+496
cp_swing_3	equ	cp_swing_2+600


;****************************************
;*	Mr Creosote ! ( Or Fattwat )	*
;****************************************

cr_walk_0	equ	0
cr_walk_1	equ	cr_walk_0+1104
cr_walk_2	equ	cr_walk_1+1080
cr_walk_3	equ	cr_walk_2+920
cr_slap_0	equ	cr_walk_3+900
cr_tkpch_0	equ	cr_slap_0+1344
cr_slap_1	equ	cr_tkpch_0+1128
cr_slap_2	equ	cr_slap_1+1472
cr_barge_0	equ	cr_slap_2+900

cr_scrn1	equ	9832

cr_lie_0	equ	cr_scrn1
cr_kick_0	equ	cr_lie_0+968
cr_getu_0	equ	cr_kick_0+1692
cr_fall_0	equ	cr_getu_0+640

;****************************************

;****************************************
;	And now lowry the stick man
;****************************************


ly_walk_0	equ	0
ly_walk_1	equ	ly_walk_0+740
ly_walk_2	equ	ly_walk_1+576
ly_walk_3	equ	ly_walk_2+740

ly_kick_0	equ	ly_walk_3+592
ly_somer_0	equ	ly_kick_0+888
ly_somer_1	equ	ly_somer_0+592
ly_somer_2	equ	ly_somer_1+736
ly_jk_0		equ	ly_somer_2+420	;last somersault !

ly_stick_0	equ	ly_jk_0+992
ly_stick_1	equ	ly_stick_0+912
ly_tkpch_0	equ	ly_stick_1+816
ly_stick_2	equ	ly_tkpch_0+592

ly_flysd_0	equ	ly_stick_2+924
ly_lie_0	equ	ly_flysd_0+528
ly_getu_0	equ	ly_lie_0+512

;******************************************************************
;	Perhaps not many frames for such a good looking character ?
;******************************************************************

;*****************************************************************
;	And now for the last (?) sprite
;	Its BIG BOSS WILLY !!!
;*****************************************************************


bb_walkd_0	equ	0
bb_walkd_1	equ	bb_walkd_0+792
bb_walkd_2	equ	bb_walkd_1+660
bb_walkd_3	equ	bb_walkd_2+660

bb_walku_0	equ	bb_walkd_3+792
bb_walku_2	equ	bb_walku_0+924

bb_swipe_0	equ	bb_walku_2+792
bb_flyback_0	equ	bb_swipe_0+620
bb_lie_0	equ	bb_flyback_0+992
bb_swipe_1	equ	bb_lie_0+640

bb_fire_0	equ	bb_swipe_1+896
bb_fire_1	equ	bb_fire_0+744
bb_tkpch_0	equ	bb_fire_1+768
bb_getup_0	equ	bb_tkpch_0+768

;	ends at + 672

