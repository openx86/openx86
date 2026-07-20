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
    logic [ 5: 0] subop;
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
        .o_fcw               (),
        .o_fcw_we            (),
        .o_stack_push        (),
        .o_stack_pop         (),
        .o_mem_valid         (),
        .o_mem_write_enable  (),
        .o_mem_wdata         (),
        .o_fpu_exception     (fpu_exception),
        .clk                 (clk),
        .rst_n               (rst_n)
    );

    // Pack a positive finite 80-bit extended value for small integers (exact when power-of-two aligned)
    function automatic logic [79: 0] pack_int(input int unsigned val);
        logic [14: 0] exp;
        logic [63: 0] sig;
        int unsigned  v;
        int           shift;
        begin
            if (val == 0) begin
                pack_int = 80'h0;
            end else begin
                v     = val;
                shift = 0;
                while (v < 32'h8000_0000) begin
                    v     = v << 1;
                    shift = shift + 1;
                end
                // v now has bit31 set; place as integer bit of 64-bit significand
                sig     = {v, 32'h0};
                exp     = 15'd16383 + 15'(31 - shift);
                pack_int = {1'b0, exp, sig};
            end
        end
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
        st0      = pack_int(10);
        st1      = pack_int(32);
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
        #1;
        if (st0_out !== pack_int(42)) begin
            $fatal(1, "FAIL FADD result=%h expected=%h", st0_out, pack_int(42));
        end
        if (st0_we) st0 = st0_out;
        if (st1_we) st1 = st1_out;
        @(posedge clk);
        valid = 1'b0;

        @(posedge clk);
        valid = 1'b1;
        subop = `EXE_X87_FXCH;
        sti   = 3'd1;
        #1;
        if ((st0_out !== pack_int(32)) || (st1_out !== pack_int(42))) begin
            $fatal(1, "FAIL FXCH st0=%h st1=%h", st0_out, st1_out);
        end
        if (st0_we) st0 = st0_out;
        if (st1_we) st1 = st1_out;
        @(posedge clk);
        valid = 1'b0;

        $display("PASS x87_smoke_tb");
        $finish;
    end

endmodule
