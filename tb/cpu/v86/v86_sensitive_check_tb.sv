// ============================================================================
// Copyright (c) 2026 Chang Wei
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
// File : v86_sensitive_check_tb.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : v86_sensitive_check IOPL/#GP smoke test
// ============================================================================

`timescale 1ns/1ns

module v86_sensitive_check_tb;

    logic        vm;
    logic [ 1: 0] iopl;
    logic        op_cli;
    logic        op_sti;
    logic        op_pushf;
    logic        op_popf;
    logic        op_int;
    logic        op_iret;
    logic        op_in;
    logic        op_out;
    logic        trap_gp;
    int          pass_count;

    v86_sensitive_check dut (
        .i_vm       (vm),
        .i_iopl     (iopl),
        .i_op_cli   (op_cli),
        .i_op_sti   (op_sti),
        .i_op_pushf (op_pushf),
        .i_op_popf  (op_popf),
        .i_op_int   (op_int),
        .i_op_iret  (op_iret),
        .i_op_in    (op_in),
        .i_op_out   (op_out),
        .o_trap_gp  (trap_gp)
    );

    initial begin
        pass_count = 0;
        vm = 1'b0; iopl = 2'd0;
        op_cli = 1'b0; op_sti = 1'b0; op_pushf = 1'b0; op_popf = 1'b0;
        op_int = 1'b0; op_iret = 1'b0; op_in = 1'b0; op_out = 1'b0;
        #1;
        if (~trap_gp) pass_count++;

        vm = 1'b1; iopl = 2'd2; op_cli = 1'b1;
        #1;
        if (trap_gp) pass_count++;

        iopl = 2'd3;
        #1;
        if (~trap_gp) pass_count++;

        op_cli = 1'b0; op_in = 1'b1; iopl = 2'd0;
        #1;
        if (trap_gp) pass_count++;

        if (pass_count == 4)
            $display("PASS v86_sensitive_check");
        else
            $fatal(1, "FAIL v86_sensitive_check");
        $finish;
    end

endmodule
