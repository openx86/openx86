/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: INVD / WBINVD / INVLPG micro-ops (cache flush and TLB invalidate pulses).
*/
// ============================================================================
// eu_extensions_i486_cache_invalidate — i486 cache control placeholders
// ============================================================================

module eu_extensions_i486_cache_invalidate (
    input  logic          insn_fire,
    input  logic          op_invd,
    input  logic          op_wbinvd,
    input  logic          op_invlpg,
    input  logic [31: 0]  invlpg_ea,
    output logic         o_cache_flush_pulse,
    output logic         o_invlpg_pulse,
    output logic [31: 0] o_invlpg_linear_addr,
    input  logic          clk,
    input  logic          rst_n
);

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
