/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements w686_core.
*/
// ============================================================================
// w686_core — 80486 级取指/译码/执行闭环（core-side pipeline）
// ============================================================================
`include "openx86_defs.h.sv"
`include "w686_decode_outputs_decl.svh"

module w686_core (
    output logic        o_mmu_vaild,
    input  logic        i_mmu_ready,
    output logic [31:0] o_mmu_address,
    input  logic [31:0] i_mmu_data_read,

    output logic        o_code_vaild,
    input  logic        i_code_ready,
    output logic [31:0] o_code_address,
    input  logic [31:0] i_code_data_read,

    output logic        o_data_vaild,
    input  logic        i_data_ready,
    output logic        o_data_write_enable,
    output logic        o_data_io_access,
    output logic [31:0] o_data_address,
    input  logic [31:0] i_data_data_read,
    output logic [31:0] o_data_data_write,

    input  logic        clock,
    input  logic        reset
);

    import stage_3_exe_execute_unit_pkg::*;
    import stage_2_dec_decode_x87_pkg::*;

    // --- GPR / 段 / 标志 / EIP / 控制寄存器（与原实现一致）---
    logic        write_enable;
    logic [ 2:0] write_index;
    logic [31:0] write_data;
    logic        wb_write_enable;
    logic [ 2:0] wb_write_index;
    logic [31:0] wb_write_data;
    logic [31:0] GPR_read__8 [0:7];
    logic [31:0] GPR_read_16 [0:7];
    logic [31:0] GPR_read_32 [0:7];

    stage_5_wrb_general_propose_register general_propose_register (
        .write_enable ( wb_write_enable ),
        .write_index ( wb_write_index ),
        .write_data ( wb_write_data ),
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
    logic        wb_SREG_write_enable;
    logic [ 2:0] wb_SREG_write_index;
    logic [15:0] wb_SREG_write_selector;
    logic [63:0] wb_SREG_write_descriptor;
    logic [15:0] segment_selector [0:5];
    logic [63:0] descriptor_cache [0:5];

    stage_5_wrb_segment_register core_segment_register (
        .write_enable ( wb_SREG_write_enable ),
        .write_index ( wb_SREG_write_index ),
        .write_selector ( wb_SREG_write_selector ),
        .write_descriptor ( wb_SREG_write_descriptor ),
        .segment_selector ( segment_selector ),
        .descriptor_cache ( descriptor_cache ),
        .clock ( clock ),
        .reset ( reset )
    );

    logic         FLAGS_write_enable;
    logic [31:0]  FLAGS_write_data;
    logic         wb_FLAGS_write_enable;
    logic [31:0]  wb_FLAGS_write_data;
    logic         CF, PF, AF, ZF, SF, TF, IF, DF, OF;
    logic [ 1:0]  IOPL;
    logic         NT, RF, VM;
    logic [31:0]  EFLAGS;
    logic [15:0]  FLAGS;

    stage_5_wrb_flags_register core_flags_register (
        .write_enable ( wb_FLAGS_write_enable ),
        .write_data ( wb_FLAGS_write_data ),
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
    logic        wb_IP_write_enable;
    logic [31:0] wb_IP_write_data;
    logic [15:0] IP;
    logic [31:0] EIP;

    stage_5_wrb_instruction_point_register core_instruction_point_register (
        .write_enable ( wb_IP_write_enable ),
        .write_data ( wb_IP_write_data ),
        .IP ( IP ),
        .EIP ( EIP ),
        .clock ( clock ),
        .reset ( reset )
    );

    logic         CR_write_enable;
    logic [ 2: 0] CR_write_index;
    logic [31: 0] CR_write_data;
    logic         wb_CR_write_enable;
    logic [ 2: 0] wb_CR_write_index;
    logic [31: 0] wb_CR_write_data;
    logic [31: 0] CR [0:7];
    logic         PE, MP, EM, TS, R, PG;
    logic [19: 0] page_directory_base;

    stage_5_wrb_control_register core_control_register (
        .write_enable ( wb_CR_write_enable ),
        .write_index ( wb_CR_write_index ),
        .write_data ( wb_CR_write_data ),
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
    logic         wb_DR_write_enable;
    logic [ 2: 0] wb_DR_write_index;
    logic [31: 0] wb_DR_write_data;
    logic [31: 0] DR [0:7];

    stage_5_wrb_debug_register core_debug_register (
        .write_enable ( wb_DR_write_enable ),
        .write_index ( wb_DR_write_index ),
        .write_data ( wb_DR_write_data ),
        .DR ( DR ),
        .clock ( clock ),
        .reset ( reset )
    );

    logic         TR_write_enable;
    logic [ 2: 0] TR_write_index;
    logic [31: 0] TR_write_data;
    logic         wb_TR_write_enable;
    logic [ 2: 0] wb_TR_write_index;
    logic [31: 0] wb_TR_write_data;
    logic [31: 0] TR [0:7];

    stage_5_wrb_test_register core_test_register (
        .write_enable ( wb_TR_write_enable ),
        .write_index ( wb_TR_write_index ),
        .write_data ( wb_TR_write_data ),
        .TR ( TR ),
        .clock ( clock ),
        .reset ( reset )
    );

    logic        GDTR_write_enable;
    logic [15:0] GDTR_write_data_limit;
    logic [31:0] GDTR_write_data_base;
    logic [15:0] GDTR_limit;
    logic [31:0] GDTR_base;

    stage_5_wrb_sar_global_descriptor_table_register core_global_descriptor_table_register (
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

    stage_5_wrb_sar_interrupt_descriptor_table_register core_interrupt_descriptor_table_register (
        .IDTR_write_enable ( IDTR_write_enable ),
        .IDTR_write_data_limit ( IDTR_write_data_limit ),
        .IDTR_write_data_base ( IDTR_write_data_base ),
        .IDTR_limit ( IDTR_limit ),
        .IDTR_base ( IDTR_base ),
        .clock ( clock ),
        .reset ( reset )
    );

    assign GDTR_write_enable   = 1'b0;
    assign IDTR_write_enable   = 1'b0;

    // CPL = CS.RPL
    wire [1:0] current_privilege_level = segment_selector[`sreg_index_CS][1:0];

    // --- Core-side memory request channels (BIU is instantiated in w686_cpu) ---
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

    assign o_mmu_vaild    = mmu_bus_vaild;
    assign mmu_bus_ready  = i_mmu_ready;
    assign o_mmu_address  = mmu_bus_addr;
    assign mmu_bus_rdata  = i_mmu_data_read;

    assign o_code_vaild   = code_vaild;
    assign code_ready     = i_code_ready;
    assign o_code_address = code_address;
    assign code_data_read = i_code_data_read;

    assign o_data_vaild        = data_vaild;
    assign data_ready          = i_data_ready;
    assign o_data_write_enable = data_write_enable;
    assign o_data_io_access    = 1'b0;
    assign o_data_address      = data_address;
    assign data_data_read      = i_data_data_read;
    assign o_data_data_write   = data_data_write;

    // --- 取指 ---
    logic [ 7:0] instruction [0:15];
    logic        instruction_ready;
    logic        if_segment_fault;

    wire         exec_stall;
    wire         ip_valid_to_fetch = ~exec_stall;

    stage_1_isc u_stage_1_isc (
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
    stage_2_dec_decode_unit core_decode (
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
    logic        stage2_valid;
    logic        stage3_valid;
    logic        stage4_valid;
    logic        stage5_valid;
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

    stage_2_dec u_stage_2_dec (
        .i_instruction_ready ( instruction_ready ),
        .o_stage_valid ( stage2_valid ),
        .o_insn_fire ( insn_fire ),
        .i_clock ( clock ),
        .i_reset ( reset )
    );

    stage_3_exe_w686_core_execute_i486 u_exec486 (
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

    // --- EU/AM：EU 负责计算，AM 负责访存握手 ---
    logic [31:0] br_rel32;
    logic signed [7:0] br_rel8;
    assign br_rel32 = o_immediate;
    assign br_rel8  = o_immediate[7:0];

    wire modrm_is_reg = ( o_dbg_modrm_mod == 2'b11 );
    wire [2:0] modrm_reg_field = instruction[1][5:3];
    wire [2:0] modrm_rm_field  = instruction[1][2:0];
    wire modrm2_is_reg = ( instruction[2][7:6] == 2'b11 );
    wire [2:0] modrm2_reg_field = instruction[2][5:3];
    wire [2:0] modrm2_rm_field  = instruction[2][2:0];

    wire [31:0] agu_base_w =
        o_base_reg_is_present ? GPR_read_32[o_base_reg_index] : 32'd0;
    wire [31:0] agu_index_w =
        o_index_reg_is_present ? GPR_read_32[o_index_reg_index] : 32'd0;

    wire [31:0] dseg_base_linear = {
        descriptor_cache[o_segment_reg_index][31:24],
        descriptor_cache[o_segment_reg_index][7:0],
        descriptor_cache[o_segment_reg_index][63:48]
    };
    wire [31:0] sseg_base_linear = {
        descriptor_cache[`sreg_index_SS][31:24],
        descriptor_cache[`sreg_index_SS][7:0],
        descriptor_cache[`sreg_index_SS][63:48]
    };
    wire [31:0] cseg_base_linear = {
        descriptor_cache[`sreg_index_CS][31:24],
        descriptor_cache[`sreg_index_CS][7:0],
        descriptor_cache[`sreg_index_CS][63:48]
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
    int_op_e     eu_int_op_sel;
    logic        eu_int_valid;
    logic [31:0] eu_int_a;
    logic [31:0] eu_int_b;
    logic        eu_int_cf;
    logic        eu_int_af;
    logic [31:0] eu_int_count;
    logic [31:0] eu_int_result;
    logic        eu_int_cf_out;
    logic        eu_int_af_out;
    logic        eu_int_zf_out;

    always_comb begin
        eu_md_op  = MD_NOP;
        eu_md_lo  = GPR_read_32[0];
        eu_md_hi  = GPR_read_32[2];
        eu_md_src = GPR_read_32[modrm_rm_field];
        if ( o_opcode_x86_MUL_acc_with_reg_mem && modrm_is_reg )
            eu_md_op = MD_MULU32;
        else if ( o_opcode_x86_IMUL_acc_with_reg_mem && modrm_is_reg )
            eu_md_op = MD_IMUL32;
        else if ( o_opcode_x86_IMUL_reg_with_reg_mem && modrm2_is_reg ) begin
            eu_md_op  = MD_IMUL32;
            eu_md_lo  = GPR_read_32[cx_r_idx];
            eu_md_src = GPR_read_32[cx_rm_idx];
        end else if ( o_opcode_x86_DIV_acc_by_reg_mem && modrm_is_reg )
            eu_md_op = MD_DIVU32;
        else if ( o_opcode_x86_IDIV_acc_by_reg_mem && modrm_is_reg )
            eu_md_op = MD_IDIV32;
    end

    always_comb begin
        eu_int_op_sel = INT_NOP;
        eu_int_valid  = 1'b0;
        eu_int_a      = 32'd0;
        eu_int_b      = 32'd0;
        eu_int_cf     = CF;
        eu_int_af     = AF;
        eu_int_count  = 32'd0;

        if (o_opcode_x86_ADD_reg_to_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_ADD;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = GPR_read_32[modrm_reg_field];
        end else if (o_opcode_x86_ADD_reg_mem_to_reg && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_ADD;
            eu_int_a      = GPR_read_32[modrm_reg_field];
            eu_int_b      = GPR_read_32[modrm_rm_field];
        end else if (o_opcode_x86_ADD_imm_to_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_ADD;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_ADD_imm_to_acc) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_ADD;
            eu_int_a      = GPR_read_32[0];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_ADC_reg_to_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_ADC;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = GPR_read_32[modrm_reg_field];
        end else if (o_opcode_x86_ADC_reg_mem_to_reg && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_ADC;
            eu_int_a      = GPR_read_32[modrm_reg_field];
            eu_int_b      = GPR_read_32[modrm_rm_field];
        end else if (o_opcode_x86_ADC_imm_to_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_ADC;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_ADC_imm_to_acc) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_ADC;
            eu_int_a      = GPR_read_32[0];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_SUB_reg_to_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SUB;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = GPR_read_32[modrm_reg_field];
        end else if (o_opcode_x86_SUB_reg_mem_to_reg && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SUB;
            eu_int_a      = GPR_read_32[modrm_reg_field];
            eu_int_b      = GPR_read_32[modrm_rm_field];
        end else if (o_opcode_x86_SUB_imm_to_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SUB;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_SUB_imm_to_acc) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SUB;
            eu_int_a      = GPR_read_32[0];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_SBB_reg_to_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SBB;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = GPR_read_32[modrm_reg_field];
        end else if (o_opcode_x86_SBB_reg_mem_to_reg && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SBB;
            eu_int_a      = GPR_read_32[modrm_reg_field];
            eu_int_b      = GPR_read_32[modrm_rm_field];
        end else if (o_opcode_x86_SBB_imm_to_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SBB;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_SBB_imm_to_acc) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SBB;
            eu_int_a      = GPR_read_32[0];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_AND_reg_to_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_AND;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = GPR_read_32[modrm_reg_field];
        end else if (o_opcode_x86_AND_reg_mem_to_reg && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_AND;
            eu_int_a      = GPR_read_32[modrm_reg_field];
            eu_int_b      = GPR_read_32[modrm_rm_field];
        end else if (o_opcode_x86_AND_imm_to_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_AND;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_AND_imm_to_acc) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_AND;
            eu_int_a      = GPR_read_32[0];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_OR_reg_to_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_OR;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = GPR_read_32[modrm_reg_field];
        end else if (o_opcode_x86_OR_reg_mem_to_reg && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_OR;
            eu_int_a      = GPR_read_32[modrm_reg_field];
            eu_int_b      = GPR_read_32[modrm_rm_field];
        end else if (o_opcode_x86_OR_imm_to_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_OR;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_OR_imm_to_acc) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_OR;
            eu_int_a      = GPR_read_32[0];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_XOR_reg_to_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_XOR;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = GPR_read_32[modrm_reg_field];
        end else if (o_opcode_x86_XOR_reg_mem_to_reg && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_XOR;
            eu_int_a      = GPR_read_32[modrm_reg_field];
            eu_int_b      = GPR_read_32[modrm_rm_field];
        end else if (o_opcode_x86_XOR_imm_to_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_XOR;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_XOR_imm_to_acc) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_XOR;
            eu_int_a      = GPR_read_32[0];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_CMP_mem_with_reg && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SUB;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = GPR_read_32[modrm_reg_field];
        end else if (o_opcode_x86_CMP_reg_with_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SUB;
            eu_int_a      = GPR_read_32[modrm_reg_field];
            eu_int_b      = GPR_read_32[modrm_rm_field];
        end else if (o_opcode_x86_CMP_imm_with_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SUB;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_CMP_imm_with_acc) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SUB;
            eu_int_a      = GPR_read_32[0];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_TEST_reg_mem_and_reg && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_AND;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = GPR_read_32[modrm_reg_field];
        end else if (o_opcode_x86_TEST_imm_and_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_AND;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_TEST_imm_and_acc) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_AND;
            eu_int_a      = GPR_read_32[0];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_NOT_one_s_complement_negation && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_NOT;
            eu_int_a      = GPR_read_32[modrm_rm_field];
        end else if (o_opcode_x86_NEG_two_s_complement_negation && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_NEG;
            eu_int_a      = GPR_read_32[modrm_rm_field];
        end else if (o_opcode_x86_INC_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_INC;
            eu_int_a      = GPR_read_32[short_reg_idx];
        end else if (o_opcode_x86_DEC_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_DEC;
            eu_int_a      = GPR_read_32[short_reg_idx];
        end else if (o_opcode_x86_INC_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_INC;
            eu_int_a      = GPR_read_32[modrm_rm_field];
        end else if (o_opcode_x86_DEC_reg_mem && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_DEC;
            eu_int_a      = GPR_read_32[modrm_rm_field];
        end else if ((o_opcode_x86_RCL_reg_mem_by_1 || o_opcode_x86_RCL_reg_mem_by_CL || o_opcode_x86_RCL_reg_mem_by_imm) && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_RCL;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            if (o_opcode_x86_RCL_reg_mem_by_1)
                eu_int_count = 32'd1;
            else if (o_opcode_x86_RCL_reg_mem_by_CL)
                eu_int_count = { 27'd0, GPR_read_32[1][4:0] };
            else
                eu_int_count = { 27'd0, o_immediate[4:0] };
        end else if ((o_opcode_x86_RCR_reg_mem_by_1 || o_opcode_x86_RCR_reg_mem_by_CL || o_opcode_x86_RCR_reg_mem_by_imm) && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_RCR;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            if (o_opcode_x86_RCR_reg_mem_by_1)
                eu_int_count = 32'd1;
            else if (o_opcode_x86_RCR_reg_mem_by_CL)
                eu_int_count = { 27'd0, GPR_read_32[1][4:0] };
            else
                eu_int_count = { 27'd0, o_immediate[4:0] };
        end else if ((o_opcode_x86_ROL_reg_mem_by_1 || o_opcode_x86_ROL_reg_mem_by_CL || o_opcode_x86_ROL_reg_mem_by_imm) && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_ROL;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            if (o_opcode_x86_ROL_reg_mem_by_1)
                eu_int_count = 32'd1;
            else if (o_opcode_x86_ROL_reg_mem_by_CL)
                eu_int_count = { 27'd0, GPR_read_32[1][4:0] };
            else
                eu_int_count = { 27'd0, o_immediate[4:0] };
        end else if ((o_opcode_x86_ROR_reg_mem_by_1 || o_opcode_x86_ROR_reg_mem_by_CL || o_opcode_x86_ROR_reg_mem_by_imm) && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_ROR;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            if (o_opcode_x86_ROR_reg_mem_by_1)
                eu_int_count = 32'd1;
            else if (o_opcode_x86_ROR_reg_mem_by_CL)
                eu_int_count = { 27'd0, GPR_read_32[1][4:0] };
            else
                eu_int_count = { 27'd0, o_immediate[4:0] };
        end else if ((o_opcode_x86_SHL_reg_mem_by_1 || o_opcode_x86_SHL_reg_mem_by_CL || o_opcode_x86_SHL_reg_mem_by_imm) && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SHL;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            if (o_opcode_x86_SHL_reg_mem_by_1)
                eu_int_count = 32'd1;
            else if (o_opcode_x86_SHL_reg_mem_by_CL)
                eu_int_count = { 27'd0, GPR_read_32[1][4:0] };
            else
                eu_int_count = { 27'd0, o_immediate[4:0] };
        end else if ((o_opcode_x86_SHR_reg_mem_by_1 || o_opcode_x86_SHR_reg_mem_by_CL || o_opcode_x86_SHR_reg_mem_by_imm) && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SHR;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            if (o_opcode_x86_SHR_reg_mem_by_1)
                eu_int_count = 32'd1;
            else if (o_opcode_x86_SHR_reg_mem_by_CL)
                eu_int_count = { 27'd0, GPR_read_32[1][4:0] };
            else
                eu_int_count = { 27'd0, o_immediate[4:0] };
        end else if ((o_opcode_x86_SAR_reg_mem_by_1 || o_opcode_x86_SAR_reg_mem_by_CL || o_opcode_x86_SAR_reg_mem_by_imm) && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SAR;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            if (o_opcode_x86_SAR_reg_mem_by_1)
                eu_int_count = 32'd1;
            else if (o_opcode_x86_SAR_reg_mem_by_CL)
                eu_int_count = { 27'd0, GPR_read_32[1][4:0] };
            else
                eu_int_count = { 27'd0, o_immediate[4:0] };
        end else if ((o_opcode_x86_SHLD_reg_mem_by_imm || o_opcode_x86_SHLD_reg_mem_by_CL) && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SHLD;
            eu_int_a      = GPR_read_32[modrm2_rm_field];
            eu_int_b      = GPR_read_32[modrm2_reg_field];
            if (o_opcode_x86_SHLD_reg_mem_by_CL)
                eu_int_count = { 27'd0, GPR_read_32[1][4:0] };
            else
                eu_int_count = { 27'd0, o_immediate[4:0] };
        end else if ((o_opcode_x86_SHRD_reg_mem_by_imm || o_opcode_x86_SHRD_reg_mem_by_CL) && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SHRD;
            eu_int_a      = GPR_read_32[modrm2_rm_field];
            eu_int_b      = GPR_read_32[modrm2_reg_field];
            if (o_opcode_x86_SHRD_reg_mem_by_CL)
                eu_int_count = { 27'd0, GPR_read_32[1][4:0] };
            else
                eu_int_count = { 27'd0, o_immediate[4:0] };
        end else if (o_opcode_x86_BSF_bit_scan_forward && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_BSF;
            eu_int_a      = GPR_read_32[cx_rm_idx];
        end else if (o_opcode_x86_BSR_bit_scan_reverse && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_BSR;
            eu_int_a      = GPR_read_32[cx_rm_idx];
        end else if (o_opcode_x86_BT_reg_mem_with_reg && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_BT;
            eu_int_a      = GPR_read_32[modrm2_rm_field];
            eu_int_b      = GPR_read_32[modrm2_reg_field];
        end else if (o_opcode_x86_BT_reg_mem_with_imm && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_BT;
            eu_int_a      = GPR_read_32[modrm2_rm_field];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_BTC_reg_mem_with_reg && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_BTC;
            eu_int_a      = GPR_read_32[modrm2_rm_field];
            eu_int_b      = GPR_read_32[modrm2_reg_field];
        end else if (o_opcode_x86_BTC_reg_mem_with_imm && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_BTC;
            eu_int_a      = GPR_read_32[modrm2_rm_field];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_BTR_reg_mem_with_reg && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_BTR;
            eu_int_a      = GPR_read_32[modrm2_rm_field];
            eu_int_b      = GPR_read_32[modrm2_reg_field];
        end else if (o_opcode_x86_BTR_reg_mem_with_imm && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_BTR;
            eu_int_a      = GPR_read_32[modrm2_rm_field];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_BTS_reg_mem_with_reg && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_BTS;
            eu_int_a      = GPR_read_32[modrm2_rm_field];
            eu_int_b      = GPR_read_32[modrm2_reg_field];
        end else if (o_opcode_x86_BTS_reg_mem_with_imm && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_BTS;
            eu_int_a      = GPR_read_32[modrm2_rm_field];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_AAA_ASCII_adjust_after_add) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_AAA;
            eu_int_a      = GPR_read_32[0];
        end else if (o_opcode_x86_AAS_ASCII_adjust_after_sub) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_AAS;
            eu_int_a      = GPR_read_32[0];
        end else if (o_opcode_x86_DAA_decimal_adjust_AL_after_add) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_DAA;
            eu_int_a      = GPR_read_32[0];
        end else if (o_opcode_x86_DAS_decimal_adjust_AL_after_sub) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_DAS;
            eu_int_a      = GPR_read_32[0];
        end else if (o_opcode_x86_CLC_clear_carry_flag) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_CLC;
            eu_int_a      = EFLAGS;
        end else if (o_opcode_x86_STC_set_carry_flag) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_STC;
            eu_int_a      = EFLAGS;
        end else if (o_opcode_x86_CMC_complement_carry_flag) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_CMC;
            eu_int_a      = EFLAGS;
        end else if (o_opcode_x86_CLD_clear_direction_flag) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_CLD;
            eu_int_a      = EFLAGS;
        end else if (o_opcode_x86_STD_set_direction_flag) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_STD;
            eu_int_a      = EFLAGS;
        end else if (o_opcode_x86_CLI_clear_interrupt_enable_flag) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_CLI;
            eu_int_a      = EFLAGS;
        end else if (o_opcode_x86_STI_set_interrupt_enable_flag) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_STI;
            eu_int_a      = EFLAGS;
        end else if (o_opcode_x86_CLTS_clear_task_switched_flag) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_CLTS;
            eu_int_a      = CR[0];
        end else if (o_opcode_x86_LAHF_load_FLAG_into_AH) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_LAHF;
            eu_int_a      = GPR_read_32[0];
            eu_int_b      = EFLAGS;
        end else if (o_opcode_x86_SAHF_store_AH_into_flags) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SAHF;
            eu_int_a      = EFLAGS;
            eu_int_b      = GPR_read_32[0];
        end else if (o_opcode_x86_AAD_ASCII_AX_before_div) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_AAD;
            eu_int_a      = GPR_read_32[0];
        end else if (o_opcode_x86_AAM_ASCII_AX_after_mul) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_AAM;
            eu_int_a      = GPR_read_32[0];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_CBW_convert_byte_to_word || o_opcode_x86_CWDE_convert_word_to_double) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_CBW;
            eu_int_a      = GPR_read_32[0];
        end else if (o_opcode_x86_CWD_convert_word_to_double || o_opcode_x86_CDQ_convert_double_word_to_quad_word) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_CDQ;
            eu_int_a      = GPR_read_32[0];
        end else if (o_opcode_x86_LODS_load_string_operand) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_STRIDX_STEP;
            eu_int_a      = GPR_read_32[6];
            eu_int_count  = { 31'd0, DF };
        end else if (o_opcode_x86_STOS_store_string_data) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_STRIDX_STEP;
            eu_int_a      = GPR_read_32[7];
            eu_int_count  = { 31'd0, DF };
        end else if (o_opcode_x86_MOVS_move_data_from_string_to_string) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_STRIDX_STEP;
            eu_int_a      = GPR_read_32[6];
            eu_int_count  = { 31'd0, DF };
        end else if (o_opcode_x86_CMPS_compare_string_operands) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_STRIDX_STEP;
            eu_int_a      = GPR_read_32[6];
            eu_int_count  = { 31'd0, DF };
        end else if (o_opcode_x86_SCAS_scan_string) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_STRIDX_STEP;
            eu_int_a      = GPR_read_32[7];
            eu_int_count  = { 31'd0, DF };
        end else if (o_opcode_x86_INS_input_from_DX_port) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_STRIDX_STEP;
            eu_int_a      = GPR_read_32[7];
            eu_int_count  = { 31'd0, DF };
        end else if (o_opcode_x86_OUTS_output_string) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_STRIDX_STEP;
            eu_int_a      = GPR_read_32[6];
            eu_int_count  = { 31'd0, DF };
        end else if (o_opcode_x86_JCXZ_jump_on_CX_zero) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_LOOP_CTRL;
            eu_int_a      = GPR_read_32[1];
            eu_int_b      = { 31'd0, ZF };
            eu_int_count  = { 30'd0, 2'b11 };
        end else if (o_opcode_x86_LOOP_count) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_LOOP_CTRL;
            eu_int_a      = GPR_read_32[1];
            eu_int_b      = { 31'd0, ZF };
            eu_int_count  = { 30'd0, 2'b00 };
        end else if (o_opcode_x86_LOOPZ_count_while_zero) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_LOOP_CTRL;
            eu_int_a      = GPR_read_32[1];
            eu_int_b      = { 31'd0, ZF };
            eu_int_count  = { 30'd0, 2'b01 };
        end else if (o_opcode_x86_LOOPNZ_count_while_not_zero) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_LOOP_CTRL;
            eu_int_a      = GPR_read_32[1];
            eu_int_b      = { 31'd0, ZF };
            eu_int_count  = { 30'd0, 2'b10 };
        end else if (o_opcode_x86_IMUL_reg_mem_with_imm_to_reg && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_IMUL_IMM;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = o_immediate;
        end else if (o_opcode_x86_LMSW_load_status_word && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_LMSW;
            eu_int_a      = CR[0];
            eu_int_b      = GPR_read_32[cx_rm_idx];
        end else if (o_opcode_x86_SMSW_store_machine_status_word && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SMSW;
            eu_int_a      = CR[0];
        end else if (o_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_MOVSX;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_count  = { 30'd0, o_gen_reg_bit_width_from_mod_rm };
        end else if (o_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_MOVZX;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_count  = { 30'd0, o_gen_reg_bit_width_from_mod_rm };
        end else if (o_opcode_x86_XCHG_reg_mem_with_reg && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_XCHG;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = GPR_read_32[modrm_reg_field];
        end else if (o_opcode_x86_XCHG_reg_with_acc_short && (short_reg_idx != 3'd0)) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_XCHG;
            eu_int_a      = GPR_read_32[0];
            eu_int_b      = GPR_read_32[short_reg_idx];
        end else if (o_opcode_x86_XADD_exchange_and_add && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_XADD;
            eu_int_a      = GPR_read_32[cx_rm_idx];
            eu_int_b      = GPR_read_32[cx_r_idx];
        end else if (o_opcode_x86_CMPXCHG_compare_and_exchange && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_CMPXCHG;
            eu_int_a      = GPR_read_32[0];
            eu_int_b      = GPR_read_32[cx_rm_idx];
            eu_int_count  = GPR_read_32[cx_r_idx];
        end else if (o_opcode_x86_SETcc_byte_set_on_condition && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_SETCC;
            eu_int_a      = EFLAGS;
            eu_int_count  = { 28'd0, o_tttn };
        end else if (o_opcode_x86_ARPL_adjust_RPL_field_of_selector && modrm_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_ARPL;
            eu_int_a      = GPR_read_32[modrm_rm_field];
            eu_int_b      = GPR_read_32[modrm_reg_field];
        end else if (o_opcode_x86_LAR_load_access_rights_byte && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_LAR;
            eu_int_a      = GPR_read_32[cx_rm_idx];
        end else if (o_opcode_x86_LSL_load_segment_limit && modrm2_is_reg) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_LSL;
            eu_int_a      = GPR_read_32[cx_rm_idx];
        end else if (o_opcode_x86_VERR_verify_a_segment_for_reading || o_opcode_x86_VERW_verify_a_segment_for_writing) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_VERR;
            eu_int_a      = GPR_read_32[cx_rm_idx];
        end else if (o_opcode_x86_BSWAP_byte_swap) begin
            eu_int_valid  = 1'b1;
            eu_int_op_sel = INT_BSWAP;
            eu_int_a      = GPR_read_32[bswap_rd_n];
        end
    end

    x87_op_e eu_x87_op_sel;
    always_comb begin
        eu_x87_op_sel = X87_NOP;
        if ( o_x87_is_esc ) begin
            if ( o_x87_opmask[M_FADD_ST0_STI] )
                eu_x87_op_sel = X87_FADD;
            else if ( o_x87_opmask[M_FMUL_ST0_STI] )
                eu_x87_op_sel = X87_FMUL;
            else if ( o_x87_opmask[M_FSUB_ST0_STI] )
                eu_x87_op_sel = X87_FSUB;
            else if ( o_x87_opmask[M_FSUBR_ST0_STI] )
                eu_x87_op_sel = X87_FSUBR;
            else if ( o_x87_opmask[M_FDIV_ST0_STI] )
                eu_x87_op_sel = X87_FDIV;
            else if ( o_x87_opmask[M_FDIVR_ST0_STI] )
                eu_x87_op_sel = X87_FDIVR;
            else if ( o_x87_opmask[M_FXCH_STI] )
                eu_x87_op_sel = X87_FXCH;
            else if ( o_x87_opmask[M_FLD_STI] )
                eu_x87_op_sel = X87_FLD_STI;
            else if ( o_x87_opmask[M_FLD1] )
                eu_x87_op_sel = X87_FLD1;
            else if ( o_x87_opmask[M_FLDZ] )
                eu_x87_op_sel = X87_FLDZ;
            else if ( o_x87_opmask[M_FST_STI] )
                eu_x87_op_sel = X87_FST;
            else if ( o_x87_opmask[M_FSTP_STI] )
                eu_x87_op_sel = X87_FSTP;
            else if ( o_x87_opmask[M_FFREE_STI] )
                eu_x87_op_sel = X87_FFREE;
            else if ( o_x87_opmask[M_FCHS] )
                eu_x87_op_sel = X87_FCHS;
            else if ( o_x87_opmask[M_FABS] )
                eu_x87_op_sel = X87_FABS;
            else if ( o_x87_opmask[M_FCOM_STI] )
                eu_x87_op_sel = X87_FCOM;
            else if ( o_x87_opmask[M_FCOMP_STI] )
                eu_x87_op_sel = X87_FCOMP;
            else if ( o_x87_opmask[M_FTST] )
                eu_x87_op_sel = X87_FTST;
            else if ( o_x87_opmask[M_FNOP] )
                eu_x87_op_sel = X87_FNOP;
            else if ( o_x87_opmask[M_FADDP_STI_ST0] )
                eu_x87_op_sel = X87_FADDP;
            else if ( o_x87_opmask[M_FMULP_STI_ST0] )
                eu_x87_op_sel = X87_FMULP;
            else if ( o_x87_opmask[M_FSUBP_STI_ST0] )
                eu_x87_op_sel = X87_FSUBP;
            else if ( o_x87_opmask[M_FSUBRP_STI_ST0] )
                eu_x87_op_sel = X87_FSUBRP;
            else if ( o_x87_opmask[M_FDIVP_STI_ST0] )
                eu_x87_op_sel = X87_FDIVP;
            else if ( o_x87_opmask[M_FDIVRP_STI_ST0] )
                eu_x87_op_sel = X87_FDIVRP;
            else if ( o_x87_opmask[M_FCOMIP_STI] )
                eu_x87_op_sel = X87_FCOMIP;
            else if ( o_x87_opmask[M_FUCOMIP_STI] )
                eu_x87_op_sel = X87_FUCOMIP;
            else if ( o_x87_opmask[M_FLD_M32] || o_x87_opmask[M_FILD_M32] )
                eu_x87_op_sel = X87_FLD;
            else if ( o_x87_opmask[M_FSTP_M32] || o_x87_opmask[M_FISTP_M32] )
                eu_x87_op_sel = X87_FSTP;
        end
    end

    logic [63:0] eu_x87_push_data;
    always_comb begin
        eu_x87_push_data = 64'd0;
        unique case (eu_x87_op_sel)
            X87_FLD1: eu_x87_push_data = 64'd1;
            X87_FLDZ: eu_x87_push_data = 64'd0;
            default:  eu_x87_push_data = 64'd0;
        endcase
    end

    wire mov_ld_mem_e  = o_opcode_x86_MOV_reg_mem_to_reg & ~modrm_is_reg;
    wire mov_st_mem_e  = o_opcode_x86_MOV_reg_to_reg_mem & ~modrm_is_reg;
    wire mov_ld_acc_mem_e = o_opcode_x86_MOV_mem_to_acc;
    wire mov_st_acc_mem_e = o_opcode_x86_MOV_acc_to_mem;
    wire [31:0] mov_moffs_linear = dseg_base_linear + o_displacement;
    wire        lsu_is_store_w = mov_st_mem_e | mov_st_acc_mem_e;
    wire [31:0] lsu_addr_req_w = (mov_ld_acc_mem_e | mov_st_acc_mem_e) ? mov_moffs_linear : lsu_linear_address;
    wire [31:0] lsu_wdata_req_w = mov_st_acc_mem_e ? GPR_read_32[0] : GPR_read_32[modrm_reg_field];
    wire am_lsu_start_w =
        insn_fire & ~cpuid_busy & ~in_exception & ~o_error & ~post486_illegal & ~if_segment_fault &
        ( mov_ld_mem_e | mov_st_mem_e | mov_ld_acc_mem_e | mov_st_acc_mem_e );

    logic        am_lsu_done;
    logic        am_lsu_busy;
    logic        am_lsu_mem_valid;
    logic        am_lsu_mem_we;
    logic [31:0] am_lsu_mem_addr;
    logic [31:0] am_lsu_mem_wdata;
    logic [31:0] am_lsu_rdata;
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

    logic        wb_mem_valid;
    logic        wb_mem_write_enable;
    logic [31:0] wb_mem_address;
    logic [31:0] wb_mem_write_data;

    stage_5_wrb u_stage_5_wrb (
        .i_stage4_valid ( stage4_valid ),
        .o_stage_valid ( stage5_valid ),
        .i_gpr_write_enable ( write_enable ),
        .i_gpr_write_index ( write_index ),
        .i_gpr_write_data ( write_data ),
        .o_gpr_write_enable ( wb_write_enable ),
        .o_gpr_write_index ( wb_write_index ),
        .o_gpr_write_data ( wb_write_data ),
        .i_sreg_write_enable ( SREG_write_enable ),
        .i_sreg_write_index ( SREG_write_index ),
        .i_sreg_write_selector ( SREG_write_selector ),
        .i_sreg_write_descriptor ( SREG_write_descriptor ),
        .o_sreg_write_enable ( wb_SREG_write_enable ),
        .o_sreg_write_index ( wb_SREG_write_index ),
        .o_sreg_write_selector ( wb_SREG_write_selector ),
        .o_sreg_write_descriptor ( wb_SREG_write_descriptor ),
        .i_flags_write_enable ( FLAGS_write_enable ),
        .i_flags_write_data ( FLAGS_write_data ),
        .o_flags_write_enable ( wb_FLAGS_write_enable ),
        .o_flags_write_data ( wb_FLAGS_write_data ),
        .i_ip_write_enable ( IP_write_enable ),
        .i_ip_write_data ( IP_write_data ),
        .o_ip_write_enable ( wb_IP_write_enable ),
        .o_ip_write_data ( wb_IP_write_data ),
        .i_cr_write_enable ( CR_write_enable ),
        .i_cr_write_index ( CR_write_index ),
        .i_cr_write_data ( CR_write_data ),
        .o_cr_write_enable ( wb_CR_write_enable ),
        .o_cr_write_index ( wb_CR_write_index ),
        .o_cr_write_data ( wb_CR_write_data ),
        .i_dr_write_enable ( DR_write_enable ),
        .i_dr_write_index ( DR_write_index ),
        .i_dr_write_data ( DR_write_data ),
        .o_dr_write_enable ( wb_DR_write_enable ),
        .o_dr_write_index ( wb_DR_write_index ),
        .o_dr_write_data ( wb_DR_write_data ),
        .i_tr_write_enable ( TR_write_enable ),
        .i_tr_write_index ( TR_write_index ),
        .i_tr_write_data ( TR_write_data ),
        .o_tr_write_enable ( wb_TR_write_enable ),
        .o_tr_write_index ( wb_TR_write_index ),
        .o_tr_write_data ( wb_TR_write_data ),
        .i_mem_valid ( am_lsu_mem_valid ),
        .i_mem_write_enable ( am_lsu_mem_we ),
        .i_mem_address ( am_lsu_mem_addr ),
        .i_mem_write_data ( am_lsu_mem_wdata ),
        .o_mem_valid ( wb_mem_valid ),
        .o_mem_write_enable ( wb_mem_write_enable ),
        .o_mem_address ( wb_mem_address ),
        .o_mem_write_data ( wb_mem_write_data )
    );

    assign data_vaild        = wb_mem_valid;
    assign data_write_enable = wb_mem_write_enable;
    assign data_address      = wb_mem_address;
    assign data_data_write   = wb_mem_write_data;

    stage_3_exe_execute_unit u_eu (
        .clk ( clock ),
        .rst ( reset ),
        .i_agu_base ( agu_base_w ),
        .i_agu_index ( agu_index_w ),
        .i_agu_scale ( o_sib_scale_factor ),
        .i_agu_disp ( o_displacement ),
        .o_agu_effective_addr ( eu_agu_ea ),
        .i_br_is_jcc ( o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp | o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp ),
        .i_br_jcc_nibble ( o_tttn ),
        .i_br_CF ( CF ),
        .i_br_PF ( PF ),
        .i_br_ZF ( ZF ),
        .i_br_SF ( SF ),
        .i_br_OF ( OF ),
        .i_br_eip ( EIP + { 28'h0, o_consume_bytes } ),
        .i_br_rel32 ( br_rel32 ),
        .i_br_rel8 ( br_rel8 ),
        .i_br_use_rel8 ( o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp ),
        .o_br_taken ( br_taken ),
        .o_br_target_eip ( br_tgt ),
        .i_md_op ( eu_md_op ),
        .i_md_lo ( eu_md_lo ),
        .i_md_hi ( eu_md_hi ),
        .i_md_src ( eu_md_src ),
        .o_md_lo ( eu_md_out_lo ),
        .o_md_hi ( eu_md_out_hi ),
        .o_md_div0 ( eu_md_div0 ),
        .i_int_valid ( eu_int_valid ),
        .i_int_op ( eu_int_op_sel ),
        .i_int_a ( eu_int_a ),
        .i_int_b ( eu_int_b ),
        .i_int_cf ( eu_int_cf ),
        .i_int_af ( eu_int_af ),
        .i_int_count ( eu_int_count ),
        .o_int_result ( eu_int_result ),
        .o_int_cf ( eu_int_cf_out ),
        .o_int_af ( eu_int_af_out ),
        .o_int_zf ( eu_int_zf_out ),
        .i_x87_valid (
            insn_fire & o_x87_is_esc & ( eu_x87_op_sel != X87_NOP ) & ~cpuid_busy & ~in_exception &
            ~o_error & ~post486_illegal
        ),
        .i_x87_op ( eu_x87_op_sel ),
        .i_x87_push_data ( eu_x87_push_data ),
        .i_x87_st_src ( o_x87_memory_operand ? 3'd0 : o_x87_rm ),
        .o_x87_st0 ( eu_x87_st0 ),
        .o_x87_st1 ( eu_x87_st1 ),
        .o_x87_zf ( eu_x87_zf ),
        .o_x87_pf ( eu_x87_pf ),
        .o_x87_cf ( eu_x87_cf )
    );

    stage_4_mem u_stage_4_mem (
        .i_stage3_valid ( stage3_valid ),
        .o_stage_valid ( stage4_valid ),
        .clk ( clock ),
        .rst ( reset ),
        .i_start ( am_lsu_start_w ),
        .i_is_store ( lsu_is_store_w ),
        .i_addr ( lsu_addr_req_w ),
        .i_wdata ( lsu_wdata_req_w ),
        .o_rdata ( am_lsu_rdata ),
        .o_done ( am_lsu_done ),
        .o_busy ( am_lsu_busy ),
        .o_mem_valid ( am_lsu_mem_valid ),
        .o_mem_we ( am_lsu_mem_we ),
        .o_mem_addr ( am_lsu_mem_addr ),
        .o_mem_wdata ( am_lsu_mem_wdata ),
        .i_mem_rdata ( data_data_read ),
        .i_mem_ready ( data_ready )
    );

    always_ff @(posedge clock or posedge reset) begin
        if ( reset )
            lsu_done_d1 <= 1'b0;
        else
            lsu_done_d1 <= am_lsu_done;
    end
    wire lsu_done_rise = am_lsu_done & ~lsu_done_d1;

    always_ff @(posedge clock or posedge reset) begin
        if ( reset )
            lsu_last_was_store_r <= 1'b0;
        else if ( am_lsu_start_w )
            lsu_last_was_store_r <= lsu_is_store_w;
    end

    always_ff @(posedge clock or posedge reset) begin
        if ( reset )
            lsu_ld_dst_reg <= 3'd0;
        else if ( am_lsu_start_w & ~lsu_is_store_w ) begin
            if (mov_ld_acc_mem_e)
                lsu_ld_dst_reg <= 3'd0;
            else
                lsu_ld_dst_reg <= modrm_reg_field;
        end
    end

    stage_3_exe u_stage_3_exe (
        .i_stage2_valid ( stage2_valid ),
        .i_cpuid_busy ( cpuid_busy ),
        .i_xadd_wait_reg_wr ( xadd_wait_reg_wr ),
        .i_am_lsu_busy ( am_lsu_busy ),
        .i_muldiv_pair_wait ( muldiv_pair_wait ),
        .o_exec_stall ( exec_stall ),
        .o_stage_valid ( stage3_valid )
    );

    // --- 异常 / 写回 ---
    logic [7:0] exception_vector;
    logic       in_exception;

    wire [2:0] cx_rm_idx  = instruction[2][2:0];
    wire [2:0] cx_r_idx   = instruction[2][5:3];
    wire [2:0] bswap_rd_n = instruction[1][2:0];
    wire [2:0] short_reg_idx = instruction[0][2:0];
    wire [31:0] eip_next_linear = EIP + { 28'h0, o_consume_bytes };
    wire [31:0] rel8_disp32 = { { 24{ o_immediate[7] } }, o_immediate[7:0] };

    logic [31:0] xadd_a;
    logic [31:0] sh_tmp;
    logic [ 4:0] sh_cnt;
    logic        sh_cf;
    logic        sh_of;
    logic [31:0] shadow_ret_stack [0:15];
    logic [ 3:0] shadow_ret_sp;

    function automatic logic parity_even8(input logic [7:0] v);
        parity_even8 = ~^v;
    endfunction

    function automatic logic msb32(input logic [31:0] v);
        msb32 = v[31];
    endfunction

    function automatic logic [31:0] write_status_flags(
        input logic [31:0] old_flags,
        input logic        cf,
        input logic        pf,
        input logic        af,
        input logic        zf,
        input logic        sf,
        input logic        of
    );
        logic [31:0] f;
        begin
            f = old_flags;
            f[0]  = cf;
            f[2]  = pf;
            f[4]  = af;
            f[6]  = zf;
            f[7]  = sf;
            f[11] = of;
            write_status_flags = f;
        end
    endfunction

    function automatic logic [31:0] flags_from_eu_result(
        input logic [31:0] old_flags,
        input logic [31:0] result,
        input logic        cf,
        input logic        af,
        input logic        of
    );
        flags_from_eu_result = write_status_flags(
            old_flags,
            cf,
            parity_even8(result[7:0]),
            af,
            (result == 32'd0),
            result[31],
            of
        );
    endfunction

    function automatic logic [31:0] flags_from_eu_result8(
        input logic [31:0] old_flags,
        input logic [31:0] result,
        input logic        cf,
        input logic        af,
        input logic        of
    );
        flags_from_eu_result8 = write_status_flags(
            old_flags,
            cf,
            parity_even8(result[7:0]),
            af,
            (result[7:0] == 8'd0),
            result[7],
            of
        );
    endfunction

    function automatic logic [31:0] flags_with_cf(
        input logic [31:0] old_flags,
        input logic        cf
    );
        logic [31:0] f;
        begin
            f = old_flags;
            f[0] = cf;
            flags_with_cf = f;
        end
    endfunction

    function automatic logic [31:0] flags_with_zf(
        input logic [31:0] old_flags,
        input logic        zf
    );
        logic [31:0] f;
        begin
            f = old_flags;
            f[6] = zf;
            flags_with_zf = f;
        end
    endfunction

    function automatic logic [31:0] flags_with_cf_af(
        input logic [31:0] old_flags,
        input logic        cf,
        input logic        af
    );
        logic [31:0] f;
        begin
            f = old_flags;
            f[0] = cf;
            f[4] = af;
            flags_with_cf_af = f;
        end
    endfunction

    function automatic logic [31:0] flags_with_cf_of(
        input logic [31:0] old_flags,
        input logic        cf,
        input logic        of
    );
        logic [31:0] f;
        begin
            f = old_flags;
            f[0] = cf;
            f[11] = of;
            flags_with_cf_of = f;
        end
    endfunction

    function automatic logic [31:0] flags_with_cf_pf_zf(
        input logic [31:0] old_flags,
        input logic        cf,
        input logic        pf,
        input logic        zf
    );
        logic [31:0] f;
        begin
            f = old_flags;
            f[0] = cf;
            f[2] = pf;
            f[6] = zf;
            flags_with_cf_pf_zf = f;
        end
    endfunction

    function automatic logic [31:0] flags_preserve_cf(
        input logic [31:0] old_flags,
        input logic [31:0] new_flags
    );
        logic [31:0] f;
        begin
            f = new_flags;
            f[0] = old_flags[0];
            flags_preserve_cf = f;
        end
    endfunction

    function automatic logic [31:0] stack_push_esp(
        input logic [31:0] esp,
        input logic [31:0] bytes
    );
        stack_push_esp = esp - bytes;
    endfunction

    function automatic logic [31:0] stack_pop_esp(
        input logic [31:0] esp,
        input logic [31:0] bytes
    );
        stack_pop_esp = esp + bytes;
    endfunction

    function automatic logic shadow_ret_has_entry(
        input logic [3:0] sp
    );
        shadow_ret_has_entry = (sp != 4'd0);
    endfunction

    function automatic logic [31:0] shadow_ret_top_or(
        input logic [3:0]  sp,
        input logic [31:0] fallback
    );
        if (sp != 4'd0)
            shadow_ret_top_or = shadow_ret_stack[sp - 4'd1];
        else
            shadow_ret_top_or = fallback;
    endfunction

    function automatic logic [15:0] shadow_ret_top16_or(
        input logic [3:0]  sp,
        input logic [15:0] fallback
    );
        if (sp != 4'd0)
            shadow_ret_top16_or = shadow_ret_stack[sp - 4'd1][15:0];
        else
            shadow_ret_top16_or = fallback;
    endfunction

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            write_enable <= 1'b0;
            IP_write_enable <= 1'b0;
            IP_write_data <= 32'h0;
            FLAGS_write_enable <= 1'b0;
            FLAGS_write_data <= 32'h0;
            SREG_write_enable <= 1'b0;
            SREG_write_index <= 3'd0;
            SREG_write_selector <= 16'd0;
            SREG_write_descriptor <= 64'd0;
            CR_write_enable <= 1'b0;
            CR_write_index <= 3'd0;
            CR_write_data <= 32'd0;
            DR_write_enable <= 1'b0;
            DR_write_index <= 3'd0;
            DR_write_data <= 32'd0;
            TR_write_enable <= 1'b0;
            TR_write_index <= 3'd0;
            TR_write_data <= 32'd0;
            exception_vector <= 8'h0;
            in_exception <= 1'b0;
            xadd_wait_reg_wr <= 1'b0;
            muldiv_pair_wait <= 1'b0;
            shadow_ret_sp <= 4'd0;
            for (int k = 0; k < 16; k++) shadow_ret_stack[k] <= 32'd0;
        end else begin
            write_enable <= 1'b0;
            IP_write_enable <= 1'b0;
            FLAGS_write_enable <= 1'b0;
            SREG_write_enable <= 1'b0;
            CR_write_enable <= 1'b0;
            DR_write_enable <= 1'b0;
            TR_write_enable <= 1'b0;

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
                write_data <= am_lsu_rdata;
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
                end else if (o_opcode_x86_WAIT_wait) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_HLT_halt) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP;
                end else if (o_opcode_x86_RSM_resume_from_system_management_mode) begin
                    exception_vector <= 8'd6;
                    in_exception <= 1'b1;
                end else if (o_opcode_x86_UD0_undefined_instruction || o_opcode_x86_UD1_undefined_instruction || o_opcode_x86_UD2_undefined_instruction) begin
                    exception_vector <= 8'd6;
                    in_exception <= 1'b1;
                end else if (o_opcode_x86_AAA_ASCII_adjust_after_add) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_cf_af(EFLAGS, eu_int_cf_out, eu_int_af_out);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_AAS_ASCII_adjust_after_sub) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_cf_af(EFLAGS, eu_int_cf_out, eu_int_af_out);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_AAD_ASCII_AX_before_div) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result8(EFLAGS, eu_int_result, EFLAGS[0], EFLAGS[4], EFLAGS[11]);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_AAM_ASCII_AX_after_mul) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result8(EFLAGS, eu_int_result, EFLAGS[0], EFLAGS[4], EFLAGS[11]);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_DAA_decimal_adjust_AL_after_add) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result8(EFLAGS, eu_int_result, eu_int_cf_out, eu_int_af_out, EFLAGS[11]);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_DAS_decimal_adjust_AL_after_sub) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result8(EFLAGS, eu_int_result, eu_int_cf_out, eu_int_af_out, EFLAGS[11]);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (
                    o_opcode_x86_CLC_clear_carry_flag ||
                    o_opcode_x86_STC_set_carry_flag ||
                    o_opcode_x86_CMC_complement_carry_flag ||
                    o_opcode_x86_CLD_clear_direction_flag ||
                    o_opcode_x86_STD_set_direction_flag ||
                    o_opcode_x86_CLI_clear_interrupt_enable_flag ||
                    o_opcode_x86_STI_set_interrupt_enable_flag
                ) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_CLTS_clear_task_switched_flag) begin
                    CR_write_enable <= 1'b1;
                    CR_write_index <= 3'd0;
                    CR_write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_LAHF_load_FLAG_into_AH) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_SAHF_store_AH_into_flags) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_CBW_convert_byte_to_word || o_opcode_x86_CWDE_convert_word_to_double) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_CWD_convert_word_to_double || o_opcode_x86_CDQ_convert_double_word_to_quad_word) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd2;
                    write_data <= eu_int_result;
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
                end else if (o_opcode_x86_JMP_to_same_segment_direct) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= br_tgt;
                end else if (o_opcode_x86_JMP_to_same_segment_indirect && modrm_is_reg) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= GPR_read_32[modrm_rm_field];
                end else if (o_opcode_x86_JMP_to_other_segment_direct) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= o_immediate;
                end else if (o_opcode_x86_JMP_to_other_segment_indirect && modrm_is_reg) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= GPR_read_32[modrm_rm_field];
                end else if (o_opcode_x86_CALL_in_same_segment_direct) begin
                    shadow_ret_stack[shadow_ret_sp] <= eip_next_linear;
                    shadow_ret_sp <= shadow_ret_sp + 4'd1;
                    write_enable <= 1'b1;
                    write_index <= 3'd4;
                    write_data <= stack_push_esp(GPR_read_32[4], 32'd4);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= br_tgt;
                end else if (o_opcode_x86_CALL_in_same_segment_indirect && modrm_is_reg) begin
                    shadow_ret_stack[shadow_ret_sp] <= eip_next_linear;
                    shadow_ret_sp <= shadow_ret_sp + 4'd1;
                    write_enable <= 1'b1;
                    write_index <= 3'd4;
                    write_data <= stack_push_esp(GPR_read_32[4], 32'd4);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= GPR_read_32[modrm_rm_field];
                end else if (o_opcode_x86_CALL_in_other_segment_direct) begin
                    shadow_ret_stack[shadow_ret_sp] <= eip_next_linear;
                    shadow_ret_sp <= shadow_ret_sp + 4'd1;
                    write_enable <= 1'b1;
                    write_index <= 3'd4;
                    write_data <= stack_push_esp(GPR_read_32[4], 32'd4);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= o_immediate;
                end else if (o_opcode_x86_CALL_in_other_segment_indirect && modrm_is_reg) begin
                    shadow_ret_stack[shadow_ret_sp] <= eip_next_linear;
                    shadow_ret_sp <= shadow_ret_sp + 4'd1;
                    write_enable <= 1'b1;
                    write_index <= 3'd4;
                    write_data <= stack_push_esp(GPR_read_32[4], 32'd4);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= GPR_read_32[modrm_rm_field];
                end else if (o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp && br_taken) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= br_tgt;
                end else if (o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp && !br_taken) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= eip_next_linear;
                end else if (o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp && br_taken) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= br_tgt;
                end else if (o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp && !br_taken) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= eip_next_linear;
                end else if (o_opcode_x86_JCXZ_jump_on_CX_zero) begin
                    IP_write_enable <= 1'b1;
                    if (eu_int_zf_out)
                        IP_write_data <= eip_next_linear + rel8_disp32;
                    else
                        IP_write_data <= eip_next_linear;
                end else if (o_opcode_x86_LOOP_count || o_opcode_x86_LOOPZ_count_while_zero || o_opcode_x86_LOOPNZ_count_while_not_zero) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd1;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    if (eu_int_zf_out)
                        IP_write_data <= eip_next_linear + rel8_disp32;
                    else
                        IP_write_data <= eip_next_linear;
                end else if (o_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument || o_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd4;
                    write_data <= stack_pop_esp(GPR_read_32[4], 32'd4);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= shadow_ret_top_or(shadow_ret_sp, eip_next_linear);
                    if (shadow_ret_has_entry(shadow_ret_sp))
                        shadow_ret_sp <= shadow_ret_sp - 4'd1;
                end else if (o_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP || o_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd4;
                    write_data <= stack_pop_esp(GPR_read_32[4], 32'd4 + o_immediate);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= shadow_ret_top_or(shadow_ret_sp, eip_next_linear);
                    if (shadow_ret_has_entry(shadow_ret_sp))
                        shadow_ret_sp <= shadow_ret_sp - 4'd1;
                end else if (o_opcode_x86_INT_interrupt_type_3) begin
                    exception_vector <= 8'd3;
                    in_exception <= 1'b1;
                end else if (o_opcode_x86_INT_interrupt_type_n) begin
                    exception_vector <= o_immediate[7:0];
                    in_exception <= 1'b1;
                end else if (o_opcode_x86_INT_interrupt_type_4) begin
                    if (OF) begin
                        exception_vector <= 8'd4;
                        in_exception <= 1'b1;
                    end else begin
                        IP_write_enable <= 1'b1;
                        IP_write_data <= eip_next_linear;
                    end
                end else if (o_opcode_x86_IRET_interrupt_return) begin
                    if (PE) begin
                        FLAGS_write_enable <= 1'b1;
                        FLAGS_write_data <= EFLAGS;
                        IP_write_enable <= 1'b1;
                        IP_write_data <= EIP;
                        in_exception <= 1'b0;
                    end else begin
                        IP_write_enable <= 1'b1;
                        IP_write_data <= eip_next_linear;
                    end
                end else if (o_opcode_x86_LEAVE_high_level_procedure_exit) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd4;
                    write_data <= GPR_read_32[5];
                    IP_write_enable <= 1'b1;
                    IP_write_data <= eip_next_linear;
                end else if (o_opcode_x86_PUSH_reg || o_opcode_x86_PUSH_imm || o_opcode_x86_PUSH_sreg_2 || o_opcode_x86_PUSH_sreg_3 || o_opcode_x86_PUSH_reg_mem || o_opcode_x86_PUSHF_push_flags_onto_stack) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd4;
                    write_data <= stack_push_esp(GPR_read_32[4], 32'd4);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= eip_next_linear;
                end else if (o_opcode_x86_PUSH_all_general_registers) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd4;
                    write_data <= stack_push_esp(GPR_read_32[4], 32'd32);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= eip_next_linear;
                end else if (o_opcode_x86_POP_reg) begin
                    write_enable <= 1'b1;
                    write_index <= short_reg_idx;
                    write_data <= shadow_ret_top_or(shadow_ret_sp, 32'd0);
                    xadd_saved_reg <= 3'd4;
                    xadd_saved_val <= stack_pop_esp(GPR_read_32[4], 32'd4);
                    xadd_wait_reg_wr <= 1'b1;
                end else if (o_opcode_x86_POP_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= shadow_ret_top_or(shadow_ret_sp, 32'd0);
                    xadd_saved_reg <= 3'd4;
                    xadd_saved_val <= stack_pop_esp(GPR_read_32[4], 32'd4);
                    xadd_wait_reg_wr <= 1'b1;
                end else if (o_opcode_x86_POP_sreg_2 || o_opcode_x86_POP_sreg_3) begin
                    SREG_write_enable <= 1'b1;
                    SREG_write_index <= o_seg_reg_index;
                    SREG_write_selector <= shadow_ret_top16_or(shadow_ret_sp, segment_selector[o_seg_reg_index]);
                    SREG_write_descriptor <= descriptor_cache[o_seg_reg_index];
                    write_enable <= 1'b1;
                    write_index <= 3'd4;
                    write_data <= stack_pop_esp(GPR_read_32[4], 32'd4);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= eip_next_linear;
                end else if (o_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= shadow_ret_top_or(shadow_ret_sp, EFLAGS);
                    write_enable <= 1'b1;
                    write_index <= 3'd4;
                    write_data <= stack_pop_esp(GPR_read_32[4], 32'd4);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= eip_next_linear;
                end else if (o_opcode_x86_POPA_pop_all_general_registers) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd4;
                    write_data <= stack_pop_esp(GPR_read_32[4], 32'd32);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= eip_next_linear;
                end else if (o_opcode_x86_IN_port_fixed || o_opcode_x86_IN_port_variable) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= 32'd0;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_OUT_port_fixed || o_opcode_x86_OUT_port_variable) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_LODS_load_string_operand) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd6;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_STOS_store_string_data) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd7;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_MOVS_move_data_from_string_to_string) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd6;
                    write_data <= eu_int_result;
                    xadd_saved_reg <= 3'd7;
                    xadd_saved_val <= DF ? (GPR_read_32[7] - 32'd1) : (GPR_read_32[7] + 32'd1);
                    xadd_wait_reg_wr <= 1'b1;
                end else if (o_opcode_x86_CMPS_compare_string_operands) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd6;
                    write_data <= eu_int_result;
                    xadd_saved_reg <= 3'd7;
                    xadd_saved_val <= DF ? (GPR_read_32[7] - 32'd1) : (GPR_read_32[7] + 32'd1);
                    xadd_wait_reg_wr <= 1'b1;
                end else if (o_opcode_x86_SCAS_scan_string) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd7;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_INS_input_from_DX_port) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd7;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_OUTS_output_string) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd6;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_XLAT_table_look_up_translation) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= { GPR_read_32[0][31:8], GPR_read_32[0][7:0] };
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_x87_is_esc && (eu_x87_op_sel != X87_NOP)) begin
                    if ((eu_x87_op_sel == X87_FCOMIP) || (eu_x87_op_sel == X87_FUCOMIP)) begin
                        FLAGS_write_enable <= 1'b1;
                        FLAGS_write_data <= flags_with_cf_pf_zf(EFLAGS, eu_x87_cf, eu_x87_pf, eu_x87_zf);
                    end
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
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
                end else if ( o_opcode_x86_IMUL_reg_with_reg_mem && modrm2_is_reg ) begin
                    write_enable <= 1'b1;
                    write_index <= cx_r_idx;
                    write_data <= eu_md_out_lo;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_IMUL_reg_mem_with_imm_to_reg && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_reg_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_cf_of(EFLAGS, eu_int_cf_out, eu_int_cf_out);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_MOV_imm_to_reg) begin
                    write_enable <= 1'b1;
                    write_index <= short_reg_idx;
                    write_data <= o_immediate;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_MOV_imm_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= o_immediate;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_LEA_load_effective_adddress_to_reg && !modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_reg_field;
                    write_data <= eu_agu_ea;
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
                end else if (o_opcode_x86_MOV_CR_from_reg && modrm2_is_reg) begin
                    CR_write_enable <= 1'b1;
                    CR_write_index <= cx_r_idx;
                    CR_write_data <= GPR_read_32[cx_rm_idx];
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_MOV_reg_from_CR && modrm2_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= cx_rm_idx;
                    write_data <= CR[cx_r_idx];
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_MOV_DR_from_reg && modrm2_is_reg) begin
                    DR_write_enable <= 1'b1;
                    DR_write_index <= cx_r_idx;
                    DR_write_data <= GPR_read_32[cx_rm_idx];
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_MOV_reg_from_DR && modrm2_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= cx_rm_idx;
                    write_data <= DR[cx_r_idx];
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_MOV_TR_from_reg && modrm2_is_reg) begin
                    TR_write_enable <= 1'b1;
                    TR_write_index <= cx_r_idx;
                    TR_write_data <= GPR_read_32[cx_rm_idx];
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_MOV_reg_from_TR && modrm2_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= cx_rm_idx;
                    write_data <= TR[cx_r_idx];
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_MOV_reg_mem_to_sreg && modrm_is_reg) begin
                    SREG_write_enable <= 1'b1;
                    SREG_write_index <= o_seg_reg_index;
                    SREG_write_selector <= GPR_read_32[modrm_rm_field][15:0];
                    SREG_write_descriptor <= descriptor_cache[o_seg_reg_index];
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_MOV_sreg_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= { 16'd0, segment_selector[o_seg_reg_index] };
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_MOV_reg_mem_to_sreg || o_opcode_x86_MOV_sreg_to_reg_mem) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_LMSW_load_status_word && modrm2_is_reg) begin
                    CR_write_enable <= 1'b1;
                    CR_write_index <= 3'd0;
                    CR_write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_SMSW_store_machine_status_word && modrm2_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= cx_rm_idx;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_ARPL_adjust_RPL_field_of_selector && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_zf(EFLAGS, eu_int_zf_out);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_BOUND_check_array_against_bounds) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_SETcc_byte_set_on_condition && modrm2_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= cx_rm_idx;
                    write_data <= { GPR_read_32[cx_rm_idx][31:8], 7'd0, eu_int_result[0] };
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_LAR_load_access_rights_byte && modrm2_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= cx_r_idx;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_zf(EFLAGS, eu_int_zf_out);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_LSL_load_segment_limit && modrm2_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= cx_r_idx;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_zf(EFLAGS, eu_int_zf_out);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_VERR_verify_a_segment_for_reading || o_opcode_x86_VERW_verify_a_segment_for_writing) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_zf(EFLAGS, eu_int_zf_out);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_LLDT_load_local_desciptor_table_reg || o_opcode_x86_LTR_load_task_register) begin
                    TR_write_enable <= 1'b1;
                    TR_write_index <= 3'd0;
                    TR_write_data <= GPR_read_32[cx_rm_idx];
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_SLDT_store_local_desciptor_table_register || o_opcode_x86_STR_store_task_register) begin
                    write_enable <= 1'b1;
                    write_index <= cx_rm_idx;
                    write_data <= TR[0];
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_SGDT_store_global_descriptor_table_register && modrm2_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= cx_rm_idx;
                    write_data <= GDTR_base;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_SIDT_store_interrupt_desciptor_table_register && modrm2_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= cx_rm_idx;
                    write_data <= IDTR_base;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_LGDT_load_global_desciptor_table_reg || o_opcode_x86_LIDT_load_interrupt_desciptor_table_reg) begin
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_LDS_load_pointer_to_DS || o_opcode_x86_LES_load_pointer_to_ES || o_opcode_x86_LFS_load_pointer_to_FS || o_opcode_x86_LGS_load_pointer_to_GS || o_opcode_x86_LSS_load_pointer_to_SS) begin
                    if (modrm_is_reg) begin
                        write_enable <= 1'b1;
                        write_index <= modrm_reg_field;
                        write_data <= GPR_read_32[modrm_rm_field];
                        SREG_write_enable <= 1'b1;
                        if (o_opcode_x86_LDS_load_pointer_to_DS) begin
                            SREG_write_index <= `sreg_index_DS;
                            SREG_write_descriptor <= descriptor_cache[`sreg_index_DS];
                        end else if (o_opcode_x86_LES_load_pointer_to_ES) begin
                            SREG_write_index <= `sreg_index_ES;
                            SREG_write_descriptor <= descriptor_cache[`sreg_index_ES];
                        end else if (o_opcode_x86_LFS_load_pointer_to_FS) begin
                            SREG_write_index <= `sreg_index_FS;
                            SREG_write_descriptor <= descriptor_cache[`sreg_index_FS];
                        end else if (o_opcode_x86_LGS_load_pointer_to_GS) begin
                            SREG_write_index <= `sreg_index_GS;
                            SREG_write_descriptor <= descriptor_cache[`sreg_index_GS];
                        end else begin
                            SREG_write_index <= `sreg_index_SS;
                            SREG_write_descriptor <= descriptor_cache[`sreg_index_SS];
                        end
                        SREG_write_selector <= GPR_read_32[modrm_rm_field][15:0];
                    end
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_reg_field;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_reg_field;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_ADD_reg_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (~(msb32(GPR_read_32[modrm_rm_field]) ^ msb32(GPR_read_32[modrm_reg_field]))) &
                        (msb32(GPR_read_32[modrm_rm_field]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_ADD_reg_mem_to_reg && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_reg_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (~(msb32(GPR_read_32[modrm_reg_field]) ^ msb32(GPR_read_32[modrm_rm_field]))) &
                        (msb32(GPR_read_32[modrm_reg_field]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_ADD_imm_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (~(msb32(GPR_read_32[modrm_rm_field]) ^ o_immediate[31])) &
                        (msb32(GPR_read_32[modrm_rm_field]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_ADD_imm_to_acc) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (~(msb32(GPR_read_32[0]) ^ o_immediate[31])) &
                        (msb32(GPR_read_32[0]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_ADC_reg_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (~(msb32(GPR_read_32[modrm_rm_field]) ^ msb32(GPR_read_32[modrm_reg_field]))) &
                        (msb32(GPR_read_32[modrm_rm_field]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_ADC_reg_mem_to_reg && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_reg_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (~(msb32(GPR_read_32[modrm_reg_field]) ^ msb32(GPR_read_32[modrm_rm_field]))) &
                        (msb32(GPR_read_32[modrm_reg_field]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_ADC_imm_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (~(msb32(GPR_read_32[modrm_rm_field]) ^ o_immediate[31])) &
                        (msb32(GPR_read_32[modrm_rm_field]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_ADC_imm_to_acc) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (~(msb32(GPR_read_32[0]) ^ o_immediate[31])) &
                        (msb32(GPR_read_32[0]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_SUB_reg_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (msb32(GPR_read_32[modrm_rm_field]) ^ msb32(GPR_read_32[modrm_reg_field])) &
                        (msb32(GPR_read_32[modrm_rm_field]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_SUB_reg_mem_to_reg && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_reg_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (msb32(GPR_read_32[modrm_reg_field]) ^ msb32(GPR_read_32[modrm_rm_field])) &
                        (msb32(GPR_read_32[modrm_reg_field]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_SUB_imm_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (msb32(GPR_read_32[modrm_rm_field]) ^ o_immediate[31]) &
                        (msb32(GPR_read_32[modrm_rm_field]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_SUB_imm_to_acc) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (msb32(GPR_read_32[0]) ^ o_immediate[31]) &
                        (msb32(GPR_read_32[0]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_SBB_reg_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (msb32(GPR_read_32[modrm_rm_field]) ^ msb32(GPR_read_32[modrm_reg_field])) &
                        (msb32(GPR_read_32[modrm_rm_field]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_SBB_reg_mem_to_reg && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_reg_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (msb32(GPR_read_32[modrm_reg_field]) ^ msb32(GPR_read_32[modrm_rm_field])) &
                        (msb32(GPR_read_32[modrm_reg_field]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_SBB_imm_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (msb32(GPR_read_32[modrm_rm_field]) ^ o_immediate[31]) &
                        (msb32(GPR_read_32[modrm_rm_field]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_SBB_imm_to_acc) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (msb32(GPR_read_32[0]) ^ o_immediate[31]) &
                        (msb32(GPR_read_32[0]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_AND_reg_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(EFLAGS, eu_int_result, 1'b0, 1'b0, 1'b0);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_AND_reg_mem_to_reg && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_reg_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(EFLAGS, eu_int_result, 1'b0, 1'b0, 1'b0);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_AND_imm_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(EFLAGS, eu_int_result, 1'b0, 1'b0, 1'b0);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_AND_imm_to_acc) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(EFLAGS, eu_int_result, 1'b0, 1'b0, 1'b0);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_OR_reg_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(EFLAGS, eu_int_result, 1'b0, 1'b0, 1'b0);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_OR_reg_mem_to_reg && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_reg_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(EFLAGS, eu_int_result, 1'b0, 1'b0, 1'b0);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_OR_imm_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(EFLAGS, eu_int_result, 1'b0, 1'b0, 1'b0);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_OR_imm_to_acc) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(EFLAGS, eu_int_result, 1'b0, 1'b0, 1'b0);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_XOR_reg_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(EFLAGS, eu_int_result, 1'b0, 1'b0, 1'b0);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_XOR_reg_mem_to_reg && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_reg_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(EFLAGS, eu_int_result, 1'b0, 1'b0, 1'b0);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_XOR_imm_to_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(EFLAGS, eu_int_result, 1'b0, 1'b0, 1'b0);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_XOR_imm_to_acc) begin
                    write_enable <= 1'b1;
                    write_index <= 3'd0;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(EFLAGS, eu_int_result, 1'b0, 1'b0, 1'b0);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_CMP_mem_with_reg && modrm_is_reg) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (msb32(GPR_read_32[modrm_rm_field]) ^ msb32(GPR_read_32[modrm_reg_field])) &
                        (msb32(GPR_read_32[modrm_rm_field]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_CMP_reg_with_mem && modrm_is_reg) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (msb32(GPR_read_32[modrm_reg_field]) ^ msb32(GPR_read_32[modrm_rm_field])) &
                        (msb32(GPR_read_32[modrm_reg_field]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_CMP_imm_with_reg_mem && modrm_is_reg) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (msb32(GPR_read_32[modrm_rm_field]) ^ o_immediate[31]) &
                        (msb32(GPR_read_32[modrm_rm_field]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_CMP_imm_with_acc) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        (msb32(GPR_read_32[0]) ^ o_immediate[31]) &
                        (msb32(GPR_read_32[0]) ^ eu_int_result[31])
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_TEST_reg_mem_and_reg && modrm_is_reg) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(EFLAGS, eu_int_result, 1'b0, 1'b0, 1'b0);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_TEST_imm_and_reg_mem && modrm_is_reg) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(EFLAGS, eu_int_result, 1'b0, 1'b0, 1'b0);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_TEST_imm_and_acc) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(EFLAGS, eu_int_result, 1'b0, 1'b0, 1'b0);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_INC_reg) begin
                    write_enable <= 1'b1;
                    write_index <= short_reg_idx;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_preserve_cf(
                        EFLAGS,
                        flags_from_eu_result(
                            EFLAGS,
                            eu_int_result,
                            eu_int_cf_out,
                            eu_int_af_out,
                            (~msb32(GPR_read_32[short_reg_idx])) & (msb32(GPR_read_32[short_reg_idx]) ^ eu_int_result[31])
                        )
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_DEC_reg) begin
                    write_enable <= 1'b1;
                    write_index <= short_reg_idx;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_preserve_cf(
                        EFLAGS,
                        flags_from_eu_result(
                            EFLAGS,
                            eu_int_result,
                            eu_int_cf_out,
                            eu_int_af_out,
                            msb32(GPR_read_32[short_reg_idx]) & (msb32(GPR_read_32[short_reg_idx]) ^ eu_int_result[31])
                        )
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_INC_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_preserve_cf(
                        EFLAGS,
                        flags_from_eu_result(
                            EFLAGS,
                            eu_int_result,
                            eu_int_cf_out,
                            eu_int_af_out,
                            (~msb32(GPR_read_32[modrm_rm_field])) & (msb32(GPR_read_32[modrm_rm_field]) ^ eu_int_result[31])
                        )
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_DEC_reg_mem && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_preserve_cf(
                        EFLAGS,
                        flags_from_eu_result(
                            EFLAGS,
                            eu_int_result,
                            eu_int_cf_out,
                            eu_int_af_out,
                            msb32(GPR_read_32[modrm_rm_field]) & (msb32(GPR_read_32[modrm_rm_field]) ^ eu_int_result[31])
                        )
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_NOT_one_s_complement_negation && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_NEG_two_s_complement_negation && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_from_eu_result(
                        EFLAGS,
                        eu_int_result,
                        eu_int_cf_out,
                        eu_int_af_out,
                        msb32(GPR_read_32[modrm_rm_field]) & eu_int_result[31]
                    );
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (
                    (
                        o_opcode_x86_ROL_reg_mem_by_1 | o_opcode_x86_ROL_reg_mem_by_CL | o_opcode_x86_ROL_reg_mem_by_imm |
                        o_opcode_x86_ROR_reg_mem_by_1 | o_opcode_x86_ROR_reg_mem_by_CL | o_opcode_x86_ROR_reg_mem_by_imm |
                        o_opcode_x86_RCL_reg_mem_by_1 | o_opcode_x86_RCL_reg_mem_by_CL | o_opcode_x86_RCL_reg_mem_by_imm |
                        o_opcode_x86_RCR_reg_mem_by_1 | o_opcode_x86_RCR_reg_mem_by_CL | o_opcode_x86_RCR_reg_mem_by_imm |
                        o_opcode_x86_SHL_reg_mem_by_1 | o_opcode_x86_SHL_reg_mem_by_CL | o_opcode_x86_SHL_reg_mem_by_imm |
                        o_opcode_x86_SHR_reg_mem_by_1 | o_opcode_x86_SHR_reg_mem_by_CL | o_opcode_x86_SHR_reg_mem_by_imm |
                        o_opcode_x86_SAR_reg_mem_by_1 | o_opcode_x86_SAR_reg_mem_by_CL | o_opcode_x86_SAR_reg_mem_by_imm
                    ) && modrm_is_reg
                ) begin
                    if (
                        o_opcode_x86_ROL_reg_mem_by_1 | o_opcode_x86_ROR_reg_mem_by_1 | o_opcode_x86_RCL_reg_mem_by_1 |
                        o_opcode_x86_RCR_reg_mem_by_1 | o_opcode_x86_SHL_reg_mem_by_1 | o_opcode_x86_SHR_reg_mem_by_1 |
                        o_opcode_x86_SAR_reg_mem_by_1
                    )
                        sh_cnt = 5'd1;
                    else if (
                        o_opcode_x86_ROL_reg_mem_by_CL | o_opcode_x86_ROR_reg_mem_by_CL | o_opcode_x86_RCL_reg_mem_by_CL |
                        o_opcode_x86_RCR_reg_mem_by_CL | o_opcode_x86_SHL_reg_mem_by_CL | o_opcode_x86_SHR_reg_mem_by_CL |
                        o_opcode_x86_SAR_reg_mem_by_CL
                    )
                        sh_cnt = GPR_read_32[1][4:0];
                    else
                        sh_cnt = o_immediate[4:0];

                    sh_tmp = eu_int_result;

                    if (sh_cnt != 5'd0) begin
                        if (o_opcode_x86_ROL_reg_mem_by_1 | o_opcode_x86_ROL_reg_mem_by_CL | o_opcode_x86_ROL_reg_mem_by_imm) begin
                            sh_cf = eu_int_cf_out;
                            sh_of = (sh_cnt == 5'd1) ? (sh_tmp[31] ^ sh_cf) : EFLAGS[11];
                            FLAGS_write_enable <= 1'b1;
                            FLAGS_write_data <= flags_with_cf_of(EFLAGS, sh_cf, sh_of);
                        end else if (o_opcode_x86_ROR_reg_mem_by_1 | o_opcode_x86_ROR_reg_mem_by_CL | o_opcode_x86_ROR_reg_mem_by_imm) begin
                            sh_cf = eu_int_cf_out;
                            sh_of = (sh_cnt == 5'd1) ? (sh_tmp[31] ^ sh_tmp[30]) : EFLAGS[11];
                            FLAGS_write_enable <= 1'b1;
                            FLAGS_write_data <= flags_with_cf_of(EFLAGS, sh_cf, sh_of);
                        end else if (o_opcode_x86_RCL_reg_mem_by_1 | o_opcode_x86_RCL_reg_mem_by_CL | o_opcode_x86_RCL_reg_mem_by_imm) begin
                            sh_cf = eu_int_cf_out;
                            sh_of = (sh_cnt == 5'd1) ? (sh_tmp[31] ^ sh_cf) : EFLAGS[11];
                            FLAGS_write_enable <= 1'b1;
                            FLAGS_write_data <= flags_with_cf_of(EFLAGS, sh_cf, sh_of);
                        end else if (o_opcode_x86_RCR_reg_mem_by_1 | o_opcode_x86_RCR_reg_mem_by_CL | o_opcode_x86_RCR_reg_mem_by_imm) begin
                            sh_cf = eu_int_cf_out;
                            sh_of = (sh_cnt == 5'd1) ? (sh_tmp[31] ^ sh_tmp[30]) : EFLAGS[11];
                            FLAGS_write_enable <= 1'b1;
                            FLAGS_write_data <= flags_with_cf_of(EFLAGS, sh_cf, sh_of);
                        end else if (o_opcode_x86_SHL_reg_mem_by_1 | o_opcode_x86_SHL_reg_mem_by_CL | o_opcode_x86_SHL_reg_mem_by_imm) begin
                            sh_cf = eu_int_cf_out;
                            sh_of = (sh_cnt == 5'd1) ? (sh_tmp[31] ^ sh_cf) : EFLAGS[11];
                            FLAGS_write_enable <= 1'b1;
                            FLAGS_write_data <= flags_from_eu_result(EFLAGS, sh_tmp, sh_cf, EFLAGS[4], sh_of);
                        end else if (o_opcode_x86_SHR_reg_mem_by_1 | o_opcode_x86_SHR_reg_mem_by_CL | o_opcode_x86_SHR_reg_mem_by_imm) begin
                            sh_cf = eu_int_cf_out;
                            sh_of = (sh_cnt == 5'd1) ? msb32(GPR_read_32[modrm_rm_field]) : EFLAGS[11];
                            FLAGS_write_enable <= 1'b1;
                            FLAGS_write_data <= flags_from_eu_result(EFLAGS, sh_tmp, sh_cf, EFLAGS[4], sh_of);
                        end else begin
                            sh_cf = eu_int_cf_out;
                            sh_of = (sh_cnt == 5'd1) ? 1'b0 : EFLAGS[11];
                            FLAGS_write_enable <= 1'b1;
                            FLAGS_write_data <= flags_from_eu_result(EFLAGS, sh_tmp, sh_cf, EFLAGS[4], sh_of);
                        end

                        write_enable <= 1'b1;
                        write_index <= modrm_rm_field;
                        write_data <= eu_int_result;
                    end

                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if ((o_opcode_x86_SHLD_reg_mem_by_imm | o_opcode_x86_SHLD_reg_mem_by_CL) && modrm2_is_reg) begin
                    if (o_opcode_x86_SHLD_reg_mem_by_CL)
                        sh_cnt = GPR_read_32[1][4:0];
                    else
                        sh_cnt = o_immediate[4:0];

                    if (sh_cnt != 5'd0) begin
                        sh_cf = eu_int_cf_out;
                        sh_tmp = eu_int_result;
                        sh_of = (sh_cnt == 5'd1) ? (sh_tmp[31] ^ sh_cf) : EFLAGS[11];

                        write_enable <= 1'b1;
                        write_index <= modrm2_rm_field;
                        write_data <= eu_int_result;
                        FLAGS_write_enable <= 1'b1;
                        FLAGS_write_data <= flags_from_eu_result(EFLAGS, sh_tmp, sh_cf, EFLAGS[4], sh_of);
                    end

                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if ((o_opcode_x86_SHRD_reg_mem_by_imm | o_opcode_x86_SHRD_reg_mem_by_CL) && modrm2_is_reg) begin
                    if (o_opcode_x86_SHRD_reg_mem_by_CL)
                        sh_cnt = GPR_read_32[1][4:0];
                    else
                        sh_cnt = o_immediate[4:0];

                    if (sh_cnt != 5'd0) begin
                        sh_cf = eu_int_cf_out;
                        sh_tmp = eu_int_result;
                        sh_of = (sh_cnt == 5'd1) ? (msb32(GPR_read_32[modrm2_rm_field]) ^ sh_tmp[31]) : EFLAGS[11];

                        write_enable <= 1'b1;
                        write_index <= modrm2_rm_field;
                        write_data <= eu_int_result;
                        FLAGS_write_enable <= 1'b1;
                        FLAGS_write_data <= flags_from_eu_result(EFLAGS, sh_tmp, sh_cf, EFLAGS[4], sh_of);
                    end

                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_BSF_bit_scan_forward && modrm2_is_reg) begin
                    if (eu_int_zf_out) begin
                        FLAGS_write_enable <= 1'b1;
                        FLAGS_write_data <= flags_with_zf(EFLAGS, 1'b1);
                    end else begin
                        write_enable <= 1'b1;
                        write_index <= cx_r_idx;
                        write_data <= eu_int_result;
                        FLAGS_write_enable <= 1'b1;
                        FLAGS_write_data <= flags_with_zf(EFLAGS, 1'b0);
                    end
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_BSR_bit_scan_reverse && modrm2_is_reg) begin
                    if (eu_int_zf_out) begin
                        FLAGS_write_enable <= 1'b1;
                        FLAGS_write_data <= flags_with_zf(EFLAGS, 1'b1);
                    end else begin
                        write_enable <= 1'b1;
                        write_index <= cx_r_idx;
                        write_data <= eu_int_result;
                        FLAGS_write_enable <= 1'b1;
                        FLAGS_write_data <= flags_with_zf(EFLAGS, 1'b0);
                    end
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_BT_reg_mem_with_reg && modrm2_is_reg) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_cf(EFLAGS, eu_int_cf_out);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_BT_reg_mem_with_imm && modrm2_is_reg) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_cf(EFLAGS, eu_int_cf_out);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_BTC_reg_mem_with_reg && modrm2_is_reg) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_cf(EFLAGS, eu_int_cf_out);
                    write_enable <= 1'b1;
                    write_index <= modrm2_rm_field;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_BTC_reg_mem_with_imm && modrm2_is_reg) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_cf(EFLAGS, eu_int_cf_out);
                    write_enable <= 1'b1;
                    write_index <= modrm2_rm_field;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_BTR_reg_mem_with_reg && modrm2_is_reg) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_cf(EFLAGS, eu_int_cf_out);
                    write_enable <= 1'b1;
                    write_index <= modrm2_rm_field;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_BTR_reg_mem_with_imm && modrm2_is_reg) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_cf(EFLAGS, eu_int_cf_out);
                    write_enable <= 1'b1;
                    write_index <= modrm2_rm_field;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_BTS_reg_mem_with_reg && modrm2_is_reg) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_cf(EFLAGS, eu_int_cf_out);
                    write_enable <= 1'b1;
                    write_index <= modrm2_rm_field;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_BTS_reg_mem_with_imm && modrm2_is_reg) begin
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_cf(EFLAGS, eu_int_cf_out);
                    write_enable <= 1'b1;
                    write_index <= modrm2_rm_field;
                    write_data <= eu_int_result;
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_XCHG_reg_mem_with_reg && modrm_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= modrm_rm_field;
                    write_data <= eu_int_result;
                    xadd_saved_reg <= modrm_reg_field;
                    xadd_saved_val <= eu_int_a;
                    xadd_wait_reg_wr <= 1'b1;
                end else if (o_opcode_x86_XCHG_reg_with_acc_short) begin
                    if (short_reg_idx == 3'd0) begin
                        IP_write_enable <= 1'b1;
                        IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                    end else begin
                        write_enable <= 1'b1;
                        write_index <= 3'd0;
                        write_data <= eu_int_result;
                        xadd_saved_reg <= short_reg_idx;
                        xadd_saved_val <= eu_int_a;
                        xadd_wait_reg_wr <= 1'b1;
                    end
                end else if ( mov_ld_mem_e | mov_st_mem_e | mov_ld_acc_mem_e | mov_st_acc_mem_e ) begin
                end else if (o_opcode_x86_CMPXCHG_compare_and_exchange && modrm2_is_reg) begin
                    write_enable <= 1'b1;
                    write_data <= eu_int_result;
                    if (eu_int_zf_out)
                        write_index <= cx_rm_idx;
                    else
                        write_index <= 3'd0;
                    FLAGS_write_enable <= 1'b1;
                    FLAGS_write_data <= flags_with_zf(EFLAGS, eu_int_zf_out);
                    IP_write_enable <= 1'b1;
                    IP_write_data <= EIP + { 28'h0, o_consume_bytes };
                end else if (o_opcode_x86_XADD_exchange_and_add && modrm2_is_reg) begin
                    write_enable <= 1'b1;
                    write_index <= cx_rm_idx;
                    write_data <= eu_int_result;
                    xadd_saved_reg <= cx_r_idx;
                    xadd_saved_val <= eu_int_a;
                    xadd_wait_reg_wr <= 1'b1;
                end else if (o_opcode_x86_BSWAP_byte_swap) begin
                    write_enable <= 1'b1;
                    write_index <= bswap_rd_n;
                    write_data <= eu_int_result;
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
