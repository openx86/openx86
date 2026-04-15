`timescale 1ns/1ps
module pc_chipset_io_tb;

    logic        clock = 0;
    logic        reset;
    logic        io_valid;
    logic        io_we;
    logic [15:0] io_addr;
    logic [7:0]  io_wdata;
    logic [7:0]  io_rdata;
    logic        io_hit;
    logic        io_ready;

    always #5 clock = ~clock;

    pc_chipset_io dut (
        .i_clock           ( clock ),
        .i_reset           ( reset ),
        .i_io_valid        ( io_valid ),
        .i_io_we           ( io_we ),
        .i_io_addr         ( io_addr ),
        .i_io_wdata        ( io_wdata ),
        .o_io_rdata        ( io_rdata ),
        .o_io_hit          ( io_hit ),
        .o_io_ready        ( io_ready ),
        .i_ps2_kbd_push    ( 1'b0 ),
        .i_ps2_kbd_data    ( 8'h0 ),
        .i_ps2_aux_push    ( 1'b0 ),
        .i_ps2_aux_data    ( 8'h0 ),
        .i_pic_slave_ir    ( 8'h0 ),
        .o_pic_master_intr ( ),
        .o_pic_slave_intr  ( ),
        .o_pit_out0        ( )
    );

    initial begin
        reset    = 1;
        io_valid = 0;
        io_we    = 0;
        repeat (4) @(posedge clock);
        reset = 0;
        @(posedge clock);

        io_valid = 1;
        io_we    = 0;
        io_addr  = 16'h0080;
        @(posedge clock);
        if (!io_hit || io_rdata !== 8'h00)
            $display("FAIL pc_chipset dma page read");
        else
            $display("PASS pc_chipset aggregate");

        io_valid = 0;
        $display("pc_chipset_io_tb done");
        $finish;
    end

endmodule
