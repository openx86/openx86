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
//  File        : rf_x86_eflags.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : EFLAGS register module
// ============================================================================

module rf_x86_eflags (
    input  logic         i_write_enable,
    input  logic [31: 0] i_write_data,
    output logic         o_CF,
    output logic         o_PF,
    output logic         o_AF,
    output logic         o_ZF,
    output logic         o_SF,
    output logic         o_TF,
    output logic         o_IF,
    output logic         o_DF,
    output logic         o_OF,
    output logic [ 1: 0] o_IOPL,
    output logic         o_NT,
    output logic         o_RF,
    output logic         o_VM,
    output logic [31: 0] o_EFLAGS,
    output logic [15: 0] o_FLAGS,
    input  logic         clk,
    input  logic         rst_n
);

logic [31: 0] flags_reg;

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        flags_reg <= 32'b0;
    end else if (i_write_enable) begin
        flags_reg <= i_write_data;
    end
end

assign o_EFLAGS = flags_reg[31: 0];
assign o_FLAGS  = flags_reg[15: 0];

assign o_CF   = flags_reg[    0];
assign o_PF   = flags_reg[    2];
assign o_AF   = flags_reg[    4];
assign o_ZF   = flags_reg[    6];
assign o_SF   = flags_reg[    7];
assign o_TF   = flags_reg[    8];
assign o_IF   = flags_reg[    9];
assign o_DF   = flags_reg[   10];
assign o_OF   = flags_reg[   11];
assign o_IOPL = flags_reg[13: 12];
assign o_NT   = flags_reg[   14];
assign o_RF   = flags_reg[   16];
assign o_VM   = flags_reg[   17];

endmodule
