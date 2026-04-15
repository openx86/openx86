// ============================================================================
// i8254_pit testbench
// ============================================================================
`timescale 1ns/1ps
module i8254_pit_tb;

    logic        clock = 0;
    logic        reset;
    logic        io_valid;
    logic        io_we;
    logic [15:0] io_addr;
    logic [7:0]  io_wdata;
    logic [7:0]  io_rdata;
    logic        io_hit;
    logic        out0, out1, out2;

    i8254_pit dut (
        .i_clock    ( clock ),
        .i_reset    ( reset ),
        .i_io_valid ( io_valid ),
        .i_io_we    ( io_we ),
        .i_io_addr  ( io_addr ),
        .i_io_wdata ( io_wdata ),
        .o_io_rdata ( io_rdata ),
        .o_io_hit   ( io_hit ),
        .o_out0     ( out0 ),
        .o_out1     ( out1 ),
        .o_out2     ( out2 )
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
        reset    = 1;
        io_valid = 0;
        io_we    = 0;
        io_addr  = '0;
        io_wdata = '0;
        repeat (3) @(posedge clock);
        reset = 0;
        repeat (2) @(posedge clock);

        wr(16'h0043, 8'h36);
        wr(16'h0040, 8'h04);
        wr(16'h0040, 8'h00);
        rd(16'h0040, rb);
        if (!io_hit)
            $display("FAIL pit io_hit");
        else
            $display("PASS pit read (data=%h)", rb);

        repeat (20) @(posedge clock);
        $display("i8254_pit_tb done");
        $finish;
    end

endmodule
