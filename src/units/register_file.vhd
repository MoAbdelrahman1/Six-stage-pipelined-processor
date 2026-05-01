-- ============================================================================
-- Register File
-- ============================================================================
-- General-purpose register file.
-- Supports 2 simultaneous reads (Decode stage) and 1 write (Write-Back stage).
-- 8 registers × 16 bits (R0–R7), or adjust as needed.
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        -- Read ports (Decode stage)
        read_addr1  : in  std_logic_vector(2 downto 0);
        read_addr2  : in  std_logic_vector(2 downto 0);
        read_data1  : out std_logic_vector(15 downto 0);
        read_data2  : out std_logic_vector(15 downto 0);
        -- Write port (Write-Back stage)
        write_en    : in  std_logic;
        write_addr  : in  std_logic_vector(2 downto 0);
        write_data  : in  std_logic_vector(15 downto 0)
    );
end entity register_file;

architecture behavioral of register_file is
begin
    -- TODO: Implement register file
end architecture behavioral;
