**************************************************************************
* Test IRQ Operation #3 - Wait Loop with interrupts active
*
* Installs an IRQ handler that counts every 60 calls (~ 1 second) and
* increments a counter in the bottom right corner. Prints the address that
* the interrupt was called from on bottom left corner. It should happen
* at address 40A0 or 40A3 based on this source. The two digits on the bottom
* corner should be matching.
*
* This is meant to test emulation, a double interrupt handler isn't a
* real use case but we can check how compatible emulation is.
*
* Operation:
*
* The program uses the same wait that the game Contras uses in a loop, 
* checking for interrupt flag b7 of ff03. 
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
* end. It should run for only 10 seconds. As interrupts are enabled while
* waiting, the address will fluctuate giving a random result. 

*
* Result:
*
* It will print the tally of interrupt address, 40A0, A1, A2, A3 as hex bytes, 
* which will look like TALLY = 8B0000CD indicating 8B interrupts from 
* address 40A0 and CD interrupts from address 40A3. There is only 2
* instructions in this loop so there is a chance it will happen from
* either one (40A0 or 40A3). Shown are 4 lines that should only have either a
* @ or an C, indicating interrupted from 40A0 or $40A3.
*
* Craig Allsop
* 2025-05-22 - v1.0 - (checksum: 09C8)
* 2026-09-09 - v1.1 - print a capture of first 128 interrupts (checksum: 2168)
**************************************************************************

        org     $4000

**************************************************************************
* setup screen
*
start   bra     .start1
        fcc     'CA'
result  fdb     0
.start1
        lbsr    clear           clear screen

        ldy     #msgs           print messages to screen
        ldx     ,y++
.msgs   lbsr    print
        ldx     ,y++
        bne     .msgs

        lda     #60             program initialization
        sta     >count1
        sta     >count2
        ldx     >timer+2
        stx     >timer
        ldd     #0
        std     >addr1
        std     >addr3
        std     >data
        std     >result
        std     >oldirq
        std     >check
        ldd     #capture
        std     >cp

        ldu     #start          program check
        ldx     #last-start
        lbsr    crc16
        ldx     #screen+10*32+24
        lbsr    printhexd
        lda     #$30            count = 0
        sta     >counter1
        sta     >counter2
        ldx     >$10d
        stx     >oldirq
        ldx     #intr1
        stx     >$10d           install irq handler
        lda     #7
        sta     >$ff03
        clra
        nop
        nop
        nop
        nop
        nop
        nop
        nop

**************************************************************************
* start of main program
*

top     ldy     >timer
        leay    -1,y
        lbeq    finish
        sty     >timer
        ldx     #screen
        sta     ,x+
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
        andcc   #$ef            enable irq
        tst     >$ff02          reset for next interrupt
baseadr equ     *
@wait   tst     >$ff03          poor mans SYNC (aka Max-10) <- instruction at 40A0 - interrupts here
        bpl     @wait           loop if no interrupt yet    <- instruction at 40A3 - interrupts here
@loop   nop                     
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
        sta     ,x+
        inca
        cmpx    #screen+8*32
        bne     @loop
        ldx     #screen+15*32+6
        pshs    a
        ldd     #$2020
        std     ,x++
        std     ,x++
        puls    a
        jmp     >top

**************************************************************************
* interrupt handler
**************************************************************************
intr1   dec     >count1         decrement count
        bne     .i1
        lda     #60             reset counter back to 60
        sta     >count1
        lda     >counter1       increment bottom corner every second
        cmpa    #$39
        bne     .i2
        lda     #$2f
.i2     inca
        sta     >counter1
.i1     ldd     10,s            write address interrupted at
        ldx     >cp
        cmpx    #capture+256
        beq     .i3
        std     ,x++
        stx     >cp
.i3
        andb    #3
        ldx     #addr1
        inc     b,x
        ldd     10,s
        ldx     #screen+15*32+1
        lbsr    printhexd
        ldx     #intr2          swap to second irq handler
        stx     >$10d           install irq handler
        leau    10,s
        bsr     addchk
        ldu     #escreen-2
        bsr     addchk
        ldu     #screen
        bsr     addchk
        *lda    $ff02           skip this
        rti                     end interrupt handler


intr2   dec     >count2         decrement count
        bne     .i1
        lda     #60             reset counter back to 60
        sta     >count2
        lda     >counter2       increment bottom corner every second
        cmpa    #$39
        bne     .i2
        lda     #$2f
.i2     inca
        sta     >counter2
.i1     ldd     10,s            write address interrupted at
        ldx     #screen+15*32+6
        bsr     printhexd
        ldx     #intr1          swap to first irq handler
        stx     >$10d           install irq handler
        ldx     #top            reset loop to top
        leau    10,s
        stx     10,s
        bsr     addchk
        lda     >$ff02          reset for next interrupt
        rti                     end interrupt handler   

addchk  ldd     >check
        ldx     #2
        lbsr    crc16
        std     >check
        rts

finish  ldy     >oldirq
        sty     >$10d
        lbsr    cleartop
        ldu     #escreen-2
        bsr     addchk
        std     >result
        ldy     #results
        ldx     ,y++
        bsr     print
        bsr     printhexd

        ldy     #tally
        ldx     ,y++
        bsr     print
        ldd     >addr1
        bsr     printhexd
        ldd     >addr3
        bsr     printhexd

        ldy     #capture
        ldx     #screen+2*32
r1:     ldd     ,y++
        subd    #baseadr
        stb     ,x+
        cmpy    #capture+256
        bne     r1      

        ldd     #screen+32*8
        std     >$88

        rts

**************************************************************************

        INCLUDE printhex.asm
        INCLUDE print.asm
        INCLUDE crc16.asm
        INCLUDE clear.asm
count1  fcb     60
count2  fcb     60

addr1   fcb     0
addr2   fcb     0
addr3   fcb     0
addr4   fcb     0

timer   fdb     601
        fdb     601
oldirq  fdb     0
data    fdb     0
check   fdb     0

screen  equ     $400
escreen equ     $600
counter1 equ    escreen-2
counter2 equ    escreen-1
msgs    fdb     screen+1
        fcc     ' <- SHOULD BE ONE @ HERE'
        fcb     0
        fdb     screen+9*32
        fcc     ' TEST #3 WAIT ACT LOOP IRQ V1.1 '
        fcc     '   CRAIG ALLSOP - 2025 (....)'
        fcb     0
        fdb     screen+12*32
        fcc     '              INTERRUPT ADDRESS '
        fcc     ' 40A0.40A0 <- SHOULD MATCH THIS'
        fcb     0
        fdb     screen+15*32
        fcc     '[    .    ]   SECONDS (0-9) ->'
        fcb     0
        fdb     0

results fdb     screen
        fcc     'RESULT = '
        fcb     0

tally   fdb     screen+1*32
        fcc     'TALLY = '
        fcb     0

cp      fdb     capture        
last    equ     *
capture rmb     256

        end     start