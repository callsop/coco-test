*
* mmu bit test v1.04 - Craig Allsop 19/7/2026
*
* The following test attempts to write into the MMU registers
* and compare what was written with a CMP. There are 3 variations
* of the same test. Each variation has two parts, firstly it
* writes values <= $3F as MMU registers normally only support
* reading of the lower 6 bits (to support 512k). The values are:
*
* $1A,$25,$0F,$30,$35,$3A
*
* The second group of values tests values >= $40, which would apply to
* machine with 2MB installed. The values are:
*
* $85,$80,$C0,$65,$4A,$1E
*
* The 3 variations mirror the following routines:
*
* 1,2: CMP/BNE - tests bit 6&7 clear as used by LOADM.
* 3,4: CMP/JMP - tests bit 6 set as used by PEEK.
* 5,6: CMP/BSR - tests bit 7 set, thrown in for good measure.
*
* The expected results are:
*
* 1.CMP/BNE($26) 1A250F30353A OK
*
* This row should always result in an OK meaning all values written are
* read back the same, no matter how much memory the machine has.
* This mirrors what the disk basic LOADM uses.
*
* The rest of the tests will return a result that is different
* than what was written. For a 128k/512k coco3, they should be as
* follows:
*
* 2.CMP/BNE($26) 85 GOT:05
* 3.CMP/JMP($7E) 1A GOT:5A
* 4.CMP/JMP($7E) 85 GOT:45
* 5.CMP/BSR($8D) 1A GOT:9A
* 6.CMP/BSR($8D) 8580C0 GOT:80
*
* For a 2mb coco3, all these tests may return OK given the
* upper bits should be valid, although its possible some hardware
* may choose not to support reading back those upper bits despite
* having 2mb.
*
* v1.00 - documentation added
*

SCREEN	equ	$400

	org	$2000
start:
	ldd	#$2020		; clear the screen
	ldx	#SCREEN
clear:
	std	,x++
	cmpx	#SCREEN+$200
	bne	clear


	ldx	#SCREEN		; show title message
	ldy	#msg
	jsr	>showmsg

	leax	-5,x
	pshs	x
	ldu	#start		; program check
	ldx	#last-start
	ldd	#$beef
	jsr	>crc16
	puls	x
	jsr	>printhexd

	jsr	>crlf
	jsr	>crlf

	lda	#%11000000	; coco3 mode, mmu, no interrupt to cpu
	sta	>$ff90

	ldy	#testa		; show test a message (CMP/BNE)
	jsr	>showmsg
	jsr	>crlf

	ldy	#msg1		; run test #1
	ldu	#msg1d
	jsr	>test

	ldy	#msg2		; run test #2
	ldu	#msg2d
	jsr	>test

	ldu	#test2		; switch to test2 function (CMP/JMP)
	stu	>func+1
	ldu	#test2a
	stu	>func2+1

	jsr	>crlf		; show test b message
	ldy	#testb
	jsr	>showmsg
	jsr	>crlf

	ldy	#msg3		; run test #3
	ldu	#msg3d
	jsr	>test

	ldy	#msg4		; run test #4
	ldu	#msg4d
	jsr	>test

	ldu	#test3		; switch to test3 function (CMP/BSR)
	stu	>func+1
	ldu	#test3a
	stu	>func2+1

	jsr	>crlf		; show test c message
	ldy	#testc
	jsr	>showmsg
	jsr	>crlf

	ldy	#msg5		; run test #5
	ldu	#msg5d
	jsr	>test

	ldy	#msg6		; run test #6
	ldu	#msg6d
	jsr	>test

	jsr	>crlf		; done message
	ldy	#done
	jsr	>showmsg

stop:	jmp	>stop		; wait forever


test:
	jsr	>showmsg
	clra
	sta	,-s
@read:	lda	,u+
	beq	@testloop
	sta	,-s
	bra	@read
@testloop:
	ldu	#$ffa2
@lp:
	lda	,s+
	beq	@ok
	jsr	>printhex
func:	jsr	>test1
	bne	@bad
	bra	@lp
@bad:	ldb	,s+
	bne	@bad
	ldy	#bad
	jsr	>showmsg
func2:	jsr	>test1a
	jsr	>printhex
	jmp	>@finish
@ok:
	ldy	#ok
	jsr	>showmsg
@finish:
	jsr	>crlf
	rts

	include	"printhex.asm"
	include "crc16.asm"

showmsg:			; show message text
	pshs	a,b
@lp:
	lda	,y+
	beq	@c
	anda	#~$40
	sta	,x+
	bra	@lp
@c:	puls	a,b,pc

crlf:	pshs	a,b
	tfr	x,d
	andb	#~$1f
	addd	#32
	tfr	d,x
	puls	a,b,pc

*
* Here are the test variations:
*
test1:
	sta	,u
	cmpa	,u
	bne	.skip
.skip:	rts

test2:
	sta	,u
	cmpa	,u
	jmp	>.skip
.skip:	rts

test3:
	sta	,u
	cmpa	,u
	bsr	.skip
.skip:	rts


*
* Should the above fail, use these to get what cpu read back:
* as above, they have same following instruction.
*
test1a:
	sta	,u
	lda	,u
	bne	.skip
.skip:	rts

test2a:
	sta	,u
	lda	,u
	jmp	>.skip
.skip:	rts

test3a:
	sta	,u
	lda	,u
	bsr	.skip
.skip:	rts

*
* Test data
*

screen  equ	$400
escreen equ	$600

msg:	fcn	' MMU BIT TEST 1.0 - 2026 (    )'

testa:	fcn	'BIT6,7 ZERO:'

msg1:	fcn	'1.CMP/BNE($26) '
msg1d:	fcb	$3A,$35,$30,$0F,$25,$1A,0

msg2:	fcn	'2.CMP/BNE($26) '
msg2d:	fcb	$1E,$4A,$65,$C0,$80,$85,0

testb:	fcn	'BIT6 SET:'

msg3:	fcn	'3.CMP/JMP($7E) '
msg3d:	fcb	$3A,$35,$30,$0F,$25,$1A,0

msg4:	fcn	'4.CMP/JMP($7E) '
msg4d:	fcb	$1E,$4A,$65,$C0,$80,$85,0

testc:	fcn	'BIT7 SET:'

msg5:	fcn	'5.CMP/BSR($8D) '
msg5d:	fcb	$3A,$35,$30,$0F,$25,$1A,0

msg6:	fcn	'6.CMP/BSR($8D) '
msg6d:	fcb	$1E,$4A,$65,$C0,$80,$85,0

ok:	fcn	' OK'
bad:	fcn	' GOT:'

done:	fcn	'DONE.'

last	equ	*

	end	start