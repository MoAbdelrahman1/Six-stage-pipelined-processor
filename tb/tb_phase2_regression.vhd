library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library STD;
use STD.ENV.ALL;

entity tb_phase2_regression is
end entity;

architecture sim of tb_phase2_regression is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    signal isa_out, branch_out, stack_out, intr_out : std_logic_vector(31 downto 0);
    signal isa_halt, branch_halt, stack_halt, intr_halt : std_logic;
    signal intr_pulse : std_logic := '0';

    signal isa_r0, isa_r2, isa_r4, isa_r7 : std_logic_vector(31 downto 0);
    signal branch_r4, branch_r7 : std_logic_vector(31 downto 0);
    signal stack_sp, stack_r2, stack_r3 : std_logic_vector(31 downto 0);
    signal intr_sp, intr_r2, intr_r6 : std_logic_vector(31 downto 0);
begin
    clk <= not clk after 5 ns;

    isa_dut: entity work.processor_top
        generic map (MEM_FILE => "programs/isa_core.mem")
        port map (
            clk => clk, rst => rst, intr_in => '0', in_port => x"0000002A",
            out_port => isa_out, halted => isa_halt,
            dbg_pc => open, dbg_sp => open, dbg_flags => open,
            dbg_r0 => isa_r0, dbg_r1 => open, dbg_r2 => isa_r2, dbg_r3 => open,
            dbg_r4 => isa_r4, dbg_r5 => open, dbg_r6 => open, dbg_r7 => isa_r7
        );

    branch_dut: entity work.processor_top
        generic map (MEM_FILE => "programs/branch.mem")
        port map (
            clk => clk, rst => rst, intr_in => '0', in_port => (others => '0'),
            out_port => branch_out, halted => branch_halt,
            dbg_pc => open, dbg_sp => open, dbg_flags => open,
            dbg_r0 => open, dbg_r1 => open, dbg_r2 => open, dbg_r3 => open,
            dbg_r4 => branch_r4, dbg_r5 => open, dbg_r6 => open, dbg_r7 => branch_r7
        );

    stack_dut: entity work.processor_top
        generic map (MEM_FILE => "programs/stack_call.mem")
        port map (
            clk => clk, rst => rst, intr_in => '0', in_port => (others => '0'),
            out_port => stack_out, halted => stack_halt,
            dbg_pc => open, dbg_sp => stack_sp, dbg_flags => open,
            dbg_r0 => open, dbg_r1 => open, dbg_r2 => stack_r2, dbg_r3 => stack_r3,
            dbg_r4 => open, dbg_r5 => open, dbg_r6 => open, dbg_r7 => open
        );

    intr_dut: entity work.processor_top
        generic map (MEM_FILE => "programs/interrupt.mem")
        port map (
            clk => clk, rst => rst, intr_in => intr_pulse, in_port => (others => '0'),
            out_port => intr_out, halted => intr_halt,
            dbg_pc => open, dbg_sp => intr_sp, dbg_flags => open,
            dbg_r0 => open, dbg_r1 => open, dbg_r2 => intr_r2, dbg_r3 => open,
            dbg_r4 => open, dbg_r5 => open, dbg_r6 => intr_r6, dbg_r7 => open
        );

    stim: process
    begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        wait for 25 ns;
        intr_pulse <= '1';
        wait for 10 ns;
        intr_pulse <= '0';

        wait for 700 ns;

        assert isa_halt = '1' report "ISA core test did not halt" severity failure;
        assert isa_out = x"00000020" report "ISA core OUT expected 0x20" severity failure;
        assert isa_r0 = x"0000002A" report "ISA core IN failed" severity failure;
        assert isa_r2 = x"00000020" report "ISA core SWAP/AND failed for R2" severity failure;
        assert isa_r4 = x"FFFFFFF0" report "ISA core SWAP/NOT failed for R4" severity failure;
        assert isa_r7 = x"00000000" report "ISA core branch skip failed" severity failure;

        assert branch_halt = '1' report "Branch test did not halt" severity failure;
        assert branch_out = x"00000007" report "Branch OUT expected 7" severity failure;
        assert branch_r4 = x"00000007" report "Branch taken path failed" severity failure;
        assert branch_r7 = x"00000000" report "Branch skipped path executed unexpectedly" severity failure;

        assert stack_halt = '1' report "Stack/CALL test did not halt" severity failure;
        assert stack_out = x"00000016" report "Stack/CALL OUT expected 22" severity failure;
        assert stack_r2 = x"00000015" report "POP did not restore pushed value" severity failure;
        assert stack_r3 = x"00000016" report "CALL/RET subroutine result failed" severity failure;
        assert stack_sp = x"00000FFF" report "SP did not return to initial value" severity failure;

        assert intr_halt = '1' report "Interrupt test did not halt" severity failure;
        assert intr_out = x"00000002" report "Interrupt resume OUT expected 2" severity failure;
        assert intr_r2 = x"00000002" report "Interrupt resume instruction stream failed" severity failure;
        assert intr_r6 = x"00000037" report "Interrupt ISR did not execute" severity failure;
        assert intr_sp = x"00000FFF" report "Interrupt SP did not restore" severity failure;

        report "phase2 regression passed";
        stop;
    end process;
end architecture;
