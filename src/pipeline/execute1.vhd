-- ============================================================================
-- Stage 3: EXECUTE 1 (EX1)
-- ============================================================================
-- Responsibilities:
--   - First cycle of ALU execution
--   - Compute effective address for memory operations
--   - Begin multi-cycle operations (e.g., multiply, shift)
--   - Evaluate branch conditions
--   - Write results into EX1/EX2 pipeline register
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity execute1_stage is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        stall          : in  std_logic;
        flush          : in  std_logic;
        -- Inputs from ID/EX1 register
        read_data1     : in  std_logic_vector(15 downto 0);
        read_data2     : in  std_logic_vector(15 downto 0);
        immediate      : in  std_logic_vector(15 downto 0);
        rd_addr_in     : in  std_logic_vector(2 downto 0);
        pc_in          : in  std_logic_vector(15 downto 0);
        -- Control signals in
        alu_op         : in  std_logic_vector(3 downto 0);
        alu_src        : in  std_logic;
        branch         : in  std_logic;
        -- Forwarded data inputs
        fwd_ex2_data   : in  std_logic_vector(15 downto 0);
        fwd_mem_data   : in  std_logic_vector(15 downto 0);
        fwd_sel_a      : in  std_logic_vector(1 downto 0);
        fwd_sel_b      : in  std_logic_vector(1 downto 0);
        -- Outputs to EX1/EX2 register
        alu_partial    : out std_logic_vector(15 downto 0);
        branch_taken   : out std_logic;
        branch_addr    : out std_logic_vector(15 downto 0);
        read_data2_out : out std_logic_vector(15 downto 0);
        rd_addr_out    : out std_logic_vector(2 downto 0);
        -- Flags
        flags_out      : out std_logic_vector(3 downto 0)  -- Z, N, C, V
    );
end entity execute1_stage;

architecture behavioral of execute1_stage is
begin
    -- TODO: Implement EX1 logic
end architecture behavioral;
