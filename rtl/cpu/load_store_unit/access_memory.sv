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
//  File        : access_memory.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : access_memory module
// ============================================================================

// MEM 子模块薄封装：将 stage_4 接口转发到 EXE 阶段 LSU，复用既有 load/store 时序

module access_memory (
    // =========================
    // access interface
    // =========================
    input  logic          i_start,
    input  logic          i_is_store,
    input  logic [31: 0] i_addr,
    input  logic [31: 0] i_wdata,
    output logic [31: 0] o_rdata,
    output logic          o_done,
    output logic          o_busy,
    // =========================
    // downstream memory port
    // =========================
    output logic          o_mem_valid,
    output logic          o_mem_we,
    output logic [31: 0] o_mem_addr,
    output logic [31: 0] o_mem_wdata,
    input  logic [31: 0] i_mem_rdata,
    input  logic          i_mem_ready,
    // =========================
    // clock and reset
    // =========================
    input  logic          clk,
    input  logic          rst_n
);

    typedef enum logic [1: 0] {
        S_IDLE,
        S_WAIT,
        S_COOLDOWN
    } am_state_e;

    am_state_e state;

    assign o_busy = (state == S_WAIT) || (state == S_COOLDOWN) ||
                    ((state == S_IDLE) && i_start);

    always_ff @(posedge clk or negedge rst_n) begin : ff_access_memory
        if (~rst_n) begin
            state        <= S_IDLE;
            o_done       <= 1'b0;
            o_rdata      <= 32'h0;
            o_mem_valid  <= 1'b0;
            o_mem_we     <= 1'b0;
            o_mem_addr   <= 32'h0;
            o_mem_wdata  <= 32'h0;
        end else begin
            o_done <= 1'b0;
            unique case (state)
                S_IDLE: begin
                    if (i_start) begin
                        o_mem_addr   <= i_addr;
                        o_mem_wdata  <= i_wdata;
                        o_mem_we     <= i_is_store;
                        o_mem_valid  <= 1'b1;
                        state        <= S_WAIT;
                    end
                end
                S_WAIT: begin
                    if (i_mem_ready) begin
                        o_mem_valid <= 1'b0;
                        if (~o_mem_we) begin
                            o_rdata <= i_mem_rdata;
                        end
                        o_done <= 1'b1;
                        // Require start to fall before the next accept so a
                        // level-held master cannot immediately re-fire.
                        state  <= S_COOLDOWN;
                    end
                end
                S_COOLDOWN: begin
                    if (~i_start)
                        state <= S_IDLE;
                end
                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule
