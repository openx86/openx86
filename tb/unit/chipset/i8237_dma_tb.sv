/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements i8237_dma_tb.
*/
// ============================================================================
// TB: i8237_dma（ISA 并行口）
// ----------------------------------------------------------------------------
// 对 8237 DMA 控制器的 I/O 寄存器访问路径做基本回归。
// ============================================================================

module i8237_dma_tb;

    logic        clock = 0;
    logic        reset;
    logic        valid;
    logic        we;
    logic [15:  0] addr;
    logic [ 7:  0]  wdata;
    logic [ 7:  0]  rdata;

    wire hit_lo   = (addr <= 16'h000F);
    wire hit_page = (addr >= 16'h0080) && (addr <= 16'h008F);
    wire hit_hi   = (addr >= 16'h00C0) && (addr <= 16'h00DF);
    wire hit      = hit_lo | hit_page | hit_hi;
    wire cs_n     = !(valid && hit);
    wire wr_n     = !(valid && we && hit);
    wire rd_n     = !(valid && !we && hit);

    chip_8237_dma dut (
        .clock    ( clock ),
        .reset_n    ( reset_n ),
        .i_cs_n     ( cs_n ),
        .i_rd_n     ( rd_n ),
        .i_wr_n     ( wr_n ),
        .i_addr     ( addr ),
        .i_d        ( wdata ),
        .o_d        ( rdata )
    );

    always #5 clock = ~clock;

    initial begin
        reset = 1;
        valid = 0;
        we    = 0;
        addr  = 16'h0005;
        wdata = '0;
        repeat (3) @(posedge clock);
        reset = 0;
        @(posedge clock);

        valid = 1;
        we    = 1;
        addr  = 16'h0005;
        wdata = 8'hAB;
        @(posedge clock);
        valid = 0;
        @(posedge clock);

        valid = 1;
        we    = 0;
        addr  = 16'h0005;
        @(posedge clock);
        if (rdata !== 8'hAB)
            $display("FAIL dma read");
        else
            $display("PASS dma read");

        $finish;
    end

endmodule
