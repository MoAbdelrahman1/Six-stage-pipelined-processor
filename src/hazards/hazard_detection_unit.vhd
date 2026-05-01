-- ============================================================================
-- Hazard Detection Unit
-- ============================================================================
-- Detects hazards that cannot be resolved by forwarding alone:
--   - Load-use hazards  → insert stall (bubble)
--   - Control hazards   → flush pipeline on branch misprediction
--   - Structural hazards (Von Neumann memory contention)
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hazard_detection_unit is
    port (
        -- From ID stage
        rs1_addr_id     : in  std_logic_vector(2 downto 0);
        rs2_addr_id     : in  std_logic_vector(2 downto 0);
        -- From EX1 stage (for load-use detection)
        rd_addr_ex1     : in  std_logic_vector(2 downto 0);
        mem_read_ex1    : in  std_logic;
        -- Branch signals
        branch_taken    : in  std_logic;
        -- Control outputs
        stall_if        : out std_logic;
        stall_id        : out std_logic;
        flush_if_id     : out std_logic;
        flush_id_ex1    : out std_logic
    );
end entity hazard_detection_unit;

architecture behavioral of hazard_detection_unit is
begin
    -- TODO: Implement hazard detection logic
end architecture behavioral;
