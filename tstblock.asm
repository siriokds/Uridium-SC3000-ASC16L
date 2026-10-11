
		
.events
	dw	.left2x1B		;21 bump left
	dw	.left2x1T		;22 turr left
	dw	.right2x1B		;23 bump right
	dw  .right2x1T		;24 turr right
	dw  .ret			;25
	dw  .ret			;26
	dw  .ret			;27
	dw  .ret			;28
	dw  .left_up3x2P	;29 plane up right
	dw  .left_dw3x2P	;30 plane up right
	dw  .left_up3x2G	;31 grid up right
	dw  .left_dw3x2G	;32 grid up right
	dw  .mid_up3x2P		;33 plane up mid
	dw  .mid_dw3x2P		;34 plane up mid
	dw  .mid_up3x2G		;35 grid up mid
	dw  .mid_dw3x2G		;36 grid up mid
	dw  .right_up3x2P	;37 plane up mid
	dw  .right_dw3x2P	;38 plane up mid
	dw  .right_up3x2G	;39 grid up mid
	dw  .right_dw3x2G	;40 grid up mid


.right2x1B
	dec de
.left2x1B
	ld hl,bump_dist
	.2 ldi
	res 0,(ix+enemy_data.status)
	ld	a,11			; destroy small ground item
	call AFXPLAY
	ld	bc,5			; score for destruction of a small ground item
	call	add_bc_score_bin
	
	call	land_now_test	; make LAND NOW arrive sooner
	xor	a
	ret						; obstacle found => return Z

.right2x1T
	dec de
.left2x1T
	ld hl,turr_dist
	.2 ldi
	res 0,(ix+enemy_data.status)
	ld	a,11			; destroy small ground item
	call AFXPLAY
	ld	bc,5			; score for destruction of a small ground item
	call	add_bc_score_bin
	
	call	land_now_test	; make LAND NOW arrive sooner
	xor	a
	ret						; obstacle found => return Z
	
.right_up3x2P
	dec de
.mid_up3x2P
	dec de
.left_up3x2P
	jp 1f
.right_dw3x2P
	dec de
.mid_dw3x2P
	dec de
.left_dw3x2P
	ld	bc,-LvlWidth
	ex de,hl
	add hl,bc
	ex de,hl
1:	ld hl,plane_dist
	call _3x2

	res 0,(ix+enemy_data.status)
	ld	a,12				; destroy large ground item
	call AFXPLAY
	ld	bc,50				; score for destruction of a large ground item
	call	add_bc_score_bin
	
	call	land_now_test	; make LAND NOW arrive sooner
	xor	a
	ret						; obstacle found => return Z
	

.right_up3x2G
	dec de
.mid_up3x2G
	dec de
.left_up3x2G
	jp 1f
	
.right_dw3x2G
	dec de
.mid_dw3x2G
	dec de
.left_dw3x2G
	ld	bc,-LvlWidth
	ex de,hl
	add hl,bc
	ex de,hl
1:	ld hl,grid_dist
	call _3x2
	
	res 0,(ix+enemy_data.status)
	ld	a,12				; destroy large ground item
	call AFXPLAY
	ld	bc,50				; score for destruction of a large ground item
	call	add_bc_score_bin
	
	call	land_now_test	; make LAND NOW arrive sooner
	xor	a
	ret						; obstacle found => return Z
