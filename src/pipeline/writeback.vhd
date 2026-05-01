-- ============================================================================
-- Stage 6: WRITE-BACK (WB)
-- ============================================================================
-- Responsibilities:
--   - Select data source (ALU result or Memory data) via mem_to_reg mux
--   - Write result back to the Register File
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity writeback_stage is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        -- Inputs from MEM/WB register
        mem_data       : in  std_logic_vector(15 downto 0);
        alu_result     : in  std_logic_vector(15 downto 0);
        rd_addr_in     : in  std_logic_vector(2 downto 0);
        -- Control signals in
        reg_write      : in  std_logic;
        mem_to_reg     : in  std_logic;
        -- Outputs to Register File
        wb_enable      : out std_logic;
        wb_addr        : out std_logic_vector(2 downto 0);
        wb_data        : out std_logic_vector(15 downto 0)
    );
end entity writeback_stage;

architecture behavioral of writeback_stage is
begin
    -- TODO: Implement write-back logic
end architecture behavioral;
