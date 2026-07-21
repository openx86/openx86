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
//  File        : interrupt_delivery_unit.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : x86 interrupt/exception delivery FSM with IDT/IVT gate fetch
//                and stack frame push/pop (32-bit PM / 16-bit real mode)
// ============================================================================

`include "openx86_defs.h.sv"

module interrupt_delivery_unit (
    input  logic         i_start,
    input  logic         i_is_iret,
    input  logic         i_is_external,
    input  logic [ 7: 0] i_vector,
    input  logic         i_has_error_code,
    input  logic [31: 0] i_error_code,
    input  logic [31: 0] i_saved_eip,
    input  logic [15: 0] i_saved_cs_selector,
    input  logic [31: 0] i_saved_eflags,
    input  logic [31: 0] i_saved_esp,
    input  logic [31: 0] i_idtr_base,
    input  logic [15: 0] i_idtr_limit,
    input  logic         i_protected_mode,
    input  logic [31: 0] i_ss_base,
    input  logic         i_inta_vector_valid,
    input  logic [ 7: 0] i_inta_vector,
    input  logic [ 1: 0] i_cpl,
    input  logic [ 1: 0] i_gate_dpl,
    input  logic         i_need_stack_switch,
    input  logic [15: 0] i_new_ss,
    input  logic [31: 0] i_new_esp,
    input  logic [15: 0] i_current_ss,
    output logic         o_busy,
    output logic         o_inta_req,
    output logic         o_done,
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
    output logic         o_mem_valid,
    input  logic         i_mem_ready,
    output logic         o_mem_write_enable,
    output logic [ 1: 0] o_mem_size,
    output logic [31: 0] o_mem_address,
    output logic [31: 0] o_mem_write_data,
    input  logic [31: 0] i_mem_rdata,
    input  logic         clk,
    input  logic         rst_n
);

    typedef enum logic [ 3: 0] {
        S_IDLE,
        S_INTA,
        S_RD_GATE_LO,
        S_RD_GATE_HI,
        S_PUSH_OLD_SS,
        S_PUSH_OLD_ESP,
        S_PUSH_EFLAGS,
        S_PUSH_CS,
        S_PUSH_EIP,
        S_PUSH_ERR,
        S_COMMIT,
        S_IRET_POP_EIP,
        S_IRET_POP_CS,
        S_IRET_POP_EFLAGS,
        S_IRET_COMMIT
    } idu_state_t;

    idu_state_t state;

    logic [ 7: 0] vector_r;
    logic         has_error_r;
    logic [31: 0] error_code_r;
    logic [31: 0] saved_eip_r;
    logic [15: 0] saved_cs_r;
    logic [31: 0] saved_eflags_r;
    logic [31: 0] saved_esp_r;
    logic [31: 0] esp_r;
    logic [31: 0] ss_base_r;
    logic         pm_r;
    logic [31: 0] gate_lo_r;
    logic [31: 0] gate_hi_r;
    logic [31: 0] iret_eip_r;
    logic [15: 0] iret_cs_r;
    logic [31: 0] iret_eflags_r;
    logic         idt_fault_r;
    logic         need_stack_switch_r;
    logic [15: 0] old_ss_r;
    logic [31: 0] old_esp_r;
    logic [ 1: 0] cpl_r;
    logic [ 1: 0] gate_dpl_r;
    logic [15: 0] new_ss_r;

    logic [ 7: 0] gate_access;
    logic [ 3: 0] gate_type;
    logic [31: 0] gate_offset;
    logic [15: 0] gate_selector;
    logic         clear_if;
    logic [31: 0] stack_delta;
    logic [31: 0] stack_lin;
    logic [ 1: 0] stack_size;
    logic [31: 0] push_wdata_flags;
    logic [31: 0] push_wdata_cs;
    logic [31: 0] push_wdata_ip;
    logic [31: 0] gate_addr_c;
    logic [31: 0] stack_lane_rdata;
    logic         mem_issue_r;

    // Real mode: IVT entry = idtr_base + vector*4; Protected: IDT gate = base + vector*8
    assign gate_addr_c = pm_r ?
                         (i_idtr_base + {21'd0, vector_r, 3'b000}) :
                         (i_idtr_base + {22'd0, vector_r, 2'b00});
    assign gate_access   = gate_hi_r[15: 8];
    assign gate_type     = gate_access[3: 0];
    assign gate_offset   = pm_r ?
                           {gate_hi_r[31: 16], gate_lo_r[15: 0]} :
                           {16'h0, gate_lo_r[15: 0]};
    assign gate_selector = gate_lo_r[31: 16];
    assign clear_if      = pm_r ?
                           ((gate_type == 4'hE) | (gate_type == 4'h6)) :
                           1'b1;
    assign stack_delta   = pm_r ? 32'd4 : 32'd2;
    assign stack_size    = pm_r ? 2'b10 : 2'b01;
    // Real mode: linear = SS.base + SP; PM: ESP is already a flat linear address
    assign stack_lin     = pm_r ? esp_r : (ss_base_r + {16'h0, esp_r[15: 0]});
    assign push_wdata_flags = pm_r ? saved_eflags_r : {16'h0, saved_eflags_r[15: 0]};
    assign push_wdata_cs    = {16'h0, saved_cs_r};
    assign push_wdata_ip    = pm_r ? saved_eip_r : {16'h0, saved_eip_r[15: 0]};
    // Cache/BIU return aligned dword; extract halfword/byte from EA[1:0]
    assign stack_lane_rdata = (stack_lin[1: 0] == 2'b10) ?
                              {16'h0, i_mem_rdata[31: 16]} :
                              (stack_lin[1: 0] == 2'b01) ?
                              { 8'h0, i_mem_rdata[31:  8]} :
                              (stack_lin[1: 0] == 2'b11) ?
                              {24'h0, i_mem_rdata[31: 24]} :
                              i_mem_rdata;
    assign o_busy           = (state != S_IDLE);
    assign o_flush_pipeline = (state != S_IDLE);
    assign o_inta_req       = (state == S_INTA);

    always_ff @(posedge clk or negedge rst_n) begin : ff_idu_fsm
        if (~rst_n) begin
            state                  <= S_IDLE;
            vector_r               <= 8'h0;
            has_error_r            <= 1'b0;
            error_code_r           <= 32'h0;
            saved_eip_r            <= 32'h0;
            saved_cs_r             <= 16'h0;
            saved_eflags_r         <= 32'h0;
            esp_r                  <= 32'h0;
            ss_base_r              <= 32'h0;
            pm_r                   <= 1'b0;
            gate_lo_r              <= 32'h0;
            gate_hi_r              <= 32'h0;
            iret_eip_r             <= 32'h0;
            iret_cs_r              <= 16'h0;
            iret_eflags_r          <= 32'h0;
            idt_fault_r            <= 1'b0;
            need_stack_switch_r    <= 1'b0;
            old_ss_r               <= 16'h0;
            old_esp_r              <= 32'h0;
            saved_esp_r            <= 32'h0;
            cpl_r                  <= 2'b00;
            gate_dpl_r             <= 2'b00;
            new_ss_r               <= 16'h0;
            o_done                 <= 1'b0;
            o_clear_if             <= 1'b0;
            o_new_eip_valid        <= 1'b0;
            o_new_eip              <= 32'h0;
            o_new_cs_valid         <= 1'b0;
            o_new_cs_selector      <= 16'h0;
            o_esp_write_enable     <= 1'b0;
            o_esp_write_data       <= 32'h0;
            o_eflags_write_enable  <= 1'b0;
            o_eflags_write_data    <= 32'h0;
            o_mem_valid            <= 1'b0;
            o_mem_write_enable     <= 1'b0;
            o_mem_size             <= 2'b10;
            o_mem_address          <= 32'h0;
            o_mem_write_data       <= 32'h0;
            mem_issue_r            <= 1'b0;
        end else begin
            o_done                <= 1'b0;
            o_clear_if            <= 1'b0;
            o_new_eip_valid       <= 1'b0;
            o_new_cs_valid        <= 1'b0;
            o_esp_write_enable    <= 1'b0;
            o_eflags_write_enable <= 1'b0;
            o_mem_valid           <= 1'b0;
            o_mem_size            <= 2'b10;

            unique case (state)
                S_IDLE: begin
                    mem_issue_r <= 1'b0;
                    if (i_start) begin
                        vector_r            <= i_vector;
                        has_error_r         <= i_has_error_code;
                        error_code_r        <= i_error_code;
                        saved_eip_r         <= i_saved_eip;
                        saved_cs_r          <= i_saved_cs_selector;
                        saved_eflags_r      <= i_saved_eflags;
                        saved_esp_r         <= i_saved_esp;
                        ss_base_r           <= i_ss_base;
                        pm_r                <= i_protected_mode;
                        need_stack_switch_r <= i_need_stack_switch & i_protected_mode;
                        old_esp_r           <= i_saved_esp;
                        old_ss_r            <= i_current_ss;
                        cpl_r               <= i_cpl;
                        gate_dpl_r          <= i_gate_dpl;
                        new_ss_r            <= i_new_ss;
                        if (i_need_stack_switch & i_protected_mode) begin
                            esp_r <= i_new_esp;
                        end else begin
                            esp_r <= i_saved_esp;
                        end
                        idt_fault_r <= 1'b0;
                        if (i_is_iret) begin
                            state <= S_IRET_POP_EIP;
                        end else if (i_is_external) begin
                            state <= S_INTA;
                        end else if (i_protected_mode ?
                                     (({21'd0, i_vector, 3'b000} + 32'd7) > {16'd0, i_idtr_limit}) :
                                     (({22'd0, i_vector, 2'b00} + 32'd3) > {16'd0, i_idtr_limit})) begin
                            idt_fault_r <= 1'b1;
                            state       <= S_COMMIT;
                        end else begin
                            state <= S_RD_GATE_LO;
                        end
                    end
                end
                S_INTA: begin
                    if (i_inta_vector_valid) begin
                        vector_r <= i_inta_vector;
                        if (pm_r ?
                            (({21'd0, i_inta_vector, 3'b000} + 32'd7) > {16'd0, i_idtr_limit}) :
                            (({22'd0, i_inta_vector, 2'b00} + 32'd3) > {16'd0, i_idtr_limit})) begin
                            idt_fault_r <= 1'b1;
                            state       <= S_COMMIT;
                        end else begin
                            state <= S_RD_GATE_LO;
                        end
                    end
                end
                S_RD_GATE_LO: begin
                    o_mem_valid        <= 1'b1;
                    o_mem_write_enable <= 1'b0;
                    o_mem_size         <= 2'b10;
                    o_mem_address      <= gate_addr_c;
                    if (mem_issue_r & i_mem_ready) begin
                        gate_lo_r   <= i_mem_rdata;
                        mem_issue_r <= 1'b0;
                        if (~pm_r) begin
                            gate_hi_r <= 32'h0;
                            esp_r     <= esp_r - stack_delta;
                            state     <= S_PUSH_EFLAGS;
                        end else begin
                            state <= S_RD_GATE_HI;
                        end
                    end else begin
                        mem_issue_r <= 1'b1;
                    end
                end
                S_RD_GATE_HI: begin
                    o_mem_valid        <= 1'b1;
                    o_mem_write_enable <= 1'b0;
                    o_mem_size         <= 2'b10;
                    o_mem_address      <= gate_addr_c + 32'd4;
                    if (mem_issue_r & i_mem_ready) begin
                        gate_hi_r   <= i_mem_rdata;
                        mem_issue_r <= 1'b0;
                        if (need_stack_switch_r) begin
                            esp_r <= esp_r - stack_delta;
                            state <= S_PUSH_OLD_SS;
                        end else begin
                            esp_r <= esp_r - stack_delta;
                            state <= S_PUSH_EFLAGS;
                        end
                    end else begin
                        mem_issue_r <= 1'b1;
                    end
                end
                S_PUSH_OLD_SS: begin
                    o_mem_valid        <= 1'b1;
                    o_mem_write_enable <= 1'b1;
                    o_mem_size         <= stack_size;
                    o_mem_address      <= stack_lin;
                    o_mem_write_data   <= {16'h0, old_ss_r};
                    if (mem_issue_r & i_mem_ready) begin
                        esp_r       <= esp_r - stack_delta;
                        state       <= S_PUSH_OLD_ESP;
                        mem_issue_r <= 1'b0;
                    end else begin
                        mem_issue_r <= 1'b1;
                    end
                end
                S_PUSH_OLD_ESP: begin
                    o_mem_valid        <= 1'b1;
                    o_mem_write_enable <= 1'b1;
                    o_mem_size         <= stack_size;
                    o_mem_address      <= stack_lin;
                    o_mem_write_data   <= old_esp_r;
                    if (mem_issue_r & i_mem_ready) begin
                        esp_r       <= esp_r - stack_delta;
                        state       <= S_PUSH_EFLAGS;
                        mem_issue_r <= 1'b0;
                    end else begin
                        mem_issue_r <= 1'b1;
                    end
                end
                S_PUSH_EFLAGS: begin
                    o_mem_valid        <= 1'b1;
                    o_mem_write_enable <= 1'b1;
                    o_mem_size         <= stack_size;
                    o_mem_address      <= stack_lin;
                    o_mem_write_data   <= push_wdata_flags;
                    if (mem_issue_r & i_mem_ready) begin
                        esp_r       <= esp_r - stack_delta;
                        state       <= S_PUSH_CS;
                        mem_issue_r <= 1'b0;
                    end else begin
                        mem_issue_r <= 1'b1;
                    end
                end
                S_PUSH_CS: begin
                    o_mem_valid        <= 1'b1;
                    o_mem_write_enable <= 1'b1;
                    o_mem_size         <= stack_size;
                    o_mem_address      <= stack_lin;
                    o_mem_write_data   <= push_wdata_cs;
                    if (mem_issue_r & i_mem_ready) begin
                        esp_r       <= esp_r - stack_delta;
                        state       <= S_PUSH_EIP;
                        mem_issue_r <= 1'b0;
                    end else begin
                        mem_issue_r <= 1'b1;
                    end
                end
                S_PUSH_EIP: begin
                    o_mem_valid        <= 1'b1;
                    o_mem_write_enable <= 1'b1;
                    o_mem_size         <= stack_size;
                    o_mem_address      <= stack_lin;
                    o_mem_write_data   <= push_wdata_ip;
                    if (mem_issue_r & i_mem_ready) begin
                        mem_issue_r <= 1'b0;
                        if (has_error_r & pm_r) begin
                            esp_r <= esp_r - stack_delta;
                            state <= S_PUSH_ERR;
                        end else begin
                            state <= S_COMMIT;
                        end
                    end else begin
                        mem_issue_r <= 1'b1;
                    end
                end
                S_PUSH_ERR: begin
                    o_mem_valid        <= 1'b1;
                    o_mem_write_enable <= 1'b1;
                    o_mem_size         <= 2'b10;
                    o_mem_address      <= stack_lin;
                    o_mem_write_data   <= error_code_r;
                    if (mem_issue_r & i_mem_ready) begin
                        state       <= S_COMMIT;
                        mem_issue_r <= 1'b0;
                    end else begin
                        mem_issue_r <= 1'b1;
                    end
                end
                S_COMMIT: begin
                    mem_issue_r           <= 1'b0;
                    o_esp_write_enable    <= ~idt_fault_r;
                    o_esp_write_data      <= esp_r;
                    o_new_eip_valid       <= 1'b1;
                    o_new_cs_valid        <= ~idt_fault_r;
                    o_clear_if            <= clear_if & ~idt_fault_r;
                    if (idt_fault_r) begin
                        o_new_eip         <= 32'hFFFF_FFF0;
                        o_new_cs_selector <= 16'h0;
                    end else begin
                        o_new_eip         <= gate_offset;
                        o_new_cs_selector <= gate_selector;
                    end
                    o_done <= 1'b1;
                    state  <= S_IDLE;
                end
                S_IRET_POP_EIP: begin
                    o_mem_valid        <= 1'b1;
                    o_mem_write_enable <= 1'b0;
                    o_mem_size         <= stack_size;
                    o_mem_address      <= stack_lin;
                    if (mem_issue_r & i_mem_ready) begin
                        iret_eip_r  <= pm_r ? i_mem_rdata : {16'h0, stack_lane_rdata[15: 0]};
                        esp_r       <= esp_r + stack_delta;
                        state       <= S_IRET_POP_CS;
                        mem_issue_r <= 1'b0;
                    end else begin
                        mem_issue_r <= 1'b1;
                    end
                end
                S_IRET_POP_CS: begin
                    o_mem_valid        <= 1'b1;
                    o_mem_write_enable <= 1'b0;
                    o_mem_size         <= stack_size;
                    o_mem_address      <= stack_lin;
                    if (mem_issue_r & i_mem_ready) begin
                        iret_cs_r   <= stack_lane_rdata[15: 0];
                        esp_r       <= esp_r + stack_delta;
                        state       <= S_IRET_POP_EFLAGS;
                        mem_issue_r <= 1'b0;
                    end else begin
                        mem_issue_r <= 1'b1;
                    end
                end
                S_IRET_POP_EFLAGS: begin
                    o_mem_valid        <= 1'b1;
                    o_mem_write_enable <= 1'b0;
                    o_mem_size         <= stack_size;
                    o_mem_address      <= stack_lin;
                    if (mem_issue_r & i_mem_ready) begin
                        iret_eflags_r <= pm_r ? i_mem_rdata :
                                         {16'h0, stack_lane_rdata[15: 0]};
                        esp_r         <= esp_r + stack_delta;
                        state         <= S_IRET_COMMIT;
                        mem_issue_r   <= 1'b0;
                    end else begin
                        mem_issue_r <= 1'b1;
                    end
                end
                S_IRET_COMMIT: begin
                    mem_issue_r           <= 1'b0;
                    o_new_eip_valid       <= 1'b1;
                    o_new_eip             <= iret_eip_r;
                    o_new_cs_valid        <= 1'b1;
                    o_new_cs_selector     <= iret_cs_r;
                    o_eflags_write_enable <= 1'b1;
                    o_eflags_write_data   <= iret_eflags_r;
                    o_esp_write_enable    <= 1'b1;
                    o_esp_write_data      <= esp_r;
                    o_done                <= 1'b1;
                    state                 <= S_IDLE;
                end
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
