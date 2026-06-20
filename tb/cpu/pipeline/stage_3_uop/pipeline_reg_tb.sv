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
//  File        : pipeline_reg_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : pipeline_reg_tb module
// ============================================================================

`timescale 1ns/1ns

module pipeline_reg_tb;
    logic clk;
    logic rst_n;

    logic i_flush;
    logic i_valid;
    logic o_ready;
    logic [7: 0] i_payload;

    logic o_valid;
    logic i_ready;
    logic [7: 0] o_payload;

    pipeline_reg #(
        .T ( logic [7: 0] )
    ) u_dut (
        .i_flush   ( i_flush ),
        .i_valid   ( i_valid ),
        .o_ready   ( o_ready ),
        .i_payload ( i_payload ),
        .o_valid   ( o_valid ),
        .i_ready   ( i_ready ),
        .o_payload ( o_payload ),
        .clk       ( clk ),
        .rst_n     ( rst_n )
    );

    task automatic tick;
        begin
            #5 clk = 1'b1;
            #5 clk = 1'b0;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        i_flush = 1'b0;
        i_valid = 1'b0;
        i_payload = 8'h00;
        i_ready = 1'b0;

        tick();
        rst_n = 1'b1;

        // Empty -> accept one beat
        i_valid = 1'b1;
        i_payload = 8'hA5;
        i_ready = 1'b0;
        tick();
        if (o_valid !== 1'b1) $fatal(1, "pipeline_reg should hold valid after accepting data");
        if (o_payload !== 8'hA5) $fatal(1, "pipeline_reg payload mismatch after accept");

        // Stall should keep payload stable
        i_valid = 1'b0;
        i_ready = 1'b0;
        tick();
        if (o_valid !== 1'b1) $fatal(1, "pipeline_reg lost valid during stall");
        if (o_payload !== 8'hA5) $fatal(1, "pipeline_reg payload changed during stall");

        // Downstream ready consumes, becomes empty
        i_ready = 1'b1;
        tick();
        if (o_valid !== 1'b0) $fatal(1, "pipeline_reg should become empty after consume");

        // Flush should clear even when full
        i_ready = 1'b0;
        i_valid = 1'b1;
        i_payload = 8'h3C;
        tick();
        if (o_valid !== 1'b1) $fatal(1, "pipeline_reg should be full before flush");
        i_flush = 1'b1;
        tick();
        i_flush = 1'b0;
        if (o_valid !== 1'b0) $fatal(1, "pipeline_reg flush did not clear valid");

        $display("pipeline_reg_tb PASS");
        $finish;
    end

endmodule
