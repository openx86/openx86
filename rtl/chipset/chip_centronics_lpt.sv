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
    input  logic         i_cs_n,  // 低有效片选
    input  logic         i_rd_n,  // 低有效读
    input  logic         i_wr_n,  // 低有效写
    input  logic [ 2: 0] i_a,     // 寄存器偏移（相对 0x378）
    input  logic [ 7: 0] i_d,     // 写数据
    output logic [ 7: 0] o_d,     // 读数据
    input  logic         clk,     // 系统时钟
    input  logic         rst_n    // 异步低有效复位
);

    logic [ 2: 0] off;  // 与 i_a 相同的寄存器索引

    assign off = i_a;

    logic [ 7: 0] data_reg;   // 数据寄存器（写后送“打印机”侧）
    logic [ 7: 0] ctrl_reg;   // 控制寄存器

    logic wr;  // 片内写选通

    assign wr = !i_cs_n && !i_wr_n;

    // 仅数据/控制寄存器可写；其余偏移忽略写。
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
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

    // 固定“空闲/就绪”状态编码（Busy 等为反相有效，与常见 PC BIOS 期望一致）。
    logic [ 7: 0] status_read = {
        1'b0,
        1'b1,
        1'b1,
        1'b1,
        1'b1,
        1'b0,
        1'b1,
        1'b1
    };

    logic rd;  // 片内读选通

    assign rd = !i_cs_n && !i_rd_n;

    // 读：数据/状态/控制口；未实现寄存器返回 0xFF。
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
