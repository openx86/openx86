// ============================================================================
// w686_core — 80486 级取指/译码/执行闭环（BIU 含 MMU 仲裁），CPL/CPUID/保护模式入口
// ============================================================================
`include "openx86_defs.h.sv"
`include "w686_decode_outputs_decl.svh"

module w686_core (
    output logic        o_bus_vaild,
    input  logic        i_bus_ready,
    input  logic        i_bus_busy,
    output logic        o_bus_write_enable,
    output logic        o_bus_io_access,
    output logic [31:0] o_bus_address,
    input  logic [31:0] i_bus_data_read,
    output logic [31:0] o_bus_data_write,
    input  logic        clock,
    input  logic        reset
);

    import execute_unit_pkg::*;
    import decode_x87_pkg::*;

    // --- GPR / 段 / 标志 / EIP / 控制寄存器（与原实现一致）---
    logic        write_enable;
    logic [ 2:0] write_index;
    logic [31:0] write_data;
    logic [31:0] GPR_read__8 [0:7];
    logic [31:0] GPR_read_16 [0:7];
    logic [31:0] GPR_read_32 [0:7];

    rf_general_propose_register general_propose_register (
        .write_enable ( write_enable ),
        .write_index ( write_index ),
        .write_data ( write_data ),
        .read__8 ( GPR_read__8 ),
        .read_16 ( GPR_read_16 ),
        .read_32 ( GPR_read_32 ),
        .clock ( clock ),
        .reset ( reset )
    );

    logic        SREG_write_enable;
    logic [ 2:0] SREG_write_index;
    logic [15:0] SREG_write_selector;
    logic [63:0] SREG_write_descriptor;
    logic [15:0] segment_selector [0:5];
    logic [63:0] descriptor_cache [0:5];

    rf_segment_register core_segment_register (
        .write_enable ( SREG_write_enable ),
        .write_index ( SREG_write_index ),
        .write_selector ( SREG_write_selector ),
        .write_descriptor ( SREG_write_descriptor ),
        .segment_selector ( segment_selector ),
        .descriptor_cache ( descriptor_cache ),
        .clock ( clock ),
        .reset ( reset )
    );

    logic         FLAGS_write_enable;
    logic [31:0]  FLAGS_write_data;
    logic         CF, PF, AF, ZF, SF, TF, IF, DF, OF;
    logic [ 1:0]  IOPL;
    logic         NT, RF, VM;
    logic [31:0]  EFLAGS;
    logic [15:0]  FLAGS;

    rf_flags_register core_flags_register (
        .write_enable ( FLAGS_write_enable ),
        .write_data ( FLAGS_write_data ),
        .CF ( CF ),
        .PF ( PF ),
        .AF ( AF ),
        .ZF ( ZF ),
        .SF ( SF ),
        .TF ( TF ),
        .IF ( IF ),
        .DF ( DF ),
        .OF ( OF ),
        .IOPL ( IOPL ),
        .NT ( NT ),
        .RF ( RF ),
        .VM ( VM ),
        .EFLAGS ( EFLAGS ),
        .FLAGS ( FLAGS ),
        .clock ( clock ),
        .reset ( reset )
    );

    logic        IP_write_enable;
    logic [31:0] IP_write_data;
    logic [15:0] IP;
    logic [31:0] EIP;

    rf_instruction_point_register core_instruction_point_register (
        .write_enable ( IP_write_enable ),
        .write_data ( IP_write_data ),
        .IP ( IP ),
        .EIP ( EIP ),
        .clock ( clock ),
        .reset ( reset )
    );

    logic         CR_write_enable;
    logic [ 2: 0] CR_write_index;
    logic [31: 0] CR_write_data;
    logic [31: 0] CR [0:7];
    logic         PE, MP, EM, TS, R, PG;
    logic [19: 0] page_directory_base;

    rf_control_register core_control_register (
        .write_enable ( CR_write_enable ),
        .write_index ( CR_write_index ),
        .write_data ( CR_write_data ),
        .CR ( CR ),
        .PE ( PE ),
        .MP ( MP ),
        .EM ( EM ),
        .TS ( TS ),
        .R ( R ),
        .PG ( PG ),
        .page_directory_base ( page_directory_base ),
        .clock ( clock ),
        .reset ( reset )
    );

    logic         DR_write_enable;
    logic [ 2: 0] DR_write_index;
    logic [31: 0] DR_write_data;
    logic [31: 0] DR [0:7];

    rf_debug_register core_debug_register (
        .write_enable ( DR_write_enable ),
        .write_index ( DR_write_index ),
        .write_data ( DR_write_data ),
        .DR ( DR ),
        .clock ( clock ),
        .reset ( reset )
    );

    logic         TR_write_enable;
    logic [ 2: 0] TR_write_index;
    logic [31: 0] TR_write_data;
    logic [31: 0] TR [0:7];

    rf_test_register core_test_register (
        .write_enable ( TR_write_enable ),
        .write_index ( TR_write_index ),
        .write_data ( TR_write_data ),
        .TR ( TR ),
        .clock ( clock ),
        .reset ( reset )
    );

    logic        GDTR_write_enable;
    logic [15:0] GDTR_write_data_limit;
    logic [31:0] GDTR_write_data_base;
    logic [15:0] GDTR_limit;
    logic [31:0] GDTR_base;

    rf_sar_global_descriptor_table_register core_global_descriptor_table_register (
        .GDTR_write_enable ( GDTR_write_enable ),
        .GDTR_write_data_limit ( GDTR_write_data_limit ),
        .GDTR_write_data_base ( GDTR_write_data_base ),
        .GDTR_limit ( GDTR_limit ),
        .GDTR_base ( GDTR_base ),
        .clock ( clock ),
        .reset ( reset )
    );

    logic        IDTR_write_enable;
    logic [15:0] IDTR_write_data_limit;
    logic [31:0] IDTR_write_data_base;
    logic [15:0] IDTR_limit;
    logic [31:0] IDTR_base;

    rf_sar_interrupt_descriptor_table_register core_interrupt_descriptor_table_register (
        .IDTR_write_enable ( IDTR_write_enable ),
        .IDTR_write_data_limit ( IDTR_write_data_limit ),
        .IDTR_write_data_base ( IDTR_write_data_base ),
        .IDTR_limit ( IDTR_limit ),
        .IDTR_base ( IDTR_base ),
        .clock ( clock ),
        .reset ( reset )
    );

    assign SREG_write_enable   = 1'b0;
    assign CR_write_enable     = 1'b0;
    assign DR_write_enable     = 1'b0;
    assign TR_write_enable     = 1'b0;
    assign GDTR_write_enable   = 1'b0;
    assign IDTR_write_enable   = 1'b0;

    // CPL = CS.RPL
    wire [1:0] current_privilege_level = segment_selector[`sreg_index_CS][1:0];

    // --- BIU（MMU > code > data）---
    logic        mmu_bus_vaild;
    logic        mmu_bus_ready;
    logic [31:0] mmu_bus_addr;
    logic [31:0] mmu_bus_rdata;

    logic        code_vaild;
    logic        code_ready;
    logic [31:0] code_address;
    logic [31:0] code_data_read;

    logic        data_vaild;
    logic        data_ready;
    logic        data_write_enable;
    logic [31:0] data_address;
    logic [31:0] data_data_read;
    logic [31:0] data_data_write;
    wire         data_io_access = 1'b0;

    bus_interface_unit core_bus_interface_unit (
        .i_mmu_vaild ( mmu_bus_vaild ),
        .o_mmu_ready ( mmu_bus_ready ),
        .i_mmu_address ( mmu_bus_addr ),
        .o_mmu_data_read ( mmu_bus_rdata ),
        .i_code_vaild ( code_vaild ),
        .o_code_ready ( code_ready ),
        .i_code_address ( code_address ),
        .o_code_data_read ( code_data_read ),
        .i_data_vaild ( data_vaild ),
        .o_data_ready ( data_ready ),
        .i_data_write_enable ( data_write_enable ),
        .i_data_io_access ( data_io_access ),
        .i_data_address ( data_address ),
        .o_data_data_read ( data_data_read ),
        .i_data_data_write ( data_data_write ),
        .o_bus_vaild ( o_bus_vaild ),
        .i_bus_ready ( i_bus_ready & ~i_bus_busy ),
        .i_bus_busy ( i_bus_busy ),
        .o_bus_write_enable ( o_bus_write_enable ),
        .o_bus_io_access ( o_bus_io_access ),
        .o_bus_address ( o_bus_address ),
        .i_bus_data_read ( i_bus_data_read ),
        .o_bus_data_write ( o_bus_data_write ),
        .i_clock ( clock ),
        .i_reset ( reset )
    );

    // --- 取指 ---
    logic [ 7:0] instruction [0:15];
    logic        instruction_ready;
    logic        if_segment_fault;

    wire         exec_stall;
    wire         ip_valid_to_fetch = ~exec_stall;

    if_instruction_fetch core_instruction_fetch (
        .o_code_vaild ( code_vaild ),
        .i_code_ready ( code_ready ),
        .o_code_address ( code_address ),
        .i_code_data_read ( code_data_read ),
        .o_mmu_bus_vaild ( mmu_bus_vaild ),
        .i_mmu_bus_ready ( mmu_bus_ready ),
        .o_mmu_bus_addr ( mmu_bus_addr ),
        .i_mmu_bus_rdata ( mmu_bus_rdata ),
        .i_protected_mode ( PE ),
        .i_segment_selector ( segment_selector ),
        .i_segment_descriptor ( descriptor_cache ),
        .i_current_privilege_level ( current_privilege_level ),
        .i_paging_enable ( PG ),
        .i_page_directory_base ( { page_directory_base, 12'b0 } ),
        .i_IP_vaild ( ip_valid_to_fetch ),
        .o_instruction ( instruction[0:15] ),
        .o_instruction_ready ( instruction_ready ),
        .o_segment_fault ( if_segment_fault ),
        .EIP ( EIP ),
        .clock ( clock ),
        .reset ( reset )
    );

    // --- 译码（.* 连接 w686_decode_outputs_decl 中声明的同名线网）---
    du_decode core_decode (
        .i_instruction ( instruction[0:15] ),
        .i_default_operand_size ( 1'b1 ),
        .*
    );

    // --- 80486：非 486 指令 → #UD（非法操作码）---
    wire post486_illegal =
        o_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size |
        o_opcode_x86_RDMSR_read_from_model_specific_reg |
        o_opcode_x86_WRMSR_write_to_model_specific_register |
        o_opcode_x86_RDTSC_read_time_stamp_counter |
        o_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id |
        o_opcode_x86_RDPMC_read_performance_monitoring_counters |
        o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg |
        o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem;

    // --- 执行辅助（CPUID 多周期）---
    logic        insn_fire;
    logic        ir_d1;
    logic        cpuid_busy;
    logic        cpuid_gpr_wr;
    logic [2:0]  cpuid_gpr_idx;
    logic [31:0] cpuid_gpr_wdata;
    logic        cpuid_done_pulse;
    logic        cache_flush_pulse;
    logic        invlpg_pulse;
    logic [31:0] invlpg_linear_addr;

    logic        xadd_wait_reg_wr;
    logic [2:0]  xadd_saved_reg;
    logic [31:0] xadd_saved_val;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            ir_d1 <= 1'b0;
        end else begin
            ir_d1 <= instruction_ready;
        end
    end

    assign insn_fire = instruction_ready & ~ir_d1;

    w686_core_execute_i486 u_exec486 (
        .clk ( clock ),
        .rst ( reset ),
        .insn_fire ( insn_fire ),
        .op_cpuid ( o_opcode_x86_CPUID_CPU_identification ),
        .gpr_eax ( GPR_read_32[0] ),
        .gpr_ecx ( GPR_read_32[1] ),
        .cpuid_busy ( cpuid_busy ),
        .gpr_wr_en ( cpuid_gpr_wr ),
        .gpr_wr_idx ( cpuid_gpr_idx ),
        .gpr_wr_data ( cpuid_gpr_wdata ),
        .cpuid_done_pulse ( cpuid_done_pulse ),
        .op_invd ( o_opcode_x86_INVD_invalidate_cache ),
        .op_wbinvd ( o_opcode_x86_WBINVD_writeback_and_invalidate_data_cache ),
        .op_invlpg ( o_opcode_x86_INVLPG_invalidate_TLB_entry ),
        .invlpg_ea ( o_displacement ),
        .cache_flush_pulse ( cache_flush_pulse ),
        .invlpg_pulse ( invlpg_pulse ),
        .invlpg_linear_addr ( invlpg_linear_addr )
    );

    // --- eu_execute_unit_top：AGU / LSU / Branch / MulDiv / X87 ---
    logic [31:0] br_rel32;
    logic signed [7:0] br_rel8;
    assign br_rel32 = o_immediate;
    assign br_rel8  = o_immediate[7:0];

    wire modrm_is_reg = ( o_dbg_modrm_mod == 2'b11 );
    wire [2:0] modrm_reg_field = instruction[1][5:3];
    wire [2:0] modrm_rm_field  = instruction[1][2:0];

    wire [31:0] agu_base_w =
        o_base_reg_is_present ? GPR_read_32[o_base_reg_index] : 32'd0;
    wire [31:0] agu_index_w =
        o_index_reg_is_present ? GPR_read_32[o_index_reg_index] : 32'd0;

    wire [31:0] dseg_base_linear = {
        descriptor_cache[o_segment_reg_index][31:24],
        descriptor_cache[o_segment_reg_index][7:0],
        descriptor_cache[o_segment_reg_index][63:48]
    };

    logic [31:0] eu_agu_ea;
    wire [31:0] lsu_linear_address = dseg_base_linear + eu_agu_ea;

    logic [ 2:0] eu_md_op;
    logic [31:0] eu_md_lo;
    logic [31:0] eu_md_hi;
    logic [31:0] eu_md_src;
    logic [31:0] eu_md_out_lo;
    logic [31:0] eu_md_out_hi;
    logic        eu_md_div0;

    always_comb begin
        eu_md_op  = MD_NOP;
        eu_md_lo  = GPR_read_32[0];
        eu_md_hi  = GPR_read_32[2];
        eu_md_src = GPR_read_32[modrm_rm_field];
        if ( o_opcode_x86_MUL_acc_with_reg_mem && modrm_is_reg )
            eu_md_op = MD_MULU32;
        else if ( o_opcode_x86_IMUL_acc_with_reg_mem && modrm_is_reg )
            eu_md_op = MD_IMUL32;
        else if ( o_opcode_x86_IMUL_reg_with_reg_mem && modrm_is_reg ) begin
            eu_md_op  = MD_IMUL32;
            eu_md_lo  = GPR_read_32[cx_r_idx];
            eu_md_src = GPR_read_32[cx_rm_idx];
        end else if ( o_opcode_x86_DIV_acc_by_reg_mem && modrm_is_reg )
            eu_md_op = MD_DIVU32;
        else if ( o_opcode_x86_IDIV_acc_by_reg_mem && modrm_is_reg )
            eu_md_op = MD_IDIV32;
    end

    x87_op_e eu_x87_op_sel;
    always_comb begin
        eu_x87_op_sel = X87_NOP;
        if ( o_x87_is_esc && modrm_is_reg ) begin
            if ( o_x87_opmask[M_FADD_ST0_STI] )
                eu_x87_op_sel = X87_FADD;
            else if ( o_x87_opmask[M_FMUL_ST0_STI] )
                eu_x87_op_sel = X87_FMUL;
            else if ( o_x87_opmask[M_FSUB_ST0_STI] | o_x87_opmask[M_FSUBR_ST0_STI] )
                eu_x87_op_sel = X87_FSUB;
            else if ( o_x87_opmask[M_FDIV_ST0_STI] | o_x87_opmask[M_FDIVR_ST0_STI] )
                eu_x87_op_sel = X87_FDIV;
            else if ( o_x87_opmask[M_FXCH_STI] )
                eu_x87_op_sel = X87_FXCH;
            else if ( o_x87_opmask[M_FLD_STI] )
                eu_x87_op_sel = X87_FLD;
            else if ( o_x87_opmask[M_FSTP_STI] )
                eu_x87_op_sel = X87_FSTP;
            else if ( o_x87_opmask[M_FCHS] )
                eu_x87_op_sel = X87_FCHS;
            else if ( o_x87_opmask[M_FABS] )
                eu_x87_op_sel = X87_FABS;
        end
    end

    wire mov_ld_mem_e  = o_opcode_x86_MOV_reg_mem_to_reg & ~modrm_is_reg;
    wire mov_st_mem_e  = o_opcode_x86_MOV_reg_to_reg_mem & ~modrm_is_reg;
    wire eu_lsu_start_w =
        insn_fire & ~cpuid_busy & ~in_exception & ~o_error & ~post486_illegal & ~if_segment_fault &
        ( mov_ld_mem_e | mov_st_mem_e );

    logic        eu_lsu_done;
    logic        eu_lsu_busy;
    logic        eu_lsu_mem_valid;
    logic        eu_lsu_mem_we;
    logic [31:0] eu_lsu_mem_addr;
    logic [31:0] eu_lsu_mem_wdata;
    logic [31:0] eu_lsu_rdata;
    logic        br_taken;
    logic [31:0] br_tgt;

    logic        lsu_done_d1;
    logic        muldiv_pair_wait;
    logic [31:0] muldiv_hi_latch;
    logic        lsu_last_was_store_r;
    logic [ 2:0] lsu_ld_dst_reg;

    logic [63:0] eu_x87_st0;
    logic [63:0] eu_x87_st1;
    logic        eu_x87_zf;
    logic        eu_x87_pf;
    logic        eu_x87_cf;

    assign data_vaild          = eu_lsu_mem_valid;
    assign data_write_enable   = eu_lsu_mem_we;
    assign data_address      = eu_lsu_mem_addr;
    assign data_data_write   = eu_lsu_mem_wdata;

    eu_execute_unit_top u_eu (
        .clk ( clock ),
        .rst ( reset ),
        .i_agu_base ( agu_base_w ),
        .i_agu_index ( agu_index_w ),
        .i_agu_scale ( o_sib_scale_factor ),
        .i_agu_disp ( o_displacement ),
        .o_agu_effective_addr ( eu_agu_ea ),
        .i_lsu_start ( eu_lsu_start_w ),
        .i_lsu_is_store ( mov_st_mem_e ),
        .i_lsu_addr ( lsu_linear_address ),
        .i_lsu_wdata ( GPR_read_32[modrm_reg_field] ),
        .o_lsu_rdata ( eu_lsu_rdata ),
        .o_lsu_done ( eu_lsu_done ),
        .o_lsu_busy ( eu_lsu_busy ),
        .o_lsu_mem_valid ( eu_lsu_mem_valid ),
        .o_lsu_mem_we ( eu_lsu_mem_we ),
        .o_lsu_mem_addr ( eu_lsu_mem_addr ),
        .o_lsu_mem_wdata ( eu_lsu_mem_wdata ),
        .i_lsu_mem_rdata ( data_data_read ),
        .i_lsu_mem_ready ( data_ready ),
        .i_br_is_jcc ( o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp ),
        .i_br_jcc_nibble ( o_tttn ),
        .i_br_CF ( CF ),
        .i_br_PF ( PF ),
        .i_br_ZF ( ZF ),
        .i_br_SF ( SF ),
        .i_br_OF ( OF ),
        .i_br_eip ( EIP + 32'd2 ),
        .i_br_rel32 ( br_rel32 ),
        .i_br_rel8 ( br_rel8 ),
        .i_br_use_rel8 ( 1'b1 ),
        .o_br_taken ( br_taken ),
        .o_br_target_eip ( br_tgt ),
        .i_md_op ( eu_md_op ),
        .i_md_lo ( eu_md_lo ),
        .i_md_hi ( eu_md_hi ),
        .i_md_src ( eu_md_src ),
        .o_md_lo ( eu_md_out_lo ),
        .o_md_hi ( eu_md_out_hi ),
        .o_md_div0 ( eu_md_div0 ),
        .i_x87_valid (
            insn_fire & o_x87_is_esc & modrm_is_reg & ( eu_x87_op_sel != X87_NOP ) & ~cpuid_busy & ~in_exception &
            ~o_error & ~post486_illegal
        ),
        .i_x87_op ( eu_x87_op_sel ),
        .i_x87_push_data ( 64'd0 ),
        .i_x87_st_src ( o_x87_rm ),
        .o_x87_st0 ( eu_x87_st0 ),
        .o_x87_st1 ( eu_x87_st1 ),
        .o_x87_zf ( eu_x87_zf ),
        .o_x87_pf ( eu_x87_pf ),
        .o_x87_cf ( eu_x87_cf )
    );

    always_ff @(posedge clock or posedge reset) begin
        if ( reset )
            lsu_done_d1 <= 1'b0;
        else
            lsu_done_d1 <= eu_lsu_done;
    end
    wire lsu_done_rise = eu_lsu_done & ~lsu_done_d1;

    always_ff @(posedge clock or posedge reset) begin
        if ( reset )
            lsu_last_was_store_r <= 1'b0;
        else if ( eu_lsu_start_w )
            lsu_last_was_store_r <= mov_st_mem_e;
    end

    always_ff @(posedge clock or posedge reset) begin
        if ( reset )
            lsu_ld_dst_reg <= 3'd0;
        else if ( eu_lsu_start_w & mov_ld_mem_e )
            lsu_ld_dst_reg <= modrm_reg_field;
    end

    assign exec_stall = cpuid_busy | xadd_wait_reg_wr | eu_lsu_busy | muldiv_pair_wait;

    // --- 异常 / 写回 ---
    logic [7:0] exception_vector;
    logic       in_exception;

    wire [2:0] cx_rm_idx  = instruction[2][2:0];
    wire [2:0] cx_r_idx   = instruction[2][5:3];
    wire [2:0] bswap_rd_n = instruction[1][2:0];

    logic [31:0] xadd_a;
    logic [31:0] xadd_sum;
    logic [31:0] bswap_v;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            write_enable <= 1'b0;
            IP_write_enable <= 1'b0;
            IP_write_data <= 32'h0;
            FLAGS_write_enable <= 1'b0;
            FLAGS_write_data <= 32'h0;
            exception_vector <= 8'h0;
            in_exception <= 1'b0;
            xadd_wait_reg_wr <= 1'b0;
            muldiv_pair_wait <= 1'b0;
        end else begin
            write_enable <= 1'b0;
            IP_write_enable <= 1'b0;
            FLAGS_write_enable <= 1'b0;

            if (cpuid_gpr_wr) begin
                write_enable <= 1'b1;
                write_index <= cpuid_gpr_idx;
                write_data <= cpuid_gpr_wdata;
            end

            if (cpuid_done_pulse) begin
                IP_write_enable <= 1'b1;
                IP_write_data <= EIP + { 28'h0, o_consume_bytes };
            end else if (xadd_wait_reg_wr) begin
                write_enable <= 1'b1;
                write_index <= xadd_saved_reg;
                write_data <= xadd_saved_val;
                IP_write_enable <= 1'b1;
                IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                xadd_wait_reg_wr <= 1'b0;
            end else if (muldiv_pair_wait) begin
                write_enable <= 1'b1;
                write_index <= 3'd2;
                write_data <= muldiv_hi_latch;
                IP_write_enable <= 1'b1;
                IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                muldiv_pair_wait <= 1'b0;
            end else if (lsu_done_rise && lsu_last_was_store_r) begin
                IP_write_enable <= 1'b1;
                IP_write_data <= EIP + { 28'h0, o_consume_bytes };
            end else if (lsu_done_rise && !lsu_last_was_store_r) begin
                write_enable <= 1'b1;
                write_index <= lsu_ld_dst_reg;
                write_data <= eu_lsu_rdata;
                IP_write_enable <= 1'b1;
                IP_write_data <= EIP + { 28'h0, o_consume_bytes };
            end else if (if_segment_fault && insn_fire) begin
                exception_vector <= 8'd13;
                in_exception <= 1'b1;
            end else if (insn_fire && !cpuid_busy && !in_exception) begin
                if (o_error || post486_illegal) begin
                    exception_vector <= 8'd6;
                    in_exception <= 1'b1;
                end else if (o_opcode_x86_CPUID_CPU_identification) begin
                end else if (o_opcode_x86_NOP_no_operation || o_opcode_x86_NOP_no_operation_multi_byte) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_CLC_clear_carry_flag) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= { EFLAGS[31:1], 1'b0 };
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_STC_set_carry_flag) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= { EFLAGS[31:1], 1'b1 };
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_INVD_invalidate_cache || o_opcode_x86_WBINVD_writeback_and_invalidate_data_cache) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_INVLPG_invalidate_TLB_entry) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_JMP_to_same_segment_short) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + 32'd2 + { { 24{ o_immediate[7] } }, o_immediate[7:0] };
                end else if (o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp && br_taken) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= br_tgt;
                end else if (o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp && !br_taken) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_IRET_interrupt_return) begin
                    if (PE) begin
                        FLAGS_write_enable <= 1'b1;
                        FLAGS_write_data <= EFLAGS;
                        IP_write_enable <= 1'b1;
                        IP_write_data <= EIP;
                        in_exception <= 1'b0;
                    end else begin
                        IP_write_enable <= 1'b1;
                        IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                    end
                end else if (
                    ( o_opcode_x86_DIV_acc_by_reg_mem | o_opcode_x86_IDIV_acc_by_reg_mem ) && modrm_is_reg &&
                    eu_md_div0
                ) begin
                    exception_vector <= 8'd0;
                    in_exception <= 1'b1;
                end else if (
                    ( o_opcode_x86_MUL_acc_with_reg_mem | o_opcode_x86_IMUL_acc_with_reg_mem ) && modrm_is_reg
                ) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_md_out_lo;
                    muldiv_hi_latch <= eu_md_out_hi;
                    muldiv_pair_wait <= 1'b1;
                end else if (
                    ( o_opcode_x86_DIV_acc_by_reg_mem | o_opcode_x86_IDIV_acc_by_reg_mem ) && modrm_is_reg &&
                    !eu_md_div0
                ) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_md_out_lo;
                    muldiv_hi_latch <= eu_md_out_hi;
                    muldiv_pair_wait <= 1'b1;
                end else if ( o_opcode_x86_IMUL_reg_with_reg_mem && modrm_is_reg ) begin
                    write_enable <= 1'b1;
                    write_index <= cx_r_idx;
                    write_data <= eu_md_out_lo;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if ( o_opcode_x86_MOV_reg_mem_to_reg && modrm_is_reg ) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_reg_field;
                    write_data <= GPR_read_32[modrm_rm_field];
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if ( o_opcode_x86_MOV_reg_to_reg_mem && modrm_is_reg ) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= GPR_read_32[modrm_reg_field];
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if ( mov_ld_mem_e | mov_st_mem_e ) begin
                end else if (o_opcode_x86_CMPXCHG_compare_and_exchange && (o_dbg_modrm_mod == 2'b11)) begin
                    if (GPR_read_32[0] == GPR_read_32[cx_rm_idx]) begin
                        write_enable <= 1'b1;
                        write_index <= cx_rm_idx;
                        write_data <= GPR_read_32[cx_r_idx];
                        FLAGS_write_enable <= 1'b1;
                        FLAGS_write_data <= { EFLAGS[31:7], 1'b1, EFLAGS[5:0] };
                    end else begin
                        write_enable <= 1'b1;
                        write_index <= 3'd0;
                        write_data <= GPR_read_32[cx_rm_idx];
                        FLAGS_write_enable <= 1'b1;
                        FLAGS_write_data <= { EFLAGS[31:7], 1'b0, EFLAGS[5:0] };
                    end
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_XADD_exchange_and_add && (o_dbg_modrm_mod == 2'b11)) begin
                    xadd_a = GPR_read_32[cx_rm_idx];
                    xadd_sum = xadd_a + GPR_read_32[cx_r_idx];
                    write_enable <= 1'b1;
                    write_index <= cx_rm_idx;
                    write_data <= xadd_sum;
                    xadd_saved_reg <= cx_r_idx;
                    xadd_saved_val <= xadd_a;
                    xadd_wait_reg_wr <= 1'b1;
                end else if (o_opcode_x86_BSWAP_byte_swap) begin
                    bswap_v = GPR_read_32[bswap_rd_n];
                    write_enable <= 1'b1;
                    write_index <= bswap_rd_n;
                    write_data <= { bswap_v[7:0], bswap_v[15:8], bswap_v[23:16], bswap_v[31:24] };
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else begin
                    exception_vector <= 8'd6;
                    in_exception <= 1'b1;
                end
            end
        end
    end

endmodule
