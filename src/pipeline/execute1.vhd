library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity execute1_stage is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        read_data1     : in  std_logic_vector(31 downto 0);
        read_data2     : in  std_logic_vector(31 downto 0);
        immediate      : in  std_logic_vector(31 downto 0);

        alu_op         : in  std_logic_vector(2 downto 0);
        alu_src        : in  std_logic_vector(1 downto 0);

        fwd_ex2_data   : in  std_logic_vector(31 downto 0);
        fwd_mem_data   : in  std_logic_vector(31 downto 0);
        fwd_wb_data    : in  std_logic_vector(31 downto 0);
        fwd_sel_a      : in  std_logic_vector(1 downto 0);
        fwd_sel_b      : in  std_logic_vector(1 downto 0);
        alu_result     : out std_logic_vector(31 downto 0);
        flags_out      : out std_logic_vector(2 downto 0)
    );
end entity execute1_stage;

architecture structural of execute1_stage is
    signal op_a, op_b : std_logic_vector(31 downto 0);
begin
    op_a <= read_data1  when fwd_sel_a = "00" else
            fwd_ex2_data when fwd_sel_a = "01" else
            fwd_mem_data when fwd_sel_a = "10" else
            fwd_wb_data;

    op_b <= read_data2  when fwd_sel_b = "00" and alu_src = "00" else
            immediate   when alu_src = "01" else
            fwd_ex2_data when fwd_sel_b = "01" else
            fwd_mem_data when fwd_sel_b = "10" else
            fwd_wb_data;

    ALU_INST: entity work.alu
        port map (
            operand_a => op_a,
            operand_b => op_b,
            alu_op    => alu_op,
            result    => alu_result,
            flags     => flags_out
        );
end architecture structural;
