/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_execute_unit.
*/
// ============================================================================
// stage_3_exe_execute_unit — AGU / Branch / MulDiv / X87 子模块聚合顶层
// 译码/微码侧通过选择信号驱动各簇；此处为直连端口便于 SoC 集成
// ============================================================================

module stage_3_exe_execute_unit (
    input logic clk,
    input logic rst,

    // --- AGU ---
    input  logic [31:0] i_agu_base,
    input  logic [31:0] i_agu_index,
    input  logic [ 1:0] i_agu_scale,
    input  logic [31:0] i_agu_disp,
    output logic [31:0] o_agu_effective_addr,

    // --- Branch ---
    input  logic        i_br_is_jcc,
    input  logic [ 3:0] i_br_jcc_nibble,
    input  logic        i_br_CF,
    input  logic        i_br_PF,
    input  logic        i_br_ZF,
    input  logic        i_br_SF,
    input  logic        i_br_OF,
    input  logic [31:0] i_br_eip,
    input  logic [31:0] i_br_rel32,
    input  logic signed [7:0] i_br_rel8,
    input  logic        i_br_use_rel8,
    output logic        o_br_taken,
    output logic [31:0] o_br_target_eip,

    // --- Mul/Div ---
    input  logic [2:0]  i_md_op,
    input  logic [31:0] i_md_lo,
    input  logic [31:0] i_md_hi,
    input  logic [31:0] i_md_src,
    output logic [31:0] o_md_lo,
    output logic [31:0] o_md_hi,
    output logic        o_md_div0,

    // --- Integer op dispatch ---
    input  logic        i_int_valid,
    input  logic [ 5:0] i_int_op,
    input  logic [31:0] i_int_a,
    input  logic [31:0] i_int_b,
    input  logic        i_int_cf,
    input  logic        i_int_af,
    input  logic [31:0] i_int_count,
    output logic [31:0] o_int_result,
    output logic        o_int_cf,
    output logic        o_int_af,
    output logic        o_int_zf,

    // --- X87 ---
    input  logic        i_x87_valid,
    input  logic [ 4:0] i_x87_op,
    input  logic [63:0] i_x87_push_data,
    input  logic [ 2:0] i_x87_st_src,
    output logic [63:0] o_x87_st0,
    output logic [63:0] o_x87_st1,
    output logic        o_x87_zf,
    output logic        o_x87_pf,
    output logic        o_x87_cf
);

    import stage_3_exe_execute_unit_pkg::*;

    stage_3_exe_address_generation_unit u_agu (
        .i_base              ( i_agu_base ),
        .i_index             ( i_agu_index ),
        .i_scale             ( i_agu_scale ),
        .i_disp              ( i_agu_disp ),
        .o_effective_address ( o_agu_effective_addr )
    );

    stage_3_exe_execute_branch_unit u_br (
        .i_is_jcc      ( i_br_is_jcc ),
        .i_jcc_nibble  ( i_br_jcc_nibble ),
        .i_CF          ( i_br_CF ),
        .i_PF          ( i_br_PF ),
        .i_ZF          ( i_br_ZF ),
        .i_SF          ( i_br_SF ),
        .i_OF          ( i_br_OF ),
        .i_eip         ( i_br_eip ),
        .i_rel32       ( i_br_rel32 ),
        .i_rel8        ( i_br_rel8 ),
        .i_use_rel8    ( i_br_use_rel8 ),
        .o_taken       ( o_br_taken ),
        .o_target_eip  ( o_br_target_eip )
    );

    stage_3_exe_execute_muldiv_unit u_md (
        .i_op   ( i_md_op ),
        .i_lo   ( i_md_lo ),
        .i_hi   ( i_md_hi ),
        .i_src  ( i_md_src ),
        .o_lo   ( o_md_lo ),
        .o_hi   ( o_md_hi ),
        .o_div0 ( o_md_div0 )
    );

    logic [31:0] int_add_res;
    logic [31:0] int_adc_res;
    logic [31:0] int_sub_res;
    logic [31:0] int_sbb_res;
    logic [31:0] int_and_res;
    logic [31:0] int_or_res;
    logic [31:0] int_xor_res;
    logic [31:0] int_not_res;
    logic [31:0] int_neg_res;
    logic [31:0] int_inc_res;
    logic [31:0] int_dec_res;
    logic [31:0] int_shl_res;
    logic [31:0] int_shr_res;
    logic [31:0] int_sar_res;
    logic [31:0] int_shld_res;
    logic [31:0] int_shrd_res;
    logic [31:0] int_rol_res;
    logic [31:0] int_ror_res;
    logic [31:0] int_rcl_res;
    logic [31:0] int_rcr_res;
    logic [31:0] int_bsf_res;
    logic [31:0] int_bsr_res;
    logic [31:0] int_bt_res;
    logic [31:0] int_bts_res;
    logic [31:0] int_btr_res;
    logic [31:0] int_btc_res;
    logic [31:0] int_bswap_res;
    logic [31:0] int_aaa_res;
    logic [31:0] int_aas_res;
    logic [31:0] int_daa_res;
    logic [31:0] int_das_res;
    logic [31:0] int_aad_res;
    logic [31:0] int_aam_res;
    logic [31:0] int_cbw_res;
    logic [31:0] int_cdq_res;
    logic [31:0] int_movsx_res;
    logic [31:0] int_movzx_res;
    logic [31:0] int_flag_status_res;
    logic [31:0] int_lahf_res;
    logic [31:0] int_sahf_res;
    logic [31:0] int_xchg_res;
    logic [31:0] int_xadd_res;
    logic [31:0] int_cmpxchg_res;
    logic [31:0] int_setcc_res;
    logic [31:0] int_arpl_res;
    logic [31:0] int_lar_res;
    logic [31:0] int_lsl_res;
    logic [31:0] int_stridx_step_res;
    logic [31:0] int_imul_imm_res;
    logic [31:0] int_clts_res;
    logic [31:0] int_lmsw_res;
    logic [31:0] int_smsw_res;
    logic [31:0] int_loop_ctrl_res;
    logic        int_cmpxchg_zf;
    logic        int_arpl_zf;
    logic        int_lar_zf;
    logic        int_lsl_zf;
    logic        int_verr_zf;
    logic        int_imul_imm_overflow;
    logic        int_loop_ctrl_taken;
    logic        int_rcl_cf;
    logic        int_rcr_cf;
    logic        int_bsf_zf;
    logic        int_bsr_zf;
    logic        int_bt_cf;
    logic        int_bts_cf;
    logic        int_btr_cf;
    logic        int_btc_cf;
    logic        int_aaa_af;
    logic        int_aaa_cf;
    logic        int_aas_af;
    logic        int_aas_cf;
    logic        int_daa_af;
    logic        int_daa_cf;
    logic        int_das_af;
    logic        int_das_cf;

    function automatic logic add_cf(
        input logic [31:0] a,
        input logic [31:0] b,
        input logic        carry_in
    );
        logic [32:0] sum;
        begin
            sum = { 1'b0, a } + { 1'b0, b } + { 32'd0, carry_in };
            add_cf = sum[32];
        end
    endfunction

    function automatic logic add_af(
        input logic [31:0] a,
        input logic [31:0] b,
        input logic        carry_in
    );
        logic [4:0] nibble_sum;
        begin
            nibble_sum = { 1'b0, a[3:0] } + { 1'b0, b[3:0] } + { 4'd0, carry_in };
            add_af = nibble_sum[4];
        end
    endfunction

    function automatic logic sub_cf(
        input logic [31:0] a,
        input logic [31:0] b,
        input logic        borrow_in
    );
        logic [32:0] diff;
        begin
            diff = { 1'b0, a } - { 1'b0, b } - { 32'd0, borrow_in };
            sub_cf = diff[32];
        end
    endfunction

    function automatic logic sub_af(
        input logic [31:0] a,
        input logic [31:0] b,
        input logic        borrow_in
    );
        logic [4:0] b_term;
        begin
            b_term = { 1'b0, b[3:0] } + { 4'd0, borrow_in };
            sub_af = ({ 1'b0, a[3:0] } < b_term);
        end
    endfunction

    stage_3_exe_ari_add u_int_add (
        .a ( i_int_a ),
        .b ( i_int_b ),
        .y ( int_add_res )
    );

    stage_3_exe_ari_adc u_int_adc (
        .a ( i_int_a ),
        .b ( i_int_b ),
        .cf ( i_int_cf ),
        .y ( int_adc_res )
    );

    stage_3_exe_ari_sub u_int_sub (
        .a ( i_int_a ),
        .b ( i_int_b ),
        .y ( int_sub_res )
    );

    stage_3_exe_ari_sbb u_int_sbb (
        .a ( i_int_a ),
        .b ( i_int_b ),
        .cf ( i_int_cf ),
        .y ( int_sbb_res )
    );

    stage_3_exe_log_and u_int_and (
        .a ( i_int_a ),
        .b ( i_int_b ),
        .y ( int_and_res )
    );

    stage_3_exe_log_or u_int_or (
        .a ( i_int_a ),
        .b ( i_int_b ),
        .y ( int_or_res )
    );

    stage_3_exe_log_xor u_int_xor (
        .a ( i_int_a ),
        .b ( i_int_b ),
        .y ( int_xor_res )
    );

    stage_3_exe_log_not u_int_not (
        .a ( i_int_a ),
        .y ( int_not_res )
    );

    stage_3_exe_ari_neg u_int_neg (
        .a ( i_int_a ),
        .y ( int_neg_res )
    );

    stage_3_exe_ari_inc u_int_inc (
        .a ( i_int_a ),
        .y ( int_inc_res )
    );

    stage_3_exe_ari_dec u_int_dec (
        .a ( i_int_a ),
        .y ( int_dec_res )
    );

    stage_3_exe_shf_shl u_int_shl (
        .a ( i_int_a ),
        .count ( i_int_count ),
        .y ( int_shl_res )
    );

    stage_3_exe_shf_shr u_int_shr (
        .a ( i_int_a ),
        .count ( i_int_count ),
        .y ( int_shr_res )
    );

    stage_3_exe_shf_sar u_int_sar (
        .a ( i_int_a ),
        .count ( i_int_count ),
        .y ( int_sar_res )
    );

    stage_3_exe_shf_shld u_int_shld (
        .a ( i_int_a ),
        .b ( i_int_b ),
        .count ( i_int_count ),
        .y ( int_shld_res )
    );

    stage_3_exe_shf_shrd u_int_shrd (
        .a ( i_int_a ),
        .b ( i_int_b ),
        .count ( i_int_count ),
        .y ( int_shrd_res )
    );

    stage_3_exe_rot_rol u_int_rol (
        .a ( i_int_a ),
        .count ( i_int_count ),
        .y ( int_rol_res )
    );

    stage_3_exe_rot_ror u_int_ror (
        .a ( i_int_a ),
        .count ( i_int_count ),
        .y ( int_ror_res )
    );

    stage_3_exe_rot_rcl u_int_rcl (
        .a ( i_int_a ),
        .count ( i_int_count ),
        .cf_in ( i_int_cf ),
        .y ( int_rcl_res ),
        .cf_out ( int_rcl_cf )
    );

    stage_3_exe_rot_rcr u_int_rcr (
        .a ( i_int_a ),
        .count ( i_int_count ),
        .cf_in ( i_int_cf ),
        .y ( int_rcr_res ),
        .cf_out ( int_rcr_cf )
    );

    stage_3_exe_bit_bsf u_int_bsf (
        .a ( i_int_a ),
        .y ( int_bsf_res ),
        .zf ( int_bsf_zf )
    );

    stage_3_exe_bit_bsr u_int_bsr (
        .a ( i_int_a ),
        .y ( int_bsr_res ),
        .zf ( int_bsr_zf )
    );

    stage_3_exe_bit_bt u_int_bt (
        .a ( i_int_a ),
        .bit_index ( i_int_b ),
        .y ( int_bt_res ),
        .cf ( int_bt_cf )
    );

    stage_3_exe_bit_bts u_int_bts (
        .a ( i_int_a ),
        .bit_index ( i_int_b ),
        .y ( int_bts_res ),
        .cf ( int_bts_cf )
    );

    stage_3_exe_bit_btr u_int_btr (
        .a ( i_int_a ),
        .bit_index ( i_int_b ),
        .y ( int_btr_res ),
        .cf ( int_btr_cf )
    );

    stage_3_exe_bit_btc u_int_btc (
        .a ( i_int_a ),
        .bit_index ( i_int_b ),
        .y ( int_btc_res ),
        .cf ( int_btc_cf )
    );

    stage_3_exe_misc_bswap u_int_bswap (
        .a ( i_int_a ),
        .y ( int_bswap_res )
    );

    stage_3_exe_misc_aaa u_int_aaa (
        .a ( i_int_a ),
        .af_in ( i_int_af ),
        .y ( int_aaa_res ),
        .af_out ( int_aaa_af ),
        .cf_out ( int_aaa_cf )
    );

    stage_3_exe_misc_aas u_int_aas (
        .a ( i_int_a ),
        .af_in ( i_int_af ),
        .y ( int_aas_res ),
        .af_out ( int_aas_af ),
        .cf_out ( int_aas_cf )
    );

    stage_3_exe_misc_daa u_int_daa (
        .a ( i_int_a ),
        .af_in ( i_int_af ),
        .cf_in ( i_int_cf ),
        .y ( int_daa_res ),
        .af_out ( int_daa_af ),
        .cf_out ( int_daa_cf )
    );

    stage_3_exe_misc_das u_int_das (
        .a ( i_int_a ),
        .af_in ( i_int_af ),
        .cf_in ( i_int_cf ),
        .y ( int_das_res ),
        .af_out ( int_das_af ),
        .cf_out ( int_das_cf )
    );

    stage_3_exe_misc_aad u_int_aad (
        .a ( i_int_a ),
        .y ( int_aad_res )
    );

    stage_3_exe_misc_aam u_int_aam (
        .a ( i_int_a ),
        .b ( i_int_b ),
        .y ( int_aam_res )
    );

    stage_3_exe_misc_cbw u_int_cbw (
        .a ( i_int_a ),
        .y ( int_cbw_res )
    );

    stage_3_exe_misc_cdq u_int_cdq (
        .a ( i_int_a ),
        .y ( int_cdq_res )
    );

    stage_3_exe_misc_movsx u_int_movsx (
        .a ( i_int_a ),
        .width ( i_int_count[1:0] ),
        .y ( int_movsx_res )
    );

    stage_3_exe_misc_movzx u_int_movzx (
        .a ( i_int_a ),
        .width ( i_int_count[1:0] ),
        .y ( int_movzx_res )
    );

    stage_3_exe_misc_lahf u_int_lahf (
        .eax_in ( i_int_a ),
        .flags_in ( i_int_b ),
        .eax_out ( int_lahf_res )
    );

    stage_3_exe_misc_sahf u_int_sahf (
        .flags_in ( i_int_a ),
        .eax_in ( i_int_b ),
        .flags_out ( int_sahf_res )
    );

    stage_3_exe_misc_xchg u_int_xchg (
        .a ( i_int_a ),
        .b ( i_int_b ),
        .y ( int_xchg_res )
    );

    stage_3_exe_misc_xadd u_int_xadd (
        .a ( i_int_a ),
        .b ( i_int_b ),
        .y ( int_xadd_res )
    );

    stage_3_exe_misc_cmpxchg u_int_cmpxchg (
        .acc ( i_int_a ),
        .dst ( i_int_b ),
        .src ( i_int_count ),
        .y ( int_cmpxchg_res ),
        .zf ( int_cmpxchg_zf )
    );

    stage_3_exe_misc_setcc u_int_setcc (
        .flags ( i_int_a ),
        .tttn ( i_int_count[3:0] ),
        .y ( int_setcc_res )
    );

    stage_3_exe_misc_arpl u_int_arpl (
        .dst ( i_int_a ),
        .src ( i_int_b ),
        .y ( int_arpl_res ),
        .zf ( int_arpl_zf )
    );

    stage_3_exe_misc_lar u_int_lar (
        .src ( i_int_a ),
        .y ( int_lar_res ),
        .zf ( int_lar_zf )
    );

    stage_3_exe_misc_lsl u_int_lsl (
        .src ( i_int_a ),
        .y ( int_lsl_res ),
        .zf ( int_lsl_zf )
    );

    stage_3_exe_misc_verr u_int_verr (
        .selector ( i_int_a ),
        .zf ( int_verr_zf )
    );

    stage_3_exe_misc_stridx_step u_int_stridx_step (
        .idx ( i_int_a ),
        .df ( i_int_count[0] ),
        .y ( int_stridx_step_res )
    );

    stage_3_exe_misc_imul_imm u_int_imul_imm (
        .a ( i_int_a ),
        .b ( i_int_b ),
        .y ( int_imul_imm_res ),
        .overflow ( int_imul_imm_overflow )
    );

    stage_3_exe_misc_clts u_int_clts (
        .cr0 ( i_int_a ),
        .y ( int_clts_res )
    );

    stage_3_exe_misc_lmsw u_int_lmsw (
        .cr0 ( i_int_a ),
        .src ( i_int_b ),
        .y ( int_lmsw_res )
    );

    stage_3_exe_misc_smsw u_int_smsw (
        .cr0 ( i_int_a ),
        .y ( int_smsw_res )
    );

    stage_3_exe_misc_loop_ctrl u_int_loop_ctrl (
        .ecx ( i_int_a ),
        .zf ( i_int_b[0] ),
        .mode ( i_int_count[1:0] ),
        .ecx_next ( int_loop_ctrl_res ),
        .taken ( int_loop_ctrl_taken )
    );

    stage_3_exe_misc_flag_status u_int_flag_status (
        .flags_in ( i_int_a ),
        .op ( i_int_op ),
        .flags_out ( int_flag_status_res )
    );

    always_comb begin
        o_int_result = 32'd0;
        o_int_cf = i_int_cf;
        o_int_af = i_int_af;
        o_int_zf = 1'b0;
        if (i_int_valid) begin
            unique case (i_int_op)
                INT_ADD: begin
                    o_int_result = int_add_res;
                    o_int_cf = add_cf(i_int_a, i_int_b, 1'b0);
                    o_int_af = add_af(i_int_a, i_int_b, 1'b0);
                end
                INT_ADC: begin
                    o_int_result = int_adc_res;
                    o_int_cf = add_cf(i_int_a, i_int_b, i_int_cf);
                    o_int_af = add_af(i_int_a, i_int_b, i_int_cf);
                end
                INT_SUB: begin
                    o_int_result = int_sub_res;
                    o_int_cf = sub_cf(i_int_a, i_int_b, 1'b0);
                    o_int_af = sub_af(i_int_a, i_int_b, 1'b0);
                end
                INT_SBB: begin
                    o_int_result = int_sbb_res;
                    o_int_cf = sub_cf(i_int_a, i_int_b, i_int_cf);
                    o_int_af = sub_af(i_int_a, i_int_b, i_int_cf);
                end
                INT_AND: begin
                    o_int_result = int_and_res;
                    o_int_cf = 1'b0;
                    o_int_af = 1'b0;
                end
                INT_OR:  begin
                    o_int_result = int_or_res;
                    o_int_cf = 1'b0;
                    o_int_af = 1'b0;
                end
                INT_XOR: begin
                    o_int_result = int_xor_res;
                    o_int_cf = 1'b0;
                    o_int_af = 1'b0;
                end
                INT_NOT: o_int_result = int_not_res;
                INT_NEG: begin
                    o_int_result = int_neg_res;
                    o_int_cf = (i_int_a != 32'd0);
                    o_int_af = sub_af(32'd0, i_int_a, 1'b0);
                end
                INT_INC: begin
                    o_int_result = int_inc_res;
                    o_int_af = add_af(i_int_a, 32'd1, 1'b0);
                end
                INT_DEC: begin
                    o_int_result = int_dec_res;
                    o_int_af = sub_af(i_int_a, 32'd1, 1'b0);
                end
                INT_SHL: begin
                    o_int_result = int_shl_res;
                    if (i_int_count[4:0] != 5'd0)
                        o_int_cf = i_int_a[32 - i_int_count[4:0]];
                end
                INT_SHR: begin
                    o_int_result = int_shr_res;
                    if (i_int_count[4:0] != 5'd0)
                        o_int_cf = i_int_a[i_int_count[4:0] - 5'd1];
                end
                INT_SAR: begin
                    o_int_result = int_sar_res;
                    if (i_int_count[4:0] != 5'd0)
                        o_int_cf = i_int_a[i_int_count[4:0] - 5'd1];
                end
                INT_SHLD: begin
                    o_int_result = int_shld_res;
                    if (i_int_count[4:0] != 5'd0)
                        o_int_cf = i_int_a[32 - i_int_count[4:0]];
                end
                INT_SHRD: begin
                    o_int_result = int_shrd_res;
                    if (i_int_count[4:0] != 5'd0)
                        o_int_cf = i_int_a[i_int_count[4:0] - 5'd1];
                end
                INT_ROL: begin
                    o_int_result = int_rol_res;
                    if (i_int_count[4:0] != 5'd0)
                        o_int_cf = int_rol_res[0];
                end
                INT_ROR: begin
                    o_int_result = int_ror_res;
                    if (i_int_count[4:0] != 5'd0)
                        o_int_cf = int_ror_res[31];
                end
                INT_RCL: begin
                    o_int_result = int_rcl_res;
                    o_int_cf = int_rcl_cf;
                end
                INT_RCR: begin
                    o_int_result = int_rcr_res;
                    o_int_cf = int_rcr_cf;
                end
                INT_BSF: begin
                    o_int_result = int_bsf_res;
                    o_int_zf = int_bsf_zf;
                end
                INT_BSR: begin
                    o_int_result = int_bsr_res;
                    o_int_zf = int_bsr_zf;
                end
                INT_BT: begin
                    o_int_result = int_bt_res;
                    o_int_cf = int_bt_cf;
                end
                INT_BTS: begin
                    o_int_result = int_bts_res;
                    o_int_cf = int_bts_cf;
                end
                INT_BTR: begin
                    o_int_result = int_btr_res;
                    o_int_cf = int_btr_cf;
                end
                INT_BTC: begin
                    o_int_result = int_btc_res;
                    o_int_cf = int_btc_cf;
                end
                INT_BSWAP: o_int_result = int_bswap_res;
                INT_AAA: begin
                    o_int_result = int_aaa_res;
                    o_int_cf = int_aaa_cf;
                    o_int_af = int_aaa_af;
                end
                INT_AAS: begin
                    o_int_result = int_aas_res;
                    o_int_cf = int_aas_cf;
                    o_int_af = int_aas_af;
                end
                INT_DAA: begin
                    o_int_result = int_daa_res;
                    o_int_cf = int_daa_cf;
                    o_int_af = int_daa_af;
                end
                INT_DAS: begin
                    o_int_result = int_das_res;
                    o_int_cf = int_das_cf;
                    o_int_af = int_das_af;
                end
                INT_AAD: o_int_result = int_aad_res;
                INT_AAM: o_int_result = int_aam_res;
                INT_CBW: o_int_result = int_cbw_res;
                INT_CDQ: o_int_result = int_cdq_res;
                INT_MOVSX: o_int_result = int_movsx_res;
                INT_MOVZX: o_int_result = int_movzx_res;
                INT_CLC: o_int_result = int_flag_status_res;
                INT_STC: o_int_result = int_flag_status_res;
                INT_CMC: o_int_result = int_flag_status_res;
                INT_CLD: o_int_result = int_flag_status_res;
                INT_STD: o_int_result = int_flag_status_res;
                INT_CLI: o_int_result = int_flag_status_res;
                INT_STI: o_int_result = int_flag_status_res;
                INT_LAHF: o_int_result = int_lahf_res;
                INT_SAHF: o_int_result = int_sahf_res;
                INT_XCHG: o_int_result = int_xchg_res;
                INT_XADD: o_int_result = int_xadd_res;
                INT_CMPXCHG: begin
                    o_int_result = int_cmpxchg_res;
                    o_int_zf = int_cmpxchg_zf;
                end
                INT_SETCC: o_int_result = int_setcc_res;
                INT_ARPL: begin
                    o_int_result = int_arpl_res;
                    o_int_zf = int_arpl_zf;
                end
                INT_LAR: begin
                    o_int_result = int_lar_res;
                    o_int_zf = int_lar_zf;
                end
                INT_LSL: begin
                    o_int_result = int_lsl_res;
                    o_int_zf = int_lsl_zf;
                end
                INT_VERR: begin
                    o_int_result = 32'd0;
                    o_int_zf = int_verr_zf;
                end
                INT_STRIDX_STEP: o_int_result = int_stridx_step_res;
                INT_IMUL_IMM: begin
                    o_int_result = int_imul_imm_res;
                    o_int_cf = int_imul_imm_overflow;
                end
                INT_CLTS: o_int_result = int_clts_res;
                INT_LMSW: o_int_result = int_lmsw_res;
                INT_SMSW: o_int_result = int_smsw_res;
                INT_LOOP_CTRL: begin
                    o_int_result = int_loop_ctrl_res;
                    o_int_zf = int_loop_ctrl_taken;
                end
                default: o_int_result = 32'd0;
            endcase
        end
    end

    stage_3_exe_execute_x87_fpu u_x87 (
        .clk         ( clk ),
        .rst         ( rst ),
        .i_valid     ( i_x87_valid ),
        .i_op        ( i_x87_op ),
        .i_push_data ( i_x87_push_data ),
        .i_st_src    ( i_x87_st_src ),
        .o_st0       ( o_x87_st0 ),
        .o_st1       ( o_x87_st1 ),
        .o_zf        ( o_x87_zf ),
        .o_pf        ( o_x87_pf ),
        .o_cf        ( o_x87_cf )
    );

endmodule
