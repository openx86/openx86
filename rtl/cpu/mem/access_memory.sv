/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements mem_access_memory.
*/
// MEM 子模块薄封装：将 stage_4 接口转发到 EXE 阶段 LSU，复用既有 load/store 时序
module mem_access_memory (
    input  logic          i_start,           // 启动访存
    input  logic          i_is_store,       // store/load 选择
    input  logic [31: 0] i_addr,            // 访存地址
    input  logic [31: 0] i_wdata,           // store 数据
    output logic [31: 0] o_rdata,           // load 结果
    output logic         o_done,            // 事务完成
    output logic         o_busy,            // 事务进行中
    output logic         o_mem_valid,       // 下游 mem 端口：请求有效
    output logic         o_mem_we,          // 下游 mem 端口：写使能
    output logic [31: 0] o_mem_addr,        // 下游 mem 端口：地址
    output logic [31: 0] o_mem_wdata,       // 下游 mem 端口：写数据
    input  logic [31: 0] i_mem_rdata,       // 下游 mem 端口：读数据
    input  logic          i_mem_ready,      // 下游 mem 端口：就绪
    input  logic          clk,
    input  logic          rst_n
);

    eu_agu_lsu_load_store_unit u_lsu (
        .clk ( clk ),
        .rst_n ( rst_n ),
        .i_start ( i_start ),
        .i_is_store ( i_is_store ),
        .i_addr ( i_addr ),
        .i_wdata ( i_wdata ),
        .o_rdata ( o_rdata ),
        .o_done ( o_done ),
        .o_busy ( o_busy ),
        .o_mem_valid ( o_mem_valid ),
        .o_mem_we ( o_mem_we ),
        .o_mem_addr ( o_mem_addr ),
        .o_mem_wdata ( o_mem_wdata ),
        .i_mem_rdata ( i_mem_rdata ),
        .i_mem_ready ( i_mem_ready )
    );

endmodule
