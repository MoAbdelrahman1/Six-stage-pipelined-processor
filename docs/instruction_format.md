# Instruction Format Specification (32-bit)

## 1. Instruction Layout
All instructions are encoded in a single **32-bit** word.

| Bits | Field | Description |
| :--- | :--- | :--- |
| [31:28] | **Opcode** | 4-bit Operation Code |
| [27:25] | **Rdst** | Destination Register (R0-R7) |
| [24:22] | **Rsrc1** | Source Register 1 |
| [21:19] | **Rsrc2** | Source Register 2 |
| [18:16] | **Func** | 3-bit Function identifier |
| [15:0]  | **Immediate** | 16-bit Signed Immediate / Offset |

## 2. Opcode & Function Table

| Mnemonic | Opcode [31:28] | Func [18:16] | Description |
| :--- | :--- | :--- | :--- |
| **NOP** | 0000 | 000 | No operation |
| **HLT** | 0000 | 001 | Halt CPU |
| **SETC** | 0000 | 010 | Set carry flag |
| **NOT** | 0001 | 000 | Rdst = NOT Rdst |
| **INC** | 0001 | 001 | Rdst = Rdst + 1 |
| **OUT** | 0001 | 010 | OUT.PORT = Rsrc1 |
| **IN** | 0001 | 011 | Rdst = IN.PORT |
| **MOV** | 0010 | 000 | Rdst = Rsrc1 |
| **SWAP** | 0010 | 001 | Exchange Rdst and Rsrc1 |
| **ADD** | 0011 | 000 | Rdst = Rs1 + Rs2 |
| **SUB** | 0011 | 001 | Rdst = Rs1 - Rs2 |
| **AND** | 0011 | 010 | Rdst = Rs1 AND Rs2 |
| **IADD** | 0100 | 000 | Rdst = Rs1 + Imm |
| **PUSH** | 0101 | 000 | M[SP] = Rsrc; SP-- |
| **POP** | 0101 | 001 | SP++; Rdst = M[SP] |
| **LDM** | 0110 | 000 | Rdst = Imm |
| **LDD** | 0110 | 001 | Rdst = M[Rs1 + Imm] |
| **STD** | 0110 | 010 | M[Rs2 + Imm] = Rs1 |
| **JZ** | 0111 | 000 | If Z=1: PC = Imm |
| **JN** | 0111 | 001 | If N=1: PC = Imm |
| **JC** | 0111 | 010 | If C=1: PC = Imm |
| **JMP** | 0111 | 011 | PC = Imm |
| **CALL** | 1000 | 000 | Push PC+1, jump to Imm |
| **RET** | 1000 | 001 | Pop PC from stack |
| **INT** | 1001 | 000 | Software interrupt |
| **RTI** | 1001 | 001 | Return from interrupt |

## 3. ALU Operations (3-bit ALUop)
- `000`: ADD (updates Z, N, C)
- `001`: SUB (updates Z, N, C)
- `010`: AND (updates Z, N)
- `011`: NOT (updates Z, N)
- `100`: INC (updates Z, N, C)
- `101`: PASS (for MOV/IN/LDM)
- `110`: SETC (Forces C=1)
