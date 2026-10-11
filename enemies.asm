VOICE_WATCH_YOUR_BACK_ADDR:		equ		_alarm3
VOICE_WATCH_OUT:				equ 	_alarm1
VOICE_ENEMY_APPROACHING:		equ 	_alarm
VOICE_ALARM:					equ		_alarm0
VOICE_SHOOT_OUT:				equ		_alarm2


; Fast random number generator using the same method
; as the CDMA used in cellular telephones
;--------------------------------------------------------------------
; init random seed 

rand8_init:
	LD      HL,(JIFFY)
	SET		0,L
	LD      (randSeed),HL
	RET


; -------------------------------------------------------------------
; rand8
; -------------------------------------------------------------------
;
; choose a random number in the set [0,127] with uniform distribution
; return: A = random value

rand8:
	ld      hl,(randSeed)
	add     hl,hl
	sbc     a,a
	and     083h
	xor     l
	ld      l,a
	ld      (randSeed),hl
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	increase the wave counter
; 	and test for landing permission
	
land_now_test:
	ld	a,(wave_count)
	inc	a
	ld	(wave_count),a
	ld	e,a
	ld  a,(level_goal)
	cp	e				
	ret nz

	ld	hl,land_now
	ld	de,0x1C00+8*3*32
	call	print_strf
	ld	a,-1
	ld	(landing_permission),a
	
	ld hl,_land_now
	ld (_vocadr),hl		        ; ovveride other speech
	;ld	a,14					; Land Now
	;call AFXPLAY
	ret

turret_init:
	ld	a,(cur_level)
	and a
	ret z					; no turrets in the warp zone
	dec a
	ld	l,a
	ld  h,0
	.4	add	hl,hl	;x16

	ld	bc,turrets_initial_pos
	add	hl,bc
	
	ld  b,max_turret		;  initialization for turrets
	ld  ix,enemies
	ld	de,enemy_data
	
1:	ld	a,(hl)
	ld  (ix+enemy_data.y),a
	inc	hl
	inc	hl					; dull byte
	ld	a,(hl)
	ld  (ix+enemy_data.x),a
	inc	hl
	ld	a,(hl)
	ld  (ix+enemy_data.x+1),a
	inc	hl
	
	ld	(ix+enemy_data.color),15
	ld  (ix+enemy_data.status),1	; active
	ld	a,(turret_type)
	ld  (ix+enemy_data.kind),a		; turret type is 8 at easier levels, 3 at insane level
	ld	(ix+enemy_data.frame),13*4	; turret frame
	ld	(ix+enemy_data.cntr),max_bullet_rate*4
	
	ld	(ix+enemy_data.speed),0		; needed for bullets
	ld	(ix+enemy_data.speed+1),0
	
	call	set_size
	add ix,de
	djnz    1b

	ld a,max_turret				; set the numenr of initial turrets
	ld (nturrets),a
	ret
	
turrets_initial_pos:
	include "old/turrets.asm"
	 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; NPC initialization - fake for testing
;
npc_init:
	ld  ix,enemies
	ld  b,max_enem
	ld	de,enemy_data

1:  ld  (ix+enemy_data.status),0
	ld  (ix+enemy_data.kind),255
	ld	(ix+enemy_data.cntr),0
	ld	(ix+enemy_data.y),192
	add ix,de
	djnz    1b

	ld	hl,assault_wave_timer_preset
	ld	(assault_wave_timer),hl
	xor	a
	ld	(wave_count),a
	ld	(landing_permission),a
	
; turn off MS and enemy bullets

bull_init:
	xor a
	ld  (bullet_rate),a

	ld  ix,ms_bullets
	ld  de,enemy_data
	DUP	max_bullets
	ld  (ix+enemy_data.status),a
	ld	(ix+enemy_data.color),15
	add ix,de
	EDUP

	; ld	a,(cur_level)
	; ld	l,a
	; ld	h,0
	; ld	bc,clr_enemy_bullts
	; add	hl,bc
	; ld	b,(hl)
	ld	b,15
	
	xor	a
	ld  ix,enem_bullets
	DUP	max_enem_bullets
	ld  (ix+enemy_data.status),a
	ld	(ix+enemy_data.color),b		; colour for enemy bullets
	add ix,de
	EDUP

	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	timer for wave assaults
;
wave_timer:
	ld	hl,(assault_wave_timer)
	dec	hl
	ld	(assault_wave_timer),hl
	ld	a,h
	or	l
	ret	nz

	if COLECO
	else
	ld	a,1			; wave incoming
	call AFXPLAY
	endif
	
	ld	hl,assault_wave_timer_preset
	ld	a,(cur_level)
	add	a,a
	ld	e,a
	ld	d,0						; at level  1 frequency is: a wave each 2,96 seconds (at 60hz)
	and	a
	sbc	hl,de					; at level 15 frequency is: a wave each 2,5 seconds  (at 60hz)
	ld	(assault_wave_timer),hl	; 180 - 2*cur_level
	
	call	land_now_test
	
	call	rand8
	and	7
	
	jp	z,wave0
	dec	a
	jp	z,wave1
	dec	a
	jp	z,wave2
	dec	a
	jp	z,wave3
	dec	a
	jp	z,wave4
	dec	a
	jp	z,wave5
	dec	a
	jp	z,wave6
	; any other
	jp	  wave7


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	colors for enemies
;
	align 0x100
spritecolors:
	db       15,14, 9, 7
	db        9, 3,14,15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	enemies coming frontally
;	with goal y	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wave0:
	include "wave0.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	enemies coming frontally
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wave1:
	call	front_alarm
	
	call	rand8
	and	15
	ld 	c,a			; Y off set
	exx
	call	rand8
	and	7
	ld	l,a
	ld	h, high spritecolors
	ld	a,(hl)	
	ld	iyl,a		; color
	ld	a,l
	.4	add	a,a

	add	a,64
	ld	b,a			; frame
	
	ld	a,(dxmap)
	and	0x80
	jr	z,.pos
.neg
	ld	de,-64
	ld	c,+1		; enemies going right
	exx	
	ld 	de,1		; enemy speed = 1
	exx
	jr	1f
.pos
	ld	de,256+32
	ld	c,1+64		; enemies going left
	ld	a,4
	add	a,b
	ld	b,a
	exx	
	ld 	de,-1		; enemy speed = -1
	exx
1:
	exx	
	ld	a,64
	add	a,c
	exx		
	
	ld	hl,(xmap)
	add	hl,de

	ld  ix,enemies
	ld	iyh,max_enem
	ld  de,enemy_data
	
1:
	bit	0,(ix+enemy_data.status)
	jr  nz,.next				; this is already active, try the next

	ld  (ix+enemy_data.status),c
	ld	(ix+enemy_data.frame),b

	ld  (ix+enemy_data.kind),1
	exx
	ld	b,iyl
	ld	(ix+enemy_data.color),b
	ld	(ix+enemy_data.speed),e
	ld	(ix+enemy_data.speed+1),d
	exx

	push	bc
	ld bc,16
	add hl,bc 
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	pop	bc
	
	ld  (ix+enemy_data.y),a
	add	a,32
	
	call	set_size

	add ix,de
	dec	iyh			
	ret	z
	cp	191-16
	jr	c,1b
	ret

.next
	add ix,de
	dec	iyh
	ret	z
	jr	1b
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	enemies coming from back
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wave2:
	call back_alarm

	call	rand8
	and	15
	ld 	c,a		; Y off set
	exx

	call	rand8
	and	7
	ld	l,a
	ld	h, high spritecolors
	ld	a,(hl)	
	ld	iyl,a		; color
	
	ld	a,l
	.4	add	a,a

	add	a,64
	ld	b,a			; frame

	exx
	ld	a,(dxmap)
	or	2
	.2 sra a			; de' = player speed 
	ld	e,a
	rla
	sbc a,a
	ld	d,a
	exx

	jr	z,.pos				
.neg
	ld	de,256+32
	ld	c,1+64		; enemies going left
	ld	a,4
	add	a,b
	ld	b,a
	exx	
	dec 	de				; enemy speed = player speed -1
	exx
	jr	1f
.pos
	ld	de,-64
	ld	c,+1		; enemies going right
	exx	
	inc 	de			; enemy speed = player speed +1
	exx
	
1:
	ld	hl,(xmap)
	add	hl,de

	ld  ix,enemies
	ld	a,64
	exx	
	add	a,c			; random offset
	exx	

	ld	iyh,max_enem
	ld  de,enemy_data

1:
	bit	0,(ix+enemy_data.status)
	jr  nz,.next

	ld  (ix+enemy_data.status),c
	ld	(ix+enemy_data.frame),b

	ld  (ix+enemy_data.kind),2

	exx	
	ld	b,iyl
	ld	(ix+enemy_data.color),b
	ld	(ix+enemy_data.speed),e
	ld	(ix+enemy_data.speed+1),d
	exx
	
	push	bc
	ld bc,16
	add hl,bc 
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	pop		bc
	
	ld  (ix+enemy_data.y),a
	add	a,32

	call	set_size

	add ix,de
	dec	iyh
	ret	z
	cp	191-16
	jr	c,1b
	ret

.next
	add ix,de
	dec	iyh
	ret	z
	jr	1b
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; enemy from back
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wave3:
	call	back_alarm
	
	ld	a,(dxmap)
	or	2
	.2 sra a			; de' = player speed 
	ld	e,a
	rla
	sbc a,a
	ld	d,a
	exx

	jr	z,.pos				
.neg
	ld	de,256+32
	ld	bc,256*100+1+64		; enemies going left
	exx	
	dec 	de				; enemy speed = player speed -1
	exx
	jr	1f
.pos
	ld	de,-64
	ld	bc,256*96+1			; enemies going right
	exx	
	inc 	de				; enemy speed = player speed +1
	exx
	
1:
	ld	hl,(xmap)
	add	hl,de

	ld  ix,enemies
	exx
	call	rand8
	exx
	and	15
	add a,16+64				; random Y offset

	ld	iyh,max_enem
	ld  de,enemy_data

1:
	bit	0,(ix+enemy_data.status)
	jr  nz,.next

	ld  (ix+enemy_data.status),c
	ld	(ix+enemy_data.frame),b

	ld  (ix+enemy_data.kind),5
	ld	(ix+enemy_data.color),10
	ld	(ix+enemy_data.cntr),0

	exx	
	ld	(ix+enemy_data.speed),e
	ld	(ix+enemy_data.speed+1),d
	exx
	
	push	bc
	bit	4,a
	ld bc,16
	jr	z,2f
	ld	bc,-16
2:	
	add hl,bc 
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	pop		bc
	
	ld  (ix+enemy_data.y),a
	add	a,24

	call	set_size

	add ix,de
	dec	iyh
	ret	z
	cp	191-16
	jr	c,1b
	ret

.next
	add ix,de
	dec	iyh
	ret	z
	jr	1b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	enemies coming from back
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wave4:
	call	back_alarm

	call	rand8
	and	7
	ld	l,a
	ld	h, high spritecolors
	ld	a,(hl)	
	ld	iyl,a		; color
	
	ld	a,l
	.4	add	a,a

	add	a,64
	ld	b,a			; frame
	
	exx
	ld	a,(dxmap)
	or	2
	.2 sra a			; de' = player speed 
	ld	e,a
	rla
	sbc a,a
	ld	d,a
	exx

	jr	z,.pos				
.neg
	ld	de,256+32
	ld	c,+1+64		; enemies going left
	ld	a,4
	add	a,b
	ld	b,a
	exx	
	dec 	de				; enemy speed = player speed -1
	exx
	jr	1f
.pos
	ld	de,-64
	ld	c,+1		; enemies going right
	exx	
	inc 	de				; enemy speed = player speed +1
	exx
	
1:
	ld	hl,(xmap)
	add	hl,de

	ld  ix,enemies
	exx	
	call	rand8
	exx	
	and	15
	add	a,64			; random offset

	ld	iyh,max_enem
	ld  de,enemy_data

1:
	bit	0,(ix+enemy_data.status)
	jr  nz,.next

	ld  (ix+enemy_data.status),c
	ld	(ix+enemy_data.frame),b

	ld  (ix+enemy_data.kind),4

	exx	
	ld	b,iyl
	ld	(ix+enemy_data.color),b
	ld	(ix+enemy_data.speed),e
	ld	(ix+enemy_data.speed+1),d
	exx
	
	push	bc
	ld bc,16
	add hl,bc 
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	pop		bc
	
	ld  (ix+enemy_data.y),a
	add	a,32

	call	set_size

	add ix,de
	dec	iyh
	ret	z
	cp	191-16
	jr	c,1b
	ret

.next
	add ix,de
	dec	iyh
	ret	z
	jr	1b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; spinning enemy color 11 from back
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wave5:
	call	back_alarm

	call	rand8
	and	15
	ld 	c,a		; Y off set
	
	ld	a,(dxmap)
	or	2
	.2 sra a			; de' = player speed 
	ld	e,a
	rla
	sbc a,a
	ld	d,a
	exx

	jr	z,.pos				
.neg
	ld	de,256+32
	ld	c,+1+64		; enemies going left
	exx	
	dec 	de				; enemy speed = player speed -1
	exx
	jr	1f
.pos
	ld	de,-64
	ld	c,+1		; enemies going right
	exx	
	inc 	de				; enemy speed = player speed +1
	exx
	
1:
	ld	hl,(xmap)
	add	hl,de

	ld  ix,enemies
	ld	a,64
	exx	
	add	a,c			; random offset
	exx	

	ld	iyh,max_enem
	ld  de,enemy_data

1:
	bit	0,(ix+enemy_data.status)
	jr  nz,.next

	ld  (ix+enemy_data.status),c
	; ld	(ix+enemy_data.frame),b
	
	ld  (ix+enemy_data.kind),6

	exx	
	ld	(ix+enemy_data.color),11
	ld	(ix+enemy_data.speed),e
	ld	(ix+enemy_data.speed+1),d
	exx
	
	push	bc
	ld bc,16
	add hl,bc 
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	pop		bc
	
	ld  (ix+enemy_data.y),a
	add	a,32

	call	set_size

	add ix,de
	dec	iyh
	ret	z
	cp	191-16
	jr	c,1b
	ret

.next
	add ix,de
	dec	iyh
	ret	z
	jr	1b


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	enemies coming from back double speed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wave6:
	call	back_alarm

	call	rand8
	and	15
	ld 	c,a		; Y off set
	exx

	call	rand8
	and	7
	ld	l,a
	ld	h, high spritecolors
	ld	a,(hl)	
	ld	iyl,a		; color
	
	ld	a,l
	.4	add	a,a
	
	add	a,64
	ld	b,a			; frame
	exx
	
	ld	a,(dxmap)
	or	2
	.2 sra a			; de' = player speed 
	ld	e,a
	rla
	sbc a,a
	ld	d,a
	exx

	jr	z,.pos				
.neg
	ld	de,256+32
	ld	c,+1+64		; enemies going left
	ld	a,4
	add	a,b
	ld	b,a
	exx	
	dec 	de				; enemy speed = player speed -2
	dec 	de				
	exx
	jr	1f
.pos
	ld	de,-64
	ld	c,+1		; enemies going right
	exx	
	inc 	de				; enemy speed = player speed +2
	inc 	de				
	exx
	
1:
	ld	hl,(xmap)
	add	hl,de

	ld  ix,enemies
	ld	a,64
	exx	
	add	a,c			; random offset
	bit	0,c
	exx	
	jr	z,1f		; randomize initial Y direction
	set	7,c
	jr	2f
1:	res	7,c
2:
	ld	iyh,max_enem
	ld  de,enemy_data

1:
	bit	0,(ix+enemy_data.status)
	jr  nz,.next

	ld  (ix+enemy_data.status),c
	ld	(ix+enemy_data.frame),b

	ld  (ix+enemy_data.kind),4

	exx	
	ld	b,iyl
	ld	(ix+enemy_data.color),b
	ld	(ix+enemy_data.speed),e
	ld	(ix+enemy_data.speed+1),d
	exx
	
	push	bc
	ld bc,16
	add hl,bc 
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	pop		bc
	
	ld  (ix+enemy_data.y),a
	add	a,32

	call	set_size

	add ix,de
	dec	iyh
	ret	z
	cp	191-16
	jr	c,1b
	ret

.next
	add ix,de
	dec	iyh
	ret	z
	jr	1b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	spinning enemy color 7 from back
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wave7:
	call	back_alarm

	call	rand8
	and	15
	ld 	c,a			; Y off set
	ld	a,(dxmap)
	or	2
	.2 sra a			; de' = player speed 
	ld	e,a
	rla
	sbc a,a
	ld	d,a
	exx

	jr	z,.pos				
.neg
	ld	de,256+32
	ld	c,1+64				; enemies going left
	exx	
	dec 	de				; enemy speed = player speed -1
	exx
	jr	1f
.pos
	ld	de,-64
	ld	c,+1		; enemies going right
	exx	
	inc 	de				; enemy speed = player speed +1
	exx
	
1:
	ld	hl,(xmap)
	add	hl,de

	ld  ix,enemies
	ld	a,64
	exx	
	add	a,c			; random offset
	exx	

	ld	iyh,max_enem
	ld  de,enemy_data

1:
	bit	0,(ix+enemy_data.status)
	jr  nz,.next

	ld  (ix+enemy_data.status),c
	; ld	(ix+enemy_data.frame),b	; dummy

	ld  (ix+enemy_data.kind),7

	exx	
	ld	(ix+enemy_data.color),7
	ld	(ix+enemy_data.speed),e
	ld	(ix+enemy_data.speed+1),d
	exx
	
	push	bc
	ld bc,16
	add hl,bc 
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	pop		bc
	
	ld  (ix+enemy_data.y),a
	add	a,32

	call	set_size

	add ix,de
	dec	iyh
	ret	z
	cp	191-16
	jr	c,1b
	ret

.next
	add ix,de
	dec	iyh
	ret	z
	jr	1b

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   logic for enemies -  fake for testing
;

npc_loop:
	ld  ix,enemies
	ld  b,max_enem

1:	push	bc
	ld  a,(ix+enemy_data.status)
	and 1
	jr  z,next

	ld	a,(ix+enemy_data.kind)
	and	a
	jp	z,enemy0
	dec a	;cp	1
	jp	z,enemy1
	dec a	;cp	2
	jp 	z,enemy2
	dec a	;cp	3
	jp 	z,enemy3
	dec a	;cp	4
	jp 	z,enemy4
	dec a	;cp	5
	jp 	z,enemy5
	dec a	;cp	6
	jp 	z,enemy6
	dec a	;cp	7
	jp 	z,enemy7
	dec a	;cp	8
	jp 	z,enemy_turret

	cp	255-8
	jp z,enemy255

next:
	pop	bc
	ld  de,enemy_data
	add ix,de
	djnz    1b
	ret
;;;;;;;;;;;;;;;;;;;;
npcdies:
	ld  (iy+enemy_data.status),0	; turn off this bullet

	ld	(ix+enemy_data.color),10	; start explosion
	ld	(ix+enemy_data.kind),255
	ld	(ix+enemy_data.cntr),2
	ld	(ix+enemy_data.frame),12

	call	rand8
	and	3
	add	a,2			; random enemy explosion
	call AFXPLAY

	ld	bc,100		; score for destruction of a flying enemy
	call	add_bc_score_bin
	jp	next
	
;;;;;;;;;;;;;;;;;;;;
; explosion
;;;;;;;;;;;;;;;;;;;;
enemy255:
	dec	(ix+enemy_data.cntr)
	jp	nz,next
	ld	(ix+enemy_data.cntr),2
	inc	(ix+enemy_data.frame)
	ld	a,(ix+enemy_data.frame)
	cp	16
	jr	c,next
	ld	(ix+enemy_data.color),8		; start explosion
	cp	23+8
	jp	nz,next
	ld	(ix+enemy_data.status),0
	jp	next

;;;;;;;;;;;;;;;;;;;;
	; metatile 0x18
enemy_turret:

	; avoid shooting from outside the screen	
	ld	b,0
	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	ld 	c,(ix+enemy_data.xoff)
	add hl,bc
	ld 	b,(ix+enemy_data.xsize)
	
	ld	de,(xmap)
	ld 	c,255
	call	CalcCollision
	jp		nc,next

	dec	(ix+enemy_data.cntr)
	jr 	nz,.no_bullet
	
	ld	(ix+enemy_data.cntr),max_bullet_rate*4
	
	call	rand8
	and 	3
	jr		nz,.no_bullet

	;ld hl,(0xbfbe)
	;push hl
	;LD A,(0xFFF8+:book_directional_shoot)
	
	ld a, (0xbfbe)
	push af
	setpage2 $$book_directional_shoot
	
	call	book_directional_shoot
	;pop hl
	;ld a,(hl)
	pop af
	ld (PAGESWAP),a

.no_bullet	
	call	test_collision_msbullets
	jp	nc,next
	
	ld a,(nturrets)
	dec a
	ld (nturrets),a
	jp	nz,npcdies
	
	ld 		hl,_syren		
	call	_vocset	
	ld hl,bannertime		; 3 seconds
	ld (bannertimer),hl

	ld	bc,2000			; score for destruction of all turrets
	call	add_bc_score_bin
	
	jp	npcdies

;;;;;;;;;;;;;;;;;;;;
enemy0:
	include "enemy0.asm"
;;;;;;;;;;;;;;;;;;;;
enemy1:
	bit 6,(ix+enemy_data.status)
	jr  z,.go_right
.go_left:

	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	dec	hl
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	ld	de,(xmap)
	and	a
	sbc	hl,de
	ld	de,-32
	and	a
	sbc	hl,de
	jp  p,1f
	ld	(ix+enemy_data.status),0
	jp	next

.go_right:

	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	inc	hl
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	ld	de,(xmap)
	and	a
	sbc	hl,de
	ld	de,256+32
	and	a
	sbc	hl,de
	jp  m,1f
	ld	(ix+enemy_data.status),0
	jp	next
1:

	call	rand8
	and 	127
	call	z,book_enemy_shoot

	call	test_collision_msbullets
	jp	nc,next
	jp	npcdies

;;;;;;;;;;;;;;;;;;;;
enemy2:
	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	ld	e,(ix+enemy_data.speed)
	ld	d,(ix+enemy_data.speed+1)
	add	hl,de
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	
	bit 6,(ix+enemy_data.status)
	jr  z,.go_right
.go_left:

	ld	de,(xmap)
	and	a
	sbc	hl,de
	ld	de,-32
	and	a
	sbc	hl,de
	jp  p,1f
	ld	(ix+enemy_data.status),0
	jp	next

.go_right:

	ld	de,(xmap)
	and	a
	sbc	hl,de
	ld	de,256+32
	and	a
	sbc	hl,de
	jp  m,1f
	ld	(ix+enemy_data.status),0
	jp	next
1:

	call	rand8
	and 	127
	call	z,book_enemy_shoot

	call	test_collision_msbullets
	jp	nc,next
	jp 	npcdies
	
;;;;;;;;;;;;;;;;;;;;
enemy3:
	ld a,(0xbfbe)
	push af
	
	;LD A,(0xFFF8+:_enemy3)
	setpage2 $$_enemy3
	jp	_enemy3

enemy3.npcdies:
	pop af
	ld (PAGESWAP),a

;	pop hl
	;ld a,(hl)
	jp	npcdies
enemy3.next:
	pop af
	ld (PAGESWAP),a
;	pop hl
;	ld a,(hl)
	jp	next

;;;;;;;;;;;;;;;;;;;;
enemy4:
	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	ld	e,(ix+enemy_data.speed)
	ld	d,(ix+enemy_data.speed+1)
	add	hl,de
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	
	bit 6,(ix+enemy_data.status)
	jr  z,.go_right
.go_left:

	ld	de,(xmap)
	and	a
	sbc	hl,de
	ld	de,-32
	and	a
	sbc	hl,de
	jp  p,1f
	ld	(ix+enemy_data.status),0
	jp	next

.go_right:

	ld	de,(xmap)
	and	a
	sbc	hl,de
	ld	de,256+32
	and	a
	sbc	hl,de
	jp  m,1f
	ld	(ix+enemy_data.status),0
	jp	next
1:

	ld	a,(ix+enemy_data.y)

	bit 7,(ix+enemy_data.status)
	jr  z,.go_dwn
.go_up:
	dec	a
	cp	64
	jr	nz,1f
	res	7,(ix+enemy_data.status)
	jr	1f
.go_dwn:
	inc	a
	cp	191-16
	jr	nz,1f
	set	7,(ix+enemy_data.status)
	; jr	1f
1:
	ld	(ix+enemy_data.y),a

	call	rand8
	and 	127
	call	z,book_enemy_shoot

	call	test_collision_msbullets
	jp	nc,next
	jp 	npcdies
	
	
;;;;;;;;;;;;;;;;;;;;
	align 0x100
rotation:
	db 0,16,32,48,48,32,16,0
;;;;;;;;;;
rotate:
	ld	a,(ix+enemy_data.cntr)
	inc a
	ld	(ix+enemy_data.cntr),a
	exx
	ld h, high rotation
	.2	rrca
	and 7
	ld	l,a
	ld a,(hl)
	exx
	ret
	

	align 0x100
sinewave:
	db 2,1,2,1,2,1,1,1,1,1,1,1,0,1,0,0,0,0,-1,0,-1,-1,-1,-1,-1,-1,-1,-2,-1,-2,-1,-2,-2,-1,-2,-1,-2,-1,-1,-1,-1,-1,-1,-1,0,-1,0,0,0,0,1,0,1,1,1,1,1,1,1,2,1,2,1,2

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;
enemy5:
	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	ld	e,(ix+enemy_data.speed)
	ld	d,(ix+enemy_data.speed+1)
	add	hl,de
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	
	bit 6,(ix+enemy_data.status)
	jr  z,.go_right
.go_left:

	ld	de,(xmap)
	and	a
	sbc	hl,de
	ld	de,-32
	and	a
	sbc	hl,de
	jp  p,1f
	ld	(ix+enemy_data.status),0
	jp	next

.go_right:

	ld	de,(xmap)
	and	a
	sbc	hl,de
	ld	de,256+32
	and	a
	sbc	hl,de
	jp  m,1f
	ld	(ix+enemy_data.status),0
	jp	next
1:

	ld	a,(ix+enemy_data.cntr)
	inc	a
	ld	(ix+enemy_data.cntr),a
	and	63
	ld	l,a
	ld	h,high sinewave
	ld	a,(hl)
	add	a,(ix+enemy_data.y)
	ld	(ix+enemy_data.y),a
	
	call	rand8
	and		a
	call	z,book_enemy_shoot

	call	test_collision_msbullets
	jp	nc,next
	jp 	npcdies


;;;;;;;;;;;;;;;;;;;;;;;;;;;
enemy6:
	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	ld	e,(ix+enemy_data.speed)
	ld	d,(ix+enemy_data.speed+1)
	add	hl,de
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	
	bit 6,(ix+enemy_data.status)
	jr  z,.go_right
.go_left:
	call	rotate
	add	a,192+4
	ld	(ix+enemy_data.frame),a
	
	ld	de,(xmap)
	and	a
	sbc	hl,de
	ld	de,-32
	and	a
	sbc	hl,de
	jp  p,1f
	ld	(ix+enemy_data.status),0
	jp	next

.go_right:
	call	rotate
	add	a,192
	ld	(ix+enemy_data.frame),a

	ld	de,(xmap)
	and	a
	sbc	hl,de
	ld	de,256+32
	and	a
	sbc	hl,de
	jp  m,1f
	ld	(ix+enemy_data.status),0
	jp	next
1:
	call	set_size	; size varies with frame
		
	ld	a,(ix+enemy_data.y)

	bit 7,(ix+enemy_data.status)
	jr  z,.go_dwn
.go_up:
	dec	a
	cp	64
	jr	nz,1f
	res	7,(ix+enemy_data.status)
	jr	1f
.go_dwn:
	inc	a
	cp	191-16
	jr	nz,1f
	set	7,(ix+enemy_data.status)
	; jr	1f
1:
	ld	(ix+enemy_data.y),a

	call	rand8
	and 	127
	call	z,book_enemy_shoot

	call	test_collision_msbullets
	jp	nc,next
	jp	npcdies
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;
enemy7:	
	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	ld	e,(ix+enemy_data.speed)
	ld	d,(ix+enemy_data.speed+1)
	add	hl,de
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	
	bit 6,(ix+enemy_data.status)
	jr  z,.go_right
.go_left:
	call	rotate
	add	a,192+4
	ld	(ix+enemy_data.frame),a

	ld	de,(xmap)
	and	a
	sbc	hl,de
	ld	de,-32
	and	a
	sbc	hl,de
	jp  p,1f
	ld	(ix+enemy_data.status),0
	jp	next

.go_right:
	call	rotate
	add	a,192
	ld	(ix+enemy_data.frame),a
	
	ld	de,(xmap)
	and	a
	sbc	hl,de
	ld	de,256+32
	and	a
	sbc	hl,de
	jp  m,1f
	ld	(ix+enemy_data.status),0
	jp	next
1:
	call	set_size	; size varies with frames

	ld	a,(ix+enemy_data.y)

	bit 7,(ix+enemy_data.status)
	jr  z,.go_dwn
.go_up:
	dec	a
	cp	64
	jr	nz,1f
	res	7,(ix+enemy_data.status)
	jr	1f
.go_dwn:
	inc	a
	cp	191-16
	jr	nz,1f
	set	7,(ix+enemy_data.status)
	; jr	1f
1:
	ld	(ix+enemy_data.y),a

	call	rand8
	and 	127
	call	z,book_enemy_shoot

	call	test_collision_msbullets
	jp	nc,next
	jp 	npcdies


; in
;	IX -> enemy ship
; out
;	active bullet in list enem_bullets

book_enemy_shoot:
	; aim to the manta
	ld	c,32
	ld	e,c
	ld	a,(yship)
	ld	b,a
	ld	d,(ix+enemy_data.y)
	call	CollisionCheck_8b
	ret		nc

	; avoid shooting from outside the screen	
	ld	b,0
	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	ld 	c,(ix+enemy_data.xoff)
	add hl,bc
	ld 	b,(ix+enemy_data.xsize)
	
	ld	de,(xmap)
	ld 	c,255
	call	CalcCollision
	ret		nc
	
	ld  iy,enem_bullets
	ld  de,enemy_data
	
	DUP	max_enem_bullets

	bit	0,(iy+enemy_data.status)
	jr  z,.activate_this
	add iy,de

	EDUP
	ret

.activate_this:
	ld	l,(ix+enemy_data.speed)
	ld	h,(ix+enemy_data.speed+1)

	bit 6,(ix+enemy_data.status)
	jr  nz,.shootsx
.shootdx
	ld  (iy+enemy_data.status),1
	.(enemy_bullet_speed)	inc hl
	jp  1f

.shootsx
	ld  (iy+enemy_data.status),1 + 64
	.(enemy_bullet_speed)	dec hl
	
1:
	ld  (iy+enemy_data.speed),l
	ld  (iy+enemy_data.speed+1),h

	xor	a
	ld	(iy+enemy_data.dxx),a
	ld	(iy+enemy_data.dxx+1),a
	ld	(iy+enemy_data.dyy),a
	ld	(iy+enemy_data.dyy+1),a
	
	ld	a,(ix+enemy_data.frame)
	.2	rra					; divide by 4
	and 63
	sub	13			; turret frame
	ld	l,a
	ld	h,0
	ld	bc,bull_frame
	add hl,bc
	ld  a,(hl)			; bullet bype depends on enemy ship
	ld  (iy+enemy_data.frame),a

	call	set_size2	; set  xoff,yoff,xsize,ysize for sprite collision

	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	ld  (iy+enemy_data.x),l
	ld  (iy+enemy_data.x+1),h

	ld  a,(ix+enemy_data.y)
	ld  (iy+enemy_data.y),a
	ld  (iy+enemy_data.cntr),(256+32+24)/enemy_bullet_speed

	; ld  (iy+enemy_data.color),11
	
	ld a,8			; enemy shoot
	call AFXPLAY
	ret

bull_frame:
	db 							14*4,14*4,14*4
	db  8*4, 8*4, 8*4, 8*4,14*4,14*4,14*4,14*4
	db  8*4, 8*4, 8*4, 8*4,12*4,12*4,12*4,12*4
	db 12*4,12*4,12*4,12*4, 8*4, 8*4, 8*4, 8*4
	db  8*4, 8*4, 8*4, 8*4, 8*4, 8*4, 8*4, 8*4
	db 12*4,12*4,12*4,12*4,12*4,12*4,12*4,12*4
	db 12*4,12*4,12*4,12*4,12*4,12*4,12*4,12*4
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; manage active enemy bullets
;

	struct ms_size
minx	db 	0
maxx	db	0
miny 	db	0
maxy	db	0
	ends

enemy_bullet_loop:

	ld	hl,ms_ani
	ld  a,(aniframe)
	ld	c,a
	ld	b,0
	add	hl,bc
	ld	a,(hl)
	.2	add	a,a
	ld	iy,ms_col_win
	ld	c,a
	ld	b,0
	add	iy,bc	
	; iy aims to MS size for current frame
	; iy -> [minx(h) maxx(h) miny(h) maxy(h)]

	ld  ix,enem_bullets
	ld  de,enemy_data
	DUP	max_enem_bullets
	exx
	bit  0,(ix+enemy_data.status)
	jp  z,1f

	ld  l,(ix+enemy_data.x)
	ld  h,(ix+enemy_data.x+1)
	ld  e,(ix+enemy_data.speed)
	ld  d,(ix+enemy_data.speed+1)
	add hl,de						; move right or  left
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	
	ld  l,(ix+enemy_data.fx)		; move in any direction
	ld  h,(ix+enemy_data.x)
	ld  e,(ix+enemy_data.dxx)
	ld  d,(ix+enemy_data.dxx+1)
	ld 	a,d
	rla
	sbc a,a		; a = 0 or -1 according to sign of de
	add	hl,de
	adc	a,(ix+enemy_data.x+1)
	ld  (ix+enemy_data.fx),l
	ld  (ix+enemy_data.x),h
	ld	(ix+enemy_data.x+1),a

	ld  l,(ix+enemy_data.fy)
	ld  h,(ix+enemy_data.y)
	ld  e,(ix+enemy_data.dyy)
	ld  d,(ix+enemy_data.dyy+1)
	add	hl,de
	ld  (ix+enemy_data.fy),l
	ld  (ix+enemy_data.y),h
	ld	a,h
	sub	64-16
	cp	192-(64-16)
	jr	nc,4f					;	bullet out of the screen
	
	ld	a,(ms_state)			; MS is immune to bullets while looping
	cp	ms_loop_right2left
	jr	z,3f
	cp	ms_loop_left2right
	jr	z,3f

	ld	a,(god_mode)
	and 	a						
	call	z,test_collision_enemy_bullets
	jp	nc,3f

	res 0,(ix+enemy_data.status)	; turn off this bullet
	
	ld	a,3				; small explosion
	call AFXPLAY

	
	ld a,(shieldlevel+1)
	and a
	jp	z,test_obstacles.found		; start ms explosion if shield is depleted
	
	ld a,(shieldlevel+1)			; decrease ms shield
	dec a
	ld (shieldlevel+1),a

	call _decreasenergy				; in A the energy level 
	ret

3:
	dec	(ix+enemy_data.cntr)
	jp  nz,1f
4:	res 0,(ix+enemy_data.status)	; turn off this bullet
1:
	exx
	add ix,de
	EDUP
	ret


front_alarm:
	call	rand8
	and 	3
	
	dec		a
	jr		nz,1f

	ld 		hl, VOICE_ENEMY_APPROACHING		; enemy_approaching
	jp 		_vocset
	
1:	dec		a
	jr		nz,1f
	ld 		hl, VOICE_ALARM					; alarm
	jp 		_vocset	
	
1:	dec		a
	jr		nz,1f
	ld 		hl, VOICE_WATCH_OUT				; watch_out
	jp 		_vocset	
	
1:	ld 		hl, VOICE_SHOOT_OUT				; shoot_up
	jp 		_vocset	

back_alarm:
	call	rand8
	and 	3
	
	dec		a
	jr		nz, 1f
	ld 		hl, VOICE_ENEMY_APPROACHING		; enemy_approaching
	jp 		_vocset
	
1:	dec		a
	jr		nz, 1f
	
	
	ld 		hl,VOICE_ENEMY_APPROACHING;VOICE_WATCH_YOUR_BACK_ADDR	; watch_your_back
	jp 		_vocset	
	
1:	dec		a
	jr		nz, 1f
	ld 		hl, VOICE_WATCH_OUT				; watch_out
	jp 		_vocset	
	
1:	ld 		hl, VOICE_WATCH_YOUR_BACK_ADDR	; watch_your_back
;1:	ld 		hl, 0							; watch_out
	jp 		_vocset	

