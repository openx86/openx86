/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements execute_branch_unit.
*/
// ============================================================================
// Branch Unit — 近分支相对位移与 Jcc 条件判定（386 子集）
// ============================================================================

module execute_branch_unit (    input  logic                i_is_jcc,  // 是否为条件跳转
    input  logic [ 3: 0]         i_jcc_nibble, // Jcc 条件编码
    input  logic                i_CF, // 进位 CF
    input  logic                i_PF, // 奇偶 PF
    input  logic                i_ZF, // 零标志 ZF
    input  logic                i_SF, // 符号 SF
    input  logic                i_OF, // 溢出 OF
    input  logic [31: 0]        i_eip, // 当前 EIP
    input  logic [31: 0]        i_rel32, // 32 位相对位移
    input  logic signed [ 7: 0] i_rel8, // 8 位相对位移
    input  logic                i_use_rel8, // 使用 8 位位移
    output logic               o_taken, // 是否跳转
    output logic [31: 0]       o_target_eip // 目标 EIP
);

    // 符号扩展后的分支位移（8 位或 32 位）
    logic [31: 0]        offset_u;

    // 组合逻辑：连续赋值
    assign offset_u = i_use_rel8 ? {{24{i_rel8[7]}}, i_rel8} : i_rel32;


    // 组合逻辑：推导输出
    always_comb begin
        // 无条件跳转：恒 taken
        if (!i_is_jcc) begin
            o_taken = 1'b1;
        end else begin
            // Jcc：nibble 编码与 SETcc 低 4 位一致
            unique case (i_jcc_nibble)
                4'h0: o_taken = i_OF;
                4'h1: o_taken = !i_OF;
                4'h2: o_taken = i_CF;
                4'h3: o_taken = !i_CF;
                4'h4: o_taken = i_ZF;
                4'h5: o_taken = !i_ZF;
                4'h6: o_taken = i_CF | i_ZF;
                4'h7: o_taken = !i_CF & !i_ZF;
                4'h8: o_taken = i_SF;
                4'h9: o_taken = !i_SF;
                4'hA: o_taken = i_PF;
                4'hB: o_taken = !i_PF;
                4'hC: o_taken = i_SF ^ i_OF;
                4'hD: o_taken = !(i_SF ^ i_OF);
                4'hE: o_taken = i_ZF | (i_SF ^ i_OF);
                default: o_taken = !i_ZF & !(i_SF ^ i_OF);
            endcase
        end
    end

    // 组合逻辑：连续赋值
    assign o_target_eip = i_eip + offset_u;

endmodule
