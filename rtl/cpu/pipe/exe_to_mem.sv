/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: pipeline_boundary — combinational bridge from EXE stage to MEM (LSU) inputs.
*/
// ============================================================================
// pipeline_boundary
// ----------------------------------------------------------------------------
// Passes EXE valid and LSU request / memory return paths into memory_stage.
// ============================================================================

module exe_to_mem (
    input  logic          i_stage3_valid, // 输入信号
    output logic         o_stage3_valid, // 输出信号
    input  logic          i_mem_stage_ready, // 输入信号
    output logic         o_exe_ready, // 输出信号
    input  logic          i_start, // 输入信号
    output logic         o_start, // 输出信号
    input  logic          i_is_store, // 输入信号
    output logic         o_is_store, // 输出信号
    input  logic [31: 0] i_addr, // 输入信号
    output logic [31: 0] o_addr, // 输出信号
    input  logic [31: 0] i_wdata, // 输入信号
    output logic [31: 0] o_wdata, // 输出信号
    input  logic [31: 0] i_mem_rdata, // 输入信号
    output logic [31: 0] o_mem_rdata, // 输出信号
    input  logic          i_mem_ready, // 输入信号
    output logic         o_mem_ready, // 输出信号
    input  logic          i_flush, // 输入信号
    input  logic          clk, // 时钟信号
    input  logic          rst_n // 复位信号
);

`include "cpu/pipeline/pipeline_types.svh"

    exe_to_mem_t payload_in;
    exe_to_mem_t payload_out;
    logic [$bits(exe_to_mem_t) - 1: 0] payload_in_bits;
    logic [$bits(exe_to_mem_t) - 1: 0] payload_out_bits;
    logic        vld_out;
    logic        rdy_in;

    // 组合逻辑块
    always_comb begin
        payload_in.start     = i_start;
        payload_in.is_store  = i_is_store;
        payload_in.addr      = i_addr;
        payload_in.wdata     = i_wdata;
        payload_in.mem_rdata = i_mem_rdata;
        payload_in.mem_ready = i_mem_ready;
    end

    assign payload_in_bits = payload_in;
    assign payload_out     = payload_out_bits;

    pipeline_reg #(
        .P_DATA_WIDTH ( $bits(exe_to_mem_t) )
    ) u_exe_to_mem_reg (
        .i_flush   ( i_flush ),
        .i_valid   ( i_stage3_valid ),
        .o_ready   ( rdy_in ),
        .i_payload ( payload_in_bits ),
        .o_valid   ( vld_out ),
        .i_ready   ( i_mem_stage_ready ),
        .o_payload ( payload_out_bits ),
        .clk       ( clk ),
        .rst_n     ( rst_n )
    );

    assign o_exe_ready    = rdy_in;
    assign o_stage3_valid = vld_out;

    assign o_start     = payload_out.start;
    assign o_is_store  = payload_out.is_store;
    assign o_addr      = payload_out.addr;
    assign o_wdata     = payload_out.wdata;
    assign o_mem_rdata = payload_out.mem_rdata;
    assign o_mem_ready = payload_out.mem_ready;

endmodule
