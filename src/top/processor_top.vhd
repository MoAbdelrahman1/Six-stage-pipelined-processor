-- ============================================================================
-- Integrated 6-stage pipelined processor
-- ============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

library STD;
use STD.TEXTIO.ALL;

entity processor_top is
    generic (
        MEM_FILE : string := "program.mem"
    );
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        intr_in  : in  std_logic;
        in_port  : in  std_logic_vector(31 downto 0);
        out_port : out std_logic_vector(31 downto 0);
        halted   : out std_logic;

        dbg_pc    : out std_logic_vector(31 downto 0);
        dbg_sp    : out std_logic_vector(31 downto 0);
        dbg_flags : out std_logic_vector(2 downto 0);
        dbg_r0    : out std_logic_vector(31 downto 0);
        dbg_r1    : out std_logic_vector(31 downto 0);
        dbg_r2    : out std_logic_vector(31 downto 0);
        dbg_r3    : out std_logic_vector(31 downto 0);
        dbg_r4    : out std_logic_vector(31 downto 0);
        dbg_r5    : out std_logic_vector(31 downto 0);
        dbg_r6    : out std_logic_vector(31 downto 0);
        dbg_r7    : out std_logic_vector(31 downto 0)
    );
end entity processor_top;

architecture rtl of processor_top is
    subtype word_t is std_logic_vector(31 downto 0);
    type ram_t is array (0 to 4095) of word_t;
    type reg_t is array (0 to 7) of word_t;

    impure function init_ram return ram_t is
        file f       : text;
        variable l   : line;
        variable mem : ram_t := (others => (others => '0'));
        variable w   : word_t;
        variable i   : integer := 0;
        variable ok  : file_open_status;
    begin
        if MEM_FILE /= "" then
            file_open(ok, f, MEM_FILE, read_mode);
            if ok = open_ok then
                while not endfile(f) and i <= 4095 loop
                    readline(f, l);
                    hread(l, w);
                    mem(i) := w;
                    i := i + 1;
                end loop;
                file_close(f);
            end if;
        end if;
        return mem;
    end function;

    type if_id_t is record
        valid   : std_logic;
        pc      : word_t;
        pc_next : word_t;
        instr   : word_t;
    end record;

    type id_ex_t is record
        valid      : std_logic;
        pc_next    : word_t;
        opcode     : std_logic_vector(3 downto 0);
        func       : std_logic_vector(2 downto 0);
        rd         : std_logic_vector(2 downto 0);
        rs1        : std_logic_vector(2 downto 0);
        rs2        : std_logic_vector(2 downto 0);
        imm        : word_t;
        a          : word_t;
        b          : word_t;
        use_imm    : std_logic;
        alu_op     : std_logic_vector(2 downto 0);
        reg_write  : std_logic;
        mem_read   : std_logic;
        mem_write  : std_logic;
        mem_to_reg : std_logic;
        flag_write : std_logic;
        branch     : std_logic_vector(2 downto 0);
        stack_op   : std_logic_vector(1 downto 0); -- 00 none, 01 push, 10 pop
        is_swap    : std_logic;
        is_out     : std_logic;
        is_in      : std_logic;
        is_hlt     : std_logic;
    end record;

    type ex1_ex2_t is record
        valid      : std_logic;
        pc_next    : word_t;
        opcode     : std_logic_vector(3 downto 0);
        func       : std_logic_vector(2 downto 0);
        rd         : std_logic_vector(2 downto 0);
        rs1        : std_logic_vector(2 downto 0);
        rs2        : std_logic_vector(2 downto 0);
        imm        : word_t;
        result     : word_t;
        b          : word_t;
        flags      : std_logic_vector(2 downto 0);
        reg_write  : std_logic;
        mem_read   : std_logic;
        mem_write  : std_logic;
        mem_to_reg : std_logic;
        flag_write : std_logic;
        branch     : std_logic_vector(2 downto 0);
        stack_op   : std_logic_vector(1 downto 0);
        is_swap    : std_logic;
        is_out     : std_logic;
        is_in      : std_logic;
        is_hlt     : std_logic;
    end record;

    type ex2_mem_t is record
        valid      : std_logic;
        pc_next    : word_t;
        rd         : std_logic_vector(2 downto 0);
        rs1        : std_logic_vector(2 downto 0);
        result     : word_t;
        store_data : word_t;
        flags      : std_logic_vector(2 downto 0);
        reg_write  : std_logic;
        mem_read   : std_logic;
        mem_write  : std_logic;
        mem_to_reg : std_logic;
        flag_write : std_logic;
        stack_op   : std_logic_vector(1 downto 0);
        is_swap    : std_logic;
        is_out     : std_logic;
        is_in      : std_logic;
        is_hlt     : std_logic;
        branch_taken : std_logic;
        branch_addr  : word_t;
        branch       : std_logic_vector(2 downto 0);
    end record;

    type mem_wb_t is record
        valid      : std_logic;
        rd         : std_logic_vector(2 downto 0);
        rs1        : std_logic_vector(2 downto 0);
        result     : word_t;
        mem_data   : word_t;
        swap_data  : word_t;
        flags      : std_logic_vector(2 downto 0);
        reg_write  : std_logic;
        mem_to_reg : std_logic;
        flag_write : std_logic;
        is_swap    : std_logic;
        is_hlt     : std_logic;
        branch_taken : std_logic;
        branch       : std_logic_vector(2 downto 0);
    end record;

    constant IF_ID_ZERO   : if_id_t   := ('0', (others => '0'), (others => '0'), (others => '0'));
    constant ID_EX_ZERO   : id_ex_t   := ('0', (others => '0'), (others => '0'), (others => '0'),
                                           (others => '0'), (others => '0'), (others => '0'),
                                           (others => '0'), (others => '0'), (others => '0'), '0',
                                           (others => '0'), '0', '0', '0', '0', '0',
                                           (others => '0'), (others => '0'), '0', '0', '0', '0');
    constant EX1_EX2_ZERO : ex1_ex2_t := ('0', (others => '0'), (others => '0'), (others => '0'),
                                           (others => '0'), (others => '0'), (others => '0'),
                                           (others => '0'), (others => '0'), (others => '0'),
                                           (others => '0'), '0', '0', '0', '0', '0',
                                           (others => '0'), (others => '0'), '0', '0', '0', '0');
    constant EX2_MEM_ZERO : ex2_mem_t := (
        valid => '0', pc_next => (others => '0'), rd => (others => '0'), rs1 => (others => '0'),
        result => (others => '0'), store_data => (others => '0'), flags => (others => '0'),
        reg_write => '0', mem_read => '0', mem_write => '0', mem_to_reg => '0', flag_write => '0',
        stack_op => (others => '0'), is_swap => '0', is_out => '0', is_in => '0', is_hlt => '0',
        branch_taken => '0', branch_addr => (others => '0'), branch => (others => '0')
    );
    constant MEM_WB_ZERO  : mem_wb_t  := (
        valid => '0', rd => (others => '0'), rs1 => (others => '0'), result => (others => '0'),
        mem_data => (others => '0'), swap_data => (others => '0'), flags => (others => '0'),
        reg_write => '0', mem_to_reg => '0', flag_write => '0', is_swap => '0', is_hlt => '0',
        branch_taken => '0', branch => (others => '0')
    );

    signal ram      : ram_t := init_ram;
    signal regs     : reg_t := (others => (others => '0'));
    signal pc       : unsigned(31 downto 0) := (others => '0');
    signal sp       : unsigned(31 downto 0) := to_unsigned(4095, 32);
    signal ccr      : std_logic_vector(2 downto 0) := (others => '0'); -- Z,N,C
    signal out_reg  : word_t := (others => '0');
    signal halt_reg : std_logic := '0';

    signal if_id    : if_id_t := IF_ID_ZERO;
    signal id_ex    : id_ex_t := ID_EX_ZERO;
    signal ex1_ex2  : ex1_ex2_t := EX1_EX2_ZERO;
    signal ex2_mem  : ex2_mem_t := EX2_MEM_ZERO;
    signal mem_wb   : mem_wb_t := MEM_WB_ZERO;
    signal interrupt_pending : std_logic := '0';

    function sx16(v : std_logic_vector(15 downto 0)) return word_t is
    begin
        return std_logic_vector(resize(signed(v), 32));
    end function;

    function add32(a, b : word_t) return word_t is
    begin
        return std_logic_vector(unsigned(a) + unsigned(b));
    end function;

    function alu(a, b : word_t; op : std_logic_vector(2 downto 0)) return word_t is
        variable tmp : unsigned(32 downto 0);
    begin
        case op is
            when "000" => tmp := unsigned('0' & a) + unsigned('0' & b); return std_logic_vector(tmp(31 downto 0));
            when "001" => tmp := unsigned('0' & a) - unsigned('0' & b); return std_logic_vector(tmp(31 downto 0));
            when "010" => return a and b;
            when "011" => return not a;
            when "100" => tmp := unsigned('0' & a) + 1; return std_logic_vector(tmp(31 downto 0));
            when others => return a;
        end case;
    end function;

    function alu_flags(a, b, r : word_t; op : std_logic_vector(2 downto 0); c_in : std_logic) return std_logic_vector is
        variable f   : std_logic_vector(2 downto 0) := (others => '0');
        variable tmp : unsigned(32 downto 0);
    begin
        if r = x"00000000" then f(0) := '1'; end if;
        f(1) := r(31);
        case op is
            when "000" => tmp := unsigned('0' & a) + unsigned('0' & b); f(2) := tmp(32);
            when "001" => tmp := unsigned('0' & a) - unsigned('0' & b); f(2) := tmp(32);
            when "100" => tmp := unsigned('0' & a) + 1; f(2) := tmp(32);
            when "110" => f(2) := '1';
            when others => f(2) := c_in;
        end case;
        return f;
    end function;

    function source1(instr : word_t) return std_logic_vector is
        variable op : std_logic_vector(3 downto 0) := instr(31 downto 28);
        variable fn : std_logic_vector(2 downto 0) := instr(18 downto 16);
    begin
        if op = "0001" and (fn = "000" or fn = "001") then
            return instr(27 downto 25); -- NOT/INC use Rdst
        elsif op = "0010" and fn = "001" then
            return instr(27 downto 25); -- SWAP reads Rdst and Rsrc1
        else
            return instr(24 downto 22);
        end if;
    end function;

    function source2(instr : word_t) return std_logic_vector is
        variable op : std_logic_vector(3 downto 0) := instr(31 downto 28);
        variable fn : std_logic_vector(2 downto 0) := instr(18 downto 16);
    begin
        if op = "0010" and fn = "001" then
            return instr(24 downto 22); -- SWAP second operand is Rsrc1
        else
            return instr(21 downto 19);
        end if;
    end function;
begin
    out_port <= out_reg;
    halted <= halt_reg;
    dbg_pc <= std_logic_vector(pc);
    dbg_sp <= std_logic_vector(sp);
    dbg_flags <= ccr;
    dbg_r0 <= regs(0); dbg_r1 <= regs(1); dbg_r2 <= regs(2); dbg_r3 <= regs(3);
    dbg_r4 <= regs(4); dbg_r5 <= regs(5); dbg_r6 <= regs(6); dbg_r7 <= regs(7);

    process(clk, rst)
        variable next_if_id   : if_id_t;
        variable next_id_ex   : id_ex_t;
        variable next_ex1_ex2 : ex1_ex2_t;
        variable next_ex2_mem : ex2_mem_t;
        variable next_mem_wb  : mem_wb_t;
        variable next_pc       : unsigned(31 downto 0);
        variable next_ccr      : std_logic_vector(2 downto 0);
        variable next_interrupt_pending : std_logic;
        variable pipeline_empty_next : std_logic;
        variable instr        : word_t;
        variable op           : std_logic_vector(3 downto 0);
        variable fn           : std_logic_vector(2 downto 0);
        variable rd_i         : integer;
        variable rs1_i        : integer;
        variable rs2_i        : integer;
        variable a_val        : word_t;
        variable b_val        : word_t;
        variable alu_b        : word_t;
        variable alu_res      : word_t;
        variable wb_value     : word_t;
        variable branch_hit   : std_logic;
        variable branch_dest  : word_t;
        variable mem_branch_hit  : std_logic;
        variable mem_branch_dest : word_t;
        variable load_use     : std_logic;
        variable f_val        : std_logic_vector(2 downto 0);
        variable s1           : std_logic_vector(2 downto 0);
        variable s2           : std_logic_vector(2 downto 0);
        variable sp_addr      : unsigned(31 downto 0);
    begin
        if rst = '1' then
            regs <= (others => (others => '0'));
            pc <= unsigned(ram(0));
            sp <= to_unsigned(4095, 32);
            ccr <= (others => '0');
            out_reg <= (others => '0');
            halt_reg <= '0';
            interrupt_pending <= '0';
            if_id <= IF_ID_ZERO;
            id_ex <= ID_EX_ZERO;
            ex1_ex2 <= EX1_EX2_ZERO;
            ex2_mem <= EX2_MEM_ZERO;
            mem_wb <= MEM_WB_ZERO;
        elsif rising_edge(clk) then
            if halt_reg = '0' then
                next_pc := pc;
                next_ccr := ccr;
                next_interrupt_pending := interrupt_pending;
                if intr_in = '1' then
                    next_interrupt_pending := '1';
                end if;

                next_if_id := IF_ID_ZERO;
                next_id_ex := ID_EX_ZERO;
                next_ex1_ex2 := EX1_EX2_ZERO;
                next_ex2_mem := EX2_MEM_ZERO;
                next_mem_wb := MEM_WB_ZERO;

                wb_value := mem_wb.result;
                if mem_wb.mem_to_reg = '1' then
                    wb_value := mem_wb.mem_data;
                end if;

                if mem_wb.valid = '1' then
                    if mem_wb.reg_write = '1' then
                        regs(to_integer(unsigned(mem_wb.rd))) <= wb_value;
                    end if;
                    if mem_wb.is_swap = '1' then
                        regs(to_integer(unsigned(mem_wb.rd))) <= mem_wb.swap_data;
                        regs(to_integer(unsigned(mem_wb.rs1))) <= mem_wb.result;
                    end if;
                    if mem_wb.flag_write = '1' then
                        next_ccr := mem_wb.flags;
                    end if;
                    -- Safe branch flag clearing in WB stage
                    if mem_wb.branch_taken = '1' then
                        case mem_wb.branch is
                            when "001" => next_ccr(0) := '0'; -- JZ
                            when "010" => next_ccr(1) := '0'; -- JN
                            when "011" => next_ccr(2) := '0'; -- JC
                            when others => null;
                        end case;
                    end if;
                    if mem_wb.is_hlt = '1' then
                        halt_reg <= '1';
                    end if;
                end if;

                -- MEM stage
                mem_branch_hit := '0';
                mem_branch_dest := (others => '0');
                next_mem_wb.valid := ex2_mem.valid;
                next_mem_wb.rd := ex2_mem.rd;
                next_mem_wb.rs1 := ex2_mem.rs1;
                next_mem_wb.result := ex2_mem.result;
                next_mem_wb.swap_data := ex2_mem.store_data;
                next_mem_wb.flags := ex2_mem.flags;
                next_mem_wb.reg_write := ex2_mem.reg_write;
                next_mem_wb.mem_to_reg := ex2_mem.mem_to_reg;
                next_mem_wb.flag_write := ex2_mem.flag_write;
                next_mem_wb.is_swap := ex2_mem.is_swap;
                next_mem_wb.is_hlt := ex2_mem.is_hlt;
                next_mem_wb.branch_taken := ex2_mem.branch_taken;
                next_mem_wb.branch := ex2_mem.branch;

                if ex2_mem.valid = '1' then
                    if ex2_mem.mem_read = '1' then
                        next_mem_wb.mem_data := ram(to_integer(unsigned(ex2_mem.result(11 downto 0))));
                    end if;
                    if ex2_mem.mem_write = '1' then
                        ram(to_integer(unsigned(ex2_mem.result(11 downto 0)))) <= ex2_mem.store_data;
                    end if;
                    if ex2_mem.stack_op = "01" then
                        ram(to_integer(sp(11 downto 0))) <= ex2_mem.store_data;
                        sp <= sp - 1;
                    elsif ex2_mem.stack_op = "10" then
                        sp_addr := sp + 1;
                        next_mem_wb.mem_data := ram(to_integer(sp_addr(11 downto 0)));
                        sp <= sp_addr;
                        if ex2_mem.branch_taken = '1' then
                            mem_branch_hit := '1';
                            mem_branch_dest := ram(to_integer(sp_addr(11 downto 0)));
                        end if;
                    end if;
                    if ex2_mem.is_out = '1' then
                        out_reg <= ex2_mem.store_data;
                    end if;
                end if;

                -- EX2 stage: branches, memory addresses, stack return addresses
                f_val := ccr;
                if ex2_mem.valid = '1' and ex2_mem.flag_write = '1' then
                    f_val := ex2_mem.flags;
                elsif mem_wb.valid = '1' and mem_wb.flag_write = '1' then
                    f_val := mem_wb.flags;
                end if;

                branch_hit := '0';
                branch_dest := ex1_ex2.imm;
                if ex1_ex2.valid = '1' then
                    case ex1_ex2.branch is
                        when "001" => if f_val(0) = '1' then branch_hit := '1'; end if; -- JZ
                        when "010" => if f_val(1) = '1' then branch_hit := '1'; end if; -- JN
                        when "011" => if f_val(2) = '1' then branch_hit := '1'; end if; -- JC
                        when "100" => branch_hit := '1'; -- JMP/CALL/INT
                        when "101" => null; -- RET/RTI redirect after stack pop in MEM
                        when others => null;
                    end case;
                end if;

                if ex1_ex2.valid = '1' and branch_hit = '1' then
                    null; -- Clear logic moved to WB for safety
                end if;

                next_ex2_mem.valid := ex1_ex2.valid;
                next_ex2_mem.pc_next := ex1_ex2.pc_next;
                next_ex2_mem.rd := ex1_ex2.rd;
                next_ex2_mem.rs1 := ex1_ex2.rs1;
                next_ex2_mem.result := ex1_ex2.result;
                next_ex2_mem.store_data := ex1_ex2.b;
                next_ex2_mem.flags := ex1_ex2.flags;
                next_ex2_mem.reg_write := ex1_ex2.reg_write;
                next_ex2_mem.mem_read := ex1_ex2.mem_read;
                next_ex2_mem.mem_write := ex1_ex2.mem_write;
                next_ex2_mem.mem_to_reg := ex1_ex2.mem_to_reg;
                next_ex2_mem.flag_write := ex1_ex2.flag_write;
                next_ex2_mem.stack_op := ex1_ex2.stack_op;
                next_ex2_mem.is_swap := ex1_ex2.is_swap;
                next_ex2_mem.is_out := ex1_ex2.is_out;
                next_ex2_mem.is_in := ex1_ex2.is_in;
                next_ex2_mem.is_hlt := ex1_ex2.is_hlt;
                next_ex2_mem.branch_taken := branch_hit;
                next_ex2_mem.branch_addr := branch_dest;
                next_ex2_mem.branch := ex1_ex2.branch;
                if ex1_ex2.is_swap = '1' then
                    next_ex2_mem.rs1 := ex1_ex2.rs2;
                end if;
                if ex1_ex2.branch = "101" then
                    next_ex2_mem.branch_taken := '1';
                end if;

                if ex1_ex2.opcode = "0110" and (ex1_ex2.func = "001" or ex1_ex2.func = "010") then
                    next_ex2_mem.result := add32(ex1_ex2.result, ex1_ex2.imm);
                end if;
                if ex1_ex2.opcode = "1000" and ex1_ex2.func = "000" then
                    next_ex2_mem.stack_op := "01";
                    next_ex2_mem.store_data := ex1_ex2.pc_next;
                end if;
                if ex1_ex2.opcode = "1001" and ex1_ex2.func = "000" then
                    next_ex2_mem.stack_op := "01";
                    next_ex2_mem.store_data := ex1_ex2.pc_next;
                    next_ex2_mem.branch_addr := ram(to_integer(unsigned(ex1_ex2.imm(11 downto 0)) + 2));
                    next_ex2_mem.branch_taken := '1';
                    branch_hit := '1';
                    branch_dest := next_ex2_mem.branch_addr;
                end if;

                -- EX1 stage with forwarding from EX2/MEM and MEM/WB.
                a_val := id_ex.a;
                b_val := id_ex.b;
                if id_ex.valid = '1' then
                    if ex1_ex2.valid = '1' and ex1_ex2.reg_write = '1' and ex1_ex2.mem_to_reg = '0' and ex1_ex2.rd = id_ex.rs1 then
                        a_val := ex1_ex2.result;
                    elsif ex2_mem.valid = '1' and ex2_mem.reg_write = '1' and ex2_mem.mem_to_reg = '1' and ex2_mem.rd = id_ex.rs1 then
                        a_val := ram(to_integer(unsigned(ex2_mem.result(11 downto 0))));
                    elsif ex2_mem.valid = '1' and ex2_mem.reg_write = '1' and ex2_mem.mem_to_reg = '0' and ex2_mem.rd = id_ex.rs1 then
                        a_val := ex2_mem.result;
                    elsif mem_wb.valid = '1' and mem_wb.reg_write = '1' and mem_wb.rd = id_ex.rs1 then
                        a_val := wb_value;
                    end if;

                    if ex1_ex2.valid = '1' and ex1_ex2.reg_write = '1' and ex1_ex2.mem_to_reg = '0' and ex1_ex2.rd = id_ex.rs2 then
                        b_val := ex1_ex2.result;
                    elsif ex2_mem.valid = '1' and ex2_mem.reg_write = '1' and ex2_mem.mem_to_reg = '1' and ex2_mem.rd = id_ex.rs2 then
                        b_val := ram(to_integer(unsigned(ex2_mem.result(11 downto 0))));
                    elsif ex2_mem.valid = '1' and ex2_mem.reg_write = '1' and ex2_mem.mem_to_reg = '0' and ex2_mem.rd = id_ex.rs2 then
                        b_val := ex2_mem.result;
                    elsif mem_wb.valid = '1' and mem_wb.reg_write = '1' and mem_wb.rd = id_ex.rs2 then
                        b_val := wb_value;
                    end if;
                end if;

                alu_b := b_val;
                if id_ex.use_imm = '1' then
                    alu_b := id_ex.imm;
                end if;
                alu_res := alu(a_val, alu_b, id_ex.alu_op);

                next_ex1_ex2.valid := id_ex.valid;
                next_ex1_ex2.pc_next := id_ex.pc_next;
                next_ex1_ex2.opcode := id_ex.opcode;
                next_ex1_ex2.func := id_ex.func;
                next_ex1_ex2.rd := id_ex.rd;
                next_ex1_ex2.rs1 := id_ex.rs1;
                next_ex1_ex2.rs2 := id_ex.rs2;
                next_ex1_ex2.imm := id_ex.imm;
                next_ex1_ex2.result := alu_res;
                next_ex1_ex2.b := b_val;
                next_ex1_ex2.flags := alu_flags(a_val, alu_b, alu_res, id_ex.alu_op, ccr(2));
                next_ex1_ex2.reg_write := id_ex.reg_write;
                next_ex1_ex2.mem_read := id_ex.mem_read;
                next_ex1_ex2.mem_write := id_ex.mem_write;
                next_ex1_ex2.mem_to_reg := id_ex.mem_to_reg;
                next_ex1_ex2.flag_write := id_ex.flag_write;
                next_ex1_ex2.branch := id_ex.branch;
                next_ex1_ex2.stack_op := id_ex.stack_op;
                next_ex1_ex2.is_swap := id_ex.is_swap;
                next_ex1_ex2.is_out := id_ex.is_out;
                next_ex1_ex2.is_in := id_ex.is_in;
                next_ex1_ex2.is_hlt := id_ex.is_hlt;
                if id_ex.is_in = '1' then
                    next_ex1_ex2.result := in_port;
                end if;
                if id_ex.opcode = "0110" and id_ex.func = "000" then
                    next_ex1_ex2.result := id_ex.imm;
                end if;

                -- ID stage
                instr := if_id.instr;
                op := instr(31 downto 28);
                fn := instr(18 downto 16);
                rd_i := to_integer(unsigned(instr(27 downto 25)));
                rs1_i := to_integer(unsigned(instr(24 downto 22)));
                rs2_i := to_integer(unsigned(instr(21 downto 19)));
                s1 := source1(instr);
                s2 := source2(instr);

                load_use := '0';
                if id_ex.valid = '1' and (id_ex.mem_read = '1' or id_ex.stack_op = "10") then
                    if if_id.valid = '1' and (id_ex.rd = s1 or id_ex.rd = s2) then
                        load_use := '1';
                    end if;
                end if;

                if if_id.valid = '1' and load_use = '0' then
                    next_id_ex.valid := '1';
                    next_id_ex.pc_next := if_id.pc_next;
                    next_id_ex.opcode := op;
                    next_id_ex.func := fn;
                    next_id_ex.rd := instr(27 downto 25);
                    next_id_ex.rs1 := s1;
                    next_id_ex.rs2 := s2;
                    next_id_ex.imm := sx16(instr(15 downto 0));
                    next_id_ex.a := regs(to_integer(unsigned(s1)));
                    next_id_ex.b := regs(to_integer(unsigned(s2)));
                    next_id_ex.alu_op := "101";

                    case op is
                        when "0000" =>
                            if fn = "001" then next_id_ex.is_hlt := '1';
                            elsif fn = "010" then next_id_ex.flag_write := '1'; next_id_ex.alu_op := "110";
                            end if;
                        when "0001" =>
                            if fn = "000" then next_id_ex.reg_write := '1'; next_id_ex.flag_write := '1'; next_id_ex.alu_op := "011";
                            elsif fn = "001" then next_id_ex.reg_write := '1'; next_id_ex.flag_write := '1'; next_id_ex.alu_op := "100";
                            elsif fn = "010" then
                                next_id_ex.is_out := '1'; next_id_ex.b := regs(rs1_i); next_id_ex.rs2 := instr(24 downto 22);
                            elsif fn = "011" then next_id_ex.reg_write := '1'; next_id_ex.is_in := '1';
                            end if;
                        when "0010" =>
                            if fn = "000" then
                                next_id_ex.reg_write := '1'; next_id_ex.a := regs(rs1_i); next_id_ex.rs1 := instr(24 downto 22);
                            elsif fn = "001" then
                                next_id_ex.is_swap := '1';
                                next_id_ex.a := regs(rd_i);
                                next_id_ex.b := regs(rs1_i);
                                next_id_ex.rs1 := instr(27 downto 25);
                                next_id_ex.rs2 := instr(24 downto 22);
                            end if;
                        when "0011" =>
                            next_id_ex.reg_write := '1'; next_id_ex.flag_write := '1'; next_id_ex.alu_op := fn;
                            next_id_ex.a := regs(rs1_i); next_id_ex.b := regs(rs2_i);
                            next_id_ex.rs1 := instr(24 downto 22); next_id_ex.rs2 := instr(21 downto 19);
                        when "0100" =>
                            next_id_ex.reg_write := '1'; next_id_ex.flag_write := '1'; next_id_ex.use_imm := '1'; next_id_ex.alu_op := "000";
                            next_id_ex.a := regs(rs1_i); next_id_ex.rs1 := instr(24 downto 22);
                        when "0101" =>
                            if fn = "000" then
                                next_id_ex.stack_op := "01"; next_id_ex.b := regs(rs1_i); next_id_ex.rs2 := instr(24 downto 22);
                            elsif fn = "001" then
                                next_id_ex.stack_op := "10"; next_id_ex.reg_write := '1'; next_id_ex.mem_to_reg := '1';
                            end if;
                        when "0110" =>
                            if fn = "000" then
                                next_id_ex.reg_write := '1';
                            elsif fn = "001" then
                                next_id_ex.reg_write := '1'; next_id_ex.mem_read := '1'; next_id_ex.mem_to_reg := '1';
                                next_id_ex.a := regs(rs1_i); next_id_ex.rs1 := instr(24 downto 22);
                            elsif fn = "010" then
                                next_id_ex.mem_write := '1'; next_id_ex.a := regs(rs2_i); next_id_ex.b := regs(rs1_i);
                                next_id_ex.rs1 := instr(21 downto 19); next_id_ex.rs2 := instr(24 downto 22);
                            end if;
                        when "0111" =>
                            if fn = "000" then next_id_ex.branch := "001";
                            elsif fn = "001" then next_id_ex.branch := "010";
                            elsif fn = "010" then next_id_ex.branch := "011";
                            elsif fn = "011" then next_id_ex.branch := "100";
                            end if;
                        when "1000" =>
                            if fn = "000" then next_id_ex.branch := "100"; next_id_ex.stack_op := "01";
                            elsif fn = "001" then next_id_ex.branch := "101"; next_id_ex.stack_op := "10";
                            end if;
                        when "1001" =>
                            if fn = "000" then next_id_ex.branch := "100"; next_id_ex.stack_op := "01";
                            elsif fn = "001" then next_id_ex.branch := "101"; next_id_ex.stack_op := "10";
                            end if;
                        when others => null;
                    end case;
                end if;

                -- IF stage: static not-taken prediction.
                if mem_branch_hit = '1' then
                    next_pc := unsigned(mem_branch_dest);
                    next_if_id := IF_ID_ZERO;
                    next_id_ex := ID_EX_ZERO;
                    next_ex1_ex2 := EX1_EX2_ZERO;
                    next_ex2_mem := EX2_MEM_ZERO;
                elsif branch_hit = '1' then
                    next_pc := unsigned(branch_dest);
                    next_if_id := IF_ID_ZERO;
                    next_id_ex := ID_EX_ZERO;
                    next_ex1_ex2 := EX1_EX2_ZERO;
                elsif load_use = '1' then
                    next_if_id := if_id;
                elsif next_interrupt_pending = '1' then
                    next_if_id := IF_ID_ZERO;
                else
                    next_if_id.valid := '1';
                    next_if_id.pc := std_logic_vector(pc);
                    next_if_id.pc_next := std_logic_vector(pc + 1);
                    next_if_id.instr := ram(to_integer(pc(11 downto 0)));
                    next_pc := pc + 1;
                end if;

                pipeline_empty_next := '0';
                if next_if_id.valid = '0' and next_id_ex.valid = '0' and next_ex1_ex2.valid = '0' and
                   next_ex2_mem.valid = '0' and next_mem_wb.valid = '0' then
                    pipeline_empty_next := '1';
                end if;

                if next_interrupt_pending = '1' and pipeline_empty_next = '1' then
                    -- External interrupt: save final PC after drain, then vector through M[1].
                    ram(to_integer(sp(11 downto 0))) <= std_logic_vector(next_pc);
                    sp <= sp - 1;
                    next_pc := unsigned(ram(1));
                    next_interrupt_pending := '0';
                    next_if_id := IF_ID_ZERO;
                    next_id_ex := ID_EX_ZERO;
                    next_ex1_ex2 := EX1_EX2_ZERO;
                    next_ex2_mem := EX2_MEM_ZERO;
                    next_mem_wb := MEM_WB_ZERO;
                end if;

                pc <= next_pc;
                ccr <= next_ccr;
                interrupt_pending <= next_interrupt_pending;
                if_id <= next_if_id;
                id_ex <= next_id_ex;
                ex1_ex2 <= next_ex1_ex2;
                ex2_mem <= next_ex2_mem;
                mem_wb <= next_mem_wb;
            end if;
        end if;
    end process;
end architecture rtl;
