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
//  Description : x86 exception/interrupt arbitration, optional TSS stack
//                switch fetch, and IDU delegation
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
    input  logic [15: 0] i_current_ss_selector,
    input  logic [31: 0] i_current_eflags,
    input  logic [31: 0] i_current_esp,
    input  logic [ 1: 0] i_cpl,
    input  logic [31: 0] i_tss_base,
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

    typedef enum logic [ 1: 0] {
        EIU_IDLE,
        EIU_TSS,
        EIU_IDU
    } eiu_state_t;

    eiu_state_t state;

    logic         pending_intr;
    logic         pending_iret;
    logic         pending_external;
    logic [ 7: 0] pending_vector;
    logic         pending_has_ec;
    logic [31: 0] pending_error_code;
    logic         need_tss_fetch;
    logic         request_latched_r;
    logic         latched_is_iret;
    logic         latched_is_external;
    logic [ 7: 0] latched_vector;
    logic         latched_has_ec;
    logic [31: 0] latched_error_code;
    logic         latched_need_switch;
    logic [15: 0] latched_new_ss;
    logic [31: 0] latched_new_esp;

    logic         idu_busy;
    logic         idu_start;
    logic         idu_mem_valid;
    logic         idu_mem_we;
    logic [31: 0] idu_mem_addr;
    logic [31: 0] idu_mem_wdata;
    logic         idu_flush;
    logic         idu_clear_if;
    logic         idu_new_eip_valid;
    logic [31: 0] idu_new_eip;
    logic         idu_new_cs_valid;
    logic [15: 0] idu_new_cs_selector;
    logic         idu_esp_we;
    logic [31: 0] idu_esp_data;
    logic         idu_eflags_we;
    logic [31: 0] idu_eflags_data;
    logic         idu_inta_req;

    logic         tss_busy;
    logic         tss_done;
    logic         tss_start;
    logic [31: 0] tss_new_esp;
    logic [15: 0] tss_new_ss;
    logic         tss_bus_valid;
    logic         tss_bus_we;
    logic [31: 0] tss_bus_addr;
    logic [31: 0] tss_bus_wdata;

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

    // Privilege change toward ring 0: fetch ESP0/SS0 from TSS when base is valid
    assign need_tss_fetch = pending_intr & ~pending_iret &
                            (i_cpl != 2'b00) & (i_tss_base != 32'h0);

    assign o_idu_busy = (state != EIU_IDLE) | idu_busy | tss_busy;

    assign o_mem_valid        = (state == EIU_TSS) ? tss_bus_valid : idu_mem_valid;
    assign o_mem_write_enable = (state == EIU_TSS) ? tss_bus_we    : idu_mem_we;
    assign o_mem_address      = (state == EIU_TSS) ? tss_bus_addr  : idu_mem_addr;
    assign o_mem_write_data   = (state == EIU_TSS) ? tss_bus_wdata : idu_mem_wdata;

    logic         tss_started_r;

    assign idu_start = (state == EIU_IDU) & ~idu_busy & request_latched_r;
    assign tss_start = (state == EIU_TSS) & ~tss_started_r;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state               <= EIU_IDLE;
            request_latched_r   <= 1'b0;
            latched_is_iret     <= 1'b0;
            latched_is_external <= 1'b0;
            latched_vector      <= 8'h0;
            latched_has_ec      <= 1'b0;
            latched_error_code  <= 32'h0;
            latched_need_switch <= 1'b0;
            latched_new_ss      <= 16'h0;
            latched_new_esp     <= 32'h0;
            tss_started_r       <= 1'b0;
        end else begin
            unique case (state)
                EIU_IDLE: begin
                    tss_started_r <= 1'b0;
                    if (pending_intr | pending_iret) begin
                        request_latched_r   <= 1'b1;
                        latched_is_iret     <= pending_iret;
                        latched_is_external <= pending_external;
                        latched_vector      <= pending_vector;
                        latched_has_ec      <= pending_has_ec;
                        latched_error_code  <= pending_error_code;
                        latched_need_switch <= 1'b0;
                        latched_new_ss      <= 16'h0;
                        latched_new_esp     <= 32'h0;
                        if (need_tss_fetch) begin
                            state <= EIU_TSS;
                        end else begin
                            state <= EIU_IDU;
                        end
                    end
                end
                EIU_TSS: begin
                    tss_started_r <= 1'b1;
                    if (tss_done) begin
                        latched_need_switch <= 1'b1;
                        latched_new_ss      <= tss_new_ss;
                        latched_new_esp     <= tss_new_esp;
                        state               <= EIU_IDU;
                    end
                end
                EIU_IDU: begin
                    if (idu_busy) begin
                        request_latched_r <= 1'b0;
                    end else if (~request_latched_r & ~idu_busy) begin
                        state <= EIU_IDLE;
                    end
                end
                default: state <= EIU_IDLE;
            endcase
        end
    end

    tss_privilege_stack u_tss_stack (
        .i_start            (tss_start),
        .i_tss_base         (i_tss_base),
        .i_target_cpl       (2'd0),
        .o_busy             (tss_busy),
        .o_done             (tss_done),
        .o_new_esp          (tss_new_esp),
        .o_new_ss           (tss_new_ss),
        .o_bus_valid        (tss_bus_valid),
        .i_bus_ready        (i_mem_ready & (state == EIU_TSS)),
        .o_bus_write_enable (tss_bus_we),
        .o_bus_address      (tss_bus_addr),
        .i_bus_data_read    (i_mem_rdata),
        .o_bus_data_write   (tss_bus_wdata),
        .clk                (clk),
        .rst_n              (rst_n)
    );

    interrupt_delivery_unit u_idu (
        .i_start                (idu_start),
        .i_is_iret              (latched_is_iret),
        .i_is_external          (latched_is_external),
        .i_vector               (latched_vector),
        .i_has_error_code       (latched_has_ec),
        .i_error_code           (latched_error_code),
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
        .i_need_stack_switch    (latched_need_switch),
        .i_new_ss               (latched_new_ss),
        .i_new_esp              (latched_new_esp),
        .i_current_ss           (i_current_ss_selector),
        .o_busy                 (idu_busy),
        .o_inta_req             (idu_inta_req),
        .o_done                 (),
        .o_flush_pipeline       (idu_flush),
        .o_clear_if             (idu_clear_if),
        .o_new_eip_valid        (idu_new_eip_valid),
        .o_new_eip              (idu_new_eip),
        .o_new_cs_valid         (idu_new_cs_valid),
        .o_new_cs_selector      (idu_new_cs_selector),
        .o_esp_write_enable     (idu_esp_we),
        .o_esp_write_data       (idu_esp_data),
        .o_eflags_write_enable  (idu_eflags_we),
        .o_eflags_write_data    (idu_eflags_data),
        .o_mem_valid            (idu_mem_valid),
        .i_mem_ready            (i_mem_ready & (state == EIU_IDU)),
        .o_mem_write_enable     (idu_mem_we),
        .o_mem_address          (idu_mem_addr),
        .o_mem_write_data       (idu_mem_wdata),
        .i_mem_rdata            (i_mem_rdata),
        .clk                    (clk),
        .rst_n                  (rst_n)
    );

    assign o_flush_pipeline       = (state != EIU_IDLE) | idu_flush;
    assign o_clear_if             = idu_clear_if;
    assign o_new_eip_valid        = idu_new_eip_valid;
    assign o_new_eip              = idu_new_eip;
    assign o_new_cs_valid         = idu_new_cs_valid;
    assign o_new_cs_selector      = idu_new_cs_selector;
    assign o_esp_write_enable     = idu_esp_we;
    assign o_esp_write_data       = idu_esp_data;
    assign o_eflags_write_enable  = idu_eflags_we;
    assign o_eflags_write_data    = idu_eflags_data;
    assign o_inta_req             = idu_inta_req;

    assign o_vector           = pending_vector;
    assign o_error_code_valid = pending_has_ec & pending_intr;
    assign o_error_code       = pending_error_code;
    assign o_ferr_n           = ~i_fpu_exception;

endmodule
