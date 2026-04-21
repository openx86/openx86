/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: INVD / WBINVD / INVLPG micro-ops (cache flush and TLB invalidate pulses).
*/
// ============================================================================
// cache_invalidate — i486 cache control placeholders
// ============================================================================

module cache_invalidate (
    input  logic          insn_fire, // 输入信号
    input  logic          op_invd, // 输入信号
    input  logic          op_wbinvd, // 输入信号
    input  logic          op_invlpg, // 输入信号
    input  logic [31: 0]  invlpg_ea, // 输入信号
    output logic         o_cache_flush_pulse, // 输出信号
    output logic         o_invlpg_pulse, // 输出信号
    output logic [31: 0] o_invlpg_linear_addr, // 输出信号
    input  logic          clk, // 时钟信号
    input  logic          rst_n // 复位信号
);

    // 时序逻辑块
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_cache_flush_pulse <= 1'b0;
            o_invlpg_pulse <= 1'b0;
            o_invlpg_linear_addr <= '0;
        end else begin
            o_cache_flush_pulse <= 1'b0;
            o_invlpg_pulse <= 1'b0;

            if (insn_fire && op_invd) begin
                o_cache_flush_pulse <= 1'b1;
            end
            if (insn_fire && op_wbinvd) begin
                o_cache_flush_pulse <= 1'b1;
            end
            if (insn_fire && op_invlpg) begin
                o_invlpg_pulse <= 1'b1;
                o_invlpg_linear_addr <= invlpg_ea;
            end
        end
    end

endmodule
