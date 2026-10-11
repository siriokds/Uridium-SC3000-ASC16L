
	ld	l,(ix+enemy_data.x)		;	if the enemy out of the screen skip the enemy
	ld	h,(ix+enemy_data.x+1)
	ld	de,(xmap)
	and	a
	sbc	hl,de				; xrel in hl
	ld	bc,-32
	and	a
	sbc	hl,bc
	jp  m,enemy3.next		; if xrel<-32
	add	hl,bc
	ld	bc,256+32
	and	a
	sbc	hl,bc
	jp  p,enemy3.next		; or xrel>256+32 skip the enemy

	; ld	a,(ix+enemy_data.y)
	; sub	64-16
	; cp	192-(64-16)
	; jp	nc,enemy3.next	; test Up/Down borders


	ld	a,(ix+enemy_data.angle)
	call getsincos

	ld	(ix+enemy_data.dxx),e
	ld	(ix+enemy_data.dxx+1),d
	
	ld	(ix+enemy_data.dyy),c
	ld	(ix+enemy_data.dyy+1),b
	
	ld	l,(ix+enemy_data.fx)		; x_enemy is 24 bit 
	ld	h,(ix+enemy_data.x)
	ld  e,(ix+enemy_data.dxx)		; speed is 16 bit
	ld  d,(ix+enemy_data.dxx+1)
	ld  a,d
	rla
	sbc	a,a
	add	hl,de
	adc	a,(ix+enemy_data.x+1)
	ld  (ix+enemy_data.fx),l
	ld  (ix+enemy_data.x),h
	ld	(ix+enemy_data.x+1),a
	
	
	ld	l,(ix+enemy_data.fy)
	ld	h,(ix+enemy_data.y)
	ld  e,(ix+enemy_data.dyy)
	ld  d,(ix+enemy_data.dyy+1)
	add	hl,de
	ld  (ix+enemy_data.fy),l
	ld  (ix+enemy_data.y),h

;;;;;

	ld	hl,(xship)
	ld	e,(ix+enemy_data.x)
	ld	d,(ix+enemy_data.x+1)
	and	a
	sbc	hl,de
	sra h
	rr  l
	ld b,l								; range -256,255

	ld a,(yship)
	sub (ix+enemy_data.y)
	sra a
	ld  c,a								; range -256,255
	
	call	atan2						; a = angle in 0-255
	
	sub (ix+enemy_data.angle)
	jp	p,.lesstahn180
.morethan180
	.2	dec	(ix+enemy_data.angle)
	jp 1f
.lesstahn180
	.2	inc	(ix+enemy_data.angle)
1:
	
;;;;;
	
	dec	(ix+enemy_data.cntr)
	jr 	nz,.no_bullet
	
	ld	(ix+enemy_data.cntr),max_bullet_rate*4
	call	rand8
	and 	3
	jr		nz,.no_bullet

	call	book_directional_shoot

.no_bullet

	call	test_collision_msbullets
	jp	nc,enemy3.next
	
	ld a,(nturrets)
	dec a
	ld (nturrets),a
	jp	nz,enemy3.npcdies

	ld 		hl,_syren		
	call	_vocset	
	ld hl,bannertime		; 3 seconds
	ld (bannertimer),hl

	ld	bc,2000				; score for destruction of all turrets
	call	add_bc_score_bin
		
	jp	enemy3.npcdies
	
; .remove:
	; ld 	(ix+enemy_data.status),0
	; jp	enemy3.next
