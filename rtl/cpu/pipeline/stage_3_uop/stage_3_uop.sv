/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: stage_3_uop wrapper for macro-instruction to micro-instruction conversion.
*/
// ============================================================================
// stage_3_uop
// ----------------------------------------------------------------------------
// Stage 3 UOP:
// - converts decoded macro-instructions to micro-operations
// - provides simplified internal instruction representation to execution stages
// - handles instruction fusion and micro-op sequencing
// ============================================================================

`include "openx86_defs.h.sv"

module stage_3_uop (
    // Stage handshake/control from stage_2_dec
    input  logic                i_stage2_valid, // 输入信号
    input  logic                i_flush, // 输入信号
    output logic                o_stage2_ready, // 输出信号
    output logic                o_stage_valid, // 输出信号

    // Decoded macro-instruction inputs from stage_2_dec (full instruction set)
    input  logic                i_opcode_aaa,
    input  logic                i_opcode_aad,
    input  logic                i_opcode_aam,
    input  logic                i_opcode_aas,
    input  logic                i_opcode_adc_reg_to_reg_mem,
    input  logic                i_opcode_adc_reg_mem_to_reg,
    input  logic                i_opcode_adc_imm_to_reg_mem,
    input  logic                i_opcode_adc_imm_to_acc,
    input  logic                i_opcode_add_reg_to_reg_mem,
    input  logic                i_opcode_add_reg_mem_to_reg,
    input  logic                i_opcode_add_imm_to_reg_mem,
    input  logic                i_opcode_add_imm_to_acc,
    input  logic                i_opcode_and_reg_to_reg_mem,
    input  logic                i_opcode_and_reg_mem_to_reg,
    input  logic                i_opcode_and_imm_to_reg_mem,
    input  logic                i_opcode_and_imm_to_acc,
    input  logic                i_opcode_arpl,
    input  logic                i_opcode_bound,
    input  logic                i_opcode_bsf,
    input  logic                i_opcode_bsr,
    input  logic                i_opcode_bswap,
    input  logic                i_opcode_bt_imm,
    input  logic                i_opcode_bt_reg,
    input  logic                i_opcode_btc_imm,
    input  logic                i_opcode_btc_reg,
    input  logic                i_opcode_btr_imm,
    input  logic                i_opcode_btr_reg,
    input  logic                i_opcode_bts_imm,
    input  logic                i_opcode_bts_reg,
    input  logic                i_opcode_call_near_direct,
    input  logic                i_opcode_call_near_indirect,
    input  logic                i_opcode_call_far_direct,
    input  logic                i_opcode_call_far_indirect,
    input  logic                i_opcode_cbw,
    input  logic                i_opcode_cdq,
    input  logic                i_opcode_clc,
    input  logic                i_opcode_cld,
    input  logic                i_opcode_cli,
    input  logic                i_opcode_clts,
    input  logic                i_opcode_cmc,
    input  logic                i_opcode_cmp_mem_reg,
    input  logic                i_opcode_cmp_reg_mem,
    input  logic                i_opcode_cmp_imm_reg_mem,
    input  logic                i_opcode_cmp_imm_acc,
    input  logic                i_opcode_cmps,
    input  logic                i_opcode_cmpxchg,
    input  logic                i_opcode_cpuid,
    input  logic                i_opcode_cwd,
    input  logic                i_opcode_cwde,
    input  logic                i_opcode_daa,
    input  logic                i_opcode_das,
    input  logic                i_opcode_dec_reg_mem,
    input  logic                i_opcode_dec_reg,
    input  logic                i_opcode_div,
    input  logic                i_opcode_hlt,
    input  logic                i_opcode_idiv,
    input  logic                i_opcode_imul_acc,
    input  logic                i_opcode_imul_reg,
    input  logic                i_opcode_imul_imm,
    input  logic                i_opcode_in_fixed,
    input  logic                i_opcode_in_var,
    input  logic                i_opcode_inc_reg_mem,
    input  logic                i_opcode_inc_reg,
    input  logic                i_opcode_ins,
    input  logic                i_opcode_int_n,
    input  logic                i_opcode_int_3,
    input  logic                i_opcode_int_4,
    input  logic                i_opcode_invd,
    input  logic                i_opcode_invlpg,
    input  logic                i_opcode_invpcid,
    input  logic                i_opcode_iret,
    input  logic                i_opcode_jcc_short,
    input  logic                i_opcode_jcc_near,
    input  logic                i_opcode_jcxz,
    input  logic                i_opcode_jmp_short,
    input  logic                i_opcode_jmp_near_direct,
    input  logic                i_opcode_jmp_near_indirect,
    input  logic                i_opcode_jmp_far_direct,
    input  logic                i_opcode_jmp_far_indirect,
    input  logic                i_opcode_lahf,
    input  logic                i_opcode_lar,
    input  logic                i_opcode_lds,
    input  logic                i_opcode_lea,
    input  logic                i_opcode_leave,
    input  logic                i_opcode_les,
    input  logic                i_opcode_lfs,
    input  logic                i_opcode_lgdt,
    input  logic                i_opcode_lgs,
    input  logic                i_opcode_lidt,
    input  logic                i_opcode_lldt,
    input  logic                i_opcode_lmsw,
    input  logic                i_opcode_lods,
    input  logic                i_opcode_loop,
    input  logic                i_opcode_loopz,
    input  logic                i_opcode_loopnz,
    input  logic                i_opcode_lsl,
    input  logic                i_opcode_lss,
    input  logic                i_opcode_ltr,
    input  logic                i_opcode_mov_reg_to_reg_mem,
    input  logic                i_opcode_mov_reg_mem_to_reg,
    input  logic                i_opcode_mov_imm_to_reg_mem,
    input  logic                i_opcode_mov_imm_to_reg,
    input  logic                i_opcode_mov_mem_to_acc,
    input  logic                i_opcode_mov_acc_to_mem,
    input  logic                i_opcode_mov_cr_from_reg,
    input  logic                i_opcode_mov_reg_from_cr,
    input  logic                i_opcode_mov_dr_from_reg,
    input  logic                i_opcode_mov_reg_from_dr,
    input  logic                i_opcode_mov_tr_from_reg,
    input  logic                i_opcode_mov_reg_from_tr,
    input  logic                i_opcode_mov_reg_mem_to_sreg,
    input  logic                i_opcode_mov_sreg_to_reg_mem,
    input  logic                i_opcode_movbe_mem_reg,
    input  logic                i_opcode_movbe_reg_mem,
    input  logic                i_opcode_movs,
    input  logic                i_opcode_movsx,
    input  logic                i_opcode_movzx,
    input  logic                i_opcode_mul,
    input  logic                i_opcode_neg,
    input  logic                i_opcode_nop,
    input  logic                i_opcode_nop_multibyte,
    input  logic                i_opcode_not,
    input  logic                i_opcode_or_reg_to_reg_mem,
    input  logic                i_opcode_or_reg_mem_to_reg,
    input  logic                i_opcode_or_imm_to_reg_mem,
    input  logic                i_opcode_or_imm_to_acc,
    input  logic                i_opcode_out_fixed,
    input  logic                i_opcode_out_var,
    input  logic                i_opcode_outs,
    input  logic                i_opcode_pop_reg_mem,
    input  logic                i_opcode_pop_reg,
    input  logic                i_opcode_pop_sreg_2,
    input  logic                i_opcode_pop_sreg_3,
    input  logic                i_opcode_popa,
    input  logic                i_opcode_popf,
    input  logic                i_opcode_push_reg_mem,
    input  logic                i_opcode_push_reg,
    input  logic                i_opcode_push_sreg_2,
    input  logic                i_opcode_push_sreg_3,
    input  logic                i_opcode_push_imm,
    input  logic                i_opcode_pusha,
    input  logic                i_opcode_pushf,
    input  logic                i_opcode_rcl_1,
    input  logic                i_opcode_rcl_cl,
    input  logic                i_opcode_rcl_imm,
    input  logic                i_opcode_rcr_1,
    input  logic                i_opcode_rcr_cl,
    input  logic                i_opcode_rcr_imm,
    input  logic                i_opcode_rdmsr,
    input  logic                i_opcode_rdpmc,
    input  logic                i_opcode_rdtsc,
    input  logic                i_opcode_rdtscp,
    input  logic                i_opcode_ret_near,
    input  logic                i_opcode_ret_near_imm,
    input  logic                i_opcode_ret_far,
    input  logic                i_opcode_ret_far_imm,
    input  logic                i_opcode_rol_1,
    input  logic                i_opcode_rol_cl,
    input  logic                i_opcode_rol_imm,
    input  logic                i_opcode_ror_1,
    input  logic                i_opcode_ror_cl,
    input  logic                i_opcode_ror_imm,
    input  logic                i_opcode_rsm,
    input  logic                i_opcode_sahf,
    input  logic                i_opcode_sar_1,
    input  logic                i_opcode_sar_cl,
    input  logic                i_opcode_sar_imm,
    input  logic                i_opcode_sbb_reg_to_reg_mem,
    input  logic                i_opcode_sbb_reg_mem_to_reg,
    input  logic                i_opcode_sbb_imm_to_reg_mem,
    input  logic                i_opcode_sbb_imm_to_acc,
    input  logic                i_opcode_scas,
    input  logic                i_opcode_setcc,
    input  logic                i_opcode_sgdt,
    input  logic                i_opcode_shl_1,
    input  logic                i_opcode_shl_cl,
    input  logic                i_opcode_shl_imm,
    input  logic                i_opcode_shld_imm,
    input  logic                i_opcode_shld_cl,
    input  logic                i_opcode_shr_1,
    input  logic                i_opcode_shr_cl,
    input  logic                i_opcode_shr_imm,
    input  logic                i_opcode_shrd_imm,
    input  logic                i_opcode_shrd_cl,
    input  logic                i_opcode_sidt,
    input  logic                i_opcode_sldt,
    input  logic                i_opcode_smsw,
    input  logic                i_opcode_stc,
    input  logic                i_opcode_std,
    input  logic                i_opcode_sti,
    input  logic                i_opcode_stos,
    input  logic                i_opcode_str,
    input  logic                i_opcode_sub_reg_to_reg_mem,
    input  logic                i_opcode_sub_reg_mem_to_reg,
    input  logic                i_opcode_sub_imm_to_reg_mem,
    input  logic                i_opcode_sub_imm_to_acc,
    input  logic                i_opcode_test_reg_mem,
    input  logic                i_opcode_test_imm_reg_mem,
    input  logic                i_opcode_test_imm_acc,
    input  logic                i_opcode_ud0,
    input  logic                i_opcode_ud1,
    input  logic                i_opcode_ud2,
    input  logic                i_opcode_verr,
    input  logic                i_opcode_verw,
    input  logic                i_opcode_wait,
    input  logic                i_opcode_wbinvd,
    input  logic                i_opcode_wrmsr,
    input  logic                i_opcode_xadd,
    input  logic                i_opcode_xchg_reg_mem,
    input  logic                i_opcode_xchg_acc,
    input  logic                i_opcode_xlat,
    input  logic                i_opcode_xor_reg_to_reg_mem,
    input  logic                i_opcode_xor_reg_mem_to_reg,
    input  logic                i_opcode_xor_imm_to_reg_mem,
    input  logic                i_opcode_xor_imm_to_acc,
    input  logic                i_opcode_x87_esc,
    input  logic [ 3: 0]        i_tttn,
    input  logic [ 2: 0]        i_eee

    input  logic [31: 0]        i_dec_displacement, // 输入信号
    input  logic [31: 0]        i_dec_immediate, // 输入信号
    input  logic                i_dec_base_reg_is_present, // 输入信号
    input  logic [ 2: 0]        i_dec_base_reg_index, // 输入信号
    input  logic                i_dec_index_reg_is_present, // 输入信号
    input  logic [ 2: 0]        i_dec_index_reg_index, // 输入信号
    input  logic [ 2: 0]        i_dec_segment_reg_index, // 输入信号
    input  logic [ 1: 0]        i_dec_sib_scale_factor, // 输入信号
    input  logic [ 1: 0]        i_dec_modrm_mod, // 输入信号

    // Micro-op outputs to stage_4_exu
    output micro_op_t           o_uop, // 输出信号

    input  logic                i_stage4_ready, // 输入信号

    input  logic                clk, // 时钟信号
    input  logic                rst_n // 复位信号
);

    // Micro-op pipeline register
    micro_op_t uop_reg;
    micro_op_t uop_next;

    // Stage valid/ready signals
    logic stage_valid;

    // Default micro-op (NOP)
    micro_op_t uop_default;
    assign uop_default = '{
        uop_opcode:      `UOP_NOP,
        uop_dest_reg:    3'b0,
        uop_src1_reg:    3'b0,
        uop_src2_reg:    3'b0,
        uop_immediate:   32'd0,
        uop_displacement: 32'd0,
        uop_has_imm:     1'b0,
        uop_has_disp:    1'b0,
        uop_mem_access:  1'b0,
        uop_is_store:    1'b0,
        uop_valid:       1'b0
    };

    // Macro-instruction to micro-op conversion logic
    always_comb begin
        uop_next = uop_default;

        if (i_stage2_valid) begin
            uop_next.uop_valid = 1'b1;

            // Data transfer instructions: MOV, MOVSX, MOVZX, XCHG, LEA
            if (i_opcode_mov_reg_to_reg_mem || i_opcode_mov_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_MOV;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_mov_imm_to_reg_mem || i_opcode_mov_imm_to_reg) begin
                uop_next.uop_opcode = `UOP_MOV;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_mov_mem_to_acc || i_opcode_mov_acc_to_mem) begin
                uop_next.uop_opcode = `UOP_MOV;
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_is_store = i_opcode_mov_acc_to_mem;
                uop_next.uop_dest_reg = 3'b0; // EAX
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_movsx) begin
                uop_next.uop_opcode = `UOP_MOVSX;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_movzx) begin
                uop_next.uop_opcode = `UOP_MOVZX;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_xchg_reg_mem || i_opcode_xchg_acc) begin
                uop_next.uop_opcode = `UOP_XCHG;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_lea) begin
                uop_next.uop_opcode = `UOP_LEA;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
            end

            // Arithmetic instructions: ADD, ADC, SUB, SBB, INC, DEC, NEG, CMP
            else if (i_opcode_add_reg_to_reg_mem || i_opcode_add_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_ADD;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_add_imm_to_reg_mem || i_opcode_add_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_ADD;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_adc_reg_to_reg_mem || i_opcode_adc_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_ADC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_adc_imm_to_reg_mem || i_opcode_adc_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_ADC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_sub_reg_to_reg_mem || i_opcode_sub_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_SUB;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_sub_imm_to_reg_mem || i_opcode_sub_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_SUB;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_sbb_reg_to_reg_mem || i_opcode_sbb_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_SBB;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_sbb_imm_to_reg_mem || i_opcode_sbb_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_SBB;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_inc_reg_mem || i_opcode_inc_reg) begin
                uop_next.uop_opcode = `UOP_INC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_dec_reg_mem || i_opcode_dec_reg) begin
                uop_next.uop_opcode = `UOP_DEC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_neg) begin
                uop_next.uop_opcode = `UOP_NEG;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_cmp_mem_reg || i_opcode_cmp_reg_mem) begin
                uop_next.uop_opcode = `UOP_CMP;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_cmp_imm_reg_mem || i_opcode_cmp_imm_acc) begin
                uop_next.uop_opcode = `UOP_CMP;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end

            // Logic instructions: AND, OR, XOR, NOT, TEST
            else if (i_opcode_and_reg_to_reg_mem || i_opcode_and_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_AND;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_and_imm_to_reg_mem || i_opcode_and_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_AND;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_or_reg_to_reg_mem || i_opcode_or_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_OR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_or_imm_to_reg_mem || i_opcode_or_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_OR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_xor_reg_to_reg_mem || i_opcode_xor_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_XOR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_xor_imm_to_reg_mem || i_opcode_xor_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_XOR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_not) begin
                uop_next.uop_opcode = `UOP_NOT;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_test_reg_mem) begin
                uop_next.uop_opcode = `UOP_TEST;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_test_imm_reg_mem || i_opcode_test_imm_acc) begin
                uop_next.uop_opcode = `UOP_TEST;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end

            // Shift instructions: SHL, SHR, SAR, ROL, ROR, RCL, RCR, SHLD, SHRD
            else if (i_opcode_shl_1 || i_opcode_shl_cl || i_opcode_shl_imm) begin
                uop_next.uop_opcode = `UOP_SHL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_shl_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_shr_1 || i_opcode_shr_cl || i_opcode_shr_imm) begin
                uop_next.uop_opcode = `UOP_SHR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_shr_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_sar_1 || i_opcode_sar_cl || i_opcode_sar_imm) begin
                uop_next.uop_opcode = `UOP_SAR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_sar_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_rol_1 || i_opcode_rol_cl || i_opcode_rol_imm) begin
                uop_next.uop_opcode = `UOP_ROL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_rol_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_ror_1 || i_opcode_ror_cl || i_opcode_ror_imm) begin
                uop_next.uop_opcode = `UOP_ROR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_ror_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_rcl_1 || i_opcode_rcl_cl || i_opcode_rcl_imm) begin
                uop_next.uop_opcode = `UOP_RCL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_rcl_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_rcr_1 || i_opcode_rcr_cl || i_opcode_rcr_imm) begin
                uop_next.uop_opcode = `UOP_RCR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_rcr_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_shld_imm || i_opcode_shld_cl) begin
                uop_next.uop_opcode = `UOP_SHLD;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_shld_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_shrd_imm || i_opcode_shrd_cl) begin
                uop_next.uop_opcode = `UOP_SHRD;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_shrd_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end

            // Multiply/Divide instructions: MUL, IMUL, DIV, IDIV
            else if (i_opcode_mul) begin
                uop_next.uop_opcode = `UOP_MUL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_imul_acc || i_opcode_imul_reg) begin
                uop_next.uop_opcode = `UOP_IMUL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_imul_imm) begin
                uop_next.uop_opcode = `UOP_IMUL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_div) begin
                uop_next.uop_opcode = `UOP_DIV;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_idiv) begin
                uop_next.uop_opcode = `UOP_IDIV;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end

            // Stack instructions: PUSH, POP
            else if (i_opcode_push_reg || i_opcode_push_reg_mem || i_opcode_push_imm) begin
                uop_next.uop_opcode = `UOP_PUSH;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = i_opcode_push_imm;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_pusha || i_opcode_pushf) begin
                uop_next.uop_opcode = `UOP_PUSH;
            end else if (i_opcode_pop_reg || i_opcode_pop_reg_mem) begin
                uop_next.uop_opcode = `UOP_POP;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_popa || i_opcode_popf) begin
                uop_next.uop_opcode = `UOP_POP;
            end

            // Control flow instructions: JMP, CALL, RET, LOOP, Jcc
            else if (i_opcode_jmp_short || i_opcode_jmp_near_direct || i_opcode_jmp_near_indirect ||
                     i_opcode_jmp_far_direct || i_opcode_jmp_far_indirect) begin
                uop_next.uop_opcode = `UOP_BRANCH;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_call_near_direct || i_opcode_call_near_indirect ||
                         i_opcode_call_far_direct || i_opcode_call_far_indirect) begin
                uop_next.uop_opcode = `UOP_CALL;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_ret_near || i_opcode_ret_near_imm ||
                         i_opcode_ret_far || i_opcode_ret_far_imm) begin
                uop_next.uop_opcode = `UOP_RET;
                uop_next.uop_has_disp = (i_opcode_ret_near_imm || i_opcode_ret_far_imm);
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_loop || i_opcode_loopz || i_opcode_loopnz || i_opcode_jcxz) begin
                uop_next.uop_opcode = `UOP_BRANCH;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_jcc_short || i_opcode_jcc_near) begin
                uop_next.uop_opcode = `UOP_BRANCH;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_dec_displacement;
            end

            // String instructions: MOVS, CMPS, SCAS, LODS, STOS, INS, OUTS
            else if (i_opcode_movs || i_opcode_cmps || i_opcode_scas ||
                     i_opcode_lods || i_opcode_stos || i_opcode_ins || i_opcode_outs) begin
                uop_next.uop_opcode = `UOP_STRING;
            end

            // Bit manipulation instructions: BT, BTS, BTR, BTC, BSF, BSR
            else if (i_opcode_bt_imm || i_opcode_bt_reg) begin
                uop_next.uop_opcode = `UOP_BT;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = i_opcode_bt_imm;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_bts_imm || i_opcode_bts_reg) begin
                uop_next.uop_opcode = `UOP_BTS;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = i_opcode_bts_imm;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_btr_imm || i_opcode_btr_reg) begin
                uop_next.uop_opcode = `UOP_BTR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = i_opcode_btr_imm;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_btc_imm || i_opcode_btc_reg) begin
                uop_next.uop_opcode = `UOP_BTC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = i_opcode_btc_imm;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_bsf) begin
                uop_next.uop_opcode = `UOP_BSF;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_bsr) begin
                uop_next.uop_opcode = `UOP_BSR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end

            // Flag control instructions: CLC, STC, CMC, CLD, STD, CLI, STI, LAHF, SAHF
            else if (i_opcode_clc || i_opcode_stc || i_opcode_cmc ||
                     i_opcode_cld || i_opcode_std || i_opcode_cli || i_opcode_sti ||
                     i_opcode_lahf || i_opcode_sahf) begin
                uop_next.uop_opcode = `UOP_FLAG_CTRL;
            end

            // Other instructions: NOP, BSWAP, XADD, CMPXCHG, SETcc, XLAT, CBW, CWDE, CDQ
            else if (i_opcode_nop || i_opcode_nop_multibyte) begin
                uop_next.uop_opcode = `UOP_NOP;
            end else if (i_opcode_bswap) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_xadd) begin
                uop_next.uop_opcode = `UOP_XADD;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_cmpxchg) begin
                uop_next.uop_opcode = `UOP_CMPXCHG;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_setcc) begin
                uop_next.uop_opcode = `UOP_SETCC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_xlat) begin
                uop_next.uop_opcode = `UOP_MISC;
            end else if (i_opcode_cbw || i_opcode_cwde || i_opcode_cdq) begin
                uop_next.uop_opcode = `UOP_MISC;
            end

            // x87 instructions
            else if (i_opcode_x87_esc) begin
                uop_next.uop_opcode = `UOP_X87;
            end

            // CPUID
            else if (i_opcode_cpuid) begin
                uop_next.uop_opcode = `UOP_NOP; // CPUID handled separately
            end

            // Other special instructions (AAA, AAD, AAM, AAS, DAA, DAS, etc.)
            else if (i_opcode_aaa || i_opcode_aad || i_opcode_aam || i_opcode_aas ||
                     i_opcode_daa || i_opcode_das) begin
                uop_next.uop_opcode = `UOP_MISC;
            end

            // System instructions (HLT, INT, IRET, etc.)
            else if (i_opcode_hlt || i_opcode_int_n || i_opcode_int_3 || i_opcode_int_4 ||
                     i_opcode_iret || i_opcode_invd || i_opcode_invlpg || i_opcode_invpcid ||
                     i_opcode_rdmsr || i_opcode_wrmsr || i_opcode_rdtsc || i_opcode_rdtscp ||
                     i_opcode_rdpmc || i_opcode_rsm || i_opcode_wbinvd || i_opcode_wait) begin
                uop_next.uop_opcode = `UOP_MISC;
            end

            // Segment/Privilege instructions (ARPL, BOUND, LAR, LSL, VERR, VERW, etc.)
            else if (i_opcode_arpl || i_opcode_bound || i_opcode_lar || i_opcode_lsl ||
                     i_opcode_verr || i_opcode_verw || i_opcode_sgdt || i_opcode_sidt ||
                     i_opcode_lgdt || i_opcode_lidt || i_opcode_lldt || i_opcode_lmsw ||
                     i_opcode_smsw || i_opcode_ltr || i_opcode_str || i_opcode_clts ||
                     i_opcode_lds || i_opcode_les || i_opcode_lfs || i_opcode_lgs ||
                     i_opcode_lss || i_opcode_leave) begin
                uop_next.uop_opcode = `UOP_MISC;
            end

            // I/O instructions (IN, OUT)
            else if (i_opcode_in_fixed || i_opcode_in_var || i_opcode_out_fixed || i_opcode_out_var) begin
                uop_next.uop_opcode = `UOP_MISC;
            end

            // Undefined instructions
            else if (i_opcode_ud0 || i_opcode_ud1 || i_opcode_ud2) begin
                uop_next.uop_opcode = `UOP_NOP; // Trigger exception
            end
        end
    end

    // Pipeline register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uop_reg <= uop_default;
            stage_valid <= 1'b0;
        end else if (i_flush) begin
            uop_reg <= uop_default;
            stage_valid <= 1'b0;
        end else if (i_stage4_ready) begin
            uop_reg <= uop_next;
            stage_valid <= i_stage2_valid;
        end
    end

    // Output assignments
    assign o_uop = uop_reg;
    assign o_stage_valid = stage_valid;
    assign o_stage2_ready = i_stage4_ready;

endmodule
