# Cairo University - Faculty of Engineering
**CMPS 301: Spring 2026** **Computer Engineering Department**

# Architecture Project

## Objective
To design and implement a simple 6-stage pipelined processor, Von-neumann (One memory for program and data).

## Processor Stages:
1. **Fetch Stage:** Fetches the next instruction from the memory.
2. **Decode Stage:** Decodes instruction and releases control signals.
3. **Execute-1 Stage:** ALU operations.
4. **Execute-2 Stage:** Branch decision resolution, memory LDD/STD address calculation.
5. **Memory Stage:** For accessing memory in memory operations.
6. **Write-Back Stage:** For updating the register file.

The design should conform to the ISA specification described in the following sections.

## Introduction
The processor in this project has a RISC-like instruction set architecture. There are eight 4-byte general purpose registers; R0, till R7. Another two special purpose registers, one works as a program counter (PC). The second is stack pointer (SP); and hence; points to the top of the stack. The initial value of SP is $(2^{12}-1)$. The memory address space is 4 KB of 32-bit width. The data bus is 32 bits.

When an interrupt occurs, the processor finishes the currently fetched instructions (instructions that have already entered the pipeline), then the address of the next instruction (in PC) is saved on top of the stack, and PC is loaded from address 1 of the memory. To return from an interrupt, an RTI instruction loads the PC from the top of stack, and the flow of the program resumes from the instruction after the interrupted instruction. Take care of corner cases like Branching.

## ISA Specifications

### A) Registers
| Register | Description |
| :--- | :--- |
| `R[0:7]<31:0>` | Eight 32-bit general purpose registers |
| `PC<31:0>` | 32-bit program counter |
| `SP<31:0>` | 32-bit stack pointer |
| `CCR<3:0>` | Condition code register |
| `Z<0> := CCR<0>` | Zero flag, change after arithmetic, logical, or shift operations |
| `N<0> := CCR<1>` | Negative flag, change after arithmetic, logical, or shift operations |
| `C<0> := CCR<2>` | Carry flag, change after arithmetic or shift operations |

### B) Input-Output
| Signal | Description |
| :--- | :--- |
| `IN.PORT<31:0>` | 32-bit data input port |
| `OUT.PORT<31:0>` | 32-bit data output port |
| `INTR.IN<0>` | A single, non-maskable interrupt |
| `RESET.IN<0>` | Reset signal |

### C) Instruction Operands
* `Rsrc1`: 1st operand register
* `Rsrc2`: 2nd operand register
* `Rdst`: Result register field
* `Offset`: Address offset (16 bit)
* `Imm`: Immediate Value 16 bits

*Take Care that Some instructions will Occupy more than one memory location*

### D) Instruction Set
| Mnemonic | Function |
| :--- | :--- |
| `NOP` | $PC \leftarrow PC+1$ |
| `HLT` | Freezes CPU (No Clock Input) until a reset |
| `SETC` | $C \leftarrow 1$ |
| `NOT Rdst` | NOT value stored in register Rdst<br>R[Rdst] $\leftarrow$ 1's Complement (R[Rdst]);<br>If (1's Complement(R[Rdst]) = 0): $Z \leftarrow 1$; else: $Z \leftarrow 0$<br>If (1's Complement(R[Rdst]) < 0): $N \leftarrow 1$; else: $N \leftarrow 0$ |
| `INC Rdst` | Increment value stored in Rdst<br>R[Rdst] $\leftarrow$ R[Rdst] + 1;<br>If ((R[Rdst]+1) = 0): $Z \leftarrow 1$ else: $Z \leftarrow 0$<br>If ((R[Rdst]+1) < 0): $N \leftarrow 1$; else: $N \leftarrow 0$<br>Updates carry |
| `OUT Rsrc` | `OUT.PORT` $\leftarrow$ R[Rsrc] |
| `IN Rdst` | R[Rdst] $\leftarrow$ `IN.PORT` |
| `MOV Rdst, Rsrc` | Move value from register Rsrc to register Rdst |
| `SWAP Rdst, Rsrc`| Exchange the values between 2 registers |
| `ADD Rdst, Rsrc1, Rsrc2` | Add the values stored in registers Rsrc1, Rsrc2 and store the result in Rdst and updates carry.<br>If the result = 0 then $Z \leftarrow 1$; else: $Z \leftarrow 0$;<br>If the result < 0 then $N \leftarrow 1$; else: $N \leftarrow 0$ |
| `SUB Rdst, Rsrc1, Rsrc2` | Subtract the values stored in registers Rsrc1, Rsrc2 and store the result in Rdst and updates carry.<br>If the result = 0 then $Z \leftarrow 1$; else: $Z \leftarrow 0$;<br>If the result < 0 then $N \leftarrow 1$; else: $N \leftarrow 0$ |
| `AND Rdst, Rsrc1, Rsrc2` | AND the values stored in registers Rsrc1, Rsrc2 and store the result in Rdst.<br>If the result = 0 then $Z \leftarrow 1$; else: $Z \leftarrow 0$;<br>If the result < 0 then $N \leftarrow 1$; else: $N \leftarrow 0$ |
| `IADD Rdst, Rsrc, Imm` | Add the values stored in registers Rsrc to Immediate Value and store the result in Rdst and updates carry.<br>If the result = 0 then $Z \leftarrow 1$; else: $Z \leftarrow 0$;<br>If the result < 0 then $N \leftarrow 1$ else: $N \leftarrow 0$ |
| `PUSH Rsrc` | X[SP] $\leftarrow$ R[Rsrc]; SP -= 1 |
| `POP Rdst` | SP += 1; R[Rdst] $\leftarrow$ X[SP] |
| `LDM Rdst, Imm` | Load immediate value (16 bit) to register Rdst<br>R[Rdst] $\leftarrow$ Imm<15:0> |
| `LDD Rdst, offset(Rsrc)` | Load value from memory address Rsrc + offset to register Rdst<br>R[Rdst] $\leftarrow$ M[R[Rsrc] + offset] |
| `STD Rsrc1, offset(Rsrc2)` | Store value that is in register Rsrc1 to memory location Rsrc2 + offset<br>M[R[Rsrc2] + offset] $\leftarrow$ R[Rsrc1] |
| `JZ Imm` | Jump if zero<br>If (Z=1): PC $\leftarrow$ Imm; (Z=0) |
| `JN Imm` | Jump if negative<br>If (N=1): PC $\leftarrow$ Imm; (N=0) |
| `JC Imm` | Jump if carry<br>If (C=1): PC $\leftarrow$ Imm; (C=0) |
| `JMP Imm` | Jump<br>PC $\leftarrow$ Imm |
| `CALL Imm` | X[SP] $\leftarrow$ PC+1; SP -= 1; PC $\leftarrow$ Imm |
| `RET` | SP += 1; PC $\leftarrow$ X[SP] |
| `INT index` | X[SP] $\leftarrow$ PC+1; SP -= 1; Flags preserved;<br>PC $\leftarrow$ M[index+2]<br>index is either 0 or 1. |
| `RTI` | SP += 1; PC $\leftarrow$ X[SP]; Flags restored |

### E) Input Signals
| Signal | Description |
| :--- | :--- |
| `Reset` | PC $\leftarrow$ M[0] //memory location of zero |
| `Interrupt` | X[SP] $\leftarrow$ PC; SP -= 1; PC $\leftarrow$ M[1]; Flags preserved |

## Phase 1 Requirement:
* Instruction format of your design
* Opcode of each instruction
* Instruction bits details
* Schematic diagram of the processor with data flow details (using a digital tool not hand written).
    * ALU / Registers / Memory Blocks
    * Dataflow Interconnections between Blocks & its sizes
* Control Unit detailed design
* Pipeline stages design
* Pipeline registers details (Size, Input, Connection, ...)
* Pipeline hazards and your solution including:
    i. Data Forwarding
    ii. Static Branch Prediction

## Phase 2 Requirement
* Implement and integrate your architecture
* VHDL Implementation of each component of the processor
* VHDL file that integrates the different components in a single module
* Simulation Test code that reads a program file and executes it on the processor.
* Setup the simulation wave
* Load Memory File & Run the test program
* Assembler code that converts assembly program (Text File) into machine code according to your design (Memory File)
* Report that contains any design changes after phase 1
* Report that contains pipeline hazards considered and how your design solves it.

## Project Testing
You will be given different test programs. You are required to compile and load it onto the RAM and reset your processor to start executing from the memory location written in address `0000h` (PC = M[0]). Each program would test some instructions (you should notify the TA if you haven't implemented or have logical errors concerning some of the instruction set).

You MUST prepare a waveform using do files with the main signals showing that your processor is working correctly (R0-R7, PC, SP, Flags, CLK, Reset, Interrupt, IN.port, Out.port). Show main signals and only main signals please, try to keep wave clean.

You need to make sure that your program can generate the programming file. [2 marks]

## Evaluation Criteria
Each project will be evaluated according to the number of instructions that are implemented, and Pipelining hazards handled in the design. Table 2 shows the evaluation criteria in detail. Failing to implement a working processor will nullify your project grade. No credits will be given to individual modules or a non-working processor. Unnecessary latching or very poor understanding of underlying hardware will be penalized. Individual Members of the same team can have different grades, you can get a zero grade if you didn't work while the rest of the team can get fullmark. Make sure you balance your Work distribution.

**Table 2: Evaluation Criteria**
| Item | Marks |
| :--- | :--- |
| Instructions | 17 marks |
| Data Hazards | 1 mark |
| Struct Hazards | 1 mark |
| Control Hazards | 1 mark |
| **Bonus Marks** | **2-bit dynamic branch prediction with address calculation in fetch (2 marks bonus)** |

## Team Members
Each team shall consist of a maximum of four members.

## Phase 1 Due Date
* Delivery a softcopy on google classroom.
* Week 12, The discussion will be during the regular lab session.

## Project Due Date
* Delivery a softcopy on google classroom.
* Week 14, The demo will be during the regular lab session.

## General Advice
1. Compile your design on regular bases (after each modification) so that you can figure out new errors early. Accumulated errors are harder to track.
2. Start by finishing a working processor that does all one operands only. Integrating early will help you find a lot of errors. You can then add each type of instructions and integrate them into the working processor.
3. Use the engineering sense to back trace the error source.
4. As much as you can, don't ignore warnings.
5. Read the transcript window messages in Modelsim carefully.
6. After each major step, and if you have a working processor, save the design before you modify it (use a versioning tool if you can as git & svn).
7. Always save the ram files to easily export and import them.
8. Start early and give yourself enough time for testing.
9. Integrate your components incrementally (i.e: Integrate the RAM with the Registers, then integrate with them the ALU...).
10. Use coding conventions to know each signal functionality easily.
11. Try to simulate your control signals sequence for an instruction (i.e: Add) to know if your timing design is correct.
12. There is no problem in changing the design after phase 1, but justify your changes.
13. Always reset all components at the start of the simulation.
14. Don't leave any input signal float "U", set it with 0 or 1.
15. Remember that your VHDL code is a HW system (logic gates, Flipflops and wires).
16. Use Do files instead of re-forcing all inputs each time.
