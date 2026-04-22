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
//  File        : rf_x86_gpr_eax.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : EAX register module with named read ports (eax/ax/ah/al) and separate write enables
// ============================================================================

module rf_x86_gpr_eax (
    // Write ports
    input  logic         i_write_enable_EAX,
    input  logic         i_write_enable_AX,
    input  logic         i_write_enable_AL,
    input  logic         i_write_enable_AH,
    input  logic [31: 0] i_write_data_EAX,
    input  logic [15: 0] i_write_data_AX,
    input  logic [ 7: 0] i_write_data_AL,
    input  logic [ 7: 0] i_write_data_AH,
    // Read ports (natural widths)
    output logic [31: 0] o_EAX,
    output logic [15: 0] o_AX,
    output logic [ 7: 0] o_AH,
    output logic [ 7: 0] o_AL,
    input  logic         clk,
    input  logic         rst_n
);

logic [31: 0] register;

always_ff @(posedge clk or negedge rst_n) begin : ff_register
    if (~rst_n) begin
        register <= 32'h0;
    end else begin
        if (i_write_enable_EAX) begin
            register <= i_write_data_EAX;
        end else if (i_write_enable_AX) begin
            register[15: 0] <= i_write_data_AX;
        end else if (i_write_enable_AL) begin
            register[ 7: 0] <= i_write_data_AL;
        end else if (i_write_enable_AH) begin
            register[15: 8] <= i_write_data_AH;
        end
    end
end

assign o_EAX = register;
assign o_AX  = register[15: 0];
assign o_AH  = register[15: 8];
assign o_AL  = register[ 7: 0];

endmodule
