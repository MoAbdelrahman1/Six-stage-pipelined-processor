library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library STD;
use STD.ENV.ALL;

entity tb_ta_test is
end entity;

architecture sim of tb_ta_test is
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal intr_in  : std_logic := '0';
    signal in_port  : std_logic_vector(31 downto 0) := x"00000000";
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

    constant CLK_PERIOD : time := 10 ns;

    type input_array_t is array (natural range <>) of std_logic_vector(31 downto 0);
    constant INPUTS : input_array_t := (
        x"00000032", -- 0: R1 = 0x32 (50)
        x"0000001E", -- 1: R2 = 0x1E (30)
        x"0000012C", -- 2: R3 = 0x12C (300)
        x"00000064", -- 3: R4 = 0x64 (100)
        x"00000037", -- 4: R1 = 0x37 (55)
        x"0000004B", -- 5: R1 = 0x4B (75)
        x"000002BC"  -- 6: R6 = 0x2BC (700)
    );
    signal input_index : integer := 0;
begin
    clk <= not clk after CLK_PERIOD / 2;

    dut: entity work.processor_top
        generic map (
            MEM_FILE => "programs/ta_test.mem"
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
        wait for 2 * CLK_PERIOD;
        rst <= '0';
        wait for 2 * CLK_PERIOD;

        -- Drive IN values in order as the program consumes them.
        for i in INPUTS'range loop
            in_port <= INPUTS(i);
            wait for 6 * CLK_PERIOD;
        end loop;

        wait until halted = '1';
        wait for 2 * CLK_PERIOD;
        report "TA test completed";
        stop;
    end process;
end architecture;
