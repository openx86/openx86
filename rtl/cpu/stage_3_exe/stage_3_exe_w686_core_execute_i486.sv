/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_w686_core_execute_i486.
*/
// ============================================================================
// stage_3_exe_w686_core_execute_i486 — 80486 模式：多周期 CPUID、INVD/WBINVD/INVLPG 占位
// ============================================================================
`include "openx86_defs.h.sv"

module stage_3_exe_w686_core_execute_i486 (
    input  logic          insn_fire,  // 指令发射脉冲
    input  logic          op_cpuid,  // CPUID 微操作
    input  logic [31: 0]  gpr_eax,  // 当前 EAX（叶号）
    input  logic [31: 0]  gpr_ecx,  // 当前 ECX（子叶，占位）
    output logic         cpuid_busy,  // CPUID 序列忙
    output logic         gpr_wr_en,  // 通用寄存器写使能
    output logic [ 2: 0] gpr_wr_idx,  // 写回寄存器索引
    output logic [31: 0] gpr_wr_data,  // 写回数据
    output logic         cpuid_done_pulse,  // CPUID 完成脉冲
    input  logic          op_invd,  // INVD 微操作
    input  logic          op_wbinvd,  // WBINVD 微操作
    input  logic          op_invlpg,  // INVLPG 微操作
    input  logic [31: 0] invlpg_ea,  // INVLPG 线性地址
    output logic         cache_flush_pulse,  // 缓存冲刷脉冲
    output logic         invlpg_pulse,  // TLB 失效脉冲
    output logic [31: 0] invlpg_linear_addr,  // 失效线性地址输出
    input  logic          clk,  // 时钟
    input  logic          rst  // 复位（高有效）
);

    typedef enum logic [ 2: 0] {
        CS_IDLE,  // 空闲
        CS_W1,  // 写 EAX
        CS_W2,  // 写 EDX
        CS_W3,  // 写 ECX
        CS_W4   // 写 EBX 并结束
    } cpuid_seq_e;

    cpuid_seq_e cpuid_st;  // CPUID 多周期状态

    // 组合逻辑：连续赋值
    assign cpuid_busy = (cpuid_st != CS_IDLE);

    localparam logic [31: 0] V_EBX = 32'h756e6547;
    localparam logic [31: 0] V_EDX = 32'h49656e69;
    localparam logic [31: 0] V_ECX = 32'h6c65746e;

    function automatic logic [31: 0] cpuid_leaf1_edx();
        return {
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
        };
    endfunction

    // 时序逻辑：寄存器更新
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cpuid_st <= CS_IDLE;
            gpr_wr_en <= 1'b0;
            gpr_wr_idx <= '0;
            gpr_wr_data <= '0;
            cpuid_done_pulse <= 1'b0;
            cache_flush_pulse <= 1'b0;
            invlpg_pulse <= 1'b0;
            invlpg_linear_addr <= '0;
        end else begin
            gpr_wr_en <= 1'b0;
            cpuid_done_pulse <= 1'b0;
            cache_flush_pulse <= 1'b0;
            invlpg_pulse <= 1'b0;

            if (insn_fire && op_invd) begin
                cache_flush_pulse <= 1'b1;
            end
            if (insn_fire && op_wbinvd) begin
                cache_flush_pulse <= 1'b1;
            end
            if (insn_fire && op_invlpg) begin
                invlpg_pulse <= 1'b1;
                invlpg_linear_addr <= invlpg_ea;
            end

            // CPUID 节拍状态机
            unique case (cpuid_st)
                CS_IDLE: begin
                    if (insn_fire && op_cpuid) begin
                        cpuid_st <= CS_W1;
                    end
                end
                CS_W1: begin
                    gpr_wr_en <= 1'b1;
                    gpr_wr_idx <= 3'd0;
                    // 叶 0/1：返回最大叶号或 family/model/stepping
                    unique case (gpr_eax)
                        32'd0: gpr_wr_data <= 32'd1;
                        32'd1: gpr_wr_data <= {
                            `cpuid_extended_family_id,
                            `cpuid_extended_model_id,
                            `cpuid_processor_type,
                            2'b0,
                            `cpuid_family_id,
                            4'b0,
                            `cpuid_model_id,
                            `cpuid_stepping_id
                        };
                        default: gpr_wr_data <= gpr_eax;
                    endcase
                    cpuid_st <= CS_W2;
                end
                CS_W2: begin
                    gpr_wr_en <= 1'b1;
                    gpr_wr_idx <= 3'd3;
                    // 叶 0：厂商串 EBX；其余写 0
                    if (gpr_eax == 32'd0) begin
                        gpr_wr_data <= V_EBX;
                    end else if (gpr_eax == 32'd1) begin
                        gpr_wr_data <= 32'h0;
                    end else begin
                        gpr_wr_data <= 32'h0;
                    end
                    cpuid_st <= CS_W3;
                end
                CS_W3: begin
                    gpr_wr_en <= 1'b1;
                    gpr_wr_idx <= 3'd2;
                    // 叶 0：厂商串 EDX；叶 1：特征位 EDX
                    if (gpr_eax == 32'd0) begin
                        gpr_wr_data <= V_EDX;
                    end else if (gpr_eax == 32'd1) begin
                        gpr_wr_data <= cpuid_leaf1_edx();
                    end else begin
                        gpr_wr_data <= 32'h0;
                    end
                    cpuid_st <= CS_W4;
                end
                CS_W4: begin
                    gpr_wr_en <= 1'b1;
                    gpr_wr_idx <= 3'd1;
                    // 叶 0：厂商串 ECX；其余写 0
                    if (gpr_eax == 32'd0) begin
                        gpr_wr_data <= V_ECX;
                    end else begin
                        gpr_wr_data <= 32'h0;
                    end
                    cpuid_st <= CS_IDLE;
                    cpuid_done_pulse <= 1'b1;
                end
                default: cpuid_st <= CS_IDLE;
            endcase
        end
    end

endmodule
