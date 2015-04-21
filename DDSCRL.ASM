  		; dummy screen handling - scrolling
		;			- loading from chr map
		; init_dummy
		; download_dummy
		; dld_main
		; dld_wrap
		; scroll_up
		; scroll_down
		; scroll left
		; scroll_right
		; buffer_row
		; display_row
		; buffer_col
		; display_col


cseg		segment	public 'code'

public		download_dummy, dld_wrap, init_dummy
public		scroll_up, scroll_down, scroll_left, scroll_right
PUBLIC		DOWNLOAD_CONT,INIT_CONT
PUBLIC		SCROLLU_CONT,SCROLLD_CONT,SCROLLL_CONT,SCROLLR_CONT
PUBLIC		INIT_DUMMY16,DOWN_LOAD16,SCROLL_U16,SCROLL_D16,SCROLL_R16
PUBLIC		SCROLL_L16

assume		cs: cseg, ds: dseg,es:dseg

include		ddeqfile

d_scrn_w	equ	144
gap		equ	24

cvert16	macro
; change from si being code to being address
;	version for tandy.

	xchg	ax,si
	xchg	al,ah
	and	ah,1
	shl	ax,1	;2
	shl	ax,1	;4
	shl	ax,1	;8
	shl	ax,1	;16
	shl	ax,1	;32
	shl	ax,1	;64
	shl	ax,1	;128
	xchg	ax,si
;mov	si,512	;is there anybody there !
	endm

cvert	macro
; this is to convert from map entry as number to give an address
; si is to be worked on
	xchg	si,ax
	xchg	al,ah
	and	ah,1
	shl	ax,1	;2
	shl	ax,1	;4
	shl	ax,1	;8
	shl	ax,1	;16
	shl	ax,1	;32
	shl	ax,1	;*64 (bytes per chite)
	add	ax,offset chr_blocks	;ha !bastard !
	xchg	ax,si
	endm

INIT_DUMMY16:
		push	ds
		push	es
		push	bx
		push	dx
		push	bp
		mov	ax,seg dseg
		mov	ds,ax
		MOV	AX,map_width
		shl	ax,1
		shl	ax,1
		add	ax,map_width
		shl	ax,1
		mov	map_width10,ax
		mov	di,32768-d_scrn_w*16-8
		MOV	CHITE_TOPLEFT,DI	;
		mov	bx, posn_in_map
		mov	bp, posn_in_chr
;jmp	suii
		sub	bx,map_width
		MOV	CX,12
next_id16:	PUSH	CX
		push	di		; save for call to display_row
		SUB	BX,2	;gosh !
		call	disp_row16	; on exit from buffer_row, bx and bp
		add	bx,map_width
		pop	di
		add	di,d_scrn_w*16	;128*16
		POP	CX
		LOOP	NEXT_ID16
suii:
		pop	bp
		pop	dx
		pop	bx
		pop	es
		pop	ds
		ret
put_chite16:
;get chite from address in SI and place at DI on screen.
	push	ds
	mov	ax,seg dseg
	mov	ds,ax	;this is wasteful and should be got rid of !
	lds	ax,chite_ptr
	cmp	di,32768-d_scrn_w*16
;jle	ch_loop
	jmp	ch_wrap
ch_loop:
	rept	16
	movsw
	movsw
	movsw
	movsw
	add	di,d_scrn_w-8
	endm
	pop	ds
	ret
ch_wrap:
	and	di,32767
	rept	15	;last movement needn't wrap 
	movsw
	and	di,32767
	movsw
	and	di,32767
	movsw
	and	di,32767
	movsw
;and	di,32767
	add	di,d_scrn_w-8
	and	di,32767
	endm
	movsw
	and	di,32767
	movsw
	and	di,32767
	movsw
	and	di,32767
	movsw
	pop	ds
	ret

init_dummy:		; sets up dummy scrn from map.
			; entry:	posn_in_map & posn_in_chr specify locn
			;		in chr map of topleft of dummy scrn
			; preserved:	none
		JMP	WORD PTR [JUMPTAB+14]
INIT_CONT:
	mov	ax,seg dseg
	mov	es,ax
		mov	di, offset dummy_scrn
		mov	bx, posn_in_map
		mov	bp, posn_in_chr
next_row_id:	push	di		; save for call to display_row
		call	buffer_row	; on exit from buffer_row, bx and bp
		cmp	bp, 64		; are set up for next pass of loop
		jl	over_id
		sub	bp, 64		; step down 1 chr in map
		add	bx, map_width
over_id:	pop	di
		call	display_row
		cmp	di, offset dummy_scrn + 9600
		jb	next_row_id
		ret

download_dummy:		; downloads dummy scrn in 3 sections - lower, wrap and
			; upper. inner loop for each is 2 pixel rows.
			; entry:	window_topleft, window_top &
			;		window_left specify posn in dummy scrn
			;		of topleft of display (ie window)
			; preserved:	bx, bp
		JMP	WORD PTR [JUMPTAB+12]
DOWNLOAD_CONT:
		mov	ax, 0b800h
		mov	es, ax		; set up es for display access
		mov	si, window_topleft
		mov	di, 810		; start of viewport on physical display
		mov	dx, 159
		sub	dx, window_top
		shr	dx, 1		; dx = # double rows in lower part
		jz	wrap_dld
lower_dld:	call	dld_main		; download lower part
wrap_dld:	test	window_top, 1		; wrap section
		jnz	odd_line
		mov	cx, 30			; wrap on even line
		rep	movsw			; first load whole line
		add	di, 2000h - 60
		call	dld_wrap
		add	di, 20 - 2000h
		jmp	end_wrap
odd_line:	call	dld_wrap
		add	di, 2000h - 60
		mov	cx, 30
		rep	movsw
		add	di, 20 - 2000h
end_wrap:	mov	dx, window_top
		shr	dx, 1		; dx = # double rows in upper part
		jz	exit_dld
		call	dld_main		; download upper part
exit_dld:	mov	ax, ds
		mov	es, ax			; restore es for dseg access
		ret
dld_main:		; downloads lower / upper part of dummy scrn.
			; entry:	si = ptr into dummy scrn
			;		di = ptr into display
			;		dx = # double rows to download
			; exit:		ptrs are stepped on; cx = dx = 0
			; preserved:	ax, bx, bp
		mov	cx, 30
		rep	movsw
		add	di, 2000h - 60
		mov	cx, 30
		rep	movsw
		add	di, 20 - 2000h
		dec	dx
		jnz	dld_main
		ret
dld_wrap:		; downloads wrap section of dummy scrn.
			; called by download_dummy and downld_row_map.
			; entry:	si = ptr into dummy scrn
			;		di = ptr into display
			; exit:		ptrs are stepped on; cx = 0
			; preserved:	ax, bx, dx, bp
		mov	cx, 60
		sub	cx, window_left
		shr	cx, 1
		jnc	over_dldw
		movsb
over_dldw:	rep	movsw
		sub	si, 9600
		mov	cx, window_left
		shr	cx, 1
		rep	movsw
		jnc	exit_dldw
		movsb
exit_dldw:	ret
scroll_up:		; scrolls dummy scrn up.
			; entry:	window & dummy posns as specified in
			;		init_dummy & download_dummy
			; preserved:	none

		JMP	WORD PTR [JUMPTAB+4]
SCROLLU_CONT:
	mov	ax,seg dseg
	mov	es,ax

		inc	scrn_top
		push	window_topleft		; save this for margin parmtr
		add	window_topleft, 240	; move window-into-dummy
		add	window_top, 4
		cmp	window_top, 160
		jl	over_su1
		sub	window_topleft, 9600
		sub	window_top, 160

over_su1:	mov	bx, posn_in_map		; load bx and bp for
		mov	ax, map_width		; margin parmtrs
		shl	ax, 1
		shl	ax, 1
		add	ax, map_width
		shl	ax, 1
		add	bx, ax
		mov	bp, posn_in_chr
		add	posn_in_chr, 16		; move dummy posn in map
		cmp	posn_in_chr, 64
		jl	over_su2
		sub	posn_in_chr, 64
 		mov	ax, map_width
		add	posn_in_map, ax

over_su2:	call	buffer_row		; load new bottom margin
		pop	di
		call	display_row
		mov	scroll_flag, 1
		ret
scroll_down:		; scrolls dummy scrn down.
			; entry:	window & dummy posns as specified in
			;		init_dummy & download_dummy
			; preserved:	none
		JMP	WORD PTR [JUMPTAB+6]
SCROLLD_CONT:
	mov	ax,seg dseg
	mov	es,ax

		dec	scrn_top
		sub	window_topleft, 240	; move window-into-dummy
		sub	window_top, 4
		jge	over_sd1
		add	window_topleft, 9600
		add	window_top, 160

over_sd1:	sub	posn_in_chr, 16		; move dummy posn in map
		jge	over_sd2
		add	posn_in_chr, 64
 		mov	ax, map_width
		sub	posn_in_map, ax

over_sd2:	mov	bx, posn_in_map		; load new top margin
		mov	bp, posn_in_chr
		call	buffer_row
		mov	di, window_topleft
		call	display_row
		mov	scroll_flag, 1
		ret
scroll_left:		; scrolls dummy scrn left.
			; entry:	window & dummy posns as specified in
			;		init_dummy & download_dummy
			; preserved:	none
		JMP	WORD PTR [JUMPTAB+8]
SCROLLL_CONT:
	mov	ax,seg dseg
	mov	es,ax

		inc	scrn_left
		push	window_topleft
		push	window_top		; save these for margin parmtrs
		inc	window_topleft		; move window-into-dummy
		inc	window_left
		cmp	window_left, 60
		jl	over_sl1
		mov	window_left, 0
		inc	window_top
		cmp	window_top, 160
		jl	over_sl1
		mov	window_topleft, offset dummy_scrn
		mov	window_top, 0
over_sl1:	mov	bx, posn_in_map		; load bx and bp for
		add	bx, 30			; margin parmtrs
		mov	bp, posn_in_chr
		inc	posn_in_chr		; move dummy posn in map
		test	posn_in_chr, 4
		jz	over_sl2
		sub	posn_in_chr, 4
		add	posn_in_map, 2

over_sl2:	call	buffer_col		; load new right margin
		pop	dx
		pop	di
		add	di, 60
		inc	dx
		cmp	dx, 160
		jl	over_sl3
		sub	di, 9600
		xor	dx, dx
over_sl3:	call	display_col
		mov	scroll_flag, 1
		ret
scroll_right:		; scrolls dummy scrn right.
			; entry:	window & dummy posns as specified in
			;		init_dummy & download_dummy
			; preserved:	none
		JMP	WORD PTR [JUMPTAB+10]
SCROLLR_CONT:
	mov	ax,seg dseg
	mov	es,ax

		dec	scrn_left
		dec	window_topleft		; move window-into-dummy
		dec	window_left
		jge	over_sr1
		mov	window_left, 59
		dec	window_top
		jge	over_sr1
		mov	window_topleft, offset dummy_scrn + 9599
		mov	window_top, 159
over_sr1:	dec	posn_in_chr		; move dummy posn in map
		test	posn_in_chr, 4
		jz	over_sr2
		add	posn_in_chr, 4
		sub	posn_in_map, 2
over_sr2:	mov	bx, posn_in_map		; load new left margin
		mov	bp, posn_in_chr
		call	buffer_col
		mov	di, window_topleft
		mov	dx, window_top
		call	display_col
		mov	scroll_flag, 1
		ret
buffer_row:		; loads row from chr map to margin buffer in 3
			; sections - a body of whole chr rows, and part-chr
			; head & tail.
			; entry:	bx = chr posn for row start
			;		bp = offset in chr
			; preserved:	none
		mov	di, offset margin_buffer
		mov	ah, 4		; loop for 4 pixel rows
		mov	dx, bp
		mov	al, dl
		and	al, 3		; al = #subchrs in tail section
		and	dl, 0fch	; dx = offset-in-chr for body section
	push	ds
	mov	si,seg dseg
	mov	es,si
	mov	si,seg chr_blocks
	mov	ds,si

next_line_br:	mov	si, es:[bx]	; head section
	cvert
		add	bx, 2
		add	si, bp
		mov	cx, 4
		sub	cl, al
		rep	movsb
		mov	cx, 14		; body section, 14 whole chr rows
next_chr_br:	mov	si, es:[bx]
	cvert
		add	bx, 2
		add	si, dx
		movsw
		movsw
		loop	next_chr_br
		mov	si, es:[bx]	; tail section
	cvert
		add	si, dx
		mov	cl, al
		rep	movsb
		sub	bx, 30		; back to 1st chr in row
		add	bp, 4		; step down 1 pixel row for both
		add	dx, 4		; offsets (no need to test for
		dec	ah		;	   bottom-of-chr)
		jnz	next_line_br
	pop	ds
		ret		
display_row:		; sends margin buffer to dummy scrn as a row.
			; entry:	di = posn in dummy scrn for row start
			; preserved:	bx, dx, bp
	mov	si,seg dummy_scrn
	mov	es,si
	mov	ds,si	;just in case
		mov	si, offset margin_buffer
		mov	ax, offset dummy_scrn + 9600
		sub	ax, di
		cmp	ax, 240
		jl	over_dr1	; wrap occurs within row
		mov	ax, 240		; no wrap - send whole buffer in 1 go
over_dr1:	mov	cx, ax
		shr	cx, 1
		rep	movsw		; send 1st part of buffer
		jnc	over_dr2
		movsb
over_dr2:	mov	cx, 240
		sub	cx, ax
		jz	exit_dr
		sub	di, 9600	; wraparound
		shr	cx, 1
		jnc	over_dr3
		movsb
over_dr3:	rep	movsw		; send 2nd part of buffer
exit_dr:	ret

buffer_col:		; loads col from chr map to margin buffer in 3
			; sections - head, body, tail.
			; entry:	bx = chr posn for col start
			;		bp = offset within chr
			; preserved:	bp

		mov	di, offset margin_buffer
		mov	dx, bp
		and	dl, 3		; dx = offset-in-chr for body section
		mov	cx, 16
		mov	ax, bp
		shr	ax, 1
		shr	ax, 1
		sub	cx, ax		; cx = #bytes in head section
	push	ds
	mov	si,seg chr_blocks
	mov	ds,si
	mov	si,seg dseg
	mov	es,si

		mov	si, es:[bx]	; head section
	cvert
		add	bx, es:map_width
		add	si, bp
		shr	cx, 1
		jz	over_bc1
		pushf
next_word_bc1:	mov	al, [si]
		mov	ah, [si+4]
		add	si, 8
		stosw
		loop	next_word_bc1
		popf
over_bc1:	jnc	over_bc2
		movsb
		add	si, 3

over_bc2:	mov	cx, 9		; body section, 9 whole chr cols

next_chr_bc:	mov	si, es:[bx]	; linear code for each whole chr col
	cvert
		add	bx, es:map_width	;thank god for es !
		add	si, dx

		mov	al, [si]
		mov	ah, [si+4]
		stosw
		mov	al, [si+8]
		mov	ah, [si+12]
		stosw
		mov	al, [si+16]
		mov	ah, [si+20]
		stosw
		mov	al, [si+24]
		mov	ah, [si+28]
		stosw
		mov	al, [si+32]
		mov	ah, [si+36]
		stosw
		mov	al, [si+40]
		mov	ah, [si+44]
		stosw
		mov	al, [si+48]
		mov	ah, [si+52]
		stosw
		mov	al, [si+56]
		mov	ah, [si+60]
		stosw
		loop	next_chr_bc
		mov	cx, bp
		shr	cx, 1
		shr	cx, 1		; cx = #bytes in tail section
		jz	exit_bc
		mov	si, es:[bx]	; tail section
	cvert
		add	si, dx
		shr	cx, 1
		jnc	over_bc3
		movsb
		add	si, 3
over_bc3:	jcxz	exit_bc
next_word_bc2:	mov	al, [si]
		mov	ah, [si+4]
		add	si, 8
		stosw
		loop	next_word_bc2

exit_bc:
	pop	ds
		ret		
display_col:		; sends margin buffer to dummy scrn as a col.
			; entry:	di = posn in dummy scrn for col start
			;		dx = #bytes to load after wrap
			; preserved:	ax, bx, dx, bp
	mov	si,seg dummy_scrn
	mov	es,si
	mov	ds,si	;these are these anyway so why bother .
		mov	si, offset margin_buffer
		mov	cx, 160
		sub	cx, dx
		shr	cx, 1
		jz	over_dc1
		pushf
next_word_dc1:	lodsw
		mov	[di], al
		mov	[di+60], ah
		add	di, 120
		loop	next_word_dc1
		popf
over_dc1:	jnc	over_dc2
		movsb
		add	di, 59
over_dc2:	mov	cx, dx
		jcxz	exit_dc
		sub	di, 9600
		shr	cx, 1
		jnc	over_dc3
		movsb
		add	di, 59
over_dc3:	jcxz	exit_dc
next_word_dc2:	lodsw
		mov	[di], al
		mov	[di+60], ah
		add	di, 120
		loop	next_word_dc2
exit_dc:	ret

SCROLL_U16:
		inc	scrn_top
	mov	ax,window_topleft
	add	ax,2*d_scrn_w	; move window-into-dummy
	sub	ax,offset dummy_scrn
	and	ax,16383	
	add	ax,offset dummy_scrn
	mov	window_topleft,ax
;add	window_top,4
;cmp	window_top,176
;jl	over_su16
;sub	window_topleft,16384
;sub	window_top,176
over_su16:	
		add	posn_in_chr,16		; move dummy posn in map
		cmp	posn_in_chr,64
		jl	over_su26
		mov	bx, posn_in_map		; load bx and bp for
		add	bx, map_width		; margin parmtrs
		mov	posn_in_map,bx
		add	bx,map_width10
		sub	posn_in_chr, 64
		MOV	DI,CHITE_TOPLEFT
		ADD	DI,d_scrn_w*16
		AND	DI,32767
		MOV	CHITE_TOPLEFT,DI
		add	di,d_scrn_w*16*11	;on bottom of screen.
		AND	DI,32767
		SUB	BX,2
		call	disp_row16
over_su26:
		mov	scroll_flag, 1
		ret
scroll_d16:
		dec	scrn_top
	mov	ax,window_topleft
	sub	ax,2*d_scrn_w	; move window-into-dummy
	sub	ax,offset dummy_scrn
	and	ax,16383	
	add	ax,offset dummy_scrn
	mov	window_topleft,ax

;sub	window_top,4
;jge	over_sd16
;add	window_topleft,16384
;add	window_top,176
over_sd16:	sub	posn_in_chr,16		; move dummy posn in map
		JGE	NONCHITE1
		ADD	POSN_IN_CHR,64	;??
		MOV	DI,CHITE_TOPLEFT
		SUB	DI,d_scrn_w*16
		AND	DI,32767
		MOV	CHITE_TOPLEFT,DI
		MOV	BX,POSN_IN_MAP
		sub	bx,map_width
		mov	posn_in_map,bx
		SUB	BX,2
		SUB	BX,MAP_WIDTH
		CALL	DISP_ROW16
NONCHITE1:	mov	scroll_flag, 1
		RET
scroll_r16:
		dec	scrn_left
	mov	ax,window_topleft
	dec	ax
	sub	ax,offset dummy_scrn
	and	ax,16383
	add	ax,offset dummy_scrn
	mov	window_topleft,ax
;dec	window_topleft		; move window-into-dummy
;dec	window_left
;jge	over_sr16
;mov	window_left,59
;dec	window_top
;jge	over_sr16
;mov	window_topleft,offset dummy_scrn+16383
		
;mov	window_top,175
over_sr16:
		mov	ax,window_topleft
		sub	ax,offset dummy_scrn
		mov	di,ax
		and	ax,3
		jnz	NO_CHITE2
		MOV	DI,CHITE_TOPLEFT
		SUB	DI,8
		AND	DI,32767
		MOV	CHITE_TOPLEFT,DI
		SUB	posn_in_map,2
		MOV	BX,posn_in_map
		sub	bx,2
		call	disp_col16
NO_CHITE2:
		mov	scroll_flag, 1
		ret
scroll_l16:
		inc	scrn_left
		push	window_topleft
	mov	ax,window_topleft
	inc	ax
	sub	ax,offset dummy_scrn
	and	ax,16383
	add	ax,offset dummy_scrn
	mov	window_topleft,ax
;inc	window_left
;cmp	window_left,60
;jl	over_sl16
;mov	window_left,0
;inc	window_top
;cmp	window_top,176	;woz 160
;jl	over_sl16
;mov	window_topleft,offset dummy_scrn
;mov	window_top,0
over_sl16:
		pop	ax
		mov	di,ax
		and	ax,3
		jnz	NO_CHITE
		MOV	DI,CHITE_TOPLEFT
		ADD	DI,8
		and	di,32767
		MOV	CHITE_TOPLEFT,DI
		ADD	DI,d_scrn_w-gap	;print at right of screen.
		and	di,32767
		MOV	BX,posn_in_map
		add	bx,30
;		sub	bx,map_width
		call	disp_col16
		add	posn_in_map,2
NO_CHITE:
		mov	scroll_flag, 1
		ret
disp_col16:
		mov	ax,seg dseg
		mov	ds,ax
		push	es
		push	bx
		les	ax,dum_ptr
		mov	cx,12	;displayed +wrap !
		SUB	BX,MAP_WIDTH
next_ch16:	mov	si,[bx]	; head section
	cvert16
		add	bx,map_width
		push	di
		push	cx
		CALL	put_chite16
		pop	cx
		POP	DI
		ADD	DI,d_scrn_w*16	;next posn for a chite.
		AND	DI,32767	;wrap !
		LOOP	next_ch16
		pop	bx
		pop	es
		ret		
disp_row16:		; puts a row of 16 chites to screen.
			;ENTRY bx = posn in map.
			; preserved:	none
			mov	ax,seg dseg
			mov	ds,ax
			push	es
			les	ax,dum_ptr
			mov	cx,17	;=15 disp +left scrl and rght scrl !
next_chite16:		mov	si,[bx]	; head section
	cvert16
			add	bx, 2
			push	di
			push	cx
	CALL	put_chite16
			pop	cx
			POP	DI
			ADD	DI,8	;next posn for a chite.
			AND	DI,32767	;wrap !
			LOOP	next_chite16
			sub	bx,32		; back to 1st chr in row
			pop	es
			ret

;the sixteen colour download mk1 
;screen size of ?
; method of wrap ?
; 
;since scrolling will stay at every 4 pixels
;the scroll will be word aligned ! 
down_load16:
	push	bx
	push	bp
	push	ds
	push	es

	MOV	AX,0B800H
	MOV	ES,AX
	mov	sp_savedum,sp
	mov	ss_savedum,ss
	cli	;stop interrupts
	MOV	AX,SEG sctab16
	mov	ss,AX
	MOV	SP,OFFSET SCTAB16
; pop off the scan line data
	mov	ax,window_topleft
	sub	ax,offset dummy_scrn
	add 	ax,ax
	LDS	SI,DUM_PTR	;get the dummy screen address full
	add	si,ax
;	add	si,8+d_scrn_w*16	;skip left scroll chite !
	AND	SI,32767	;wrap
	mov	bx,60
	mov	dx,40	;loop counter
downld_loop:
	cmp	si,32767-d_scrn_w*4
	jae	dl_wrap

	pop	di	;
	mov	cx,bx	;
rep	movsw		;
rnty1:
	add	si,gap	;past the xtra bit
	pop	di	;
	mov	cx,bx	;
rep	movsw		;
rnty2:
	add	si,gap	;past the xtra bit
	pop	di	;
	mov	cx,bx	;
rep	movsw		;
rnty3:
	add	si,gap	;past the xtra bit
	pop	di	;
	mov	cx,bx	;
rep	movsw		;
rentry:
	add	si,gap	;past the xtra bit
	and	si,32767
	dec	dx
	jne	downld_loop
	mov	ax,seg dseg
	mov	ds,ax
	mov	sp,sp_savedum
	mov	ax,ss_savedum
	mov	ss,ax
	sti

	pop	es
	pop	ds
	pop	bp
	pop	bx

	ret
dl_wrap:
	pop	di	;
	cmp	si,32767-120
	jG	dl_wl4
	mov	cx,bx	;
rep	movsw		;
	add	si,gap	;past the xtra bit
	and	si,32767

	pop	di	;
	cmp	si,32767-120
	jG	dl_wl3
	mov	cx,bx	;
rep	movsw		;
	add	si,gap	;past the xtra bit
	and	si,32767

	pop	di	;
	cmp	si,32767-120
	jG	dl_wl2
	mov	cx,bx	;
rep	movsw		;
	add	si,gap	;past the xtra bit
	and	si,32767

	pop	di	;
	cmp	si,32767-120
	jG	dl_wl1
	mov	cx,bx	;
rep	movsw		;
	jmp	rentry
dl_wl4:
;wrap download of a line !
	mov	cx,32768
	sub	cx,si
	shr	cx,1
	mov	ax,bx
	sub	ax,cx	;other count !
rep	MOVSW
	AND	SI,32767
	mov	cx,ax
rep	movsw
	JMP	RNTY1
dl_wl3:
;wrap download of a line !
	mov	cx,32768
	sub	cx,si
	shr	cx,1
	mov	ax,bx
	sub	ax,cx	;other count !
rep	MOVSW
	AND	SI,32767
	mov	cx,ax
rep	movsw

	JMP	RNTY2
dl_wl2:
	mov	cx,32768
	sub	cx,si
	shr	cx,1
	mov	ax,bx
	sub	ax,cx	;other count !
rep	MOVSW
	AND	SI,32767
	mov	cx,ax
rep	movsw

	JMP	RNTY3
dl_wl1:
	mov	cx,32768
	sub	cx,si
	shr	cx,1
	mov	ax,bx
	sub	ax,cx	;other count !
rep	MOVSW
	AND	SI,32767
	mov	cx,ax
rep	movsw

	JMP	RENTRY
	
cseg		ends


dseg		segment	para public 'data'

EXTRN		JUMPTAB:WORD,dum_ptr:dword,chite_ptr:dword
extrn		map_width:word

public		scroll_flag, window_topleft, window_top, window_left
public		chr_map, scrn_left, scrn_top
public		dummy_scrn,posn_in_map,chite_topleft
public		map_width10,posn_in_chr,mp_wdth,mp_hght

mp_wdth		dw	?	;loaded from map !
mp_hght		dw	?	;loaded from map !
chr_map		db	5212 dup (?)	;largest is level2
; has just 4 bytes spare
window_topleft	dw	offset dummy_scrn	; location of window in dummy
window_top	dw	0			; y-coord, unit is 1 pixel
window_left	dw	0			; x-coord, unit is 4 pixels
posn_in_map	dw	offset chr_map+588	; location of dummy in map
posn_in_chr	dw	0			; offset within chr
scrn_left	dw	0
scrn_top	dw	12

map_width10	dw	4000

chite_topleft	dw	0			;top left for chite stuff ! 
scroll_flag	db	1
col		db	1	;colour for border
sp_savedum	dw	0
ss_savedum	dw	0

even
sctab16	label	word
	if vers eq vga
xx=160*5+20
		rept	40
		dw	xx,xx+8192,xx+16384,xx+24576
		xx=xx+160
		endm
	endif	; no table for cga only version

dummy_scrn	db	9600 dup (?)
margin_buffer	db	480 dup (?)

dseg		ends

block_seg	segment	public	'data'
public	chr_blocks,mask_tabtan,pl2_recol,roper_recol,ghost_recol

res_mem		chr_blocks	,32768 , 30720
		;dummy screen for 16 colours
		; chr blocks for cga
		; and the stack frame in 32k versions.
res_mem		mask_tabtan	,256,1	;must be here !!!
res_mem		pl2_recol	,256,1	;must be here !!!
res_mem		roper_recol	,256,1	;must be here !!!
res_mem		ghost_recol	,256,1	;must be here !!!
res_mem		stackfrme_recol	,256,1	;must be here !!!

block_seg	ends		;stack frame at 33000b !

end
