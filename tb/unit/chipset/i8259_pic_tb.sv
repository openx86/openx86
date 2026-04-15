// ============================================================================
// i8259_pic testbench — 单主片初始化 + IMR + 中断线
// ============================================================================
module i8259_pic_tb;

    logic        clock = 0;
    logic        reset;
    logic        io_valid;
    logic        io_we;
    logic [15:0] io_addr;
    logic [7:0]  io_wdata;
    logic [7:0]  io_rdata;
    logic        io_hit;
    logic [7:0]  ir;
    logic        intr;

    i8259_pic #(
        .PORT_BASE ( 16'h0020 )
    ) dut (
        .i_clock    ( clock ),
        .i_reset    ( reset ),
        .i_io_valid ( io_valid ),
        .i_io_we    ( io_we ),
        .i_io_addr  ( io_addr ),
        .i_io_wdata ( io_wdata ),
        .o_io_rdata ( io_rdata ),
        .o_io_hit   ( io_hit ),
        .i_ir       ( ir ),
        .o_intr     ( intr )
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

    initial begin
        ir       = 8'h0;
        reset    = 1;
        io_valid = 0;
        repeat (3) @(posedge clock);
        reset = 0;
        repeat (2) @(posedge clock);

        wr(16'h0020, 8'h13);
        wr(16'h0021, 8'h08);
        wr(16'h0021, 8'h01);
        wr(16'h0021, 8'hFE);
        ir = 8'h01;
        repeat (2) @(posedge clock);
        if (!intr)
            $display("FAIL pic intr");
        else
            $display("PASS pic intr");

        $display("i8259_pic_tb done");
        $finish;
    end

endmodule
