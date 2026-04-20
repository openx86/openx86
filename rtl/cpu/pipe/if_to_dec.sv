/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: pipeline_boundary — combinational bridge from IF (stage_1) to decode inputs.
*/
// ============================================================================
// pipeline_boundary
// ----------------------------------------------------------------------------
// Passes instruction window, ready, and segment fault from IFU to DEC.
// ============================================================================

module if_to_dec (
    input  logic [15: 0][ 7: 0] i_instruction, // 输入信号
    input  logic          i_instruction_ready, // 输入信号
    input  logic          i_segment_fault, // 输入信号
    output logic [15: 0][ 7: 0] o_instruction, // 输出信号
    output logic         o_instruction_ready, // 输出信号
    output logic         o_segment_fault, // 输出信号
    input  logic          i_dec_ready, // 输入信号
    output logic         o_ifu_ready, // 输出信号
    input  logic          i_flush, // 输入信号
    input  logic          clk, // 时钟信号
    input  logic          rst_n // 复位信号
);

`include "cpu/pipeline/pipeline_types.svh"

    ifu_to_dec_t payload_in;
    ifu_to_dec_t payload_out;
    logic [$bits(ifu_to_dec_t) - 1: 0] payload_in_bits;
    logic [$bits(ifu_to_dec_t) - 1: 0] payload_out_bits;
    logic        vld_out;
    logic        rdy_in;

    // 组合逻辑块
    always_comb begin
        payload_in.instruction   = i_instruction;
        payload_in.segment_fault = i_segment_fault;
    end

    assign payload_in_bits = payload_in;
    assign payload_out     = payload_out_bits;

    pipeline_reg #(
        .P_DATA_WIDTH ( $bits(ifu_to_dec_t) )
    ) u_if_to_dec_reg (
        .i_flush   ( i_flush ),
        .i_valid   ( i_instruction_ready ),
        .o_ready   ( rdy_in ),
        .i_payload ( payload_in_bits ),
        .o_valid   ( vld_out ),
        .i_ready   ( i_dec_ready ),
        .o_payload ( payload_out_bits ),
        .clk       ( clk ),
        .rst_n     ( rst_n )
    );

    assign o_ifu_ready         = rdy_in;
    assign o_instruction_ready = vld_out;
    assign o_instruction       = payload_out.instruction;
    assign o_segment_fault     = payload_out.segment_fault;

endmodule
