**************************************************************************
* Test IRQ Operation #2 - Wait Loop
*
* Installs an IRQ handler that counts every 60 calls (~ 1 second) and
* increments a counter in the bottom right corner. Prints the address that
* the interrupt was called from on bottom left corner. It should happen
* at address 4090 based on this source. The two digits on the bottom
* corner should be always matching.
*
* This is meant to test emulation, a double interrupt handler isn't a
* real use case but we can check how compatible emulation is.
*
* Operation:
*
* The program uses the same wait that Max-10 uses in a loop, checking for
* interrupt flag b7 of ff03. If interrupts are disabled the interrupt
* line should be active (low) after this point and should be serviced
* as soon as cpu flag I is unmasked (0), (after puls cc). This should 
* happen at address 4090.
*
* A second interrupt handler is installed to check that emulation correctly
* calls the second handler when the interrupt acknowledge doesn't happen.
* After the second handler is done, the interrupt is acknowledged and program
* is reset back to beginning (top).
*
* Should there be a failure to execute the handler, the screen will fill
* with a partial or full character set (instead of a single @), indicating
* there is a problem with emulation.
*
* The program continuously checksum addresses of the interrupt execution
* and execute a fixed number of interrupts and print the result at the 
* end, any deviation will result in wrong checksum. It should run for
* only 10 seconds. The result should be 5886 for version v1.0 (AE33).
*
* Craig Allsop, 2025-05-19 - v1.0 - program verification checksum = AE33
**************************************************************************

	org	$4000

**************************************************************************
* setup screen
*
start	bra	.start1
	fcc	'CA'
result	fdb	0
.start1
	lbsr	clear		clear screen

	ldy	#msgs		print messages to screen
	ldx	,y++
.msgs   lbsr	print
	ldx	,y++
	bne	.msgs

	lda	#60		program initialization
	sta	count1
	sta	count2
	ldx	timer+2
	stx	timer
	ldd	#0
	std	data
	std	result
	std	oldirq
	std	check

	ldu	#start		program check
	ldx	#last-start
	lbsr	crc16
	ldx	#screen+10*32+24
	lbsr	printhexd
	lda	#$30		count = 0
	sta	counter1
	sta	counter2
	ldx	$10d
	stx	oldirq
	ldx	#intr1
	stx	$10d		install irq handler
	lda	#7
	sta	$ff03
	clra
	nop
	nop
	nop
	nop
	nop

**************************************************************************
* start of main program
*

top	ldy	timer
	leay	-1,y
	lbeq	finish
	sty	timer
	tst	$ff02		reset for next interrupt
	ldx	#screen
	sta	,x+
	andcc	#$ef		enable irq & push this state
	pshs	cc
	orcc	#$50		disable irq while waiting
@wait   tst	$ff03		poor mans SYNC (aka Max-10)
	bpl	@wait		loop if no interrupt yet
here	mul			interrupt has occurred!
	mul
	mul
	mul
	mul
	mul
	mul
	mul
	mul
	mul
	mul
	mul
	puls	cc		unsuspend interrupt 
@loop	nop			<- instruction at 4090 - interrupts here
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ldy	#intr1		swap to first irq handler
	sty	$10d		install irq handler
	sta	,x+
	inca
	cmpx	#screen+8*32
	bne	@loop
	ldx	#screen+15*32+6
	pshs	a
	ldd	#$2020
	std	,x++
	std	,x++
	puls	a
	jmp	top

	INCLUDE irq.asm

addchk	ldd	check
	ldx	#2
	bsr	crc16
	std	check
	rts

	INCLUDE finish.asm

**************************************************************************

	INCLUDE	printhex.asm
	INCLUDE	print.asm
	INCLUDE crc16.asm
	INCLUDE clear.asm
count1  fcb	60
count2  fcb	60

timer	fdb	601
	fdb	601
oldirq	fdb	0
data	fdb	0
check	fdb	0

screen  equ	$400
escreen equ	$600
counter1 equ	escreen-2
counter2 equ	escreen-1
msgs	fdb	screen+1
	fcc	' <- SHOULD BE ONE @ HERE'
	fcb	0
	fdb	screen+9*32
	fcc	'   TEST #2 WAIT LOOP IRQ V1.0   '
	fcc	'   CRAIG ALLSOP - 2025 (....)'
	fcb	0
	fdb	screen+12*32
	fcc	'              INTERRUPT ADDRESS '
	fcc	' 4090.4090 <- SHOULD MATCH THIS'
	fcb	0
	fdb	screen+15*32
	fcc	'[    .    ]   SECONDS (0-9) ->'
	fcb	0
	fdb	0

results	fdb	screen
	fcc	'RESULT = '
	fcb	0
last	equ	*

	end	start