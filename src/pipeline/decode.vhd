-- ============================================================================
-- Stage 2: DECODE (ID)
-- ============================================================================
-- Responsibilities:
--   - Decode instruction opcode and extract operands
--   - Read source registers from Register File
--   - Generate control signals
--   - Sign-extend immediate values
--   - Write decoded data into ID/EX1 pipeline register
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decode_stage is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        stall          : in  std_logic;
        flush          : in  std_logic;
        -- Input from IF/ID register
        instruction_in : in  std_logic_vector(15 downto 0);
        pc_in          : in  std_logic_vector(15 downto 0);
        -- Write-back interface (from WB stage)
        wb_enable      : in  std_logic;
        wb_addr        : in  std_logic_vector(2 downto 0);
        wb_data        : in  std_logic_vector(15 downto 0);
        -- Outputs to ID/EX1 register
        read_data1     : out std_logic_vector(15 downto 0);
        read_data2     : out std_logic_vector(15 downto 0);
        immediate      : out std_logic_vector(15 downto 0);
        rd_addr        : out std_logic_vector(2 downto 0);
        pc_out         : out std_logic_vector(15 downto 0);
        -- Control signals out
        alu_op         : out std_logic_vector(3 downto 0);
        mem_read       : out std_logic;
        mem_write      : out std_logic;
        reg_write      : out std_logic;
        mem_to_reg     : out std_logic;
        alu_src        : out std_logic;
        branch         : out std_logic
    );
end entity decode_stage;

architecture behavioral of decode_stage is
begin
    -- TODO: Implement decode logic
end architecture behavioral;
