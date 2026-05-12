library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity writeback_stage is
    port (
        mem_data       : in  std_logic_vector(31 downto 0);
        alu_result     : in  std_logic_vector(31 downto 0);
        pc_plus1       : in  std_logic_vector(31 downto 0);

        mem_to_reg     : in  std_logic_vector(1 downto 0);

        wb_data        : out std_logic_vector(31 downto 0)
    );
end entity writeback_stage;

architecture behavioral of writeback_stage is
begin
    wb_data <= alu_result when mem_to_reg = "00" else
               mem_data   when mem_to_reg = "01" else
               pc_plus1   when mem_to_reg = "10" else
               alu_result;
end architecture behavioral;
