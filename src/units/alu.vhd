library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    port (
        operand_a  : in  std_logic_vector(31 downto 0);
        operand_b  : in  std_logic_vector(31 downto 0);
        alu_op     : in  std_logic_vector(2 downto 0);
        result     : out std_logic_vector(31 downto 0);
        flags      : out std_logic_vector(2 downto 0)
    );
end entity alu;

architecture behavioral of alu is
begin
    process(operand_a, operand_b, alu_op)
        variable res_long : unsigned(32 downto 0);
        variable res_32   : std_logic_vector(31 downto 0);
        variable c_out    : std_logic := '0';
    begin
        res_32 := (others => '0');
        c_out  := '0';

        case alu_op is
            when "000" =>
                res_long := unsigned('0' & operand_a) + unsigned('0' & operand_b);
                res_32   := std_logic_vector(res_long(31 downto 0));
                c_out    := res_long(32);
            when "001" =>
                res_long := unsigned('0' & operand_a) - unsigned('0' & operand_b);
                res_32   := std_logic_vector(res_long(31 downto 0));
                c_out    := res_long(32);
            when "010" =>
                res_32   := operand_a and operand_b;
            when "011" =>
                res_32   := not operand_a;
            when "100" =>
                res_long := unsigned('0' & operand_a) + 1;
                res_32   := std_logic_vector(res_long(31 downto 0));
                c_out    := res_long(32);
            when "101" =>
                res_32   := operand_a;
            when "110" =>
                c_out    := '1';
                res_32   := operand_a;
            when others =>
                res_32   := (others => '0');
        end case;

        result <= res_32;
        
        flags(0) <= '1' when res_32 = x"00000000" else '0';
        flags(1) <= res_32(31);
        flags(2) <= c_out;
    end process;
end architecture behavioral;
