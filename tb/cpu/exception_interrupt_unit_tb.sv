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
//  File        : exception_interrupt_unit_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Smoke test for exception/interrupt delivery unit
// ============================================================================

`timescale 1ns/1ns

module exception_interrupt_unit_tb;

    logic clk;
    logic rst_n;
    logic         flush_pipeline;
    logic         clear_if;
    logic         new_eip_valid;
    logic [31: 0] new_eip;
    logic [ 7: 0] vector;
    logic         error_code_valid;
    logic [31: 0] error_code;
    logic         ferr_n;

    always #1 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        #4 rst_n = 1'b1;
        #2;

        if (flush_pipeline !== 1'b1) begin
            $display("FAIL: external interrupt did not flush pipeline");
            $fatal(1);
        end
        if (vector !== 8'h20) begin
            $display("FAIL: unexpected vector %h", vector);
            $fatal(1);
        end
        $display("PASS exception_interrupt_unit_tb");
        $finish;
    end

    exception_interrupt_unit dut (
        .i_exception_valid   (1'b0),
        .i_exception_vector  (8'h0),
        .i_has_error_code    (1'b0),
        .i_error_code        (32'h0),
        .i_external_intr     (1'b1),
        .i_nmi               (1'b0),
        .i_if_flag           (1'b1),
        .i_idtr_base         (32'h0000_0000),
        .i_idtr_limit        (16'h0FFF),
        .i_current_eip       (32'h0000_0100),
        .i_current_cs_base   (32'h0),
        .i_cpl               (2'b0),
        .o_flush_pipeline    (flush_pipeline),
        .o_clear_if          (clear_if),
        .o_new_eip_valid     (new_eip_valid),
        .o_new_eip           (new_eip),
        .o_vector            (vector),
        .o_error_code_valid  (error_code_valid),
        .o_error_code        (error_code),
        .o_ferr_n            (ferr_n),
        .i_fpu_exception     (1'b0),
        .clk                 (clk),
        .rst_n               (rst_n)
    );

endmodule
