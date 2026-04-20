/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: pipeline_boundary — combinational bridge from MEM LSU outputs to WRB inputs.
*/
// ============================================================================
// pipeline_boundary
// ----------------------------------------------------------------------------
// Passes MEM stage valid and data-bus request bundle into write_back_stage.
// ============================================================================

module mem_to_wrb (
    input  logic          i_stage4_valid, // 输入信号
    output logic         o_stage4_valid, // 输出信号
    input  logic          i_wrb_ready, // 输入信号
    output logic         o_mem_ready, // 输出信号
    input  logic          i_mem_valid, // 输入信号
    output logic         o_mem_valid, // 输出信号
    input  logic          i_mem_write_enable, // 输入信号
    output logic         o_mem_write_enable, // 输出信号
    input  logic [31: 0] i_mem_address, // 输入信号
    output logic [31: 0] o_mem_address, // 输出信号
    input  logic [31: 0] i_mem_write_data, // 输入信号
    output logic [31: 0] o_mem_write_data, // 输出信号
    input  logic          i_flush, // 输入信号
    input  logic          clk, // 时钟信号
    input  logic          rst_n // 复位信号
);

`include "cpu/pipeline/pipeline_types.svh"

    mem_to_wrb_t payload_in;
    mem_to_wrb_t payload_out;
    logic [$bits(mem_to_wrb_t) - 1: 0] payload_in_bits;
    logic [$bits(mem_to_wrb_t) - 1: 0] payload_out_bits;
    logic        vld_out;
    logic        rdy_in;

    // 组合逻辑块
    always_comb begin
        payload_in.mem_valid        = i_mem_valid;
        payload_in.mem_write_enable = i_mem_write_enable;
        payload_in.mem_address      = i_mem_address;
        payload_in.mem_write_data   = i_mem_write_data;
    end

    assign payload_in_bits = payload_in;
    assign payload_out     = payload_out_bits;

    pipeline_reg #(
        .P_DATA_WIDTH ( $bits(mem_to_wrb_t) )
    ) u_mem_to_wrb_reg (
        .i_flush   ( i_flush ),
        .i_valid   ( i_stage4_valid ),
        .o_ready   ( rdy_in ),
        .i_payload ( payload_in_bits ),
        .o_valid   ( vld_out ),
        .i_ready   ( i_wrb_ready ),
        .o_payload ( payload_out_bits ),
        .clk       ( clk ),
        .rst_n     ( rst_n )
    );

    assign o_mem_ready    = rdy_in;
    assign o_stage4_valid = vld_out;

    assign o_mem_valid        = payload_out.mem_valid;
    assign o_mem_write_enable = payload_out.mem_write_enable;
    assign o_mem_address      = payload_out.mem_address;
    assign o_mem_write_data   = payload_out.mem_write_data;

endmodule
