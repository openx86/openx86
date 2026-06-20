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
//  File        : x87_smoke_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : x87_fpu_core reg-stack FADD/FXCH smoke test
// ============================================================================

`timescale 1ns/1ns

`include "openx86_defs.h.sv"

module x87_smoke_tb;

    logic         clk;
    logic         rst_n;
    logic         valid;
    logic [ 4: 0] subop;
    logic [ 2: 0] sti;
    logic [31: 0] mem_data;
    logic [79: 0] st0;
    logic [79: 0] st1;
    logic [79: 0] st2;
    logic [79: 0] st3;
    logic [79: 0] st4;
    logic [79: 0] st5;
    logic [79: 0] st6;
    logic [79: 0] st7;
    logic [15: 0] fcw;
    logic [15: 0] fsw;
    logic [79: 0] st0_out;
    logic [79: 0] st1_out;
    logic [79: 0] st2_out;
    logic [79: 0] st3_out;
    logic [79: 0] st4_out;
    logic [79: 0] st5_out;
    logic [79: 0] st6_out;
    logic [79: 0] st7_out;
    logic         st0_we;
    logic         st1_we;
    logic [15: 0] fsw_out;
    logic         fsw_we;
    logic         fpu_exception;

    always #1 clk = ~clk;

    x87_fpu_core dut (
        .i_valid             (valid),
        .i_x87_subop         (subop),
        .i_sti_index         (sti),
        .i_mem_data          (mem_data),
        .i_st0               (st0),
        .i_st1               (st1),
        .i_st2               (st2),
        .i_st3               (st3),
        .i_st4               (st4),
        .i_st5               (st5),
        .i_st6               (st6),
        .i_st7               (st7),
        .i_fcw               (fcw),
        .i_fsw               (fsw),
        .o_st0               (st0_out),
        .o_st1               (st1_out),
        .o_st2               (st2_out),
        .o_st3               (st3_out),
        .o_st4               (st4_out),
        .o_st5               (st5_out),
        .o_st6               (st6_out),
        .o_st7               (st7_out),
        .o_st0_we            (st0_we),
        .o_st1_we            (st1_we),
        .o_st2_we            (),
        .o_st3_we            (),
        .o_st4_we            (),
        .o_st5_we            (),
        .o_st6_we            (),
        .o_st7_we            (),
        .o_fsw               (fsw_out),
        .o_fsw_we            (fsw_we),
        .o_stack_push        (),
        .o_stack_pop         (),
        .o_mem_valid         (),
        .o_mem_write_enable  (),
        .o_mem_wdata         (),
        .o_fpu_exception     (fpu_exception),
        .clk                 (clk),
        .rst_n               (rst_n)
    );

    function automatic logic [79: 0] pack_ext(input logic [63: 0] mant);
        pack_ext[79]    = 1'b0;
        pack_ext[78: 64] = 15'd16383;
        pack_ext[63: 0]  = {1'b1, mant[62: 0]};
    endfunction

    initial begin
        clk      = 1'b0;
        rst_n    = 1'b0;
        valid    = 1'b0;
        subop    = `EXE_X87_NOP;
        sti      = 3'd0;
        mem_data = 32'h0;
        fcw      = 16'h037F;
        fsw      = 16'h0000;
        st0      = pack_ext(64'd10);
        st1      = pack_ext(64'd32);
        st2      = 80'h0;
        st3      = 80'h0;
        st4      = 80'h0;
        st5      = 80'h0;
        st6      = 80'h0;
        st7      = 80'h0;
        #4 rst_n = 1'b1;

        @(posedge clk);
        valid = 1'b1;
        subop = `EXE_X87_FADD;
        sti   = 3'd1;
        @(posedge clk);
        valid = 1'b0;
        @(posedge clk);
        if (st0_out[62: 0] != 64'd42) begin
            $display("FAIL FADD result=%0d", st0_out[62: 0]);
            $finish(1);
        end
        if (st0_we) st0 = st0_out;
        if (st1_we) st1 = st1_out;

        @(posedge clk);
        valid = 1'b1;
        subop = `EXE_X87_FXCH;
        sti   = 3'd1;
        @(posedge clk);
        valid = 1'b0;
        @(posedge clk);
        if (st0_out[62: 0] != 64'd32 || st1_out[62: 0] != 64'd42) begin
            $display("FAIL FXCH st0=%0d st1=%0d", st0_out[62: 0], st1_out[62: 0]);
            $finish(1);
        end

        $display("PASS x87_smoke_tb");
        $finish;
    end

endmodule
