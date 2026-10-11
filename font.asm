

set_font:
	_setvdpwvram 0x0000
	ld	hl, _rom_tileset
	ld	bc, 1024
	call	vdp_copyvram

	_setvdpwvram 0x0800
	ld	hl, _rom_tileset
	ld	bc, 1024
	call	vdp_copyvram

set_font3:
	_setvdpwvram 0x1000
	ld	hl, _rom_tileset
	ld	bc, 1024
	call	vdp_copyvram
	
	ret

