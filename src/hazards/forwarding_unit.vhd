library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity forwarding_unit is
    port (
        rs1_addr_ex1    : in  std_logic_vector(2 downto 0);
        rs2_addr_ex1    : in  std_logic_vector(2 downto 0);

        rd_addr_ex2     : in  std_logic_vector(2 downto 0);
        rd_addr_mem     : in  std_logic_vector(2 downto 0);
        rd_addr_wb      : in  std_logic_vector(2 downto 0);

        reg_write_ex2   : in  std_logic;
        reg_write_mem   : in  std_logic;
        reg_write_wb    : in  std_logic;

        fwd_sel_a       : out std_logic_vector(1 downto 0);
        fwd_sel_b       : out std_logic_vector(1 downto 0)
    );
end entity forwarding_unit;

architecture behavioral of forwarding_unit is
begin
    process(rs1_addr_ex1, rs2_addr_ex1, rd_addr_ex2, rd_addr_mem, rd_addr_wb,
            reg_write_ex2, reg_write_mem, reg_write_wb)
    begin
        fwd_sel_a <= "00";
        fwd_sel_b <= "00";

        -- Prefer the newest in-flight value.
        if reg_write_ex2 = '1' and rd_addr_ex2 = rs1_addr_ex1 then
            fwd_sel_a <= "01";
        elsif reg_write_mem = '1' and rd_addr_mem = rs1_addr_ex1 then
            fwd_sel_a <= "10";
        elsif reg_write_wb = '1' and rd_addr_wb = rs1_addr_ex1 then
            fwd_sel_a <= "11";
        end if;

        if reg_write_ex2 = '1' and rd_addr_ex2 = rs2_addr_ex1 then
            fwd_sel_b <= "01";
        elsif reg_write_mem = '1' and rd_addr_mem = rs2_addr_ex1 then
            fwd_sel_b <= "10";
        elsif reg_write_wb = '1' and rd_addr_wb = rs2_addr_ex1 then
            fwd_sel_b <= "11";
        end if;
    end process;
end architecture behavioral;
