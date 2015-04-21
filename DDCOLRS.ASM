cseg		segment public 'code'

assume		cs:cseg, ds:dseg



public		setup_colrs



setup_colrs:
		mov	bx, offset black

		mov	di, offset identity_table
		mov	black, 0
		mov	cyan, 1
		mov	red, 2
		mov	white, 3
		call	gen_colr_tab

		mov	di, offset player2_table
		mov	black, 0
		mov	cyan, 2
		mov	red, 2
		mov	white, 3
		call	gen_colr_tab

;	mov	di, offset will_A_table
;	mov	black, 0
;	mov	cyan, 0
;	mov	red, 3
;	mov	white, 2
;	call	gen_colr_tab
;
;	mov	di, offset will_B_table
;	mov	black, 0
;	mov	cyan, 3
;	mov	red, 0
;	mov	white, 2
;	call	gen_colr_tab
;
;	mov	di, offset will_C_table
;	mov	black, 0
;	mov	cyan, 1
;	mov	red, 0
;	mov	white, 2
;	call	gen_colr_tab
;
;	mov	di, offset abobo_B_table
;	mov	black, 0
;	mov	cyan, 2
;	mov	red, 0
;	mov	white, 1
;	call	gen_colr_tab
;
;	mov	di, offset roper_table
;	mov	black, 0
;	mov	cyan, 3
;	mov	red, 1
;	mov	white, 2
;	call	gen_colr_tab

		ret



gen_colr_tab:	xor	dl, dl
gen_loop:	mov	ah, dl
		call	replace
		call	replace
		call	replace
		call	replace
		mov	[di], ah
		inc	di
		inc	dl
		jnz	gen_loop
		ret


replace:	mov	al, ah
		and	ax, 0fc03h
		xlat
		or	ah, al
		rol	ah, 1
		rol	ah, 1
		ret



cseg		ends




dseg		segment	public 'data'

public		identity_table, player2_table, colrmap_table

; bit bloody silly really I've only got a colour change set for player2 !
; cant even do player2 yet so even sillier !
colrmap_table	dw	offset identity_table	; player1
		dw	offset identity_table	; williams
		dw	offset identity_table	; abobo
		dw	offset identity_table	; linda
		dw	offset identity_table	; big_boss_willy
		dw	offset player2_table	; player2
		dw	offset identity_table	;will_A_table	; williams_A
		dw	offset identity_table	;will_B_table	; williams_B
		dw	offset identity_table	;will_C_table	; williams_C
		dw	offset identity_table	;will_B_table	; abobo_A
		dw	offset identity_table	;abobo_B_table	; abobo_B
		dw	offset identity_table	;roper_table	; roper
		dw	offset identity_table	;bill
		dw	offset identity_table	;lowry
		dw	offset identity_table	; captain
		dw	offset identity_table	;a
		dw	offset identity_table	;b
		dw	offset identity_table	;c ?
		dw	offset identity_table	;wepons
		dw	offset identity_table	;abobo 
		dw	offset identity_table	;
		dw	offset identity_table	;

identity_table	db	256 dup (?)
player2_table	db	256 dup (?)

;will_A_table	db	256 dup (?)
;will_B_table	db	256 dup (?)
;will_C_table	db	256 dup (?)
;abobo_B_table	db	256 dup (?)
;roper_table	db	256 dup (?)


black		db	?
cyan		db	?
red		db	?
white		db	?



dseg		ends




end
