library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library STD;
use STD.ENV.ALL;

entity tb_test3 is
end entity;

architecture sim of tb_test3 is
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal in_port  : std_logic_vector(31 downto 0) := x"00000000";
    signal halted   : std_logic;
    signal pc       : std_logic_vector(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;
begin
    clk <= not clk after CLK_PERIOD / 2;

    dut: entity work.processor_top
        generic map (MEM_FILE => "programs/test3.mem")
        port map (
            clk => clk, rst => rst, intr_in => '0', in_port => in_port,
            halted => halted, dbg_pc => pc
        );

    process(clk)
    begin
        if rising_edge(clk) then
            case to_integer(unsigned(pc)) is
                when 165 => in_port <= x"00000005"; -- IN R1 at PC 0xA3+2
                when 166 => in_port <= x"00000010"; -- IN R2 at PC 0xA4+2
                when others => null;
            end case;
        end if;
    end process;

    stim: process
    begin
        rst <= '1'; wait for 2 * CLK_PERIOD; rst <= '0';
        wait until halted = '1'; wait for 2 * CLK_PERIOD;
        report "Test3 completed"; stop;
    end process;
end architecture;
