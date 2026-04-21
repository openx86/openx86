/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements opcode_x87.
*/

`include "openx86_defs.h.sv"

module stage_2_dec_opcode_x87 (
    output logic                o_opcode_x87_ESC,
    output logic                o_opcode_x87_FADD_ST0_STI,
    output logic                o_opcode_x87_FMUL_ST0_STI,
    output logic                o_opcode_x87_FCOM_STI,
    output logic                o_opcode_x87_FCOMP_STI,
    output logic                o_opcode_x87_FSUB_ST0_STI,
    output logic                o_opcode_x87_FSUBR_ST0_STI,
    output logic                o_opcode_x87_FDIV_ST0_STI,
    output logic                o_opcode_x87_FDIVR_ST0_STI,
    output logic                o_opcode_x87_FLD_STI,
    output logic                o_opcode_x87_FXCH_STI,
    output logic                o_opcode_x87_FNOP,
    output logic                o_opcode_x87_FCHS,
    output logic                o_opcode_x87_FABS,
    output logic                o_opcode_x87_FTST,
    output logic                o_opcode_x87_FLD1,
    output logic                o_opcode_x87_FLDZ,
    output logic                o_opcode_x87_FST_STI,
    output logic                o_opcode_x87_FSTP_STI,
    output logic                o_opcode_x87_FFREE_STI,
    output logic                o_opcode_x87_FADDP_STI_ST0,
    output logic                o_opcode_x87_FMULP_STI_ST0,
    output logic                o_opcode_x87_FSUBRP_STI_ST0,
    output logic                o_opcode_x87_FSUBP_STI_ST0,
    output logic                o_opcode_x87_FDIVRP_STI_ST0,
    output logic                o_opcode_x87_FDIVP_STI_ST0,
    output logic                o_opcode_x87_FCOMIP_STI,
    output logic                o_opcode_x87_FUCOMIP_STI,
    output logic                o_opcode_x87_FILD_M32,
    output logic                o_opcode_x87_FISTP_M32,
    output logic                o_opcode_x87_FLD_M32,
    output logic                o_opcode_x87_FSTP_M32,
    output logic                o_opcode_x87_RESERVED,
    output logic [ 2: 0]        o_opcode_x87_ESC_group,
    output logic [ 1: 0]        o_opcode_x87_mod,
    output logic [ 2: 0]        o_opcode_x87_reg,
    output logic [ 2: 0]        o_opcode_x87_rm,
    output logic                o_opcode_x87_memory_operand,
    output logic                o_opcode_x87_modrm_required,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

logic [31: 0] x87_opmask;

stage_2_dec_x87_esc u_stage_2_dec_x87_esc (
    .i_b0             ( i_instruction[0] ),
    .i_b1             ( i_instruction[1] ),
    .o_is_esc         ( o_opcode_x87_ESC ),
    .o_mod            ( o_opcode_x87_mod ),
    .o_reg            ( o_opcode_x87_reg ),
    .o_rm             ( o_opcode_x87_rm ),
    .o_esc_group      ( o_opcode_x87_ESC_group ),
    .o_opmask         ( x87_opmask ),
    .o_modrm_required ( o_opcode_x87_modrm_required ),
    .o_memory_operand ( o_opcode_x87_memory_operand )
);

assign o_opcode_x87_FADD_ST0_STI  = x87_opmask[`X87_MASK_M_FADD_ST0_STI];
assign o_opcode_x87_FMUL_ST0_STI  = x87_opmask[`X87_MASK_M_FMUL_ST0_STI];
assign o_opcode_x87_FCOM_STI      = x87_opmask[`X87_MASK_M_FCOM_STI];
assign o_opcode_x87_FCOMP_STI     = x87_opmask[`X87_MASK_M_FCOMP_STI];
assign o_opcode_x87_FSUB_ST0_STI  = x87_opmask[`X87_MASK_M_FSUB_ST0_STI];
assign o_opcode_x87_FSUBR_ST0_STI = x87_opmask[`X87_MASK_M_FSUBR_ST0_STI];
assign o_opcode_x87_FDIV_ST0_STI  = x87_opmask[`X87_MASK_M_FDIV_ST0_STI];
assign o_opcode_x87_FDIVR_ST0_STI = x87_opmask[`X87_MASK_M_FDIVR_ST0_STI];
assign o_opcode_x87_FLD_STI       = x87_opmask[`X87_MASK_M_FLD_STI];
assign o_opcode_x87_FXCH_STI      = x87_opmask[`X87_MASK_M_FXCH_STI];
assign o_opcode_x87_FNOP          = x87_opmask[`X87_MASK_M_FNOP];
assign o_opcode_x87_FCHS          = x87_opmask[`X87_MASK_M_FCHS];
assign o_opcode_x87_FABS          = x87_opmask[`X87_MASK_M_FABS];
assign o_opcode_x87_FTST          = x87_opmask[`X87_MASK_M_FTST];
assign o_opcode_x87_FLD1          = x87_opmask[`X87_MASK_M_FLD1];
assign o_opcode_x87_FLDZ          = x87_opmask[`X87_MASK_M_FLDZ];
assign o_opcode_x87_FST_STI       = x87_opmask[`X87_MASK_M_FST_STI];
assign o_opcode_x87_FSTP_STI      = x87_opmask[`X87_MASK_M_FSTP_STI];
assign o_opcode_x87_FFREE_STI     = x87_opmask[`X87_MASK_M_FFREE_STI];
assign o_opcode_x87_FADDP_STI_ST0 = x87_opmask[`X87_MASK_M_FADDP_STI_ST0];
assign o_opcode_x87_FMULP_STI_ST0 = x87_opmask[`X87_MASK_M_FMULP_STI_ST0];
assign o_opcode_x87_FSUBRP_STI_ST0 = x87_opmask[`X87_MASK_M_FSUBRP_STI_ST0];
assign o_opcode_x87_FSUBP_STI_ST0 = x87_opmask[`X87_MASK_M_FSUBP_STI_ST0];
assign o_opcode_x87_FDIVRP_STI_ST0 = x87_opmask[`X87_MASK_M_FDIVRP_STI_ST0];
assign o_opcode_x87_FDIVP_STI_ST0 = x87_opmask[`X87_MASK_M_FDIVP_STI_ST0];
assign o_opcode_x87_FCOMIP_STI    = x87_opmask[`X87_MASK_M_FCOMIP_STI];
assign o_opcode_x87_FUCOMIP_STI   = x87_opmask[`X87_MASK_M_FUCOMIP_STI];
assign o_opcode_x87_FILD_M32      = x87_opmask[`X87_MASK_M_FILD_M32];
assign o_opcode_x87_FISTP_M32     = x87_opmask[`X87_MASK_M_FISTP_M32];
assign o_opcode_x87_FLD_M32       = x87_opmask[`X87_MASK_M_FLD_M32];
assign o_opcode_x87_FSTP_M32      = x87_opmask[`X87_MASK_M_FSTP_M32];
assign o_opcode_x87_RESERVED      = x87_opmask[`X87_MASK_M_RESERVED];

endmodule