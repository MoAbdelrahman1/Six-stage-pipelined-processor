-- ============================================================================
-- Stage 4: EXECUTE 2 (EX2)
-- ============================================================================
-- Responsibilities:
--   - Second cycle of ALU execution
--   - Complete multi-cycle operations (multiply result, barrel shift, etc.)
--   - Finalize ALU result
--   - Write results into EX2/MEM pipeline register
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity execute2_stage is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        stall          : in  std_logic;
        -- Inputs from EX1/EX2 register
        alu_partial    : in  std_logic_vector(15 downto 0);
        read_data2_in  : in  std_logic_vector(15 downto 0);
        rd_addr_in     : in  std_logic_vector(2 downto 0);
        flags_in       : in  std_logic_vector(3 downto 0);
        -- Control signals in (forwarded from decode)
        mem_read       : in  std_logic;
        mem_write      : in  std_logic;
        reg_write      : in  std_logic;
        mem_to_reg     : in  std_logic;
        -- Outputs to EX2/MEM register
        alu_result     : out std_logic_vector(15 downto 0);
        read_data2_out : out std_logic_vector(15 downto 0);
        rd_addr_out    : out std_logic_vector(2 downto 0);
        flags_out      : out std_logic_vector(3 downto 0)
    );
end entity execute2_stage;

architecture behavioral of execute2_stage is
begin
    -- TODO: Implement EX2 logic
end architecture behavioral;
