# Phase 2 Implementation Report

## Implemented Design

The Phase 2 implementation integrates the processor in `src/top/processor_top.vhd`.
It implements a 6-stage pipeline:

1. Fetch
2. Decode
3. Execute-1
4. Execute-2
5. Memory
6. Write-back

The design uses one unified 4K x 32-bit memory array for instructions and data.
The memory is initialized from a text hex memory file selected by the `MEM_FILE`
generic. Address `0` contains the reset PC value, and address `1` contains the
external interrupt vector.

The top module exposes debug ports for waveform viewing:

- `dbg_r0` to `dbg_r7`
- `dbg_pc`
- `dbg_sp`
- `dbg_flags`
- `in_port`
- `out_port`
- `intr_in`
- `rst`
- `clk`

## Design Changes After Phase 1

- The final working implementation is integrated inside `processor_top.vhd`.
  The smaller stage files remain in the repository as structural references, but
  the simulation target uses the integrated top-level pipeline.
- The processor uses one internal unified memory initialized by `MEM_FILE`
  instead of a separately instantiated memory component.
- Pipeline registers are implemented as internal records in the top-level module
  to keep control/data propagation explicit and easier to verify.
- The assembler emits one 32-bit hexadecimal word per memory address.
- The testbench uses debug ports instead of reaching into internal hierarchy for
  the required waveform signals.

## Implemented Instructions

Implemented instruction groups:

- No-operand: `NOP`, `HLT`, `SETC`
- One-operand: `NOT`, `INC`, `IN`, `OUT`, `PUSH`, `POP`
- Register operations: `MOV`, `SWAP`, `ADD`, `SUB`, `AND`
- Immediate/memory: `IADD`, `LDM`, `LDD`, `STD`
- Control flow: `JZ`, `JN`, `JC`, `JMP`, `CALL`, `RET`
- Interrupts: external `intr_in`, software `INT`, `RTI`

## Hazard Handling

### Data Hazards

The implementation forwards ALU results from later pipeline stages back to EX1.
Forwarding paths include:

- EX1/EX2 result to EX1 operand
- EX2/MEM result to EX1 operand
- MEM/WB writeback value to EX1 operand
- Memory-stage load data to a dependent EX1 operand

The standalone `src/hazards/forwarding_unit.vhd` also implements priority-based
forwarding selection from EX2, MEM, and WB.

### Load-Use Hazards

The integrated top supports memory-stage forwarding for immediate use after
`LDD`. The standalone `hazard_detection_unit.vhd` provides the conventional
stall/flush outputs for a load-use dependency when used in a structural version
of the datapath.

### Control Hazards

The base control-hazard solution used static "not taken" prediction. This branch
adds the bonus dynamic predictor:

- 16-entry branch history table
- 2-bit saturating counter per entry
- branch target buffer (BTB) target per entry
- PC tag per entry to prevent low-bit aliasing from redirecting non-branch PCs

Counter interpretation:

- `00`: strongly not taken
- `01`: weakly not taken
- `10`: weakly taken
- `11`: strongly taken

Fetch checks the predictor using the current PC. If the entry is valid, the tag
matches the PC, and the counter MSB is `1`, fetch predicts taken and uses the BTB
target as the next PC. Otherwise fetch uses `PC + 1`.

Branches are still resolved in EX2. On resolution, the counter is incremented for
taken branches and decremented for not-taken branches, saturating at `00` and
`11`. Taken branches also update the BTB target.

If the prediction disagrees with the actual branch decision or predicts the wrong
target, younger instructions are flushed and the PC is corrected.

`RET` and `RTI` redirect after the stack pop in the memory stage because the
return PC is only available after reading the stack.

### Structural Hazards

The architecture is Von Neumann, so instruction and data share one address
space. In this simulation implementation the unified memory is modeled as a
single internal RAM array with separate read/write actions scheduled inside the
pipeline process. This avoids a simulator-level IF/MEM port conflict while still
preserving one memory image for program and data.

## Assembler

The assembler is located at `src/assembler/assembler.py`.

Usage:

```text
python src/assembler/assembler.py programs/smoke.asm -o programs/smoke.mem
```

The current machine has a broken Python launcher configuration, so the checked-in
`.mem` files are included for immediate simulation.

## Simulation Files

Main testbenches:

- `tb/tb_processor.vhd`: smoke test for ALU, memory, forwarding, output, and halt.
- `tb/tb_phase2_regression.vhd`: regression for ISA core, branches, stack/CALL/RET,
  and interrupt/RTI.
- `tb/tb_dynamic_branch.vhd`: repeated branch loop that trains and verifies the
  2-bit dynamic branch predictor.

Programs:

- `programs/smoke.asm`
- `programs/isa_core.asm`
- `programs/branch.asm`
- `programs/stack_call.asm`
- `programs/interrupt.asm`
- `programs/dynamic_branch.asm`

Run script:

```text
vsim -do sim/run.do
```

The `.do` file compiles the design and runs the smoke, regression, dynamic
branch, and TA-style testbenches with bounded simulation durations so the script
does not hang on a non-terminating test.

## Verified Results

The following simulations pass in Questa:

- `tb_processor`: `OUT.PORT = 0x0000000D`
- `tb_phase2_regression`:
  - ISA core output: `0x00000020`
  - Branch output: `0x00000007`
  - Stack/CALL/RET output: `0x00000016`
  - Interrupt resume output: `0x00000002`
- `tb_dynamic_branch`: loop output `0x00000006`
