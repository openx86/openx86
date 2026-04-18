/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This package defines shared declarations for stage_3_exe_execute_unit_pkg.
*/
// ============================================================================
// execute_unit 公共类型与常量（供 AGU / LSU / Branch / MulDiv / X87 子模块使用）
// ============================================================================

`ifndef EXECUTE_UNIT_PKG_SV
`define EXECUTE_UNIT_PKG_SV

package stage_3_exe_execute_unit_pkg;

    // 聚合顶层选择的执行簇（由译码/微码驱动）
    typedef enum logic [ 3: 0] {
        EU_CLUSTER_IDLE = 4'h0,  // 空闲
        EU_CLUSTER_AGU    = 4'h1,  // 地址生成 AGU
        EU_CLUSTER_LSU    = 4'h2,  // 访存 LSU
        EU_CLUSTER_BRANCH = 4'h3,  // 分支
        EU_CLUSTER_MULDIV = 4'h4,  // 乘除
        EU_CLUSTER_X87    = 4'h5   // 浮点栈 X87
    } eu_cluster_e;

    // 乘除单元操作
    typedef enum logic [ 2: 0] {
        MD_NOP    = 3'd0,  // 无操作
        MD_MULU32 = 3'd1,  // 无符号 32×32 乘
        MD_IMUL32 = 3'd2,  // 有符号 32×32 乘
        MD_DIVU32 = 3'd3,  // 无符号 64÷32 除
        MD_IDIV32 = 3'd4   // 有符号 64÷32 除
    } muldiv_op_e;

    // X87 子操作（简化整数/位级模型，非完整 IEEE 管线）
    typedef enum logic [ 4: 0] {
        X87_NOP   = 5'd0,  // 空操作
        X87_FLD   = 5'd1,  // 压栈加载
        X87_FSTP  = 5'd2,  // 存储并弹出
        X87_FADD  = 5'd3,  // 加
        X87_FSUB  = 5'd4,  // 减
        X87_FMUL  = 5'd5,  // 乘
        X87_FDIV  = 5'd6,  // 除
        X87_FCHS  = 5'd7,  // 变号
        X87_FABS  = 5'd8,  // 绝对值
        X87_FXCH  = 5'd9,  // 交换栈顶
        X87_FCOMI = 5'd10, // 比较并写整数标志
        X87_FLD_STI = 5'd11, // 从 STi 压栈加载
        X87_FST     = 5'd12, // 存储实数
        X87_FFREE   = 5'd13, // 释放寄存器标记
        X87_FCOM    = 5'd14, // 比较
        X87_FCOMP   = 5'd15, // 比较并出栈
        X87_FTST    = 5'd16, // 与 0 比较
        X87_FLD1    = 5'd17, // 压入 1
        X87_FLDZ    = 5'd18, // 压入 0
        X87_FNOP    = 5'd19, // 浮点空操作
        X87_FADDP   = 5'd20, // 相加并弹出
        X87_FMULP   = 5'd21, // 相乘并弹出
        X87_FSUBP   = 5'd22, // 相减并弹出
        X87_FSUBRP  = 5'd23, // 反向减并弹出
        X87_FDIVP   = 5'd24, // 相除并弹出
        X87_FDIVRP  = 5'd25, // 反向除并弹出
        X87_FCOMIP  = 5'd26, // 比较写标志并弹出
        X87_FUCOMIP = 5'd27, // 无序比较写标志并弹出
        X87_FSUBR   = 5'd28, // 反向减
        X87_FDIVR   = 5'd29  // 反向除
    } x87_op_e;

    // execute_unit 整数分派统一操作码（译码侧与组合汇聚共用）
    typedef enum logic [ 5: 0] {
        INT_NOP = 6'd0,  // 空
        INT_ADD = 6'd1,  // ADD
        INT_ADC = 6'd2,  // ADC
        INT_SUB = 6'd3,  // SUB
        INT_SBB = 6'd4,  // SBB
        INT_AND = 6'd5,  // AND
        INT_OR  = 6'd6,  // OR
        INT_XOR = 6'd7,  // XOR
        INT_NOT = 6'd8,  // NOT
        INT_NEG = 6'd9,  // NEG
        INT_INC = 6'd10, // INC
        INT_DEC = 6'd11, // DEC
        INT_SHL = 6'd12, // SHL/SAL
        INT_SHR = 6'd13, // SHR
        INT_SAR = 6'd14, // SAR
        INT_ROL = 6'd15, // ROL
        INT_ROR = 6'd16, // ROR
        INT_SHLD = 6'd17, // SHLD
        INT_SHRD = 6'd18, // SHRD
        INT_RCL = 6'd19, // RCL
        INT_RCR = 6'd20, // RCR
        INT_BSF = 6'd21, // BSF
        INT_BSR = 6'd22, // BSR
        INT_BT = 6'd23,  // BT
        INT_BTS = 6'd24, // BTS
        INT_BTR = 6'd25, // BTR
        INT_BTC = 6'd26, // BTC
        INT_BSWAP = 6'd27, // BSWAP
        INT_AAA = 6'd28, // AAA
        INT_AAS = 6'd29, // AAS
        INT_DAA = 6'd30, // DAA
        INT_DAS = 6'd31, // DAS
        INT_AAD = 6'd32, // AAD
        INT_AAM = 6'd33, // AAM
        INT_CBW = 6'd34, // CBW/CWDE
        INT_CDQ = 6'd35, // CWD/CDQ
        INT_MOVSX = 6'd36, // MOVSX
        INT_MOVZX = 6'd37, // MOVZX
        INT_CLC = 6'd38, // CLC
        INT_STC = 6'd39, // STC
        INT_CMC = 6'd40, // CMC
        INT_CLD = 6'd41, // CLD
        INT_STD = 6'd42, // STD
        INT_CLI = 6'd43, // CLI
        INT_STI = 6'd44, // STI
        INT_LAHF = 6'd45, // LAHF
        INT_SAHF = 6'd46, // SAHF
        INT_XCHG = 6'd47, // XCHG
        INT_XADD = 6'd48, // XADD
        INT_CMPXCHG = 6'd49, // CMPXCHG
        INT_SETCC = 6'd50, // SETcc
        INT_ARPL = 6'd51, // ARPL
        INT_LAR = 6'd52, // LAR
        INT_LSL = 6'd53, // LSL
        INT_VERR = 6'd54, // VERR
        INT_STRIDX_STEP = 6'd55, // 串操作索引步进
        INT_IMUL_IMM = 6'd56, // IMUL 立即数形态
        INT_CLTS = 6'd57, // CLTS
        INT_LMSW = 6'd58, // LMSW
        INT_SMSW = 6'd59, // SMSW
        INT_LOOP_CTRL = 6'd60 // LOOP/LOOPE/LOOPNE
    } int_op_e;

endpackage

`endif
