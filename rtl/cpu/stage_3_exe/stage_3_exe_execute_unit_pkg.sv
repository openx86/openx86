// ============================================================================
// execute_unit 公共类型与常量（供 AGU / LSU / Branch / MulDiv / X87 子模块使用）
// ============================================================================

`ifndef EXECUTE_UNIT_PKG_SV
`define EXECUTE_UNIT_PKG_SV

package stage_3_exe_execute_unit_pkg;

    // 聚合顶层选择的执行簇（由译码/微码驱动）
    typedef enum logic [3:0] {
        EU_CLUSTER_IDLE = 4'h0,
        EU_CLUSTER_AGU    = 4'h1,
        EU_CLUSTER_LSU    = 4'h2,
        EU_CLUSTER_BRANCH = 4'h3,
        EU_CLUSTER_MULDIV = 4'h4,
        EU_CLUSTER_X87    = 4'h5
    } eu_cluster_e;

    // 乘除单元操作
    typedef enum logic [2:0] {
        MD_NOP    = 3'd0,
        MD_MULU32 = 3'd1,
        MD_IMUL32 = 3'd2,
        MD_DIVU32 = 3'd3,
        MD_IDIV32 = 3'd4
    } muldiv_op_e;

    // X87 子操作（简化整数/位级模型，非完整 IEEE 管线）
    typedef enum logic [4:0] {
        X87_NOP   = 5'd0,
        X87_FLD   = 5'd1,
        X87_FSTP  = 5'd2,
        X87_FADD  = 5'd3,
        X87_FSUB  = 5'd4,
        X87_FMUL  = 5'd5,
        X87_FDIV  = 5'd6,
        X87_FCHS  = 5'd7,
        X87_FABS  = 5'd8,
        X87_FXCH  = 5'd9,
        X87_FCOMI = 5'd10,
        X87_FLD_STI = 5'd11,
        X87_FST     = 5'd12,
        X87_FFREE   = 5'd13,
        X87_FCOM    = 5'd14,
        X87_FCOMP   = 5'd15,
        X87_FTST    = 5'd16,
        X87_FLD1    = 5'd17,
        X87_FLDZ    = 5'd18,
        X87_FNOP    = 5'd19,
        X87_FADDP   = 5'd20,
        X87_FMULP   = 5'd21,
        X87_FSUBP   = 5'd22,
        X87_FSUBRP  = 5'd23,
        X87_FDIVP   = 5'd24,
        X87_FDIVRP  = 5'd25,
        X87_FCOMIP  = 5'd26,
        X87_FUCOMIP = 5'd27,
        X87_FSUBR   = 5'd28,
        X87_FDIVR   = 5'd29
    } x87_op_e;

    // Unified integer op selector used by stage_3_exe_execute_unit dispatch.
    typedef enum logic [5:0] {
        INT_NOP = 6'd0,
        INT_ADD = 6'd1,
        INT_ADC = 6'd2,
        INT_SUB = 6'd3,
        INT_SBB = 6'd4,
        INT_AND = 6'd5,
        INT_OR  = 6'd6,
        INT_XOR = 6'd7,
        INT_NOT = 6'd8,
        INT_NEG = 6'd9,
        INT_INC = 6'd10,
        INT_DEC = 6'd11,
        INT_SHL = 6'd12,
        INT_SHR = 6'd13,
        INT_SAR = 6'd14,
        INT_ROL = 6'd15,
        INT_ROR = 6'd16,
        INT_SHLD = 6'd17,
        INT_SHRD = 6'd18,
        INT_RCL = 6'd19,
        INT_RCR = 6'd20,
        INT_BSF = 6'd21,
        INT_BSR = 6'd22,
        INT_BT = 6'd23,
        INT_BTS = 6'd24,
        INT_BTR = 6'd25,
        INT_BTC = 6'd26,
        INT_BSWAP = 6'd27,
        INT_AAA = 6'd28,
        INT_AAS = 6'd29,
        INT_DAA = 6'd30,
        INT_DAS = 6'd31,
        INT_AAD = 6'd32,
        INT_AAM = 6'd33,
        INT_CBW = 6'd34,
        INT_CDQ = 6'd35,
        INT_MOVSX = 6'd36,
        INT_MOVZX = 6'd37,
        INT_CLC = 6'd38,
        INT_STC = 6'd39,
        INT_CMC = 6'd40,
        INT_CLD = 6'd41,
        INT_STD = 6'd42,
        INT_CLI = 6'd43,
        INT_STI = 6'd44,
        INT_LAHF = 6'd45,
        INT_SAHF = 6'd46,
        INT_XCHG = 6'd47,
        INT_XADD = 6'd48,
        INT_CMPXCHG = 6'd49,
        INT_SETCC = 6'd50,
        INT_ARPL = 6'd51,
        INT_LAR = 6'd52,
        INT_LSL = 6'd53,
        INT_VERR = 6'd54,
        INT_STRIDX_STEP = 6'd55,
        INT_IMUL_IMM = 6'd56,
        INT_CLTS = 6'd57,
        INT_LMSW = 6'd58,
        INT_SMSW = 6'd59,
        INT_LOOP_CTRL = 6'd60
    } int_op_e;

endpackage

`endif
