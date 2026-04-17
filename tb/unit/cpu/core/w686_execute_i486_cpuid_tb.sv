/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements w686_execute_i486_cpuid_tb.
*/
// ============================================================================
// stage_3_exe_w686_core_execute_i486 — CPUID 多周期写回冒烟（iverilog -g2012 / Verilator）
// ============================================================================
`timescale 1ns/1ns

module w686_execute_i486_cpuid_tb;

    logic clk;
    logic rst;
    logic insn_fire;
    logic op_cpuid;
    logic [31:  0] gpr_eax;
    logic [31:  0] gpr_ecx;
    logic cpuid_busy;
    logic gpr_wr_en;
    logic [ 2:  0] gpr_wr_idx;
    logic [31:  0] gpr_wr_data;
    logic cpuid_done_pulse;
    logic op_invd;
    logic op_wbinvd;
    logic op_invlpg;
    logic [31:  0] invlpg_ea;
    logic cache_flush_pulse;
    logic invlpg_pulse;
    logic [31:  0] invlpg_linear_addr;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    stage_3_exe_w686_core_execute_i486 u_dut (
        .clk ( clk ),
        .rst ( rst ),
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

    initial begin
        rst = 1'b1;
        insn_fire = 1'b0;
        op_cpuid = 1'b0;
        gpr_eax = 32'd0;
        gpr_ecx = 32'h0;
        op_invd = 1'b0;
        op_wbinvd = 1'b0;
        op_invlpg = 1'b0;
        invlpg_ea = 32'h0;
        #22 rst = 1'b0;

        @(posedge clk);
        gpr_eax = 32'd0;
        op_cpuid = 1'b1;
        insn_fire = 1'b1;
        @(posedge clk);
        insn_fire = 1'b0;

        repeat (10) @(posedge clk);

        if (!cpuid_done_pulse) begin
            $display("FAIL: cpuid_done_pulse");
            $finish(1);
        end
        $display("w686_execute_i486_cpuid_tb PASS");
        $finish;
    end

endmodule
