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
//  File        : segment_load_unit_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : segment_load_unit MOV DS + GDT descriptor load smoke test
// ============================================================================

`timescale 1ns/1ns

`include "openx86_defs.h.sv"

module segment_load_unit_tb;

    localparam logic [ 1: 0] LP_OP_MOV_SEG   = 2'b00;
    localparam logic [ 1: 0] LP_OP_FAR_JMP  = 2'b01;
    localparam logic [ 1: 0] LP_OP_FAR_RET  = 2'b11;

    logic         clk;
    logic         rst_n;
    logic         valid;
    logic         ready;
    logic [ 1: 0] op_type;
    logic         protected_mode;
    logic [ 1: 0] cpl;
    logic [15: 0] selector;
    logic [ 2: 0] target_seg_index;
    logic [31: 0] gdtr_base;
    logic [15: 0] gdtr_limit;
    logic [15: 0] ldtr_selector;
    logic [63: 0] ldtr_descriptor;
    logic [31: 0] far_offset;
    logic [15: 0] far_selector;
    logic         seg_write_enable;
    logic [ 2: 0] seg_write_index;
    logic [15: 0] seg_write_selector;
    logic [63: 0] seg_write_descriptor;
    logic         ip_write_enable;
    logic [31: 0] ip_write_data;
    logic         segment_not_present;
    logic         stack_segment_fault;
    logic         segment_fault;
    logic         bus_valid;
    logic         bus_ready;
    logic         bus_we;
    logic [31: 0] bus_addr;
    logic [31: 0] bus_rdata;
    logic [31: 0] bus_wdata;

    logic [31: 0] mem [0: 4095];
    logic [63: 0] expected_descriptor;
    int           pass_count;

    segment_descriptor_encode u_desc_enc (
        .i_base                                      (32'h0001_0000),
        .i_limit                                     (20'hF_FFFF),
        .i_present                                   (1'b1),
        .i_privilege_level                           (2'b00),
        .i_available_field                           (1'b0),
        .i_descriptor_type                           (1'b1),
        .i_date_or_code_granularity                  (1'b1),
        .i_date_or_code_default_operation_size       (1'b1),
        .i_date_or_code_executable                   (1'b1),
        .i_data_expansion_direction_code_conforming  (1'b0),
        .i_data_writeable_code_readable              (1'b1),
        .i_date_or_code_accessed                     (1'b0),
        .o_descriptor                                (expected_descriptor)
    );

    always #1 clk = ~clk;

    segment_load_unit dut (
        .i_valid                 (valid),
        .o_ready                 (ready),
        .i_op_type               (op_type),
        .i_protected_mode        (protected_mode),
        .i_cpl                   (cpl),
        .i_selector              (selector),
        .i_target_seg_index      (target_seg_index),
        .i_gdtr_base             (gdtr_base),
        .i_gdtr_limit            (gdtr_limit),
        .i_ldtr_selector         (ldtr_selector),
        .i_ldtr_descriptor       (ldtr_descriptor),
        .i_far_offset            (far_offset),
        .i_far_selector          (far_selector),
        .o_seg_write_enable      (seg_write_enable),
        .o_seg_write_index       (seg_write_index),
        .o_seg_write_selector    (seg_write_selector),
        .o_seg_write_descriptor  (seg_write_descriptor),
        .o_ip_write_enable       (ip_write_enable),
        .o_ip_write_data         (ip_write_data),
        .o_segment_not_present   (segment_not_present),
        .o_stack_segment_fault   (stack_segment_fault),
        .o_segment_fault         (segment_fault),
        .o_bus_valid             (bus_valid),
        .i_bus_ready             (bus_ready),
        .o_bus_write_enable      (bus_we),
        .o_bus_address           (bus_addr),
        .i_bus_data_read         (bus_rdata),
        .o_bus_data_write        (bus_wdata),
        .clk                     (clk),
        .rst_n                   (rst_n)
    );

    logic bus_ready_r;

    assign bus_rdata = mem[bus_addr >> 2];

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            bus_ready_r <= 1'b0;
        end else begin
            bus_ready_r <= bus_valid;
        end
    end

    assign bus_ready = bus_ready_r;

    task automatic do_far_op(
        input logic [ 1: 0] op,
        input logic [31: 0] f_offset,
        input logic [15: 0] f_selector
    );
        begin
            op_type      = op;
            far_offset   = f_offset;
            far_selector = f_selector;
            valid        = 1'b0;
            @(posedge clk);
            valid        = 1'b1;
            // Sample completion strobes on the ready cycle (IDLE clears them next).
            while (~ready) @(posedge clk);
            valid        = 1'b0;
        end
    endtask

    task automatic do_mov_ds(input logic [15: 0] sel);
        begin
            selector          = sel;
            target_seg_index  = `sreg_index_DS;
            op_type           = LP_OP_MOV_SEG;
            valid             = 1'b0;
            @(posedge clk);
            valid             = 1'b1;
            while (~ready) @(posedge clk);
            valid             = 1'b0;
        end
    endtask

    initial begin
        clk              = 1'b0;
        rst_n            = 1'b0;
        valid            = 1'b0;
        op_type          = LP_OP_MOV_SEG;
        protected_mode   = 1'b1;
        cpl              = 2'b00;
        selector         = 16'h0;
        target_seg_index = `sreg_index_DS;
        gdtr_base        = 32'h0000_1000;
        gdtr_limit       = 16'h0040;
        ldtr_selector    = 16'h0;
        ldtr_descriptor  = 64'h0;
        far_offset       = 32'h0;
        far_selector     = 16'h0;
        pass_count       = 0;

        mem[32'h1018 >> 2] = {expected_descriptor[63: 48], expected_descriptor[47: 32]};
        mem[32'h101C >> 2] = expected_descriptor[31: 0];

        #4 rst_n = 1'b1;
        #2;

        do_mov_ds(16'h0018);
        if (segment_not_present || stack_segment_fault || segment_fault) begin
            $fatal(1, "FAIL MOV DS fault np=%b ss=%b gp=%b", segment_not_present,
                   stack_segment_fault, segment_fault);
        end
        if (~seg_write_enable || (seg_write_index != `sreg_index_DS)) begin
            $fatal(1, "FAIL MOV DS no seg write en=%b idx=%0d", seg_write_enable, seg_write_index);
        end
        if (seg_write_selector != 16'h0018) begin
            $fatal(1, "FAIL MOV DS selector=%h", seg_write_selector);
        end
        if (seg_write_descriptor != expected_descriptor) begin
            $fatal(1, "FAIL MOV DS descriptor=%h expected=%h",
                   seg_write_descriptor, expected_descriptor);
        end
        if (ip_write_enable) begin
            $fatal(1, "FAIL MOV DS unexpected IP write");
        end
        pass_count++;

        mem[32'h8000 >> 2] = 32'h0000_1234;
        mem[32'h8004 >> 2] = 32'h0000_0018;
        protected_mode     = 1'b1;
        do_far_op(LP_OP_FAR_JMP, 32'h0000_5678, 16'h0018);
        if (segment_not_present || stack_segment_fault || segment_fault) begin
            $fatal(1, "FAIL FAR JMP fault np=%b ss=%b gp=%b", segment_not_present,
                   stack_segment_fault, segment_fault);
        end
        if (~seg_write_enable || (seg_write_index != `sreg_index_CS) ||
            (seg_write_selector != 16'h0018) || (seg_write_descriptor != expected_descriptor) ||
            ~ip_write_enable || (ip_write_data != 32'h0000_5678)) begin
            $fatal(1, "FAIL FAR JMP cs=%h ip=%h en=%b", seg_write_selector, ip_write_data,
                   seg_write_enable);
        end
        pass_count++;

        do_far_op(LP_OP_FAR_RET, 32'h0000_8000, 16'h0);
        if (segment_not_present || stack_segment_fault || segment_fault) begin
            $fatal(1, "FAIL FAR RET fault np=%b ss=%b gp=%b", segment_not_present,
                   stack_segment_fault, segment_fault);
        end
        if (~seg_write_enable || (seg_write_index != `sreg_index_CS) ||
            (seg_write_selector != 16'h0018) || ~ip_write_enable ||
            (ip_write_data != 32'h0000_1234)) begin
            $fatal(1, "FAIL FAR RET cs=%h ip=%h", seg_write_selector, ip_write_data);
        end
        pass_count++;

        protected_mode = 1'b0;
        do_mov_ds(16'h0020);
        // Real-mode loads fill hidden cache: base=sel<<4, limit=FFFF, AR=93
        if (~seg_write_enable || (seg_write_selector != 16'h0020) ||
            (seg_write_descriptor != 64'h0200_FFFF_0000_9300)) begin
            $fatal(1, "FAIL real-mode MOV DS sel=%h desc=%h", seg_write_selector, seg_write_descriptor);
        end
        pass_count++;

        $display("PASS segment_load_unit_tb pass_count=%0d", pass_count);
        $finish;
    end

endmodule
