// ============================================================================
// execute_unit 公共类型与常量（供 AGU / LSU / Branch / MulDiv / X87 子模块使用）
// ============================================================================

`ifndef EXECUTE_UNIT_PKG_SV
`define EXECUTE_UNIT_PKG_SV

package execute_unit_pkg;

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

endpackage

`endif
