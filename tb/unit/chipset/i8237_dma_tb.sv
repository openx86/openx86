// ============================================================================
// TB: i8237_dma
// ----------------------------------------------------------------------------
// 目标：对 8237 DMA 控制器的 I/O 寄存器访问路径做基本回归。
// - 通过 `io_valid/io_we/io_addr/io_wdata` 驱动 DUT
// - 观察 `io_hit/io_rdata` 是否符合期望（本 TB 以简单序列为主）
//
// 说明：这是 unit TB，不依赖完整 SoC 集成；由脚本统一注入 RTL filelist。
// ============================================================================

module i8237_dma_tb;

    logic        clock = 0;
    logic        reset;
    logic        io_valid;
    logic        io_we;
    logic [15:0] io_addr;
    logic [7:0]  io_wdata;
    logic [7:0]  io_rdata;
    logic        io_hit;

    i8237_dma dut (
        .i_clock    ( clock ),
        .i_reset    ( reset ),
        .i_io_valid ( io_valid ),
        .i_io_we    ( io_we ),
        .i_io_addr  ( io_addr ),
        .i_io_wdata ( io_wdata ),
        .o_io_rdata ( io_rdata ),
        .o_io_hit   ( io_hit )
    );

    always #5 clock = ~clock;

    initial begin
        reset    = 1;
        io_valid = 0;
        io_we    = 0;
        repeat (3) @(posedge clock);
        reset = 0;
        @(posedge clock);

        io_valid = 1;
        io_we    = 1;
        io_addr  = 16'h0005;
        io_wdata = 8'hAB;
        @(posedge clock);
        io_valid = 0;
        @(posedge clock);

        io_valid = 1;
        io_we    = 0;
        io_addr  = 16'h0005;
        @(posedge clock);
        if (io_rdata !== 8'hAB)
            $display("FAIL dma read");
        else
            $display("PASS dma read");

        $finish;
    end

endmodule
