.org 0
.word main
.word isr
.word 0

main:
    LDM R1, 1
    NOP
    NOP
    LDM R2, 2
    OUT R2
    HLT
    NOP

isr:
    LDM R6, 55
    RTI
