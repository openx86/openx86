// ============================================================================
// stage_3_exe
// ----------------------------------------------------------------------------
// Stage 3 (EXE / execute control): centralizes stall composition for execute.
// ============================================================================

module stage_3_exe (
    input  logic i_stage2_valid,
    input  logic i_cpuid_busy,
    input  logic i_xadd_wait_reg_wr,
    input  logic i_am_lsu_busy,
    input  logic i_muldiv_pair_wait,
    output logic o_exec_stall,
    output logic o_stage_valid
);

    always_comb begin
        o_exec_stall = i_cpuid_busy | i_xadd_wait_reg_wr | i_am_lsu_busy | i_muldiv_pair_wait;
        o_stage_valid = i_stage2_valid & ~o_exec_stall;
    end

endmodule
