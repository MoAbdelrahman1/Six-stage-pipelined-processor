library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        instr_addr  : in  std_logic_vector(31 downto 0);
        instr_out   : out std_logic_vector(31 downto 0);

        data_addr   : in  std_logic_vector(31 downto 0);
        data_in     : in  std_logic_vector(31 downto 0);
        mem_read    : in  std_logic;
        mem_write   : in  std_logic;
        data_out    : out std_logic_vector(31 downto 0)
    );
end entity data_memory;

architecture behavioral of data_memory is
    type ram_type is array (0 to 4095) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (
        0 => x"00000000",
        others => (others => '0')
    );
begin
    instr_out <= ram(to_integer(unsigned(instr_addr(11 downto 0))));

    process(clk)
    begin
        if rising_edge(clk) then
            if mem_write = '1' then
                ram(to_integer(unsigned(data_addr(11 downto 0)))) <= data_in;
            end if;
            if mem_read = '1' then
                data_out <= ram(to_integer(unsigned(data_addr(11 downto 0))));
            end if;
        end if;
    end process;
end architecture behavioral;
