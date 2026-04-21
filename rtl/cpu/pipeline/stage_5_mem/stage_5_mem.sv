/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: stage_5_mem wrapper for EXE->MEM->WRB memory path handshake.
*/
// ============================================================================
// stage_5_mem
// ----------------------------------------------------------------------------
// Stage 5 MEM:
// - bridges EXE LSU request through exe_to_mem boundary
// - executes access in memory_stage
// - forwards commit-side mem bundle through mem_to_wrb boundary
// ============================================================================

module stage_5_mem (
    input  logic          i_stage3_valid, // 输入信号
    output logic          o_stage3_ready, // 输出信号

    input  logic          i_start, // 输入信号
    input  logic          i_is_store, // 输入信号
    input  logic [31: 0]  i_addr, // 输入信号
    input  logic [31: 0]  i_wdata, // 输入信号

    input  logic [31: 0]  i_mem_rdata, // 输入信号
    input  logic          i_mem_ready, // 输入信号

    output logic [31: 0]  o_lsu_rdata, // 输出信号
    output logic          o_lsu_done, // 输出信号
    output logic          o_lsu_busy, // 输出信号

    output logic          o_stage4_valid, // 输出信号
    input  logic          i_wrb_ready, // 输入信号
    output logic          o_mem_valid, // 输出信号
    output logic          o_mem_write_enable, // 输出信号
    output logic [31: 0]  o_mem_address, // 输出信号
    output logic [31: 0]  o_mem_write_data, // 输出信号

    input  logic          i_flush, // 输入信号
    input  logic          clk, // 时钟信号
    input  logic          rst_n // 复位信号
);

    logic        s34_stage3_valid;
    logic        s34_start;
    logic        s34_is_store;
    logic [31: 0] s34_addr;
    logic [31: 0] s34_wdata;
    logic [31: 0] s34_mem_rdata;
    logic        s34_mem_ready;
    logic        s34_stage_ready;

    logic        stage4_valid_from_mem;
    logic        mem_valid_from_mem;
    logic        mem_write_enable_from_mem;
    logic [31: 0] mem_address_from_mem;
    logic [31: 0] mem_write_data_from_mem;

    exe_to_mem u_stage_4_mem_exe_to_mem (
        .i_stage3_valid    ( i_stage3_valid ),
        .o_stage3_valid    ( s34_stage3_valid ),
        .i_mem_stage_ready ( s34_stage_ready ),
        .o_exe_ready       ( ),
        .i_start           ( i_start ),
        .o_start           ( s34_start ),
        .i_is_store        ( i_is_store ),
        .o_is_store        ( s34_is_store ),
        .i_addr            ( i_addr ),
        .o_addr            ( s34_addr ),
        .i_wdata           ( i_wdata ),
        .o_wdata           ( s34_wdata ),
        .i_mem_rdata       ( i_mem_rdata ),
        .o_mem_rdata       ( s34_mem_rdata ),
        .i_mem_ready       ( i_mem_ready ),
        .o_mem_ready       ( s34_mem_ready ),
        .i_flush           ( i_flush ),
        .clk               ( clk ),
        .rst_n             ( rst_n )
    );

    memory_stage u_stage_4_mem_main (
        .i_stage3_valid ( s34_stage3_valid ),
        .o_stage_valid  ( stage4_valid_from_mem ),
        .o_stage_ready  ( s34_stage_ready ),
        .i_start        ( s34_start ),
        .i_is_store     ( s34_is_store ),
        .i_addr         ( s34_addr ),
        .i_wdata        ( s34_wdata ),
        .o_rdata        ( o_lsu_rdata ),
        .o_done         ( o_lsu_done ),
        .o_busy         ( o_lsu_busy ),
        .o_mem_valid    ( mem_valid_from_mem ),
        .o_mem_we       ( mem_write_enable_from_mem ),
        .o_mem_addr     ( mem_address_from_mem ),
        .o_mem_wdata    ( mem_write_data_from_mem ),
        .i_mem_rdata    ( s34_mem_rdata ),
        .i_mem_ready    ( s34_mem_ready ),
        .clk            ( clk ),
        .rst_n          ( rst_n )
    );

    mem_to_wrb u_stage_4_mem_to_wrb (
        .i_stage4_valid      ( stage4_valid_from_mem ),
        .o_stage4_valid      ( o_stage4_valid ),
        .i_wrb_ready         ( i_wrb_ready ),
        .o_mem_ready         ( ),
        .i_mem_valid         ( mem_valid_from_mem ),
        .o_mem_valid         ( o_mem_valid ),
        .i_mem_write_enable  ( mem_write_enable_from_mem ),
        .o_mem_write_enable  ( o_mem_write_enable ),
        .i_mem_address       ( mem_address_from_mem ),
        .o_mem_address       ( o_mem_address ),
        .i_mem_write_data    ( mem_write_data_from_mem ),
        .o_mem_write_data    ( o_mem_write_data ),
        .i_flush             ( i_flush ),
        .clk                 ( clk ),
        .rst_n               ( rst_n )
    );

    assign o_stage3_ready = s34_stage_ready;

endmodule
