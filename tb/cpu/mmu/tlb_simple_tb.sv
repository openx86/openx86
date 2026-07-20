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
// File : tlb_simple_tb.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : tlb_simple lookup / fill / INVLPG / invall smoke test
// ============================================================================

`timescale 1ns/1ns

module tlb_simple_tb;

    logic         clk;
    logic         rst_n;
    logic         lookup_valid;
    logic [31: 0] lookup_linear;
    logic         hit;
    logic [31: 0] phys_page;
    logic         fill_valid;
    logic [31: 0] fill_linear;
    logic [31: 0] fill_phys;
    logic         invall;
    logic         invlpg;
    logic [31: 0] invlpg_linear;
    int           pass_count;

    always #1 clk = ~clk;

    tlb_simple dut (
        .i_lookup_valid     (lookup_valid),
        .i_lookup_linear    (lookup_linear),
        .o_hit              (hit),
        .o_phys_page_base   (phys_page),
        .i_fill_valid       (fill_valid),
        .i_fill_linear      (fill_linear),
        .i_fill_phys_page   (fill_phys),
        .i_invall           (invall),
        .i_invlpg           (invlpg),
        .i_invlpg_linear    (invlpg_linear),
        .clk                (clk),
        .rst_n              (rst_n)
    );

    initial begin
        clk            = 1'b0;
        rst_n          = 1'b0;
        lookup_valid   = 1'b0;
        lookup_linear  = 32'h0;
        fill_valid     = 1'b0;
        fill_linear    = 32'h0;
        fill_phys      = 32'h0;
        invall         = 1'b0;
        invlpg         = 1'b0;
        invlpg_linear  = 32'h0;
        pass_count     = 0;
        #4;
        rst_n = 1'b1;
        @(posedge clk);

        fill_linear  = 32'h0001_2000;
        fill_phys    = 32'h00AB_C000;
        fill_valid   = 1'b1;
        @(posedge clk);
        fill_valid = 1'b0;

        lookup_linear = 32'h0001_2345;
        lookup_valid  = 1'b1;
        #1;
        if (hit && (phys_page == 32'h00AB_C000))
            pass_count++;
        lookup_valid = 1'b0;
        @(posedge clk);

        invlpg_linear = 32'h0001_2000;
        invlpg        = 1'b1;
        @(posedge clk);
        invlpg = 1'b0;
        lookup_valid = 1'b1;
        #1;
        if (~hit)
            pass_count++;
        lookup_valid = 1'b0;

        fill_linear = 32'h0002_0000;
        fill_phys   = 32'h0011_1000;
        fill_valid  = 1'b1;
        @(posedge clk);
        fill_valid = 1'b0;
        invall = 1'b1;
        @(posedge clk);
        invall = 1'b0;
        lookup_linear = 32'h0002_0100;
        lookup_valid  = 1'b1;
        #1;
        if (~hit)
            pass_count++;

        if (pass_count == 3)
            $display("tlb_simple_tb PASS");
        else
            $fatal(1, "tlb_simple_tb FAIL pass_count=%0d", pass_count);
        $finish;
    end

endmodule
