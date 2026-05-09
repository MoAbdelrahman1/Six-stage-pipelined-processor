.org 0
.word main
.word isr0
.word isr1

main:
    LDM R1, 5
    LDM R2, 7
    ADD R3, R1, R2
    STD R3, 100(R0)
    LDD R4, 100(R0)
    IADD R5, R4, 1
    OUT R5
    HLT

isr0:
    LDM R6, 10
    RTI

isr1:
    LDM R7, 11
    RTI
