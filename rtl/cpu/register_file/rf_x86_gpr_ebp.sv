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
//  File        : rf_x86_gpr_ebp.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : EBP register module
// ============================================================================

module rf_x86_gpr_ebp (
    input  logic         i_write_enable,
    input  logic [31: 0] i_write_data,
    output logic [ 7: 0] o_read__8,
    output logic [ 7: 0] o_read_16,
    output logic [31: 0] o_read_32,
    input  logic         clk,
    input  logic         rst_n
);

logic [31: 0] register;

always_ff @(posedge clk or negedge rst_n) begin : ff_register
    if (~rst_n) begin
        register <= 32'h0;
    end else if (i_write_enable) begin
        register <= i_write_data;
    end
end

assign o_read_32 = register;
assign o_read_16 = {16'h0, register[15: 0]};
assign o_read__8 = {24'h0, register[ 7: 0]};

endmodule
