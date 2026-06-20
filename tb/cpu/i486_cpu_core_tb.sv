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
//  File        : i486_cpu_core_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Smoke and fetch activity test for i486_cpu_core
// ============================================================================

`timescale 1ns/1ns

module i486_cpu_core_tb;

    logic clk;
    logic rst_n;
    logic         mmu_valid;
    logic         mmu_ready;
    logic [31: 0] mmu_address;
    logic [31: 0] mmu_data_read;
    logic         code_valid;
    logic         code_ready;
    logic [31: 0] code_address;
    logic [31: 0] code_data_read;
    logic         data_valid;
    logic         data_ready;
    logic         data_write_enable;
    logic         data_io_access;
    logic [31: 0] data_address;
    logic [31: 0] data_data_read;
    logic [31: 0] data_data_write;
    logic         ferr_n;

    int           code_fetch_count;
    int           cycle_count;

    always #1 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        mmu_ready = 1'b1;
        code_ready = 1'b1;
        data_ready = 1'b1;
        mmu_data_read = 32'h0;
        code_data_read = 32'h9090_9090;
        data_data_read = 32'h0;
        code_fetch_count = 0;
        cycle_count = 0;
        #8 rst_n = 1'b1;
    end

    always @(posedge clk) begin
        if (rst_n) begin
            cycle_count <= cycle_count + 1;
            if (code_valid & code_ready) begin
                code_fetch_count <= code_fetch_count + 1;
            end
            if (cycle_count == 64) begin
                if (code_fetch_count > 0) begin
                    $display("PASS i486_cpu_core_tb code_fetch_count=%0d", code_fetch_count);
                end else begin
                    $display("FAIL i486_cpu_core_tb no code fetch activity");
                end
                $finish;
            end
        end
    end

    i486_cpu_core dut (
        .o_mmu_valid         (mmu_valid),
        .i_mmu_ready         (mmu_ready),
        .o_mmu_address       (mmu_address),
        .i_mmu_data_read     (mmu_data_read),
        .o_code_valid        (code_valid),
        .i_code_ready        (code_ready),
        .o_code_address      (code_address),
        .i_code_data_read    (code_data_read),
        .o_data_valid        (data_valid),
        .i_data_ready        (data_ready),
        .o_data_write_enable (data_write_enable),
        .o_data_io_access    (data_io_access),
        .o_data_address      (data_address),
        .i_data_data_read    (data_data_read),
        .o_data_data_write   (data_data_write),
        .i_intr              (1'b0),
        .i_nmi               (1'b0),
        .o_ferr_n            (ferr_n),
        .clk                 (clk),
        .rst_n               (rst_n)
    );

endmodule
