/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements ide_sd_native_disk_tb.
*/
// ============================================================================
// chip_ata_ide（异步）+ ide_sd_sector_bridge + sd_native_host_4bit + card 模型
// ============================================================================
`timescale 1ns/1ps

module ide_sd_native_disk_tb;

    logic        clock = 0;
    logic        reset;
    logic        io_valid, io_we;
    logic [15: 0] io_addr;
    logic [ 7: 0] io_wdata, io_rdata;

    logic ide_hit = ((io_addr >= 16'h01F0) && (io_addr <= 16'h01F7)) | (io_addr == 16'h03F6);
    logic ide_cs_n = !(io_valid && ide_hit);
    logic ide_wr_n = !(io_valid && io_we && ide_hit);
    logic ide_rd_n = !(io_valid && !io_we && ide_hit);

    logic [31: 0] ide_raddr;
    logic        ide_sector_req;
    logic        ide_sector_ready;
    logic [ 7: 0]  disk_rdata_mux;

    logic        sd_start;
    logic [31: 0] sd_lba;
    logic        sd_busy, sd_done, sd_err;
    logic        sd_payload_we;
    logic [ 8: 0]  sd_payload_addr;
    logic [ 7: 0]  sd_payload_data;

    logic         sd_clk;
    logic         sd_cmd;
    logic [ 3: 0]   sd_dat;

    logic        host_cmd_oe;
    logic        host_cmd_o;
    logic        host_dat_oe;
    logic [ 3: 0]  host_dat_o;

    logic        card_cmd_oe;
    logic        card_cmd_o;
    logic        card_dat_oe;
    logic [ 3: 0]  card_dat_o;

    always #5 clock = ~clock;

    assign sd_cmd = host_cmd_oe ? host_cmd_o : (card_cmd_oe ? card_cmd_o : 1'b1);
    assign sd_dat = host_dat_oe ? host_dat_o : (card_dat_oe ? card_dat_o : 4'hF);

    sd_native_host_4bit u_host (
        .clock        ( clock ),
        .reset_n        ( reset_n ),
        .o_sd_clk       ( sd_clk ),
        .o_sd_phy_cmd_out  ( host_cmd_o ),
        .o_sd_phy_cmd_oe   ( host_cmd_oe ),
        .i_sd_phy_cmd_in   ( sd_cmd ),
        .o_sd_phy_dat_out  ( host_dat_o ),
        .o_sd_phy_dat_oe   ( host_dat_oe ),
        .i_sd_phy_dat_in   ( sd_dat ),
        .i_start        ( sd_start ),
        .i_lba          ( sd_lba ),
        .o_busy         ( sd_busy ),
        .o_done         ( sd_done ),
        .o_err          ( sd_err ),
        .o_payload_we   ( sd_payload_we ),
        .o_payload_addr ( sd_payload_addr ),
        .o_payload_data ( sd_payload_data )
    );

    sd_mmc_card_model_native u_card (
        .i_sd_clk      ( sd_clk ),
        .reset_n       ( reset_n ),
        .i_host_cmd_oe ( host_cmd_oe ),
        .i_host_cmd_o  ( host_cmd_o ),
        .i_sd_cmd_bus  ( sd_cmd ),
        .o_card_cmd_oe ( card_cmd_oe ),
        .o_card_cmd_o  ( card_cmd_o ),
        .i_host_dat_oe ( host_dat_oe ),
        .i_host_dat_o  ( host_dat_o ),
        .o_card_dat_oe ( card_dat_oe ),
        .o_card_dat_o  ( card_dat_o )
    );

    ide_sd_sector_bridge u_bridge (
        .clock             ( clock ),
        .reset_n             ( reset_n ),
        .i_ide_disk_raddr    ( ide_raddr ),
        .o_ide_disk_rdata    ( disk_rdata_mux ),
        .i_ide_sector_req    ( ide_sector_req ),
        .o_ide_sector_ready  ( ide_sector_ready ),
        .o_sd_start          ( sd_start ),
        .o_sd_lba            ( sd_lba ),
        .i_sd_busy           ( sd_busy ),
        .i_sd_done           ( sd_done ),
        .i_sd_err            ( sd_err ),
        .i_sd_payload_we     ( sd_payload_we ),
        .i_sd_payload_addr   ( sd_payload_addr ),
        .i_sd_payload_data   ( sd_payload_data )
    );

    chip_ata_ide #(
        .SECTOR_BYTES(512),
        .SECTOR_COUNT(16),
        .USE_INTERNAL_DISK_MEM(1'b0),
        .USE_ASYNC_DISK(1'b1)
    ) u_ide (
        .clock             ( clock ),
        .reset_n             ( reset_n ),
        .i_cs_n              ( ide_cs_n ),
        .i_rd_n              ( ide_rd_n ),
        .i_wr_n              ( ide_wr_n ),
        .i_addr              ( io_addr ),
        .i_d                 ( io_wdata ),
        .o_d                 ( io_rdata ),
        .o_disk_raddr        ( ide_raddr ),
        .i_disk_rdata        ( disk_rdata_mux ),
        .i_disk_sector_ready( ide_sector_ready ),
        .o_disk_sector_req   ( ide_sector_req )
    );

    task automatic wr(input logic [15: 0] a, input  logic [ 7: 0] d);
        @(posedge clock);
        io_valid = 1;
        io_we    = 1;
        io_addr  = a;
        io_wdata = d;
        @(posedge clock);
        io_valid = 0;
    endtask

    task automatic rd(input logic [15: 0] a, output logic [ 7: 0] d);
        @(posedge clock);
        io_valid = 1;
        io_we    = 0;
        io_addr  = a;
        @(posedge clock);
        d = io_rdata;
        io_valid = 0;
    endtask

    logic [ 7: 0] rb;
    int unsigned wait_cycles;
    logic seen_done;

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            seen_done  <= 1'b0;
        end else begin
            if (sd_done)
                seen_done <= 1'b1;
        end
    end

    initial begin
        reset    = 1;
        io_valid = 0;
        repeat (5) @(posedge clock);
        reset = 0;
        repeat (5) @(posedge clock);

        wr(16'h01F2, 8'h01);
        wr(16'h01F3, 8'h00);
        wr(16'h01F4, 8'h00);
        wr(16'h01F5, 8'h00);
        wr(16'h01F6, 8'hE0);
        wr(16'h01F7, 8'h20);

        wait_cycles = 0;
        while (!(ide_sector_ready || seen_done) && (wait_cycles < 200000)) begin
            @(posedge clock);
            wait_cycles = wait_cycles + 1;
        end
        if (!(ide_sector_ready || seen_done)) begin
            $display("FAIL ide_sd_native timeout: req=%0b start=%0b busy=%0b done=%0b err=%0b seen_done=%0b", ide_sector_req, sd_start, sd_busy, sd_done, sd_err, seen_done);
            $finish;
        end
        @(posedge clock);

        rd(16'h01F0, rb);
        if (rb !== 8'hA5)
            $display("FAIL ide_sd_native first byte %h err %b", rb, sd_err);
        else
            $display("PASS ide_sd_native_disk_tb");

        $finish;
    end

endmodule
