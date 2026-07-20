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
//  Description : x86 exception/interrupt arbitration and IDU delegation
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
    input  logic         i_software_int_valid,
    input  logic [ 7: 0] i_software_int_vector,
    input  logic         i_iret_valid,
    input  logic [31: 0] i_idtr_base,
    input  logic [15: 0] i_idtr_limit,
    input  logic [31: 0] i_current_eip,
    input  logic [15: 0] i_current_cs_selector,
    input  logic [31: 0] i_current_eflags,
    input  logic [31: 0] i_current_esp,
    input  logic [ 1: 0] i_cpl,
    input  logic         i_inta_vector_valid,
    input  logic [ 7: 0] i_inta_vector,
    output logic         o_flush_pipeline,
    output logic         o_clear_if,
    output logic         o_new_eip_valid,
    output logic [31: 0] o_new_eip,
    output logic         o_new_cs_valid,
    output logic [15: 0] o_new_cs_selector,
    output logic         o_esp_write_enable,
    output logic [31: 0] o_esp_write_data,
    output logic         o_eflags_write_enable,
    output logic [31: 0] o_eflags_write_data,
    output logic [ 7: 0] o_vector,
    output logic         o_error_code_valid,
    output logic [31: 0] o_error_code,
    output logic         o_inta_req,
    output logic         o_idu_busy,
    output logic         o_mem_valid,
    input  logic         i_mem_ready,
    output logic         o_mem_write_enable,
    output logic [31: 0] o_mem_address,
    output logic [31: 0] o_mem_write_data,
    input  logic [31: 0] i_mem_rdata,
    output logic         o_ferr_n,
    input  logic         i_fpu_exception,
    input  logic         clk,
    input  logic         rst_n
);

    logic         pending_intr;
    logic         pending_iret;
    logic         pending_external;
    logic [ 7: 0] pending_vector;
    logic         pending_has_ec;
    logic [31: 0] pending_error_code;
    logic         request_pending_r;
    logic         idu_start;

    assign pending_intr = i_exception_valid |
                          i_nmi |
                          (i_external_intr & i_if_flag) |
                          i_software_int_valid;

    assign pending_iret = i_iret_valid & ~pending_intr;

    always_comb begin
        pending_vector     = 8'hFF;
        pending_has_ec     = 1'b0;
        pending_error_code = 32'h0;
        pending_external   = 1'b0;
        if (i_exception_valid) begin
            pending_vector     = i_exception_vector;
            pending_has_ec     = i_has_error_code;
            pending_error_code = i_error_code;
        end else if (i_nmi) begin
            pending_vector = 8'h02;
        end else if (i_external_intr & i_if_flag) begin
            pending_vector   = 8'h20;
            pending_external = 1'b1;
        end else if (i_software_int_valid) begin
            pending_vector = i_software_int_vector;
        end
    end

    assign idu_start = request_pending_r & ~o_idu_busy;

    always_ff @(posedge clk or negedge rst_n) begin : ff_request_pending
        if (~rst_n) begin
            request_pending_r <= 1'b0;
        end else if (pending_intr | pending_iret) begin
            request_pending_r <= 1'b1;
        end else if (o_idu_busy) begin
            request_pending_r <= 1'b0;
        end
    end

    interrupt_delivery_unit u_idu (
        .i_start                (idu_start),
        .i_is_iret              (pending_iret),
        .i_is_external          (pending_external),
        .i_vector               (pending_vector),
        .i_has_error_code       (pending_has_ec),
        .i_error_code           (pending_error_code),
        .i_saved_eip            (i_current_eip),
        .i_saved_cs_selector    (i_current_cs_selector),
        .i_saved_eflags         (i_current_eflags),
        .i_saved_esp            (i_current_esp),
        .i_idtr_base            (i_idtr_base),
        .i_idtr_limit           (i_idtr_limit),
        .i_inta_vector_valid    (i_inta_vector_valid),
        .i_inta_vector          (i_inta_vector),
        .i_cpl                  (i_cpl),
        .i_gate_dpl             (2'b00),
        .i_need_stack_switch    (1'b0),
        .i_new_ss               (16'h0),
        .i_new_esp              (32'h0),
        .o_busy                 (o_idu_busy),
        .o_inta_req             (o_inta_req),
        .o_done                 (),
        .o_flush_pipeline       (o_flush_pipeline),
        .o_clear_if             (o_clear_if),
        .o_new_eip_valid        (o_new_eip_valid),
        .o_new_eip              (o_new_eip),
        .o_new_cs_valid         (o_new_cs_valid),
        .o_new_cs_selector      (o_new_cs_selector),
        .o_esp_write_enable     (o_esp_write_enable),
        .o_esp_write_data       (o_esp_write_data),
        .o_eflags_write_enable  (o_eflags_write_enable),
        .o_eflags_write_data    (o_eflags_write_data),
        .o_mem_valid            (o_mem_valid),
        .i_mem_ready            (i_mem_ready),
        .o_mem_write_enable     (o_mem_write_enable),
        .o_mem_address          (o_mem_address),
        .o_mem_write_data       (o_mem_write_data),
        .i_mem_rdata            (i_mem_rdata),
        .clk                    (clk),
        .rst_n                  (rst_n)
    );

    assign o_vector           = pending_vector;
    assign o_error_code_valid = pending_has_ec & pending_intr;
    assign o_error_code       = pending_error_code;
    assign o_ferr_n           = ~i_fpu_exception;

endmodule
