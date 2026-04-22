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
//  File        : execute_i486_cpuid_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : execute_i486_cpuid_tb module
// ============================================================================

// ============================================================================
// execute_unit — CPUID 多周期写回冒烟（iverilog -g2012 / Verilator）
// ============================================================================
`timescale 1ns/1ns

module execute_i486_cpuid_tb;

    logic clk;
    logic rst_n;
    logic insn_fire;
    logic op_cpuid;
    logic [31: 0] gpr_eax;
    logic [31: 0] gpr_ecx;
    logic cpuid_busy;
    logic gpr_wr_en;
    logic [ 2: 0] gpr_wr_idx;
    logic [31: 0] gpr_wr_data;
    logic cpuid_done_pulse;
    logic op_invd;
    logic op_wbinvd;
    logic op_invlpg;
    logic [31: 0] invlpg_ea;
    logic cache_flush_pulse;
    logic invlpg_pulse;
    logic [31: 0] invlpg_linear_addr;
    logic load_eax;
    logic [31: 0] load_eax_data;

    logic [ 2: 0] wr_idx_hist [ 0: 3];
    logic [31: 0] wr_data_hist [ 0: 3];
    int wr_hist_count;
    logic done_seen;

    localparam logic [31: 0] V_EBX = 32'h756e6547;
    localparam logic [31: 0] V_EDX = 32'h49656e69;
    localparam logic [31: 0] V_ECX = 32'h6c65746e;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    execute_unit_i486_ext u_dut (
        .clk ( clk ),
        .rst_n ( rst_n ),
        .insn_fire ( insn_fire ),
        .op_cpuid ( op_cpuid ),
        .gpr_eax ( gpr_eax ),
        .gpr_ecx ( gpr_ecx ),
        .cpuid_busy ( cpuid_busy ),
        .gpr_wr_en ( gpr_wr_en ),
        .gpr_wr_idx ( gpr_wr_idx ),
        .gpr_wr_data ( gpr_wr_data ),
        .cpuid_done_pulse ( cpuid_done_pulse ),
        .op_invd ( op_invd ),
        .op_wbinvd ( op_wbinvd ),
        .op_invlpg ( op_invlpg ),
        .invlpg_ea ( invlpg_ea ),
        .cache_flush_pulse ( cache_flush_pulse ),
        .invlpg_pulse ( invlpg_pulse ),
        .invlpg_linear_addr ( invlpg_linear_addr )
    );

    // 模拟 core 中 EAX 在 CPUID 写回后的可见行为，避免测试与真实流水线脱节。
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gpr_eax <= 32'h0;
        end else if (load_eax) begin
            gpr_eax <= load_eax_data;
        end else if (gpr_wr_en && (gpr_wr_idx == 3'd0)) begin
            gpr_eax <= gpr_wr_data;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_hist_count <= 0;
            done_seen <= 1'b0;
        end else begin
            if (gpr_wr_en) begin
                if (wr_hist_count < 4) begin
                    wr_idx_hist[wr_hist_count] <= gpr_wr_idx;
                    wr_data_hist[wr_hist_count] <= gpr_wr_data;
                end
                wr_hist_count <= wr_hist_count + 1;
            end
            if (cpuid_done_pulse) begin
                done_seen <= 1'b1;
            end
        end
    end

    task automatic launch_cpuid(input logic [31: 0] leaf);
        begin
            @(posedge clk);
            load_eax = 1'b1;
            load_eax_data = leaf;
            op_cpuid = 1'b1;
            insn_fire = 1'b1;

            @(posedge clk);
            load_eax = 1'b0;
            op_cpuid = 1'b0;
            insn_fire = 1'b0;
        end
    endtask

    initial begin
        int unsigned wait_cycles;

        rst_n = 1'b0;
        insn_fire = 1'b0;
        op_cpuid = 1'b0;
        gpr_ecx = 32'h0;
        op_invd = 1'b0;
        op_wbinvd = 1'b0;
        op_invlpg = 1'b0;
        invlpg_ea = 32'h0;
        load_eax = 1'b0;
        load_eax_data = 32'h0;
        #22 rst_n = 1'b1;

        launch_cpuid(32'd0);

        wait_cycles = 0;
        while (!done_seen && (wait_cycles < 20)) begin
            @(posedge clk);
            wait_cycles = wait_cycles + 1;
        end

        if (!done_seen) begin
            $display("FAIL: cpuid_done_pulse timeout");
            $finish(1);
        end

        if (wr_hist_count != 4) begin
            $display("FAIL: CPUID write count expected=4 actual=%0d", wr_hist_count);
            $finish(1);
        end

        if ((wr_idx_hist[0] !== 3'd0) || (wr_data_hist[0] !== 32'd1)) begin
            $display("FAIL: CPUID write0 expected EAX=1, got idx=%0d data=%h", wr_idx_hist[0], wr_data_hist[0]);
            $finish(1);
        end
        if ((wr_idx_hist[1] !== 3'd3) || (wr_data_hist[1] !== V_EBX)) begin
            $display("FAIL: CPUID write1 expected EBX=%h, got idx=%0d data=%h", V_EBX, wr_idx_hist[1], wr_data_hist[1]);
            $finish(1);
        end
        if ((wr_idx_hist[2] !== 3'd2) || (wr_data_hist[2] !== V_EDX)) begin
            $display("FAIL: CPUID write2 expected EDX=%h, got idx=%0d data=%h", V_EDX, wr_idx_hist[2], wr_data_hist[2]);
            $finish(1);
        end
        if ((wr_idx_hist[3] !== 3'd1) || (wr_data_hist[3] !== V_ECX)) begin
            $display("FAIL: CPUID write3 expected ECX=%h, got idx=%0d data=%h", V_ECX, wr_idx_hist[3], wr_data_hist[3]);
            $finish(1);
        end

        $display("execute_i486_cpuid_tb PASS");
        $finish;
    end

endmodule
