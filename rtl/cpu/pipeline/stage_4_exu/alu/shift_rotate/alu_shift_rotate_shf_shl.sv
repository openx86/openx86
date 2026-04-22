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
//  File        : shf_execute_shift_left.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : shf_execute_shift_left module
// ============================================================================

module alu_shift_rotate_shf_shl #(
    parameter BIT_WIDTH = 32
) (
    input  logic [BIT_WIDTH-1: 0] a,
    input  logic [BIT_WIDTH-1: 0] count,
    output logic [BIT_WIDTH-1: 0] y
);

localparam int SHIFT_W = (BIT_WIDTH <= 1) ? 1 : $clog2(BIT_WIDTH);
logic [SHIFT_W-1: 0] shift_amt;

assign shift_amt = count[SHIFT_W-1:0];
assign y = a << shift_amt;

endmodule
