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
//  File        : eu_ld_execute_load_segment_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_ld_execute_load_segment_tb module
// ============================================================================

`timescale 1ns/1ns
`include "openx86_defs.h.sv"

module eu_ld_execute_load_segment_tb;
    logic        protected_mode_enable;
    logic [15: 0] index_segment_register;
    logic [15: 0] index_general_register;
    logic [ 7: 0] greg__8;
    logic [15: 0] greg_16;
    logic [31: 0] greg_32;
    logic [15: 0] write_enable;
    logic [15: 0] write_index;
    logic [15: 0] write_selector;
    logic [63: 0] write_descriptor;
    logic        valid;
    logic        ready;

    ld_execute_load_segment u_dut (
        .protected_mode_enable(protected_mode_enable),
        .index_segment_register(index_segment_register),
        .index_general_register(index_general_register),
        .greg__8(greg__8),
        .greg_16(greg_16),
        .greg_32(greg_32),
        .write_enable(write_enable),
        .write_index(write_index),
        .write_selector(write_selector),
        .write_descriptor(write_descriptor),
        .valid(valid),
        .ready(ready)
    );

    initial begin
        protected_mode_enable = 1'b0;
        index_segment_register = `sreg_index_DS;
        index_general_register = 16'd0;
        greg__8 = 8'd0;
        greg_16 = 16'h1234;
        greg_32 = 32'h0;
        valid = 1'b1;
        #1;
        if (!ready) begin
            $display("FAIL load_segment ready");
            $finish(1);
        end
        if (write_selector !== 16'h1234 || write_index !== `sreg_index_DS) begin
            $display("FAIL load_segment values");
            $finish(1);
        end
        $display("eu_ld_execute_load_segment_tb PASS");
        $finish;
    end
endmodule
