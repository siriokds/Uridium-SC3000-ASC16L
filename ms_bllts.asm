;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; activate ms bullets
;
max_bullet_rate equ 5

ms_shoot:
	ld	a,(bullet_rate)
	and a
	jp	z,.book_bullet
	dec a
	ld	(bullet_rate),a
	ret

.book_bullet:
	ld	a,max_bullet_rate
	ld	(bullet_rate),a

	ld	ix,ms_bullets
	ld	b,max_bullets
	ld	de,enemy_data
1:	bit	0,(ix+enemy_data.status)
	jr	z,.activate_this
	add ix,de
	djnz   1b
	ret

.activate_this:
;	xor	a				; ms bullet
	ld a, 10
	call AFXPLAY

	ld	a,(ms_state)	; in states 0-3 ms faces right
	and 0x04
	jr	nz,.shootsx
.shootdx
	ld	(ix+enemy_data.status),1
	ld	hl,8
	jp	1f

.shootsx
	ld	(ix+enemy_data.status),1 + 64
	ld	hl,-8
1:
	ld	a,(aniframe)
	and 7
	cp 5
	jr c,2f		; deal with frames 0-4
	neg			
	add a,8		; deal with frames 5-7
	
2:	add a,8
	add a,a
	add a,a
	ld	(ix+enemy_data.frame),a
	ld  c,a				; preserve frame for later
	call	set_size	; set  xoff,yoff,xsize,ysize for sprite collision

	ld	a,(dxmap)
	.2 sra a
	ld	e,a
	rla
	sbc a,a
	ld	d,a

	add hl,de
	ld	(ix+enemy_data.speed),l
	ld	(ix+enemy_data.speed+1),h

	ld	hl,(xship)
	ld	(ix+enemy_data.x),l
	ld	(ix+enemy_data.x+1),h

	ld	a,(yship)
	ld	(ix+enemy_data.y),a
	ld	(ix+enemy_data.cntr),17
	
	; preset data for testing backgroung collisions
	
	ld	b,0				; frame in C
	ld	iy,ms_bllts_col_win-32
	add	iy,bc			; here iy points to the collision window of the current frame of the bullet

	ld  a,(iy+2)				; upper offset
	ld  (ix+enemy_data.dyy),a   ; store it in unused .dyy
	ld  a,(iy+3)				; lower offset
	ld  (ix+enemy_data.dyy+1),a ; store it in unused .dyy+1

	bit	7,(ix+enemy_data.speed+1)
	jp	z,2f			;.x_positive

	;speed<0 
	ld	c,(iy+0)				; left edge
	ld  (ix+enemy_data.fx),c    ; store it in unused .fx
	ret

	;speed>=0 
2:	ld	c,(iy+1)				; right edge
	ld  (ix+enemy_data.fx),c    ; store it in unused .fx
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; manage active ms bullets
;

ms_bullet_loop:
	
	DUP	max_bullets, DUPIDX
	ld	ix,ms_bullets+DUPIDX*enemy_data

	bit	 0,(ix+enemy_data.status)
	jr	z,1f

	; move right or	left

	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	ld	e,(ix+enemy_data.speed)
	ld	d,(ix+enemy_data.speed+1)
	add hl,de
	ld	(ix+enemy_data.x),l
	ld	(ix+enemy_data.x+1),h

	call	.test_obstacles

	dec	(ix+enemy_data.cntr)
	jr	nz,1f
	res 0,(ix+enemy_data.status)
1:

	EDUP
	ret


.test_obstacles
	ld	d,0				; DE is the frame lenght
	ld	e,(ix+enemy_data.fx)
						; HL is already X of the current bullet
	add hl,de			
	ld	a,(ix+enemy_data.y)
	add	a,(ix+enemy_data.dyy)	; upper edge
	and	0xF8			; convert Y at tile resolution
	push af				; HL = X, A = Y
	call 	test_obstacles.meta_tile_peek
						; hl: pointer in level_buffer to meta tile
						; a: meta tile at x,y
	push	hl
	call	.tst_block
	pop 	hl			; save map address in case of a second test
	pop de
	ret	z				; skip the rest if already hit
						; if NZ, HL aims to the MAP
	ld	a,(ix+enemy_data.y)	
	add	a,(ix+enemy_data.dyy+1)	; lower edge
	and	0xF8
	sub d
	ret z				; avoid testing twice the same tile
	cp	8
	jr nz,1f
	ld de,LvlWidth		;read one block lower
	jp 2f
1:	ld de,2*LvlWidth	;read two blocks lower
2:	add	hl,de
	ld	a,(hl)

.tst_block:
	dec	a					; deal with 0 apart (0 == space block)
	cp  nblock+n_d2x1+n_d3x2+n_d2x1 - 1 ; = 41 - 1
	jp  c,.nonvoid			; 
							; MAP>=41 or MAP = 0 void blocks
.ret
	or 1					; obstacle NOT found => return NZ
	ret 
	
.nonvoid			

	sub nblock-1			; blocking range 1..(nblock-1)
	jp	nc,.destructable	; MAP>=21
	
							; MAP<21 hit solid wall
	res 0,(ix+enemy_data.status)
	ld	a,10			
	call AFXPLAY
	xor	a
	ret						; obstacle found => return Z
	
.destructable:
							; bump sane 21->0
	add a,a					; SWITCH()
	ld c,a
	ld b,0
	ex de,hl
	ld hl,.events
	add hl,bc
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	jp (hl) 				; de = map position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	include "tstblock.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_3x2:
	.3 ldi
	ld	bc,LvlWidth-3
	ex de,hl
	add hl,bc
	ex de,hl
	.3 ldi
	ret 

	
plane_sane:
	db 	29,    33,    37
    db 	30,    34,    38
grid_sane:
	db  31,    35,    39
    db  32,    36,    40
plane_dist:	
	db  41,    45,    49
    db	42,    46,    50
grid_dist:
	db  43,    47,    51
    db  44,    48,    52
bump_sane:
	db  21,		23
turr_sane:
	db  22,		24
bump_dist:
	db  25,		27
turr_dist:
	db  26,		28
	