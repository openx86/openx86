// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : stage_5_exu.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Execute unit — receives micro_op_t and operand data from
//                stage_4_reg, decodes uop to sub-unit control signals,
//                dispatches to ALU/branch/muldiv/FPU/AGU/LSU
// ============================================================================

`include "openx86_defs.h.sv"

module stage_5_exu (
    // =========================
    // Pipeline handshake
    // =========================
    input  logic                i_uop_valid,
    input  micro_op_t           i_uop,
    output logic                o_stage_ready,
    output logic                o_stage_valid,
    input  logic                i_wrb_ready,

    // =========================
    // Pipeline control
    // =========================
    input  logic                i_flush,

    // =========================
    // Operand data from stage_4_reg
    // =========================
    input  logic [31: 0]        i_src1_data,
    input  logic [31: 0]        i_src2_data,

    // =========================
    // GPR values (for muldiv/AGU)
    // =========================
    input  logic [31: 0]        i_gpr_edx,
    input  logic [ 7: 0][31: 0] i_gpr_by_idx,

    // =========================
    // Flags (from stage_4_reg)
    // =========================
    input  logic                i_flag_cf,
    input  logic                i_flag_pf,
    input  logic                i_flag_af,
    input  logic                i_flag_zf,
    input  logic                i_flag_sf,
    input  logic                i_flag_of,

    // =========================
    // Instruction pointer
    // =========================
    input  logic [31: 0]        i_eip,

    // =========================
    // i486 extension controls
    // =========================
    input  logic                i_op_cpuid,
    input  logic                i_op_invd,
    input  logic                i_op_wbinvd,
    input  logic                i_op_invlpg,
    input  logic [31: 0]        i_invlpg_ea,
    output logic                o_cpuid_busy,
    output logic                o_cpuid_gpr_wr,
    output logic [ 2: 0]        o_cpuid_gpr_idx,
    output logic [31: 0]        o_cpuid_gpr_wdata,
    output logic                o_cpuid_done_pulse,
    output logic                o_cache_flush_pulse,
    output logic                o_invlpg_pulse,
    output logic [31: 0]        o_invlpg_linear_addr,

    // =========================
    // Execute result outputs
    // =========================
    output logic [31: 0]        o_result,
    output logic                o_result_valid,
    output logic [ 2: 0]        o_dest_reg,

    // Branch outputs
    output logic                o_br_taken,
    output logic [31: 0]        o_br_target_eip,

    // MulDiv outputs
    output logic [31: 0]        o_md_lo,
    output logic [31: 0]        o_md_hi,
    output logic                o_md_div0,

    // AGU output
    output logic [31: 0]        o_agu_effective_addr,

    // Flag update outputs
    output logic                o_flag_cf,
    output logic                o_flag_af,
    output logic                o_flag_zf,

    // X87 FPU outputs
    output logic [63: 0]        o_x87_st0,
    output logic [63: 0]        o_x87_st1,
    output logic                o_x87_zf,
    output logic                o_x87_pf,
    output logic                o_x87_cf,

    // =========================
    // Clock and reset
    // =========================
    input  logic                clk,
    input  logic                rst_n
);

    // ============================================================
    // Internal signals — uop decode
    // ============================================================
    logic [ 5: 0] int_op;
    logic         int_valid;
    logic [ 2: 0] md_op;
    logic         md_valid;
    logic [ 4: 0] x87_op;
    logic         x87_valid;
    logic         is_branch;
    logic         is_jcc;
    logic         is_mem_access;
    logic         is_store;
    logic         is_flag_ctrl;
    logic         is_lea;
    logic         is_nop;

    // ============================================================
    // Internal signals — operand selection
    // ============================================================
    logic [31: 0] operand_a;    // dest reg value / src1
    logic [31: 0] operand_b;    // src2 reg value or immediate
    logic [31: 0] operand_count; // shift/rotate count

    // ============================================================
    // Internal signals — sub-unit results
    // ============================================================
    logic [31: 0] alu_result;
    logic         alu_cf;
    logic         alu_zf;

    logic [31: 0] branch_result;   // not used for data, placeholder
    logic         br_taken;
    logic [31: 0] br_target_eip;

    logic [31: 0] md_lo;
    logic [31: 0] md_hi;
    logic         md_div0;

    logic [31: 0] agu_ea;

    logic [63: 0] x87_st0;
    logic [63: 0] x87_st1;
    logic         x87_zf;
    logic         x87_pf;
    logic         x87_cf;

    // ============================================================
    // Stall / handshake
    // ============================================================
    logic         exec_stall;
    logic         cpuid_busy_r;
    logic         lsu_busy_r;

    // ============================================================
    // Uop decode — map uop_opcode to sub-unit control signals
    // ============================================================
    always_comb begin
        // Defaults
        int_op      = `EXE_INT_NOP;
        int_valid   = 1'b0;
        md_op       = `EXE_MD_NOP;
        md_valid    = 1'b0;
        x87_op      = `EXE_X87_NOP;
        x87_valid   = 1'b0;
        is_branch   = 1'b0;
        is_jcc      = 1'b0;
        is_mem_access = 1'b0;
        is_store    = 1'b0;
        is_flag_ctrl = 1'b0;
        is_lea      = 1'b0;
        is_nop      = 1'b0;

        if (i_uop_valid && !i_flush) begin
            unique case (i_uop.uop_opcode)
                `UOP_ADD: begin
                    int_op    = `EXE_INT_ADD;
                    int_valid = 1'b1;
                end
                `UOP_ADC: begin
                    int_op    = `EXE_INT_ADC;
                    int_valid = 1'b1;
                end
                `UOP_SUB: begin
                    int_op    = `EXE_INT_SUB;
                    int_valid = 1'b1;
                end
                `UOP_SBB: begin
                    int_op    = `EXE_INT_SBB;
                    int_valid = 1'b1;
                end
                `UOP_AND: begin
                    int_op    = `EXE_INT_AND;
                    int_valid = 1'b1;
                end
                `UOP_OR: begin
                    int_op    = `EXE_INT_OR;
                    int_valid = 1'b1;
                end
                `UOP_XOR: begin
                    int_op    = `EXE_INT_XOR;
                    int_valid = 1'b1;
                end
                `UOP_NOT: begin
                    int_op    = `EXE_INT_NOT;
                    int_valid = 1'b1;
                end
                `UOP_NEG: begin
                    int_op    = `EXE_INT_NEG;
                    int_valid = 1'b1;
                end
                `UOP_INC: begin
                    int_op    = `EXE_INT_INC;
                    int_valid = 1'b1;
                end
                `UOP_DEC: begin
                    int_op    = `EXE_INT_DEC;
                    int_valid = 1'b1;
                end
                `UOP_SHL: begin
                    int_op    = `EXE_INT_SHL;
                    int_valid = 1'b1;
                end
                `UOP_SHR: begin
                    int_op    = `EXE_INT_SHR;
                    int_valid = 1'b1;
                end
                `UOP_SAR: begin
                    int_op    = `EXE_INT_SAR;
                    int_valid = 1'b1;
                end
                `UOP_ROL: begin
                    int_op    = `EXE_INT_ROL;
                    int_valid = 1'b1;
                end
                `UOP_ROR: begin
                    int_op    = `EXE_INT_ROR;
                    int_valid = 1'b1;
                end
                `UOP_RCL: begin
                    int_op    = `EXE_INT_RCL;
                    int_valid = 1'b1;
                end
                `UOP_RCR: begin
                    int_op    = `EXE_INT_RCR;
                    int_valid = 1'b1;
                end
                `UOP_SHLD: begin
                    int_op    = `EXE_INT_SHLD;
                    int_valid = 1'b1;
                end
                `UOP_SHRD: begin
                    int_op    = `EXE_INT_SHRD;
                    int_valid = 1'b1;
                end
                `UOP_BSF: begin
                    int_op    = `EXE_INT_BSF;
                    int_valid = 1'b1;
                end
                `UOP_BSR: begin
                    int_op    = `EXE_INT_BSR;
                    int_valid = 1'b1;
                end
                `UOP_BT: begin
                    int_op    = `EXE_INT_BT;
                    int_valid = 1'b1;
                end
                `UOP_BTS: begin
                    int_op    = `EXE_INT_BTS;
                    int_valid = 1'b1;
                end
                `UOP_BTR: begin
                    int_op    = `EXE_INT_BTR;
                    int_valid = 1'b1;
                end
                `UOP_BTC: begin
                    int_op    = `EXE_INT_BTC;
                    int_valid = 1'b1;
                end
                `UOP_MOV: begin
                    int_op    = `EXE_INT_XCHG;  // MOV = pass-through src
                    int_valid = 1'b1;
                end
                `UOP_MOVSX: begin
                    int_op    = `EXE_INT_MOVSX;
                    int_valid = 1'b1;
                end
                `UOP_MOVZX: begin
                    int_op    = `EXE_INT_MOVZX;
                    int_valid = 1'b1;
                end
                `UOP_CMP: begin
                    int_op    = `EXE_INT_SUB;   // CMP = SUB without writeback
                    int_valid = 1'b1;
                end
                `UOP_TEST: begin
                    int_op    = `EXE_INT_AND;   // TEST = AND without writeback
                    int_valid = 1'b1;
                end
                `UOP_XCHG: begin
                    int_op    = `EXE_INT_XCHG;
                    int_valid = 1'b1;
                end
                `UOP_LEA: begin
                    is_lea    = 1'b1;
                end
                `UOP_BRANCH: begin
                    is_branch = 1'b1;
                    is_jcc    = (i_uop.uop_tttn != 4'b0) ? 1'b1 : 1'b0;
                end
                `UOP_CALL: begin
                    is_branch = 1'b1;
                    is_jcc    = 1'b0;
                end
                `UOP_RET: begin
                    is_branch = 1'b1;
                    is_jcc    = 1'b0;
                end
                `UOP_MUL: begin
                    md_op     = `EXE_MD_MULU32;
                    md_valid  = 1'b1;
                end
                `UOP_IMUL: begin
                    md_op     = `EXE_MD_IMUL32;
                    md_valid  = 1'b1;
                end
                `UOP_DIV: begin
                    md_op     = `EXE_MD_DIVU32;
                    md_valid  = 1'b1;
                end
                `UOP_IDIV: begin
                    md_op     = `EXE_MD_IDIV32;
                    md_valid  = 1'b1;
                end
                `UOP_PUSH,
                `UOP_POP: begin
                    is_mem_access = 1'b1;
                    is_store     = (i_uop.uop_opcode == `UOP_PUSH);
                end
                `UOP_LOAD: begin
                    is_mem_access = 1'b1;
                    is_store     = 1'b0;
                end
                `UOP_STORE: begin
                    is_mem_access = 1'b1;
                    is_store     = 1'b1;
                end
                `UOP_X87: begin
                    x87_valid = 1'b1;
                    // Map uop_eee to x87 sub-opcode
                    x87_op    = i_uop.uop_eee[2:0] == 3'b000 ? `EXE_X87_FADD :
                                i_uop.uop_eee[2:0] == 3'b001 ? `EXE_X87_FMUL :
                                i_uop.uop_eee[2:0] == 3'b010 ? `EXE_X87_FCOM :
                                i_uop.uop_eee[2:0] == 3'b011 ? `EXE_X87_FCOMP :
                                i_uop.uop_eee[2:0] == 3'b100 ? `EXE_X87_FSUB :
                                i_uop.uop_eee[2:0] == 3'b101 ? `EXE_X87_FSUBR :
                                i_uop.uop_eee[2:0] == 3'b110 ? `EXE_X87_FDIV :
                                `EXE_X87_FDIVR;
                end
                `UOP_FLAG_CTRL: begin
                    is_flag_ctrl = 1'b1;
                end
                `UOP_XADD: begin
                    int_op    = `EXE_INT_XADD;
                    int_valid = 1'b1;
                end
                `UOP_CMPXCHG: begin
                    int_op    = `EXE_INT_CMPXCHG;
                    int_valid = 1'b1;
                end
                `UOP_SETCC: begin
                    int_op    = `EXE_INT_SETCC;
                    int_valid = 1'b1;
                end
                `UOP_MISC: begin
                    int_op    = `EXE_INT_BSWAP;
                    int_valid = 1'b1;
                end
                `UOP_STRING: begin
                    is_mem_access = 1'b1;
                end
                default: begin
                    is_nop    = 1'b1;
                end
            endcase
        end
    end

    // ============================================================
    // Operand selection
    // ============================================================
    assign operand_a = i_src1_data;
    assign operand_b = i_uop.uop_has_imm ? i_uop.uop_immediate :
                       i_src2_data;
    assign operand_count = i_uop.uop_has_imm ? i_uop.uop_immediate[4:0] :
                           i_src2_data[4:0];

    // ============================================================
    // ALU — Integer arithmetic/logic/shift/bitmanip
    // ============================================================
    logic [31: 0] alu_add_y;
    logic [31: 0] alu_adc_y;
    logic [31: 0] alu_sub_y;
    logic [31: 0] alu_sbb_y;
    logic [31: 0] alu_and_y;
    logic [31: 0] alu_or_y;
    logic [31: 0] alu_xor_y;
    logic [31: 0] alu_not_y;
    logic [31: 0] alu_neg_y;
    logic [31: 0] alu_inc_y;
    logic [31: 0] alu_dec_y;
    logic [31: 0] alu_shl_y;
    logic [31: 0] alu_shr_y;
    logic [31: 0] alu_sar_y;
    logic [31: 0] alu_rol_y;
    logic [31: 0] alu_ror_y;
    logic [31: 0] alu_rcl_y;
    logic         alu_rcl_cf;
    logic [31: 0] alu_rcr_y;
    logic         alu_rcr_cf;
    logic [31: 0] alu_shld_y;
    logic [31: 0] alu_shrd_y;
    logic [31: 0] alu_bsf_y;
    logic         alu_bsf_zf;
    logic [31: 0] alu_bsr_y;
    logic         alu_bsr_zf;
    logic [31: 0] alu_bt_y;
    logic         alu_bt_cf;
    logic [31: 0] alu_bts_y;
    logic         alu_bts_cf;
    logic [31: 0] alu_btr_y;
    logic         alu_btr_cf;
    logic [31: 0] alu_btc_y;
    logic         alu_btc_cf;
    logic [31: 0] alu_xchg_y;
    logic [31: 0] alu_movsx_y;
    logic [31: 0] alu_movzx_y;
    logic [31: 0] alu_bswap_y;
    logic [31: 0] alu_xadd_y;
    logic [31: 0] alu_cmpxchg_y;
    logic         alu_cmpxchg_zf;
    logic [31: 0] alu_setcc_y;

    // Arithmetic
    alu_arithmetic_ari_add   u_ari_add   (.a (operand_a), .b (operand_b), .y (alu_add_y));
    alu_arithmetic_ari_adc   u_ari_adc   (.a (operand_a), .b (operand_b), .cf (i_flag_cf), .y (alu_adc_y));
    alu_arithmetic_ari_sub   u_ari_sub   (.a (operand_a), .b (operand_b), .y (alu_sub_y));
    alu_arithmetic_ari_sbb   u_ari_sbb   (.a (operand_a), .b (operand_b), .cf (i_flag_cf), .y (alu_sbb_y));
    alu_arithmetic_ari_inc   u_ari_inc   (.a (operand_a), .y (alu_inc_y));
    alu_arithmetic_ari_dec   u_ari_dec   (.a (operand_a), .y (alu_dec_y));
    alu_arithmetic_ari_neg   u_ari_neg   (.a (operand_a), .y (alu_neg_y));
    alu_logic_log_not   u_log_not   (.a (operand_a), .y (alu_not_y));

    // Logic
    alu_logic_log_and   u_log_and   (.a (operand_a), .b (operand_b), .y (alu_and_y));
    alu_logic_log_or    u_log_or    (.a (operand_a), .b (operand_b), .y (alu_or_y));
    alu_logic_log_xor   u_log_xor   (.a (operand_a), .b (operand_b), .y (alu_xor_y));

    // Shift/Rotate
    alu_shift_rotate_shf_shl   u_shf_shl   (.a (operand_a), .count (operand_count), .y (alu_shl_y));
    alu_shift_rotate_shf_shr   u_shf_shr   (.a (operand_a), .count (operand_count), .y (alu_shr_y));
    alu_shift_rotate_shf_sar   u_shf_sar   (.a (operand_a), .count (operand_count), .y (alu_sar_y));
    alu_shift_rotate_rot_rol   u_rot_rol   (.a (operand_a), .count (operand_count), .y (alu_rol_y));
    alu_shift_rotate_rot_ror   u_rot_ror   (.a (operand_a), .count (operand_count), .y (alu_ror_y));
    alu_shift_rotate_rot_rcl   u_rot_rcl   (.a (operand_a), .count (operand_count), .cf_in (i_flag_cf), .y (alu_rcl_y), .cf_out (alu_rcl_cf));
    alu_shift_rotate_rot_rcr   u_rot_rcr   (.a (operand_a), .count (operand_count), .cf_in (i_flag_cf), .y (alu_rcr_y), .cf_out (alu_rcr_cf));
    alu_shift_rotate_shf_shld  u_shf_shld  (.a (operand_a), .b (operand_b), .count (operand_count), .y (alu_shld_y));
    alu_shift_rotate_shf_shrd  u_shf_shrd  (.a (operand_a), .b (operand_b), .count (operand_count), .y (alu_shrd_y));

    // Bit manipulation
    alu_bitmanip_bit_bsf   u_bit_bsf   (.a (operand_a), .y (alu_bsf_y), .zf (alu_bsf_zf));
    alu_bitmanip_bit_bsr   u_bit_bsr   (.a (operand_a), .y (alu_bsr_y), .zf (alu_bsr_zf));
    alu_bitmanip_bit_bt    u_bit_bt    (.a (operand_a), .bit_index (operand_b), .y (alu_bt_y), .cf (alu_bt_cf));
    alu_bitmanip_bit_bts   u_bit_bts   (.a (operand_a), .bit_index (operand_b), .y (alu_bts_y), .cf (alu_bts_cf));
    alu_bitmanip_bit_btr   u_bit_btr   (.a (operand_a), .bit_index (operand_b), .y (alu_btr_y), .cf (alu_btr_cf));
    alu_bitmanip_bit_btc   u_bit_btc   (.a (operand_a), .bit_index (operand_b), .y (alu_btc_y), .cf (alu_btc_cf));

    // Misc
    alu_misc_misc_xchg     u_misc_xchg     (.a (operand_a), .b (operand_b), .y (alu_xchg_y));
    alu_misc_misc_movsx    u_misc_movsx    (.a (operand_a), .width (2'b10), .y (alu_movsx_y));
    alu_misc_misc_movzx    u_misc_movzx    (.a (operand_a), .width (2'b10), .y (alu_movzx_y));
    alu_misc_misc_bswap    u_misc_bswap    (.a (operand_a), .y (alu_bswap_y));
    alu_misc_misc_xadd     u_misc_xadd     (.a (operand_a), .b (operand_b), .y (alu_xadd_y));
    alu_misc_misc_cmpxchg  u_misc_cmpxchg  (.acc (operand_a), .dst (operand_a), .src (operand_b), .y (alu_cmpxchg_y), .zf (alu_cmpxchg_zf));
    alu_misc_misc_setcc    u_misc_setcc    (.flags ({21'd0, i_flag_of, 1'b0, i_flag_sf, 1'b0, i_flag_zf, 1'b0, i_flag_af, 1'b0, i_flag_pf, 1'b1, i_flag_cf}), .tttn (i_uop.uop_tttn), .y (alu_setcc_y));

    // ============================================================
    // ALU result mux — select based on int_op
    // ============================================================
    always_comb begin
        alu_result = 32'd0;
        alu_cf     = 1'b0;
        alu_zf     = 1'b0;

        unique case (int_op)
            `EXE_INT_ADD:    alu_result = alu_add_y;
            `EXE_INT_ADC:    alu_result = alu_adc_y;
            `EXE_INT_SUB:    alu_result = alu_sub_y;
            `EXE_INT_SBB:    alu_result = alu_sbb_y;
            `EXE_INT_AND:    alu_result = alu_and_y;
            `EXE_INT_OR:     alu_result = alu_or_y;
            `EXE_INT_XOR:    alu_result = alu_xor_y;
            `EXE_INT_NOT:    alu_result = alu_not_y;
            `EXE_INT_NEG:    alu_result = alu_neg_y;
            `EXE_INT_INC:    alu_result = alu_inc_y;
            `EXE_INT_DEC:    alu_result = alu_dec_y;
            `EXE_INT_SHL:    alu_result = alu_shl_y;
            `EXE_INT_SHR:    alu_result = alu_shr_y;
            `EXE_INT_SAR:    alu_result = alu_sar_y;
            `EXE_INT_ROL:    alu_result = alu_rol_y;
            `EXE_INT_ROR:    alu_result = alu_ror_y;
            `EXE_INT_RCL:  begin alu_result = alu_rcl_y; alu_cf = alu_rcl_cf; end
            `EXE_INT_RCR:  begin alu_result = alu_rcr_y; alu_cf = alu_rcr_cf; end
            `EXE_INT_SHLD:   alu_result = alu_shld_y;
            `EXE_INT_SHRD:   alu_result = alu_shrd_y;
            `EXE_INT_BSF:  begin alu_result = alu_bsf_y; alu_zf = alu_bsf_zf; end
            `EXE_INT_BSR:  begin alu_result = alu_bsr_y; alu_zf = alu_bsr_zf; end
            `EXE_INT_BT:   begin alu_result = alu_bt_y;  alu_cf = alu_bt_cf;  end
            `EXE_INT_BTS:  begin alu_result = alu_bts_y; alu_cf = alu_bts_cf; end
            `EXE_INT_BTR:  begin alu_result = alu_btr_y; alu_cf = alu_btr_cf; end
            `EXE_INT_BTC:  begin alu_result = alu_btc_y; alu_cf = alu_btc_cf; end
            `EXE_INT_XCHG:   alu_result = alu_xchg_y;
            `EXE_INT_MOVSX:  alu_result = alu_movsx_y;
            `EXE_INT_MOVZX:  alu_result = alu_movzx_y;
            `EXE_INT_BSWAP:  alu_result = alu_bswap_y;
            `EXE_INT_XADD:   alu_result = alu_xadd_y;
            `EXE_INT_CMPXCHG: begin alu_result = alu_cmpxchg_y; alu_zf = alu_cmpxchg_zf; end
            `EXE_INT_SETCC:  alu_result = alu_setcc_y;
            default:         alu_result = 32'd0;
        endcase
    end

    // ============================================================
    // Branch unit
    // ============================================================
    branch_execute_branch_unit u_branch (
        .i_is_jcc     ( is_jcc              ),
        .i_jcc_nibble ( i_uop.uop_tttn      ),
        .i_CF         ( i_flag_cf            ),
        .i_PF         ( i_flag_pf            ),
        .i_ZF         ( i_flag_zf            ),
        .i_SF         ( i_flag_sf            ),
        .i_OF         ( i_flag_of            ),
        .i_eip        ( i_eip                ),
        .i_rel32      ( i_uop.uop_displacement ),
        .i_rel8       ( i_uop.uop_displacement[7:0] ),
        .i_use_rel8   ( 1'b0                 ), // TODO: derive from instruction length
        .o_taken      ( br_taken             ),
        .o_target_eip ( br_target_eip        )
    );

    // ============================================================
    // MulDiv unit
    // ============================================================
    execute_muldiv_unit u_muldiv (
        .i_op   ( md_op                ),
        .i_lo   ( operand_a            ),
        .i_hi   ( i_gpr_edx            ), // EDX for 64-bit dividend
        .i_src  ( operand_b            ),
        .o_lo   ( md_lo                ),
        .o_hi   ( md_hi                ),
        .o_div0 ( md_div0              )
    );

    // ============================================================
    // AGU (Address Generation Unit)
    // ============================================================
    agu_lsu_address_generation_unit u_agu (
        .i_base              ( operand_a                ),
        .i_index             ( gpr_by_idx[i_uop.uop_src1_reg] ),
        .i_scale             ( i_uop.uop_sib_scale       ),
        .i_disp              ( i_uop.uop_displacement    ),
        .o_effective_address ( agu_ea                    )
    );

    // ============================================================
    // X87 FPU
    // ============================================================
    execute_x87_fpu u_x87_fpu (
        .i_valid     ( x87_valid           ),
        .i_op        ( x87_op              ),
        .i_push_data ( 64'd0               ), // TODO: from memory load
        .i_st_src    ( i_uop.uop_eee       ),
        .o_st0       ( x87_st0             ),
        .o_st1       ( x87_st1             ),
        .o_zf        ( x87_zf              ),
        .o_pf        ( x87_pf              ),
        .o_cf        ( x87_cf              ),
        .clk         ( clk                 ),
        .rst_n       ( rst_n               )
    );

    // ============================================================
    // i486 Extensions (CPUID / Cache invalidate)
    // ============================================================
    logic insn_fire;
    assign insn_fire = i_uop_valid & o_stage_ready & ~i_flush;

    i486_execute_unit u_ext (
        .insn_fire          ( insn_fire           ),
        .op_cpuid           ( i_op_cpuid          ),
        .gpr_eax            ( i_src1_data        ),
        .gpr_ecx            ( i_src2_data        ),
        .cpuid_busy         ( cpuid_busy_r        ),
        .gpr_wr_en          ( o_cpuid_gpr_wr      ),
        .gpr_wr_idx         ( o_cpuid_gpr_idx     ),
        .gpr_wr_data        ( o_cpuid_gpr_wdata   ),
        .cpuid_done_pulse   ( o_cpuid_done_pulse  ),
        .op_invd            ( i_op_invd           ),
        .op_wbinvd          ( i_op_wbinvd         ),
        .op_invlpg          ( i_op_invlpg         ),
        .invlpg_ea          ( i_invlpg_ea         ),
        .cache_flush_pulse  ( o_cache_flush_pulse ),
        .invlpg_pulse       ( o_invlpg_pulse      ),
        .invlpg_linear_addr ( o_invlpg_linear_addr ),
        .clk                ( clk                 ),
        .rst_n              ( rst_n               )
    );

    assign o_cpuid_busy = cpuid_busy_r;

    // ============================================================
    // Stall control
    // ============================================================
    always_comb begin
        lsu_busy_r   = 1'b0; // TODO: connect to LSU busy
        exec_stall   = cpuid_busy_r | lsu_busy_r;
    end

    // ============================================================
    // Output assignments — handshake
    // ============================================================
    assign o_stage_ready = ~exec_stall;
    assign o_stage_valid = i_uop_valid & ~i_flush & ~exec_stall;

    // ============================================================
    // Output assignments — result mux (select between ALU/branch/AGU/muldiv)
    // ============================================================
    always_comb begin
        o_result       = 32'd0;
        o_result_valid = 1'b0;
        o_dest_reg     = i_uop.uop_dest_reg;
        o_flag_cf      = 1'b0;
        o_flag_af      = 1'b0;
        o_flag_zf      = 1'b0;

        if (i_uop_valid && !i_flush && !exec_stall) begin
            if (int_valid) begin
                o_result       = alu_result;
                o_result_valid = 1'b1;
                o_flag_cf      = alu_cf;
                o_flag_zf      = alu_zf;
            end else if (is_branch) begin
                o_br_taken     = br_taken;
                o_br_target_eip = br_target_eip;
                o_result_valid = 1'b1;
            end else if (md_valid) begin
                o_md_lo  = md_lo;
                o_md_hi  = md_hi;
                o_md_div0 = md_div0;
                o_result = md_lo;
                o_result_valid = 1'b1;
            end else if (is_lea || is_mem_access) begin
                o_agu_effective_addr = agu_ea;
                o_result = agu_ea;
                o_result_valid = 1'b1;
            end else if (is_flag_ctrl) begin
                // Flag control: result not meaningful, valid to advance pipeline
                o_result_valid = 1'b1;
            end else if (is_nop) begin
                o_result_valid = 1'b1;
            end
        end
    end

    // X87 outputs — direct wiring
    assign o_x87_st0 = x87_st0;
    assign o_x87_st1 = x87_st1;
    assign o_x87_zf  = x87_zf;
    assign o_x87_pf  = x87_pf;
    assign o_x87_cf  = x87_cf;

endmodule
