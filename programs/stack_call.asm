.org 0
.word main
.word 0
.word 0

main:
    LDM R1, 21
    PUSH R1
    LDM R1, 0
    POP R2
    NOP
    NOP
    CALL subroutine
    OUT R3
    HLT
    NOP

subroutine:
    IADD R3, R2, 1
    RET
