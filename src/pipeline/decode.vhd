-- ============================================================================
-- Stage 2: DECODE (ID)
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decode_stage is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        -- Input from IF/ID register
        instruction_in : in  std_logic_vector(31 downto 0);
        pc_in          : in  std_logic_vector(31 downto 0);
        -- Outputs to ID/EX1 register
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
    -- Fields according to spec: [31:28] Opcode, [27:25] Rdst, [24:22] Rsrc1, [21:19] Rsrc2, [18:16] Func, [15:0] Imm
    opcode    <= instruction_in(31 downto 28);
    rd_addr   <= instruction_in(27 downto 25);
    rs1_addr  <= instruction_in(24 downto 22);
    rs2_addr  <= instruction_in(21 downto 19);
    func      <= instruction_in(18 downto 16);
    pc_out    <= pc_in;

    -- Sign-extend 16-bit immediate to 32-bit
    immediate <= std_logic_vector(resize(signed(instruction_in(15 downto 0)), 32));
end architecture behavioral;
