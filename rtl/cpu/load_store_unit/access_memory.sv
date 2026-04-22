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
    input  logic          i_start,          // 启动访存
    input  logic          i_is_store,       // store/load 选择
    input  logic [31: 0] i_addr,           // 访存地址
    input  logic [31: 0] i_wdata,          // store 数据
    output logic [31: 0] o_rdata,          // load 结果
    output logic          o_done,           // 事务完成
    output logic          o_busy,           // 事务进行中
    output logic          o_mem_valid,      // 下游 memory 端口：请求有效
    output logic          o_mem_we,         // 下游 memory 端口：写使能
    output logic [31: 0] o_mem_addr,       // 下游 memory 端口：地址
    output logic [31: 0] o_mem_wdata,      // 下游 memory 端口：写数据
    input  logic [31: 0] i_mem_rdata,      // 下游 memory 端口：读数据
    input  logic          i_mem_ready,      // 下游 memory 端口：就绪
    input  logic          clk,              // 时钟信号
    input  logic          rst_n             // 复位信号
);

    typedef enum logic [1: 0] {
        S_IDLE,
        S_WAIT
    } am_state_e;

    am_state_e state;

    assign o_busy = (state == S_WAIT) || ((state == S_IDLE) && i_start);

    // 时序逻辑块：将 MEM 子模块保持为独立可综合状态机，不跨目录实例化 LSU。
    always_ff @(posedge clk or negedge rst_n) begin
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
                        state  <= S_IDLE;
                    end
                end
                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule
