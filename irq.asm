**************************************************************************
* interrupt handler shared with I1, I2
*
* Craig Allsop - 2025/05/20
**************************************************************************
intr1   dec	count1		decrement count
	bne	.i1
	lda	#60		reset counter back to 60
	sta	count1
	lda	counter1	increment bottom corner every second
	cmpa	#$39
	bne	.i2
	lda	#$2f
.i2	inca
	sta	counter1
.i1	ldd	10,s		write address interrupted at
	ldx	#screen+15*32+1
	bsr	printhexd
	ldx	#intr2		swap to second irq handler
	stx	$10d		install irq handler
	leau	10,s
	bsr	addchk
	ldu	#escreen-2
	bsr	addchk
	ldu	#screen
	bsr	addchk
	*lda	$ff02		skip this
	rti			end interrupt handler


intr2   dec	count2		decrement count
	bne	.i1
	lda	#60		reset counter back to 60
	sta	count2
	lda	counter2	increment bottom corner every second
	cmpa	#$39
	bne	.i2
	lda	#$2f
.i2	inca
	sta	counter2
.i1	ldd	10,s		write address interrupted at
	ldx	#screen+15*32+6
	bsr	printhexd
	ldx	#intr1		swap to first irq handler
	stx	$10d		install irq handler
	ldx	#top		reset loop to top
	stx	10,s
	leau	10,s
	bsr	addchk
	lda	$ff02		reset for next interrupt
	rti			end interrupt handler	