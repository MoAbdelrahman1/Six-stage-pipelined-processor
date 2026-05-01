-- ============================================================================
-- Stage 5: MEMORY (MEM)
-- ============================================================================
-- Responsibilities:
--   - Access data memory for LOAD / STORE instructions
--   - Pass ALU result through for non-memory instructions
--   - Handle stack operations (PUSH / POP) if applicable
--   - Write results into MEM/WB pipeline register
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_stage is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        -- Inputs from EX2/MEM register
        alu_result     : in  std_logic_vector(15 downto 0);
        write_data     : in  std_logic_vector(15 downto 0);
        rd_addr_in     : in  std_logic_vector(2 downto 0);
        -- Control signals in
        mem_read       : in  std_logic;
        mem_write      : in  std_logic;
        reg_write      : in  std_logic;
        mem_to_reg     : in  std_logic;
        -- Outputs to MEM/WB register
        mem_data       : out std_logic_vector(15 downto 0);
        alu_result_out : out std_logic_vector(15 downto 0);
        rd_addr_out    : out std_logic_vector(2 downto 0)
    );
end entity memory_stage;

architecture behavioral of memory_stage is
begin
    -- TODO: Implement memory access logic
end architecture behavioral;
