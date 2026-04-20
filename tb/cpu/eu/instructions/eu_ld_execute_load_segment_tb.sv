/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_ld_execute_load_segment_tb.
*/
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
