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
//  File        : rf_x86_gpr_ebx.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : EBX register module with named read ports (ebx/bx/bh/bl) and separate write enables
// ============================================================================

module rf_x86_gpr_ebx (
    // Write ports
    input  logic         i_write_enable_EBX,
    input  logic         i_write_enable_BX,
    input  logic         i_write_enable_BL,
    input  logic         i_write_enable_BH,
    input  logic [31: 0] i_write_data_EBX,
    input  logic [15: 0] i_write_data_BX,
    input  logic [ 7: 0] i_write_data_BL,
    input  logic [ 7: 0] i_write_data_BH,
    // Read ports (natural widths)
    output logic [31: 0] o_EBX,
    output logic [15: 0] o_BX,
    output logic [ 7: 0] o_BH,
    output logic [ 7: 0] o_BL,
    input  logic         clk,
    input  logic         rst_n
);

logic [31: 0] register;

always_ff @(posedge clk or negedge rst_n) begin : ff_register
    if (~rst_n) begin
        register <= 32'h0;
    end else begin
        if (i_write_enable_EBX) begin
            register <= i_write_data_EBX;
        end else if (i_write_enable_BX) begin
            register[15: 0] <= i_write_data_BX;
        end else if (i_write_enable_BL) begin
            register[ 7: 0] <= i_write_data_BL;
        end else if (i_write_enable_BH) begin
            register[15: 8] <= i_write_data_BH;
        end
    end
end

assign o_EBX = register;
assign o_BX  = register[15: 0];
assign o_BH  = register[15: 8];
assign o_BL  = register[ 7: 0];

endmodule
