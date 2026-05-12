library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        read_addr1  : in  std_logic_vector(2 downto 0);
        read_addr2  : in  std_logic_vector(2 downto 0);
        read_data1  : out std_logic_vector(31 downto 0);
        read_data2  : out std_logic_vector(31 downto 0);

        write_en    : in  std_logic;
        write_addr  : in  std_logic_vector(2 downto 0);
        write_data  : in  std_logic_vector(31 downto 0)
    );
end entity register_file;

architecture behavioral of register_file is
    type reg_array is array (0 to 7) of std_logic_vector(31 downto 0);
    signal registers : reg_array := (others => (others => '0'));
begin
    read_data1 <= registers(to_integer(unsigned(read_addr1)));
    read_data2 <= registers(to_integer(unsigned(read_addr2)));

    process(clk, rst)
    begin
        if rst = '1' then
            registers <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if write_en = '1' then
                registers(to_integer(unsigned(write_addr))) <= write_data;
            end if;
        end if;
    end process;
end architecture behavioral;
