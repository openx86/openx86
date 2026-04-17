/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_4_mem_access_memory.
*/
module stage_4_mem_access_memory (
    input  logic        clk,
    input  logic        rst,
    input  logic        i_start,
    input  logic        i_is_store,
    input  logic [31:0] i_addr,
    input  logic [31:0] i_wdata,
    output logic [31:0] o_rdata,
    output logic        o_done,
    output logic        o_busy,
    output logic        o_mem_valid,
    output logic        o_mem_we,
    output logic [31:0] o_mem_addr,
    output logic [31:0] o_mem_wdata,
    input  logic [31:0] i_mem_rdata,
    input  logic        i_mem_ready
);

    stage_3_exe_load_store_unit u_lsu (
        .clk ( clk ),
        .rst ( rst ),
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
