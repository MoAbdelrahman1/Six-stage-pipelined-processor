-- ============================================================================
-- Arithmetic Logic Unit (ALU)
-- ============================================================================
-- Performs arithmetic and logical operations.
-- Used by both EX1 and EX2 stages.
-- Generates condition flags: Zero (Z), Negative (N), Carry (C), Overflow (V)
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    port (
        operand_a  : in  std_logic_vector(15 downto 0);
        operand_b  : in  std_logic_vector(15 downto 0);
        alu_op     : in  std_logic_vector(3 downto 0);
        result     : out std_logic_vector(15 downto 0);
        flags      : out std_logic_vector(3 downto 0)  -- Z, N, C, V
    );
end entity alu;

architecture behavioral of alu is
begin
    -- TODO: Implement ALU operations
end architecture behavioral;
