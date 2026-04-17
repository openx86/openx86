/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_8237_dma.
*/
// ============================================================================
// Intel 8237 DMA — 寄存器占位模型（无真实 ISA 总线主控周期）
// 主机接口：nCS/nRD/nWR + i_addr[15:0]（仅当片选有效时由上层保证地址落在
//   0x00–0x0F / 0x80–0x8F / 0xC0–0xDF）
// ============================================================================

module chip_8237_dma (
    input  logic        i_clock,
    input  logic        i_reset,
    input  logic        i_cs_n,
    input  logic        i_rd_n,
    input  logic        i_wr_n,
    input  logic [15:0] i_addr,
    input  logic [7:0]  i_d,
    output logic [7:0]  o_d
);

    logic [7:0] regfile [0:15];
    logic [7:0] page_reg [0:7];
    logic [7:0] dma16_stub [0:31];

    wire hit_lo   = (i_addr <= 16'h000F);
    wire hit_page = (i_addr >= 16'h0080) && (i_addr <= 16'h008F);
    wire hit_hi   = (i_addr >= 16'h00C0) && (i_addr <= 16'h00DF);

    wire wr = !i_cs_n && !i_wr_n;
    wire rd = !i_cs_n && !i_rd_n;

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            for (int i = 0; i < 16; i++)
                regfile[i] <= 8'h00;
            for (int j = 0; j < 8; j++)
                page_reg[j] <= 8'h00;
            for (int k = 0; k < 32; k++)
                dma16_stub[k] <= 8'h00;
        end else if (wr) begin
            if (hit_lo)
                regfile[i_addr[3:0]] <= i_d;
            else if (hit_page)
                page_reg[i_addr[2:0]] <= i_d;
            else if (hit_hi)
                dma16_stub[i_addr[4:0]] <= i_d;
        end
    end

    always_comb begin
        o_d = 8'hFF;
        if (rd) begin
            if (hit_lo)
                o_d = regfile[i_addr[3:0]];
            else if (hit_page)
                o_d = page_reg[i_addr[2:0]];
            else if (hit_hi)
                o_d = dma16_stub[i_addr[4:0]];
        end
    end

endmodule
