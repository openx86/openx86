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
//  File        : rf_x86_gpr_ecx.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ECX register module with named read ports (ecx/cx/ch/cl) and separate write enables
// ============================================================================

module rf_x86_gpr_ecx (
    // Write ports
    input  logic         i_write_enable_ECX,
    input  logic         i_write_enable_CX,
    input  logic         i_write_enable_CL,
    input  logic         i_write_enable_CH,
    input  logic [31: 0] i_write_data_ECX,
    input  logic [15: 0] i_write_data_CX,
    input  logic [ 7: 0] i_write_data_CL,
    input  logic [ 7: 0] i_write_data_CH,
    // Read ports (natural widths)
    output logic [31: 0] o_ECX,
    output logic [15: 0] o_CX,
    output logic [ 7: 0] o_CH,
    output logic [ 7: 0] o_CL,
    input  logic         clk,
    input  logic         rst_n
);

logic [31: 0] register;

always_ff @(posedge clk or negedge rst_n) begin : ff_register
    if (~rst_n) begin
        register <= 32'h0;
    end else begin
        if (i_write_enable_ECX) begin
            register <= i_write_data_ECX;
        end else if (i_write_enable_CX) begin
            register[15: 0] <= i_write_data_CX;
        end else if (i_write_enable_CL) begin
            register[ 7: 0] <= i_write_data_CL;
        end else if (i_write_enable_CH) begin
            register[15: 8] <= i_write_data_CH;
        end
    end
end

assign o_ECX = register;
assign o_CX  = register[15: 0];
assign o_CH  = register[15: 8];
assign o_CL  = register[ 7: 0];

endmodule
