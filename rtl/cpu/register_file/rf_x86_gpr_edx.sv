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
//  File        : rf_x86_gpr_edx.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : EDX register module with named read ports (edx/dx/dh/dl) and separate write enables
// ============================================================================

module rf_x86_gpr_edx (
    // Write ports
    input  logic         i_write_enable_EDX,
    input  logic         i_write_enable_DX,
    input  logic         i_write_enable_DL,
    input  logic         i_write_enable_DH,
    input  logic [31: 0] i_write_data_EDX,
    input  logic [15: 0] i_write_data_DX,
    input  logic [ 7: 0] i_write_data_DL,
    input  logic [ 7: 0] i_write_data_DH,
    // Read ports (natural widths)
    output logic [31: 0] o_EDX,
    output logic [15: 0] o_DX,
    output logic [ 7: 0] o_DH,
    output logic [ 7: 0] o_DL,
    input  logic         clk,
    input  logic         rst_n
);

logic [31: 0] register;

always_ff @(posedge clk or negedge rst_n) begin : ff_register
    if (~rst_n) begin
        register <= 32'h0;
    end else begin
        if (i_write_enable_EDX) begin
            register <= i_write_data_EDX;
        end else if (i_write_enable_DX) begin
            register[15: 0] <= i_write_data_DX;
        end else if (i_write_enable_DL) begin
            register[ 7: 0] <= i_write_data_DL;
        end else if (i_write_enable_DH) begin
            register[15: 8] <= i_write_data_DH;
        end
    end
end

assign o_EDX = register;
assign o_DX  = register[15: 0];
assign o_DH  = register[15: 8];
assign o_DL  = register[ 7: 0];

endmodule
