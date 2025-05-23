**************************************************************************
* crc16
* u = address (modified)
* x = length (modified)
* d = start (result in d) - for XMODEM d = 0
*
* Craig Allsop - 2025/05/20
**************************************************************************

crc16 	eora	,u+
	ldy	#8
.loop   aslb
	rola
	bcc	.skip
	eora	#$10
	eorb	#$21
.skip   leay	-1,y
	bne	.loop
	leax	-1,x
	bne	crc16
	rts

