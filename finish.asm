
**************************************************************************
* common finish and print results for I1, I2
*
* Craig Allsop - 2025/05/20
**************************************************************************
finish  ldy     >oldirq
        sty     >$10d
        lbsr    cleartop
        ldu     #escreen-2
        bsr     addchk
        std     >result
        ldy     #results
        ldx     ,y++
        lbsr    print
        lbsr    printhexd
        ldd     #screen+32*8
        std     >$88

        ldy     #capture
        ldx     #screen+2*32
r1:     ldd     ,y++
        subd    #baseadr
        stb     ,x+
        cmpy    #capture+256
        bne     r1