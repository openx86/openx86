/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_muldiv_execute_muldiv_unit.
*/
// ============================================================================
// Multiply / Divide Unit — MUL/IMUL 32×32→64，DIV/IDIV 64÷32
// ============================================================================

`include "openx86_defs.h.sv"

module eu_muldiv_execute_muldiv_unit (
    input  logic [ 2: 0] i_op,  // 乘除操作类型
    input  logic [31: 0] i_lo,  // 低半部 / 被除数低 32 位
    input  logic [31: 0] i_hi,  // 被除数高 32 位
    input  logic [31: 0] i_src,  // 乘数或除数
    output logic [31: 0] o_lo,  // 结果低半 / 商
    output logic [31: 0] o_hi,  // 结果高半 / 余
    output logic         o_div0  // 除数为 0
);
    // 64 位中间量：乘积、扩展被除数、商余（有/无符号）
    logic [63: 0] umul;
    logic signed [63: 0] smul;
    logic [63: 0] dividend;
    logic [63: 0] divisor_u;
    logic signed [63: 0] sdividend;
    logic [63: 0] uquot, urem;
    logic signed [63: 0] squot, srem;

    // 组合逻辑：推导输出
    always_comb begin
        umul = 64'(i_lo) * 64'(i_src);
        smul = $signed(i_lo) * $signed(i_src);
        dividend = {i_hi, i_lo};
        divisor_u = {32'h0, i_src};
        sdividend = $signed({i_hi, i_lo});
        uquot = '0;
        urem  = '0;
        squot = '0;
        srem  = '0;

        o_div0 = 1'b0;
        o_lo   = 32'h0;
        o_hi   = 32'h0;

        // MUL/IMUL/DIV/IDIV 数据通路选择
        unique case (i_op)
            `EXE_MD_MULU32: begin
                o_lo = umul[31: 0];
                o_hi = umul[63: 32];
            end
            `EXE_MD_IMUL32: begin
                o_lo = smul[31: 0];
                o_hi = smul[63: 32];
            end
            `EXE_MD_DIVU32: begin
                // 除数为 0：置 div0，不写商余
                if (i_src == 32'h0) begin
                    o_div0 = 1'b1;
                end else begin
                    uquot = (dividend / divisor_u);
                    urem  = (dividend % divisor_u);
                    o_lo  = uquot[31: 0];
                    o_hi  = urem[31: 0];
                end
            end
            `EXE_MD_IDIV32: begin
                // 除数为 0：置 div0，不写商余
                if (i_src == 32'h0) begin
                    o_div0 = 1'b1;
                end else begin
                    squot = (sdividend / 64'($signed(i_src)));
                    srem  = (sdividend % 64'($signed(i_src)));
                    o_lo  = squot[31: 0];
                    o_hi  = srem[31: 0];
                end
            end
            default: ;
        endcase
    end

endmodule
