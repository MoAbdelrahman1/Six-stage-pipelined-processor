# 6-Stage Pipelined Von Neumann Processor

A 16-bit pipelined processor implementation using VHDL, featuring a 6-stage pipeline and a unified Von Neumann memory architecture.

## Pipeline Architecture
The processor uses a 6-stage pipeline to improve throughput while allowing for more complex execution logic (split across two EX stages).

1.  **Fetch (IF)**: Fetches the 16-bit instruction from unified memory.
2.  **Decode (ID)**: Decodes opcode, reads from the Register File, and generates control signals.
3.  **Execute 1 (EX1)**: First stage of ALU execution / branch target calculation.
4.  **Execute 2 (EX2)**: Second stage of ALU execution / completion of multi-cycle operations.
5.  **Memory (MEM)**: Data memory access (Load/Store) from the unified memory.
6.  **Write-Back (WB)**: Writes results back to the Register File.

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
