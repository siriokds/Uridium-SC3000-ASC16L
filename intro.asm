optionmenu_offset:	equ 0x1800
optionmenu_shift:	equ 0
	
	
; text:				equ 0xC100
	
; options_miz:
	; incbin "options_no_menu.nam.pck"
	
text:
	db	"HEWSON & Trilobyte  ",13				;  0
	db	"presents ",13							;  1
	db	127,128,129,130,131,132,133,134,13			;  2
	db	135,136,137,138,136,139,140,141,13			;  3
	db	"@ Graftgold Ltd.",13						;  4
;	db	"Congratulations!",13						;  4
	db	"Original C64 design:",13					;  5
	db	"Andrew Braybrook",13						;  6
	db	"ARTRAG - MSX coding     ",13				;  7
	db	"Toni Galvez - Graphic & SFX",13			;  8
	db	"                      ",13					;  9
	db	"   SiRioKD - SC-3000 coding",13			; 10
	db	"                 & testing",13				; 11
	db	"Slogra - SC-3000 music      ",13			; 12
	db	"                        ",13				; 13
	db	"   Published by SiRioKD   ",13				; 14
	
prstr:
	ex de,hl
    disint	
	call setwrtvram
	ex de,hl
1:	ld   a,(de)
	inc  de
	cp	13
	ret  z
	add	a,-'!'+1
	out (VDP),a
	jr   1b

cls:
	_setvdpwvram 0x1800
	xor	a
	ld	b,192
1:	call set4
	djnz	1b
	ret
	
	
	
	
print_page:
    disint
	call	cls

	
	; ld	hl,	options_miz
	; ld	de, text
	; call	BitBuster_Unpack
	
	; _setvdpwvram (0x1800)
	; ld  hl, text
	; ld  bc, 768
	; call vdp_copyvram
	
	
	ld	de,text
	ld	hl,optionmenu_offset+32*0+7+optionmenu_shift
	call	prstr
	ld	hl,optionmenu_offset+32*2+12+optionmenu_shift
	call	prstr

	ld	hl,optionmenu_offset+32*4+12
	call	prstr
	ld	hl,optionmenu_offset+32*5+12
	call	prstr

	ld	hl,optionmenu_offset+32*7+8+optionmenu_shift
	call	prstr
	ld	hl,optionmenu_offset+32*9+1+optionmenu_shift
	call	prstr

	ld	hl,optionmenu_offset+32*10+9+optionmenu_shift
	call	prstr
   
	ld	hl,optionmenu_offset+32*12+6+optionmenu_shift
	call	prstr
	ld	hl,optionmenu_offset+32*13+1+optionmenu_shift
	call	prstr
	ld	hl,optionmenu_offset+32*14+0+6+optionmenu_shift
	call	prstr
	ld	hl,optionmenu_offset+32*15+2+optionmenu_shift
	call	prstr
	ld	hl,optionmenu_offset+32*16+3+optionmenu_shift
	call	prstr
	ld	hl,optionmenu_offset+32*17+6+optionmenu_shift
	call	prstr
	ld	hl,optionmenu_offset+32*18+5+optionmenu_shift
	call	prstr
	ld	hl,optionmenu_offset+32*19+3+optionmenu_shift
	call	prstr
	
	
    ret
	

	
set4:
	DUP	4
	out	(VDP),a
	push	af
	pop		af
	EDUP
	ret



plot_title_screen:
    disint
	call	disscr
	
	; set shapes	

	ld a,(0xbfbe)
	push af

	setpage2 $$set_font

	call set_font

	pop af
	ld (PAGESWAP),a
	
	; set colours
	_setvdpwvram 0x2000
	ld	bc,0x0003
1:	ld	a,0x51
	call	set4
	ld	a,0x41
	call	set4
	djnz	1b
	dec	c
	jr	nz,1b
	
	
	
	
	_setvdpwvram (0x2000+95*8)
	ld	b,8*8
	ld	a,0x60
	; nop / out / djnz = 28 T, sotto il minimo di 29 richiesto dal VDP
	;1:	nop
	;	out	(VDP),a
	;	djnz	1b
1:	out	(VDP),a		; 11 T
	dec	b		;  4 T
	nop			;  4 T
	jp	nz,1b		; 10 T	-> 29 T esatti
	ld	b,7*8
	ld	a,0xD0
	; nop / out / djnz = 28 T, sotto il minimo di 29 richiesto dal VDP
	;1:	nop
	;	out	(VDP),a
	;	djnz	1b
1:	out	(VDP),a		; 11 T
	dec	b		;  4 T
	nop			;  4 T
	jp	nz,1b		; 10 T	-> 29 T esatti

	xor	a
	ld	(toshiba_switch),a

	;call	intro_music

	xor	a				; active voice and music by default
	ld	(music_off),a
	ld	(voice_off),a

	ld  a, 1
	ld  (start_intro_mus), a
	call	menu0
	
1:	ld	a,(ayFX_PRIORITY)
	inc	a
	jr	nz,1b				; wait for last sfx

	;call 	sfx_waitsfx
	
	call	PT3_MUTE
	ret
	


; key_table:
        ; db $80,$08,$04,$05,$0c,$07,$0a,$02
        ; db $0d,$0b,$00,$09,$03,$01,$06,$80

;;;;;;;;;;;;;;;;;;;;
; Keyboard testing
ayFX_test:

		ld	a,(ayFX_PRIORITY)
		cp      255
		ret     nz              	; play only if no other sfx is active
		
		; out (0x80),a
		; ex (sp),hl
		; ex (sp),hl
		; in a,(0xfc)
		; ld e,a
		; in a,(0xff)
		; and e
		; and 0x0f
		; ld hl,key_table
		; ld e,a
		; ld d,0
		; add hl,de
		; ld a,(hl)
		; cp $80
		; call nz,_ayFX_INIT


		ret
		
_ayFX_INIT:
		cp	n_sfx+1
		ret	nc
		jp	AFXPLAY
		
intro_music:
		disint

		setpage2 $$mus_intro
		;ld		hl,mus_intro-100+16
		ld		hl,mus_intro+16
		ld      e, $$mus_intro
		call	PT3_INIT
		
		; ld		hl,mus_intro
		; call 	wavemap_init
		; call	ayFX_SETUP
		
		xor a
		ld  (start_intro_mus), a
		enaint
		ret
	
ending_music:
		disint

		setpage2 $$mus_end
		
		;ld		hl,mus_end-100+16
		ld		hl,mus_end+16
		ld      e, $$mus_end
		call	PT3_INIT

		; ld		hl,mus_end
		; call 	wavemap_init
		; call	ayFX_SETUP
		enaint
		ret
		