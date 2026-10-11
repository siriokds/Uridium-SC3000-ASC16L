

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	load sprites in vram

sprite_init:
    ;LD A,(0xFFF8+:normal_sprites_spt)
	setpage2 $$normal_sprites_spt
	ld	a,(sprite_3c)
	and	a
	ld	hl,normal_sprites_spt	
	jr	z,1f
	ld	hl,ennanched_sprites_spt_3c
1:	ld	de,level_buffer
	call	mom_depack_rom
	;ld a,(0xfff8+:endpage2)
	setpage2 $$endpage2
	
	halt
	disint
	ld	hl,level_buffer
	_setvdpwvram 0x3800
	call	write_256
	
	_setvdpwvram (0x1800+60*32)		; at 0x1F80
	ld	b,32*4						; fake sat for screen split
	; xor a / out / djnz = 28 T, sotto il minimo di 29 richiesto dal VDP
	;1:	xor a
	;	out	(VDP),a
	;	djnz	1b
1:	xor a		;  4 T
	out	(VDP),a	; 11 T
	dec	b		;  4 T
	jp	nz,1b	; 10 T	-> 29 T esatti
	enaint

	halt
	disint
	_setvdpwvram 0x1B80				 ; sprites in the score bar
	ld	hl,scorebar_sat
	ld	bc,0x8000+VDP
	otir

	ld	hl,line1
	ld	de,0x1C08+32
	call	print_str
		
	; call	_plotenergy
	
	ld	hl,0
	ld	(score_bin),hl
	ld	(score_bin+2),hl

	ld	a,7
	ld	(lives_bin),a

	ld	hl,lives
	ld	de,lives+1
	ld	(hl),13
	ld	bc,14-1				; lives and score are strings in ram
	ldir

    disint
	;	set Manta icon (its upper part is used as screen split placeholder)

	ld a,(0xbfbe)
	push af
	;ld a,(0xfff8+:_rom_tileset)			; enable page where _rom_tileset is
	setpage2 $$_rom_tileset

	_setvdpwvram  0x1C00
	ld	b,8						; placeholder for screen split

1:	ld a,-1	
	out	(VDP),a						
	djnz	1b
	
	; _setvdpwvram  0x1C08
	ld	hl,_rom_tileset+110*8
	ld	bc,0x800+VDP
	otir
	; _setvdpwvram  (0x1C08+16)

	ld	b,8						; placeholder for screen split
1:	ld a,-1	
	out	(VDP),a						
	djnz	1b

	ld	b,0x8
	otir

	_setvdpwvram  (0x1C08+4*32)
	ld	b,0x8
	otir
	_setvdpwvram  (0x1C08+4*32+16)
	ld	b,0x8
	otir

	pop af
	ld (PAGESWAP),a
	;pop bc
	;ld a,(bc)				; restore the old page

	call _set_uridium_sign	; set Uridium sign	

;;;;;;;;;;;;;;;;;;;
	

	xor a
	ld	(reverse_sat),a

	ld	hl,ram_sat
	ld	de,ram_sat+1
	ld	bc,127
	ld	(hl),a
	ldir

	ret

set_level_name:	
	ld	a,(cur_level)
	dec	a
	ld	l,a
	ld	h,0
	ld	e,l
	ld	d,h

	.3	add	hl,hl
	add	hl,de
	
	ld	de,levelnames
	add	hl,de
	ld	de,0x1C00+8*3*32
	call	print_strf
	
	xor    a
	ld     (insequence), a

	ret


draw_paused:	
	ld	hl, paused_string
	ld	de, 0x1C00+8*3*32
	call	print_strf
	ret
