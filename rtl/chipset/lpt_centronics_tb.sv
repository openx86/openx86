// ============================================================================
// lpt_centronics testbench — 写数据口、读状态/控制
// ============================================================================
`timescale 1ns/1ps

module lpt_centronics_tb;

    logic        clock = 0;
    logic        reset;
    logic        io_valid, io_we;
    logic [15:0] io_addr;
    logic [7:0]  io_wdata, io_rdata;
    logic        io_hit;

    lpt_centronics dut (
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
        reset = 1;
        io_valid = 0;
        repeat (4) @(posedge clock);
        reset = 0;
        repeat (2) @(posedge clock);

        wr(16'h0378, 8'hA5);
        rd(16'h0378, rb);
        if (rb !== 8'hA5)
            $display("FAIL lpt data %h", rb);
        else
            $display("PASS lpt data readback");

        rd(16'h0379, rb);
        $display("STATUS=%h", rb);
        $display("lpt_centronics_tb done");
        $finish;
    end

endmodule
