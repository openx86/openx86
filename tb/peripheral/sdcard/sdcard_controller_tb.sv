/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Testbench for sdcard_controller BRAM mode byte read.
*/
// ============================================================================

`timescale 1ns/1ps

module sdcard_controller_tb;

    logic        clk = 0;
    logic        rst_n;
    logic [31: 0] raddr;
    logic [ 7: 0] rdata;
    logic         sector_req;
    logic         sector_ready;

    always #5 clk = ~clk;

    sdcard_controller #(
        .P_BYTE_DEPTH    ( 512 * 16 ),
        .P_USE_SDIO_DISK ( 1'b0 )
    ) dut (
        .i_disk_raddr        ( raddr ),
        .o_disk_rdata        ( rdata ),
        .i_disk_sector_req   ( sector_req ),
        .o_disk_sector_ready ( sector_ready ),
        .o_sdcard_controller_phy_clk     ( ),
        .o_sdcard_controller_phy_cmd_out ( ),
        .o_sdcard_controller_phy_cmd_oe  ( ),
        .i_sdcard_controller_phy_cmd_in  ( 1'b1 ),
        .o_sdcard_controller_phy_dat_out ( ),
        .o_sdcard_controller_phy_dat_oe  ( ),
        .i_sdcard_controller_phy_dat_in  ( 4'hF ),
        .clk               ( clk ),
        .rst_n             ( rst_n )
    );

    initial begin
        rst_n     = 0;
        raddr       = 0;
        sector_req  = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);
        raddr = 0;
        @(posedge clk);
        if (rdata !== 8'hA5)
            $display("FAIL sdcard_controller byte0 %h", rdata);
        else
            $display("PASS sdcard_controller_tb");
        $finish;
    end

endmodule
