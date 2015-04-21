assume		ds:dseg

include		ddaddresses.asm

public		p_null_0f,lastfrm2
public		lie_r_0, club_r_0, club_l_0
public		throk_r_0, throk_l_0, hldup_dr_0, hldup_dl_0, bthrn_r_0
public		bthrn_l_0, bkneed_r_0, bkneed_l_0
public		p_null_0, p_splash_0,lie_l_0
public		comb1_l,comb1_c,comb2_l,comb2_c,grabbd_1


extrn		walk_dr_0:word, walk_dl_0:word, getup_r_0:word
extrn		getup_l_0:word

extrn		pl1_dat1:byte , capt_dat:byte , wil_dat:byte
extrn		wep_dat:byte , lin_dat:byte  , abo_dat:byte
extrn		bill_dat:byte

dseg		segment	public 'data'


		; three bytes give wep-x-offset, wep-y-offset, then
		; 000000(can be hit)(can hit)



p_null_0	dw	offset p_null_0f, offset p_null_0
		db	0, 0, 0

lie_r_0		dw	offset lie_r_0f, offset lie_r_1
		db	0, 0, 0
lie_r_1		dw	offset lie_r_0f, offset lie_r_2
		db	0, 0, 0
lie_r_2		dw	offset lie_r_0f, offset getup_r_0
		db	0, 0, 0

lie_l_0		dw	offset lie_r_0f, offset lie_l_1
		db	0, 0, 0
lie_l_1		dw	offset lie_r_0f, offset lie_l_2
		db	0, 0, 0
lie_l_2		dw	offset lie_r_0f, offset getup_l_0
		db	0, 0, 0

club_r_0	dw	offset club_r_0f, offset club_r_1
		db	-7, -5, 2
club_r_1	dw	offset club_r_1f, offset club_r_2
		db	1, -2, 2
club_r_2	dw	offset club_r_2f, offset club_r_3
		db	7, -7, 3
club_r_3	dw	offset club_r_3f, offset walk_dr_0
		db	0, -7, 2

club_l_0	dw	offset club_r_0f, offset club_l_1
		db	3, -5, 2
club_l_1	dw	offset club_r_1f, offset club_l_2
		db	-2, -2, 2
club_l_2	dw	offset club_r_2f, offset club_l_3
		db	-7, -7, 3
club_l_3	dw	offset club_r_3f, offset walk_dl_0
		db	2, -7, 2

throk_r_0	dw	offset throk_r_0f, offset throk_r_1
		db	0, 0, 2
throk_r_1	dw	offset throk_r_0f, offset throk_r_2
		db	0, 0, 2
throk_r_2	dw	offset throk_r_0f, offset walk_dr_0
		db	0, 0, 2

throk_l_0	dw	offset throk_r_0f, offset throk_l_1
		db	0, 0, 2
throk_l_1	dw	offset throk_r_0f, offset throk_l_2
		db	0, 0, 2
throk_l_2	dw	offset throk_r_0f, offset walk_dl_0
		db	0, 0, 2

hldup_dr_0	dw	offset hldup_dr_0f, offset hldup_dr_1
		db	0, 0, 2
hldup_dr_1	dw	offset hldup_dr_1f, offset hldup_dr_2
		db	0, 0, 2
hldup_dr_2	dw	offset hldup_dr_2f, offset hldup_dr_3
		db	0, 0, 2
hldup_dr_3	dw	offset hldup_dr_3f, offset hldup_dr_0
		db	0, 0, 2

hldup_dl_0	dw	offset hldup_dr_0f, offset hldup_dl_1
		db	0, 0, 2
hldup_dl_1	dw	offset hldup_dr_1f, offset hldup_dl_2
		db	0, 0, 2
hldup_dl_2	dw	offset hldup_dr_2f, offset hldup_dl_3
		db	0, 0, 2
hldup_dl_3	dw	offset hldup_dr_3f, offset hldup_dl_0
		db	0, 0, 2

hldup_ur_0	dw	offset hldup_ur_0f, offset hldup_ur_1
		db	0, 0, 2
hldup_ur_1	dw	offset hldup_ur_1f, offset hldup_ur_2
		db	0, 0, 2
hldup_ur_2	dw	offset hldup_ur_2f, offset hldup_ur_3
		db	0, 0, 2
hldup_ur_3	dw	offset hldup_ur_3f, offset hldup_ur_0
		db	0, 0, 2

hldup_ul_0	dw	offset hldup_ur_0f, offset hldup_ul_1
		db	0, 0, 2
hldup_ul_1	dw	offset hldup_ur_1f, offset hldup_ul_2
		db	0, 0, 2
hldup_ul_2	dw	offset hldup_ur_2f, offset hldup_ul_3
		db	0, 0, 2
hldup_ul_3	dw	offset hldup_ur_3f, offset hldup_ul_0
		db	0, 0, 2

bthrn_r_0	dw	offset bthrn_r_0f, offset bthrn_r_1
		db	0, 0, 0
bthrn_r_1	dw	offset bthrn_r_0f, offset bthrn_r_2
		db	0, 0, 0
bthrn_r_2	dw	offset bthrn_r_1f, offset bthrn_r_3
		db	0, 0, 0
bthrn_r_3	dw	offset bthrn_r_1f, offset bthrn_r_3
		db	0, 0, 0

bthrn_l_0	dw	offset bthrn_r_0f, offset bthrn_l_1
		db	0, 0, 0
bthrn_l_1	dw	offset bthrn_r_0f, offset bthrn_l_2
		db	0, 0, 0
bthrn_l_2	dw	offset bthrn_r_1f, offset bthrn_l_3
		db	0, 0, 0
bthrn_l_3	dw	offset bthrn_r_1f, offset bthrn_l_3
		db	0, 0, 0

bkneed_r_0	dw	offset bkneed_r_0f, offset bkneed_r_0
		db	0, 0, 0

bkneed_l_0	dw	offset bkneed_r_0f, offset bkneed_l_0
		db	0, 0, 0

p_splash_0	dw	offset p_splash_0f, offset p_splash_1
		db	0, 0, 0
p_splash_1	dw	offset p_splash_1f, offset p_splash_2
		db	0, 0, 0
p_splash_2	dw	offset p_splash_2f, offset p_null_0
		db	0, 0, 0


comb1_l		dw	offset comb1_lf ,offset comb1_l
		db	0,0,0
comb1_c		dw	offset comb1_cf ,offset comb1_c
		db	0,0,0
comb2_l		dw	offset comb2_lf ,offset comb2_l
		db	0,0,0
comb2_c		dw	offset comb2_cf ,offset comb2_c
		db	0,0,0

grabbd_1	dw	offset grab_1f ,offset grabbd_2
		db	0,0,0
grabbd_2	dw	offset grab_0f ,offset grabbd_3
		db	0,0,0
grabbd_3	dw	offset grab_0f ,offset grabbd_1
		db	0,0,0

;	this is for player being grabbed !
;	nulls all control ? Think so ?

even

p_null_0f	dw	we_hand_0, seg wep_dat	;but being ghost its really player anyway !
		db	2, 2, -100, -100	;puts it off scrn (dead clever)

grab_0f		dw	pl_grbil_1,seg pl1_dat1
		db	8,68 , -4,-68
grab_1f		dw	pl_grbil_1,seg pl1_dat1
		db	8,68 , -4,-64

comb1_lf	dw	we_comb1_l,seg wep_dat
		db	12,32,-6,-32
comb1_cf	dw	we_comb1_c,seg wep_dat
		db	8,32,-6,-32

comb2_lf	dw	we_comb2_l,seg wep_dat
		db	12,38,-6,-34
comb2_cf	dw	we_comb2_c,seg wep_dat
		db	16,38,-8,-34	;moved down by 4 pixels


lie_r_0f	dw	pl_lie_0, seg pl1_dat1
		db	14, 30, -7, -26
		dw	ca_lie_0, seg wil_dat
		db	16, 32, -6, -28
		dw	li_lie_0, seg lin_dat
		db	14, 28, -3, -22
		dw	da_lie_0, seg abo_dat
		db	20, 40, -5, -36
		dw	bb_lie_0, seg wil_dat
		db	20, 32, -10, -28
		dw	bi_lie_0, seg bill_dat
		db	18, 42, -9, -38
		dw	cp_lie_0, seg capt_dat
		db	14, 34, -7, -32
		dw	cr_lie_0,seg bill_dat
		db	22,44,-11,-40
		dw	ly_lie_0,seg capt_dat
		db	16,32,-8,-28

clam_2f		dw	pl_clam_0, seg pl1_dat1
		db	8, 64, -4, -60

throk_r_0f	dw	pl_throk_0, seg pl1_dat1
		db	8, 54, -3, -50
		db	16 dup (?)
		dw	15920, seg abo_dat
		db	12, 64, -2, -60
		dw	0,0
		db	1,1,1,1		;none for bbw
		dw	0,0
		db	1,1,1,1		;none for bill
		dw	cp_throk_1,seg capt_dat
		db	8,56,-4,-54

club_r_0f	dw	pl_swing_0, seg pl1_dat1
		db	8, 58, -4, -54
		dw	29944, seg wil_dat
		db	7, 48, -3, -44
	dw	0,0
	db	1,1,1,1	;none for linda
	dw	0,0
	db	1,1,1,1	;none for dave
	dw	0,0
	db	1,1,1,1	;none for bbw
	dw	0,0
	db	1,1,1,1	;none for bill
		dw	cp_swing_0,seg capt_dat
		db	8,62,-4,-60

club_r_1f	dw	pl_swing_1, seg pl1_dat1
		db	8, 60, -4, -56
		dw	30616, seg wil_dat
		db	7, 48, -3, -44
	dw	0,0
	db	1,1,1,1	;none for linda
	dw	0,0
	db	1,1,1,1	;none for dave
	dw	0,0
	db	1,1,1,1	;none for bbw
	dw	0,0
	db	1,1,1,1	;none for bill
		dw	cp_swing_1,seg capt_dat
		db	8,62,-4,-60

club_r_2f	dw	pl_swing_2, seg pl1_dat1
		db	10, 60, -5, -56
		dw	31288, seg wil_dat
		db	11, 48, -3, -44
	dw	0,0
	db	1,1,1,1	;none for linda
	dw	0,0
	db	1,1,1,1	;none for dave
	dw	0,0
	db	1,1,1,1	;none for bbw
	dw	0,0
	db	1,1,1,1	;none for bill
		dw	cp_swing_2,seg capt_dat
		db	10,60,-4,-58

club_r_3f	dw	pl_swing_3, seg pl1_dat1
		db	8, 62, -4, -58
		dw	32344, seg wil_dat
		db	6, 50, -3, -46
	dw	0,0
	db	1,1,1,1	;none for linda
	dw	0,0
	db	1,1,1,1	;none for dave
	dw	0,0
	db	1,1,1,1	;none for bbw
	dw	0,0
	db	1,1,1,1	;none for bill
		dw	cp_swing_3,seg capt_dat
		db	8,62,-4,-60

hldup_dr_0f	dw	pl_holdu_1, seg pl1_dat1
		db	8, 60, -4, -56
		db	16 dup (?)
		dw	36576, seg abo_dat
		db	8, 70, -4, -66
	dw	0,0
	db	1,1,1,1	;none for bbw
	dw	0,0
	db	1,1,1,1	;none for bill
		dw	cp_holdd_0,seg capt_dat
		db	8,60,-4,-58
hldup_dr_1f	dw	pl_holdu_3, seg pl1_dat1
		db	8, 60, -4, -56
		db	16 dup (?)
		dw	36576, seg abo_dat
		db	8, 70, -4, -66
	dw	0,0
	db	1,1,1,1	;none for bbw
	dw	0,0
	db	1,1,1,1	;none for bill
		dw	cp_holdd_2,seg capt_dat
		db	8,60,-4,-58

hldup_dr_2f	dw	pl_holdu_1, seg pl1_dat1
		db	8, 60, -4, -56
		db	16 dup (?)
		dw	37696, seg abo_dat
		db	7, 70, -4, -66
	dw	0,0
	db	1,1,1,1	;none for bbw
	dw	0,0
	db	1,1,1,1	;none for bill
		dw	cp_holdd_0,seg capt_dat
		db	8,60,-4,-58

hldup_dr_3f	dw	pl_holdu_3, seg pl1_dat1
		db	8, 60, -4, -56
		db	16 dup (?)
		dw	37696, seg abo_dat
		db	7, 70, -4, -66
	dw	0,0
	db	1,1,1,1	;none for bbw
	dw	0,0
	db	1,1,1,1	;none for bill
		dw	cp_holdd_2,seg capt_dat
		db	8,60,-4,-58

hldup_ur_0f	dw	pl_holdd_0, seg pl1_dat1
		db	8, 60, -4, -56
		db	16 dup (?)
		dw	38676, seg abo_dat
		db	8, 70, -4, -66
	dw	0,0
	db	1,1,1,1	;none for bbw
	dw	0,0
	db	1,1,1,1	;none for bill
		dw	cp_holdu_0,seg capt_dat
		db	8,60,-4,-58

hldup_ur_1f	dw	pl_holdd_3, seg pl1_dat1
		db	8, 60, -4, -56
		db	16 dup (?)
		dw	38676, seg abo_dat
		db	8, 70, -4, -66
	dw	0,0
	db	1,1,1,1	;none for bbw
	dw	0,0
	db	1,1,1,1	;none for bill
		dw	cp_holdu_2,seg capt_dat
		db	8,60,-4,-58

hldup_ur_2f	dw	pl_holdd_0, seg pl1_dat1
		db	8, 60, -4, -56
		db	16 dup (?)
		dw	39796, seg abo_dat
		db	8, 70, -4, -66
	dw	0,0
	db	1,1,1,1	;none for bbw
	dw	0,0
	db	1,1,1,1	;none for bill
		dw	cp_holdu_0,seg capt_dat
		db	8,60,-4,-58

hldup_ur_3f	dw	pl_holdd_3, seg pl1_dat1
		db	8, 60, -4, -56
		db	16 dup (?)
		dw	39796, seg abo_dat
		db	8, 70, -4, -66
	dw	0,0
	db	1,1,1,1	;none for bbw
	dw	0,0
	db	1,1,1,1	;none for bill
		dw	cp_holdu_2,seg capt_dat
		db	8,60,-4,-58

bthrn_r_0f	dw	pl_flybk_0, seg pl1_dat1
		db	14, 42, -7, -38
		dw	ca_flysd_0, seg wil_dat
		db	14, 46, -7, -44
		dw	0,0
		db	1,1,1,1	;none for linda
		dw	0,0
		db	1,1,1,1	;none for dave
		dw	0,0
		db	1,1,1,1	;none for bbw
		dw	0,0
		db	1,1,1,1	;none for bill
		dw	cp_flysd_0,seg capt_dat
		db	14,48,-7,-46

bthrn_r_1f	dw	pl_flysd_0, seg pl1_dat1
		db	14, 34, -7, -32
		dw	ca_fall_0, seg wil_dat
		db	14, 34, -7, -32
		dw	0,0
		db	1,1,1,1	;none for linda
		dw	0,0
		db	1,1,1,1	;none for dave
		dw	0,0
		db	1,1,1,1	;none for bbw
		dw	0,0
		db	1,1,1,1	;none for bill
		dw	cp_fall_0,seg capt_dat
		db	14,36,-7,-34

bkneed_r_0f	dw	pl_getu_0, seg pl1_dat1
		db	10, 42, -10, -40
		dw	ca_tkpch_0,seg wil_dat
		db	8, 52, -8, -50
		dw	0,0
		db	1,1,1,1	;none for linda
		dw	0,0
		db	1,1,1,1	;none for dave
		dw	0,0
		db	1,1,1,1	;none for bbw
		dw	0,0
		db	1,1,1,1	;none for bill
		dw	cp_getu_0,seg capt_dat
		db	8,46,-8,-42

p_splash_0f	dw	16080, seg wep_dat
		db	8, 24, -3, -18
p_splash_1f	dw	16464, seg wep_dat
		db	10, 40, -4, -30
p_splash_2f	dw	17264, seg wep_dat
		db	12, 46, -5, -33

lastfrm2	label	word

dseg	ends


end
