/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_centronics_lpt.
*/
// ============================================================================
// IBM PC 并行口（LPT1）— Centronics 风格寄存器级模型
// 主机接口：nCS/nRD/nWR + A[ 2: 0]（相对基址 0x378）
// 状态位与 PC 一致：Busy/ACK 等为反相有效（读时按常见 BIOS 期望编码）
// ============================================================================

module chip_centronics_lpt (
    input  logic        i_cs_n,
    input  logic        i_rd_n,
    input  logic        i_wr_n,
    input  logic [ 2: 0]  i_a,
    input  logic [ 7: 0]  i_d,
    output logic [ 7: 0]  o_d,
    input  logic        reset_n,
    input  logic        clock
);

    wire [ 2: 0] off = i_a;

    logic [ 7: 0] data_reg;
    logic [ 7: 0] ctrl_reg;

    wire wr = !i_cs_n && !i_wr_n;

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            data_reg <= 8'h0;
            ctrl_reg <= 8'h0C;
        end else if (wr) begin
            unique case (off)
                3'd0: data_reg <= i_d;
                3'd2: ctrl_reg <= i_d;
                default: ;
            endcase
        end
    end

    wire [ 7: 0] status_read = {
        1'b0,
        1'b1,
        1'b1,
        1'b1,
        1'b1,
        1'b0,
        1'b1,
        1'b1
    };

    wire rd = !i_cs_n && !i_rd_n;

    always_comb begin
        o_d = 8'hFF;
        if (rd) begin
            unique case (off)
                3'd0: o_d = data_reg;
                3'd1: o_d = status_read;
                3'd2: o_d = ctrl_reg;
                default: o_d = 8'hFF;
            endcase
        end
    end

endmodule
