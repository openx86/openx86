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
//  File        : memory_management_unit_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : MMU flat segmentation and paging integration smoke test
// ============================================================================

`timescale 1ns/1ns

`include "openx86_defs.h.sv"

module memory_management_unit_tb;

    logic         clk;
    logic         rst_n;
    logic         valid;
    logic         ready;
    logic         protected_mode;
    logic [ 5: 0][15: 0] segment_selector;
    logic [ 5: 0][63: 0] segment_descriptor;
    logic [ 1: 0] cpl;
    logic [ 2: 0] segment_index;
    logic [31: 0] effective_address;
    logic         write_enable;
    logic         paging_enable;
    logic [31: 0] page_directory_base;
    logic [31: 0] physical_address;
    logic         segment_fault;
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
    logic         bus_ready_r;
    int           pass_count;

    localparam logic [63: 0] LP_FLAT_CODE_DESC = 64'h0000_FFFF_004F_CD00;

    always #1 clk = ~clk;

    assign bus_rdata = mem[bus_addr >> 2];

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            bus_ready_r <= 1'b0;
        end else begin
            bus_ready_r <= bus_valid;
        end
    end

    assign bus_ready = bus_ready_r;

    memory_management_unit dut (
        .i_valid                 (valid),
        .o_ready                 (ready),
        .i_protected_mode        (protected_mode),
        .i_segment_selector      (segment_selector),
        .i_segment_descriptor    (segment_descriptor),
        .i_current_privilege_level (cpl),
        .i_segment_index         (segment_index),
        .i_effective_address     (effective_address),
        .i_write_enable          (write_enable),
        .i_paging_enable         (paging_enable),
        .i_page_directory_base   (page_directory_base),
        .o_physical_address      (physical_address),
        .o_segment_fault         (segment_fault),
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

    task automatic do_translate(
        input logic [31: 0] ea,
        input logic         paging_on
    );
        begin
            effective_address   = ea;
            paging_enable       = paging_on;
            valid               = 1'b0;
            @(posedge clk);
            valid               = 1'b1;
            while (~ready) @(posedge clk);
            valid               = 1'b0;
            @(posedge clk);
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        protected_mode = 1'b1;
        cpl = 2'b00;
        segment_index = `index_reg_seg__CS;
        write_enable = 1'b0;
        paging_enable = 1'b0;
        page_directory_base = 32'h0;
        segment_selector = '{default: 16'h0};
        segment_descriptor = '{default: 64'h0};
        segment_selector[`index_reg_seg__CS] = 16'h0008;
        segment_descriptor[`index_reg_seg__CS] = LP_FLAT_CODE_DESC;
        mem[32'h0 >> 2] = 32'h0000_2003;
        mem[32'h2000 >> 2] = 32'h0000_0000;
        pass_count = 0;
        #8 rst_n = 1'b1;
        @(posedge clk);

        do_translate(32'h0000_0100, 1'b0);
        if ((~segment_fault) && (physical_address == 32'h0000_0100)) begin
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL memory_management_unit_tb flat translate pa=%08h sf=%b",
                     physical_address, segment_fault);
            $finish(1);
        end

        do_translate(32'h0000_0200, 1'b1);
        if ((~segment_fault) && (~page_fault) && (physical_address == 32'h0000_0200)) begin
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL memory_management_unit_tb paging translate pa=%08h pf=%b sf=%b",
                     physical_address, page_fault, segment_fault);
            $finish(1);
        end

        if (pass_count == 2) begin
            $display("PASS memory_management_unit_tb flat+paging");
        end
        $finish;
    end

endmodule
