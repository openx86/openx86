module ps2_i8042_tb;

    logic        clock = 0;
    logic        reset;
    logic        io_valid;
    logic        io_we;
    logic [15:0] io_addr;
    logic [7:0]  io_wdata;
    logic [7:0]  io_rdata;
    logic        io_hit;
    logic        kbd_push;
    logic [7:0]  kbd_data;

    ps2_i8042 #(
        .USE_REAL_PS2 ( 1'b0 )
    ) dut (
        .i_clock     ( clock ),
        .i_reset     ( reset ),
        .i_io_valid  ( io_valid ),
        .i_io_we     ( io_we ),
        .i_io_addr   ( io_addr ),
        .i_io_wdata  ( io_wdata ),
        .o_io_rdata  ( io_rdata ),
        .o_io_hit    ( io_hit ),
        .i_kbd_push  ( kbd_push ),
        .i_kbd_data  ( kbd_data ),
        .i_aux_push  ( 1'b0 ),
        .i_aux_data  ( 8'h0 ),
        .o_kbd_irq   ( ),
        .o_aux_irq   ( ),
        .o_ps2_kbd_clk_out ( ),
        .o_ps2_kbd_clk_oe  ( ),
        .i_ps2_kbd_clk_in  ( 1'b1 ),
        .o_ps2_kbd_dat_out ( ),
        .o_ps2_kbd_dat_oe  ( ),
        .i_ps2_kbd_dat_in  ( 1'b1 ),
        .o_ps2_aux_clk_out ( ),
        .o_ps2_aux_clk_oe  ( ),
        .i_ps2_aux_clk_in  ( 1'b1 ),
        .o_ps2_aux_dat_out ( ),
        .o_ps2_aux_dat_oe  ( ),
        .i_ps2_aux_dat_in  ( 1'b1 )
    );

    always #5 clock = ~clock;

    initial begin
        kbd_push = 0;
        reset    = 1;
        io_valid = 0;
        repeat (3) @(posedge clock);
        reset = 0;
        @(posedge clock);

        kbd_data = 8'h5A;
        kbd_push = 1;
        @(posedge clock);
        kbd_push = 0;
        @(posedge clock);

        io_valid = 1;
        io_we    = 0;
        io_addr  = 16'h0060;
        @(posedge clock);
        if (io_rdata !== 8'h5A)
            $display("FAIL ps2 data read");
        else
            $display("PASS ps2 kbd fifo");

        $finish;
    end

endmodule
