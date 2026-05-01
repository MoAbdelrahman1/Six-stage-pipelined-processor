-- ============================================================================
-- Forwarding Unit
-- ============================================================================
-- Detects data hazards and selects forwarding paths to resolve them.
-- Forwards results from EX2, MEM, or WB stages back to EX1 inputs
-- to avoid pipeline stalls where possible.
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity forwarding_unit is
    port (
        -- Source register addresses (from ID/EX1)
        rs1_addr_ex1    : in  std_logic_vector(2 downto 0);
        rs2_addr_ex1    : in  std_logic_vector(2 downto 0);
        -- Destination register addresses from later stages
        rd_addr_ex2     : in  std_logic_vector(2 downto 0);
        rd_addr_mem     : in  std_logic_vector(2 downto 0);
        rd_addr_wb      : in  std_logic_vector(2 downto 0);
        -- Write-enable signals from later stages
        reg_write_ex2   : in  std_logic;
        reg_write_mem   : in  std_logic;
        reg_write_wb    : in  std_logic;
        -- Forwarding mux selectors
        fwd_sel_a       : out std_logic_vector(1 downto 0);
        fwd_sel_b       : out std_logic_vector(1 downto 0)
    );
end entity forwarding_unit;

architecture behavioral of forwarding_unit is
begin
    -- TODO: Implement forwarding logic
end architecture behavioral;
