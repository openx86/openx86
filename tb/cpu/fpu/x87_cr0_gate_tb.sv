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
// File : x87_cr0_gate_tb.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : x87_cr0_gate #NM when EM|TS smoke test
// ============================================================================

`timescale 1ns/1ns

module x87_cr0_gate_tb;

    logic x87_op;
    logic cr0_em;
    logic cr0_ts;
    logic nm;
    int   pass_count;

    x87_cr0_gate dut (
        .i_x87_op       (x87_op),
        .i_cr0_em       (cr0_em),
        .i_cr0_ts       (cr0_ts),
        .o_nm_exception (nm)
    );

    initial begin
        pass_count = 0;
        x87_op = 1'b0; cr0_em = 1'b0; cr0_ts = 1'b0;
        #1; if (~nm) pass_count++;
        x87_op = 1'b1;
        #1; if (~nm) pass_count++;
        cr0_em = 1'b1;
        #1; if (nm) pass_count++;
        cr0_em = 1'b0; cr0_ts = 1'b1;
        #1; if (nm) pass_count++;
        if (pass_count == 4)
            $display("x87_cr0_gate_tb PASS");
        else
            $fatal(1, "x87_cr0_gate_tb FAIL");
        $finish;
    end

endmodule
