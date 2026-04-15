// ============================================================================
// com_ns16550 testbench — 写 THR + 回环读 RBR，读 LSR
// ============================================================================
`timescale 1ns/1ps

module com_ns16550_tb;

    logic        clock = 0;
    logic        reset;
    logic        io_valid, io_we;
    logic [15:0] io_addr;
    logic [7:0]  io_wdata, io_rdata;
    logic        io_hit;
    logic        rx_push;
    logic [7:0]  rx_data;

    com_ns16550 dut (
        .i_clock    ( clock ),
        .i_reset    ( reset ),
        .i_io_valid ( io_valid ),
        .i_io_we    ( io_we ),
        .i_io_addr  ( io_addr ),
        .i_io_wdata ( io_wdata ),
        .o_io_rdata ( io_rdata ),
        .o_io_hit   ( io_hit ),
        .i_rx_push  ( rx_push ),
        .i_rx_data  ( rx_data )
    );

    always #5 clock = ~clock;

    task automatic wr(input logic [15:0] a, input logic [7:0] d);
        @(posedge clock);
        io_valid = 1;
        io_we    = 1;
        io_addr  = a;
        io_wdata = d;
        @(posedge clock);
        io_valid = 0;
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
    initial begin
        rx_push = 0;
        rx_data = 0;
        reset   = 1;
        io_valid = 0;
        repeat (4) @(posedge clock);
        reset = 0;
        repeat (2) @(posedge clock);

        wr(16'h03FC, 8'h10);
        wr(16'h03F8, 8'h55);
        rd(16'h03F8, rb);
        if (rb !== 8'h55)
            $display("FAIL com loopback %h", rb);
        else
            $display("PASS com loopback");

        rd(16'h03FD, rb);
        $display("LSR=%h", rb);
        $display("com_ns16550_tb done");
        $finish;
    end

endmodule
