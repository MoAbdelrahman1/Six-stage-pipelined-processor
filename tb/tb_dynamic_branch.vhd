library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library STD;
use STD.ENV.ALL;

entity tb_dynamic_branch is
end entity;

architecture sim of tb_dynamic_branch is
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal out_port : std_logic_vector(31 downto 0);
    signal halted   : std_logic;
    signal r1       : std_logic_vector(31 downto 0);
begin
    clk <= not clk after 5 ns;

    dut: entity work.processor_top
        generic map (
            MEM_FILE => "programs/dynamic_branch.mem"
        )
        port map (
            clk => clk,
            rst => rst,
            intr_in => '0',
            in_port => (others => '0'),
            out_port => out_port,
            halted => halted,
            dbg_pc => open,
            dbg_sp => open,
            dbg_flags => open,
            dbg_r0 => open,
            dbg_r1 => r1,
            dbg_r2 => open,
            dbg_r3 => open,
            dbg_r4 => open,
            dbg_r5 => open,
            dbg_r6 => open,
            dbg_r7 => open
        );

    stim: process
    begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait until halted = '1' for 800 ns;
        assert halted = '1'
            report "dynamic branch test did not halt"
            severity failure;
        assert out_port = x"00000006"
            report "dynamic branch loop expected OUT.PORT = 6"
            severity failure;
        assert r1 = x"00000006"
            report "dynamic branch loop expected R1 = 6"
            severity failure;
        report "dynamic branch predictor test passed";
        stop;
    end process;
end architecture;
