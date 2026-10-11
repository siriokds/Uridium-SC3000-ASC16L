scorebar_sat:

; counter:=32*4
	; repeat	6
	; repeat	4
	; db	@@# * 8 -8-1
	; if	(!((@@#/4) & 1))
		; if	((counter!=32*4) & (counter!=32*4+4*4) & (counter!=4*8+32*4) & (counter!=4*12+32*4))
			; db	(@# * 16)+192
		; else
			; db	0
		; endif
	; else
		; db	96+(@# * 16)
	; endif
	; db	0+counter
	; if ((counter>=33*4)&(counter<=35*4))
	; db	13
	; elseif ((counter>=37*4)&(counter<=39*4))
	; db	6
	; else
	; db	14+8-counter/16
	; endif
; counter:=counter+4
	; endrepeat
	; endrepeat


    db $F7, $08, $80, $0E,	 			$F7, $C8, $84, $0D,		$F7, $D8, $88, $0D,		$F7, $E8, $8C, $0D 
    db $FF, $08, $90, $0D,	 			$FF, $C8, $94, $06,		$FF, $D8, $98, $06,		$FF, $E8, $9C, $06 
    db $07, $08, $A0, $0C,	 			$07, $C8, $A4, $0C,		$07, $D8, $A8, $0C,		$07, $E8, $AC, $0C 
    db $0F, $08, $B0, $0B,	 			$0F, $C8, $B4, $0B,		$0F, $D8, $B8, $0B,		$0F, $E8, $BC, $0B 

    db $17, $60, $C0, $0A,	 $17, $70, $C4, $0A,	$17, $80, $C8, $0A,		$17, $90, $CC, $0A 
    db $1F, $60, $D0, $09,	 $1F, $70, $D4, $09,	$1F, $80, $D8, $09,		$1F, $90, $DC, $09

;	F7 00 80 0E F7 D0 84 0E F7 E0 88 0E F7 F0 8C 0E 
;	FF 00 90 0D FF D0 94 0D FF E0 98 0D FF F0 9C 0D 
	
counter:=(32+6*4)*4
	DUP	4, DUPIDX
	db	3*16-1
	db	96+(DUPIDX * 16)
	db	counter
	db	14
counter:=counter+4
	EDUP
	
	
	DUP	1			; 28
	db	3*16-1-2		; 3 pixels of overlap with the upper sign
	; db	(@# * 16)+16
	db	16
	db	32*4			; placeholder
	db	1+0x80
	EDUP

	DUP	1			; 29
	db	4*16-1-2		; 3 pixels of overlap with the upper sign
	; db	(@# * 16)+16
	db	16
	db	32*4			; placeholder
	db	1+0x80
	EDUP

	DUP	2			; 30,31
	db	0xd0		; 3 pixels of overlap with the upper sign
	; db	4*16-1-2		; 3 pixels of overlap with the upper sign
	db	16
	db	32*4			; placeholder
	db	1+0x80
	EDUP


