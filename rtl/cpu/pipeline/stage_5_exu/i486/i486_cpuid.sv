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
//
// CPUID 指令实现：
// - Leaf 0: 返回厂商 ID 字符串（EBX, EDX, ECX）和最大支持的 leaf 值（EAX）
// - Leaf 1: 返回处理器签名（EAX）和特性标志（EDX, ECX）
// - 其他 leaf: 直通模式，EAX 返回输入值，其他寄存器返回 0
//
// GPR 写入顺序：EAX → EBX → EDX → ECX（4 个周期）
// ============================================================================
`include "openx86_defs.h.sv"

module i486_cpuid #(
    // ========================================
    // 厂商 ID 字符串配置（Leaf 0）
    // ========================================
    parameter logic [31: 0] P_VENDOR_EBX = 32'h756e6547,  // "Genu"
    parameter logic [31: 0] P_VENDOR_EDX = 32'h49656e69,  // "ineI"
    parameter logic [31: 0] P_VENDOR_ECX = 32'h6c65746e,  // "ntel"
    
    // ========================================
    // 处理器签名配置（Leaf 1 EAX）
    // ========================================
    parameter logic [ 3: 0] P_STEPPING_ID    = 4'h0,       // 步进 ID
    parameter logic [ 3: 0] P_MODEL_ID       = 4'h0,       // 型号 ID
    parameter logic [ 3: 0] P_FAMILY_ID      = 4'h6,       // 家族 ID (i486=4, i586=5, i686=6)
    parameter logic [ 1: 0] P_PROCESSOR_TYPE = 2'b0,       // 处理器类型 (0=OEM, 1=Overdrive, 2=Dual)
    parameter logic [ 3: 0] P_EXTENDED_MODEL = 4'h0,       // 扩展型号
    parameter logic [ 7: 0] P_EXTENDED_FAMILY = 8'h0,       // 扩展家族
    
    // ========================================
    // 最大支持的 leaf 值（Leaf 0 EAX）
    // ========================================
    parameter logic [31: 0] P_MAX_LEAF = 32'd1,             // 当前支持的最大 leaf
    
    // ========================================
    // 特性标志覆盖（Leaf 1 EDX）
    // ========================================
    parameter logic [31: 0] P_FEATURE_EDX = 32'h00000001   // 默认仅启用 FPU
) (
    input  logic          insn_fire,              // 指令触发信号
    input  logic          op_cpuid,               // CPUID 操作使能
    input  logic [31: 0]  gpr_eax,                // 输入：EAX（leaf 值）
    output logic         o_cpuid_busy,            // 输出：CPUID 忙标志
    output logic         o_gpr_wr_en,             // 输出：GPR 写使能
    output logic [ 2: 0] o_gpr_wr_idx,            // 输出：GPR 写索引（0=EAX, 1=ECX, 2=EDX, 3=EBX）
    output logic [31: 0] o_gpr_wr_data,           // 输出：GPR 写数据
    output logic         o_cpuid_done_pulse,      // 输出：CPUID 完成脉冲
    input  logic          clk,                     // 时钟信号
    input  logic          rst_n                    // 异步低有效复位
);

    // ========================================
    // 状态机定义：CPUID 写序列
    // ========================================
    typedef enum logic [ 2: 0] {
        CS_IDLE,      // 空闲状态，等待 CPUID 指令触发
        CS_W1,        // 写周期 1：写入 EAX
        CS_W2,        // 写周期 2：写入 EBX
        CS_W3,        // 写周期 3：写入 EDX
        CS_W4         // 写周期 4：写入 ECX，完成后返回空闲
    } cpuid_seq_e;

    // ========================================
    // 内部寄存器
    // ========================================
    cpuid_seq_e cpuid_st;          // 当前状态
    logic [31: 0] cpuid_leaf_latch; // 锁存的 leaf 值（来自 EAX）

    // ========================================
    // 组合逻辑：忙标志
    // ========================================
    assign o_cpuid_busy = (cpuid_st != CS_IDLE);

    // ========================================
    // 处理器签名构造（Leaf 1 EAX）
    // 格式：[31:28]扩展家族 [27:20]保留 [19:16]扩展型号 [15:14]处理器类型 [13:12]保留 [11:8]家族 [7:4]保留 [3:0]型号
    // ========================================
    localparam logic [31: 0] L_PROCESSOR_SIGNATURE = {
        P_EXTENDED_FAMILY,
        4'b0000,
        P_EXTENDED_MODEL,
        P_PROCESSOR_TYPE,
        2'b00,
        P_FAMILY_ID,
        4'b0000,
        P_MODEL_ID,
        P_STEPPING_ID
    };

    // ========================================
    // Leaf 1 EDX 特性标志构造函数
    // 使用参数 P_FEATURE_EDX 覆盖默认值
    // ========================================
    function automatic logic [31: 0] cpuid_leaf1_edx();
        begin
            // 如果参数 P_FEATURE_EDX 非零，则使用参数值
            // 否则使用宏定义的默认特性标志
            if (P_FEATURE_EDX != 32'h00000000) begin
                cpuid_leaf1_edx = P_FEATURE_EDX;
            end else begin
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
        end
    endfunction

    // ========================================
    // 时序逻辑：CPUID 状态机
    // ========================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位：初始化所有输出和状态
            cpuid_st          <= CS_IDLE;
            cpuid_leaf_latch  <= 32'h0;
            o_gpr_wr_en      <= 1'b0;
            o_gpr_wr_idx     <= '0;
            o_gpr_wr_data    <= '0;
            o_cpuid_done_pulse <= 1'b0;
        end else begin
            // 默认清除脉冲信号
            o_gpr_wr_en      <= 1'b0;
            o_cpuid_done_pulse <= 1'b0;

            unique case (cpuid_st)
                // ========================================
                // CS_IDLE: 等待 CPUID 指令触发
                // ========================================
                CS_IDLE: begin
                    if (insn_fire && op_cpuid) begin
                        // 锁存 EAX 中的 leaf 值，进入写序列
                        cpuid_leaf_latch <= gpr_eax;
                        cpuid_st         <= CS_W1;
                    end
                end

                // ========================================
                // CS_W1: 写周期 1 - 写入 EAX
                // ========================================
                CS_W1: begin
                    o_gpr_wr_en  <= 1'b1;
                    o_gpr_wr_idx <= 3'd0;  // EAX
                    unique case (cpuid_leaf_latch)
                        32'd0: o_gpr_wr_data <= P_MAX_LEAF;           // Leaf 0: 最大支持的 leaf
                        32'd1: o_gpr_wr_data <= L_PROCESSOR_SIGNATURE; // Leaf 1: 处理器签名
                        default: o_gpr_wr_data <= cpuid_leaf_latch;    // 其他: 直通模式
                    endcase
                    cpuid_st <= CS_W2;
                end

                // ========================================
                // CS_W2: 写周期 2 - 写入 EBX
                // ========================================
                CS_W2: begin
                    o_gpr_wr_en  <= 1'b1;
                    o_gpr_wr_idx <= 3'd3;  // EBX
                    if (cpuid_leaf_latch == 32'd0) begin
                        o_gpr_wr_data <= P_VENDOR_EBX;  // Leaf 0: 厂商 ID 第 1 部分
                    end else begin
                        o_gpr_wr_data <= 32'h0;        // 其他 leaf: 返回 0
                    end
                    cpuid_st <= CS_W3;
                end

                // ========================================
                // CS_W3: 写周期 3 - 写入 EDX
                // ========================================
                CS_W3: begin
                    o_gpr_wr_en  <= 1'b1;
                    o_gpr_wr_idx <= 3'd2;  // EDX
                    if (cpuid_leaf_latch == 32'd0) begin
                        o_gpr_wr_data <= P_VENDOR_EDX;  // Leaf 0: 厂商 ID 第 2 部分
                    end else if (cpuid_leaf_latch == 32'd1) begin
                        o_gpr_wr_data <= cpuid_leaf1_edx();  // Leaf 1: 特性标志
                    end else begin
                        o_gpr_wr_data <= 32'h0;        // 其他 leaf: 返回 0
                    end
                    cpuid_st <= CS_W4;
                end

                // ========================================
                // CS_W4: 写周期 4 - 写入 ECX，完成
                // ========================================
                CS_W4: begin
                    o_gpr_wr_en  <= 1'b1;
                    o_gpr_wr_idx <= 3'd1;  // ECX
                    if (cpuid_leaf_latch == 32'd0) begin
                        o_gpr_wr_data <= P_VENDOR_ECX;  // Leaf 0: 厂商 ID 第 3 部分
                    end else begin
                        o_gpr_wr_data <= 32'h0;        // 其他 leaf: 返回 0
                    end
                    cpuid_st          <= CS_IDLE;      // 返回空闲状态
                    o_cpuid_done_pulse <= 1'b1;        // 发出完成脉冲
                end

                default: cpuid_st <= CS_IDLE;
            endcase
        end
    end

endmodule
