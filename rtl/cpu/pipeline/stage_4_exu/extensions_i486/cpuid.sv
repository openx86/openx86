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
//  File        : cpuid.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : cpuid module
// ============================================================================

// ============================================================================
// cpuid — CPUID leaf 0/1 (and passthrough latch) GPR write sequence
// ============================================================================
`include "openx86_defs.h.sv"

module cpuid (
    input  logic          insn_fire, // 输入信号
    input  logic          op_cpuid, // 输入信号
    input  logic [31: 0]  gpr_eax, // 输入信号
    output logic         o_cpuid_busy, // 输出信号
    output logic         o_gpr_wr_en, // 输出信号
    output logic [ 2: 0] o_gpr_wr_idx, // 输出信号
    output logic [31: 0] o_gpr_wr_data, // 输出信号
    output logic         o_cpuid_done_pulse, // 输出信号
    input  logic          clk, // 时钟信号
    input  logic          rst_n // 复位信号
);

    typedef enum logic [ 2: 0] {
        CS_IDLE,
        CS_W1,
        CS_W2,
        CS_W3,
        CS_W4
    } cpuid_seq_e;

    cpuid_seq_e cpuid_st;
    logic [31: 0] cpuid_leaf_latch;

    assign o_cpuid_busy = (cpuid_st != CS_IDLE);

    localparam logic [31: 0] V_EBX = 32'h756e6547;
    localparam logic [31: 0] V_EDX = 32'h49656e69;
    localparam logic [31: 0] V_ECX = 32'h6c65746e;

    function automatic logic [31: 0] cpuid_leaf1_edx();
        begin
            cpuid_leaf1_edx = 32'({
                `cpuid_feature_pbe,
                `cpuid_feature_ia64,
                `cpuid_feature_tm,
                `cpuid_feature_htt,
                `cpuid_feature_ss,
                `cpuid_feature_sse2,
                `cpuid_feature_sse,
                `cpuid_feature_fxsr,
                `cpuid_feature_mmx,
                `cpuid_feature_acpi,
                `cpuid_feature_ds,
                `cpuid_feature_clfsh,
                `cpuid_feature_psn,
                `cpuid_feature_pse36,
                `cpuid_feature_pat,
                `cpuid_feature_cmov,
                `cpuid_feature_mca,
                `cpuid_feature_peg,
                `cpuid_feature_mtrr,
                `cpuid_feature_sep,
                `cpuid_feature_apic,
                `cpuid_feature_cx8,
                `cpuid_feature_mce,
                `cpuid_feature_pae,
                `cpuid_feature_msr,
                `cpuid_feature_tsc,
                `cpuid_feature_pse,
                `cpuid_feature_de,
                `cpuid_feature_vme,
                `cpuid_feature_fpu
            });
        end
    endfunction

    // 时序逻辑块
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cpuid_st <= CS_IDLE;
            cpuid_leaf_latch <= 32'h0;
            o_gpr_wr_en <= 1'b0;
            o_gpr_wr_idx <= '0;
            o_gpr_wr_data <= '0;
            o_cpuid_done_pulse <= 1'b0;
        end else begin
            o_gpr_wr_en <= 1'b0;
            o_cpuid_done_pulse <= 1'b0;

            unique case (cpuid_st)
                CS_IDLE: begin
                    if (insn_fire && op_cpuid) begin
                        cpuid_leaf_latch <= gpr_eax;
                        cpuid_st <= CS_W1;
                    end
                end
                CS_W1: begin
                    o_gpr_wr_en <= 1'b1;
                    o_gpr_wr_idx <= 3'd0;
                    unique case (cpuid_leaf_latch)
                        32'd0: o_gpr_wr_data <= 32'd1;
                        32'd1: o_gpr_wr_data <= {
                            `cpuid_extended_family_id,
                            `cpuid_extended_model_id,
                            `cpuid_processor_type,
                            2'b0,
                            `cpuid_family_id,
                            4'b0,
                            `cpuid_model_id,
                            `cpuid_stepping_id
                        };
                        default: o_gpr_wr_data <= cpuid_leaf_latch;
                    endcase
                    cpuid_st <= CS_W2;
                end
                CS_W2: begin
                    o_gpr_wr_en <= 1'b1;
                    o_gpr_wr_idx <= 3'd3;
                    if (cpuid_leaf_latch == 32'd0) begin
                        o_gpr_wr_data <= V_EBX;
                    end else if (cpuid_leaf_latch == 32'd1) begin
                        o_gpr_wr_data <= 32'h0;
                    end else begin
                        o_gpr_wr_data <= 32'h0;
                    end
                    cpuid_st <= CS_W3;
                end
                CS_W3: begin
                    o_gpr_wr_en <= 1'b1;
                    o_gpr_wr_idx <= 3'd2;
                    if (cpuid_leaf_latch == 32'd0) begin
                        o_gpr_wr_data <= V_EDX;
                    end else if (cpuid_leaf_latch == 32'd1) begin
                        o_gpr_wr_data <= cpuid_leaf1_edx();
                    end else begin
                        o_gpr_wr_data <= 32'h0;
                    end
                    cpuid_st <= CS_W4;
                end
                CS_W4: begin
                    o_gpr_wr_en <= 1'b1;
                    o_gpr_wr_idx <= 3'd1;
                    if (cpuid_leaf_latch == 32'd0) begin
                        o_gpr_wr_data <= V_ECX;
                    end else begin
                        o_gpr_wr_data <= 32'h0;
                    end
                    cpuid_st <= CS_IDLE;
                    o_cpuid_done_pulse <= 1'b1;
                end
                default: cpuid_st <= CS_IDLE;
            endcase
        end
    end

endmodule
