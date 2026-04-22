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
//  File        : load_store_unit.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : load_store_unit module
// ============================================================================

// ============================================================================
// Load / Store Unit (LSU)
// 将执行侧访存请求转换为对总线/存储器端口的握手（valid/ready）
// ============================================================================

module load_store_unit (
    // =========================
    // execution interface
    // =========================
    input  logic          i_start,
    input  logic          i_is_store,
    input  logic [31: 0] i_addr,
    input  logic [31: 0] i_wdata,

    output logic [31: 0] o_rdata,
    output logic         o_done,
    output logic         o_busy,

    // =========================
    // memory interface
    // =========================
    output logic         o_mem_valid,
    output logic         o_mem_we,
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

    // ============================================================
    // LSU state machine
    // ============================================================
    typedef enum logic [ 1: 0] {
        S_IDLE,
        S_WAIT
    } lsu_state_e;

    lsu_state_e state;

    // ============================================================
    // combinational logic: continuous assignment
    // ============================================================
    assign o_busy = (state == S_WAIT) || (state == S_IDLE && i_start);

    // ============================================================
    // sequential logic: register update
    // ============================================================
    always_ff @(posedge clk) begin : ff_lsu_state
        if (!rst_n) begin
            state     <= S_IDLE;
            o_done    <= 1'b0;
            o_rdata   <= 32'h0;
            o_mem_valid <= 1'b0;
            o_mem_we  <= 1'b0;
            o_mem_addr <= 32'h0;
            o_mem_wdata <= 32'h0;
        end else begin
            o_done <= 1'b0;
            // ============================================================
            // main state machine: idle start and wait ready two-phase handshake
            // ============================================================
            unique case (state)
                S_IDLE: begin
                    // 锁存地址/写数据并发起总线访问
                    if (i_start) begin
                        o_mem_addr   <= i_addr;
                        o_mem_wdata  <= i_wdata;
                        o_mem_we     <= i_is_store;
                        o_mem_valid  <= 1'b1;
                        state        <= S_WAIT;
                    end
                end
                S_WAIT: begin
                    // 从设备就绪：结束本次事务
                    if (i_mem_ready) begin
                        o_mem_valid <= 1'b0;
                        // 读路径才采样读数据
                        if (!o_mem_we)
                            o_rdata <= i_mem_rdata;
                        o_done  <= 1'b1;
                        state   <= S_IDLE;
                    end
                end
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
