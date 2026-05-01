-- ============================================================================
-- Pipeline Registers
-- ============================================================================
-- Inter-stage registers for the 6-stage pipeline:
--   IF/ID  →  ID/EX1  →  EX1/EX2  →  EX2/MEM  →  MEM/WB
--
-- Each register latches data on the rising clock edge.
-- Supports stall (hold current value) and flush (clear to NOP).
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ===== IF/ID Register =====
entity if_id_register is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        stall       : in  std_logic;
        flush       : in  std_logic;
        -- Inputs
        pc_in       : in  std_logic_vector(15 downto 0);
        instr_in    : in  std_logic_vector(15 downto 0);
        -- Outputs
        pc_out      : out std_logic_vector(15 downto 0);
        instr_out   : out std_logic_vector(15 downto 0)
    );
end entity if_id_register;

architecture behavioral of if_id_register is
begin
    -- TODO: Implement IF/ID pipeline register
end architecture behavioral;

-- ===== ID/EX1 Register =====
-- TODO: Implement ID/EX1 pipeline register entity

-- ===== EX1/EX2 Register =====
-- TODO: Implement EX1/EX2 pipeline register entity

-- ===== EX2/MEM Register =====
-- TODO: Implement EX2/MEM pipeline register entity

-- ===== MEM/WB Register =====
-- TODO: Implement MEM/WB pipeline register entity
