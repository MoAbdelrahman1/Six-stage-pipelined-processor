library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
    signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;
begin
    -- Clock Generation
    clk <= not clk after CLK_PERIOD / 2;

    -- Device Under Test (DUT)
    dut: entity work.processor_top
        generic map (MEM_FILE => "programs/test5.mem")
        port map (
            clk => clk, rst => rst, intr_in => intr_in, in_port => in_port,
            out_port => out_port, halted => halted, dbg_pc => pc, dbg_sp => sp,
            dbg_flags => flags, dbg_r0 => r0, dbg_r1 => r1, dbg_r2 => r2,
            dbg_r3 => r3, dbg_r4 => r4, dbg_r5 => r5, dbg_r6 => r6, dbg_r7 => r7
        );

    ---------------------------------------------------------------------------
    -- Hardware Interrupt Stimulus (Tuned exactly for test5.mem)
    -- 1. Triggers First Interrupt at PC 0x75 to enter the ISR.
    -- 2. Triggers Second Interrupt at PC 0x904 (right after RTI) to test loop.
    ---------------------------------------------------------------------------
    hw_interrupt_stim: process
    begin
        intr_in <= '0';
        
        -- FIRST INTERRUPT: Target the 'INC R1' instruction at address 0x75
        wait until rising_edge(clk) and pc = x"00000075";
        report "Triggering FIRST Hardware Interrupt to enter ISR (PC=0x0075)";
        intr_in <= '1';
        wait until rising_edge(clk);
        intr_in <= '0';
        
        -- SECOND INTERRUPT: Target the instruction after RTI at address 0x904
        -- (This only happens after the processor finishes the first ISR)
        wait until rising_edge(clk) and pc = x"00000904";
        report "Triggering SECOND Hardware Interrupt corner case (PC=0x0904)";
        intr_in <= '1';
        wait until rising_edge(clk);
        intr_in <= '0';
        
        wait;
    end process;

    ---------------------------------------------------------------------------
    -- Input Port Stimulus (Synchronized with Fetch PC)
    ---------------------------------------------------------------------------
    process(clk)
        variable v_pc : integer;
    begin
        if rising_edge(clk) then
            v_pc := to_integer(unsigned(pc));
            case v_pc is
                when 18   => in_port <= x"0000001E"; -- R1=30 at PC 0x10+2
                when 19   => in_port <= x"00000032"; -- R2=50 at PC 0x11+2
                when 20   => in_port <= x"00000064"; -- R3=100 at PC 0x12+2
                when 21   => in_port <= x"0000012C"; -- R4=300 at PC 0x13+2
                when 85   => in_port <= x"0000003C"; -- R1=60 at PC 0x53+2
                when 98   => in_port <= x"00000046"; -- R1=70 at PC 0x60+2
                when 130  => in_port <= x"000002BC"; -- R6=700 at PC 0x80+2
                -- ISR Input
                when 2306 => in_port <= x"00000005"; -- R7=5 at PC 0x900+2
                when others => null;
            end case;
        end if;
    end process;

    ---------------------------------------------------------------------------
    -- Main Control Process
    ---------------------------------------------------------------------------
    stim: process
    begin
        -- Reset sequence
        rst <= '1';
        wait for 2 * CLK_PERIOD;
        rst <= '0';
        
        -- Wait until the processor reaches the HLT instruction
        wait until halted = '1';
        wait for 2 * CLK_PERIOD;
        report "TA test completed";
        stop;
    end process;

end architecture;
