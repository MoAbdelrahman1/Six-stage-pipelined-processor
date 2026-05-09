-- ============================================================================
-- Pipeline Registers (Section 8)
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 8.1 IF/ID Register
entity if_id_register is
    port (
        clk, rst, en, clr : in  std_logic;
        inst_in           : in  std_logic_vector(31 downto 0);
        pc_plus1_in       : in  std_logic_vector(31 downto 0);
        inst_out          : out std_logic_vector(31 downto 0);
        pc_plus1_out      : out std_logic_vector(31 downto 0)
    );
end if_id_register;

architecture arch of if_id_register is
begin
    process(clk, rst)
    begin
        if rst = '1' or clr = '1' then
            inst_out <= (others => '0');
            pc_plus1_out <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                inst_out <= inst_in;
                pc_plus1_out <= pc_plus1_in;
            end if;
        end if;
end process;
end arch;

-- 8.2 ID/EX1 Register
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity id_ex1_register is
    port (
        clk, rst, clr : in  std_logic;
        rdata1_in     : in  std_logic_vector(31 downto 0);
        rdata2_in     : in  std_logic_vector(31 downto 0);
        imm_in        : in  std_logic_vector(31 downto 0);
        rdst_in       : in  std_logic_vector(2 downto 0);
        rs1_in        : in  std_logic_vector(2 downto 0);
        rs2_in        : in  std_logic_vector(2 downto 0);
        pc_plus1_in   : in  std_logic_vector(31 downto 0);
        ctrl_in       : in  std_logic_vector(15 downto 0); -- Placeholder for control signals
        rdata1_out    : out std_logic_vector(31 downto 0);
        rdata2_out    : out std_logic_vector(31 downto 0);
        imm_out       : out std_logic_vector(31 downto 0);
        rdst_out      : out std_logic_vector(2 downto 0);
        rs1_out       : out std_logic_vector(2 downto 0);
        rs2_out       : out std_logic_vector(2 downto 0);
        pc_plus1_out  : out std_logic_vector(31 downto 0);
        ctrl_out      : out std_logic_vector(15 downto 0)
    );
end id_ex1_register;

architecture arch of id_ex1_register is
begin
    process(clk, rst)
    begin
        if rst = '1' or clr = '1' then
            rdata1_out <= (others => '0'); rdata2_out <= (others => '0');
            imm_out <= (others => '0'); rdst_out <= (others => '0');
            rs1_out <= (others => '0'); rs2_out <= (others => '0');
            pc_plus1_out <= (others => '0'); ctrl_out <= (others => '0');
        elsif rising_edge(clk) then
            rdata1_out <= rdata1_in; rdata2_out <= rdata2_in;
            imm_out <= imm_in; rdst_out <= rdst_in;
            rs1_out <= rs1_in; rs2_out <= rs2_in;
            pc_plus1_out <= pc_plus1_in; ctrl_out <= ctrl_in;
        end if;
    end process;
end arch;

-- Note: EX1/EX2, EX2/MEM, and MEM/WB follow similar latching patterns
-- based on the fields defined in sections 8.3, 8.4, and 8.5.
