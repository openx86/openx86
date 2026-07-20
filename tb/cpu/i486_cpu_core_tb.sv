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

    logic [31: 0] mmu_mem [0: 4095];
    logic         mmu_ready_r;

    int           code_fetch_count;
    int           cycle_count;
    bit           pf_test_phase;
    bit           pf_cr2_seen;
    bit           pf_vector_seen;

    localparam logic [63: 0] LP_FLAT_CODE_DESC = 64'h0000_FFFF_004F_CD00;

    always #1 clk = ~clk;

    assign mmu_data_read = mmu_mem[mmu_address >> 2];

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            mmu_ready_r <= 1'b0;
        end else begin
            mmu_ready_r <= mmu_valid;
        end
    end

    assign mmu_ready = pf_test_phase ? mmu_ready_r : 1'b1;

    task automatic setup_protected_paging();
        begin
            mmu_mem[32'h0 >> 2]    = 32'h0000_2003;
            mmu_mem[32'h2000 >> 2] = 32'h0000_0000;

            @(posedge clk);
            dut.u_rf_cr0.register              = 32'h8000_0001;
            dut.u_rf_cr3.register              = 32'h0000_0000;
            dut.u_rf_seg_cs.o_selector         = 16'h0008;
            dut.u_rf_seg_cs.o_descriptor       = LP_FLAT_CODE_DESC;
            dut.u_pipeline.u_ifu.eip_r         = 32'h0000_0000;
            dut.u_pipeline.u_ifu.page_fault_r  = 1'b0;
            dut.u_pipeline.u_ifu.segment_fault_r = 1'b0;
            dut.u_pipeline.u_ifu.fetch_active_r  = 1'b0;
            dut.u_pipeline.u_ifu.fetch_code_phase = 1'b0;
            dut.u_pipeline.u_ifu.fetch_word_idx_r = 2'b00;
            dut.u_pipeline.u_ifu.u_stage_1_ifu_fifo.count = 5'd0;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        code_ready = 1'b1;
        data_ready = 1'b1;
        code_data_read = 32'h9090_9090;
        data_data_read = 32'h0;
        code_fetch_count = 0;
        cycle_count = 0;
        pf_test_phase = 1'b0;
        pf_cr2_seen = 1'b0;
        pf_vector_seen = 1'b0;
        #8 rst_n = 1'b1;
    end

    always @(posedge clk) begin
        if (rst_n) begin
            cycle_count <= cycle_count + 1;

            if (~pf_test_phase) begin
                if (code_valid & code_ready) begin
                    code_fetch_count <= code_fetch_count + 1;
                end
                if (cycle_count == 64) begin
                    if (code_fetch_count == 0) begin
                        $display("FAIL i486_cpu_core_tb no code fetch activity");
                        $finish(1);
                    end
                    pf_test_phase <= 1'b1;
                    setup_protected_paging();
                end
            end else begin
                if (dut.u_pipeline.o_wrb_cr2_write_enable &&
                    (dut.u_pipeline.o_wrb_cr_write_data == 32'h0000_0000)) begin
                    pf_cr2_seen <= 1'b1;
                end
                if (dut.u_pipeline.ifu_page_fault) begin
                    pf_vector_seen <= 1'b1;
                end
                if (cycle_count == 256) begin
                    if (pf_cr2_seen && pf_vector_seen) begin
                        $display("PASS i486_cpu_core_tb code_fetch_count=%0d pf_cr2=1 pm=1",
                                 code_fetch_count);
                    end else begin
                        $display("FAIL i486_cpu_core_tb pf_cr2=%b pf_vector=%b fetch=%0d",
                                 pf_cr2_seen, pf_vector_seen, code_fetch_count);
                    end
                    $finish;
                end
                if (cycle_count == 192) begin
                    if (dut.u_rf_cr0.register[31]) begin
                        $display("INFO i486_cpu_core_tb protected_mode_cr0=1");
                    end
                end
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
