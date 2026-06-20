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
//  File        : exception_interrupt_unit.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : x86 exception and interrupt delivery unit
// ============================================================================

`include "openx86_defs.h.sv"

module exception_interrupt_unit (
    input  logic         i_exception_valid,
    input  logic [ 7: 0] i_exception_vector,
    input  logic         i_has_error_code,
    input  logic [31: 0] i_error_code,
    input  logic         i_external_intr,
    input  logic         i_nmi,
    input  logic         i_if_flag,
    input  logic [31: 0] i_idtr_base,
    input  logic [15: 0] i_idtr_limit,
    input  logic [31: 0] i_current_eip,
    input  logic [31: 0] i_current_cs_base,
    input  logic [ 1: 0] i_cpl,
    output logic         o_flush_pipeline,
    output logic         o_clear_if,
    output logic         o_new_eip_valid,
    output logic [31: 0] o_new_eip,
    output logic [ 7: 0] o_vector,
    output logic         o_error_code_valid,
    output logic [31: 0] o_error_code,
    output logic         o_ferr_n,
    input  logic         i_fpu_exception,
    input  logic         clk,
    input  logic         rst_n
);

    logic         pending_intr;
    logic [ 7: 0] pending_vector;
    logic         deliver;

    assign pending_intr = (i_external_intr & i_if_flag) | i_nmi | i_exception_valid;

    always_comb begin
        pending_vector = 8'hFF;
        if (i_exception_valid) begin
            pending_vector = i_exception_vector;
        end else if (i_nmi) begin
            pending_vector = 8'h02;
        end else if (i_external_intr & i_if_flag) begin
            pending_vector = 8'h20;
        end
    end

    assign deliver = pending_intr;

    always_comb begin
        o_flush_pipeline  = deliver;
        o_clear_if        = deliver;
        o_new_eip_valid   = deliver;
        o_vector          = pending_vector;
        o_error_code_valid = deliver & i_has_error_code;
        o_error_code      = i_error_code;
        if (deliver) begin
            if ((pending_vector * 8 + 8) > {16'd0, i_idtr_limit}) begin
                o_new_eip = 32'hFFFF_FFF0;
            end else begin
                o_new_eip = i_idtr_base + {24'd0, pending_vector, 3'b000};
            end
        end else begin
            o_new_eip = i_current_eip;
        end
    end

    assign o_ferr_n = ~i_fpu_exception;

endmodule
