#!/usr/bin/env python3
"""Assembler for the 6-stage pipelined processor.

Input syntax is intentionally small and simulator-friendly:

    .org 0
    .word main
    .org 2
    main:
        LDM R1, 5
        LDM R2, 7
        ADD R3, R1, R2
        OUT R3
        HLT

The output file contains one 32-bit hexadecimal word per memory address.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path


OPCODES = {
    "NOP": (0x0, 0x0),
    "HLT": (0x0, 0x1),
    "SETC": (0x0, 0x2),
    "NOT": (0x1, 0x0),
    "INC": (0x1, 0x1),
    "OUT": (0x1, 0x2),
    "IN": (0x1, 0x3),
    "MOV": (0x2, 0x0),
    "SWAP": (0x2, 0x1),
    "ADD": (0x3, 0x0),
    "SUB": (0x3, 0x1),
    "AND": (0x3, 0x2),
    "IADD": (0x4, 0x0),
    "PUSH": (0x5, 0x0),
    "POP": (0x5, 0x1),
    "LDM": (0x6, 0x0),
    "LDD": (0x6, 0x1),
    "STD": (0x6, 0x2),
    "JZ": (0x7, 0x0),
    "JN": (0x7, 0x1),
    "JC": (0x7, 0x2),
    "JMP": (0x7, 0x3),
    "CALL": (0x8, 0x0),
    "RET": (0x8, 0x1),
    "INT": (0x9, 0x0),
    "RTI": (0x9, 0x1),
}


def strip_comment(line: str) -> str:
    return re.split(r"[;#]", line, maxsplit=1)[0].strip()


def tokenize_operands(text: str) -> list[str]:
    return [part.strip() for part in text.split(",") if part.strip()]


def reg(token: str) -> int:
    token = token.strip().upper()
    if not re.fullmatch(r"R[0-7]", token):
        raise ValueError(f"invalid register '{token}'")
    return int(token[1])


def number(token: str, labels: dict[str, int]) -> int:
    token = token.strip()
    if token in labels:
        return labels[token]
    if token.lower().startswith("0x"):
        return int(token, 16)
    if token.lower().endswith("h"):
        return int(token[:-1], 16)
    return int(token, 10)


def encode(opcode: int, rdst: int = 0, rs1: int = 0, rs2: int = 0,
           func: int = 0, imm: int = 0) -> int:
    return (
        ((opcode & 0xF) << 28)
        | ((rdst & 0x7) << 25)
        | ((rs1 & 0x7) << 22)
        | ((rs2 & 0x7) << 19)
        | ((func & 0x7) << 16)
        | (imm & 0xFFFF)
    )


def parse_memory_operand(token: str, labels: dict[str, int]) -> tuple[int, int]:
    match = re.fullmatch(r"\s*([^()]+)\((R[0-7])\)\s*", token, re.IGNORECASE)
    if not match:
        raise ValueError(f"expected offset(Rx), got '{token}'")
    return number(match.group(1).strip(), labels), reg(match.group(2))


def first_pass(lines: list[str]) -> tuple[list[tuple[int, str]], dict[str, int]]:
    pc = 0
    labels: dict[str, int] = {}
    items: list[tuple[int, str]] = []

    for raw in lines:
        line = strip_comment(raw)
        if not line:
            continue

        while ":" in line:
            label, rest = line.split(":", 1)
            label = label.strip()
            if not re.fullmatch(r"[A-Za-z_]\w*", label):
                raise ValueError(f"invalid label '{label}'")
            labels[label] = pc
            line = rest.strip()
            if not line:
                break

        if not line:
            continue
        if line.lower().startswith(".org"):
            pc = int(line.split(None, 1)[1], 0)
            continue

        items.append((pc, line))
        pc += 1

    return items, labels


def assemble_line(line: str, labels: dict[str, int]) -> int:
    parts = line.split(None, 1)
    mnemonic = parts[0].upper()
    operand_text = parts[1] if len(parts) > 1 else ""
    operands = tokenize_operands(operand_text)

    if mnemonic == ".WORD":
        if len(operands) != 1:
            raise ValueError(".word requires one value")
        return number(operands[0], labels) & 0xFFFFFFFF

    if mnemonic not in OPCODES:
        raise ValueError(f"unknown mnemonic '{mnemonic}'")
    opcode, func = OPCODES[mnemonic]

    if mnemonic in {"NOP", "HLT", "SETC", "RET", "RTI"}:
        return encode(opcode, func=func)
    if mnemonic in {"NOT", "INC"}:
        return encode(opcode, rdst=reg(operands[0]), rs1=reg(operands[0]), func=func)
    if mnemonic == "OUT":
        return encode(opcode, rs1=reg(operands[0]), func=func)
    if mnemonic == "IN":
        return encode(opcode, rdst=reg(operands[0]), func=func)
    if mnemonic in {"MOV", "SWAP"}:
        return encode(opcode, rdst=reg(operands[0]), rs1=reg(operands[1]), func=func)
    if mnemonic in {"ADD", "SUB", "AND"}:
        return encode(opcode, rdst=reg(operands[0]), rs1=reg(operands[1]),
                      rs2=reg(operands[2]), func=func)
    if mnemonic == "IADD":
        return encode(opcode, rdst=reg(operands[0]), rs1=reg(operands[1]),
                      func=func, imm=number(operands[2], labels))
    if mnemonic == "PUSH":
        return encode(opcode, rs1=reg(operands[0]), func=func)
    if mnemonic == "POP":
        return encode(opcode, rdst=reg(operands[0]), func=func)
    if mnemonic == "LDM":
        return encode(opcode, rdst=reg(operands[0]), func=func,
                      imm=number(operands[1], labels))
    if mnemonic == "LDD":
        offset, base = parse_memory_operand(operands[1], labels)
        return encode(opcode, rdst=reg(operands[0]), rs1=base, func=func, imm=offset)
    if mnemonic == "STD":
        offset, base = parse_memory_operand(operands[1], labels)
        return encode(opcode, rs1=reg(operands[0]), rs2=base, func=func, imm=offset)
    if mnemonic in {"JZ", "JN", "JC", "JMP", "CALL"}:
        return encode(opcode, func=func, imm=number(operands[0], labels))
    if mnemonic == "INT":
        return encode(opcode, func=func, imm=number(operands[0], labels))

    raise ValueError(f"unhandled mnemonic '{mnemonic}'")


def assemble(source: Path, output: Path) -> None:
    lines = source.read_text().splitlines()
    items, labels = first_pass(lines)
    memory: dict[int, int] = {}

    for addr, line in items:
        try:
            memory[addr] = assemble_line(line, labels)
        except Exception as exc:
            raise SystemExit(f"{source}:{addr}: {line}\n  {exc}") from exc

    max_addr = max(memory.keys(), default=0)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("".join(f"{memory.get(addr, 0):08X}\n" for addr in range(max_addr + 1)))


def main() -> None:
    parser = argparse.ArgumentParser(description="Assemble processor assembly to memory hex")
    parser.add_argument("source", type=Path)
    parser.add_argument("-o", "--output", type=Path)
    args = parser.parse_args()
    output = args.output or args.source.with_suffix(".mem")
    assemble(args.source, output)


if __name__ == "__main__":
    main()
