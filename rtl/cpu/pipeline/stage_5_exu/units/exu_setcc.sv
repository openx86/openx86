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
//  File        : exu_setcc.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : SETCC execution unit - set byte on condition
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_setcc (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [31: 0] i_immediate,
    input  logic         i_has_imm,
    input  logic [ 3: 0] i_tttn,
    output exu_result_t   o_result
);

    logic         condition_met;
    logic [ 7: 0] result;
    logic [ 3: 0] tttn;
    logic [31: 0] result_full;

    assign tttn = i_tttn;

    always_comb begin
        condition_met = 1'b0;
        case (tttn)
            4'h0: condition_met = 1'b0;
            4'h1: condition_met = 1'b0;
            4'h2: condition_met = 1'b0;
            4'h3: condition_met = 1'b0;
            4'h4: condition_met = 1'b0;
            4'h5: condition_met = 1'b0;
            4'h6: condition_met = 1'b0;
            4'h7: condition_met = 1'b0;
            4'h8: condition_met = 1'b0;
            4'h9: condition_met = 1'b0;
            4'hA: condition_met = 1'b0;
            4'hB: condition_met = 1'b0;
            4'hC: condition_met = 1'b0;
            4'hD: condition_met = 1'b0;
            4'hE: condition_met = 1'b0;
            4'hF: condition_met = 1'b1;
            default: condition_met = 1'b0;
        endcase
    end

    assign result = condition_met ? 8'h01 : 8'h00;
    assign result_full = {24'd0, result};

    assign o_result.result           = result_full;
    assign o_result.cf               = 1'b0;
    assign o_result.pf               = 1'b0;
    assign o_result.af               = 1'b0;
    assign o_result.zf               = 1'b0;
    assign o_result.sf               = 1'b0;
    assign o_result.of               = 1'b0;
    assign o_result.mem_valid        = 1'b0;
    assign o_result.mem_write_enable = 1'b0;
    assign o_result.mem_address      = 32'd0;
    assign o_result.mem_write_data   = 32'd0;

endmodule
