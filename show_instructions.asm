
	
instruct:
		db	0x99+' ',0x9A+' '," Avoid barriers and other",13
		db	0x9B+' ',0x9C+' '," tall obstacles",13
		db	0x9D+' ',0x9E+' ',13
		db	0x84+' ',0x86+' '," Press up/down + RB to spin",13
		db	0x85+' ',0x87+' '," and pass between barriers",13
		db	0x80+' ',0x82+' '," Use looping to dodge",13
		db	0x81+' ',0x83+' '," enemy bullets",13
		db	0x88+' ',0x89+' ',0x88+' ',13
		db	0x8B+' ',0x8C+' ',0x8B+' '," Destroy ground targets",13
		db	0x8D+' ',0x8E+' ',0x8F+' '," to weaken Dreadnought's",13	
		db	0x90+' ',0x91+' ',0x92+' '," defense",13	
		db	0x88+' ',0x93+' ',0x94+' ',13
		db	0x88+' ',0x95+' ',0x96+' ',13
		db	"Land on the main runway of",13	
		db	"each Dreadnought and activate",13
		db	"its self destruction system",13	
		
		
show_instructions:
	call cls
	call _color_set
	call _destr_set
	
	ld  de,instruct
	ld	hl,0x1800+32*1+2
	call	prstr
	ld	hl,0x1800+32*2+2
	call	prstr
	ld	hl,0x1800+32*3+2
	call	prstr
	
	ld	hl,0x1800+32*5+2
	call	prstr
	ld	hl,0x1800+32*6+2
	call	prstr

	ld	hl,0x1800+32*8+2
	call	prstr
	ld	hl,0x1800+32*9+2
	call	prstr
	
	ld	hl,0x1800+32*11+2
	call	prstr
	ld	hl,0x1800+32*12+2
	call	prstr
	ld	hl,0x1800+32*13+2
	call	prstr
	ld	hl,0x1800+32*14+2
	call	prstr
	ld	hl,0x1800+32*15+2
	call	prstr
	ld	hl,0x1800+32*16+2
	call	prstr

	ld	hl,0x1800+32*18+2
	call	prstr
	ld	hl,0x1800+32*19+2
	call	prstr
	ld	hl,0x1800+32*20+2
	call	prstr
		
	ld	de,0x1800+32*22+8
    disint	
	call	setwrtvram
	ld	bc,0x1000+VDP
	; outi->outi = 8 T e outi->outi(giro succ.) = 22 T (con jr nz), entrambi
	; sotto il minimo di 29 (schermo attivo). jr nz -> jp nz (fisso 10 T)
	; + nop per portare entrambi i gap a 32 T.
1:	ld	hl,runway_map	; 10 T
	outi			; 16 T
	nop			;  4 T
	nop			;  4 T
	nop			;  4 T
	nop			;  4 T
	nop			;  4 T
	nop			;  4 T
	nop			;  4 T
	nop			;  4 T	-> outi->outi = 32 T
	outi			; 16 T
	nop			;  4 T
	nop			;  4 T
	nop			;  4 T
	jp nz,1b		; 10 T	-> outi->outi(giro succ.) = 32 T
	ld	hl,runway_map
	outi
	
	ld	de,0x1800+32*23+8
	disint
	call	setwrtvram
	ld	bc,0x1000+VDP
	; outi->outi = 16 T e outi->outi(giro succ.) = 30 T (con jr nz, ma
	; sotto 29 appena convertito a jp nz fisso). Porto entrambi a 32 T.
1:	ld	hl,runway_map+2	; 10 T
	outi			; 16 T
	nop			;  4 T
	nop			;  4 T
	nop			;  4 T
	nop			;  4 T	-> outi->outi = 16 T
	nop			;  4 T
	nop			;  4 T
	nop			;  4 T
	nop			;  4 T	-> outi->outi = 32 T
	outi			; 16 T
	nop			;  4 T
	nop			;  4 T
	nop			;  4 T	-> outi->outi(giro succ.) = 32 T
	jp nz,1b		; 10 T
	ld	hl,runway_map+2
	nop
	nop
	nop
	nop
	outi
	
	; setvdpwvram 0x3800
	; ld	hl,enbullet	
	; ld	b,0
	; ld	c,VDP
; 1:	outi
	; jr nz,1b
	
	; setvdpwvram 0x1b00
	; ld	a,0			; y
	; out	(VDP),a
	; ld	a,0			; x
	; out	(VDP),a
	; ld 	a,0
	; out	(VDP),a		; shape
	; ld 	a,15
	; out	(VDP),a		; color

	; ld	a,0xD0		; delimiter
	; out (VDP),a

    enaint
	
	
	
3:
	xor	a
	ld	(aniframe),a
	
2:	halt	
	call plot_spt_char_anim
	ld b,10
1:	halt
	djnz 1b
	
	ld	a,(aniframe)
	inc	a
	ld	(aniframe),a
	cp 32
	jr z,3b


	call	joy_read
	and	0x33		; up/down/fire
	jp	nz, return_noreset_mus
	
	jr 2b
	
	
plot_spt_char_anim:
	setvdpwvram 0x0400
	ld	a,(aniframe)
	and 7
	call	1f
	setvdpwvram 0x0C00
	ld	a,(aniframe)
	and 7
	call	1f
	; setvdpwvram 0x1400
	; ld	a,(aniframe)
	; and 7
	; call	1f
	
	setvdpwvram 0x0420
	ld	a,(aniframe)
	and 15
	add	a,32
	call	1f
	setvdpwvram 0x0C20
	ld	a,(aniframe)
	and 15
	add	a,32
	; call	1f
	; setvdpwvram 0x1420
	; ld	a,(aniframe)
	; and 15
	; add	a,32
	; call	1f
	; ret
	
1:	ld	hl,ms_ani
	ld	c,a
	ld	b,0
	add	hl,bc
	ld	l,(hl)
	ld	h,b
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld	e,l
	ld	d,h
	add	hl,hl
	add	hl,de
	ld	de,ms_spt
	add hl,de
	ld	bc,0x2000+VDP
	; outi / jr nz = 28 T, sotto il minimo di 29 (schermo attivo)
	;1:	outi
	;	jr nz,1b
1:	nop			;  4 T
	outi			; 16 T
	jp nz,1b		; 10 T	-> 30 T
	ret

; set colours
_color_set
	setvdpwvram (0x2000+128*8)
	call 1f
	setvdpwvram (0x2800+128*8)
	call 1f
	setvdpwvram (0x3000+128*8)
1:	ld	b,8*8
1:	ld	a,0xF1
	out	(VDP),a
	djnz	1b
	ret

_destr_set:
	halt
	setvdpwvram (0x0000+136*8)
	call 2f
	setvdpwvram (0x0800+136*8)
	call 2f
	setvdpwvram (0x1000+136*8)
	call 2f
	
	setvdpwvram (0x2000+136*8)
	call 1f
	setvdpwvram (0x2800+136*8)
	call 1f
	setvdpwvram (0x3000+136*8)
1:
	ld	hl,destruct_colors
	ld	bc,23*8*256+VDP
11:	nop
	outi
	jr	nz,11b
	ret
2:
	ld	hl,destruct_tiles
	ld	bc,23*8*256+VDP
11:	nop
	outi
	jr	nz,11b
	ret
	
	
destruct_tiles:
	incbin	"destr_shape.bin"
runway_shape:
	db 0x00,0x00,0x00,0x00,0x00,0xC0,0x07,0x01
	db 0x01,0x07,0xC0,0x00,0x00,0x00,0x00,0xFF 
barrier_shape:
	db	0x80,0x40,0x40,0x40,0x40,0x40,0x40,0x40    ;
	db	0x01,0x02,0x02,0x02,0x02,0x02,0x02,0x02    ;
	db	0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x40    ;
	db	0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x02    ;
	db	0x40,0x40,0x40,0x40,0x40,0x40,0x40,0x80    ;
	db	0x02,0x02,0x02,0x02,0x02,0x02,0x02,0x01    ;

destruct_colors:
	incbin	"destr_col.bin"
runway_col:   
	db 0x55,0x44,0x44,0x44,0x44,0xA4,0x4A,0x4A
	db 0x4A,0x4A,0xA4,0x44,0x44,0x44,0x44,0x11 
barrier_col:
	db 0x4C,0xC4,0x4C,0x4C,0x4C,0x4C,0x4C,0x4C    
	db 0x1C,0xC1,0x1C,0x1C,0x1C,0x1C,0x1C,0x1C    
	db 0x4C,0x4C,0x4C,0x4C,0x4C,0x4C,0x4C,0x4C    
	db 0x1C,0x1C,0x1C,0x1C,0x1C,0x1C,0x1C,0x1C    
	db 0x4C,0x4C,0x4C,0x4C,0x4C,0x4C,0xC4,0x4C    
	db 0x1C,0x1C,0x1C,0x1C,0x1C,0x1C,0xC1,0x1C    

	
; destruct_map
	; db 0x00,0x01,0x00
	; db 0x03,0x04,0x03
	; db 0x05,0x06,0x07
	; db 0x08,0x09,0x0A
	; db 0x00,0x0B,0x0C
	; db 0x00,0x0D,0x0E
runway_map:
	db	0x8D,0x97
	db	0x90,0x98
	
; enbullet:
; [2]	db	0
	; db	00011000b
	; db	00111100b
	; db	00111100b
	; db	00011000b	
; [2+24]	db	0