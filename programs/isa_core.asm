.org 0
.word main
.word 0
.word 0

main:
    IN R0
    LDM R1, -1
    INC R1
    NOP
    NOP
    NOP
    JZ zero_path
    LDM R7, 99

zero_path:
    SETC
    NOP
    NOP
    NOP
    JC carry_path
    LDM R7, 88

carry_path:
    LDM R2, 15
    NOT R2
    AND R3, R0, R2
    MOV R4, R3
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    SWAP R4, R2
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    OUT R2
    HLT
