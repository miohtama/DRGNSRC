
cseg		segment	public 'code'

assume		cs:cseg, ds:dseg

include		ddeqfile

public		panel, bonus, end_game

extrn		entry:near, pull_person:near, put_person:near
extrn		main_loop:near, find_walkable:near

extrn		ptxt:near,head:near,pnum:near
extrn		pscore:near,strength_bar:near,big_num:near

panel:		cmp	cycle, 1
		jg	same_panel
		call	header
		call	heads
same_panel:	call	scores
		call	time
	cmp	cheat_mode,0
	je	no_creds
		call	cred
no_creds:
		call	bars
		call	lives
		call	end_game
		ret


header:		mov	si, offset one_up
		mov	dx, 2
		call	ptxt
		mov	si, offset two_up
		mov	dx, 30
		call	ptxt
		mov	si, offset pow
		mov	dx, 28+256*188
		call	ptxt
		mov	si, offset pow
		mov	dx, 2+256*188
		call	ptxt
;mov	si, offset hi_up
;mov	dx, 16
;call	ptxt
		mov	si, offset time_up
		mov	dx, 16+2*256
		call	big_num
;mov	dx, 20+0*256

	cmp	cheat_mode,0
	je	no_chtxyz
		mov	si, offset creds_up
		mov	dx, 15+188*256
		call	ptxt
no_chtxyz:	
		ret


scores:		mov	ax, cycle
		and	ax, 6
	shr	ax,1	;ha ha ha !
		cmp	ax, 1
		je	score_pl1
		cmp	ax, 2
		je	score_pl2
;cmp	ax, 3
;je	score_hi
		ret
score_pl1:	mov	ax, pl1_score
		mov	dx, 4
		mov	cx, 6
		call	pscore
		ret
score_pl2:	mov	ax, pl2_score
		mov	dx, 32
		mov	cx, 6
		call	pscore
		ret
score_hi:	mov	ax, hi_score
		mov	dx, 18
		mov	cx, 6
		call	pscore
		ret


time:		test	cycle, 3eh
		jz	new_time
		ret
new_time:	test	cycle,1
		jnz	nnnn
		dec	timer
nnnn:
	cmp	timer,0
		jl	time_over
		mov	ax, timer
		mov	cx, 2
		mov	dx, 20+2*256
		mov	si,offset dum_frg
		call	big_num		;pnum
		ret

time_over:	mov	byte ptr person_table + 5, 0
		mov	byte ptr person_table + 5 + per_list_size, 0
		mov	bl, mission
		shl	bl, 1
		xor	bh, bh
		add	bx, offset timetable2 - 2
		mov	ax, [bx]
		mov	timer, ax
		inc	timer
		ret


cred:		mov	ax, credits
		mov	cx, 1
		mov	dx, 24+188*256
		call	pnum
		ret


bars:		test	cycle, 6
		jz	new_bars
		ret
new_bars:	mov	si, offset person_table
		mov	al, [si+5]
		xor	ah, ah
		mov	di, 6
		mov	cx, 256 + 8*256
		call	strength_bar
		mov	si, offset person_table + per_list_size
		mov	al, [si+5]
		xor	ah, ah
		mov	di, 33
		mov	cx, 7*256	;light grey?
		call	strength_bar
		ret


heads:
;		mov	ax, 1
;		mov	di, 1
;		call	head
;		mov	ax, 2
;		mov	di, 28
;		call	head
		ret


lives:		test	cycle, 6
		jz	new_lives
		ret
new_lives:	mov	ax, pl1_lives
		mov	cx, 1
		mov	dx, 1+256*180
		mov	si,offset dum_frg
		call	big_num
		mov	ax, pl2_lives
		mov	cx, 1
		mov	dx, 27+256*180
		mov	si,offset dum_frg
		call	big_num
		ret


no_end_game:	ret
end_game:	cmp	byte ptr person_table + 2, being_dead
		jne	no_end_game
		cmp	byte ptr person_table + 2 + per_list_size, being_dead
		jne	no_end_game
		mov	si, offset game_over
		mov	dx, 2+10*256
		call	ptxt
		mov	si, offset game_over
		mov	dx, 30+10*256
		call	ptxt
		pause	10
		cmp	credits, 0
		jne	test_restart
		jmp	entry
test_restart:	mov	dx, 8
flashloop:	push	dx
		mov	si, offset continue
		mov	dx, 2+10*256
		call	ptxt
		mov	si, offset continue
		mov	dx, 30+10*256
		call	ptxt
		mov	cx, 0
scanloop1:	cmp	keybd+fire_j, 0
		je	pl1_rst
		cmp	keybd+fire_jk, 0
		je	pl1_rst
		cmp	keybd+fire_k, 0
		je	pl2_rst
		loop	scanloop1
		mov	si, offset spaces
		mov	dx, 2+10*256
		call	ptxt
		mov	si, offset spaces
		mov	dx, 30+10*256
		call	ptxt
		mov	cx, 30000
scanloop2:	cmp	keybd+fire_j, 0
		je	pl1_rst
		cmp	keybd+fire_jk, 0
		je	pl1_rst
		cmp	keybd+fire_k, 0
		je	pl2_rst
		loop	scanloop2
		pop	dx
		dec	dx
		jnz	flashloop
		jmp	entry

pl1_rst:	mov	pl1_lives, 2
		mov	pl1_score, 0
		mov	si, offset person_table
		jmp	player_rst
pl2_rst:	mov	pl2_lives, 2
		mov	pl2_score, 0
		mov	si, offset person_table + per_list_size
player_rst:
	mov	ax,seg dseg
	mov	ds,ax
;mov	es,ax	;is this bug ever gunna go ????
		push	si
		call	pull_person
		mov	strength, 20
		mov	action, getting_up
		mov	frame_no, -1
		call	find_walkable
		pop	si
		call	put_person
		dec	credits
		mov	si, offset spaces
		mov	dx, 2+10*256
		call	ptxt
		mov	si, offset spaces
		mov	dx, 30+10*256
		call	ptxt
		mov	bl, mission
		shl	bl, 1
		xor	bh, bh
		add	bx, offset timetable2 - 2
		mov	ax, [bx]
		mov	timer, ax
		pop	ax
		pop	ax
		pop	ax
		jmp	main_loop

bonus:
	mov	bx,offset bonii
	mov	cl,mission
	xor	ch,ch
	shl	cx,1	;cx = mission*2 !
	add	bx,cx	;index into table
	mov	ax,[bx]
	mov	bonus_sc,ax	;save for later !

	cmp	mission,5
	je	miss5_only
	
		mov	si, offset bonus_pt
		mov	dx, 12+80*256
		call	ptxt

	mov	ax,bonus_sc
		mov	cx, 3
		mov	dx, 24+80*256
	xor	bscrn,200h
		call	pnum
	xor	bscrn,200h
		mov	si, offset missn_message
		mov	dx, 8+96*256
		call	ptxt

		mov	al, mission
		cbw
		mov	cx, 1
		mov	dx, 30+96*256
	xor	bscrn,200h
		call	pnum
	xor	bscrn,200h
from_miss5:
	mov	ax,bonus_sc
		cmp	byte ptr person_table + 2, being_dead
		je	no_pl1_bonus
		add	pl1_score, ax	;300
no_pl1_bonus:	cmp	byte ptr person_table + 2 + per_list_size, being_dead
		je	no_pl2_bonus
		add	pl2_score, ax	;300
no_pl2_bonus:	ret

miss5_only:
	mov	si, offset miss5_message
	mov	dx, 8+96*256
	call	ptxt
	jmp	from_miss5

cseg		ends


dseg		segment	public 'data'

public		pl1_score, pl2_score, pl1_lives, pl2_lives, hi_score
public		credits, timer

extrn		identity_table:byte, player2_table:byte, cycle:word
extrn		person_table:byte, walk_dr_0f:word, walk_dl_0f:word
extrn		keybd:byte, strength:byte, action:byte, frame_no:word
extrn		mission:byte,cheat_mode:word
extrn		number:byte

ss_s		dw	?
sp_s		dw	?

pl1_score	dw	0
pl2_score	dw	0
pl1_lives	dw	2
pl2_lives	dw	2
credits		dw	5
timer		dw	70
hi_score	dw	2000 ; x 10
dum_frg	db	0
one_up		db	"1P", 0
two_up		db	"2P", 0
hi_up		db	"HI", 0
time_up		db	255,0		;"TIME", 0
creds_up	db	"CREDITS", 0
game_over	db	"GAME OVER", 0
continue	db	"CONTINUE ", 0
spaces		db	"         ", 0
pow		db	"POW",0
bonus_pt	db	"BONUS POINT 3000", 0	;end zero needed!
missn_message	db	"GET READY FOR MISSION ", 0
miss5_message	db	"INVADE THE ENEMY'S BASE ",0
bonus_sc	dw	0
bonii		dw	0,0,300,500,800,0,0	;no bonuses for last two levels
; er its 1-5 and mission is 1 bigger than the one just finished!
timetable2	dw	70, 70, 90, 50, 90

extrn		bscrn:word

dseg		ends

end
