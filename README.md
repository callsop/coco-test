# CoCo Test Disk

Just my collection of test programs that are used to verify coco emulation.

Programs:

**I1.BIN** - Interrupt Test #1 (8C4D) - Tests SYNC / IRQ handler. Runs for 10 seconds and checks for proper operation of interrupt handler, interrupted address and number of interrupts. Produces checksum result of A66C.

**I2.BIN** - Interrupt Test #2 (AE33) - Tests interrupt wait loop, interrupts disabled while waiting & IRQ handler. (Similar to Max-10) Similar to above, should produce checksum result of 5886.

**I3.BIN** - Interrupt Test #3 (09C8) - Tests interrupt wait loop while interrupts active (enabled) & IRQ handler. (Similar to the game Contras) The results for this test vary because
interrupts being enabled can happen anywhere but in this test it should only
occur at address 4090 and 4093. This test will tally up how many for each,
typical results are TALLY = CA00008E as tested on a real CoCo3.

ToDo: Test how often the wait loop while interrupts active in test #3 continue looping after interrupt has occurred, as this seems to affect the title screen of the game Contras.

## Results

| Machine | Version | #1 | #2 | #3 |
| -------- | ------- | -- | -- | -- |
| CoCo 3   | -   |  <green>Pass :heavy_check_mark:</green> | Pass :heavy_check_mark: | Pass :heavy_check_mark: Tally = CA00008E |
| MAME coco3 | 0277b   |  <green>Pass :heavy_check_mark:</green> | Pass :heavy_check_mark: | Pass :heavy_check_mark: |
| xroar coco3p | 1.5     |  Pass :heavy_check_mark: | Pass :heavy_check_mark: | Pass :heavy_check_mark: Tally = B10000A7 |
| xroar coco3p | 1.8.1   |  Pass :heavy_check_mark: | Pass :heavy_check_mark: | Pass :heavy_check_mark: Tally = BD00009B |
| VCC      | <2.1.9.1 |   No :x: |  No :x: |  No :x: Tally = 510000DB| 
| VCC      | 2.1.9.2 | Pass :heavy_check_mark: | Pass :heavy_check_mark: | Pass :heavy_check_mark: Tally = 980000C0 | 
| Coco3FPGA  | :grey_question: | :grey_question: | :grey_question: | :grey_question: | 
| RealCoco3  | :grey_question: | :grey_question: | :grey_question: | :grey_question: | 

- Interestingly on test #3 a real CoCo 3 interrupts from address 4090 more often than 4093.

## Building

To build the dsk image require some tools...

### Requirements

- Jam 2.6.1
- Toolshed 2.2

#### Linux
 WIP

```
sudo apt install jam
```

#### Windows

Jam 2.6.1 is here: https://github.com/callsop/perforce-jam/releases/tag/v2.6.1

### Building .dsk image

```
jam dsk
```

### Clean

```
jam clean
```

## Running

### Requirements

Either of these can be used:

- xroar 1.8.1
- vcc 2.1.9.2

### Launching with xroar

Use the label x- and program name.

```
jam x-i1
```

### Launching with vcc

Use the label v- and program name.

```
jam v-i1
```
