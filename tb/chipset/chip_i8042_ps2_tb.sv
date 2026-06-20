// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : chip_i8042_ps2_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : chip_i8042_ps2_tb module
// ============================================================================

﻿
// ============================================================================
// TB: chip_i8042_ps2（ISA 并行口）
// ============================================================================

module chip_i8042_ps2_tb;

    // ============================================================
    // test signals
    // ============================================================
    logic        clk = 0;
    logic rst_n;
    logic        io_valid;
    logic        io_we;
    logic [15: 0] io_addr;
    logic [ 7: 0] io_wdata;
    logic [ 7: 0] io_rdata;
    logic        kbd_push;
    logic [ 7: 0]  kbd_data;

    logic ps2_hit = (io_addr == 16'h0060) | (io_addr == 16'h0064);
    logic cs_n    = !(io_valid && ps2_hit);
    logic wr_n    = !(io_valid && io_we && ps2_hit);
    logic rd_n    = !(io_valid && !io_we && ps2_hit);

    // ============================================================
    // DUT instantiation
    // ============================================================
    chip_i8042_ps2 #(
        .USE_REAL_PS2 ( 1'b0 )
    ) dut (
        .clk     ( clk ),
        .rst_n     ( rst_n ),
        .i_cs_n      ( cs_n ),
        .i_rd_n      ( rd_n ),
        .i_wr_n      ( wr_n ),
        .i_a0        ( io_addr[2] ),
        .i_d         ( io_wdata ),
        .o_d         ( io_rdata ),
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

    // ============================================================
    // clock generation
    // ============================================================
    always #5 clk = ~clk;

    // ============================================================
    // test procedure
    // ============================================================
    initial begin : main_test
        kbd_push = 0;
        rst_n    = 1;
        io_valid = 0;
        repeat (3) @(posedge clk);
        rst_n = 0;
        @(posedge clk);

        kbd_data = 8'h5A;
        kbd_push = 1;
        @(posedge clk);
        kbd_push = 0;
        @(posedge clk);

        io_valid = 1;
        io_we    = 0;
        io_addr  = 16'h0060;
        @(posedge clk);
        if (io_rdata !== 8'h5A)
            $display("FAIL ps2 data read");
        else
            $display("PASS ps2 kbd fifo");

        $finish;
    end

endmodule
