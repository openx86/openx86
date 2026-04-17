/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_execute_branch_unit.
*/
// ============================================================================
// Branch Unit — 近分支相对位移与 Jcc 条件判定（386 子集）
// ============================================================================

module stage_3_exe_execute_branch_unit (
    input  logic        i_is_jcc,
    input  logic [ 3:0] i_jcc_nibble,
    input  logic        i_CF,
    input  logic        i_PF,
    input  logic        i_ZF,
    input  logic        i_SF,
    input  logic        i_OF,
    input  logic [31:  0] i_eip,
    input  logic [31:  0] i_rel32,
    input  logic signed [ 7:  0] i_rel8,
    input  logic        i_use_rel8,
    output logic        o_taken,
    output logic [31:  0] o_target_eip);

    logic signed [31:  0] offset_s;
    logic [31:  0]        offset_u;

    always_comb begin
        if (i_use_rel8)
            offset_s = 32'(i_rel8);
        else
            offset_s = 32'(signed'(i_rel32));
    end

    assign offset_u = 32'(offset_s);

    always_comb begin
        if (!i_is_jcc) begin
            o_taken = 1'b1;
        end else begin
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

    assign o_target_eip = i_eip + offset_u;

endmodule
