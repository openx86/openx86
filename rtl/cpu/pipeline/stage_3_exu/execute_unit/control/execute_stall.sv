/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements execute_stall.
*/
// ============================================================================
// execute_stall
// ----------------------------------------------------------------------------
// Stage 3 (EXE / execute control): centralizes stall composition for execute.
// ============================================================================


    input  logic i_stage2_valid,  // 上一流水级有效
    input  logic i_cpuid_busy, // CPUID 忙
    input  logic i_xadd_wait_reg_wr, // XADD 等待写回
    input  logic i_am_lsu_busy, // 访存单元忙
    input  logic i_muldiv_pair_wait, // 乘除配对等待
    output logic o_exec_stall, // 执行级停顿
    output logic o_stage_ready, // 执行级可接收
    output logic o_stage_valid // 本流水级有效输出
);
    // 组合逻辑：推导输出
    always_comb begin
        o_exec_stall = i_cpuid_busy | i_xadd_wait_reg_wr | i_am_lsu_busy | i_muldiv_pair_wait;
        o_stage_ready = ~o_exec_stall;
        o_stage_valid = i_stage2_valid & o_stage_ready;
    end

endmodule
