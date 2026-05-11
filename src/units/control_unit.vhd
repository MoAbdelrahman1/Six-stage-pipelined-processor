library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    port (
        opcode     : in  std_logic_vector(3 downto 0);
        func       : in  std_logic_vector(2 downto 0);

        reg_write  : out std_logic;
        reg_dst    : out std_logic_vector(1 downto 0);
        alu_src    : out std_logic_vector(1 downto 0);
        alu_op     : out std_logic_vector(2 downto 0);
        mem_read   : out std_logic;
        mem_write  : out std_logic;
        mem_to_reg : out std_logic_vector(1 downto 0);
        branch     : out std_logic_vector(2 downto 0);
        pc_src     : out std_logic_vector(1 downto 0);
        sp_op      : out std_logic_vector(1 downto 0);
        out_port_en: out std_logic;
        flag_write : out std_logic;
        is_interrupt:out std_logic
    );
end entity control_unit;

architecture behavioral of control_unit is
begin
    process(opcode, func)
    begin
        reg_write <= '0'; reg_dst <= "00"; alu_src <= "00"; alu_op <= "101";
        mem_read <= '0'; mem_write <= '0'; mem_to_reg <= "00"; branch <= "000";
        pc_src <= "00"; sp_op <= "00"; out_port_en <= '0'; flag_write <= '0';
        is_interrupt <= '0';

        case opcode is
            when "0011" =>
                reg_write <= '1';
                flag_write <= '1';
                alu_op <= func;
            
            when "0100" =>
                reg_write <= '1';
                flag_write <= '1';
                alu_src <= "01";
                alu_op <= "000";
            
            when "0110" =>
                if func = "000" then
                    reg_write <= '1';
                    alu_src <= "01";
                    alu_op <= "101";
                elsif func = "001" then
                    reg_write <= '1';
                    mem_read <= '1';
                    mem_to_reg <= "01";
                elsif func = "011" then
                    mem_write <= '1';
                end if;

            when "0111" =>
                branch <= func;
            
            when others => null;
        end case;
    end process;
end architecture behavioral;
