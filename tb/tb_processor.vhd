library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library STD;
use STD.ENV.ALL;

entity tb_processor is
end entity;

architecture sim of tb_processor is
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal intr_in  : std_logic := '0';
    signal in_port  : std_logic_vector(31 downto 0) := x"0000002A";
    signal out_port : std_logic_vector(31 downto 0);
    signal halted   : std_logic;
    signal pc       : std_logic_vector(31 downto 0);
    signal sp       : std_logic_vector(31 downto 0);
    signal flags    : std_logic_vector(2 downto 0);
    signal r0       : std_logic_vector(31 downto 0);
    signal r1       : std_logic_vector(31 downto 0);
    signal r2       : std_logic_vector(31 downto 0);
    signal r3       : std_logic_vector(31 downto 0);
    signal r4       : std_logic_vector(31 downto 0);
    signal r5       : std_logic_vector(31 downto 0);
    signal r6       : std_logic_vector(31 downto 0);
    signal r7       : std_logic_vector(31 downto 0);
begin
    clk <= not clk after 5 ns;

    dut: entity work.processor_top
        generic map (
            MEM_FILE => "programs/smoke.mem"
        )
        port map (
            clk => clk,
            rst => rst,
            intr_in => intr_in,
            in_port => in_port,
            out_port => out_port,
            halted => halted,
            dbg_pc => pc,
            dbg_sp => sp,
            dbg_flags => flags,
            dbg_r0 => r0,
            dbg_r1 => r1,
            dbg_r2 => r2,
            dbg_r3 => r3,
            dbg_r4 => r4,
            dbg_r5 => r5,
            dbg_r6 => r6,
            dbg_r7 => r7
        );

    stim: process
    begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait until halted = '1';
        wait for 20 ns;
        assert out_port = x"0000000D"
            report "smoke program expected OUT.PORT = 13"
            severity failure;
        report "smoke program passed";
        stop;
    end process;
end architecture;
