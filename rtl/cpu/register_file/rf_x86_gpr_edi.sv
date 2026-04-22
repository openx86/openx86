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
//  File        : rf_x86_gpr_edi.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : EDI register module with named read port (edi) and separate write enables for 32/16-bit writes
// ============================================================================

module rf_x86_gpr_edi (
    // Write ports
    input  logic         i_write_enable_EDI,
    input  logic         i_write_enable_DI,
    input  logic [31: 0] i_write_data_EDI,
    input  logic [15: 0] i_write_data_DI,
    // Read port (natural width)
    output logic [31: 0] o_EDI,
    input  logic         clk,
    input  logic         rst_n
);

logic [31: 0] register;

always_ff @(posedge clk or negedge rst_n) begin : ff_register
    if (~rst_n) begin
        register <= 32'h0;
    end else begin
        if (i_write_enable_EDI) begin
            register <= i_write_data_EDI;
        end else if (i_write_enable_DI) begin
            register[15: 0] <= i_write_data_DI;
        end
    end
end

assign o_EDI = register;

endmodule
