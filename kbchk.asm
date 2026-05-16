*
* keyboard interrupt test v1.04 - Craig Allsop 20/4/2026
*
* v1.00 - documentation added
* v1.01 - clarify documentation (3,4)
* v1.02 - decode keys and scroll, add title
* v1.03 - show both wait loops
* v1.04 - restart loops at same value
*
*             KEYBOARD INTERRUPT TEST 1.04  
*            WAIT[12] COUNT[0] SCAN[xxxxxxxx]
*
* The test:
*
* Waits for a keyboard interrupt in wait loop 1. When an
* interrupt is triggered, increment the count character and
* scan the keyboard onto the screen and then waits for the
* interrupt flag to clear before repeating (wait loop 2).
*
* NOTE: This is intended only to test the keyboard interrupt,
* thus its not an appropriate keyboard routine as it won't
* detect multiple keys being pressed.
*
* The expected/observed behavior:
*
* 1. The 'wait for clear' doesn't seem to wait, i.e. its
*       always clear at this point so the wait character only
*       advances once (or twice).
*
* 2. The wait for interrupt flag should trigger once on both 
*       press and release of the same key.
*
* 3. Where multiple keys are pressed, the 2nd key does not
*       issue an interrupt and only the final key released 
*       triggers an interrupt.
*
* 4. In this version, it should decode each key press so 
*       long as only one key is pressed at a time. Decoding
*       multiple presses will require a different method.
*
* Incorrect behavior includes:
*
* - The counter continuously counting and thus see
*       duplicate keys printed in the scrolling line. (1,2)
*
* - The wait showing a space instead of '*', aside from a 
*       brief flicker we should almost always see a '*'. (2)
*
* - The counter incrementing when a 2nd key pressed at
*       the same time. (4)
*
* - The counter incrementing when two keys have been
*       pressed and one key is released. (4)
*
* Let me know if some coco3 doesn't behave like above as
* I've only got one coco3 to test on. (an '86 GIME)
*

SCREEN	equ	$400
LINE2	equ	SCREEN+32
LINE4	equ	SCREEN+32*4
WAIT1	equ	LINE2+5		 the wait character pos
WAIT2	equ	LINE2+6		 the wait character pos
COUNTER	equ	LINE2+15	; the counter character pos
SCAN	equ	LINE2+23	; the keyboard scan
PRINT	equ	LINE4-1		; print position

READ	macro			; read a keyboard column 
	rola
	sta	$ff02
	ldb	$ff00
	stb	,x+
	endm


	org	$4000
start:
	ldd	#$2020		; clear the screen
	ldx	#SCREEN
clear:
	std	,x++
	cmpx	#SCREEN+$200
	bne	clear

	ldx	#SCREEN
	ldy	#msg
showmsg:			; show message text
	lda	,y+
	beq	continue
	anda	#~$40
	sta	,x+
	bra	showmsg

continue:
	lda	#%11000000	; coco3 mode, mmu, no interrupt to cpu
	sta	$ff90
	lda	#2		; enable only keyboard interrupt
	sta	$ff92

	lda	#0		; check all keys
	sta	$ff02	

top:
	lda	#'0'		; start loop at a zero
	sta	WAIT1

loop:	inc	WAIT1
	lda	$ff92		; wait for keyboard interrupt
	bne	pressed
	bra	loop
pressed:
	inc	COUNTER		; count each scan
	ldx	#SCAN		; scan keyboard

	lda	pressed
	beq	nopause		; if nothing pressed, don't pause
	jsr	pause		; wait (required for a release event, if
				;       we scan too early we'll read the
				;       prior pressed state)
nopause:
	clr	ispressed
	
	andcc	#$fe		; clear carry
	lda	#$ff

	READ			; rola and read keyboard to x
	READ
	READ
	READ
	READ
	READ
	READ
	READ

	lda	#' '		; show the space while in 2nd loop
	sta	WAIT1

	lda	#'0'		; start loop at a zero
	sta	WAIT2

	lda	#0		; check all keys
	sta	$ff02

wait:	inc	WAIT2
	lda	$ff92
	bne	wait		; wait for clear flag (never waits?)

	ldx	#SCAN		; decode key
	ldy	#table
print:
	lda	,x+
	ldb	#7
@next:
	rora
	bcs	@nokey		; found a key?
	pshs	d,x		; print the key & scroll
	lda	,y
	sta	PRINT
	bsr	scroll
	puls	d,x
	inc	ispressed	; something was pressed
@nokey:
	leay	1,y
	decb
	bne	@next
	cmpx	#SCAN+8
	bne	print
	lbra	top

scroll:
	ldx	#PRINT-29	; scroll decoded keys left
@loop:
	ldd	,x+
	std	-2,x
	cmpx	#PRINT+1
	bne	@loop
	rts

pause:	lda	#20		; a small pause
@loop:	deca
	bne	@loop
	rts

ispressed:
	fcb	0
msg:	fcn	'  KEYBOARD INTERRUPT TEST 1.04  WAIT[* ] COUNT[0] SCAN[        ]'

table:	fcc	'@HPX08e'
	fcc	'AIQY19c'
	fcc	'BJRZ2:b'
	fcc	'CKSu3;a'
	fcc	'DLTd4,t'
	fcc	'EMUl5-1'
	fcc	'FNVr6.2'
	fcc	'GOW 7/h'

	end	start