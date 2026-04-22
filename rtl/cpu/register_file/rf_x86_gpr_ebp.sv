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
//  Description : EBP register module with named read port (ebp) and separate write enables for 32/16-bit writes
// ============================================================================

module rf_x86_gpr_ebp (
    // Write ports
    input  logic         i_write_enable_EBP,
    input  logic         i_write_enable_BP,
    input  logic [31: 0] i_write_data_EBP,
    input  logic [15: 0] i_write_data_BP,
    // Read port (natural width)
    output logic [31: 0] o_EBP,
    input  logic         clk,
    input  logic         rst_n
);

logic [31: 0] register;

always_ff @(posedge clk or negedge rst_n) begin : ff_register
    if (~rst_n) begin
        register <= 32'h0;
    end else begin
        if (i_write_enable_EBP) begin
            register <= i_write_data_EBP;
        end else if (i_write_enable_BP) begin
            register[15: 0] <= i_write_data_BP;
        end
    end
end

assign o_EBP = register;

endmodule
