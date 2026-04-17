/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_execute_muldiv_unit.
*/
// ============================================================================
// Multiply / Divide Unit — MUL/IMUL 32×32→64，DIV/IDIV 64÷32
// ============================================================================

module stage_3_exe_execute_muldiv_unit (
    input  logic [ 2:  0]  i_op,
    input  logic [31:  0] i_lo,
    input  logic [31:  0] i_hi,
    input  logic [31:  0] i_src,
    output logic [31:  0] o_lo,
    output logic [31:  0] o_hi,
    output logic        o_div0);

    import stage_3_exe_execute_unit_pkg::*;

    logic [63:  0] umul;
    logic signed [63:  0] smul;
    logic [63:  0] dividend;
    logic [63:  0] divisor_u;
    logic signed [63:  0] sdividend;
    logic signed [31:  0] sdivisor;
    logic [63:  0] uquot, urem;
    logic signed [63:  0] squot, srem;

    always_comb begin
        umul = 64'(i_lo) * 64'(i_src);
        smul = $signed(i_lo) * $signed(i_src);
        dividend = {i_hi, i_lo};
        divisor_u = {32'h0, i_src};
        sdividend = $signed({i_hi, i_lo});
        sdivisor  = $signed(i_src);
        uquot = '0;
        urem  = '0;
        squot = '0;
        srem  = '0;

        o_div0 = 1'b0;
        o_lo   = 32'h0;
        o_hi   = 32'h0;

        unique case (i_op)
            MD_MULU32: begin
                o_lo = umul[31:  0];
                o_hi = umul[63: 32];
            end
            MD_IMUL32: begin
                o_lo = smul[31:  0];
                o_hi = smul[63: 32];
            end
            MD_DIVU32: begin
                if (i_src == 32'h0) begin
                    o_div0 = 1'b1;
                end else begin
                    uquot = (dividend / divisor_u);
                    urem  = (dividend % divisor_u);
                    o_lo  = uquot[31:  0];
                    o_hi  = urem[31:  0];
                end
            end
            MD_IDIV32: begin
                if (i_src == 32'h0) begin
                    o_div0 = 1'b1;
                end else begin
                    squot = (sdividend / sdivisor);
                    srem  = (sdividend % sdivisor);
                    o_lo  = squot[31:  0];
                    o_hi  = srem[31:  0];
                end
            end
            default: ;
        endcase
    end

endmodule
