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
//  File        : exu_dispatcher.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Execution unit dispatcher - routes uops to exu_* sub-units
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_dispatcher (
    input  logic         i_valid,
    input  logic [ 5: 0] i_uop_opcode,
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [31: 0] i_immediate,
    input  logic [31: 0] i_displacement,
    input  logic         i_cf,
    input  logic         i_has_imm,
    input  logic         i_has_disp,
    input  logic         i_mem_access,
    input  logic         i_is_store,
    input  logic         i_agu_base,
    input  logic         i_agu_index,
    input  logic [ 1: 0] i_sib_scale,
    input  logic [ 3: 0] i_tttn,
    input  logic         i_pf,
    input  logic         i_af,
    input  logic         i_zf,
    input  logic         i_sf,
    input  logic         i_of,
    input  logic [63: 0] i_dividend,
    input  logic [31: 0] i_cpuid_eax,
    output logic         o_handled,
    output exu_dispatch_out_t o_dispatch
);

    localparam int LP_NUM_ENTRIES = 48;

    exu_result_t add_r;
    exu_result_t sub_r;
    exu_result_t and_r;
    exu_result_t or_r;
    exu_result_t xor_r;
    exu_result_t adc_r;
    exu_result_t sbb_r;
    exu_result_t inc_r;
    exu_result_t dec_r;
    exu_result_t neg_r;
    exu_result_t not_r;
    exu_result_t cmp_r;
    exu_result_t test_r;
    exu_result_t shl_r;
    exu_result_t shr_r;
    exu_result_t sar_r;
    exu_result_t rol_r;
    exu_result_t ror_r;
    exu_result_t rcl_r;
    exu_result_t rcr_r;
    exu_result_t shld_r;
    exu_result_t shrd_r;
    exu_result_t mov_r;
    exu_result_t movsx_r;
    exu_result_t movzx_r;
    exu_result_t lea_r;
    exu_result_t xchg_r;
    exu_result_t call_r;
    exu_result_t ret_r;
    exu_result_t push_r;
    exu_result_t pop_r;
    exu_result_t mul_r;
    exu_result_t imul_r;
    exu_result_t div_r;
    exu_result_t idiv_r;
    exu_result_t bswap_r;
    exu_result_t cmpxchg_r;
    exu_result_t xadd_r;
    exu_result_t bt_r;
    exu_result_t bts_r;
    exu_result_t btr_r;
    exu_result_t btc_r;
    exu_result_t bsf_r;
    exu_result_t bsr_r;
    exu_result_t setcc_r;
    exu_result_t string_r;
    exu_result_t flag_ctrl_r;
    exu_result_t misc_r;

    logic [31: 0] mul_hi_r;
    logic [31: 0] imul_hi_r;
    logic [31: 0] div_hi_r;
    logic [31: 0] idiv_hi_r;

    exu_dispatch_out_t entries [0: LP_NUM_ENTRIES - 1];
    exu_dispatch_out_t mux_out;
    exu_dispatch_out_t xchg_entry;
    exu_dispatch_out_t branch_entry;
    exu_dispatch_out_t call_entry;

    logic [ 5: 0] select_idx;
    logic         reg_mov_only;
    logic         misc_simple;
    logic         condition_met;
    logic [31: 0] branch_target;
    logic [31: 0] call_target;

    assign reg_mov_only = (i_uop_opcode == `UOP_MOV) & ~i_mem_access;
    assign misc_simple  = (i_uop_opcode == `UOP_MISC) &
                          exu_opcode_is_misc_simple(i_immediate[7: 0]);
    assign branch_target = i_has_disp ? i_displacement : i_src1_data;
    assign call_target   = i_has_disp ? i_displacement : i_immediate;
    // JMP marks unconditional with has_imm && imm[0]; Jcc leaves has_imm=0.
    assign condition_met = (i_has_imm & i_immediate[0]) |
                           compute_condition(i_tttn, i_of, i_cf, i_zf, i_sf, i_pf);

    function automatic exu_dispatch_out_t pack_gpr_flags(
        input exu_result_t data
    );
        exu_dispatch_out_t out;
        out.data        = data;
        out.write_gpr   = 1'b1;
        out.write_flags = 1'b1;
        out.write_ip    = 1'b0;
        out.ip_data     = 32'd0;
        return out;
    endfunction

    function automatic exu_dispatch_out_t pack_gpr_only(
        input exu_result_t data
    );
        exu_dispatch_out_t out;
        out.data        = data;
        out.write_gpr   = 1'b1;
        out.write_flags = 1'b0;
        out.write_ip    = 1'b0;
        out.ip_data     = 32'd0;
        return out;
    endfunction

    function automatic exu_dispatch_out_t pack_flags_only(
        input exu_result_t data
    );
        exu_dispatch_out_t out;
        out.data        = data;
        out.write_gpr   = 1'b0;
        out.write_flags = 1'b1;
        out.write_ip    = 1'b0;
        out.ip_data     = 32'd0;
        return out;
    endfunction

    function automatic exu_dispatch_out_t pack_mem_gpr(
        input exu_result_t data
    );
        exu_dispatch_out_t out;
        out.data        = data;
        out.write_gpr   = 1'b1;
        out.write_flags = 1'b0;
        out.write_ip    = 1'b0;
        out.ip_data     = 32'd0;
        return out;
    endfunction

    exu_add u_add (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (add_r)
    );

    exu_sub u_sub (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (sub_r)
    );

    exu_and u_and (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (and_r)
    );

    exu_or u_or (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (or_r)
    );

    exu_xor u_xor (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (xor_r)
    );

    exu_adc u_adc (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_cf        (i_cf),
        .i_has_imm   (i_has_imm),
        .o_result    (adc_r)
    );

    exu_sbb u_sbb (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_cf        (i_cf),
        .i_has_imm   (i_has_imm),
        .o_result    (sbb_r)
    );

    exu_inc u_inc (
        .i_src1_data (i_src1_data),
        .i_cf        (i_cf),
        .o_result    (inc_r)
    );

    exu_dec u_dec (
        .i_src1_data (i_src1_data),
        .i_cf        (i_cf),
        .o_result    (dec_r)
    );

    exu_neg u_neg (
        .i_src1_data (i_src1_data),
        .o_result    (neg_r)
    );

    exu_not u_not (
        .i_src1_data (i_src1_data),
        .o_result    (not_r)
    );

    exu_cmp u_cmp (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (cmp_r)
    );

    exu_test u_test (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (test_r)
    );

    exu_shl u_shl (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (shl_r)
    );

    exu_shr u_shr (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (shr_r)
    );

    exu_sar u_sar (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (sar_r)
    );

    exu_rol u_rol (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (rol_r)
    );

    exu_ror u_ror (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (ror_r)
    );

    exu_rcl u_rcl (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .i_cf        (i_cf),
        .o_result    (rcl_r)
    );

    exu_rcr u_rcr (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .i_cf        (i_cf),
        .o_result    (rcr_r)
    );

    exu_shld u_shld (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (shld_r)
    );

    exu_shrd u_shrd (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (shrd_r)
    );

    exu_mov u_mov (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (mov_r)
    );

    exu_movsx u_movsx (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (movsx_r)
    );

    exu_movzx u_movzx (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (movzx_r)
    );

    exu_lea u_lea (
        .i_src1_data    (i_src1_data),
        .i_src2_data    (i_src2_data),
        .i_displacement (i_displacement),
        .i_agu_base     (i_agu_base),
        .i_agu_index    (i_agu_index),
        .i_sib_scale    (i_sib_scale),
        .o_result       (lea_r)
    );

    exu_xchg u_xchg (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .o_result    (xchg_r)
    );

    exu_call u_call (
        .i_src1_data    (i_src1_data),
        .i_src2_data    (i_src2_data),
        .i_immediate    (i_immediate),
        .i_displacement (i_displacement),
        .i_has_imm      (i_has_imm),
        .i_has_disp     (i_has_disp),
        .o_result       (call_r)
    );

    exu_ret u_ret (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (ret_r)
    );

    exu_push u_push (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (push_r)
    );

    exu_pop u_pop (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (pop_r)
    );

    exu_mul u_mul (
        .i_src1_data   (i_src1_data),
        .i_src2_data   (i_src2_data),
        .o_result      (mul_r),
        .o_result_high (mul_hi_r)
    );

    exu_imul u_imul (
        .i_src1_data   (i_src1_data),
        .i_src2_data   (i_src2_data),
        .o_result      (imul_r),
        .o_result_high (imul_hi_r)
    );

    exu_div u_div (
        .i_src1_data (i_src2_data),
        .i_src2_data (i_src2_data),
        .i_dividend  (i_dividend),
        .o_result    (div_r),
        .o_result_high (div_hi_r)
    );

    exu_idiv u_idiv (
        .i_src1_data (i_src2_data),
        .i_src2_data (i_src2_data),
        .i_dividend  ($signed(i_dividend)),
        .o_result    (idiv_r),
        .o_result_high (idiv_hi_r)
    );

    exu_bswap u_bswap (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (bswap_r)
    );

    exu_cmpxchg u_cmpxchg (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (cmpxchg_r)
    );

    exu_xadd u_xadd (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (xadd_r)
    );

    exu_bt u_bt (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (bt_r)
    );

    exu_bts u_bts (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (bts_r)
    );

    exu_btr u_btr (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (btr_r)
    );

    exu_btc u_btc (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (btc_r)
    );

    exu_bsf u_bsf (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (bsf_r)
    );

    exu_bsr u_bsr (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .o_result    (bsr_r)
    );

    exu_setcc u_setcc (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .i_tttn      (i_tttn),
        .i_cf        (i_cf),
        .i_pf        (i_pf),
        .i_zf        (i_zf),
        .i_sf        (i_sf),
        .i_of        (i_of),
        .o_result    (setcc_r)
    );

    exu_string u_string (
        .i_src1_data   (i_src1_data),
        .i_src2_data   (i_src2_data),
        .i_ecx         (32'd0),
        .i_is_store    (i_is_store),
        .i_df          (i_sf),
        .i_rep         (1'b0),
        .i_repne       (1'b0),
        .i_zf          (i_zf),
        .o_result      (string_r),
        .o_rep_restart ( ),
        .o_ecx_next    ( )
    );

    exu_flag_ctrl u_flag_ctrl (
        .i_cf        (i_cf),
        .i_pf        (i_pf),
        .i_af        (i_af),
        .i_zf        (i_zf),
        .i_sf        (i_sf),
        .i_of        (i_of),
        .i_immediate (i_immediate),
        .o_result    (flag_ctrl_r)
    );

    exu_misc u_misc (
        .i_src1_data (i_src1_data),
        .i_src2_data (i_src2_data),
        .i_immediate (i_immediate),
        .i_has_imm   (i_has_imm),
        .i_cpuid_eax (i_cpuid_eax),
        .o_result    (misc_r)
    );

    assign entries[ 0] = pack_gpr_flags(add_r);
    assign entries[ 1] = pack_gpr_flags(sub_r);
    assign entries[ 2] = pack_gpr_flags(and_r);
    assign entries[ 3] = pack_gpr_flags(or_r);
    assign entries[ 4] = pack_gpr_flags(xor_r);
    assign entries[ 5] = pack_gpr_flags(adc_r);
    assign entries[ 6] = pack_gpr_flags(sbb_r);
    assign entries[ 7] = pack_gpr_flags(inc_r);
    assign entries[ 8] = pack_gpr_flags(dec_r);
    assign entries[ 9] = pack_gpr_flags(neg_r);
    assign entries[10] = pack_gpr_only(not_r);
    assign entries[11] = pack_flags_only(cmp_r);
    assign entries[12] = pack_flags_only(test_r);
    assign entries[13] = pack_gpr_flags(shl_r);
    assign entries[14] = pack_gpr_flags(shr_r);
    assign entries[15] = pack_gpr_flags(sar_r);
    assign entries[16] = pack_gpr_only(rol_r);
    assign entries[17] = pack_gpr_only(ror_r);
    assign entries[18] = pack_gpr_only(rcl_r);
    assign entries[19] = pack_gpr_only(rcr_r);
    assign entries[20] = pack_gpr_flags(shld_r);
    assign entries[21] = pack_gpr_flags(shrd_r);
    assign entries[22] = pack_gpr_only(mov_r);
    assign entries[23] = pack_gpr_only(movsx_r);
    assign entries[24] = pack_gpr_only(movzx_r);
    assign entries[25] = pack_gpr_only(lea_r);
    assign entries[26] = branch_entry;
    assign entries[27] = call_entry;
    assign entries[28] = pack_mem_gpr(ret_r);
    assign entries[29] = pack_mem_gpr(push_r);
    assign entries[30] = pack_mem_gpr(pop_r);
    assign entries[31] = pack_gpr_flags(mul_r);
    assign entries[32] = pack_gpr_flags(imul_r);
    assign entries[33] = pack_gpr_only(div_r);
    assign entries[34] = pack_gpr_only(idiv_r);
    assign entries[35] = pack_gpr_only(bswap_r);
    assign entries[36] = pack_gpr_flags(cmpxchg_r);
    assign entries[37] = pack_gpr_flags(xadd_r);
    assign entries[38] = pack_flags_only(bt_r);
    assign entries[39] = pack_gpr_flags(bts_r);
    assign entries[40] = pack_gpr_flags(btr_r);
    assign entries[41] = pack_gpr_flags(btc_r);
    assign entries[42] = pack_gpr_flags(bsf_r);
    assign entries[43] = pack_gpr_flags(bsr_r);
    assign entries[44] = pack_gpr_only(setcc_r);
    assign entries[45] = pack_mem_gpr(string_r);
    assign entries[46] = pack_flags_only(flag_ctrl_r);
    assign entries[47] = pack_gpr_only(misc_r);

    assign branch_entry.data.result           = branch_target;
    assign branch_entry.data.cf               = 1'b0;
    assign branch_entry.data.pf               = 1'b0;
    assign branch_entry.data.af               = 1'b0;
    assign branch_entry.data.zf               = 1'b0;
    assign branch_entry.data.sf               = 1'b0;
    assign branch_entry.data.of               = 1'b0;
    assign branch_entry.data.mem_valid        = 1'b0;
    assign branch_entry.data.mem_write_enable = 1'b0;
    assign branch_entry.data.mem_address      = 32'd0;
    assign branch_entry.data.mem_write_data   = 32'd0;
    assign branch_entry.write_gpr             = 1'b0;
    assign branch_entry.write_flags           = 1'b0;
    assign branch_entry.write_ip              = condition_met;
    assign branch_entry.ip_data               = branch_target;

    // Single driver for call_entry (avoid whole-struct + field assign conflict
    // that left write_ip stuck at 0 in Verilator).
    // Defer ESP and IP writeback until store completes — issuing write_ip early
    // redirects before the return address is pushed; write_gpr early lets a
    // re-issue push again with ESP already decremented (clobbering the arg).
    always_comb begin
        call_entry                = pack_mem_gpr(call_r);
        call_entry.write_gpr      = 1'b0;
        call_entry.write_ip       = 1'b0;
        call_entry.ip_data        = call_target;
    end

    assign xchg_entry.data             = xchg_r;
    assign xchg_entry.write_gpr        = 1'b1;
    assign xchg_entry.write_flags      = 1'b0;
    assign xchg_entry.write_ip         = 1'b0;
    assign xchg_entry.ip_data          = 32'd0;

    always_comb begin
        select_idx = 6'd63;
        unique case (i_uop_opcode)
            `UOP_ADD:     select_idx = 6'd0;
            `UOP_SUB:     select_idx = 6'd1;
            `UOP_AND:     select_idx = 6'd2;
            `UOP_OR:      select_idx = 6'd3;
            `UOP_XOR:     select_idx = 6'd4;
            `UOP_ADC:     select_idx = 6'd5;
            `UOP_SBB:     select_idx = 6'd6;
            `UOP_INC:     select_idx = 6'd7;
            `UOP_DEC:     select_idx = 6'd8;
            `UOP_NEG:     select_idx = 6'd9;
            `UOP_NOT:     select_idx = 6'd10;
            `UOP_CMP:     select_idx = 6'd11;
            `UOP_TEST:    select_idx = 6'd12;
            `UOP_SHL:     select_idx = 6'd13;
            `UOP_SHR:     select_idx = 6'd14;
            `UOP_SAR:     select_idx = 6'd15;
            `UOP_ROL:     select_idx = 6'd16;
            `UOP_ROR:     select_idx = 6'd17;
            `UOP_RCL:     select_idx = 6'd18;
            `UOP_RCR:     select_idx = 6'd19;
            `UOP_SHLD:    select_idx = 6'd20;
            `UOP_SHRD:    select_idx = 6'd21;
            `UOP_MOV:     if (reg_mov_only) select_idx = 6'd22;
            `UOP_MOVSX:   if (~i_mem_access) select_idx = 6'd23;
            `UOP_MOVZX:   if (~i_mem_access) select_idx = 6'd24;
            `UOP_LEA:     select_idx = 6'd25;
            `UOP_BRANCH:  if (~i_mem_access) select_idx = 6'd26;
            `UOP_CALL:    select_idx = 6'd27;
            `UOP_RET:     select_idx = 6'd28;
            `UOP_PUSH:    select_idx = 6'd29;
            `UOP_POP:     select_idx = 6'd30;
            `UOP_MUL:     select_idx = 6'd31;
            `UOP_IMUL:    select_idx = 6'd32;
            `UOP_DIV:     select_idx = 6'd33;
            `UOP_IDIV:    select_idx = 6'd34;
            `UOP_XADD:    select_idx = 6'd37;
            `UOP_CMPXCHG: select_idx = 6'd36;
            `UOP_BT:      select_idx = 6'd38;
            `UOP_BTS:     select_idx = 6'd39;
            `UOP_BTR:     select_idx = 6'd40;
            `UOP_BTC:     select_idx = 6'd41;
            `UOP_BSF:     select_idx = 6'd42;
            `UOP_BSR:     select_idx = 6'd43;
            `UOP_SETCC:   select_idx = 6'd44;
            `UOP_STRING:  select_idx = 6'd45;
            `UOP_FLAG_CTRL: select_idx = 6'd46;
            `UOP_MISC:    if (misc_simple) begin
                if (i_immediate[7: 0] == `MISC_SUB_BSWAP) select_idx = 6'd35;
                else select_idx = 6'd47;
            end
            `UOP_XCHG:    select_idx = 6'd63;
            default:      select_idx = 6'd63;
        endcase
    end

    exu_result_mux #(
        .LP_ENTRIES (LP_NUM_ENTRIES)
    ) u_result_mux (
        .i_entries  (entries),
        .i_select   (select_idx),
        .o_selected (mux_out)
    );

    assign o_dispatch = (i_uop_opcode == `UOP_XCHG) ? xchg_entry : mux_out;

    assign o_handled = i_valid & (
        exu_opcode_dispatched(i_uop_opcode) |
        misc_simple |
        (i_uop_opcode == `UOP_XCHG)
    ) & ~((i_uop_opcode == `UOP_MOV) & i_mem_access)
      & ~(((i_uop_opcode == `UOP_MOVZX) | (i_uop_opcode == `UOP_MOVSX)) & i_mem_access)
      & ~((i_uop_opcode == `UOP_BRANCH) & i_mem_access);

endmodule
