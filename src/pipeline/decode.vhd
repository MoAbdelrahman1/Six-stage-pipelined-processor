library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decode_stage is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;

        instruction_in : in  std_logic_vector(31 downto 0);
        pc_in          : in  std_logic_vector(31 downto 0);

        rd_addr        : out std_logic_vector(2 downto 0);
        rs1_addr       : out std_logic_vector(2 downto 0);
        rs2_addr       : out std_logic_vector(2 downto 0);
        immediate      : out std_logic_vector(31 downto 0);
        func           : out std_logic_vector(2 downto 0);
        opcode         : out std_logic_vector(3 downto 0);
        pc_out         : out std_logic_vector(31 downto 0)
    );
end entity decode_stage;

architecture behavioral of decode_stage is
begin
    opcode    <= instruction_in(31 downto 28);
    rd_addr   <= instruction_in(27 downto 25);
    rs1_addr  <= instruction_in(24 downto 22);
    rs2_addr  <= instruction_in(21 downto 19);
    func      <= instruction_in(18 downto 16);
    pc_out    <= pc_in;

    immediate <= std_logic_vector(resize(signed(instruction_in(15 downto 0)), 32));
end architecture behavioral;
