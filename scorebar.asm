add16_de:
	push	hl
	ld hl,16
	add hl,de
	ex de,hl
	pop hl
	ret	
	
;;;;;;;;;;;;;;;;;;;
bannertime:	equ 180		; 3 seconds

bannerupdate:
	and a
	ld	bc,bannertime
	ld 	hl,(bannertimer)
	sbc hl,bc
	jr nz,1f
	
	halt 
	call _set_bonus_sign
	call _set_bonus_sign2
	
1:	and a
	adc	hl,bc	; test ZF
	ret z
	
	ld 		hl,_syren		
	call	_vocset	

	ld hl,(bannertimer)
	dec hl
	ld (bannertimer),hl
	ld a,l
	or h
	ret nz
	
restore_scorebar:							; restore the banner
	halt 
	call _set_uridium_sign
	
	disint
	_setvdpwvram 0x1800
	
	ld b,0
	; xor a / out / djnz = 28 T, sotto il minimo di 29 richiesto dal VDP
	;1:	xor a
	;	out (VDP),a
	;	djnz 1b
1:	xor a		;  4 T
	out (VDP),a	; 11 T
	dec	b		;  4 T
	jp	nz,1b	; 10 T	-> 29 T esatti
    enaint
	
	ret
	
;;;;;;;;;;;;;;;;;;;	

_set_uridium_sign:
	ld a,(0xbfbe)
	push af
	;ld a,(0xfff8+:_rom_tileset)				; enable page where _rom_tileset is
	setpage2 $$_rom_tileset

	ld	de,0x1C00+16*32+ 8*1
	ld 	hl,_rom_tileset+95*8
	ld	bc,12*256+VDP
1:	push	bc
	call	_set_onetile
	pop	bc
	djnz	1b
	
	ld hl,_rom_tileset+104*8
	call	_set_onetile
	
	ld hl,_rom_tileset+107*8
	ld	b,3	
1:	push	bc
	call	_set_onetile
	pop	bc
	djnz	1b

	pop af
	ld (PAGESWAP),a
	;ld a,(bc)					; restore initial page 
	ret
	
_set_bonus_sign:
	ld a,(0xbfbe)
	push af
	;ld a,(0xfff8+:_rom_tileset)				; enable page where _rom_tileset is
	setpage2 $$_rom_tileset
	
	ld	de,0x1C00+16*32+ 8*1
	ld 	hl,_rom_tileset+(32*4+16)*8
	ld	bc,16*256+VDP
1:	push	bc
	call	_set_onetile
	pop	bc
	djnz	1b

	pop  af
	ld (PAGESWAP),a
	;ld a,(bc)
	ret
	
_set_onetile:
	disint
	call	setwrtvram	
	ld	b,0x8 
1:	nop
	outi
	jp nz,1b
	enaint	
	call	add16_de
	ret
	
_set_bonus_sign2:
	ld a,(0xbfbe)
	push af
	;ld a,(0xfff8+:bonus_sign)				; enable page where _rom_tileset is
	setpage2 $$bonus_sign
	
	disint
	ld hl,bonus_sign
	call setbanner
	enaint

	pop  af
	ld (PAGESWAP),a
	;ld a,(bc)
	ret
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
test_1up:
	and	a
	sbc	hl,de
	ret	nc		; if oldscore > 20.000 try next treshold
	add	hl,de	; hl = score
	add	hl,bc	; hl = score + newpts
	and	a
	sbc	hl,de
	ret	c		; if newscore < 20.000 returns
	exx
	ld	a,18	; one up
	call	AFXPLAY
	ld	c,1							; show lives on screen 
	call	add_c_lives_bin
	exx
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	in BC the score to be added
;
add_bc_score_bin:
	ld	hl,(score_bin)
	ld	de,0x4E20	; 20.000 points
	call	test_1up
	ld	hl,(score_bin)
	ld	de,0x9C40	; 40.000 points
	call	test_1up
	ld	hl,(score_bin)
	ld	de,0xEA60	; 60.000 points
	call	test_1up
	
	
	ld	hl,(score_bin)
	add	hl,bc
	ld	(score_bin),hl
	ld	e,l
	ld	d,h
	ld	hl,(score_bin+2)
	ld	bc,0
	adc	hl,bc
	ld	(score_bin+2),hl
	
	ld	bc,score-4
	call	long2ascii
	
	; ld	a,13		; CR
	; ld	(de),a
	
	ld	hl,score
	ld	de,0x1C08+9*32
	jp	print_str

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	in C the lives to be added
add_c_lives_bin:
	ld	a,(lives_bin)
	add	a,c
	jr	1f
sub_c_lives_bin:
	ld	a,(lives_bin)
	sub	c
1:	daa
	ld	(lives_bin),a
	ld	e,a
	ld	hl,lives
	.4	rrca
    and  $0f
	add  a,'0'
	ld	(hl),a
	inc	hl
	ld	a,e
	and  $0f
	add  a,'0'
	ld	(hl),a
	; inc	hl
	; ld	a,13		; CR
	; ld	(hl),a

	ld	hl,lives					; show lives on screen 
	ld	de,0x1C08+8*32
	jp	print_str


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

line1:
	db	"Score ",13
line2:
	db	"00",13
	
	
print_str:
	; in hl = string terminated by 13
	; in de = vram position
1:
	ld	a,(hl)
	cp	13
	ret	z
	call	print
	inc	hl
	ld	a,16
	add	a,e
	ld e,a
	ld a,d
	adc a,0
	ld d,a
	jp	1b
	

	
print:
	; in A = char
	; in de = vram position
	push	hl
	push	de
	push	af

	ld      l, a

	ld a,(0xbfbe)
	push af
	
	;ld a,(0xfff8+:_rom_tileset)		; enable page where _rom_tileset is
	setpage2 $$_rom_tileset


	ld  a, l
		
	add	a,1-'!'
	
	ld	l,a
	ld	h,0
	.3	add hl,hl
	ld	bc,_rom_tileset
	add hl,bc
	
	ld bc,0x0400+VDP
	call	plot_tile

	ld	a,4*32
	add	a,e
	ld e,a
	ld a,d
	adc a,0
	ld d,a

	ld bc,0x0400+VDP
	call	plot_tile

	pop af
	ld (PAGESWAP),a
	;ld a,(bc)		; restore the old page
	
	pop	af
	pop	de
	pop	hl
	ret

	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
paused_string:
	db	" Paused ",13
land_now:
	db	"Land now",13
dummy:
	db	"        ",13
warping:
	db	" Warping",13
defeated:
	db	"Defeated",13
GameOver:
	db	"GameOver",13
levelnames:
	db	"  Zinc  ",13
	db	"  Lead  ",13
	db	" Copper ",13
	db	" Silver ",13
	db	"  Iron  ",13
	db	"  Gold  ",13
	db	"Platinum",13
	db	"Tungsten",13
	db	" Iridon ",13
	db	"Kallisto",13
	db	"TriAlloy",13
	db	"Quadmium",13
	db	"Ergonite",13
	db	"Galactus",13
	db	"Uridium ",13
	
	
print_strf:
	; in hl = string terminated by 13
	; in de = vram position
1:
	ld	a,(hl)
	cp	13
	ret	z
	call	printf
	inc	hl
	ld	a,16
	add	a,e
	ld e,a
	ld a,d
	adc a,0
	ld d,a
	jp	1b

printf:
	; in A = char
	; in de = vram position
	push	hl
	push	de
	push	af


	ld   l, a

	ld   a,(0xbfbe)
	push af
	
	;ld a,(0xfff8+:_rom_tileset)		; enable page where _rom_tileset is
	setpage2 $$_rom_tileset


	ld  a, l
	add	a,1-'!'
	
	ld	l,a
	ld	h,0
	.3	add hl,hl
	ld	bc,_rom_tileset
	add hl,bc
	
	ld bc,0x0800+VDP
	call	plot_tile

	pop af
	ld (PAGESWAP),a
	;ld a,(bc)		; restore the old page

	pop	af
	pop	de
	pop	hl
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
plot_tile:	
	
    disint
	ld	a,e
	out (VDP+1),a
	ld	a,d 
	or	0x40
	out (VDP+1),a
	
	ld	c,VDP
	xor	a

	; outi -> out (c),a: gap reale (fine outi -> out(c),a) misurato a 28 T
	; con 4 nop, sotto il minimo di 29 richiesto dal VDP. Un nop in piu'
	; porta il gap reale a 32 T (il piu' vicino per eccesso, dato che
	; non si puo' aggiungere esattamente 1 T).
1:	outi			; 16 T
	nop				;  4
	nop				;  4
	nop				;  4
	nop				;  4
	nop				;  4	-> nop extra: 28 T -> 32 T
	out (c),a		; 12 T

	; out (c),a -> outi (giro succ.): jp nz(10) + outi(16) = 26 T fissi,
	; sotto il minimo di 29. Un solo nop porta il gap reale a 30 T.
	nop				;  4

	jp nz,1b		; 10 T
    enaint
	
	ret

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IN HL:DE INPUT
; BC POINTS TO OUTPUT

long2ascii:
					; HL = HIGH WORD
	PUSH	DE
	EXX
	POP		HL		; HL' = LOW WORD
	EXX

	LD	E,C
	LD	D,B

	LD	BC,-1000000000/0x10000 -1
	EXX
	LD	BC,-1000000000&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-100000000/0x10000 -1
	EXX
	LD	BC,-100000000&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-10000000/0x10000 -1
	EXX
	LD	BC,-10000000&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-1000000/0x10000 -1
	EXX
	LD	BC,-1000000&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-100000/0x10000 -1
	EXX
	LD	BC,-100000&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-10000/0x10000 -1
	EXX
	LD	BC,-10000&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-1000/0x10000 -1
	EXX
	LD	BC,-1000&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-100/0x10000 -1
	EXX
	LD	BC,-100&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-10/0x10000 -1
	EXX
	LD	BC,-10&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-1/0x10000 -1
	EXX
	LD	BC,-1&0xFFFF
	EXX

NUM1:
	LD	A,'0'-1	 ; '0' IN THE TILESET

1:
	INC A
	EXX
	add HL,BC		; low word
	EXX
	ADC HL,BC		; high word
	jp	C,1b

	EXX
	SBC HL,BC		; low word
	EXX
	SBC HL,BC		; high word

	LD	(DE),A
	INC DE
	RET

	
_plotenergy:
	disint
	ld	de,0x1C00+32
	call	setwrtvram

	ld	hl,_shieldtext
	ld 	bc,3*32*256+VDP
1:	nop
	outi
	jp	nz,1b
	enaint
	
	; plot full energy bar
	
	ld	de,0x1C00+32+32*4+8
	ld	hl,ch1
	call	_decreasenergy.plot

	ld	de,0x1C00+32+32*4+16+8
	ld	hl,ch2
	call	_decreasenergy.plot

	ld	de,0x1C00+32+32*5+8
	ld	hl,ch2
	call	_decreasenergy.plot

	ld	de,0x1C00+32+32*5+16+8
	ld	hl,ch2
	call	_decreasenergy.plot

	ld	de,0x1C00+32+32*6+8
	ld	hl,ch2
	call	_decreasenergy.plot

	ld	de,0x1C00+32+32*6+16+8
	ld	hl,ch3
	call	_decreasenergy.plot
	
	ret

;
	
_decreasenergy:
	; in A = energy level in 0-7
	
	and	7
	jp z,.energy0
	dec a
	jp z,.energy1
	dec a
	jp z,.energy2
	dec a
	jp z,.energy3
	dec a
	jp z,.energy4
	dec a
	jp z,.energy5
	dec a
	jp z,.energy6
	
.energy7:
	ld	de,0x1C08+32*(5+2)+16
	ld	hl,ch3
	jp .plot

.energy6
	ld	de,0x1C08+32*(5+2)+16
	ld	hl,ch4
	jp .plot
	
.energy5
	ld	de,0x1C08+32*(5+2)
	ld	hl,ch5
	call .plot
	ld	de,0x1C08+32*(5+2)+16
	ld	hl,ch6
	jp .plot

.energy4
	ld	de,0x1C08+32*(5+1)+16
	ld	hl,ch5
	call .plot
	ld	de,0x1C08+32*(5+2)
	ld	hl,ch7
	jp .plot

.energy3
	ld	de,0x1C08+32*(5+1)
	ld	hl,ch5
	call .plot
	ld	de,0x1C08+32*(5+1)+16
	ld	hl,ch7
	jp .plot

.energy2
	ld	de,0x1C08+32*(5+0)+16
	ld	hl,ch5
	call .plot
	ld	de,0x1C08+32*(5+1)
	ld	hl,ch7
	jp .plot
	
.energy1
	ld	de,0x1C08+32*(5+0)
	ld	hl,ch8
	call .plot
	ld	de,0x1C08+32*(5+0)+16
	ld	hl,ch7
	jp .plot

.energy0
	ld	de,0x1C08+32*(5+0)
	ld	hl,ch9
	jp .plot
		
.plot:
	disint
	call	setwrtvram

	ld bc,8*256+VDP
1:	nop
	outi
	jp	nz,1b
	enaint
	ret


ch1:	db 0x1f,0x60,0x9f,0xbf,0xbf,0x9f,0x60,0x1f	; headleftfull
ch2:	db 0xff,0x00,0xff,0xff,0xff,0xff,0x00,0xff	; bodyfull
ch3:	db 0xf8,0x06,0xf9,0xfd,0xfd,0xf9,0x06,0xf8	; headrightfull
ch4:	db 0xf8,0x06,0xe1,0xf1,0xf1,0xe1,0x06,0xf8	; headrighthalffull
ch5:	db 0xff,0x00,0xe0,0xf0,0xf0,0xe0,0x00,0xff	; bodyhalffull
ch6:	db 0xf8,0x06,0x01,0x01,0x01,0x01,0x06,0xf8	; headrightempty
ch7:	db 0xff,0x00,0x00,0x00,0x00,0x00,0x00,0xff	; bodyempty
ch8:	db 0x1f,0x60,0x90,0xb8,0xb8,0x90,0x60,0x1f	; headlefthalffull
ch9:	db 0x1f,0x60,0x80,0x80,0x80,0x80,0x60,0x1f	; headleftempty

; _barlevels
; l7:	dw ch1,ch2,ch2,ch2,ch2,ch3
; l6:	dw ch1,ch2,ch2,ch2,ch2,ch4
; l5:	dw ch1,ch2,ch2,ch2,ch5,ch6
; l4:	dw ch1,ch2,ch2,ch5,ch7,ch6
; l3:	dw ch1,ch2,ch5,ch7,ch7,ch6
; l2:	dw ch1,ch5,ch7,ch7,ch7,ch6
; l1:	dw ch8,ch7,ch7,ch7,ch7,ch6
; l0:	dw ch9,ch7,ch7,ch7,ch7,ch6

_shieldtext 
	db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,000h,000h,001h,000h,000h
	db 000h,000h,000h,000h,000h,000h,000h,000h,000h,0F4h,004h,0E7h,014h,0E4h,000h,000h
	db 000h,000h,000h,000h,000h,000h,000h,000h,000h,04Eh,044h,0C4h,044h,04Eh,000h,000h
	db 000h,000h,000h,000h,000h,000h,000h,000h,000h,0FAh,082h,0F2h,082h,0FBh,000h,000h
	db 000h,000h,000h,000h,000h,000h,000h,000h,000h,00Fh,004h,004h,004h,0EFh,000h,000h
	db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,080h,080h,080h,000h,000h,000h
