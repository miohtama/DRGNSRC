
cseg		segment	public 'code'

public		return, newivector, restore_int
public		load, save, create, open, writeF, error, READF, close
public		INIT_STICKS,load_error

extrn   delzw:near,main_loop:near,write_text:near

PUBLIC	TEST_SND
;PUBLIC	ANJOY_INIT, ANJOY_READ, ANJOY_INIT_2, ANJOY_READ_2
public	hit_snd, thud_snd, linda_snd, will_snd, colaps_snd, whip_snd
public	thumb_snd, splash_snd, splat_snd, bounce_snd, knife_snd, gun_snd

;	when a whatsit error occurs erm
;	try first error_fl and returning ?

assume		cs:cseg, ds:dseg

include		ddeqfile

load_error:
;	ax denotes disk I should have at this point
;	0-3 for different ones
;	I think ?
;	0 - main disc/cga grafix
;	1 - main disc/cga grafix
;	2 - Ega graphics disc 
;	3 - Vga graphics disc 

	pushall
;w_f_n_sp:
;cmp	byte ptr [keybd+39h],0
;je	w_f_n_sp

;border	1

	shl	ax,1
	mov	si,ax
	mov	si,[si+offset disc_names]
	mov	dx,24*256
	call	write_text
w_f_sp:
	cmp	byte ptr [keybd+39h],0
	jne	w_f_sp
	mov	si,offset null_str
	mov	dx,24*256	;bottom of screen.
	call	write_text

	popall
;	note after this another attempt is made to load the file
	ret

return:		
	mov	ax,seg dseg
	mov	ds,ax
	call	restore_int
	IN	AL, 61H		; this kills the sound effects
	AND	AL, 0FCH	
	OUT	61H, AL		;so buzzes ! dont cont after ESC
	MOV	SND_PTR, 0	
		mov	ax, 2
		int	16
l_shift_key	equ	2ah
not_pressed:
		mov	ax, 4c00h
		int	33

newivector:	cli
		push	ds
		push	es
		mov	ax, dseg
		mov	ds, ax
		xor	ax, ax
		mov	es, ax

		mov	ax, es: [36]
		mov	ivect9_ip, ax
		mov	ax, es: [38]
		mov	ivect9_cs, ax

;mov	ax, es: [36]
;mov	ivect_ip, ax
;mov	ax, es: [38]	;take over critical
;mov	ivect_cs, ax	;error handler.

		mov	ax, es: [8*4]
		mov	ivect28_ip, ax
		mov	es:[0fh*4],ax

		mov	ax, es: [8*4+2]
		mov	ivect28_cs, ax
		mov	es:[0fh*4+2],ax

	call	fast_i

		mov	word ptr es: [36], offset scan
		mov	es: [38], cs
		mov	word ptr es: [8*4], offset timer_int
		mov	es: [8*4+2], cs

		MOV	FIREJ,1
		MOV	FIREK,1
	mov	dx,201h	; Iam sure this is wrong !
	out	dx,al	;leave for the moment BUT !
	sti
		pop	es
		pop	ds
		ret
fast_i:
	mov	byte ptr in_slow,0
	mov	al,36h
	out     [43h],al
	mov     al,0
	out     [40h],al
	mov     al,16   ;for 4 times the ints 74hz
	out     [40h],al        ;
	ret

slow_i:
	mov	byte ptr in_slow,1
	mov	al,36h
	out     [43h],al
	xor     al,al
	out     [40h],al
	out     [40h],al        ;timer back to default 54ms
	ret

INIT_STICKS:
		CLI
		MOV	FIREJ,1
		MOV	FIREK,1
		call	anjoy_init
		call	anjoy_init_2
		STI
	RET

restore_int:	cli
		push	ds
		push	es
		mov	ax, dseg
		mov	ds, ax
		xor	ax, ax
		mov	es, ax
		mov	ax, ivect9_ip
		mov	es: [36], ax
		mov	ax, ivect9_cs
		mov	es: [38], ax

		call	slow_i

		mov	ax, ivect28_ip		;timer int
		mov	es: [8*4], ax		;
		mov	ax, ivect28_cs		;
		mov	es: [8*4+2], ax	;
		pop	es
		pop	ds
		sti
		ret




no_call:
		mov    al,20h  ;god knows but its in the pink book
		out    20h,al  ;
	STI
		pop	ds
		pop	ax

no_call2:	iret

timer_int:
;put timer interrupt code here (ie Second count and sfx)
		push	ax
		push	ds
		MOV	AX,DSEG		; SEG FRAME_COUNT
		MOV	DS,AX
		INC	FRAME_COUNT	; always count dont care speed
		cmp	byte ptr in_slow,1
		jp_e	slower
		push	si

		MOV	SI, SND_PTR
		OR	SI, SI
		JZ	END_SOUND
SOUND:
		LODSW
		OR	AX, AX
		JZ	STOP_SOUND
		MOV	SND_PTR, SI
		OUT	42H, AL
		MOV	AL, AH
		OUT	42H, AL
		JMP	END_SOUND
STOP_SOUND:
		IN	AL, 61H
		AND	AL, 0FCH
		OUT	61H, AL
		MOV	SND_PTR, 0
END_SOUND:
		POP	SI
		mov	ax,[intcount]
		inc	ax
		mov	[intcount],ax
		test	ax,3	;low bits
		jnz	no_call
	cmp	nojoyflag,-1
	je	soddestick
	push	dx
	push	bx
	push	cx
	mov	fudlr,31
	mov	fudlr_2,31

	MOV	DX,201H
	IN	AL,DX	;READ THE BUTTONS (this is silly)
	NOT	AL
	CMP	AJF1,0
	JNE	ONAL
	TEST	AL,30H	;HAVE I PRESSED A BUTTON ON JOYSTICK ? 
	JZ	ONAL	;WHEN STICK NOT ON ?
	CALL	ANJOY_INIT
	CMP	AJF2,0
	JE	ONAL2
	CALL	ANJOY_INIT_2
;RE-READ DATA FOR OTHER STICK 
	JMP	ONAL2
ONAL:	CMP	AJF2,0
	JNE	ONAL2
	TEST	AL,0C0H	;HAVE I PRESSED A BUTTON ON JOYSTICK ? 
	JZ	ONAL2	;WHEN STICK NOT ON ?
	CALL	ANJOY_INIT_2
	CMP	AJF1,0
	JE	ONAL2
	CALL	ANJOY_INIT	;RE-READ DATA FOR OTHER STICK 
ONAL2:	call	anjoy_read
	call	anjoy_read_2
shag:
	pop	cx
	pop	bx
	pop	dx
soddestick:
		sti	;re-interruptable !
slower: 	pop	ds
		pop	ax
		int	0fh	; bless my soul ! there is an easier way !
		iret


;Jake Sound Routines for setting up different Sound Effects !

hit_snd:	mov	snd_ptr, offset snd_tab_2
		jmp	start_sound

thud_snd:	mov	snd_ptr, offset snd_tab_3
		jmp	start_sound

linda_snd:	mov	snd_ptr, offset snd_tab_4
		jmp	start_sound

will_snd:	mov	snd_ptr, offset snd_tab_5
		jmp	start_sound

colaps_snd:	mov	snd_ptr, offset snd_tab_6
		jmp	start_sound

thumb_snd:	mov	snd_ptr, offset snd_tab_7
		jmp	start_sound

whip_snd:	mov	snd_ptr, offset snd_tab_8
		jmp	start_sound

splash_snd:	mov	snd_ptr, offset snd_tab_9
		jmp	start_sound

splat_snd:	mov	snd_ptr, offset snd_tab_10
		jmp	start_sound

bounce_snd:	mov	snd_ptr, offset snd_tab_11
		jmp	start_sound

knife_snd:	mov	snd_ptr, offset snd_tab_12
		jmp	start_sound

gun_snd:	mov	snd_ptr, offset snd_tab_13
		jmp	start_sound

TEST_SND:
		MOV	SND_PTR, OFFSET SND_TAB_1
START_SOUND:
		CMP	SND_FLAG, 0
		JE	NO_SOUND

		MOV	AL,0B6H			; init spkr timer
		OUT	43H, AL
		IN	AL, 61H
		OR	AL, 3
		OUT	61H, AL
		RET
NO_SOUND:
		MOV	SND_PTR, 0
		RET


try_cont:
	cmp	byte ptr [keybd+bx],0	;pressed
	jne	no_go
	sti

	jmp	main_loop	;oh god ( what about the bloody stack !)
; and itll get called twice !
no_go:
	jmp	try_back	;ie dont on release

scan:
		push	ax
		push	bx
		push	ds
		mov	ax, dseg
		mov	ds, ax

		in	al, 60h
		mov	bl, al
		in	al, 61h
		or	al, 80h
		out	61h, al
		and	al, 7fh
		out	61h, al

		xor	al, al
		mov	bh, al
		shl	bl, 1
		rcl	al, 1
		shr	bl, 1
		mov	[keybd + bx], al

		mov	al, 61h
		out	20h, al
	cmp	bx,1	;pressing the escape key !
	je	escape

;cmp	bx,3	;f2 key ? 
;jne	no_ch_time
;mov	timer,11
;no_ch_time:

	push	si
	mov	si,cht_ptr
	cmp	bl,[si] ;does it equal this one ?
	jne	no_cheat_mde	;no so leave ptr here
	inc	cht_ptr
	cmp	si,offset endtxt
	jne	no_cheat_mde
	mov	cheat_mode,-1	;turn it to the opposite
	mov	cht_ptr,offset cht_text
no_cheat_mde:
	pop	si

	cmp	bx,42h	;f8 key
	jne	no_reset
	mov	cht_ptr,offset cht_text
no_reset:
	cmp	bx,43h	;f9 key
	jne	no_reset_cht
	mov	cheat_mode,0	;put to no cheat
no_reset_cht:

try_back:
		CMP	BX,FIRE_K
		JNE	NF1
		MOV	FIREK,AL	;STORE THE REAL FIRE KEY
NF1:
		CMP	BX,FIRE_J
		JNE	NF2	
		MOV	FIREJ,AL	;STORE THE REAL FIRE KEY
NF2:

		pop	ds
		pop	bx
		pop	ax
		sti
		iret

escape:
	sti	;
	jmp	return
	


loadit:
	mov	errfl,0	;zero the error variable
	push	nojoyflag
	mov	nojoyflag,-1	;kill sticks ?
		call	open
;border	8
		call	READF
;border	9
		call	close
	pop	nojoyflag
		ret
save:
	mov	errfl,0	;zero the error variable
		call	create
		call	writeF
		call	close
		ret
create:
		mov	dx, file_name
		xor	cx, cx
		mov	al, 2
		mov	ah, 3ch			; function 3c - create file
		int	33
		jc	error
		mov	handle, ax
		ret
;	    open a file for READFing

open:
		mov     ah,13
		int     21h
		mov     dx, file_name
		xor	al, al
		mov	ah, 3dh			; function 3d - open file
		int	33
		jc	error
		mov	handle, ax
		ret
; 	     write to file

writeF:
		mov	ax, start_seg
		mov	bx, handle
		mov	cx, len
		mov	dx, start_offset
		push	ds
		mov	ds, ax
		mov	ah, 40h			; function 40 - write file
		int	33
		pop	ds
		jc	error
		ret

;	flag error
flg_error:		;assumes dseg is set correct at this point.
	mov	errfl,-1
	ret	;returns as before!

; print up the error message

error:		
;	grief what state is the stack in at this point !!!
;	restore what we can !!!
;	???????????????

;	let other rout sort this out.
;	this is going to be problematical
;	hmmm.
	jmp	word ptr [error_rout]


div_err:
		call	restore_int
		mov	ax,2
		int	16	;change mode before exit.
		int	0	;exit with divide overflow (v.tacky or what)
		mov	ax, 4c00h
		int	33

;	   read a file

READF:
		mov     ah,13
		int     21h
	jc	error	;will it help
		mov     ax, start_seg
		mov	bx, handle
		mov	cx, 0ffffh
		mov	dx, start_offset
		push	ds
		mov	ds, ax
		mov	ah, 3fh			; function 3f - read file
		int	33
		pop	ds
		jc	error
		ret

close:
		mov	bx, handle
		mov	ah, 3eh			; function 3e - close file
		int	33
		jc	error
		ret

load:
	pushall
	call    slow_i
;de_vice:
	push	es
	push	ds

	push	start_seg
	push	start_offset
	mov	start_offset,0
	mov     ax,buff_seg
	mov     start_seg,ax
;border	15
	call    loadit  ;loads into normal space ?

;border	12

	pop	di	;start_offset
	pop	es	;start_seg
	cmp	errfl,0
	jne	error_on_load
	xor	si,si
	mov	ax,start_seg
	mov	ds,ax
	call    delzw   ;decompress from DS:SI to ES:DI
error_on_load:
	pop	ds
	pop	es
	sub	cx,di	;well ya never know !
	mov	len,cx
	call    fast_i
	popall	;this is just so fucking rediculous
	ret

;ASSUME NO STICK BUT WHEN A BUTTON IS PRESSED INITIATE THE JOYSTICK
;The Tandy joystick routines from Jake

no_stcks:
	ret

ANJOY_START:
	cmp	nojoyflag,-1
	jp_e	no_stcks
;CLI			; NOTE !!!
		MOV	DX, 201H
		OUT	DX, AL
		NOP
		NOP
		MOV	BX, 0
		MOV	CX, 0
AJS_ALP:
		IN	AL, DX
		INC	BX
		INC	CX
		TEST	AL, 1
		JZ	AJS_YLP_A
		TEST	AL, 2
		JZ	AJS_XLP_A
		CMP	CX, 1000
		JL	AJS_ALP
		JMP	AJS_TO		; for time-out
AJS_XLP:
		; Y done - just count x
		IN	AL, DX
		INC	BX
		NOP
		NOP
		NOP			; adjust timing
		NOP
		NOP
		CMP	BX, 1000	;0	; for time-out
		JGE	AJS_TO
AJS_XLP_A:
		TEST	AL, 1
		JNZ	AJS_XLP
;STI
		RET
AJS_YLP:
		; X done - just count y
		IN	AL, DX
		INC	CX
		NOP
		NOP
		NOP
		NOP
		NOP
		CMP	CX, 1000	;0
		JGE	AJS_TO
AJS_YLP_A:
		TEST	AL, 2
		JNZ	AJS_YLP
;STI
		RET
AJS_TO:
; time-out	SHOULDNT IT MAKE THE JOY FLAG FALSE ?
		MOV	AJF1, 0		; F
;STI
		RET

		
ANJOY_INIT:
	cmp	nojoyflag,-1
	jp_e	no_stcks
		MOV	AJF1,1
		CALL	ANJOY_START
		CMP	AJF1, 0
		JE	E_AJI
		MOV	AJXO1, BX	; x-origin
		MOV	AJXN1, BX
		SHR	BX, 1		; calc x-nullzone
		SUB	AJXN1, BX
		MOV	AJYO1, CX	; Y-origin
		MOV	AJYN1, CX
		SHR	CX, 1
		SUB	AJYN1, CX	; Y-nullzone
E_AJI:
		RET


ANJOY_READ:
	cmp	nojoyflag,-1
	jp_e	no_stcks
	MOV	FUDLR_2,31
		CMP	AJF1, 0
		JE	E_ANJR1
		CALL	ANJOY_START
		CMP	AJF1, 0
		JE	E_ANJR1
	MOV	DL,FIREJ
	MOV	KEYBD+FIRE_J,DL
		MOV	DL,0
		NOT	AL
		TEST	AL,030H	; both buttons
		JZ	N_ANJF1
	MOV	BYTE PTR KEYBD+FIRE_J,0	;changed
N_ANJF1:
		SUB	BX, AJXO1
		MOV	AX, AJXN1
		CMP	BX, AX
		JL	N_R1
		OR	DL, 1		; R bit
N_R1:
		NEG	AX
		CMP	BX, AX
		JG	N_L1
		OR	DL, 2		; L bit
N_L1:
		SUB	CX, AJYO1
		MOV	AX, AJYN1
		CMP	CX, AX
		JL	N_D1
		OR	DL, 4		; D bit
N_D1:
		NEG	AX
		CMP	CX, AX
		JG	N_U1
		OR	DL, 8		; U bit
N_U1:
		XOR	DL,31
		MOV	FUDLR_2, DL
E_ANJR1:	RET

ANJOY_START_2:
	cmp	nojoyflag,-1
	jp_e	no_stcks
;CLI			; NOTE !!!
		MOV	DX, 201H
		OUT	DX, AL
		NOP
		NOP
		MOV	BX, 0
		MOV	CX, 0
AJS2_ALP:
		IN	AL,DX
		INC	BX
		INC	CX
		TEST	AL, 4
		JZ	AJS2_YLP_A
		TEST	AL, 8
		JZ	AJS2_XLP_A
		CMP	CX, 1000
		JL	AJS2_ALP
		JMP	AJS2_TO		; for time-out
AJS2_XLP:
		; Y done - just count x
		IN	AL, DX
		INC	BX
		NOP
		NOP
		NOP			; adjust timing
		NOP
		NOP
		CMP	BX, 1000	;0	; for time-out
		JGE	AJS2_TO
AJS2_XLP_A:
		TEST	AL, 4
		JNZ	AJS2_XLP
;STI	no need off already !
		RET
AJS2_YLP:
		; X done - just count y
		IN	AL, DX
		INC	CX
		NOP
		NOP
		NOP
		NOP
		NOP
		CMP	CX, 1000	;0
		JGE	AJS2_TO
AJS2_YLP_A:
		TEST	AL, 8
		JNZ	AJS2_YLP
;STI
		RET
AJS2_TO:	; time-out
		MOV	AJF2, 0		; F
;STI
		RET
		
ANJOY_INIT_2:
	cmp	nojoyflag,-1
	jp_e	no_stcks
		MOV	AJF2,1	;ASSUME JOYSTICK PRESENT
		CALL	ANJOY_START_2
		CMP	AJF2, 0
		JE	E_AJI2
		MOV	AJXO2, BX	; x-origin
		MOV	AJXN2, BX
		SHR	BX, 1		; calc x-nullzone
		SUB	AJXN2, BX
		MOV	AJYO2, CX	; Y-origin
		MOV	AJYN2, CX
		SHR	CX, 1
		SUB	AJYN2, CX	; Y-nullzone
E_AJI2:
		RET

ANJOY_READ_2:
	cmp	nojoyflag,-1
	jp_e	no_stcks
	MOV	FUDLR,31	;changed
		CMP	AJF2, 0
		JE	E_ANJR2
		CALL	ANJOY_START_2
		CMP	AJF2, 0
		JE	E_ANJR2
	MOV	DL,FIREK
	MOV	KEYBD+FIRE_K,DL
		MOV	DL, 0
		NOT	AL
		TEST	AL, 0C0H	; both buttons
		JZ	N_ANJF2
	MOV	BYTE PTR KEYBD+FIRE_K,0
N_ANJF2:
		SUB	BX, AJXO2
		MOV	AX, AJXN2
		CMP	BX, AX
		JL	N_R2
		OR	DL, 1		; R bit
N_R2:
		NEG	AX
		CMP	BX, AX
		JG	N_L2
		OR	DL, 2		; L bit
N_L2:
		SUB	CX, AJYO2
		MOV	AX, AJYN2
		CMP	CX, AX
		JL	N_D2
		OR	DL, 4		; D bit
N_D2:
		NEG	AX
		CMP	CX, AX
		JG	N_U2
		OR	DL, 8		; U bit
N_U2:
		XOR	DL,31
		MOV	FUDLR, DL	;changed
E_ANJR2:
		RET
	
cseg		ends

dseg		segment	public 'data'

public		keybd, start_seg, start_offset, len, file_name, handle
PUBLIC		INTCOUNT,frame_count
PUBLIC		FUDLR, FUDLR_2, SND_PTR, SND_FLAG
PUBLIC		AJF1, AJF2,error_rout,errfl,cheat_mode

;extrn		dum_ptr:dword
extrn		nojoyflag:word,timer:word

cheat_mode	dw	0	;off for the moment.

ivect9_ip	dw	0
ivect9_cs	dw	0
ivect28_ip	dw	0
ivect28_cs	dw	0
intcount	dw	0
frame_count	dw	0

error_rout	dw	offset flg_error	;div_err
;	jmps short via this for a disc loading error

keybd		db	128 dup (1)

cht_ptr	dw	offset cht_text	;start at the beginning
				; reset pointer by pressing f8

cht_text	db	16h;	u whats the text ????
	db	26h	;l
	db	14h	;t
	db	13h	;r
	db	1eh	;a

	db	2fh	;v
	db	17h	;i
	db	18h	;o
	db	26h	;l

	db	12h	;e
	db	31h	;n
	db	2eh	;c
endtxt	db	12h	;e

; 13 letters once done we can cheat ! 1-5 works and enemy has low energy.
; lets try ultraviolence

errfl	dw	0
start_seg	dw	0
start_offset	dw	0
len		dw	0
file_name	dw	0
handle		dw	0
in_slow 	db	1

AJF1		DB	0	;F
AJXO1		DW	0
AJYO1		DW	0
AJXN1		DW	0
AJYN1		DW	0
AJF2		DB	0	;F
AJXO2		DW	0
AJYO2		DW	0
AJXN2		DW	0
AJYN2		DW	0

SND_PTR		DW	0
SND_FLAG	DW	-1		; T
FUDLR		DB	0
FUDLR_2		DB	0
LKEY		DB	0
FIREK	DB	1
FIREJ	DB	1

snd_tab_1	dw	0

snd_tab_2	dw	1000, 2000, 4000, 6000, 5000, 8000, 7500, 9000, 11000
		dw	9000, 12000, 18000, 15000, 20000, 17000, 23000
		dw	0

snd_tab_3	dw	5000, 8000, 12000, 6000, 9000, 13000, 7000, 10000
		dw	15000, 8000, 11000, 16000, 13000, 9000, 17000, 14000
		dw	15500, 19000, 20000, 18500, 23000, 27000, 31000
		dw	0

snd_tab_4	dw	1000, 950, 900, 850, 800, 700, 600, 450, 300, 200
		dw	90, 250, 400, 650, 900, 1100, 1300, 1600, 1900, 2200
		dw	2500, 3200, 4000, 4100, 4200, 4300, 4400
		dw	0

snd_tab_5	dw	5000, 5400, 4900, 5300, 4800, 5200, 4600, 5000
		dw	4600, 4900, 4600, 4800, 4800, 5200, 4900, 5300
		dw	5000, 5400, 5100, 5500, 5300, 5600, 5500, 5700
		dw	0

snd_tab_6	dw	4000, 4500, 4100, 4600, 4300, 4800, 4300, 4800, 4200, 4700
		dw	4400, 4900, 4500, 5000, 4600, 5100, 4600, 5100, 4500, 5000
		dw	4400, 4900, 4500, 5000, 4800, 5300, 5000, 5500, 5200, 5700
		dw	5500, 5500, 5600, 6100, 5700, 6200, 5700, 6200, 5600, 6100
		dw	5500, 6000, 5600, 6100, 5700, 6200, 5900, 6400, 6000, 6500
		dw	6000, 6500, 6200, 6700, 6500, 7000, 6600, 7100, 6600, 7100
		dw	0

snd_tab_7	dw	1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000
		dw	1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000
		dw	1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000
		dw	1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000
		dw	1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000
		dw	0

snd_tab_8	dw	4000, 8000, 3500, 7500, 2700, 6700, 2000, 6000
		dw	2000, 6000, 2500, 6500, 3000, 7000, 3900, 7900
		dw	4500, 8500, 5000, 9000, 5500, 9500, 6000, 10000
		dw	6500, 10500, 7000, 11000, 7500, 11500, 8000, 12000
		dw	0

snd_tab_9	dw	1000, 6000, 300, 9000, 5000, 12000, 1500, 5000, 400
		dw	1500, 7000, 9000, 4000, 4600, 3000, 13000, 8000, 7000
		dw	15000, 11000, 2300, 6700, 3000, 12000, 7000, 6000, 760
		dw	3000, 4000, 8000, 11000, 800, 9000, 11500, 3500, 7500
		dw	11300, 15500, 9500, 5500, 6789, 9999, 13000, 7500
		dw	0

snd_tab_10	dw	8000, 12000, 8000, 8000, 12000, 8000, 12000, 8000
		dw	12000, 8000, 12000, 8000, 12000
		dw	0

snd_tab_11	dw	1000, 8000, 8600, 8100, 9000, 8800, 8500, 9500, 9000
		dw	10000, 9400, 9900, 10200, 10700, 9800, 11050, 10600
		dw	12000, 11300, 11700, 13000, 11200, 11900, 12600, 13200
		dw	12800, 13400, 12900, 13300, 13700, 13400, 13900, 14000
		dw	13800, 14200, 14450, 13960, 14800, 15300, 14300, 14850
		dw	15200, 14950, 14300, 15500, 15000, 15350, 15400, 15600
		dw	16200, 16000, 15900, 16600, 16900, 17000, 16700, 17300
		dw	0

snd_tab_12	dw	12000, 2000, 800, 700, 710, 700, 710, 700, 710, 700
		dw	710, 700, 710, 700, 710, 700, 710, 700, 710, 700
		dw	0

snd_tab_13	dw	3000, 5000, 12000
		dw	0

null_str db	39 dup (32),0

disc_names	dw	offset main_str
		dw	offset main_str
		dw	offset ega_str
		dw	offset vga_str

main_str	db	" Insert Main disc .  Then Press Space .",0
ega_str		db	" Insert EGA disc  .  Then Press Space .",0
vga_str		db	" Insert VGA disc  .  Then Press Space .",0


dseg		ends

buff_seg  segment para public 'DATA'

;db      4096 dup (?)	;why is there an extra 4096 bytes here !
;			; there is about 30k in this area anyway !

buff_seg  ends

	end

cseg		segment	public 'code'

public		return, newivector, restore_int
public		load, save, create, open, writeF, error, READF, close
public		de_vice,INIT_STICKS

extrn   delzw:near

PUBLIC	TEST_SND
;PUBLIC	ANJOY_INIT, ANJOY_READ, ANJOY_INIT_2, ANJOY_READ_2
public	hit_snd, thud_snd, linda_snd, will_snd, colaps_snd, whip_snd
public	thumb_snd, splash_snd, splat_snd, bounce_snd, knife_snd, gun_snd

assume		cs:cseg, ds:dseg

include 	ddeqfile
include 	c:\masm\macross.asm

return:		call	restore_int
		mov	ax, 2
		int	16
		mov	ax, 4c00h
		int	33

newivector:	cli
		push	ds
		push	es
		mov	ax, dseg
		mov	ds, ax
		xor	ax, ax
		mov	es, ax
		mov	ax, es: [36]
		mov	ivect9_ip, ax
		mov	ax, es: [38]
		mov	ivect9_cs, ax
		mov	ax, es: [28*4]
		mov	es:[0fh*4],ax
		mov	ivect28_ip, ax
		mov	ax, es: [28*4+2]
		mov	es:[0fh*4+2],ax
		mov	ivect28_cs, ax

		call	fast_i

		mov	word ptr es: [36], offset scan
		mov	es: [38], cs

		mov	word ptr es: [28*4], offset timer_int
		mov	es: [28*4+2], cs
		MOV	FIREJ,1
		MOV	FIREK,1
	mov	dx,201h
	out	dx,al
	sti
		pop	es
		pop	ds
		ret


START_SOUND:
		CMP	SND_FLAG, 0
		JE	NO_SOUND

		MOV	AL,0B6H			; init spkr timer
		OUT	43H, AL
		IN	AL, 61H
		OR	AL, 3
		OUT	61H, AL
		RET
NO_SOUND:
		MOV	SND_PTR, 0
		RET

scan:
		push	ax
		push	bx
		push	ds
		mov	ax, dseg
		mov	ds, ax

		in	al, 60h
		mov	bl, al
		in	al, 61h
		or	al, 80h
		out	61h, al
		and	al, 7fh
		out	61h, al

		xor	al, al
		mov	bh, al
		shl	bl, 1
		rcl	al, 1
		shr	bl, 1
		mov	[keybd + bx], al
		CMP	BX,FIRE_K
		JNE	NF1
		MOV	FIREK,AL	;STORE THE REAL FIRE KEY
NF1:
		CMP	BX,FIRE_J
		JNE	NF2	
		MOV	FIREJ,AL	;STORE THE REAL FIRE KEY
NF2:
		mov	al, 61h
		out	20h, al

		pop	ds
		pop	bx
		pop	ax
		sti
		iret
loadit:
	push	nojoyflag
	mov	nojoyflag,-1	;kill sticks ?
		call	open
		call	READF
		call	close
	pop	nojoyflag
		ret
save:
		call	create
		call	writeF
		call	close
		ret
create:		mov	dx, file_name
		xor	cx, cx
		mov	al, 2
		mov	ah, 3ch			; function 3c - create file
		int	33
		jc	error
		mov	handle, ax
		ret
;	    open a file for READFing

open:           mov     ah,13
		int     21h
		mov     dx, file_name
		xor	al, al
		mov	ah, 3dh			; function 3d - open file
		int	33
		jc	error
		mov	handle, ax
		ret
; 	     write to file

writeF:		mov	ax, start_seg
		mov	bx, handle
		mov	cx, len
		mov	dx, start_offset
		push	ds
		mov	ds, ax
		mov	ah, 40h			; function 40 - write file
		int	33
		pop	ds
		jc	error
		ret
; print up the error message

error:		
		call	restore_int
		int	0
		mov	ax, 4c00h
		int	33

;	   read a file

READF:          mov     ah,13
		int     21h
		mov     ax, start_seg
		mov	bx, handle
		mov	cx, 0ffffh
		mov	dx, start_offset
		push	ds
		mov	ds, ax
		mov	ah, 3fh			; function 3f - read file
		int	33
		pop	ds
		jc	error
		ret

close:		mov	bx, handle
		mov	ah, 3eh			; function 3e - close file
		int	33
		jc	error
		ret

load:
	call    slow_i
de_vice:
;load the file into a buffer area and then decompress to load area
	push	es
	push	ds

	push	start_seg
	push	start_offset

	xor	ax,ax
	mov	start_offset,ax
;	mov	ax,word ptr [dum_ptr+2]
;       add     ax,4096 ;+64k
	mov	ax,buff_seg
	mov     start_seg,ax
;load into free memory (hopefully!)
	call    loadit  ;loads into normal space ?
	pop	di	;start_offset
	pop	es	;start_seg
;those are destination for deviceing
	xor	si,si
	mov	ax,start_seg
	mov	ds,ax
	call    delzw   ;decompress from DS:SI to ES:DI

	pop	ds
	pop	es

	call    fast_i

	ret

;ASSUME NO STICK BUT WHEN A BUTTON IS PRESSED INITIATE THE JOYSTICK
;The Tandy joystick routines from Jake

ANJOY_START_2:
;CLI			; NOTE !!!
		MOV	DX, 201H
		OUT	DX, AL
		NOP
		NOP
		MOV	BX, 0
		MOV	CX, 0
AJS_ALP:
		IN	AL, DX
		INC	BX
		INC	CX
		TEST	AL, 1
		JZ	AJS_YLP_A
		TEST	AL, 2
		JZ	AJS_XLP_A
		CMP	CX, 1000
		JL	AJS_ALP
		JMP	AJS_TO		; for time-out
AJS_XLP:
		; Y done - just count x
		IN	AL, DX
		INC	BX
		NOP
		NOP
		NOP			; adjust timing
		NOP
		NOP
		CMP	BX, 1000	;0	; for time-out
		JGE	AJS_TO
AJS_XLP_A:
		TEST	AL, 1
		JNZ	AJS_XLP
;STI
		RET
AJS_YLP:
		; X done - just count y
		IN	AL, DX
		INC	CX
		NOP
		NOP
		NOP
		NOP
		NOP
		CMP	CX, 1000	;0
		JGE	AJS_TO
AJS_YLP_A:
		TEST	AL, 2
		JNZ	AJS_YLP
;STI
		RET
AJS_TO:
; time-out	SHOULDNT IT MAKE THE JOY FLAG FALSE ?
		MOV	AJF1, 0		; F
;STI
		RET

		
ANJOY_INIT_2:
		MOV	AJF1,1
		CALL	ANJOY_START_2
		CMP	AJF1, 0
		JE	E_AJI
		MOV	AJXO1, BX	; x-origin
		MOV	AJXN1, BX
		SHR	BX, 1		; calc x-nullzone
		SUB	AJXN1, BX
		MOV	AJYO1, CX	; Y-origin
		MOV	AJYN1, CX
		SHR	CX, 1
		SUB	AJYN1, CX	; Y-nullzone
E_AJI:
		RET


ANJOY_READ_2:
	MOV	FUDLR,31
		CMP	AJF1, 0
		JE	E_ANJR1
		CALL	ANJOY_START_2
		CMP	AJF1, 0
		JE	E_ANJR1
	MOV	DL,FIREK
	MOV	KEYBD+FIRE_K,DL
		MOV	DL,0
		NOT	AL
		TEST	AL,030H	; both buttons
		JZ	N_ANJF1
	MOV	BYTE PTR KEYBD+FIRE_K,0
N_ANJF1:
		SUB	BX, AJXO1
		MOV	AX, AJXN1
		CMP	BX, AX
		JL	N_R1
		OR	DL, 1		; R bit
N_R1:
		NEG	AX
		CMP	BX, AX
		JG	N_L1
		OR	DL, 2		; L bit
N_L1:
		SUB	CX, AJYO1
		MOV	AX, AJYN1
		CMP	CX, AX
		JL	N_D1
		OR	DL, 4		; D bit
N_D1:
		NEG	AX
		CMP	CX, AX
		JG	N_U1
		OR	DL, 8		; U bit
N_U1:
		XOR	DL,31
		MOV	FUDLR, DL
E_ANJR1:	RET

ANJOY_START:
;CLI			; NOTE !!!
		MOV	DX, 201H
		OUT	DX, AL
		NOP
		NOP
		MOV	BX, 0
		MOV	CX, 0
AJS2_ALP:
		IN	AL,DX
		INC	BX
		INC	CX
		TEST	AL, 4
		JZ	AJS2_YLP_A
		TEST	AL, 8
		JZ	AJS2_XLP_A
		CMP	CX, 1000
		JL	AJS2_ALP
		JMP	AJS2_TO		; for time-out
AJS2_XLP:
		; Y done - just count x
		IN	AL, DX
		INC	BX
		NOP
		NOP
		NOP			; adjust timing
		NOP
		NOP
		CMP	BX, 1000	;0	; for time-out
		JGE	AJS2_TO
AJS2_XLP_A:
		TEST	AL, 4
		JNZ	AJS2_XLP
;STI	no need off already !
		RET
AJS2_YLP:
		; X done - just count y
		IN	AL, DX
		INC	CX
		NOP
		NOP
		NOP
		NOP
		NOP
		CMP	CX, 1000	;0
		JGE	AJS2_TO
AJS2_YLP_A:
		TEST	AL, 8
		JNZ	AJS2_YLP
;STI
		RET
AJS2_TO:	; time-out
		MOV	AJF2, 0		; F
;STI
		RET
		
ANJOY_INIT:
		MOV	AJF2,1	;ASSUME JOYSTICK PRESENT
		CALL	ANJOY_START
		CMP	AJF2, 0
		JE	E_AJI2
		MOV	AJXO2, BX	; x-origin
		MOV	AJXN2, BX
		SHR	BX, 1		; calc x-nullzone
		SUB	AJXN2, BX
		MOV	AJYO2, CX	; Y-origin
		MOV	AJYN2, CX
		SHR	CX, 1
		SUB	AJYN2, CX	; Y-nullzone
E_AJI2:
		RET

ANJOY_READ:
	MOV	FUDLR_2,31
		CMP	AJF2, 0
		JE	E_ANJR2
		CALL	ANJOY_START
		CMP	AJF2, 0
		JE	E_ANJR2
	MOV	DL,FIREJ
	MOV	KEYBD+FIRE_J,DL
		MOV	DL, 0
		NOT	AL
		TEST	AL, 0C0H	; both buttons
		JZ	N_ANJF2
	MOV	BYTE PTR KEYBD+FIRE_J,0
N_ANJF2:
		SUB	BX, AJXO2
		MOV	AX, AJXN2
		CMP	BX, AX
		JL	N_R2
		OR	DL, 1		; R bit
N_R2:
		NEG	AX
		CMP	BX, AX
		JG	N_L2
		OR	DL, 2		; L bit
N_L2:
		SUB	CX, AJYO2
		MOV	AX, AJYN2
		CMP	CX, AX
		JL	N_D2
		OR	DL, 4		; D bit
N_D2:
		NEG	AX
		CMP	CX, AX
		JG	N_U2
		OR	DL, 8		; U bit
N_U2:
		XOR	DL,31
		MOV	FUDLR_2, DL
E_ANJR2:
		RET
	
cseg		ends

