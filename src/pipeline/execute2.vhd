library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity execute2_stage is
    port (
        clk            : in  std_logic;

        alu_result     : in  std_logic_vector(31 downto 0);
        rdata2_in      : in  std_logic_vector(31 downto 0);
        imm_in         : in  std_logic_vector(31 downto 0);
        ccr_in         : in  std_logic_vector(2 downto 0);

        branch_type    : in  std_logic_vector(2 downto 0);

        effective_addr : out std_logic_vector(31 downto 0);
        branch_taken   : out std_logic;
        branch_addr    : out std_logic_vector(31 downto 0)
    );
end entity execute2_stage;

architecture behavioral of execute2_stage is
begin
    effective_addr <= std_logic_vector(unsigned(alu_result) + unsigned(imm_in));

    process(branch_type, ccr_in, imm_in)
    begin
        branch_taken <= '0';
        branch_addr  <= imm_in;
        case branch_type is
            when "000" =>
                if ccr_in(0) = '1' then branch_taken <= '1'; end if;
            when "001" =>
                if ccr_in(1) = '1' then branch_taken <= '1'; end if;
            when "010" =>
                if ccr_in(2) = '1' then branch_taken <= '1'; end if;
            when "011" =>
                branch_taken <= '1';
            when others =>
                branch_taken <= '0';
        end case;
    end process;
end architecture behavioral;
