/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements ide_ata_pio_tb.
*/
// ============================================================================
// TB: chip_ata_ide（ISA 并行口）
// ============================================================================

module ide_ata_pio_tb;

    logic        clock = 0;
    logic        reset;
    logic        io_valid;
    logic        io_we;
    logic [15: 0] io_addr;
    logic [ 7: 0] io_wdata;
    logic [ 7: 0] io_rdata;

    logic ide_hit = ((io_addr >= 16'h01F0) && (io_addr <= 16'h01F7)) | (io_addr == 16'h03F6);
    logic cs_n    = !(io_valid && ide_hit);
    logic wr_n    = !(io_valid && io_we && ide_hit);
    logic rd_n    = !(io_valid && !io_we && ide_hit);

    logic [31: 0] disk_ra;
    logic disk_sector_req;
    chip_ata_ide dut (
        .clock             ( clock ),
        .reset_n             ( reset_n ),
        .i_cs_n              ( cs_n ),
        .i_rd_n              ( rd_n ),
        .i_wr_n              ( wr_n ),
        .i_addr              ( io_addr ),
        .i_d                 ( io_wdata ),
        .o_d                 ( io_rdata ),
        .o_disk_raddr        ( disk_ra ),
        .i_disk_rdata        ( 8'h0 ),
        .i_disk_sector_ready ( 1'b0 ),
        .o_disk_sector_req   ( disk_sector_req )
    );

    always #5 clock = ~clock;

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
    initial begin
        reset    = 1;
        io_valid = 0;
        repeat (3) @(posedge clock);
        reset = 0;
        repeat (2) @(posedge clock);

        wr(16'h01F2, 8'h01);
        wr(16'h01F3, 8'h00);
        wr(16'h01F4, 8'h00);
        wr(16'h01F5, 8'h00);
        wr(16'h01F6, 8'hE0);
        wr(16'h01F7, 8'h20);
        repeat (2) @(posedge clock);
        rd(16'h01F0, rb);
        if (rb !== 8'hA5)
            $display("FAIL ide first byte %h", rb);
        else
            $display("PASS ide pio read");

        $finish;
    end

endmodule
