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
//  File        : x87_fpu_alu.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : x87 floating-point ALU (80-bit extended precision path)
// ============================================================================

module x87_fpu_alu (
    input  logic         i_op_add,
    input  logic         i_op_sub,
    input  logic         i_op_mul,
    input  logic         i_op_div,
    input  logic [79: 0] i_st0,
    input  logic [79: 0] i_sti,
    output logic [79: 0] o_result,
    output logic         o_divide_by_zero,
    output logic         o_invalid_op
);

    localparam logic [14: 0] LP_EXP_BIAS = 15'd16383;

    logic         st0_sign;
    logic         sti_sign;
    logic [14: 0] st0_exp;
    logic [14: 0] sti_exp;
    logic [63: 0] st0_sig;
    logic [63: 0] sti_sig;
    logic         st0_zero;
    logic         sti_zero;
    logic [14: 0] res_exp;
    logic [63: 0] res_sig;
    logic         res_sign;
    logic [127: 0] mul_wide;
    logic [127: 0] div_wide;

    assign st0_sign = i_st0[79];
    assign sti_sign = i_sti[79];
    assign st0_exp  = i_st0[78: 64];
    assign sti_exp  = i_sti[78: 64];
    assign st0_sig  = i_st0[63: 0];
    assign sti_sig  = i_sti[63: 0];
    logic [63: 0] st0_sig_eff;
    logic [63: 0] sti_sig_eff;

    assign st0_zero    = (st0_exp == 15'h0) && (st0_sig == 64'h0);
    assign sti_zero    = (sti_exp == 15'h0) && (sti_sig == 64'h0);
    assign st0_sig_eff = st0_sig[63] ? st0_sig : {1'b1, st0_sig[62: 0]};
    assign sti_sig_eff = sti_sig[63] ? sti_sig : {1'b1, sti_sig[62: 0]};

    always_comb begin
        o_result         = i_st0;
        o_divide_by_zero = 1'b0;
        o_invalid_op     = 1'b0;
        res_exp          = st0_exp;
        res_sig          = st0_sig;
        res_sign         = st0_sign;

        if (i_op_add | i_op_sub) begin
            if (st0_zero) begin
                o_result = i_sti;
                if (i_op_sub) begin
                    o_result[79]    = ~i_sti[79];
                    o_result[78: 0] = i_sti[78: 0];
                end
            end else if (sti_zero) begin
                o_result = i_st0;
            end else begin
                logic [14: 0] big_exp;
                logic [14: 0] small_exp;
                logic [63: 0] big_sig;
                logic [63: 0] small_sig;
                logic         big_sign;
                logic [14: 0] exp_diff;
                logic [63: 0] aligned_small;
                logic [64: 0] sum_wide;
                if (st0_exp >= sti_exp) begin
                    big_exp   = st0_exp;
                    small_exp = sti_exp;
                    big_sig   = st0_sig_eff;
                    small_sig = sti_sig_eff;
                    big_sign  = st0_sign;
                    exp_diff  = st0_exp - sti_exp;
                end else begin
                    big_exp   = sti_exp;
                    small_exp = st0_exp;
                    big_sig   = sti_sig_eff;
                    small_sig = st0_sig_eff;
                    big_sign  = sti_sign;
                    exp_diff  = sti_exp - st0_exp;
                end
                aligned_small = exp_diff >= 15'd64 ? 64'h0 : (small_sig >> exp_diff);
                if (i_op_add) begin
                    if (st0_sign == sti_sign) begin
                        sum_wide  = {1'b0, big_sig} + {1'b0, aligned_small};
                        res_sign  = st0_sign;
                        res_exp   = big_exp;
                        // Carry out of integer bit: right-shift and bump exponent
                        res_sig   = sum_wide[64] ? sum_wide[64: 1] : sum_wide[63: 0];
                        if (sum_wide[64])
                            res_exp = res_exp + 15'd1;
                    end else begin
                        if (big_sig >= aligned_small) begin
                            res_sig  = big_sig - aligned_small;
                            res_sign = big_sign;
                            res_exp  = big_exp;
                        end else begin
                            res_sig  = aligned_small - big_sig;
                            res_sign = ~big_sign;
                            res_exp  = big_exp;
                        end
                    end
                end else begin
                    if (st0_sign != sti_sign) begin
                        sum_wide  = {1'b0, big_sig} + {1'b0, aligned_small};
                        res_sign  = st0_sign;
                        res_exp   = big_exp;
                        res_sig   = sum_wide[64] ? sum_wide[64: 1] : sum_wide[63: 0];
                        if (sum_wide[64])
                            res_exp = res_exp + 15'd1;
                    end else begin
                        if (big_sig >= aligned_small) begin
                            res_sig  = big_sig - aligned_small;
                            res_sign = big_sign;
                            res_exp  = big_exp;
                        end else begin
                            res_sig  = aligned_small - big_sig;
                            res_sign = ~big_sign;
                            res_exp  = big_exp;
                        end
                    end
                end
                o_result[79]    = res_sign;
                o_result[78: 64] = res_exp;
                o_result[63: 0]  = res_sig;
            end
        end else if (i_op_mul) begin
            if (st0_zero | sti_zero) begin
                o_result = 80'h0;
            end else begin
                mul_wide         = st0_sig_eff * sti_sig_eff;
                res_exp          = st0_exp + sti_exp - LP_EXP_BIAS;
                res_sign         = st0_sign ^ sti_sign;
                if (mul_wide[127]) begin
                    res_sig  = mul_wide[127: 64];
                    res_exp  = res_exp + 15'd1;
                end else begin
                    res_sig  = mul_wide[126: 63];
                end
                o_result[79]    = res_sign;
                o_result[78: 64] = res_exp;
                o_result[63: 0]  = res_sig;
            end
        end else if (i_op_div) begin
            if (sti_zero) begin
                o_divide_by_zero = 1'b1;
                o_result         = 80'h0;
            end else if (st0_zero) begin
                o_result = 80'h0;
            end else begin
                div_wide         = {st0_sig_eff, 64'h0} / sti_sig_eff;
                res_exp          = st0_exp - sti_exp + LP_EXP_BIAS;
                res_sign         = st0_sign ^ sti_sign;
                res_sig          = div_wide[127: 64];
                o_result[79]    = res_sign;
                o_result[78: 64] = res_exp;
                o_result[63: 0]  = res_sig;
            end
        end
    end

endmodule
