transcript on
if {![file exists work]} {
    vlib work
}
vcom -2008 src/top/processor_top.vhd
vcom -2008 tb/tb_processor.vhd
vcom -2008 tb/tb_phase2_regression.vhd
vsim work.tb_processor

add wave -radix hexadecimal sim:/tb_processor/clk
add wave -radix hexadecimal sim:/tb_processor/rst
add wave -radix hexadecimal sim:/tb_processor/intr_in
add wave -radix hexadecimal sim:/tb_processor/in_port
add wave -radix hexadecimal sim:/tb_processor/out_port
add wave -radix hexadecimal sim:/tb_processor/pc
add wave -radix hexadecimal sim:/tb_processor/sp
add wave -radix binary      sim:/tb_processor/flags
add wave -radix hexadecimal sim:/tb_processor/r0
add wave -radix hexadecimal sim:/tb_processor/r1
add wave -radix hexadecimal sim:/tb_processor/r2
add wave -radix hexadecimal sim:/tb_processor/r3
add wave -radix hexadecimal sim:/tb_processor/r4
add wave -radix hexadecimal sim:/tb_processor/r5
add wave -radix hexadecimal sim:/tb_processor/r6
add wave -radix hexadecimal sim:/tb_processor/r7
add wave -radix binary      sim:/tb_processor/halted

run -all

vsim work.tb_phase2_regression
run -all
