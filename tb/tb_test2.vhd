library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library STD;
use STD.ENV.ALL;

entity tb_test2 is
end entity;

architecture sim of tb_test2 is
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal intr_in  : std_logic := '0';
    signal in_port  : std_logic_vector(31 downto 0) := x"00000000";
    signal out_port : std_logic_vector(31 downto 0);
    signal halted   : std_logic;
    signal pc       : std_logic_vector(31 downto 0);
    signal sp       : std_logic_vector(31 downto 0);
    signal flags    : std_logic_vector(2 downto 0);
    signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;
begin
    clk <= not clk after CLK_PERIOD / 2;

    dut: entity work.processor_top
        generic map (MEM_FILE => "programs/test2.mem")
        port map (
            clk => clk, rst => rst, intr_in => intr_in, in_port => in_port,
            out_port => out_port, halted => halted, dbg_pc => pc, dbg_sp => sp,
            dbg_flags => flags, dbg_r0 => r0, dbg_r1 => r1, dbg_r2 => r2,
            dbg_r3 => r3, dbg_r4 => r4, dbg_r5 => r5, dbg_r6 => r6, dbg_r7 => r7
        );

    -- Drive in_port based on PC
    process(clk)
        variable v_pc : integer;
    begin
        if rising_edge(clk) then
            v_pc := to_integer(unsigned(pc));
            case v_pc is
                when 18 => in_port <= x"00000032"; -- R1=50 at PC 0x10+2
                when 19 => in_port <= x"0000001E"; -- R2=30 at PC 0x11+2
                when 20 => in_port <= x"0000012C"; -- R3=300 at PC 0x12+2
                when 21 => in_port <= x"00000064"; -- R4=100 at PC 0x13+2
                when 85 => in_port <= x"00000037"; -- R1=55 at PC 0x53+2
                when 98 => in_port <= x"0000004B"; -- R1=75 at PC 0x60+2
                when 130 => in_port <= x"000002BC"; -- R6=700 at PC 0x80+2
                when others => null;
            end case;
        end if;
    end process;

    stim: process
    begin
        rst <= '1';
        wait for 2 * CLK_PERIOD;
        rst <= '0';
        
        wait until halted = '1';
        wait for 2 * CLK_PERIOD;
        report "Test2 completed";
        stop;
    end process;
end architecture;
