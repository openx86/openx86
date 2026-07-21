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
// File : exu_string_tb.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : Verify exu_string step size for byte/half/dword and DF
// ============================================================================

`timescale 1ns/1ns

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_string_tb;

    logic [31: 0] src1;
    logic [31: 0] src2;
    logic [31: 0] ecx;
    logic [ 1: 0] mem_size;
    logic         is_store;
    logic         df;
    logic         rep;
    logic         repne;
    logic         zf;
    exu_result_t  result;
    logic         rep_restart;
    logic [31: 0] ecx_next;

    exu_string dut (
        .i_src1_data   (src1),
        .i_src2_data   (src2),
        .i_ecx         (ecx),
        .i_mem_size    (mem_size),
        .i_is_store    (is_store),
        .i_df          (df),
        .i_rep         (rep),
        .i_repne       (repne),
        .i_zf          (zf),
        .o_result      (result),
        .o_rep_restart (rep_restart),
        .o_ecx_next    (ecx_next)
    );

    initial begin
        src1     = 32'h1000;
        src2     = 32'h55;
        ecx      = 32'd4;
        is_store = 1'b1;
        df       = 1'b0;
        rep      = 1'b0;
        repne    = 1'b0;
        zf       = 1'b0;

        mem_size = 2'b00;
        #1;
        if (result.mem_address !== 32'h1000 || result.result !== 32'h1001) begin
            $display("FAIL STOSB step: addr=%h next=%h", result.mem_address, result.result);
            $fatal(1);
        end

        mem_size = 2'b01;
        #1;
        if (result.result !== 32'h1002) begin
            $display("FAIL STOSW step: next=%h", result.result);
            $fatal(1);
        end

        mem_size = 2'b10;
        #1;
        if (result.result !== 32'h1004) begin
            $display("FAIL STOSD step: next=%h", result.result);
            $fatal(1);
        end

        df = 1'b1;
        mem_size = 2'b00;
        #1;
        if (result.result !== 32'h0FFF) begin
            $display("FAIL STOSB DF: next=%h", result.result);
            $fatal(1);
        end

        $display("PASS exu_string_tb");
        $finish;
    end

endmodule
