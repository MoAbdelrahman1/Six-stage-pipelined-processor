transcript on
if {![file exists work]} {
    vlib work
}
vcom -2008 src/top/processor_top.vhd
vcom -2008 tb/tb_processor.vhd
vcom -2008 tb/tb_phase2_regression.vhd
vcom -2008 tb/tb_test1.vhd
vcom -2008 tb/tb_test2.vhd
vcom -2008 tb/tb_test3.vhd
vcom -2008 tb/tb_test4.vhd
vcom -2008 tb/tb_test6.vhd
vcom -2008 tb/tb_ta_test.vhd

# Run All Tests
foreach tb {tb_test1 tb_test2 tb_test3 tb_test4 tb_test6 tb_ta_test} {
    vsim work.$tb
    
    # Add waves for the current test
    add wave -divider "Processor State: $tb"
    add wave -radix hex /dut/*
    
    if {$tb == "tb_ta_test"} {
        run 100 us
    } else {
        run -all
    }
}
