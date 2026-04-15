// ============================================================================
// sdram_controller 基本读写与握手
// ============================================================================

`timescale 1ns/1ns

module sdram_controller_tb;

    logic        clk;
    logic        rst;
    logic        i_en;
    logic        i_we;
    logic [23:0] i_addr_off;
    logic [31:0] i_wdata;
    logic [31:0] o_rdata;
    logic        o_ready;
    logic        o_busy;

    logic        o_sdram_clk;
    logic        o_sdram_cke;
    logic        o_sdram_cs_n;
    logic        o_sdram_ras_n;
    logic        o_sdram_cas_n;
    logic        o_sdram_we_n;
    logic [1:0]  o_sdram_ba;
    logic [12:0] o_sdram_a;
    logic [1:0]  o_sdram_dqm;
    logic [15:0] o_sdram_dq_out;
    logic        o_sdram_dq_oe;

    sdram_controller #(
        .MEM_WORDS_LG2 ( 10 ),
        .LATENCY       ( 3 )
    ) dut (
        .clk            ( clk ),
        .rst            ( rst ),
        .i_en           ( i_en ),
        .i_we           ( i_we ),
        .i_addr_off     ( i_addr_off ),
        .i_wdata        ( i_wdata ),
        .o_rdata        ( o_rdata ),
        .o_ready        ( o_ready ),
        .o_busy         ( o_busy ),
        .o_sdram_clk    ( o_sdram_clk ),
        .o_sdram_cke    ( o_sdram_cke ),
        .o_sdram_cs_n   ( o_sdram_cs_n ),
        .o_sdram_ras_n  ( o_sdram_ras_n ),
        .o_sdram_cas_n  ( o_sdram_cas_n ),
        .o_sdram_we_n   ( o_sdram_we_n ),
        .o_sdram_ba     ( o_sdram_ba ),
        .o_sdram_a      ( o_sdram_a ),
        .o_sdram_dqm    ( o_sdram_dqm ),
        .o_sdram_dq_out ( o_sdram_dq_out ),
        .o_sdram_dq_oe  ( o_sdram_dq_oe )
    );

    always #5 clk = ~clk;

    initial begin
        clk    = 1'b0;
        rst    = 1'b1;
        i_en   = 1'b0;
        i_we   = 1'b0;
        i_addr_off = '0;
        i_wdata    = '0;
        #40 rst = 1'b0;

        // 写
        @(posedge clk);
        i_en = 1'b1;
        i_we = 1'b1;
        i_addr_off = 24'h10;
        i_wdata    = 32'hDEAD_BEEF;
        @(posedge clk);
        i_en = 1'b0;

        while (!o_ready) @(posedge clk);
        @(posedge clk);

        // 读
        @(posedge clk);
        i_en = 1'b1;
        i_we = 1'b0;
        i_addr_off = 24'h10;
        @(posedge clk);
        i_en = 1'b0;

        while (!o_ready) @(posedge clk);
        @(posedge clk);
        if (o_rdata !== 32'hDEAD_BEEF) begin
            $display("FAIL read 0x%08h", o_rdata);
            $finish(1);
        end

        $display("sdram_controller_tb PASS");
        $finish;
    end

endmodule
