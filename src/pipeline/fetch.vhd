-- ============================================================================
-- Stage 1: FETCH (IF)
-- ============================================================================
-- Responsibilities:
--   - Read instruction from memory using the Program Counter (PC)
--   - Increment PC (PC + 1) or load branch/jump target
--   - Write instruction + next PC into IF/ID pipeline register
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fetch_stage is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        stall       : in  std_logic;
        flush       : in  std_logic;
        -- Branch / Jump resolution from later stages
        branch_taken : in  std_logic;
        branch_addr  : in  std_logic_vector(15 downto 0);
        -- Output to IF/ID register
        pc_out      : out std_logic_vector(15 downto 0);
        instruction : out std_logic_vector(15 downto 0)
    );
end entity fetch_stage;

architecture behavioral of fetch_stage is
begin
    -- TODO: Implement fetch logic
end architecture behavioral;
