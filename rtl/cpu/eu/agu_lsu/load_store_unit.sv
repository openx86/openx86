/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements load_store_unit.
*/
// ============================================================================
// Load / Store Unit (LSU)
// 将执行侧访存请求转换为对总线/存储器端口的握手（valid/ready）
// ============================================================================

module load_store_unit (
    input  logic          i_start,  // 启动一次访存
    input  logic          i_is_store,  // 写访存
    input  logic [31: 0] i_addr,  // 访存地址
    input  logic [31: 0] i_wdata,  // 写数据

    output logic [31: 0] o_rdata,  // 读回数据
    output logic         o_done,  // 事务完成
    output logic         o_busy,  // 忙

    output logic         o_mem_valid,  // 存储器请求有效
    output logic         o_mem_we,  // 存储器写使能
    output logic [31: 0] o_mem_addr,  // 存储器地址
    output logic [31: 0] o_mem_wdata,  // 存储器写数据
    input  logic [31: 0] i_mem_rdata,  // 存储器读数据
    input  logic          i_mem_ready,  // 存储器就绪
    input  logic          clk,  // 时钟
    input  logic          rst_n  // 异步低有效复位
);

    typedef enum logic [ 1: 0] {
        S_IDLE,  // 空闲，可接收启动
        S_WAIT   // 已发请求，等待 mem_ready
    } lsu_state_e;

    lsu_state_e state;  // LSU 主状态

    // 组合逻辑：连续赋值
    assign o_busy = (state == S_WAIT) || (state == S_IDLE && i_start);

    // 时序逻辑：寄存器更新
    always_ff @(posedge clk) begin
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
            // 主状态机：空闲启动与等待就绪两相握手
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
