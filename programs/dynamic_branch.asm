.org 0
.word main
.word 0
.word 0

main:
    LDM R1, 0
    LDM R2, 6

loop:
    INC R1
    SUB R3, R1, R2
    JZ done
    JMP loop

done:
    OUT R1
    HLT
