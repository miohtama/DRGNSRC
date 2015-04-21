	assume		ds:dseg

base2		equ	10416	;bases for posns in data blocks
base3		equ	base2+5544	;screen 3 base
base4		equ	base3+5816	;last screen

base2c		equ	25592/2	;similar thing for the cartwheel sprite.

include		ddaddresses.asm		;a list of the addresses of sprites !

public		frame_0_table, walk_dr_0, walk_dl_0, getup_r_0, flybk_r_0
public		clim_r_0, clim_l_0, knee_r_3, knee_l_3, walk_dr_0f
public		walk_ul_3, clim_l_3, getup_l_0, knee_r_1, knee_l_1
public		colaps_r_0,colaps_l_0,walk_dl_1,bidie_r_8
public		knee_r_5, knee_l_5,knee_r_7, knee_l_7
public		knee_r_9, knee_l_9,knee_r_11, knee_l_11
public		knee_r_12, knee_l_12
public	shrnk_r_0,shrnk_r_1,shrnk_r_2,shrnk_r_3

extrn		hldup_dr_0:word, hldup_dl_0:word
extrn		club_r_0:word, club_l_0:word
extrn		lie_r_0:word, throk_r_0:word, throk_l_0:word
extrn		colaps_l_1f:word, colaps_l_2f:word
extrn		bthrn_r_0:word, bthrn_l_0:word, bkneed_r_0:word
extrn		bkneed_l_0:word, p_null_0:word,p_null_0f:word
extrn		lie_l_0:word

extrn		capt_dat:byte , bill_dat:byte , abo_dat:byte
extrn		pl1_dat1:byte , wil_dat:byte  , lin_dat:byte

dseg		segment	public 'data'

public	lastfrm1

frame_0_table	dw	?, ?				; dead
		dw	offset walk_dr_0, offset walk_dl_0
		dw	offset punch_r_0, offset punch_l_0
		dw	offset kick_r_0, offset kick_l_0
		dw	offset jk_r_0, offset jk_l_0
		dw	offset tk_r_0, offset tk_l_0
		dw	offset elbo_r_0, offset elbo_l_0
		dw	offset butt_r_0, offset butt_l_0
		dw	offset club_r_0, offset club_l_0
		dw	offset whip_r_0, offset whip_l_0
		dw	offset jump_r_0, offset jump_l_0
		dw	offset whip_r_0, offset whip_l_0	; throw knife
		dw	offset throk_r_0, offset throk_l_0
		dw	offset clim_r_0, offset clim_l_0
		dw	offset fall_r_0, offset fall_l_0
		dw	offset colaps_r_0, offset colaps_l_0
		dw	offset getup_r_0, offset getup_l_0
		dw	offset knee_r_0, offset knee_l_0
		dw	offset pkps_r_0, offset pkps_l_0
		dw	offset pkpb_r_0, offset pkpb_l_0
		dw	offset tkpch_r_0, offset tkpch_l_0
		dw	offset walk_dr_0, offset walk_dl_0
		dw	offset lie_r_0, offset lie_l_0
		dw	offset whip_r_0, offset whip_l_0	; throw man
		dw	offset bthrn_r_0, offset bthrn_l_0
		dw	offset flybk_r_0, offset flybk_l_0
		dw	offset flysd_r_0, offset flysd_l_0
		dw	offset hldup_dr_0, offset hldup_dl_0
		dw	offset hldup_dr_0, offset hldup_dl_0
		dw	offset bkneed_r_0, offset bkneed_l_0
		dw	offset kickb_r_0, offset kickb_l_0
		dw	offset runin_r_0, offset runin_l_0
		dw	offset bidie_r_0 , offset bidie_r_0
		dw	offset shrnk_r_0 , offset shrnk_r_0	;wepact !
		dw	offset shrnk_r_0 , offset shrnk_r_0


shrnk_r_0	dw	offset p_null_0f , offset shrnk_r_0a
		db	0,0,0
shrnk_r_0a	dw	offset shrnk_r_0f , offset shrnk_r_1
		db	0,0,0
shrnk_r_1	dw	offset shrnk_r_1f , offset shrnk_r_1a
		db	0,0,0
shrnk_r_1a	dw	offset shrnk_r_1af , offset shrnk_r_2
		db	0,0,0
shrnk_r_2	dw	offset shrnk_r_2f , offset shrnk_r_2a
		db	0,0,0
shrnk_r_2a	dw	offset shrnk_r_2af , offset shrnk_r_3
		db	0,0,0
shrnk_r_3	dw	offset shrnk_r_3f , offset shrnk_r_3a	;get moving !
		db	0,0,0
shrnk_r_3a	dw	offset shrnk_r_3af , offset walk_dr_0
		db	0,0,0

bidie_r_0	dw	offset bill_die_0f,offset bidie_r_1
		db	0,0,0
bidie_r_1	dw	offset bill_die_0f,offset bidie_r_2
		db	0,0,0
bidie_r_2	dw	offset bill_die_0f,offset bidie_r_2a
		db	0,0,0
bidie_r_2a	dw	offset bill_die_0f,offset bidie_r_2b
		db	0,0,0
bidie_r_2b	dw	offset bill_die_0f,offset bidie_r_3
		db	0,0,0
bidie_r_3	dw	offset bill_die_1f,offset bidie_r_4
		db	0,0,0
bidie_r_4	dw	offset bill_die_1f,offset bidie_r_5
		db	0,0,0
bidie_r_5	dw	offset bill_die_2f,offset bidie_r_6
		db	0,0,0
bidie_r_6	dw	offset bill_die_2f,offset bidie_r_7
		db	0,0,0
bidie_r_7	dw	offset bill_die_2f,offset bidie_r_8
		db	0,0,0
bidie_r_8	dw	offset bill_die_2f,offset bidie_r_8
		db	0,0,0	;stay at that thing


runin_r_0	dw	offset run_0f, offset runin_r_1
		db	4, -5, 2
runin_r_1	dw	offset run_1f, offset runin_r_2
		db	4, -5, 2
runin_r_2	dw	offset run_4f, offset runin_r_3
		db	4, -5, 2
runin_r_3	dw	offset run_2f, offset runin_r_4
		db	4, -5, 2
runin_r_4	dw	offset run_3f, offset runin_r_5
		db	4, -5, 2
runin_r_5	dw	offset run_1f, offset cart_r_0
		db	4, -5, 2
cart_r_0	dw	offset cart_0f,offset cart_r_1
		db	4, -5, 2
cart_r_1	dw	offset cart_1f,offset cart_r_2
		db	4, -5, 3
cart_r_2	dw	offset cart_2f,offset cart_r_3
		db	4, -5, 3
cart_r_3	dw	offset run_1f, offset cart_r_4
		db	4, -5, 3
cart_r_4	dw	offset run_2f, offset walk_dr_0
		db	4, -5, 2


runin_l_0	dw	offset run_0f, offset runin_l_1
		db	-1, -5, 2
runin_l_1	dw	offset run_1f, offset runin_l_2
		db	-1, -5, 2
runin_l_2	dw	offset run_4f, offset runin_l_3
		db	-1, -5, 2
runin_l_3	dw	offset run_2f, offset runin_l_4
		db	-1, -5, 2
runin_l_4	dw	offset run_3f, offset runin_l_5
		db	-1, -5, 2
runin_l_5	dw	offset run_1f, offset cart_l_0
		db	-1, -5, 2
cart_l_0	dw	offset cart_0f,offset cart_l_1
		db	-1, -5, 2
cart_l_1	dw	offset cart_1f,offset cart_l_2
		db	-1, -5, 3
cart_l_2	dw	offset cart_2f,offset cart_l_3
		db	-1, -5, 3	;hit detect here !
cart_l_3	dw	offset run_1f, offset cart_l_4
		db	-1, -5, 3
cart_l_4	dw	offset run_2f, offset walk_dl_0
		db	-1, -5, 2



walk_dr_0	dw	offset walk_dr_0f, offset walk_dr_1
		db	2, -8, 2
walk_dr_1	dw	offset walk_dr_1f, offset walk_dr_2
		db	3, -8, 2
walk_dr_2	dw	offset walk_dr_2f, offset walk_dr_3
		db	3, -8, 2
walk_dr_3	dw	offset walk_dr_3f, offset walk_dr_0
		db	2, -8, 2

walk_dl_0	dw	offset walk_dr_0f, offset walk_dl_1
		db	-2, -8, 2
walk_dl_1	dw	offset walk_dr_1f, offset walk_dl_2
		db	-3, -8, 2
walk_dl_2	dw	offset walk_dr_2f, offset walk_dl_3
		db	-3, -8, 2
walk_dl_3	dw	offset walk_dr_3f, offset walk_dl_0
		db	-2, -8, 2

walk_ur_0	dw	offset walk_ur_0f, offset walk_ur_1
		db	3, -8, 2
walk_ur_1	dw	offset walk_ur_1f, offset walk_ur_2
		db	3, -8, 2
walk_ur_2	dw	offset walk_ur_2f, offset walk_ur_3
		db	3, -8, 2
walk_ur_3	dw	offset walk_ur_3f, offset walk_ur_0
		db	3, -8, 2

walk_ul_0	dw	offset walk_ur_0f, offset walk_ul_1
		db	-2, -8, 2
walk_ul_1	dw	offset walk_ur_1f, offset walk_ul_2
		db	-2, -8, 2
walk_ul_2	dw	offset walk_ur_2f, offset walk_ul_3
		db	-2, -8, 2
walk_ul_3	dw	offset walk_ur_3f, offset walk_ul_0
		db	-2, -8, 2

punch_r_0	dw	offset punch_r_0f, offset punch_r_1
		db	0, 0, 2
punch_r_1	dw	offset punch_r_1f, offset punch_r_2
		db	0, 0, 3
punch_r_2	dw	offset punch_r_2f, offset punch_r_3
		db	0, 0, 2

punch_r_3	dw	offset punch_r_3f, offset punch_r_4
		db	0, 0, 2
punch_r_4	dw	offset punch_r_4f, offset punch_r_5
		db	0, 0, 3
punch_r_5	dw	offset punch_r_5f, offset walk_dr_0
		db	0, 0, 2

punch_l_0	dw	offset punch_r_0f, offset punch_l_1
		db	0, 0, 2
punch_l_1	dw	offset punch_r_1f, offset punch_l_2
		db	0, 0, 3
punch_l_2	dw	offset punch_r_2f, offset walk_dr_0
		db	0, 0, 2

punch_l_3	dw	offset punch_r_3f, offset punch_l_4
		db	0, 0, 2
punch_l_4	dw	offset punch_r_4f, offset punch_l_5
		db	0, 0, 3
punch_l_5	dw	offset punch_r_5f, offset walk_dr_0
		db	0, 0, 2

kick_r_0	dw	offset kick_r_0f, offset kick_r_1
		db	4, -5, 2
kick_r_1	dw	offset kick_r_1f, offset walk_dr_0
		db	4, -5, 3

kick_l_0	dw	offset kick_r_0f, offset kick_l_1
		db	-1, -5, 2
kick_l_1	dw	offset kick_r_1f, offset walk_dr_0
		db	-1, -5, 3

clim_r_0	dw	offset clim_r_0f, offset clim_r_1
		db	4, -9, 2
clim_r_1	dw	offset clim_r_1f, offset clim_r_2
		db	4, -5, 2
clim_r_2	dw	offset clim_r_2f, offset clim_r_3
		db	4, -5, 2
clim_r_3	dw	offset clim_r_3f, offset clim_r_0
		db	4, -8, 2

clim_l_0	dw	offset clim_r_0f, offset clim_l_1
		db	-1, -9, 2
clim_l_1	dw	offset clim_r_1f, offset clim_l_2
		db	-1, -5, 2
clim_l_2	dw	offset clim_r_2f, offset clim_l_3
		db	-1, -5, 2
clim_l_3	dw	offset clim_r_3f, offset clim_l_0
		db	-1, -8, 2

elbo_r_0	dw	offset elbo_r_0f, offset elbo_r_1
		db	0, 0, 2
elbo_r_1	dw	offset elbo_r_1f, offset elbo_r_2
		db	0, 0, 3
elbo_r_2	dw	offset elbo_r_1f, offset walk_dr_0
		db	0, 0, 3

elbo_l_0	dw	offset elbo_r_0f, offset elbo_l_1
		db	0, 0, 2
elbo_l_1	dw	offset elbo_r_1f, offset elbo_l_2
		db	0, 0, 3
elbo_l_2	dw	offset elbo_r_1f, offset walk_dr_0
		db	0, 0, 3

butt_r_0	dw	offset butt_r_0f, offset butt_r_1
		db	5, -5, 3
butt_r_1	dw	offset butt_r_0f, offset walk_dr_0
		db	5, -5, 3

butt_l_0	dw	offset butt_r_0f, offset butt_l_1
		db	-3, -5, 3
butt_l_1	dw	offset butt_r_0f, offset walk_dr_0
		db	-3, -5, 3

jump_r_0	dw	offset jump_r_0f, offset jump_r_1
		db	6, -5, 2
jump_r_1	dw	offset jump_r_1f, offset jump_r_1
		db	6, -5, 2

jump_l_0	dw	offset jump_r_0f, offset jump_l_1
		db	-2, -5, 2
jump_l_1	dw	offset jump_r_1f, offset jump_l_1
		db	-2, -5, 2

jk_r_0		dw	offset jump_r_0f, offset jk_r_1
		db	6, -8, 2	;woz -5
jk_r_1		dw	offset jk_r_0f, offset jk_r_1
		db	4, -8, 3	;woz -5

jk_l_0		dw	offset jump_r_0f, offset jk_l_1
		db	0, -8, 2	;-5
jk_l_1		dw	offset jk_r_0f, offset jk_l_1
		db	1, -8, 3	;-5

tk_r_0		dw	offset jump_r_0f, offset tk_r_1
		db	4, -5, 2
tk_r_1		dw	offset tk_r_0f, offset tk_r_2
		db	4, -5, 2
tk_r_2		dw	offset tk_r_1f, offset tk_r_2
		db	4, -5, 3

tk_l_0		dw	offset jump_r_0f, offset tk_l_1
		db	0, -5, 2
tk_l_1		dw	offset tk_r_0f, offset tk_l_2
		db	0, -5, 2
tk_l_2		dw	offset tk_r_1f, offset tk_l_2
		db	0, -5, 3

getup_r_0	dw	offset getup_r_0f, offset getup_r_1
		db	0, 0, 0
getup_r_1	dw	offset getup_r_0f, offset getup_r_2
		db	0, 0, 0
getup_r_2	dw	offset getup_r_0f, offset walk_dr_0
		db	0, 0, 0

getup_l_0	dw	offset getup_r_0f, offset getup_l_1
		db	0, 0, 0
getup_l_1	dw	offset getup_r_0f, offset getup_l_2
		db	0, 0, 0
getup_l_2	dw	offset getup_r_0f, offset walk_dr_0
		db	0, 0, 0

fall_r_0	dw	offset jump_r_1f, offset fall_r_1
		db	0, 0, 0
fall_r_1	dw	offset jump_r_1f, offset fall_r_2
		db	0, 0, 0
fall_r_2	dw	offset flysd_r_0f, offset fall_r_3
		db	0, 0, 0
fall_r_3	dw	offset fall_r_0f, offset fall_r_3
		db	0, 0, 0

fall_l_0	dw	offset jump_r_1f, offset fall_l_1
		db	0, 0, 0
fall_l_1	dw	offset jump_r_1f, offset fall_l_2
		db	0, 0, 0
fall_l_2	dw	offset flysd_r_0f, offset fall_l_3
		db	0, 0, 0
fall_l_3	dw	offset fall_r_0f, offset fall_l_3
		db	0, 0, 0

tkpch_r_0	dw	offset tkpch_r_0f, offset tkpch_r_1
		db	0, 0, 0
tkpch_r_1	dw	offset tkpch_r_0f, offset walk_dr_0
		db	0, 0, 0

tkpch_l_0	dw	offset tkpch_r_0f, offset tkpch_l_1
		db	0, 0, 0
tkpch_l_1	dw	offset tkpch_r_0f, offset walk_dr_0
		db	0, 0, 0

flybk_r_0	dw	offset flybk_r_0f, offset flybk_r_0
		db	0, 0, 0

flybk_l_0	dw	offset flybk_r_0f, offset flybk_l_0
		db	0, 0, 0

flysd_r_0	dw	offset flysd_r_0f, offset flysd_r_0
		db	0, 0, 0

flysd_l_0	dw	offset flysd_r_0f, offset flysd_l_0
		db	0, 0, 0

pkps_r_0	dw	offset getup_r_0f, offset pkps_r_1
		db	0, 0, 2
pkps_r_1	dw	offset getup_r_0f, offset walk_dr_0
		db	0, 0, 2

pkps_l_0	dw	offset getup_r_0f, offset pkps_l_1
		db	0, 0, 2
pkps_l_1	dw	offset getup_r_0f, offset walk_dr_0
		db	0, 0, 2

pkpb_r_0	dw	offset pkpb_r_0f, offset pkpb_r_1
		db	3, 0, 2
pkpb_r_1	dw	offset pkpb_r_1f, offset pkpb_r_2
		db	2, -8, 2
pkpb_r_2	dw	offset pkpb_r_2f, offset hldup_dr_0
		db	1, -11, 2

pkpb_l_0	dw	offset pkpb_r_0f, offset pkpb_l_1
		db	-3, 0, 2
pkpb_l_1	dw	offset pkpb_r_1f, offset pkpb_l_2
		db	-2, -8, 2
pkpb_l_2	dw	offset pkpb_r_2f, offset hldup_dl_0
		db	-1, -11, 2


whip_r_0	dw	offset whip_r_0f, offset whip_r_1
		db	-3, -8, 2
whip_r_1	dw	offset whip_r_1f, offset whip_r_2
		db	-3, -12, 2
whip_r_2	dw	offset whip_r_2f, offset whip_r_3
		db	7, -4, 3
whip_r_3	dw	offset whip_r_3f, offset walk_dr_0
		db	7, -4, 3	;changed to same as frame is same !

whip_l_0	dw	offset whip_r_0f, offset whip_l_1
		db	4, -6, 2
whip_l_1	dw	offset whip_r_1f, offset whip_l_2
		db	2, -12, 2
whip_l_2	dw	offset whip_r_2f, offset whip_l_3
		db	-6, -4, 3
whip_l_3	dw	offset whip_r_3f, offset walk_dl_0
		db	-6, -4, 3

colaps_r_0	dw	offset colaps_r_0f, offset colaps_r_1
		db	0, 0, 0
colaps_r_1	dw	offset colaps_r_0f, offset colaps_r_2
		db	0, 0, 0
colaps_r_2	dw	offset colaps_r_1f, offset colaps_r_3
		db	0, 0, 0
colaps_r_3	dw	offset colaps_r_1f, offset colaps_r_4
		db	0, 0, 0
colaps_r_4	dw	offset colaps_r_2f, offset colaps_r_5
		db	0, 0, 0
colaps_r_5	dw	offset colaps_r_2f, offset colaps_r_6
		db	0, 0, 0
colaps_r_6	dw	offset colaps_r_2f, offset p_null_0
		db	0, 0, 0

colaps_l_0	dw	offset colaps_r_0f, offset colaps_l_1
		db	0, 0, 0
colaps_l_1	dw	offset colaps_r_0f, offset colaps_l_2
		db	0, 0, 0
colaps_l_2	dw	offset colaps_r_1f, offset colaps_l_3
		db	0, 0, 0
colaps_l_3	dw	offset colaps_r_1f, offset colaps_l_4
		db	0, 0, 0
colaps_l_4	dw	offset colaps_r_2f, offset colaps_l_5
		db	0, 0, 0
colaps_l_5	dw	offset colaps_r_2f, offset colaps_l_6
		db	0, 0, 0
colaps_l_6	dw	offset colaps_r_2f, offset p_null_0
		db	0, 0, 0

knee_r_0	dw	offset knee_r_0f, offset knee_r_1
		db	0, 0, 0	
knee_r_1	dw	offset knee_r_1f, offset knee_r_2
		db	0, 0, 0
knee_r_2	dw	offset knee_r_2f, offset knee_r_3
		db	0, 0, 0
knee_r_3	dw	offset knee_r_2f, offset knee_r_4
		db	0, 0, 0

knee_r_4	dw	offset knee_r_0f, offset knee_r_5
		db	0, 0, 0	
knee_r_5	dw	offset knee_r_1f, offset knee_r_6
		db	0, 0, 0
knee_r_6	dw	offset knee_r_2f, offset knee_r_7
		db	0, 0, 0
knee_r_7	dw	offset knee_r_2f, offset knee_r_8
		db	0, 0, 0

knee_r_8	dw	offset knee_r_0f, offset knee_r_9
		db	0, 0, 0	
knee_r_9	dw	offset knee_r_1f, offset knee_r_10
		db	0, 0, 0
knee_r_10	dw	offset knee_r_2f, offset knee_r_11
		db	0, 0, 0
knee_r_11	dw	offset knee_r_2f, offset knee_r_12
		db	0, 0, 0
knee_r_12	dw	offset knee_r_2f, offset knee_r_0
		db	0, 0, 0

;	ive made kneeing un hittable by anyone.

knee_l_0	dw	offset knee_r_0f, offset knee_l_1
		db	0, 0, 0
knee_l_1	dw	offset knee_r_1f, offset knee_l_2
		db	0, 0, 0
knee_l_2	dw	offset knee_r_2f, offset knee_l_3
		db	0, 0, 0
knee_l_3	dw	offset knee_r_2f, offset knee_l_4
		db	0, 0, 0

knee_l_4	dw	offset knee_r_0f, offset knee_l_5
		db	0, 0, 0
knee_l_5	dw	offset knee_r_1f, offset knee_l_6
		db	0, 0, 0
knee_l_6	dw	offset knee_r_2f, offset knee_l_7
		db	0, 0, 0
knee_l_7	dw	offset knee_r_2f, offset knee_l_8
		db	0, 0, 0

knee_l_8	dw	offset knee_r_0f, offset knee_l_9
		db	0, 0, 0	
knee_l_9	dw	offset knee_r_1f, offset knee_l_10
		db	0, 0, 0
knee_l_10	dw	offset knee_r_2f, offset knee_l_11
		db	0, 0, 0
knee_l_11	dw	offset knee_r_2f, offset knee_l_12
		db	0, 0, 0
knee_l_12	dw	offset knee_r_2f, offset knee_l_0
		db	0, 0, 0

;	loads of new ones !

kickb_r_0	dw	offset kickb_r_0f, offset kickb_r_1
		db	3, -5, 2
kickb_r_1	dw	offset kickb_r_1f, offset kickb_r_2
		db	3, -5, 2
kickb_r_2	dw	offset kickb_r_1f, offset walk_dr_0
		db	3, -5, 2

kickb_l_0	dw	offset kickb_r_0f, offset kickb_l_1
		db	-1, -5, 2
kickb_l_1	dw	offset kickb_r_1f, offset kickb_l_2
		db	-1, -5, 2
kickb_l_2	dw	offset kickb_r_1f, offset walk_dr_0
		db	-1, -5, 2


shrnk_r_0f	dw	pl_walkd_0, seg pl1_dat1	;to start all !
		db	6,8,-3,-8
shrnk_r_1f	dw	pl_walkd_0, seg pl1_dat1	;3/4
		db	6,16,-3,-16
shrnk_r_1af	dw	pl_walkd_0, seg pl1_dat1	;to start all !
		db	6,24,-3,-24
shrnk_r_2f	dw	pl_walkd_0, seg pl1_dat1	;1/2
		db	6,32,-3,-32
shrnk_r_2af	dw	pl_walkd_0, seg pl1_dat1	;1/4
		db	6,40,-3,-40
shrnk_r_3f	dw	pl_walkd_0, seg pl1_dat1	;1/4
		db	6,48,-3,-48
shrnk_r_3af	dw	pl_walkd_0, seg pl1_dat1	;1/4
		db	6,56,-3,-56


walk_dr_0f	dw	pl_walkd_0, seg	pl1_dat1
		db	6, 64, -3, -60
		dw	ca_walkd_0, seg wil_dat
		db	8, 64, -3, -60
		dw	li_walkd_0, seg lin_dat
		db	6, 62, -3, -60
		dw	da_walkd_0, seg abo_dat
		db	8, 80, -4, -76
		dw	bb_walkd_0, seg wil_dat
		db	12, 66, -6, -62
		dw	bi_walk_0,seg bill_dat
		db	12,80,-6,-76
		dw	cp_walkd_0,seg capt_dat
		db	6,64,-3,-60
		dw	cr_walk_0,seg bill_dat	;mr creosote in bill data
		db	12,92,-6,-88
		dw	ly_walk_0,seg capt_dat	;lowry in bill as well !
		db	10,74,-5,-70

walk_dr_1f	dw	pl_walkd_1, seg pl1_dat1
		db	8, 64, -3, -60
		dw	ca_walkd_1, seg wil_dat
		db	8, 64, -3, -60
		dw	li_walkd_1, seg lin_dat
		db	6, 62, -3, -60
		dw	da_walkd_1, seg abo_dat
		db	8, 80, -4, -76
		dw	bb_walkd_1, seg wil_dat
		db	10, 66, -5, -62
		dw	bi_walk_1,seg bill_dat
		db	12,80,-6,-76
		dw	cp_walkd_1,seg capt_dat
		db	8,64,-4,-60
		dw	cr_walk_1,seg bill_dat	;mr creosote in bill data
		db	12,90,-6,-86
		dw	ly_walk_1,seg capt_dat	;lowry in bill as well !
		db	8,72,-4,-68


walk_dr_2f	dw	pl_walkd_2, seg pl1_dat1
		db	8, 64, -4, -60
		dw	ca_walkd_2, seg wil_dat
		db	8, 64, -3, -60
		dw	li_walkd_2, seg lin_dat
		db	6, 62, -3, -60
		dw	da_walkd_2, seg abo_dat
		db	8, 80, -4, -76
		dw	bb_walkd_2, seg wil_dat
		db	10, 66, -4, -62
		dw	bi_walk_2,seg bill_dat
		db	12,80,-6,-76
		dw	cp_walkd_2,seg capt_dat
		db	8,64,-3,-60
		dw	cr_walk_2,seg bill_dat	;mr creosote in bill data
		db	10,92,-5,-88
		dw	ly_walk_2,seg capt_dat	;lowry in bill as well !
		db	10,74,-5,-70


walk_dr_3f	dw	pl_walkd_3, seg pl1_dat1
		db	6, 64, -4, -60
		dw	ca_walkd_3, seg wil_dat
		db	8, 64, -3, -60
		dw	li_walkd_3, seg lin_dat
		db	6, 62, -3, -60
		dw	da_walkd_3, seg abo_dat
		db	8, 80, -4, -76
		dw	bb_walkd_3, seg wil_dat
		db	12, 66, -4, -62
		dw	bi_walk_3,seg bill_dat
		db	12,80,-6,-76
		dw	cp_walkd_3,seg capt_dat
		db	8,64,-3,-60
		dw	cr_walk_3,seg bill_dat	;mr creosote in bill data
		db	10,90,-5,-86
		dw	ly_walk_3,seg capt_dat	;lowry in bill as well !
		db	8,74,-4,-70

walk_ur_0f	dw	pl_walku_0, seg pl1_dat1
		db	8, 62, -4, -56
		dw	ca_walku_1, seg wil_dat
		db	8, 64, -3, -60
		dw	li_walku_0, seg lin_dat
		db	8, 62, -3, -60
		dw	da_walku_1, seg abo_dat
		db	8, 80, -4, -76
		dw	bb_walku_0,seg wil_dat
		db	14,66,-7,-62
		dw	bi_walk_0,seg bill_dat
		db	12,80,-6,-76
		dw	cp_walku_1,seg capt_dat
		db	8,64,-4,-60
		dw	cr_walk_0,seg bill_dat	;mr creosote in bill data
		db	12,92,-6,-88
		dw	ly_walk_0,seg capt_dat	;lowry in bill as well !
		db	10,74,-5,-70

walk_ur_1f	dw	pl_walku_3, seg pl1_dat1
		db	8, 62, -4, -56
		dw	ca_walku_3, seg wil_dat
		db	8, 64, -3, -60
		dw	li_walku_2, seg lin_dat
		db	8, 62, -3, -60
		dw	da_walku_2, seg abo_dat
		db	8, 80, -4, -76
		dw	bb_walku_2,seg wil_dat
		db	12,66,-6,-62
		dw	bi_walk_1,seg bill_dat
		db	12,80,-6,-76
		dw	cp_walku_3,seg capt_dat
		db	8,64,-4,-60
		dw	cr_walk_1,seg bill_dat	;mr creosote in bill data
		db	12,90,-6,-86
		dw	ly_walk_1,seg capt_dat	;lowry in bill as well !
		db	8,72,-4,-68

walk_ur_2f	dw	pl_walku_0, seg pl1_dat1
		db	8, 62, -4, -60
		dw	ca_walku_1, seg wil_dat
		db	8, 64, -3, -60
		dw	li_walku_0, seg lin_dat
		db	8, 62, -3, -60

		dw	da_walku_1, seg abo_dat
		db	8, 80, -4, -76
		dw	bb_walku_0,seg wil_dat
		db	14,66,-6,-62
		dw	bi_walk_2,seg bill_dat
		db	12,80,-6,-76
		dw	cp_walku_1,seg capt_dat
		db	8,64,-4,-60
		dw	cr_walk_2,seg bill_dat	;mr creosote in bill data
		db	10,92,-5,-88
		dw	ly_walk_2,seg capt_dat	;lowry in bill as well !
		db	10,74,-5,-70

walk_ur_3f	dw	pl_walku_3, seg pl1_dat1
		db	8, 62, -4, -60
		dw	ca_walku_3, seg wil_dat
		db	8, 64, -3, -60
		dw	li_walku_2, seg lin_dat
		db	8, 62, -3, -60

		dw	da_walku_2, seg abo_dat
		db	8, 80, -4, -76
		dw	bb_walku_2,seg wil_dat
		db	12,66,-6,-62
		dw	bi_walk_3,seg bill_dat
		db	12,80,-6,-76
		dw	cp_walku_3,seg capt_dat
		db	8,64,-4,-60
		dw	cr_walk_3,seg bill_dat	;mr creosote in bill data
		db	10,90,-6,-86
		dw	ly_walk_3,seg capt_dat	;lowry in bill as well !
		db	8,74,-4,-70

punch_r_0f	dw	pl_punch_0, seg pl1_dat1
		db	10, 64, -3, -60
		dw	ca_punch_0, seg wil_dat
		db	8, 62, -3, -58
		dw	li_punch_0, seg lin_dat
		db	8, 62, -3, -60
		dw	da_walkd_0, seg abo_dat
		db	8, 80, -4, -76
		dw	bb_fire_0,seg wil_dat
		db	12,62,-4,-58
		dw	bi_walk_1,seg bill_dat
		db	12,80,-6,-76
		dw	cp_punch_0,seg capt_dat
		db	14,62,-4,-60
		dw	cr_slap_0,seg bill_dat
		db	14,96,-8,-92
		dw	ly_stick_0,seg capt_dat
		db	12,76,-6,-72

punch_r_1f	dw	pl_punch_1, seg pl1_dat1
		db	16, 64, -3, -60
		dw	ca_punch_1, seg wil_dat
		db	14, 60, -3, -56
		dw	li_punch_1, seg lin_dat
		db	14, 62, -3, -60

		dw	da_punch_1, seg abo_dat
		db	18, 80, -6, -76
		dw	bb_fire_1,seg wil_dat
		db	12,64,-6,-60
		dw	bi_punch_1,seg bill_dat
		db	12,76,-6,-72
		dw	cp_punch_1,seg capt_dat
		db	8,62,-3,-60
		dw	cr_slap_1,seg bill_dat
		db	16,92,-5,-88
		dw	ly_stick_1,seg capt_dat
		db	12,68,-6,-64

punch_r_2f	dw	pl_punch_2 , seg pl1_dat1
		db	10, 64, -3, -60
		dw	ca_punch_2, seg wil_dat
		db	8, 60, -2, -58
		dw	li_walkd_0, seg lin_dat
		db	6, 62, -3, -60

		dw	da_punch_2, seg abo_dat
		db	10, 78, -2, -76
		dw	bb_fire_0,seg wil_dat
		db	12,62,-4,-58
		dw	bi_punch_2,seg bill_dat
		db	18,76,-6,-72
		dw	cp_punch_2,seg capt_dat
		db	8,62,-2,-60
		dw	cr_slap_2,seg bill_dat
		db	10,90,-6,-86
		dw	ly_stick_2,seg capt_dat
		db	14,66,-7,-62

punch_r_3f	dw	pl_punch_0, seg pl1_dat1
		db	10, 64, -4, -60
		dw	ca_punch_0, seg wil_dat
		db	8, 62, -3, -56
		dw	li_punch_0, seg lin_dat
		db	8, 62, -3, -60

		dw	da_walkd_0, seg abo_dat
		db	8, 80, -4, -76
		dw	bb_fire_1,seg wil_dat
		db	12,64,-6,-60
		dw	bi_walk_1,seg bill_dat
		db	12,80,-6,-76
		dw	cp_punch_0,seg capt_dat
		db	14,62,-4,-60
		dw	cr_slap_0,seg bill_dat
		db	14,96,-8,-92
		dw	ly_stick_0,seg capt_dat
		db	12,76,-6,-72

punch_r_4f	dw	pl_punch_1, seg pl1_dat1
		db	16, 64, -4, -60
		dw	ca_punch_1, seg wil_dat
		db	14, 60, -3, -56
		dw	li_punch_1, seg lin_dat
		db	14, 62, -3, -60

		dw	da_punch_1, seg abo_dat
		db	18, 80, -6, -76
		dw	bb_fire_0,seg wil_dat
		db	12,62,-4,-58
		dw	bi_punch_1,seg bill_dat
		db	12,76,-6,-72
		dw	cp_punch_1,seg capt_dat
		db	8,62,-2,-60
		dw	cr_slap_1,seg bill_dat
		db	16,92,-5,-88
		dw	ly_stick_1,seg capt_dat
		db	12,68,-6,-64

punch_r_5f	dw	pl_punch_2, seg pl1_dat1
		db	10, 64, -4, -60
		dw	ca_punch_2, seg wil_dat
		db	8, 60, -4, -58
		dw	li_walkd_0, seg lin_dat
		db	6, 62, -3, -60

		dw	da_punch_2, seg abo_dat
		db	10, 78, -2, -76
		dw	bb_fire_1,seg wil_dat
		db	12,64,-6,-60
		dw	bi_punch_2,seg bill_dat
		db	18,76,-6,-72
		dw	cp_punch_2,seg capt_dat
		db	8,62,-2,-60
		dw	cr_slap_2,seg bill_dat
		db	10,90,-6,-86
		dw	ly_stick_2,seg capt_dat
		db	14,66,-7,-62

butt_r_0f	dw	14052, seg pl1_dat1		;NOT DEFINED
		db	8, 48, -3, -44			;***********

elbo_r_0f	dw	pl_elbow_0, seg pl1_dat1
		db	6, 62, -3, -54
elbo_r_1f	dw	pl_elbow_1, seg pl1_dat1
		db	10, 64, -5, -54

clim_r_0f	dw	pl_clam_0 , seg pl1_dat1
		db	8, 64, -4, -60
		dw	ca_clim_0, seg wil_dat
		db	8, 66, -4, -44
clim_r_1f	dw	pl_clam_3 , seg pl1_dat1
		db	6, 64, -4, -60
		dw	ca_clim_1, seg wil_dat
		db	8, 66, -4, -44
clim_r_2f	dw	pl_clam_0 , seg pl1_dat1
		db	8, 64, -4, -60
		dw	ca_clim_0, seg wil_dat
		db	8, 66, -3, -44
clim_r_3f	dw	pl_clam_3 , seg pl1_dat1
		db	6, 64, -4, -60
		dw	ca_clim_1, seg wil_dat
		db	8, 66, -3, -44



jump_r_0f	dw	pl_jmp_0 , seg pl1_dat1
		db	10, 64, -4, -56
		dw	ca_jmp_0, seg wil_dat
		db	12, 42, -6, -44
		dw	0,0
		db	1,1,1,1		;no jump linda
		dw	0,0
		db	1,1,1,1		;no jump abobo
		dw	0,0
		db	1,1,1,1		;no jump big boss willy
		dw	0,0
		db	1,1,1,1		;no jumping for bill !
		dw	cp_jmp_0, seg capt_dat
		db	12, 44, -6, -40
		dw	0,0
		db	1,1,1,1		;no jumping for creosote !
		dw	ly_somer_0 , seg capt_dat
		db	8,74,-4,-70

jump_r_1f	dw	pl_jmp_1 , seg pl1_dat1
		db	14, 38, -4, -34
		dw	ca_jmp_0, seg wil_dat
		db	12, 42, -6, -44
		dw	0,0
		db	1,1,1,1		;no jump linda
		dw	0,0
		db	1,1,1,1		;no jump abobo
		dw	0,0
		db	1,1,1,1		;no jump big boss willy
		dw	0,0
		db	1,1,1,1		;no jumping for bill !
		dw	cp_jmp_0, seg capt_dat
		db	12, 44, -6, -40

jk_r_0f		dw	pl_jmp_2 , seg pl1_dat1
		db	14, 42, -4, -38
		dw	ca_jk_0, seg wil_dat
		db	14, 40, -4, -34
		dw	0,0
		db	1,1,1,1		;no jump linda
		dw	0,0
		db	1,1,1,1		;no jump abobo
		dw	0,0
		db	1,1,1,1		;no jump big boss willy
		dw	0,0
		db	1,1,1,1		;no jumping for bill !
		dw	cp_jk_0, seg capt_dat
		db	14, 44, -7, -42
		dw	0,0
		db	1,1,1,1		;no jumping for creosote
		dw	ly_jk_0 , seg capt_dat
		db	16,62,-8,-58

kick_r_0f	dw	pl_turnk_1, seg pl1_dat1		;not defined ?
		db	10, 56, -5, -52
		db	16 dup (?)
		dw	da_slap_0, seg abo_dat		;Slap for Abobos'
		db	12, 82, -10, -82
		dw	bb_swipe_0, seg wil_dat
		db	10, 62, -5, -58
		dw	bi_kick_1,seg bill_dat		;dave/bill
		db	10,80,-5,-60
		dw	0,0
		db	1,1,1,1		;no kicking for bill !
		dw	cr_kick_0,seg bill_dat
		db	18,94,-11,-90
		dw	ly_kick_0,seg capt_dat
		db	12,74,-6,-70

kick_r_1f	dw	pl_turnk_2, seg pl1_dat1		;not defined as a move
		db	16, 56, -8, -52
		db	16 dup (?)
		dw	da_slap_1, seg abo_dat
		db	12, 76, -6, -70
		dw	bb_swipe_1, seg wil_dat
		db	14, 64, -6, -60
		dw	bi_kick_2,seg bill_dat
		db	14,80,-7,-60
		dw	0,0
		db	1,1,1,1		;no kicking for bill !
		dw	cr_kick_0,seg bill_dat
		db	18,94,-11,-90
		dw	ly_kick_0,seg capt_dat
		db	12,74,-6,-70

knee_r_0f	dw	pl_punch_0, seg pl1_dat1
		db	10, 64, -3, -60
		dw	0,0
		db	1,1,1,1		;no kick back for cartwheel
		dw	0,0
		db	1,1,1,1		;no kick back for linda
		dw	0,0
		db	1,1,1,1		;no kick back for dave
		dw	0,0
		db	1,1,1,1		;no kick back for Boss
		dw	bi_pch_0,seg bill_dat
		db	14,82,-7,-78		;no kick back for bill
knee_r_1f	dw	pl_punch_1, seg pl1_dat1
		db	16, 64, -4, -60
		dw	0,0
		db	1,1,1,1		;no kick back for cartwheel
		dw	0,0
		db	1,1,1,1		;no kick back for linda
		dw	0,0
		db	1,1,1,1		;no kick back for dave
		dw	0,0
		db	1,1,1,1		;no kick back for Boss
		dw	bi_pch_0,seg bill_dat
		db	14,82,-7,-78		;no kick back for bill
knee_r_2f	dw	pl_punch_0, seg pl1_dat1
		db	10, 64, -3, -60
		dw	0,0
		db	1,1,1,1		;no kick back for cartwheel
		dw	0,0
		db	1,1,1,1		;no kick back for linda
		dw	0,0
		db	1,1,1,1		;no kick back for dave
		dw	0,0
		db	1,1,1,1		;no kick back for Boss
		dw	bi_pch_3,seg bill_dat
		db	16,78,-8,-74		;no kick back for bill

tk_r_0f		dw	pl_kickb_0, seg pl1_dat1		;replaced by kickback
		db	8, 56, -5, -52
		dw	0,0
		db	1,1,1,1		;no kick back for cartwheel
		dw	0,0
		db	1,1,1,1		;no kick back for linda
		dw	0,0
		db	1,1,1,1		;no kick back for dave
		dw	0,0
		db	1,1,1,1		;no kick back for Boss
		dw	0,0
		db	1,1,1,1		;no kick back for bill
		dw	cp_kickb_0,seg capt_dat
		db	8,60,-4,-58

tk_r_1f		dw	pl_kickb_1, seg pl1_dat1
		db	14, 54, -10, -50	;woz -8 
		dw	0,0
		db	1,1,1,1		;no kick back for cartwheel
		dw	0,0
		db	1,1,1,1		;no kick back for linda
		dw	0,0
		db	1,1,1,1		;no kick back for dave
		dw	0,0
		db	1,1,1,1		;no kick back for Boss
		dw	0,0
		db	1,1,1,1		;no kick back for bill
		dw	cp_kickb_1,seg capt_dat
		db	14,58,-7,-58

getup_r_0f	dw	pl_getu_0, seg pl1_dat1
		db	10, 42, -5, -36
		dw	ca_walkd_0, seg wil_dat
		db	8, 64, -3, -60		; CRAP IVE HAD TO USE WALK!
		dw	li_getu_0, seg lin_dat
		db	8, 46, -3, -34
		dw	da_getu_0, seg abo_dat
		db	12, 52, -4, -48
		dw	bb_getup_0, seg wil_dat
		db	14, 48, -8, -44
		dw	bi_getup_0,seg bill_dat
		db	12,48,-6,-44
		dw	cp_getu_0,seg capt_dat
		db	8,46,-4,-42
		dw	cr_getu_0,seg bill_dat
		db	10,64,-5,-60
		dw	ly_getu_0,seg capt_dat
		db	10,50,-5,-46


tkpch_r_0f	dw	pl_tkpch_0, seg pl1_dat1
		db	8, 64, -4, -60
		dw	ca_tkpch_0, seg wil_dat
		db	8, 52, -3, -46
		dw	li_tkpch_0, seg lin_dat
		db	8, 62, -3, -56
		dw	da_tkpch_1, seg abo_dat
		db	10, 64, -5, -60
		dw	bb_tkpch_0, seg wil_dat
		db	12, 64, -6, -60
		dw	bi_walk_0,seg bill_dat
		db	12,80,-7,-76
		dw	cp_tkpch_0,seg capt_dat
		db	8,64,-4,-62
		dw	cr_tkpch_0,seg bill_dat
		db	12,94,-6,-90
		dw	ly_tkpch_0,seg capt_dat
		db	8,74,-4,-70


flysd_r_0f	dw	pl_fall_0, seg pl1_dat1
		db	6, 50, -3, -44
		dw	ca_fall_0, seg wil_dat
		db	14, 34, -3, -44
		dw	8 dup (?)
		dw	bb_flyback_0, seg wil_dat
		db	16, 62, -10, -58
		dw	bi_flysd_0,seg bill_dat
		db	14,72,-8,-68
		dw	cp_fall_0,seg capt_dat
		db	14,36,-8,-34
		dw	cr_fall_0,seg bill_dat
		db	18,62,-9,-58
		dw	ly_flysd_0,seg capt_dat
		db	12,44,-6,-40

fall_r_0f	dw	pl_flysd_0, seg pl1_dat1
		db	14, 34, -3, -30
		dw	ca_flysd_0, seg wil_dat
		db	14, 46, -3, -40
		dw	8 dup (?)
		dw	bb_flyback_0, seg wil_dat
		db	16, 62, -10, -58
		dw	bi_flysd_0,seg bill_dat
		db	14,72,-7,-68
		dw	cp_flysd_0,seg capt_dat
		db	14,48,-7,-44
		dw	cr_fall_0,seg bill_dat
		db	18,62,-9,-58
		dw	ly_flysd_0,seg capt_dat
		db	12,44,-6,-40

kickb_r_0f	dw	pl_barrk_0, seg pl1_dat1
		db	10, 60, -5, -56
kickb_r_1f	dw	pl_barrk_1, seg pl1_dat1
		db	8, 56, -3, -52

colaps_r_0f	dw	pl_die_0, seg pl1_dat1
		db	12, 34, -3, -30
colaps_r_1f	dw	pl_die_1, seg pl1_dat1
		db	14, 30, -3, -16
colaps_r_2f	dw	pl_lie_0, seg pl1_dat1
		db	14, 30, -3, -20

flybk_r_0f	dw	pl_flybk_0, seg pl1_dat1
		db	14, 42, -3, -38
		dw	ca_fall_0, seg wil_dat
		db	14, 34, -3, -24
		dw	li_flysd_0, seg lin_dat
		db	14, 44, -3, -24
		dw	da_fall_0, seg abo_dat
		db	20, 48, -5, -40
		dw	bb_flyback_0, seg wil_dat
		db	16, 62, -10, -58
		dw	bi_flysd_0,seg bill_dat
		db	14,72,-8,-68
		dw	cp_fall_0,seg capt_dat
		db	14,36,-6,-34
		dw	cr_fall_0,seg bill_dat
		db	18,62,-9,-58
		dw	ly_flysd_0,seg capt_dat
		db	12,44,-6,-40

whip_r_0f	dw	pl_whip_0, seg pl1_dat1
		db	12, 60, -6, -56
		dw	ca_whip_1, seg wil_dat
		db	12, 60, -6, -54
		dw	li_whip_0, seg lin_dat
		db	12, 62, -6, -58
		dw	28112, seg abo_dat
		db	8, 64, -4, -60

whip_r_1f	dw	pl_whip_1, seg pl1_dat1
		db	8, 62, -4, -58
		dw	ca_whip_2, seg wil_dat
		db	8, 62, -3, -58
		dw	li_whip_1, seg lin_dat
		db	8, 62, -3, -58
		dw	29136, seg abo_dat
		db	8, 64, -4, -60

whip_r_2f	dw	pl_whip_2, seg pl1_dat1
		db	12, 62, -6, -58
		dw	ca_whip_3, seg wil_dat
		db	10, 58, -4, -54
		dw	li_whip_2, seg lin_dat
		db	8, 62, -2, -58
		dw	30160, seg abo_dat
		db	10, 72, -4, -68

whip_r_3f	dw	pl_whip_2, seg pl1_dat1
		db	12, 62, -6, -58
		dw	ca_whip_3, seg wil_dat
		db	10, 58, -4, -54
		dw	li_whip_2, seg lin_dat
		db	8, 62, -2, -58
		dw	30160, seg abo_dat
		db	10, 72, -4, -68

clam_0f		dw	pl_clam_0 , seg pl1_dat1
		db	8, 64, -4, -60
		dw	10980, seg wil_dat
		db	8, 48, -4, -44
clam_1f		dw	pl_clam_3 , seg pl1_dat1
		db	6, 64, -4, -60
		dw	11748, seg wil_dat
		db	7, 50, -4, -44

pkpb_r_0f	dw	pl_getu_0 , seg pl1_dat1
		db	10, 42, -5, -38
		db	16 dup (?)
		dw	40916, seg abo_dat	;NOTE DAVE DOES NOT DO THIS !
		db	10, 48, -4, -44
		dw	0,0		;non for bbw
		db	1,1,1,1
		dw	0,0		;none for bill
		db	1,1,1,1
		dw	cp_getu_0 , seg capt_dat
		db	8,46,-4,-44

pkpb_r_1f	dw	pl_prok_0 , seg pl1_dat1
		db	8, 50, -4, -46
		db	16 dup (?)
		dw	40916, seg abo_dat
		db	10, 48, -4, -44
		dw	0,0		;non for bbw
		db	1,1,1,1
		dw	0,0		;none for bill
		db	1,1,1,1
		dw	cp_pickb_0 , seg capt_dat
		db	8,60,-4,-58

pkpb_r_2f	dw	pl_holdu_1 , seg pl1_dat1
		db	8, 60, -3, -56
		db	16 dup (?)
		dw	38676, seg abo_dat
		db	8, 70, -4, -66
		dw	0,0		;non for bbw
		db	1,1,1,1
		dw	0,0		;none for bill
		db	1,1,1,1
		dw	cp_holdd_0 , seg capt_dat
		db	8,60,-4,-58

run_0f		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1
		dw	ca_run_0,seg wil_dat
		db	8,58,-4,-48
run_1f		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1
		dw	ca_run_1,seg wil_dat
		db	12,60,-6,-50
run_2f		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1
		dw	ca_run_2,seg wil_dat
		db	10,62,-6,-52
run_3f		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1
		dw	ca_run_3,seg wil_dat
		db	12,62,-6,-50
run_4f		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1
		dw	ca_run_4,seg wil_dat
		db	12,60,-6,-50

cart_0f		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1
		dw	ca_cart_0,seg wil_dat
		db	14,68,-7,-58
cart_1f		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1
		dw	ca_cart_1,seg wil_dat
		db	14,76,-7,-66
cart_2f		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1
		dw	ca_cart_2,seg wil_dat
		db	14,66,-7,-56


bill_die_0f	dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1				;player
		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1				;cartwheel
		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1				;linda
		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1				;dave
		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1				;big_boss_willy
		dw	bi_dye_0 , seg bill_dat
		db	18,88,-9,-74

bill_die_1f	dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1				;player
		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1				;cartwheel
		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1				;linda
		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1				;dave
		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1				;big_boss_willy
		dw	bi_dye_3 , seg bill_dat
		db	18,66,-9,-52

bill_die_2f	dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1				;player
		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1				;cartwheel
		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1				;linda
		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1				;dave
		dw	pl_walkd_0,seg pl1_dat1
		db	1,1,1,1				;big_boss_willy
		dw	bi_dye_6 , seg bill_dat
		db	16,22,-8,-8	;bill (all that for 1 definition)

lastfrm1	label	word


dseg	ends


end
