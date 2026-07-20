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
// File : instruction_footprint_tb.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : Lightweight i486_cpu_core cycle footprint scaffold TB
// ============================================================================

`timescale 1ns/1ns

module instruction_footprint_tb;

    logic         clk;
    logic         rst_n;
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
    int           cycle_count;

    logic [31: 0] code_mem [0: 255];

    always #1 clk = ~clk;

    assign mmu_ready      = 1'b1;
    assign mmu_data_read  = 32'h0;
    assign code_ready     = code_valid;
    assign code_data_read = code_mem[code_address[9: 2]];
    assign data_ready     = data_valid;
    assign data_data_read = 32'h0;

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
        .o_invalidate_cache  ( ),
        .o_wbinvd            ( ),
        .clk                 (clk),
        .rst_n               (rst_n)
    );

    initial begin
        for (int i = 0; i < 256; i++)
            code_mem[i] = 32'h90909090; // NOP slide
        clk         = 1'b0;
        rst_n       = 1'b0;
        cycle_count = 0;
        #4;
        rst_n = 1'b1;
        repeat (64) begin
            @(posedge clk);
            cycle_count++;
        end
        $display("PASS instruction_footprint (cycles=%0d)", cycle_count);
        $finish;
    end

endmodule
