# 6-Stage Pipelined Von Neumann Processor

A 32-bit pipelined processor implementation using VHDL, featuring a 6-stage pipeline and a unified Von Neumann memory architecture.

## Pipeline Architecture
The processor uses a 6-stage pipeline to improve throughput:

1.  **Fetch (IF)**: Fetches the 32-bit instruction from unified memory.
2.  **Decode (ID)**: Extracts opcode/fields, reads Register File, and sign-extends 16-bit immediates to 32-bit.
3.  **Execute 1 (EX1)**: Performs ALU operations with full forwarding support.
4.  **Execute 2 (EX2)**: Resolves branch decisions and calculates Effective Addresses (EA).
5.  **Memory (MEM)**: Accesses the 32-bit wide unified memory (Load/Store).
6.  **Write-Back (WB)**: Writes results (ALU, Memory, or PC+1) back to the Register File.

## Memory Architecture (Von Neumann)
This project implements a **Von Neumann architecture**, meaning instructions and data share the same address space. 
- To avoid structural hazards between the **IF** and **MEM** stages, the memory is implemented as a **Dual-Ported Unified Memory**.
- **Port A** is used by Fetch.
- **Port B** is used by Memory stage.

## Project Structure
- `src/pipeline/`: VHDL files for each pipeline stage and pipeline registers.
- `src/units/`: Core components like the ALU, Register File, and Control Unit.
- `src/memory/`: Unified memory implementation.
- `src/hazards/`: Forwarding and Hazard Detection units.
- `src/assembler/`: Python-based assembler to convert assembly to machine code.
- `docs/`: Documentation on instruction set and architecture details.

## Getting Started
### Prerequisites
- VHDL Simulator (GHDL, ModelSim, or Vivado)
- Python 3.x (for the assembler)

### Usage
1. Write your assembly code in `programs/`.
2. Run the assembler: `python src/assembler/assembler.py program.asm`.
3. Load the resulting hex file into the VHDL testbench.
