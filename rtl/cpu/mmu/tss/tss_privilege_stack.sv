// ============================================================================
// Copyright (c) 2026 Chang Wei
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
// File : tss_privilege_stack.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : Read SS:ESP for CPL target from 386 TSS privilege stack fields
// ============================================================================

`include "openx86_defs.h.sv"

module tss_privilege_stack (
    input  logic         i_start,
    input  logic [31: 0] i_tss_base,
    input  logic [ 1: 0] i_target_cpl,
    output logic         o_busy,
    output logic         o_done,
    output logic [31: 0] o_new_esp,
    output logic [15: 0] o_new_ss,
    output logic         o_bus_valid,
    input  logic         i_bus_ready,
    output logic         o_bus_write_enable,
    output logic [31: 0] o_bus_address,
    input  logic [31: 0] i_bus_data_read,
    output logic [31: 0] o_bus_data_write,
    input  logic         clk,
    input  logic         rst_n
);

    // 386 TSS layout: ESP0@+4, SS0@+8, ESP1@+12, SS1@+16, ESP2@+20, SS2@+24
    typedef enum logic [ 2: 0] {
        S_IDLE,
        S_RD_ESP,
        S_RD_ESP_WAIT,
        S_RD_SS,
        S_RD_SS_WAIT,
        S_DONE
    } tss_stack_state_t;

    tss_stack_state_t state;
    logic [31: 0] esp_r;
    logic [15: 0] ss_r;
    logic [31: 0] esp_addr;
    logic [31: 0] ss_addr;

    always_comb begin
        unique case (i_target_cpl)
            2'd0: begin
                esp_addr = i_tss_base + 32'd4;
                ss_addr  = i_tss_base + 32'd8;
            end
            2'd1: begin
                esp_addr = i_tss_base + 32'd12;
                ss_addr  = i_tss_base + 32'd16;
            end
            default: begin
                esp_addr = i_tss_base + 32'd20;
                ss_addr  = i_tss_base + 32'd24;
            end
        endcase
    end

    assign o_busy             = (state != S_IDLE) & (state != S_DONE);
    assign o_bus_write_enable = 1'b0;
    assign o_bus_data_write   = 32'h0;
    assign o_new_esp          = esp_r;
    assign o_new_ss           = ss_r;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state       <= S_IDLE;
            esp_r       <= 32'h0;
            ss_r        <= 16'h0;
            o_done      <= 1'b0;
            o_bus_valid <= 1'b0;
            o_bus_address <= 32'h0;
        end else begin
            o_done      <= 1'b0;
            o_bus_valid <= 1'b0;
            unique case (state)
                S_IDLE: begin
                    if (i_start) begin
                        state <= S_RD_ESP;
                    end
                end
                S_RD_ESP: begin
                    o_bus_valid   <= 1'b1;
                    o_bus_address <= esp_addr;
                    state         <= S_RD_ESP_WAIT;
                end
                S_RD_ESP_WAIT: begin
                    if (i_bus_ready) begin
                        esp_r <= i_bus_data_read;
                        state <= S_RD_SS;
                    end
                end
                S_RD_SS: begin
                    o_bus_valid   <= 1'b1;
                    o_bus_address <= ss_addr;
                    state         <= S_RD_SS_WAIT;
                end
                S_RD_SS_WAIT: begin
                    if (i_bus_ready) begin
                        ss_r  <= i_bus_data_read[15: 0];
                        state <= S_DONE;
                    end
                end
                S_DONE: begin
                    o_done <= 1'b1;
                    state  <= S_IDLE;
                end
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
