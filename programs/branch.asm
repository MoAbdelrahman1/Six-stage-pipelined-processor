.org 0
.word main
.word 0
.word 0

main:
    LDM R1, 0
    INC R1
    JZ fail
    LDM R2, 1
    SUB R3, R2, R2
    NOP
    NOP
    NOP
    JZ pass
    LDM R7, 99
    JMP done

pass:
    LDM R4, 7
    JMP done

done:
    OUT R4
    HLT

fail:
    LDM R7, 55
    OUT R7
    HLT
