-- ============================================================================
-- Processor Top-Level Entity
-- ============================================================================
-- Pipeline: IF -> ID -> EX1 -> EX2 -> MEM -> WB
-- Architecture: Von Neumann (unified instruction + data memory)
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity processor_top is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        port_in   : in  std_logic_vector(15 downto 0);
        port_out  : out std_logic_vector(15 downto 0)
    );
end entity processor_top;

architecture structural of processor_top is
begin
    -- TODO: Instantiate and wire all stages
end architecture structural;
