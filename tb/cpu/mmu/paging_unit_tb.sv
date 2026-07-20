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
//  File        : paging_unit_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : paging_unit PTE/PDE attribute and page fault smoke test
// ============================================================================

`timescale 1ns/1ns

`include "openx86_defs.h.sv"

module paging_unit_tb;

    logic         clk;
    logic         rst_n;
    logic         valid;
    logic         ready;
    logic [31: 0] linear_address;
    logic [31: 0] page_dir_base;
    logic [ 1: 0] cpl;
    logic         is_write;
    logic [31: 0] physical_address;
    logic         page_fault;
    logic         fault_present;
    logic [31: 0] fault_linear_address;
    logic         bus_valid;
    logic         bus_ready;
    logic         bus_we;
    logic [31: 0] bus_addr;
    logic [31: 0] bus_rdata;
    logic [31: 0] bus_wdata;

    logic [31: 0] mem [0: 4095];
    int           pass_count;

    always #1 clk = ~clk;

    paging_unit dut (
        .i_valid                 (valid),
        .o_ready                 (ready),
        .i_linear_address        (linear_address),
        .i_page_directory_base   (page_dir_base),
        .i_cpl                   (cpl),
        .i_is_write              (is_write),
        .i_tlb_invall            (1'b0),
        .i_tlb_invlpg            (1'b0),
        .i_tlb_invlpg_linear     (32'h0),
        .o_physical_address      (physical_address),
        .o_page_fault            (page_fault),
        .o_fault_present         (fault_present),
        .o_fault_linear_address  (fault_linear_address),
        .o_bus_valid             (bus_valid),
        .i_bus_ready             (bus_ready),
        .o_bus_write_enable      (bus_we),
        .o_bus_address           (bus_addr),
        .i_bus_data_read         (bus_rdata),
        .o_bus_data_write        (bus_wdata),
        .clk                     (clk),
        .rst_n                   (rst_n)
    );

    logic         bus_ready_r;

    assign bus_rdata = mem[bus_addr >> 2];

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            bus_ready_r <= 1'b0;
        end else begin
            bus_ready_r <= bus_valid;
        end
    end

    assign bus_ready = bus_ready_r;

    task automatic do_translate(
        input logic [31: 0] lin,
        input logic         write_en,
        input logic [ 1: 0] req_cpl
    );
        begin
            linear_address  = lin;
            is_write        = write_en;
            cpl             = req_cpl;
            valid           = 1'b0;
            @(posedge clk);
            valid           = 1'b1;
            while (~ready) @(posedge clk);
            valid           = 1'b0;
            @(posedge clk);
        end
    endtask

    initial begin
        clk               = 1'b0;
        rst_n             = 1'b0;
        valid             = 1'b0;
        linear_address    = 32'h0;
        page_dir_base     = 32'h0000;
        cpl               = 2'b00;
        is_write          = 1'b0;
        pass_count        = 0;

        mem[32'h0 >> 2]     = 32'h0000_2003;
        mem[32'h2000 >> 2]  = 32'h0000_3007;
        mem[32'h2004 >> 2]  = 32'h0000_0000;
        mem[32'h3000 >> 2]  = 32'h0000_0000;

        #4 rst_n = 1'b1;
        #2;

        do_translate(32'h0000_0123, 1'b0, 2'b00);
        if (page_fault || (physical_address != 32'h0000_3123)) begin
            $display("FAIL valid translation phys=%h fault=%b", physical_address, page_fault);
            $finish(1);
        end
        pass_count++;

        do_translate(32'h0000_1000, 1'b0, 2'b00);
        if (!page_fault || fault_present) begin
            $display("FAIL not-present PTE fault=%b present=%b", page_fault, fault_present);
            $finish(1);
        end
        if (fault_linear_address != 32'h0000_1000) begin
            $display("FAIL CR2 linear addr=%h", fault_linear_address);
            $finish(1);
        end
        pass_count++;

        mem[32'h2000 >> 2] = 32'h0000_4001;
        do_translate(32'h0000_0789, 1'b1, 2'b00);
        if (!page_fault || !fault_present) begin
            $display("FAIL write-protection fault=%b present=%b", page_fault, fault_present);
            $finish(1);
        end
        pass_count++;

        $display("PASS paging_unit_tb pass_count=%0d", pass_count);
        $finish;
    end

endmodule
