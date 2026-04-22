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
//  File        : rf_x87_fpu_st1.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ST1 x87 FPU register module
// ============================================================================

module rf_x87_fpu_st1 (
    input  logic         i_write_enable,
    input  logic [79: 0] i_write_data,
    output logic [79: 0] o_data,
    input  logic         clk,
    input  logic         rst_n
);

logic [79: 0] register;

always_ff @(posedge clk or negedge rst_n) begin : ff_register
    if (~rst_n) begin
        register <= 80'h0;
    end else if (i_write_enable) begin
        register <= i_write_data;
    end
end

assign o_data = register;

endmodule
