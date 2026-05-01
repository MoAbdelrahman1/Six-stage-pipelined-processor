-- ============================================================================
-- Data Memory
-- ============================================================================
-- Von Neumann unified memory (shared instruction + data space).
-- Used by the Memory stage for LOAD/STORE operations.
-- Also provides instruction fetch port for the Fetch stage.
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        -- Data port (MEM stage)
        data_addr   : in  std_logic_vector(15 downto 0);
        data_in     : in  std_logic_vector(15 downto 0);
        mem_read    : in  std_logic;
        mem_write   : in  std_logic;
        data_out    : out std_logic_vector(15 downto 0);
        -- Instruction port (IF stage)
        instr_addr  : in  std_logic_vector(15 downto 0);
        instr_out   : out std_logic_vector(15 downto 0)
    );
end entity data_memory;

architecture behavioral of data_memory is
begin
    -- TODO: Implement Von Neumann unified memory
end architecture behavioral;
