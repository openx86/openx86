/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This package defines shared declarations for stage_2_dec_decode_x87_pkg.
*/
// ============================================================================
// X87 ESC (D8–DF) 译码 — 位掩码与常量（与 decode_x87_esc 配套）
// 参考：Intel SDM Vol 2 Table A-15 ~ A-22（ModR/M 与 opcode 扩展）
// ============================================================================

`ifndef DECODE_X87_PKG_SV
`define DECODE_X87_PKG_SV

package stage_2_dec_decode_x87_pkg;

    // o_opmask 位图：与 decode_x87_esc 中各分支一一对应（0..31 预分配常用 ESC）
    localparam int unsigned M_FADD_ST0_STI     = 0;
    localparam int unsigned M_FMUL_ST0_STI     = 1;
    localparam int unsigned M_FCOM_STI         = 2;
    localparam int unsigned M_FCOMP_STI        = 3;
    localparam int unsigned M_FSUB_ST0_STI     = 4;
    localparam int unsigned M_FSUBR_ST0_STI    = 5;
    localparam int unsigned M_FDIV_ST0_STI     = 6;
    localparam int unsigned M_FDIVR_ST0_STI    = 7;
    localparam int unsigned M_FLD_STI          = 8;
    localparam int unsigned M_FXCH_STI         = 9;
    localparam int unsigned M_FNOP             = 10;
    localparam int unsigned M_FCHS             = 11;
    localparam int unsigned M_FABS             = 12;
    localparam int unsigned M_FTST             = 13;
    localparam int unsigned M_FLD1             = 14;
    localparam int unsigned M_FLDZ             = 15;
    localparam int unsigned M_FST_STI          = 16;
    localparam int unsigned M_FSTP_STI         = 17;
    localparam int unsigned M_FFREE_STI        = 18;
    localparam int unsigned M_FADDP_STI_ST0    = 19;
    localparam int unsigned M_FMULP_STI_ST0    = 20;
    localparam int unsigned M_FSUBRP_STI_ST0   = 21;
    localparam int unsigned M_FSUBP_STI_ST0    = 22;
    localparam int unsigned M_FDIVRP_STI_ST0   = 23;
    localparam int unsigned M_FDIVP_STI_ST0    = 24;
    localparam int unsigned M_FCOMIP_STI       = 25;
    localparam int unsigned M_FUCOMIP_STI      = 26;
    localparam int unsigned M_FILD_M32         = 27;
    localparam int unsigned M_FISTP_M32        = 28;
    localparam int unsigned M_FLD_M32          = 29;
    localparam int unsigned M_FSTP_M32         = 30;
    localparam int unsigned M_RESERVED         = 31;

endpackage

`endif
