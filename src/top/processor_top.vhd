-- ============================================================================
-- Processor Top-Level Entity (Section 4.1)
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity processor_top is
    port (
        clk : in std_logic;
        rst : in std_logic
    );
end entity processor_top;

architecture structural of processor_top is
    -- Internal signals for memory bus, pipeline registers, etc.
    -- (Omitted for brevity in skeleton, would connect all stages)
begin
    -- 1. Memory Instance (Unified)
    MEM_INST: entity work.data_memory
        port map ( clk => clk, rst => rst, others => open );

    -- 2. Pipeline Stages (IF, ID, EX1, EX2, MEM, WB)
    -- 3. Pipeline Registers (IF/ID, ID/EX1, etc.)
    -- 4. Units (ALU, Register File, Control, Hazard)
end architecture structural;
