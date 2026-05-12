library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fetch_stage is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        stall       : in  std_logic;

        branch_taken : in  std_logic;
        branch_addr  : in  std_logic_vector(31 downto 0);

        instr_addr  : out std_logic_vector(31 downto 0);
        instruction : in  std_logic_vector(31 downto 0);

        pc_out      : out std_logic_vector(31 downto 0);
        instr_out   : out std_logic_vector(31 downto 0)
    );
end entity fetch_stage;

architecture behavioral of fetch_stage is
    signal pc_reg : unsigned(31 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            pc_reg <= (others => '0');
        elsif rising_edge(clk) then
            if stall = '0' then
                if branch_taken = '1' then
                    pc_reg <= unsigned(branch_addr);
                else
                    pc_reg <= pc_reg + 1;
                end if;
            end if;
        end if;
    end process;

    instr_addr <= std_logic_vector(pc_reg);
    pc_out     <= std_logic_vector(pc_reg + 1);
    instr_out  <= instruction;
end architecture behavioral;
