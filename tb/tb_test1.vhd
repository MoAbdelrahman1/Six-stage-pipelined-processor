library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library STD;
use STD.ENV.ALL;

entity tb_test1 is
end entity;

architecture sim of tb_test1 is
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
        generic map (MEM_FILE => "programs/test1.mem")
        port map (
            clk => clk, rst => rst, intr_in => intr_in, in_port => in_port,
            out_port => out_port, halted => halted, dbg_pc => pc, dbg_sp => sp,
            dbg_flags => flags, dbg_r0 => r0, dbg_r1 => r1, dbg_r2 => r2,
            dbg_r3 => r3, dbg_r4 => r4, dbg_r5 => r5, dbg_r6 => r6, dbg_r7 => r7
        );

    -- Drive in_port based on PC
    process(clk)
    begin
        if rising_edge(clk) then
            -- IN is at index 18 (0x12) in the source?
            -- Let's re-calculate:
            -- .org 0
            -- .word 5  (addr 0)
            -- .org 5
            -- LDM R0, 1 (addr 5)
            -- LDM R1, AAAA (addr 6)
            -- LDM R2, FFFF (addr 7)
            -- INC R0 (addr 8)
            -- MOV R4, R1 (addr 9)
            -- NOT R1 (addr 10)
            -- MOV R3, R0 (addr 11)
            -- IN R0 (addr 12 / 0x0C)
            -- It enters EX1 when Fetch PC is 14 (0x0E).
            if unsigned(pc) = 14 then
                in_port <= x"FFFFFFFF";
            else
                in_port <= x"00000000";
            end if;
        end if;
    end process;

    stim: process
    begin
        rst <= '1';
        wait for 2 * CLK_PERIOD;
        rst <= '0';
        
        wait for 100 * CLK_PERIOD;
        report "Test1 completed";
        stop;
    end process;
end architecture;
