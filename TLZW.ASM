
include macross.asm

public  delzw

cseg    segment para public 'CODE'

	assume  cs:cseg,ds:buff_seg

BUMP_CODE       EQU     0100H
LOWEST_CODE	EQU	0101H

delzw:
;
;	Assumes ds points to buffseg to which the files are loaded.
;
	MOV     AX,[SI]         ; read header
	CMP     AX,9d1fH        ; is it PA in lemp!
	.if     notzero
		MOV     CX,0
		STC                     ;header error
		RET
	.endif
	CALL    MDECOMPRESS
	MOV     CX,AX

	CLC
	RET

 ;    Return value
 ; ax = size of the dest buffer (in bytes).
MDECOMPRESS:

	PUSH    BP
	PUSH    BX
	PUSH    CX
	PUSH    DI
	PUSH    DS
	PUSH    DX
	PUSH    ES
	PUSH    SI

 ; WARNING: The source is wiped out on the fly
	MOV     BP,SI      ; Base of new offset table.
	MOV     bx,SI      ; First free word position of new

	MOV     AX,2[SI]   ; # of bytes in src buffer.

	INC     AX ;

	MOV     word ptr COUNT,AX

	ADD     SI,6       ; Skip past header.

	CALL    INIT_VARIABLES

 ;   -
 ; Main loop
 ;   -
D_LOOP:
	MOV     [BX],DI
	ADD     BX,2
D_READ:
	CALL    READ_BITS
	CMP     AX,BUMP_CODE
	JNE     D_CNT
	INC     word ptr BITS_PER_CODE
	JMP     D_READ
D_CNT:
	CMP     word ptr COUNT,0
	JE      D_99
	CALL    OUTPUT_PATTERN
D_READ1:
	CALL    READ_BITS
	CMP     AX,BUMP_CODE
	JNE     D_CNT1
	INC     word ptr BITS_PER_CODE
	JMP     D_READ1
D_CNT1:
	CMP     word ptr COUNT,0
	JE      D_99
	CALL    OUTPUT_PATTERN
	JMP     D_LOOP

D_99:
	MOV     AX,DI  ; return the size of the dest buf

	POP     SI
	POP     ES
	POP     DX
	POP     DS
	POP     DI
	POP     CX
	POP     BX
	POP     BP
	RET


INIT_VARIABLES:

 ; Init two (2) variables used by read_bits().
	MOV     word ptr INBITS,0        ; so will wrap and read again
	MOV     word ptr BITS_PER_CODE,9 ; # of bits per code (to start with).

	RET

 ; output_pattern():
 ; Output the pattern which code ax maps
 ;    to, to the destination buffer (es:[di]...).
 ;
 ;    Parameters
 ; ax  Code
 ; bp  Ptr to beginning of new offset buffer.
 ;
 ;    Return value
 ; --  (ax scratched)
OUTPUT_PATTERN:

	CMP     AX,255
	JLE     OP_BYTE

	SUB     AX,LOWEST_CODE     ; start from bottom of table
	SHL     AX,1
	ADD     AX,BP
	PUSH    CX
	PUSH    SI
	MOV     SI,AX
	MOV     AX,[SI]
	MOV     CX,2[SI]
	SUB     CX,AX
	MOV     SI,AX
	MOV     DX,DS      ; Save ds
	PUSH    ES
	POP     DS
	CLD
	TEST    CX,1
	JZ      OP_WORD
	MOV     AL,[SI]
	INC     SI
	STOSB
OP_WORD:
	SHR     CX,1
	REP     MOVSW
	MOV     DS,DX      ; Restore ds
	POP     SI
	POP     CX
	JMP     OP_DONE

 ; It's not a special code- so save it
OP_BYTE:
	CLD
	STOSB

OP_DONE:
	RET


 ;
 ; read_bits():
 ;    Read next set of bits- quit if done
 ;
 ;    Parameters
 ; ds:inbits
 ; ds:bits_per_code
 ; ds:count
 ;
 ;    Return value
 ; if ds:count == 0  then done
 ; otherwise
 ;    ax = code returned
 ;    dx scrapped
 ;    ds:inbits updated
 ;    ds:savebl updated
 ;    ds:count updated
 ;
READ_BITS:

	PUSH    BX
	PUSH    CX

	XOR     AX,AX      ; clear out ax
	MOV     DX,word ptr INBITS
	MOV     BL,byte ptr SAVEBL

	MOV     CX,word ptr BITS_PER_CODE ; get bit counter
RB_LOOP:
	DEC     DX        ; count down next bit
	CMP     DX,0
	JL      RB_NEXT     ; not out yet
 ; bl has the byte
RB_OK:
	RCL     BL,1       ; right 1
	RCL     AX,1       ; get carry in ax
	LOOP    RB_LOOP
	JMP     RB_DONE

RB_NEXT:
	MOV     BL,[SI]    ; read next
	INC     SI ; Advance src index.
	MOV     DX,7       ; Reset bit counter
	DEC     word ptr COUNT
	JNE     RB_OK      ; not done yet

RB_DONE:
	MOV     word ptr INBITS,DX
	MOV     byte ptr SAVEBL,BL
	POP     CX
	POP     BX
	RET

cseg    ends

buff_seg  segment para public 'DATA'

DASE_OFF        DW ?
DLIDE_DAS       DW ?

BITS_PER_CODE   DW ?
COUNT           DW ?
INBITS          DW ?
SAVEBL          DB ?

buff_seg  ends

	end

