	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	ld	de,(xmap)

	bit 6,(ix+enemy_data.status)
	jr  z,.go_right
.go_left:	
	dec	hl
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	and	a
	sbc	hl,de
	ld	bc,-32
	and	a
	sbc	hl,bc
	jp  m,.remove
	jr  1f
	
.go_right:
	inc	hl
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	and	a
	sbc	hl,de
	ld	bc,256+32
	and	a
	sbc	hl,bc
	jp  p,.remove

1:

;;;;;
	ld	a,(ix+enemy_data.y)
	cp (ix+enemy_data.goaly)
	jp  z,1f
	jp  m,.go_dwn
.go_up:
	ld	a,(ix+enemy_data.fy)
	sub (ix+enemy_data.dyy)
	ld	(ix+enemy_data.fy),a

	ld	a,(ix+enemy_data.y)
	sbc a,(ix+enemy_data.dyy+1)
	cp	64-16
	jr	c,.remove
	jr	1f
.go_dwn:
	ld	a,(ix+enemy_data.fy)
	add a,(ix+enemy_data.dyy)
	ld	(ix+enemy_data.fy),a

	ld	a,(ix+enemy_data.y)
	adc a,(ix+enemy_data.dyy+1)
	cp	192
	jr	nc,.remove

1:
	ld	(ix+enemy_data.y),a
	
	call	rand8
	and 	127
	call	z,book_enemy_shoot

	call	test_collision_msbullets
	jp	nc,next
	jp	npcdies
	
.remove:
	ld 	(ix+enemy_data.status),0
	jp	next
