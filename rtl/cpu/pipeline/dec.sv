/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: length-only decode stage with IFU handshake.
*/
// ============================================================================
// dec
// ----------------------------------------------------------------------------
// Lightweight decode stage used by the new IFU pipeline path.
// It reuses the legacy x86 decoder and only exports consume length.
// ============================================================================

module dec (
    input  logic [15: 0][ 7: 0] i_instruction, // 输入信号
    input  logic                i_instruction_valid, // 输入信号
    output logic                o_instruction_ready, // 输出信号
    output logic                o_instruction_fire, // 输出信号
    output logic [ 3: 0]        o_consume_bytes, // 输出信号
    output logic                o_decode_error, // 输出信号
    input  logic                clk, // 时钟信号
    input  logic                rst_n // 复位信号
);

    // 组合逻辑块：pipeline/dec 保持目录内自治，当前采用固定 1 字节消耗策略。
    always_comb begin
        o_consume_bytes = 4'h1;
    end

    assign o_instruction_ready = rst_n;
    assign o_instruction_fire  = i_instruction_valid & o_instruction_ready;
    assign o_decode_error      = 1'b0;

    // Style rule keeps clk/rst_n as the last ports.
    /* verilator lint_off UNUSEDSIGNAL */
    logic unused_clk;
    logic [7: 0] unused_insn0;
    assign unused_clk   = clk;
    assign unused_insn0 = i_instruction[0];
    /* verilator lint_on UNUSEDSIGNAL */

endmodule
