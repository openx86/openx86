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
//  File        : sse_alu.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : SSE1 scalar/packed ALU subset
// ============================================================================

module sse_alu (
    input  logic         i_op_addss,
    input  logic         i_op_mulss,
    input  logic [31: 0] i_src1,
    input  logic [31: 0] i_src2,
    output logic [31: 0] o_result
);

    always_comb begin
        o_result = i_src1;
        if (i_op_addss) begin
            o_result = i_src1 + i_src2;
        end else if (i_op_mulss) begin
            o_result = i_src1 * i_src2;
        end
    end

endmodule
