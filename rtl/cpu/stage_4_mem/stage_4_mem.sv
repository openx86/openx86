/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_4_mem.
*/
// ============================================================================
// stage_4_mem
// ----------------------------------------------------------------------------
// Stage 4 (MEM / memory): wraps LSU memory access sequencing.
// ============================================================================

module stage_4_mem (
    input  logic          i_stage3_valid,   // 上游 EXE 阶段有效（与 MEM 流水对齐）
    output logic         o_stage_valid,    // 本阶段对外有效（busy 或 done 时保持传递）

    input  logic          i_start,          // 启动一次 LSU 访存
    input  logic          i_is_store,       // 1=写（store），0=读（load）
    input  logic [31: 0] i_addr,            // 访存线性/物理地址（由上游约定）
    input  logic [31: 0] i_wdata,           // store 写数据
    output logic [31: 0] o_rdata,           // load 读回数据
    output logic         o_done,            // 本次访存完成
    output logic         o_busy,            // 访存进行中（占用下游）
    output logic         o_mem_valid,       // 对内存子系统：请求有效
    output logic         o_mem_we,          // 对内存子系统：写使能
    output logic [31: 0] o_mem_addr,        // 对内存子系统：地址
    output logic [31: 0] o_mem_wdata,       // 对内存子系统：写数据
    input  logic [31: 0] i_mem_rdata,       // 从内存子系统读回
    input  logic          i_mem_ready,      // 内存子系统就绪/完成握手
    input  logic          clk,
    input  logic          rst
);

    // 委托 LSU 时序与下游 mem 接口细节
    stage_4_mem_access_memory u_am_access_memory (
        .clk         ( clk ),
        .rst         ( rst ),
        .i_start     ( i_start ),
        .i_is_store  ( i_is_store ),
        .i_addr      ( i_addr ),
        .i_wdata     ( i_wdata ),
        .o_rdata     ( o_rdata ),
        .o_done      ( o_done ),
        .o_busy      ( o_busy ),
        .o_mem_valid ( o_mem_valid ),
        .o_mem_we    ( o_mem_we ),
        .o_mem_addr  ( o_mem_addr ),
        .o_mem_wdata ( o_mem_wdata ),
        .i_mem_rdata ( i_mem_rdata ),
        .i_mem_ready ( i_mem_ready )
    );

    // MEM 段有效：上游有效且本次事务已发起或已结束（与 busy/done 组合避免气泡丢失）
    assign o_stage_valid = i_stage3_valid & (o_busy | o_done);

endmodule
