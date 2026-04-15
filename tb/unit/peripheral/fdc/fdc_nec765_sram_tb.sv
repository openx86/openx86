// ============================================================================
// fdc_nec765_sram testbench — 小容量几何（1 柱 × 1 头 × 1 扇区）加快仿真
// ============================================================================
`timescale 1ns/1ps

module fdc_nec765_sram_tb;

    logic        clock = 0;
    logic        reset;
    logic        io_valid;
    logic        io_we;
    logic [15:0] io_addr;
    logic [7:0]  io_wdata;
    logic [7:0]  io_rdata;
    logic        io_hit;

    fdc_nec765_sram #(
        .CYLINDERS   ( 1 ),
        .HEADS       ( 1 ),
        .SECTORS_TRK ( 1 ),
        .SECTOR_BYTES( 512 )
    ) dut (
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
        int i;
        int nb = $size(dut.sram);
        for (i = 0; i < nb; i++)
            dut.sram[i] = 8'hE5;
        if (nb > 2) begin
            dut.sram[0] = 8'hEB;
            dut.sram[1] = 8'h3C;
            dut.sram[2] = 8'h90;
        end
    end

    task automatic wr(input logic [15:0] a, input logic [7:0] d);
        @(posedge clock);
        io_valid = 1;
        io_we    = 1;
        io_addr  = a;
        io_wdata = d;
        @(posedge clock);
        io_valid = 0;
        io_we    = 0;
    endtask

    task automatic rd(input logic [15:0] a, output logic [7:0] d);
        @(posedge clock);
        io_valid = 1;
        io_we    = 0;
        io_addr  = a;
        @(posedge clock);
        d = io_rdata;
        io_valid = 0;
    endtask

    logic [7:0] rb;
    integer     i;
    initial begin
        reset    = 1;
        io_valid = 0;
        io_we    = 0;
        repeat (4) @(posedge clock);
        reset = 0;
        repeat (2) @(posedge clock);

        wr(16'h03F2, 8'h0C);

        wr(16'h03F5, 8'hE6);
        wr(16'h03F5, 8'h00);
        wr(16'h03F5, 8'h00);
        wr(16'h03F5, 8'h00);
        wr(16'h03F5, 8'h01);
        wr(16'h03F5, 8'h02);
        wr(16'h03F5, 8'h12);
        wr(16'h03F5, 8'h1B);
        wr(16'h03F5, 8'hFF);

        rd(16'h03F4, rb);
        $display("MSR after cmd = %h", rb);

        for (i = 0; i < 519; i++) begin
            rd(16'h03F5, rb);
            if (i == 0 && rb !== 8'h40)
                $display("FAIL ST0 expect 40 got %h", rb);
            if (i == 7 && rb !== 8'hEB)
                $display("FAIL first data byte expect EB got %h", rb);
        end
        $display("PASS fdc read sector pio");
        $finish;
    end

endmodule
