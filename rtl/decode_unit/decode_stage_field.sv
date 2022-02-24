/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_stage_field
create at: 2022-02-21 16:03:48
description: decode_stage_field
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_stage_field (
    input  logic [ 7:0] i_instruction [0:2],
    input  logic        i_opcode_MOV_reg_to_reg_mem,
    input  logic        i_opcode_MOV_reg_mem_to_reg,
    input  logic        i_opcode_MOV_imm_to_reg_mem,
    input  logic        i_opcode_MOV_imm_to_reg_short,
    input  logic        i_opcode_MOV_mem_to_acc,
    input  logic        i_opcode_MOV_acc_to_mem,
    input  logic        i_opcode_MOV_reg_mem_to_sreg,
    input  logic        i_opcode_MOV_sreg_to_reg_mem,
    input  logic        i_opcode_MOVSX,
    input  logic        i_opcode_MOVZX,
    input  logic        i_opcode_PUSH_reg_mem,
    input  logic        i_opcode_PUSH_reg_short,
    input  logic        i_opcode_PUSH_sreg_2,
    input  logic        i_opcode_PUSH_sreg_3,
    input  logic        i_opcode_PUSH_imm,
    input  logic        i_opcode_PUSH_all,
    input  logic        i_opcode_POP_reg_mem,
    input  logic        i_opcode_POP_reg_short,
    input  logic        i_opcode_POP_sreg_2,
    input  logic        i_opcode_POP_sreg_3,
    input  logic        i_opcode_POP_all,
    input  logic        i_opcode_XCHG_reg_mem_with_reg,
    input  logic        i_opcode_XCHG_reg_with_acc_short,
    input  logic        i_opcode_IN_port_fixed,
    input  logic        i_opcode_IN_port_variable,
    input  logic        i_opcode_OUT_port_fixed,
    input  logic        i_opcode_OUT_port_variable,
    input  logic        i_opcode_LEA_load_ea_to_reg,
    input  logic        i_opcode_LDS_load_ptr_to_DS,
    input  logic        i_opcode_LES_load_ptr_to_ES,
    input  logic        i_opcode_LFS_load_ptr_to_FS,
    input  logic        i_opcode_LGS_load_ptr_to_GS,
    input  logic        i_opcode_LSS_load_ptr_to_SS,
    input  logic        i_opcode_CLC_clear_carry_flag,
    input  logic        i_opcode_CLD_clear_direction_flag,
    input  logic        i_opcode_CLI_clear_interrupt_enable_flag,
    input  logic        i_opcode_CLTS_clear_task_switched_flag,
    input  logic        i_opcode_CMC_complement_carry_flag,
    input  logic        i_opcode_LAHF_load_ah_into_flag,
    input  logic        i_opcode_POPF_pop_flags,
    input  logic        i_opcode_PUSHF_push_flags,
    input  logic        i_opcode_SAHF_store_ah_into_flag,
    input  logic        i_opcode_STC_set_carry_flag,
    input  logic        i_opcode_STD_set_direction_flag,
    input  logic        i_opcode_STI_set_interrupt_enable_flag,
    input  logic        i_opcode_ADD_reg_to_mem,
    input  logic        i_opcode_ADD_mem_to_reg,
    input  logic        i_opcode_ADD_imm_to_reg_mem,
    input  logic        i_opcode_ADD_imm_to_acc,
    input  logic        i_opcode_ADC_reg_to_mem,
    input  logic        i_opcode_ADC_mem_to_reg,
    input  logic        i_opcode_ADC_imm_to_reg_mem,
    input  logic        i_opcode_ADC_imm_to_acc,
    input  logic        i_opcode_INC_reg_mem,
    input  logic        i_opcode_INC_reg,
    input  logic        i_opcode_SUB_reg_to_mem,
    input  logic        i_opcode_SUB_mem_to_reg,
    input  logic        i_opcode_SUB_imm_to_reg_mem,
    input  logic        i_opcode_SUB_imm_to_acc,
    input  logic        i_opcode_SBB_reg_to_mem,
    input  logic        i_opcode_SBB_mem_to_reg,
    input  logic        i_opcode_SBB_imm_to_reg_mem,
    input  logic        i_opcode_SBB_imm_to_acc,
    input  logic        i_opcode_DEC_reg_mem,
    input  logic        i_opcode_DEC_reg,
    input  logic        i_opcode_CMP_mem_with_reg,
    input  logic        i_opcode_CMP_reg_with_mem,
    input  logic        i_opcode_CMP_imm_with_reg_mem,
    input  logic        i_opcode_CMP_imm_with_acc,
    input  logic        i_opcode_NEG_change_sign,
    input  logic        i_opcode_AAA,
    input  logic        i_opcode_AAS,
    input  logic        i_opcode_DAA,
    input  logic        i_opcode_DAS,
    input  logic        i_opcode_MUL_acc_with_reg_mem,
    input  logic        i_opcode_IMUL_acc_with_reg_mem,
    input  logic        i_opcode_IMUL_reg_with_reg_mem,
    input  logic        i_opcode_IMUL_reg_mem_with_imm_to_reg,
    input  logic        i_opcode_DIV_acc_by_reg_mem,
    input  logic        i_opcode_IDIV_acc_by_reg_mem,
    input  logic        i_opcode_AAD,
    input  logic        i_opcode_AAM,
    input  logic        i_opcode_CBW,
    input  logic        i_opcode_CWD,
    input  logic        i_opcode_ROL_reg_mem_by_1,
    input  logic        i_opcode_ROL_reg_mem_by_CL,
    input  logic        i_opcode_ROL_reg_mem_by_imm,
    input  logic        i_opcode_ROR_reg_mem_by_1,
    input  logic        i_opcode_ROR_reg_mem_by_CL,
    input  logic        i_opcode_ROR_reg_mem_by_imm,
    input  logic        i_opcode_SHL_reg_mem_by_1,
    input  logic        i_opcode_SHL_reg_mem_by_CL,
    input  logic        i_opcode_SHL_reg_mem_by_imm,
    input  logic        i_opcode_SAR_reg_mem_by_1,
    input  logic        i_opcode_SAR_reg_mem_by_CL,
    input  logic        i_opcode_SAR_reg_mem_by_imm,
    input  logic        i_opcode_SHR_reg_mem_by_1,
    input  logic        i_opcode_SHR_reg_mem_by_CL,
    input  logic        i_opcode_SHR_reg_mem_by_imm,
    input  logic        i_opcode_RCL_reg_mem_by_1,
    input  logic        i_opcode_RCL_reg_mem_by_CL,
    input  logic        i_opcode_RCL_reg_mem_by_imm,
    input  logic        i_opcode_RCR_reg_mem_by_1,
    input  logic        i_opcode_RCR_reg_mem_by_CL,
    input  logic        i_opcode_RCR_reg_mem_by_imm,
    input  logic        i_opcode_SHLD_reg_mem_by_imm,
    input  logic        i_opcode_SHLD_reg_mem_by_CL,
    input  logic        i_opcode_SHRD_reg_mem_by_imm,
    input  logic        i_opcode_SHRD_reg_mem_by_CL,
    input  logic        i_opcode_AND_reg_to_mem,
    input  logic        i_opcode_AND_mem_to_reg,
    input  logic        i_opcode_AND_imm_to_reg_mem,
    input  logic        i_opcode_AND_imm_to_acc,
    input  logic        i_opcode_TEST_reg_mem_and_reg,
    input  logic        i_opcode_TEST_imm_to_reg_mem,
    input  logic        i_opcode_TEST_imm_to_acc,
    input  logic        i_opcode_OR_reg_to_mem,
    input  logic        i_opcode_OR_mem_to_reg,
    input  logic        i_opcode_OR_imm_to_reg_mem,
    input  logic        i_opcode_OR_imm_to_acc,
    input  logic        i_opcode_XOR_reg_to_mem,
    input  logic        i_opcode_XOR_mem_to_reg,
    input  logic        i_opcode_XOR_imm_to_reg_mem,
    input  logic        i_opcode_XOR_imm_to_acc,
    input  logic        i_opcode_NOT,
    input  logic        i_opcode_CMPS,
    input  logic        i_opcode_INS,
    input  logic        i_opcode_LODS,
    input  logic        i_opcode_MOVS,
    input  logic        i_opcode_OUTS,
    input  logic        i_opcode_SCAS,
    input  logic        i_opcode_STOS,
    input  logic        i_opcode_XLAT,
    input  logic        i_opcode_REPE,
    input  logic        i_opcode_REPNE,
    input  logic        i_opcode_BSF,
    input  logic        i_opcode_BSR,
    input  logic        i_opcode_BT_reg_mem_with_imm,
    input  logic        i_opcode_BT_reg_mem_with_reg,
    input  logic        i_opcode_BTC_reg_mem_with_imm,
    input  logic        i_opcode_BTC_reg_mem_with_reg,
    input  logic        i_opcode_BTR_reg_mem_with_imm,
    input  logic        i_opcode_BTR_reg_mem_with_reg,
    input  logic        i_opcode_BTS_reg_mem_with_imm,
    input  logic        i_opcode_BTS_reg_mem_with_reg,
    input  logic        i_opcode_CALL_direct_within_segment,
    input  logic        i_opcode_CALL_indirect_within_segment,
    input  logic        i_opcode_CALL_direct_intersegment,
    input  logic        i_opcode_CALL_indirect_intersegment,
    input  logic        i_opcode_JMP_short,
    input  logic        i_opcode_JMP_direct_within_segment,
    input  logic        i_opcode_JMP_indirect_within_segment,
    input  logic        i_opcode_JMP_direct_intersegment,
    input  logic        i_opcode_JMP_indirect_intersegment,
    input  logic        i_opcode_RET_within_segment,
    input  logic        i_opcode_RET_within_segment_adding_imm_to_SP,
    input  logic        i_opcode_RET_intersegment,
    input  logic        i_opcode_RET_intersegment_adding_imm_to_SP,
    input  logic        i_opcode_JO_8bit_disp,
    input  logic        i_opcode_JO_full_disp,
    input  logic        i_opcode_JNO_8bit_disp,
    input  logic        i_opcode_JNO_full_disp,
    input  logic        i_opcode_JB_8bit_disp,
    input  logic        i_opcode_JB_full_disp,
    input  logic        i_opcode_JNB_8bit_disp,
    input  logic        i_opcode_JNB_full_disp,
    input  logic        i_opcode_JE_8bit_disp,
    input  logic        i_opcode_JE_full_disp,
    input  logic        i_opcode_JNE_8bit_disp,
    input  logic        i_opcode_JNE_full_disp,
    input  logic        i_opcode_JBE_8bit_disp,
    input  logic        i_opcode_JBE_full_disp,
    input  logic        i_opcode_JNBE_8bit_disp,
    input  logic        i_opcode_JNBE_full_disp,
    input  logic        i_opcode_JS_8bit_disp,
    input  logic        i_opcode_JS_full_disp,
    input  logic        i_opcode_JNS_8bit_disp,
    input  logic        i_opcode_JNS_full_disp,
    input  logic        i_opcode_JP_8bit_disp,
    input  logic        i_opcode_JP_full_disp,
    input  logic        i_opcode_JNP_8bit_disp,
    input  logic        i_opcode_JNP_full_disp,
    input  logic        i_opcode_JL_8bit_disp,
    input  logic        i_opcode_JL_full_disp,
    input  logic        i_opcode_JNL_8bit_disp,
    input  logic        i_opcode_JNL_full_disp,
    input  logic        i_opcode_JLE_8bit_disp,
    input  logic        i_opcode_JLE_full_disp,
    input  logic        i_opcode_JNLE_8bit_disp,
    input  logic        i_opcode_JNLE_full_disp,
    input  logic        i_opcode_JCXZ,
    input  logic        i_opcode_LOOP,
    input  logic        i_opcode_LOOPZ,
    input  logic        i_opcode_LOOPNZ,
    input  logic        i_opcode_SETO,
    input  logic        i_opcode_SETNO,
    input  logic        i_opcode_SETB,
    input  logic        i_opcode_SETNB,
    input  logic        i_opcode_SETE,
    input  logic        i_opcode_SETNE,
    input  logic        i_opcode_SETBE,
    input  logic        i_opcode_SETNBE,
    input  logic        i_opcode_SETS,
    input  logic        i_opcode_SETNS,
    input  logic        i_opcode_SETP,
    input  logic        i_opcode_SETNP,
    input  logic        i_opcode_SETL,
    input  logic        i_opcode_SETNL,
    input  logic        i_opcode_SETLE,
    input  logic        i_opcode_SETNLE,
    input  logic        i_opcode_ENTER,
    input  logic        i_opcode_LEAVE,
    input  logic        i_opcode_INT_type_3,
    input  logic        i_opcode_INT_type_specified,
    input  logic        i_opcode_INTO,
    input  logic        i_opcode_BOUND,
    input  logic        i_opcode_IRET,
    input  logic        i_opcode_HLT,
    input  logic        i_opcode_MOV_CR0_CR2_CR3_from_reg,
    input  logic        i_opcode_MOV_reg_from_CR0_3,
    input  logic        i_opcode_MOV_DR0_7_from_reg,
    input  logic        i_opcode_MOV_reg_from_DR0_7,
    input  logic        i_opcode_MOV_TR6_7_from_reg,
    input  logic        i_opcode_MOV_reg_from_TR6_7,
    input  logic        i_opcode_NOP,
    input  logic        i_opcode_WAIT,
    input  logic        i_opcode_processor_extension_escape,
    input  logic        i_opcode_ARPL,
    input  logic        i_opcode_LAR,
    input  logic        i_opcode_LGDT,
    input  logic        i_opcode_LIDT,
    input  logic        i_opcode_LLDT,
    input  logic        i_opcode_LMSW,
    input  logic        i_opcode_LSL,
    input  logic        i_opcode_LTR,
    input  logic        i_opcode_SGDT,
    input  logic        i_opcode_SIDT,
    input  logic        i_opcode_SLDT,
    input  logic        i_opcode_SMSW,
    input  logic        i_opcode_STR,
    input  logic        i_opcode_VERR,
    input  logic        i_opcode_VERW,
    output logic        o_s_is_present,
    output logic        o_s,
    output logic        o_w_is_present,
    output logic        o_w,
    output logic        o_gen_reg_is_present,
    output logic [ 2:0] o_gen_reg_index,
    output logic        o_seg_reg_is_present,
    output logic [ 2:0] o_seg_reg_index,
    output logic        o_mod_rm_is_present,
    output logic [ 1:0] o_mod,
    output logic [ 2:0] o_rm,
    output logic        o_displacement_is_present,
    output logic        o_displacement_size_default,
    output logic        o_displacement_size_8,
    output logic        o_displacement_size_16,
    output logic        o_immediate_is_present,
    output logic        o_immediate_size_default,
    output logic        o_immediate_size_8,
    output logic        o_unsigned_full_offset_or_selector_is_present,
    output logic [ 2:0] o_bytes_consumed,
    output logic        o_error
);

wire opcode_MOV_reg_to_reg_mem = i_opcode_MOV_reg_to_reg_mem;
wire opcode_MOV_reg_mem_to_reg = i_opcode_MOV_reg_mem_to_reg;
wire opcode_MOV_imm_to_reg_mem = i_opcode_MOV_imm_to_reg_mem;
wire opcode_MOV_imm_to_reg_short = i_opcode_MOV_imm_to_reg_short;
wire opcode_MOV_mem_to_acc = i_opcode_MOV_mem_to_acc;
wire opcode_MOV_acc_to_mem = i_opcode_MOV_acc_to_mem;
wire opcode_MOV_reg_mem_to_sreg = i_opcode_MOV_reg_mem_to_sreg;
wire opcode_MOV_sreg_to_reg_mem = i_opcode_MOV_sreg_to_reg_mem;
wire opcode_MOVSX = i_opcode_MOVSX;
wire opcode_MOVZX = i_opcode_MOVZX;
wire opcode_PUSH_reg_mem = i_opcode_PUSH_reg_mem;
wire opcode_PUSH_reg_short = i_opcode_PUSH_reg_short;
wire opcode_PUSH_sreg_2 = i_opcode_PUSH_sreg_2;
wire opcode_PUSH_sreg_3 = i_opcode_PUSH_sreg_3;
wire opcode_PUSH_imm = i_opcode_PUSH_imm;
wire opcode_PUSH_all = i_opcode_PUSH_all;
wire opcode_POP_reg_mem = i_opcode_POP_reg_mem;
wire opcode_POP_reg_short = i_opcode_POP_reg_short;
wire opcode_POP_sreg_2 = i_opcode_POP_sreg_2;
wire opcode_POP_sreg_3 = i_opcode_POP_sreg_3;
wire opcode_POP_all = i_opcode_POP_all;
wire opcode_XCHG_reg_mem_with_reg = i_opcode_XCHG_reg_mem_with_reg;
wire opcode_XCHG_reg_with_acc_short = i_opcode_XCHG_reg_with_acc_short;
wire opcode_IN_port_fixed = i_opcode_IN_port_fixed;
wire opcode_IN_port_variable = i_opcode_IN_port_variable;
wire opcode_OUT_port_fixed = i_opcode_OUT_port_fixed;
wire opcode_OUT_port_variable = i_opcode_OUT_port_variable;
wire opcode_LEA_load_ea_to_reg = i_opcode_LEA_load_ea_to_reg;
wire opcode_LDS_load_ptr_to_DS = i_opcode_LDS_load_ptr_to_DS;
wire opcode_LES_load_ptr_to_ES = i_opcode_LES_load_ptr_to_ES;
wire opcode_LFS_load_ptr_to_FS = i_opcode_LFS_load_ptr_to_FS;
wire opcode_LGS_load_ptr_to_GS = i_opcode_LGS_load_ptr_to_GS;
wire opcode_LSS_load_ptr_to_SS = i_opcode_LSS_load_ptr_to_SS;
wire opcode_CLC_clear_carry_flag = i_opcode_CLC_clear_carry_flag;
wire opcode_CLD_clear_direction_flag = i_opcode_CLD_clear_direction_flag;
wire opcode_CLI_clear_interrupt_enable_flag = i_opcode_CLI_clear_interrupt_enable_flag;
wire opcode_CLTS_clear_task_switched_flag = i_opcode_CLTS_clear_task_switched_flag;
wire opcode_CMC_complement_carry_flag = i_opcode_CMC_complement_carry_flag;
wire opcode_LAHF_load_ah_into_flag = i_opcode_LAHF_load_ah_into_flag;
wire opcode_POPF_pop_flags = i_opcode_POPF_pop_flags;
wire opcode_PUSHF_push_flags = i_opcode_PUSHF_push_flags;
wire opcode_SAHF_store_ah_into_flag = i_opcode_SAHF_store_ah_into_flag;
wire opcode_STC_set_carry_flag = i_opcode_STC_set_carry_flag;
wire opcode_STD_set_direction_flag = i_opcode_STD_set_direction_flag;
wire opcode_STI_set_interrupt_enable_flag = i_opcode_STI_set_interrupt_enable_flag;
wire opcode_ADD_reg_to_mem = i_opcode_ADD_reg_to_mem;
wire opcode_ADD_mem_to_reg = i_opcode_ADD_mem_to_reg;
wire opcode_ADD_imm_to_reg_mem = i_opcode_ADD_imm_to_reg_mem;
wire opcode_ADD_imm_to_acc = i_opcode_ADD_imm_to_acc;
wire opcode_ADC_reg_to_mem = i_opcode_ADC_reg_to_mem;
wire opcode_ADC_mem_to_reg = i_opcode_ADC_mem_to_reg;
wire opcode_ADC_imm_to_reg_mem = i_opcode_ADC_imm_to_reg_mem;
wire opcode_ADC_imm_to_acc = i_opcode_ADC_imm_to_acc;
wire opcode_INC_reg_mem = i_opcode_INC_reg_mem;
wire opcode_INC_reg = i_opcode_INC_reg;
wire opcode_SUB_reg_to_mem = i_opcode_SUB_reg_to_mem;
wire opcode_SUB_mem_to_reg = i_opcode_SUB_mem_to_reg;
wire opcode_SUB_imm_to_reg_mem = i_opcode_SUB_imm_to_reg_mem;
wire opcode_SUB_imm_to_acc = i_opcode_SUB_imm_to_acc;
wire opcode_SBB_reg_to_mem = i_opcode_SBB_reg_to_mem;
wire opcode_SBB_mem_to_reg = i_opcode_SBB_mem_to_reg;
wire opcode_SBB_imm_to_reg_mem = i_opcode_SBB_imm_to_reg_mem;
wire opcode_SBB_imm_to_acc = i_opcode_SBB_imm_to_acc;
wire opcode_DEC_reg_mem = i_opcode_DEC_reg_mem;
wire opcode_DEC_reg = i_opcode_DEC_reg;
wire opcode_CMP_mem_with_reg = i_opcode_CMP_mem_with_reg;
wire opcode_CMP_reg_with_mem = i_opcode_CMP_reg_with_mem;
wire opcode_CMP_imm_with_reg_mem = i_opcode_CMP_imm_with_reg_mem;
wire opcode_CMP_imm_with_acc = i_opcode_CMP_imm_with_acc;
wire opcode_NEG_change_sign = i_opcode_NEG_change_sign;
wire opcode_AAA = i_opcode_AAA;
wire opcode_AAS = i_opcode_AAS;
wire opcode_DAA = i_opcode_DAA;
wire opcode_DAS = i_opcode_DAS;
wire opcode_MUL_acc_with_reg_mem = i_opcode_MUL_acc_with_reg_mem;
wire opcode_IMUL_acc_with_reg_mem = i_opcode_IMUL_acc_with_reg_mem;
wire opcode_IMUL_reg_with_reg_mem = i_opcode_IMUL_reg_with_reg_mem;
wire opcode_IMUL_reg_mem_with_imm_to_reg = i_opcode_IMUL_reg_mem_with_imm_to_reg;
wire opcode_DIV_acc_by_reg_mem = i_opcode_DIV_acc_by_reg_mem;
wire opcode_IDIV_acc_by_reg_mem = i_opcode_IDIV_acc_by_reg_mem;
wire opcode_AAD = i_opcode_AAD;
wire opcode_AAM = i_opcode_AAM;
wire opcode_CBW = i_opcode_CBW;
wire opcode_CWD = i_opcode_CWD;
wire opcode_ROL_reg_mem_by_1 = i_opcode_ROL_reg_mem_by_1;
wire opcode_ROL_reg_mem_by_CL = i_opcode_ROL_reg_mem_by_CL;
wire opcode_ROL_reg_mem_by_imm = i_opcode_ROL_reg_mem_by_imm;
wire opcode_ROR_reg_mem_by_1 = i_opcode_ROR_reg_mem_by_1;
wire opcode_ROR_reg_mem_by_CL = i_opcode_ROR_reg_mem_by_CL;
wire opcode_ROR_reg_mem_by_imm = i_opcode_ROR_reg_mem_by_imm;
wire opcode_SHL_reg_mem_by_1 = i_opcode_SHL_reg_mem_by_1;
wire opcode_SHL_reg_mem_by_CL = i_opcode_SHL_reg_mem_by_CL;
wire opcode_SHL_reg_mem_by_imm = i_opcode_SHL_reg_mem_by_imm;
wire opcode_SAR_reg_mem_by_1 = i_opcode_SAR_reg_mem_by_1;
wire opcode_SAR_reg_mem_by_CL = i_opcode_SAR_reg_mem_by_CL;
wire opcode_SAR_reg_mem_by_imm = i_opcode_SAR_reg_mem_by_imm;
wire opcode_SHR_reg_mem_by_1 = i_opcode_SHR_reg_mem_by_1;
wire opcode_SHR_reg_mem_by_CL = i_opcode_SHR_reg_mem_by_CL;
wire opcode_SHR_reg_mem_by_imm = i_opcode_SHR_reg_mem_by_imm;
wire opcode_RCL_reg_mem_by_1 = i_opcode_RCL_reg_mem_by_1;
wire opcode_RCL_reg_mem_by_CL = i_opcode_RCL_reg_mem_by_CL;
wire opcode_RCL_reg_mem_by_imm = i_opcode_RCL_reg_mem_by_imm;
wire opcode_RCR_reg_mem_by_1 = i_opcode_RCR_reg_mem_by_1;
wire opcode_RCR_reg_mem_by_CL = i_opcode_RCR_reg_mem_by_CL;
wire opcode_RCR_reg_mem_by_imm = i_opcode_RCR_reg_mem_by_imm;
wire opcode_SHLD_reg_mem_by_imm = i_opcode_SHLD_reg_mem_by_imm;
wire opcode_SHLD_reg_mem_by_CL = i_opcode_SHLD_reg_mem_by_CL;
wire opcode_SHRD_reg_mem_by_imm = i_opcode_SHRD_reg_mem_by_imm;
wire opcode_SHRD_reg_mem_by_CL = i_opcode_SHRD_reg_mem_by_CL;
wire opcode_AND_reg_to_mem = i_opcode_AND_reg_to_mem;
wire opcode_AND_mem_to_reg = i_opcode_AND_mem_to_reg;
wire opcode_AND_imm_to_reg_mem = i_opcode_AND_imm_to_reg_mem;
wire opcode_AND_imm_to_acc = i_opcode_AND_imm_to_acc;
wire opcode_TEST_reg_mem_and_reg = i_opcode_TEST_reg_mem_and_reg;
wire opcode_TEST_imm_to_reg_mem = i_opcode_TEST_imm_to_reg_mem;
wire opcode_TEST_imm_to_acc = i_opcode_TEST_imm_to_acc;
wire opcode_OR_reg_to_mem = i_opcode_OR_reg_to_mem;
wire opcode_OR_mem_to_reg = i_opcode_OR_mem_to_reg;
wire opcode_OR_imm_to_reg_mem = i_opcode_OR_imm_to_reg_mem;
wire opcode_OR_imm_to_acc = i_opcode_OR_imm_to_acc;
wire opcode_XOR_reg_to_mem = i_opcode_XOR_reg_to_mem;
wire opcode_XOR_mem_to_reg = i_opcode_XOR_mem_to_reg;
wire opcode_XOR_imm_to_reg_mem = i_opcode_XOR_imm_to_reg_mem;
wire opcode_XOR_imm_to_acc = i_opcode_XOR_imm_to_acc;
wire opcode_NOT = i_opcode_NOT;
wire opcode_CMPS = i_opcode_CMPS;
wire opcode_INS = i_opcode_INS;
wire opcode_LODS = i_opcode_LODS;
wire opcode_MOVS = i_opcode_MOVS;
wire opcode_OUTS = i_opcode_OUTS;
wire opcode_SCAS = i_opcode_SCAS;
wire opcode_STOS = i_opcode_STOS;
wire opcode_XLAT = i_opcode_XLAT;
wire opcode_REPE = i_opcode_REPE;
wire opcode_REPNE = i_opcode_REPNE;
wire opcode_BSF = i_opcode_BSF;
wire opcode_BSR = i_opcode_BSR;
wire opcode_BT_reg_mem_with_imm = i_opcode_BT_reg_mem_with_imm;
wire opcode_BT_reg_mem_with_reg = i_opcode_BT_reg_mem_with_reg;
wire opcode_BTC_reg_mem_with_imm = i_opcode_BTC_reg_mem_with_imm;
wire opcode_BTC_reg_mem_with_reg = i_opcode_BTC_reg_mem_with_reg;
wire opcode_BTR_reg_mem_with_imm = i_opcode_BTR_reg_mem_with_imm;
wire opcode_BTR_reg_mem_with_reg = i_opcode_BTR_reg_mem_with_reg;
wire opcode_BTS_reg_mem_with_imm = i_opcode_BTS_reg_mem_with_imm;
wire opcode_BTS_reg_mem_with_reg = i_opcode_BTS_reg_mem_with_reg;
wire opcode_CALL_direct_within_segment = i_opcode_CALL_direct_within_segment;
wire opcode_CALL_indirect_within_segment = i_opcode_CALL_indirect_within_segment;
wire opcode_CALL_direct_intersegment = i_opcode_CALL_direct_intersegment;
wire opcode_CALL_indirect_intersegment = i_opcode_CALL_indirect_intersegment;
wire opcode_JMP_short = i_opcode_JMP_short;
wire opcode_JMP_direct_within_segment = i_opcode_JMP_direct_within_segment;
wire opcode_JMP_indirect_within_segment = i_opcode_JMP_indirect_within_segment;
wire opcode_JMP_direct_intersegment = i_opcode_JMP_direct_intersegment;
wire opcode_JMP_indirect_intersegment = i_opcode_JMP_indirect_intersegment;
wire opcode_RET_within_segment = i_opcode_RET_within_segment;
wire opcode_RET_within_segment_adding_imm_to_SP = i_opcode_RET_within_segment_adding_imm_to_SP;
wire opcode_RET_intersegment = i_opcode_RET_intersegment;
wire opcode_RET_intersegment_adding_imm_to_SP = i_opcode_RET_intersegment_adding_imm_to_SP;
wire opcode_JO_8bit_disp = i_opcode_JO_8bit_disp;
wire opcode_JO_full_disp = i_opcode_JO_full_disp;
wire opcode_JNO_8bit_disp = i_opcode_JNO_8bit_disp;
wire opcode_JNO_full_disp = i_opcode_JNO_full_disp;
wire opcode_JB_8bit_disp = i_opcode_JB_8bit_disp;
wire opcode_JB_full_disp = i_opcode_JB_full_disp;
wire opcode_JNB_8bit_disp = i_opcode_JNB_8bit_disp;
wire opcode_JNB_full_disp = i_opcode_JNB_full_disp;
wire opcode_JE_8bit_disp = i_opcode_JE_8bit_disp;
wire opcode_JE_full_disp = i_opcode_JE_full_disp;
wire opcode_JNE_8bit_disp = i_opcode_JNE_8bit_disp;
wire opcode_JNE_full_disp = i_opcode_JNE_full_disp;
wire opcode_JBE_8bit_disp = i_opcode_JBE_8bit_disp;
wire opcode_JBE_full_disp = i_opcode_JBE_full_disp;
wire opcode_JNBE_8bit_disp = i_opcode_JNBE_8bit_disp;
wire opcode_JNBE_full_disp = i_opcode_JNBE_full_disp;
wire opcode_JS_8bit_disp = i_opcode_JS_8bit_disp;
wire opcode_JS_full_disp = i_opcode_JS_full_disp;
wire opcode_JNS_8bit_disp = i_opcode_JNS_8bit_disp;
wire opcode_JNS_full_disp = i_opcode_JNS_full_disp;
wire opcode_JP_8bit_disp = i_opcode_JP_8bit_disp;
wire opcode_JP_full_disp = i_opcode_JP_full_disp;
wire opcode_JNP_8bit_disp = i_opcode_JNP_8bit_disp;
wire opcode_JNP_full_disp = i_opcode_JNP_full_disp;
wire opcode_JL_8bit_disp = i_opcode_JL_8bit_disp;
wire opcode_JL_full_disp = i_opcode_JL_full_disp;
wire opcode_JNL_8bit_disp = i_opcode_JNL_8bit_disp;
wire opcode_JNL_full_disp = i_opcode_JNL_full_disp;
wire opcode_JLE_8bit_disp = i_opcode_JLE_8bit_disp;
wire opcode_JLE_full_disp = i_opcode_JLE_full_disp;
wire opcode_JNLE_8bit_disp = i_opcode_JNLE_8bit_disp;
wire opcode_JNLE_full_disp = i_opcode_JNLE_full_disp;
wire opcode_JCXZ = i_opcode_JCXZ;
wire opcode_LOOP = i_opcode_LOOP;
wire opcode_LOOPZ = i_opcode_LOOPZ;
wire opcode_LOOPNZ = i_opcode_LOOPNZ;
wire opcode_SETO = i_opcode_SETO;
wire opcode_SETNO = i_opcode_SETNO;
wire opcode_SETB = i_opcode_SETB;
wire opcode_SETNB = i_opcode_SETNB;
wire opcode_SETE = i_opcode_SETE;
wire opcode_SETNE = i_opcode_SETNE;
wire opcode_SETBE = i_opcode_SETBE;
wire opcode_SETNBE = i_opcode_SETNBE;
wire opcode_SETS = i_opcode_SETS;
wire opcode_SETNS = i_opcode_SETNS;
wire opcode_SETP = i_opcode_SETP;
wire opcode_SETNP = i_opcode_SETNP;
wire opcode_SETL = i_opcode_SETL;
wire opcode_SETNL = i_opcode_SETNL;
wire opcode_SETLE = i_opcode_SETLE;
wire opcode_SETNLE = i_opcode_SETNLE;
wire opcode_ENTER = i_opcode_ENTER;
wire opcode_LEAVE = i_opcode_LEAVE;
wire opcode_INT_type_3 = i_opcode_INT_type_3;
wire opcode_INT_type_specified = i_opcode_INT_type_specified;
wire opcode_INTO = i_opcode_INTO;
wire opcode_BOUND = i_opcode_BOUND;
wire opcode_IRET = i_opcode_IRET;
wire opcode_HLT = i_opcode_HLT;
wire opcode_MOV_CR0_CR2_CR3_from_reg = i_opcode_MOV_CR0_CR2_CR3_from_reg;
wire opcode_MOV_reg_from_CR0_3 = i_opcode_MOV_reg_from_CR0_3;
wire opcode_MOV_DR0_7_from_reg = i_opcode_MOV_DR0_7_from_reg;
wire opcode_MOV_reg_from_DR0_7 = i_opcode_MOV_reg_from_DR0_7;
wire opcode_MOV_TR6_7_from_reg = i_opcode_MOV_TR6_7_from_reg;
wire opcode_MOV_reg_from_TR6_7 = i_opcode_MOV_reg_from_TR6_7;
wire opcode_NOP = i_opcode_NOP;
wire opcode_WAIT = i_opcode_WAIT;
wire opcode_processor_extension_escape = i_opcode_processor_extension_escape;
wire opcode_ARPL = i_opcode_ARPL;
wire opcode_LAR = i_opcode_LAR;
wire opcode_LGDT = i_opcode_LGDT;
wire opcode_LIDT = i_opcode_LIDT;
wire opcode_LLDT = i_opcode_LLDT;
wire opcode_LMSW = i_opcode_LMSW;
wire opcode_LSL = i_opcode_LSL;
wire opcode_LTR = i_opcode_LTR;
wire opcode_SGDT = i_opcode_SGDT;
wire opcode_SIDT = i_opcode_SIDT;
wire opcode_SLDT = i_opcode_SLDT;
wire opcode_SMSW = i_opcode_SMSW;
wire opcode_STR = i_opcode_STR;
wire opcode_VERR = i_opcode_VERR;
wire opcode_VERW = i_opcode_VERW;


// signed
wire s_at_0_1 =
opcode_PUSH_imm |
opcode_ADD_imm_to_reg_mem |
opcode_ADC_imm_to_reg_mem |
opcode_SUB_imm_to_reg_mem |
opcode_SBB_imm_to_reg_mem |
opcode_CMP_imm_with_reg_mem |
opcode_IMUL_reg_mem_with_imm_to_reg |
opcode_AND_imm_to_reg_mem |
opcode_OR_imm_to_reg_mem |
opcode_XOR_imm_to_reg_mem |
1'b0;

always_comb begin: decode_s
    unique case (1'b1)
        s_at_0_1: begin o_s_is_present <= 1'b1; o_s <= i_instruction[0][1]; end
        default:  begin o_s_is_present <= 1'b0; o_s <= 0; end
    endcase
end


// width
wire w_at_0_0 =
opcode_MOV_reg_to_reg_mem |
opcode_MOV_reg_mem_to_reg |
opcode_MOV_imm_to_reg_mem |
opcode_MOV_mem_to_acc |
opcode_MOV_acc_to_mem |
opcode_IN_port_fixed |
opcode_IN_port_variable |
opcode_OUT_port_fixed |
opcode_OUT_port_variable |
opcode_ADD_reg_to_mem |
opcode_ADD_mem_to_reg |
opcode_ADD_imm_to_reg_mem |
opcode_ADD_imm_to_acc |
opcode_ADC_reg_to_mem |
opcode_ADC_mem_to_reg |
opcode_ADC_imm_to_reg_mem |
opcode_ADC_imm_to_acc |
opcode_INC_reg_mem |
opcode_SUB_reg_to_mem |
opcode_SUB_mem_to_reg |
opcode_SUB_imm_to_reg_mem |
opcode_SUB_imm_to_acc |
opcode_SBB_reg_to_mem |
opcode_SBB_mem_to_reg |
opcode_SBB_imm_to_reg_mem |
opcode_SBB_imm_to_acc |
opcode_DEC_reg_mem |
opcode_CMP_mem_with_reg |
opcode_CMP_reg_with_mem |
opcode_CMP_imm_with_reg_mem |
opcode_CMP_imm_with_acc |
opcode_NEG_change_sign |
opcode_IMUL_acc_with_reg_mem |
opcode_IDIV_acc_by_reg_mem |
opcode_ROL_reg_mem_by_1 |
opcode_ROL_reg_mem_by_CL |
opcode_ROL_reg_mem_by_imm |
opcode_ROR_reg_mem_by_1 |
opcode_ROR_reg_mem_by_CL |
opcode_ROR_reg_mem_by_imm |
opcode_SHL_reg_mem_by_1 |
opcode_SHL_reg_mem_by_CL |
opcode_SHL_reg_mem_by_imm |
opcode_SAR_reg_mem_by_1 |
opcode_SAR_reg_mem_by_CL |
opcode_SAR_reg_mem_by_imm |
opcode_SHR_reg_mem_by_1 |
opcode_SHR_reg_mem_by_CL |
opcode_SHR_reg_mem_by_imm |
opcode_RCL_reg_mem_by_1 |
opcode_RCL_reg_mem_by_CL |
opcode_RCL_reg_mem_by_imm |
opcode_RCR_reg_mem_by_1 |
opcode_RCR_reg_mem_by_CL |
opcode_RCR_reg_mem_by_imm |
opcode_SHLD_reg_mem_by_imm |
opcode_SHLD_reg_mem_by_CL |
opcode_SHRD_reg_mem_by_imm |
opcode_SHRD_reg_mem_by_CL |
opcode_AND_reg_to_mem |
opcode_AND_mem_to_reg |
opcode_AND_imm_to_reg_mem |
opcode_AND_imm_to_acc |
opcode_TEST_reg_mem_and_reg |
opcode_TEST_imm_to_reg_mem |
opcode_TEST_imm_to_acc |
opcode_OR_reg_to_mem |
opcode_OR_mem_to_reg |
opcode_OR_imm_to_reg_mem |
opcode_OR_imm_to_acc |
opcode_XOR_reg_to_mem |
opcode_XOR_mem_to_reg |
opcode_XOR_imm_to_reg_mem |
opcode_XOR_imm_to_acc |
opcode_NOT |
opcode_CMPS |
opcode_INS |
opcode_LODS |
opcode_MOVS |
opcode_OUTS |
opcode_SCAS |
opcode_STOS |
1'b0;

wire w_at_0_3 = opcode_MOV_imm_to_reg_short;

wire w_at_1_0 =
opcode_MOVSX |
opcode_MOVZX |
1'b0;

always_comb begin: decode_w
    unique case (1'b1)
        w_at_0_0: begin o_w_is_present <= 1'b1; o_w <= i_instruction[0][0]; end
        w_at_0_3: begin o_w_is_present <= 1'b1; o_w <= i_instruction[0][3]; end
        w_at_1_0: begin o_w_is_present <= 1'b1; o_w <= i_instruction[1][0]; end
        default:  begin o_w_is_present <= 1'b0; o_w <= 0; end
    endcase
end


// general propose register
wire reg_at_0_2_0 =
opcode_MOV_imm_to_reg_short |
opcode_PUSH_reg_short |
opcode_POP_reg_short |
opcode_XCHG_reg_with_acc_short |
opcode_INC_reg |
opcode_DEC_reg |
1'b0;

wire reg_at_1_5_3 =
opcode_MOV_reg_to_reg_mem |
opcode_MOV_reg_mem_to_reg |
1'b0;

wire reg_at_2_5_3 =
opcode_MOVSX |
opcode_MOVZX |
opcode_LFS_load_ptr_to_FS |
opcode_LGS_load_ptr_to_GS |
opcode_LSS_load_ptr_to_SS |
opcode_IMUL_reg_with_reg_mem |
opcode_SHLD_reg_mem_by_imm |
opcode_SHLD_reg_mem_by_CL |
opcode_SHRD_reg_mem_by_imm |
opcode_SHRD_reg_mem_by_CL |
opcode_BSF |
opcode_BSR |
opcode_BT_reg_mem_with_reg |
opcode_BTC_reg_mem_with_reg |
opcode_BTR_reg_mem_with_reg |
opcode_BTS_reg_mem_with_reg |
opcode_LAR |
opcode_LSL |
1'b0;

wire reg_at_2_2_0 =
opcode_MOV_CR0_CR2_CR3_from_reg |
opcode_MOV_reg_from_CR0_3 |
opcode_MOV_DR0_7_from_reg |
opcode_MOV_reg_from_DR0_7 |
opcode_MOV_TR6_7_from_reg |
opcode_MOV_reg_from_TR6_7 |
1'b0;

always_comb begin: decode_greg
    unique case (1'b1)
        reg_at_0_2_0: begin o_gen_reg_is_present <= 1'b1; o_gen_reg_index <= i_instruction[0][2:0]; end
        reg_at_1_5_3: begin o_gen_reg_is_present <= 1'b1; o_gen_reg_index <= i_instruction[1][5:3]; end
        reg_at_2_5_3: begin o_gen_reg_is_present <= 1'b1; o_gen_reg_index <= i_instruction[2][5:3]; end
        reg_at_2_2_0: begin o_gen_reg_is_present <= 1'b1; o_gen_reg_index <= i_instruction[2][2:0]; end
        default:      begin o_gen_reg_is_present <= 1'b0; o_gen_reg_index <= 0; end
    endcase
end


// segment register
wire sreg3_at_1_5_3 =
opcode_MOV_reg_mem_to_sreg |
opcode_MOV_sreg_to_reg_mem |
opcode_PUSH_sreg_3 |
opcode_POP_sreg_3 |
1'b0;

wire sreg2_at_1_4_3 =
opcode_PUSH_sreg_2 |
opcode_POP_sreg_2 |
1'b0;

always_comb begin: decode_sreg3
    unique case (1'b1)
        sreg3_at_1_5_3: begin o_seg_reg_is_present <= 1'b1; o_seg_reg_index <= i_instruction[1][5:3]; end
        sreg2_at_1_4_3: begin o_seg_reg_is_present <= 1'b1; o_seg_reg_index <= {1'b0, i_instruction[1][4:3]}; end
        default:        begin o_seg_reg_is_present <= 1'b0; o_seg_reg_index <= 0; end
    endcase
end

// mod_rm
wire mod_rm_at_1 =
opcode_MOV_reg_to_reg_mem |
opcode_MOV_reg_mem_to_reg |
opcode_MOV_imm_to_reg_mem |
opcode_MOV_reg_mem_to_sreg |
opcode_MOV_sreg_to_reg_mem |
opcode_PUSH_reg_mem |
opcode_POP_reg_mem |
opcode_XCHG_reg_mem_with_reg |
opcode_LEA_load_ea_to_reg |
opcode_LDS_load_ptr_to_DS |
opcode_LES_load_ptr_to_ES |
opcode_ADD_reg_to_mem |
opcode_ADD_mem_to_reg |
opcode_ADD_imm_to_reg_mem |
opcode_ADC_reg_to_mem |
opcode_ADC_mem_to_reg |
opcode_ADC_imm_to_reg_mem |
opcode_INC_reg_mem |
opcode_SUB_reg_to_mem |
opcode_SUB_mem_to_reg |
opcode_SUB_imm_to_reg_mem |
opcode_SBB_reg_to_mem |
opcode_SBB_mem_to_reg |
opcode_SBB_imm_to_reg_mem |
opcode_DEC_reg_mem |
opcode_CMP_mem_with_reg |
opcode_CMP_reg_with_mem |
opcode_CMP_imm_with_reg_mem |
opcode_NEG_change_sign |
opcode_MUL_acc_with_reg_mem |
opcode_IMUL_acc_with_reg_mem |
opcode_IMUL_reg_mem_with_imm_to_reg |
opcode_DIV_acc_by_reg_mem |
opcode_IDIV_acc_by_reg_mem |
opcode_ROL_reg_mem_by_1 |
opcode_ROL_reg_mem_by_CL |
opcode_ROL_reg_mem_by_imm |
opcode_ROR_reg_mem_by_1 |
opcode_ROR_reg_mem_by_CL |
opcode_ROR_reg_mem_by_imm |
opcode_SHL_reg_mem_by_1 |
opcode_SHL_reg_mem_by_CL |
opcode_SHL_reg_mem_by_imm |
opcode_SAR_reg_mem_by_1 |
opcode_SAR_reg_mem_by_CL |
opcode_SAR_reg_mem_by_imm |
opcode_SHR_reg_mem_by_1 |
opcode_SHR_reg_mem_by_CL |
opcode_SHR_reg_mem_by_imm |
opcode_RCL_reg_mem_by_1 |
opcode_RCL_reg_mem_by_CL |
opcode_RCL_reg_mem_by_imm |
opcode_RCR_reg_mem_by_1 |
opcode_RCR_reg_mem_by_CL |
opcode_RCR_reg_mem_by_imm |
opcode_AND_reg_to_mem |
opcode_AND_mem_to_reg |
opcode_AND_imm_to_reg_mem |
opcode_TEST_reg_mem_and_reg |
opcode_TEST_imm_to_reg_mem |
opcode_OR_reg_to_mem |
opcode_OR_mem_to_reg |
opcode_OR_imm_to_reg_mem |
opcode_XOR_reg_to_mem |
opcode_XOR_mem_to_reg |
opcode_XOR_imm_to_reg_mem |
opcode_NOT |
opcode_CALL_indirect_within_segment |
opcode_CALL_indirect_intersegment |
opcode_JMP_indirect_within_segment |
opcode_JMP_indirect_intersegment |
opcode_BOUND |
opcode_ARPL |
1'b0;

wire mod_rm_at_2 =
opcode_MOVSX |
opcode_MOVZX |
opcode_LFS_load_ptr_to_FS |
opcode_LGS_load_ptr_to_GS |
opcode_LSS_load_ptr_to_SS |
opcode_IMUL_reg_with_reg_mem |
opcode_SHLD_reg_mem_by_imm |
opcode_SHLD_reg_mem_by_CL |
opcode_SHRD_reg_mem_by_imm |
opcode_SHRD_reg_mem_by_CL |
opcode_BSF |
opcode_BSR |
opcode_BT_reg_mem_with_imm |
opcode_BT_reg_mem_with_reg |
opcode_BTC_reg_mem_with_imm |
opcode_BTC_reg_mem_with_reg |
opcode_BTR_reg_mem_with_imm |
opcode_BTR_reg_mem_with_reg |
opcode_BTS_reg_mem_with_imm |
opcode_BTS_reg_mem_with_reg |
opcode_SETO |
opcode_SETNO |
opcode_SETB |
opcode_SETNB |
opcode_SETE |
opcode_SETNE |
opcode_SETBE |
opcode_SETNBE |
opcode_SETS |
opcode_SETNS |
opcode_SETP |
opcode_SETNP |
opcode_SETL |
opcode_SETNL |
opcode_SETLE |
opcode_SETNLE |
opcode_LAR |
opcode_LGDT |
opcode_LIDT |
opcode_LLDT |
opcode_LMSW |
opcode_LSL |
opcode_LTR |
opcode_SGDT |
opcode_SIDT |
opcode_SLDT |
opcode_SMSW |
opcode_STR |
opcode_VERR |
opcode_VERW |
1'b0;

always_comb begin: decode_mod_rm
    unique case (1'b1)
        mod_rm_at_1: begin o_mod_rm_is_present <= 1'b1; o_mod <= i_instruction[1][7:6]; o_rm <= i_instruction[1][2:0]; end
        mod_rm_at_2: begin o_mod_rm_is_present <= 1'b1; o_mod <= i_instruction[2][7:6]; o_rm <= i_instruction[2][2:0]; end
        default:     begin o_mod_rm_is_present <= 1'b0; o_mod <= 0; o_rm <= 0; end
    endcase
end


// displacement
assign o_displacement_size_default =
opcode_MOV_mem_to_acc |
opcode_MOV_acc_to_mem |
opcode_CALL_direct_within_segment |
opcode_JMP_direct_within_segment |
opcode_JO_full_disp |
opcode_JNO_full_disp |
opcode_JB_full_disp |
opcode_JNB_full_disp |
opcode_JE_full_disp |
opcode_JNE_full_disp |
opcode_JBE_full_disp |
opcode_JNBE_full_disp |
opcode_JS_full_disp |
opcode_JNS_full_disp |
opcode_JP_full_disp |
opcode_JNP_full_disp |
opcode_JL_full_disp |
opcode_JNL_full_disp |
opcode_JLE_full_disp |
opcode_JNLE_full_disp |
1'b0;

assign o_displacement_size_8 =
opcode_JMP_short |
opcode_JO_8bit_disp |
opcode_JNO_8bit_disp |
opcode_JB_8bit_disp |
opcode_JNB_8bit_disp |
opcode_JE_8bit_disp |
opcode_JNE_8bit_disp |
opcode_JBE_8bit_disp |
opcode_JNBE_8bit_disp |
opcode_JS_8bit_disp |
opcode_JNS_8bit_disp |
opcode_JP_8bit_disp |
opcode_JNP_8bit_disp |
opcode_JL_8bit_disp |
opcode_JNL_8bit_disp |
opcode_JLE_8bit_disp |
opcode_JNLE_8bit_disp |
opcode_JCXZ |
opcode_LOOP |
opcode_LOOPZ |
opcode_LOOPNZ |
1'b0;

assign o_displacement_size_16 =
opcode_RET_within_segment_adding_imm_to_SP |
opcode_RET_intersegment_adding_imm_to_SP |
opcode_ENTER |
1'b0;

assign o_displacement_is_present = o_displacement_size_default | o_displacement_size_8 | o_displacement_size_16;


// unsigned full offset or selector
assign o_unsigned_full_offset_or_selector_is_present =
opcode_CALL_direct_intersegment |
opcode_JMP_direct_intersegment |
1'b0;


// immediate
assign o_immediate_size_default =
opcode_MOV_imm_to_reg_mem |
opcode_MOV_imm_to_reg_short |
opcode_PUSH_imm |
opcode_ADD_imm_to_reg_mem |
opcode_ADD_imm_to_acc |
opcode_ADC_imm_to_reg_mem |
opcode_ADC_imm_to_acc |
opcode_SUB_imm_to_reg_mem |
opcode_SUB_imm_to_acc |
opcode_SBB_imm_to_reg_mem |
opcode_SBB_imm_to_acc |
opcode_CMP_imm_with_reg_mem |
opcode_CMP_imm_with_acc |
opcode_IMUL_reg_mem_with_imm_to_reg |
opcode_AND_imm_to_reg_mem |
opcode_AND_imm_to_acc |
opcode_TEST_imm_to_reg_mem |
opcode_TEST_imm_to_acc |
opcode_OR_imm_to_reg_mem |
opcode_OR_imm_to_acc |
opcode_XOR_imm_to_reg_mem |
opcode_XOR_imm_to_acc |
opcode_BT_reg_mem_with_imm |
opcode_BTC_reg_mem_with_imm |
opcode_BTR_reg_mem_with_imm |
opcode_BTS_reg_mem_with_imm |
1'b0;

/* consider the
IN port,
OUT port,
ENTER level,
INT type
as 8-bit operand
*/
assign o_immediate_size_8 =
opcode_IN_port_fixed |
opcode_OUT_port_fixed |
opcode_ROL_reg_mem_by_imm |
opcode_ROR_reg_mem_by_imm |
opcode_SHL_reg_mem_by_imm |
opcode_SAR_reg_mem_by_imm |
opcode_SHR_reg_mem_by_imm |
opcode_RCL_reg_mem_by_imm |
opcode_RCR_reg_mem_by_imm |
opcode_SHLD_reg_mem_by_imm |
opcode_SHRD_reg_mem_by_imm |
opcode_ENTER |
opcode_INT_type_specified |
1'b0;

assign o_immediate_is_present = o_immediate_size_default | o_immediate_size_8;


// length (include {mod {3-bytes opcode | greg_index} r/m})
wire next_stage_decode_offset_1 =
opcode_MOV_imm_to_reg_short |
opcode_MOV_mem_to_acc |
opcode_MOV_acc_to_mem |
opcode_PUSH_reg_short |
opcode_PUSH_sreg_2 |
opcode_PUSH_imm |
opcode_PUSH_all |
opcode_POP_reg_short |
opcode_POP_sreg_2 |
opcode_POP_all |
opcode_XCHG_reg_with_acc_short |
opcode_IN_port_variable |
opcode_OUT_port_variable |
opcode_CLC_clear_carry_flag |
opcode_CLD_clear_direction_flag |
opcode_CLI_clear_interrupt_enable_flag |
opcode_CMC_complement_carry_flag |
opcode_LAHF_load_ah_into_flag |
opcode_POPF_pop_flags |
opcode_PUSHF_push_flags |
opcode_SAHF_store_ah_into_flag |
opcode_STC_set_carry_flag |
opcode_STD_set_direction_flag |
opcode_STI_set_interrupt_enable_flag |
opcode_ADD_imm_to_acc |
opcode_ADC_imm_to_acc |
opcode_INC_reg |
opcode_SUB_imm_to_acc |
opcode_SBB_imm_to_acc |
opcode_DEC_reg |
opcode_CMP_imm_with_acc |
opcode_AAA |
opcode_AAS |
opcode_DAA |
opcode_DAS |
opcode_CBW |
opcode_CWD |
opcode_AND_imm_to_acc |
opcode_TEST_imm_to_acc |
opcode_OR_imm_to_acc |
opcode_XOR_imm_to_acc |
opcode_CMPS |
opcode_INS |
opcode_LODS |
opcode_MOVS |
opcode_OUTS |
opcode_SCAS |
opcode_STOS |
opcode_XLAT |
opcode_CALL_direct_within_segment |
opcode_CALL_direct_intersegment |
opcode_JMP_direct_within_segment |
opcode_JMP_direct_intersegment |
opcode_RET_within_segment |
opcode_RET_intersegment |
opcode_LEAVE |
opcode_INT_type_3 |
opcode_INTO |
opcode_IRET |
opcode_HLT |
opcode_NOP |
opcode_WAIT |
1'b0;

wire next_stage_decode_offset_2 =
opcode_MOV_reg_to_reg_mem |
opcode_MOV_reg_mem_to_reg |
opcode_MOV_imm_to_reg_mem |
opcode_MOV_reg_mem_to_sreg |
opcode_MOV_sreg_to_reg_mem |
opcode_PUSH_reg_mem |
opcode_PUSH_sreg_3 |
opcode_POP_reg_mem |
opcode_POP_sreg_3 |
opcode_XCHG_reg_with_acc_short |
opcode_IN_port_fixed |
opcode_OUT_port_fixed |
opcode_LEA_load_ea_to_reg |
opcode_LDS_load_ptr_to_DS |
opcode_LES_load_ptr_to_ES |
opcode_CLTS_clear_task_switched_flag |
opcode_ADD_reg_to_mem |
opcode_ADD_mem_to_reg |
opcode_ADD_imm_to_reg_mem |
opcode_ADC_reg_to_mem |
opcode_ADC_mem_to_reg |
opcode_ADC_imm_to_reg_mem |
opcode_INC_reg_mem |
opcode_SUB_reg_to_mem |
opcode_SUB_mem_to_reg |
opcode_SUB_imm_to_reg_mem |
opcode_SBB_reg_to_mem |
opcode_SBB_mem_to_reg |
opcode_SBB_imm_to_reg_mem |
opcode_DEC_reg_mem |
opcode_CMP_mem_with_reg |
opcode_CMP_reg_with_mem |
opcode_CMP_imm_with_reg_mem |
opcode_NEG_change_sign |
opcode_MUL_acc_with_reg_mem |
opcode_IMUL_acc_with_reg_mem |
opcode_IMUL_reg_mem_with_imm_to_reg |
opcode_DIV_acc_by_reg_mem |
opcode_IDIV_acc_by_reg_mem |
opcode_AAD |
opcode_AAM |
opcode_ROL_reg_mem_by_1 |
opcode_ROL_reg_mem_by_CL |
opcode_ROR_reg_mem_by_1 |
opcode_ROR_reg_mem_by_CL |
opcode_SHL_reg_mem_by_1 |
opcode_SHL_reg_mem_by_CL |
opcode_SAR_reg_mem_by_1 |
opcode_SAR_reg_mem_by_CL |
opcode_SHR_reg_mem_by_1 |
opcode_SHR_reg_mem_by_CL |
opcode_RCL_reg_mem_by_1 |
opcode_RCL_reg_mem_by_CL |
opcode_RCR_reg_mem_by_1 |
opcode_RCR_reg_mem_by_CL |
opcode_AND_reg_to_mem |
opcode_AND_mem_to_reg |
opcode_AND_imm_to_reg_mem |
opcode_TEST_reg_mem_and_reg |
opcode_TEST_imm_to_reg_mem |
opcode_OR_reg_to_mem |
opcode_OR_mem_to_reg |
opcode_OR_imm_to_reg_mem |
opcode_XOR_reg_to_mem |
opcode_XOR_mem_to_reg |
opcode_XOR_imm_to_reg_mem |
opcode_NOT |
opcode_REPE |
opcode_REPNE |
opcode_CALL_indirect_within_segment |
opcode_CALL_indirect_intersegment |
opcode_JMP_short |
opcode_JMP_direct_intersegment |
opcode_JMP_indirect_intersegment |
opcode_JO_8bit_disp |
opcode_JO_full_disp |
opcode_JNO_8bit_disp |
opcode_JNO_full_disp |
opcode_JB_8bit_disp |
opcode_JB_full_disp |
opcode_JNB_8bit_disp |
opcode_JNB_full_disp |
opcode_JE_8bit_disp |
opcode_JE_full_disp |
opcode_JNE_8bit_disp |
opcode_JNE_full_disp |
opcode_JBE_8bit_disp |
opcode_JBE_full_disp |
opcode_JNBE_8bit_disp |
opcode_JNBE_full_disp |
opcode_JS_8bit_disp |
opcode_JS_full_disp |
opcode_JNS_8bit_disp |
opcode_JNS_full_disp |
opcode_JP_8bit_disp |
opcode_JP_full_disp |
opcode_JNP_8bit_disp |
opcode_JNP_full_disp |
opcode_JL_8bit_disp |
opcode_JL_full_disp |
opcode_JNL_8bit_disp |
opcode_JNL_full_disp |
opcode_JLE_8bit_disp |
opcode_JLE_full_disp |
opcode_JNLE_8bit_disp |
opcode_JNLE_full_disp |
opcode_JCXZ |
opcode_LOOP |
opcode_LOOPZ |
opcode_LOOPNZ |
opcode_INT_type_specified |
opcode_BOUND |
opcode_processor_extension_escape |
opcode_ARPL |
1'b0;

wire next_stage_decode_offset_3 =
opcode_MOVSX |
opcode_MOVZX |
opcode_LFS_load_ptr_to_FS |
opcode_LGS_load_ptr_to_GS |
opcode_LSS_load_ptr_to_SS |
opcode_IMUL_reg_with_reg_mem |
opcode_ROL_reg_mem_by_imm |
opcode_ROR_reg_mem_by_imm |
opcode_SHL_reg_mem_by_imm |
opcode_SAR_reg_mem_by_imm |
opcode_SHR_reg_mem_by_imm |
opcode_RCL_reg_mem_by_imm |
opcode_RCR_reg_mem_by_imm |
opcode_SHLD_reg_mem_by_CL |
opcode_SHRD_reg_mem_by_CL |
opcode_BSF |
opcode_BSR |
opcode_BT_reg_mem_with_reg |
opcode_BTC_reg_mem_with_reg |
opcode_BTR_reg_mem_with_reg |
opcode_BTS_reg_mem_with_reg |
opcode_RET_within_segment_adding_imm_to_SP |
opcode_RET_intersegment_adding_imm_to_SP |
opcode_SETO |
opcode_SETNO |
opcode_SETB |
opcode_SETNB |
opcode_SETE |
opcode_SETNE |
opcode_SETBE |
opcode_SETNBE |
opcode_SETS |
opcode_SETNS |
opcode_SETP |
opcode_SETNP |
opcode_SETL |
opcode_SETNL |
opcode_SETLE |
opcode_SETNLE |
opcode_ENTER |
opcode_MOV_CR0_CR2_CR3_from_reg |
opcode_MOV_reg_from_CR0_3 |
opcode_MOV_DR0_7_from_reg |
opcode_MOV_reg_from_DR0_7 |
opcode_MOV_TR6_7_from_reg |
opcode_MOV_reg_from_TR6_7 |
opcode_LAR |
opcode_LGDT |
opcode_LIDT |
opcode_LLDT |
opcode_LMSW |
opcode_LSL |
opcode_LTR |
opcode_SGDT |
opcode_SIDT |
opcode_SLDT |
opcode_SMSW |
opcode_STR |
opcode_VERR |
opcode_VERW |
1'b0;

wire next_stage_decode_offset_4 =
opcode_SHLD_reg_mem_by_imm |
opcode_SHRD_reg_mem_by_imm |
opcode_BT_reg_mem_with_imm |
opcode_BTC_reg_mem_with_imm |
opcode_BTR_reg_mem_with_imm |
opcode_BTS_reg_mem_with_imm |
1'b0;

always_comb begin
    case (1'b1)
        next_stage_decode_offset_1: o_bytes_consumed <= 3'h1;
        next_stage_decode_offset_2: o_bytes_consumed <= 3'h2;
        next_stage_decode_offset_3: o_bytes_consumed <= 3'h3;
        next_stage_decode_offset_4: o_bytes_consumed <= 3'h4;
        default                   : o_bytes_consumed <= 3'h0;
    endcase
end

wire opcode_error = 0;
assign o_error = opcode_error;

endmodule
