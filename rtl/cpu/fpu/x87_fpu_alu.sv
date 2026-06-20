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
//  Description : x87 floating-point ALU (80-bit simplified real path)
// ============================================================================

module x87_fpu_alu (
    input  logic         i_op_add,
    input  logic         i_op_sub,
    input  logic         i_op_mul,
    input  logic         i_op_div,
    input  logic [63: 0] i_st0_mant,
    input  logic [63: 0] i_sti_mant,
    input  logic         i_st0_sign,
    input  logic         i_sti_sign,
    output logic [63: 0] o_result_mant,
    output logic         o_result_sign,
    output logic         o_divide_by_zero,
    output logic         o_invalid_op
);

    logic [63: 0] sum_mant;
    logic [127: 0] mul_mant;
    logic [63: 0] div_mant;

    assign sum_mant = i_st0_mant + i_sti_mant;
    assign mul_mant = i_st0_mant * i_sti_mant;

    always_comb begin
        o_result_mant    = i_st0_mant;
        o_result_sign    = i_st0_sign;
        o_divide_by_zero = 1'b0;
        o_invalid_op     = 1'b0;

        if (i_op_add) begin
            o_result_mant = sum_mant;
            o_result_sign = i_st0_sign;
        end else if (i_op_sub) begin
            o_result_mant = i_st0_mant - i_sti_mant;
            o_result_sign = i_st0_sign;
        end else if (i_op_mul) begin
            o_result_mant = mul_mant[63: 0];
            o_result_sign = i_st0_sign ^ i_sti_sign;
        end else if (i_op_div) begin
            if (i_sti_mant == 64'd0) begin
                o_divide_by_zero = 1'b1;
            end else begin
                div_mant         = i_st0_mant / i_sti_mant;
                o_result_mant    = div_mant;
                o_result_sign    = i_st0_sign ^ i_sti_sign;
            end
        end
    end

endmodule
