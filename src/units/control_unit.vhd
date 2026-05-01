-- ============================================================================
-- Control Unit
-- ============================================================================
-- Generates all control signals based on the instruction opcode.
-- Outputs drive the datapath through the pipeline:
--   ALU operation, register write, memory read/write, branching, etc.
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit is
    port (
        opcode     : in  std_logic_vector(4 downto 0);
        -- Control signal outputs
        alu_op     : out std_logic_vector(3 downto 0);
        reg_write  : out std_logic;
        mem_read   : out std_logic;
        mem_write  : out std_logic;
        mem_to_reg : out std_logic;
        alu_src    : out std_logic;
        branch     : out std_logic;
        jump       : out std_logic
    );
end entity control_unit;

architecture behavioral of control_unit is
begin
    -- TODO: Implement control signal generation
end architecture behavioral;
