-- ============================================================================
-- Stage 5: MEMORY (MEM) - Section 7.5
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity memory_stage is
    port (
        -- From EX2
        effective_addr : in  std_logic_vector(31 downto 0);
        alu_result     : in  std_logic_vector(31 downto 0);
        store_data     : in  std_logic_vector(31 downto 0);
        -- Control signals
        mem_read       : in  std_logic;
        mem_write      : in  std_logic;
        -- Memory Interface (Port B)
        mem_bus_addr   : out std_logic_vector(31 downto 0);
        mem_bus_in     : out std_logic_vector(31 downto 0);
        mem_bus_out    : in  std_logic_vector(31 downto 0);
        -- Outputs to WB
        mem_data_out   : out std_logic_vector(31 downto 0);
        alu_result_out : out std_logic_vector(31 downto 0)
    );
end entity memory_stage;

architecture behavioral of memory_stage is
begin
    mem_bus_addr   <= effective_addr;
    mem_bus_in     <= store_data;
    mem_data_out   <= mem_bus_out;
    alu_result_out <= alu_result;
end architecture behavioral;
