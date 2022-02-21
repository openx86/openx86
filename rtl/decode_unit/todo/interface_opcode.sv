/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: interface_opcode
create at: 2022-02-14 22:33:45
description: opcode interface
*/

interface interface_opcode ();
logic        opcode_MOV_reg_to_reg_mem;
logic        opcode_MOV_reg_mem_to_reg;
logic        opcode_MOV_imm_to_reg_mem;
logic        opcode_MOV_imm_to_reg_short;
logic        opcode_MOV_mem_to_acc;
logic        opcode_MOV_acc_to_mem;
logic        opcode_MOV_reg_mem_to_sreg;
logic        opcode_MOV_sreg_to_reg_mem;
logic        opcode_MOVSX;
logic        opcode_MOVZX;
logic        opcode_PUSH_reg_mem;
logic        opcode_PUSH_reg_short;
logic        opcode_PUSH_sreg_2;
logic        opcode_PUSH_sreg_3;
logic        opcode_PUSH_imm;
logic        opcode_PUSH_all;
logic        opcode_POP_reg_mem;
logic        opcode_POP_reg_short;
logic        opcode_POP_sreg_2;
logic        opcode_POP_sreg_3;
logic        opcode_POP_all;
logic        opcode_XCHG_reg_mem_with_reg;
logic        opcode_XCHG_reg_with_acc_short;
logic        opcode_IN_port_fixed;
logic        opcode_IN_port_variable;
logic        opcode_OUT_port_fixed;
logic        opcode_OUT_port_variable;
logic        opcode_LEA_load_ea_to_reg;
logic        opcode_LDS_load_ptr_to_DS;
logic        opcode_LES_load_ptr_to_ES;
logic        opcode_LFS_load_ptr_to_FS;
logic        opcode_LGS_load_ptr_to_GS;
logic        opcode_LSS_load_ptr_to_SS;
logic        opcode_CLC_clear_carry_flag;
logic        opcode_CLD_clear_direction_flag;
logic        opcode_CLI_clear_interrupt_enable_flag;
logic        opcode_CLTS_clear_task_switched_flag;
logic        opcode_CMC_complement_carry_flag;
logic        opcode_LAHF_load_ah_into_flag;
logic        opcode_POPF_pop_flags;
logic        opcode_PUSHF_push_flags;
logic        opcode_SAHF_store_ah_into_flag;
logic        opcode_STC_set_carry_flag;
logic        opcode_STD_set_direction_flag;
logic        opcode_STI_set_interrupt_enable_flag;
logic        opcode_ADD_reg_to_mem;
logic        opcode_ADD_mem_to_reg;
logic        opcode_ADD_imm_to_reg_mem;
logic        opcode_ADD_imm_to_acc;
logic        opcode_ADC_reg_to_mem;
logic        opcode_ADC_mem_to_reg;
logic        opcode_ADC_imm_to_reg_mem;
logic        opcode_ADC_imm_to_acc;
logic        opcode_INC_reg_mem;
logic        opcode_INC_reg;
logic        opcode_SUB_reg_to_mem;
logic        opcode_SUB_mem_to_reg;
logic        opcode_SUB_imm_to_reg_mem;
logic        opcode_SUB_imm_to_acc;
logic        opcode_SBB_reg_to_mem;
logic        opcode_SBB_mem_to_reg;
logic        opcode_SBB_imm_to_reg_mem;
logic        opcode_SBB_imm_to_acc;
logic        opcode_DEC_reg_mem;
logic        opcode_DEC_reg;
logic        opcode_CMP_mem_with_reg;
logic        opcode_CMP_reg_with_mem;
logic        opcode_CMP_imm_with_reg_mem;
logic        opcode_CMP_imm_with_acc;
logic        opcode_NEG_change_sign;
logic        opcode_AAA;
logic        opcode_AAS;
logic        opcode_DAA;
logic        opcode_DAS;
logic        opcode_MUL_acc_with_reg_mem;
logic        opcode_IMUL_acc_with_reg_mem;
logic        opcode_IMUL_reg_with_reg_mem;
logic        opcode_IMUL_reg_mem_with_imm_to_reg;
logic        opcode_DIV_acc_by_reg_mem;
logic        opcode_IDIV_acc_by_reg_mem;
logic        opcode_AAD;
logic        opcode_AAM;
logic        opcode_CBW;
logic        opcode_CWD;
logic        opcode_ROL_reg_mem_by_1;
logic        opcode_ROL_reg_mem_by_CL;
logic        opcode_ROL_reg_mem_by_imm;
logic        opcode_ROR_reg_mem_by_1;
logic        opcode_ROR_reg_mem_by_CL;
logic        opcode_ROR_reg_mem_by_imm;
logic        opcode_SHL_reg_mem_by_1;
logic        opcode_SHL_reg_mem_by_CL;
logic        opcode_SHL_reg_mem_by_imm;
logic        opcode_SAR_reg_mem_by_1;
logic        opcode_SAR_reg_mem_by_CL;
logic        opcode_SAR_reg_mem_by_imm;
logic        opcode_SHR_reg_mem_by_1;
logic        opcode_SHR_reg_mem_by_CL;
logic        opcode_SHR_reg_mem_by_imm;
logic        opcode_RCL_reg_mem_by_1;
logic        opcode_RCL_reg_mem_by_CL;
logic        opcode_RCL_reg_mem_by_imm;
logic        opcode_RCR_reg_mem_by_1;
logic        opcode_RCR_reg_mem_by_CL;
logic        opcode_RCR_reg_mem_by_imm;
logic        opcode_SHLD_reg_mem_by_imm;
logic        opcode_SHLD_reg_mem_by_CL;
logic        opcode_SHRD_reg_mem_by_imm;
logic        opcode_SHRD_reg_mem_by_CL;
logic        opcode_AND_reg_to_mem;
logic        opcode_AND_mem_to_reg;
logic        opcode_AND_imm_to_reg_mem;
logic        opcode_AND_imm_to_acc;
logic        opcode_TEST_reg_mem_and_reg;
logic        opcode_TEST_imm_to_reg_mem;
logic        opcode_TEST_imm_to_acc;
logic        opcode_OR_reg_to_mem;
logic        opcode_OR_mem_to_reg;
logic        opcode_OR_imm_to_reg_mem;
logic        opcode_OR_imm_to_acc;
logic        opcode_XOR_reg_to_mem;
logic        opcode_XOR_mem_to_reg;
logic        opcode_XOR_imm_to_reg_mem;
logic        opcode_XOR_imm_to_acc;
logic        opcode_NOT;
logic        opcode_CMPS;
logic        opcode_INS;
logic        opcode_LODS;
logic        opcode_MOVS;
logic        opcode_OUTS;
logic        opcode_SCAS;
logic        opcode_STOS;
logic        opcode_XLAT;
logic        opcode_REPE;
logic        opcode_REPNE;
logic        opcode_BSF;
logic        opcode_BSR;
logic        opcode_BT_reg_mem_with_imm;
logic        opcode_BT_reg_mem_with_reg;
logic        opcode_BTC_reg_mem_with_imm;
logic        opcode_BTC_reg_mem_with_reg;
logic        opcode_BTR_reg_mem_with_imm;
logic        opcode_BTR_reg_mem_with_reg;
logic        opcode_BTS_reg_mem_with_imm;
logic        opcode_BTS_reg_mem_with_reg;
logic        opcode_CALL_direct_within_segment;
logic        opcode_CALL_indirect_within_segment;
logic        opcode_CALL_direct_intersegment;
logic        opcode_CALL_indirect_intersegment;
logic        opcode_JMP_short;
logic        opcode_JMP_direct_within_segment;
logic        opcode_JMP_indirect_within_segment;
logic        opcode_JMP_direct_intersegment;
logic        opcode_JMP_indirect_intersegment;
logic        opcode_RET_within_segment;
logic        opcode_RET_within_segment_adding_imm_to_SP;
logic        opcode_RET_intersegment;
logic        opcode_RET_intersegment_adding_imm_to_SP;
logic        opcode_JO_8bit_disp;
logic        opcode_JO_full_disp;
logic        opcode_JNO_8bit_disp;
logic        opcode_JNO_full_disp;
logic        opcode_JB_8bit_disp;
logic        opcode_JB_full_disp;
logic        opcode_JNB_8bit_disp;
logic        opcode_JNB_full_disp;
logic        opcode_JE_8bit_disp;
logic        opcode_JE_full_disp;
logic        opcode_JNE_8bit_disp;
logic        opcode_JNE_full_disp;
logic        opcode_JBE_8bit_disp;
logic        opcode_JBE_full_disp;
logic        opcode_JNBE_8bit_disp;
logic        opcode_JNBE_full_disp;
logic        opcode_JS_8bit_disp;
logic        opcode_JS_full_disp;
logic        opcode_JNS_8bit_disp;
logic        opcode_JNS_full_disp;
logic        opcode_JP_8bit_disp;
logic        opcode_JP_full_disp;
logic        opcode_JNP_8bit_disp;
logic        opcode_JNP_full_disp;
logic        opcode_JL_8bit_disp;
logic        opcode_JL_full_disp;
logic        opcode_JNL_8bit_disp;
logic        opcode_JNL_full_disp;
logic        opcode_JLE_8bit_disp;
logic        opcode_JLE_full_disp;
logic        opcode_JNLE_8bit_disp;
logic        opcode_JNLE_full_disp;
logic        opcode_JCXZ;
logic        opcode_LOOP;
logic        opcode_LOOPZ;
logic        opcode_LOOPNZ;
logic        opcode_SETO;
logic        opcode_SETNO;
logic        opcode_SETB;
logic        opcode_SETNB;
logic        opcode_SETE;
logic        opcode_SETNE;
logic        opcode_SETBE;
logic        opcode_SETNBE;
logic        opcode_SETS;
logic        opcode_SETNS;
logic        opcode_SETP;
logic        opcode_SETNP;
logic        opcode_SETL;
logic        opcode_SETNL;
logic        opcode_SETLE;
logic        opcode_SETNLE;
logic        opcode_ENTER;
logic        opcode_LEAVE;
logic        opcode_INT_type_3;
logic        opcode_INT_type_specified;
logic        opcode_INTO;
logic        opcode_BOUND;
logic        opcode_IRET;
logic        opcode_HLT;
logic        opcode_MOV_CR0_CR2_CR3_from_reg;
logic        opcode_MOV_reg_from_CR0_3;
logic        opcode_MOV_DR0_7_from_reg;
logic        opcode_MOV_reg_from_DR0_7;
logic        opcode_MOV_TR6_7_from_reg;
logic        opcode_MOV_reg_from_TR6_7;
logic        opcode_NOP;
logic        opcode_WAIT;
logic        opcode_processor_extension_escape;
logic        opcode_ARPL;
logic        opcode_LAR;
logic        opcode_LGDT;
logic        opcode_LIDT;
logic        opcode_LLDT;
logic        opcode_LMSW;
logic        opcode_LSL;
logic        opcode_LTR;
logic        opcode_SGDT;
logic        opcode_SIDT;
logic        opcode_SLDT;
logic        opcode_SMSW;
logic        opcode_STR;
logic        opcode_VERR;
logic        opcode_VERW;
modport opcode_input (
    input
    opcode_MOV_reg_to_reg_mem,
    opcode_MOV_reg_mem_to_reg,
    opcode_MOV_imm_to_reg_mem,
    opcode_MOV_imm_to_reg_short,
    opcode_MOV_mem_to_acc,
    opcode_MOV_acc_to_mem,
    opcode_MOV_reg_mem_to_sreg,
    opcode_MOV_sreg_to_reg_mem,
    opcode_MOVSX,
    opcode_MOVZX,
    opcode_PUSH_reg_mem,
    opcode_PUSH_reg_short,
    opcode_PUSH_sreg_2,
    opcode_PUSH_sreg_3,
    opcode_PUSH_imm,
    opcode_PUSH_all,
    opcode_POP_reg_mem,
    opcode_POP_reg_short,
    opcode_POP_sreg_2,
    opcode_POP_sreg_3,
    opcode_POP_all,
    opcode_XCHG_reg_mem_with_reg,
    opcode_XCHG_reg_with_acc_short,
    opcode_IN_port_fixed,
    opcode_IN_port_variable,
    opcode_OUT_port_fixed,
    opcode_OUT_port_variable,
    opcode_LEA_load_ea_to_reg,
    opcode_LDS_load_ptr_to_DS,
    opcode_LES_load_ptr_to_ES,
    opcode_LFS_load_ptr_to_FS,
    opcode_LGS_load_ptr_to_GS,
    opcode_LSS_load_ptr_to_SS,
    opcode_CLC_clear_carry_flag,
    opcode_CLD_clear_direction_flag,
    opcode_CLI_clear_interrupt_enable_flag,
    opcode_CLTS_clear_task_switched_flag,
    opcode_CMC_complement_carry_flag,
    opcode_LAHF_load_ah_into_flag,
    opcode_POPF_pop_flags,
    opcode_PUSHF_push_flags,
    opcode_SAHF_store_ah_into_flag,
    opcode_STC_set_carry_flag,
    opcode_STD_set_direction_flag,
    opcode_STI_set_interrupt_enable_flag,
    opcode_ADD_reg_to_mem,
    opcode_ADD_mem_to_reg,
    opcode_ADD_imm_to_reg_mem,
    opcode_ADD_imm_to_acc,
    opcode_ADC_reg_to_mem,
    opcode_ADC_mem_to_reg,
    opcode_ADC_imm_to_reg_mem,
    opcode_ADC_imm_to_acc,
    opcode_INC_reg_mem,
    opcode_INC_reg,
    opcode_SUB_reg_to_mem,
    opcode_SUB_mem_to_reg,
    opcode_SUB_imm_to_reg_mem,
    opcode_SUB_imm_to_acc,
    opcode_SBB_reg_to_mem,
    opcode_SBB_mem_to_reg,
    opcode_SBB_imm_to_reg_mem,
    opcode_SBB_imm_to_acc,
    opcode_DEC_reg_mem,
    opcode_DEC_reg,
    opcode_CMP_mem_with_reg,
    opcode_CMP_reg_with_mem,
    opcode_CMP_imm_with_reg_mem,
    opcode_CMP_imm_with_acc,
    opcode_NEG_change_sign,
    opcode_AAA,
    opcode_AAS,
    opcode_DAA,
    opcode_DAS,
    opcode_MUL_acc_with_reg_mem,
    opcode_IMUL_acc_with_reg_mem,
    opcode_IMUL_reg_with_reg_mem,
    opcode_IMUL_reg_mem_with_imm_to_reg,
    opcode_DIV_acc_by_reg_mem,
    opcode_IDIV_acc_by_reg_mem,
    opcode_AAD,
    opcode_AAM,
    opcode_CBW,
    opcode_CWD,
    opcode_ROL_reg_mem_by_1,
    opcode_ROL_reg_mem_by_CL,
    opcode_ROL_reg_mem_by_imm,
    opcode_ROR_reg_mem_by_1,
    opcode_ROR_reg_mem_by_CL,
    opcode_ROR_reg_mem_by_imm,
    opcode_SHL_reg_mem_by_1,
    opcode_SHL_reg_mem_by_CL,
    opcode_SHL_reg_mem_by_imm,
    opcode_SAR_reg_mem_by_1,
    opcode_SAR_reg_mem_by_CL,
    opcode_SAR_reg_mem_by_imm,
    opcode_SHR_reg_mem_by_1,
    opcode_SHR_reg_mem_by_CL,
    opcode_SHR_reg_mem_by_imm,
    opcode_RCL_reg_mem_by_1,
    opcode_RCL_reg_mem_by_CL,
    opcode_RCL_reg_mem_by_imm,
    opcode_RCR_reg_mem_by_1,
    opcode_RCR_reg_mem_by_CL,
    opcode_RCR_reg_mem_by_imm,
    opcode_SHLD_reg_mem_by_imm,
    opcode_SHLD_reg_mem_by_CL,
    opcode_SHRD_reg_mem_by_imm,
    opcode_SHRD_reg_mem_by_CL,
    opcode_AND_reg_to_mem,
    opcode_AND_mem_to_reg,
    opcode_AND_imm_to_reg_mem,
    opcode_AND_imm_to_acc,
    opcode_TEST_reg_mem_and_reg,
    opcode_TEST_imm_to_reg_mem,
    opcode_TEST_imm_to_acc,
    opcode_OR_reg_to_mem,
    opcode_OR_mem_to_reg,
    opcode_OR_imm_to_reg_mem,
    opcode_OR_imm_to_acc,
    opcode_XOR_reg_to_mem,
    opcode_XOR_mem_to_reg,
    opcode_XOR_imm_to_reg_mem,
    opcode_XOR_imm_to_acc,
    opcode_NOT,
    opcode_CMPS,
    opcode_INS,
    opcode_LODS,
    opcode_MOVS,
    opcode_OUTS,
    opcode_SCAS,
    opcode_STOS,
    opcode_XLAT,
    opcode_REPE,
    opcode_REPNE,
    opcode_BSF,
    opcode_BSR,
    opcode_BT_reg_mem_with_imm,
    opcode_BT_reg_mem_with_reg,
    opcode_BTC_reg_mem_with_imm,
    opcode_BTC_reg_mem_with_reg,
    opcode_BTR_reg_mem_with_imm,
    opcode_BTR_reg_mem_with_reg,
    opcode_BTS_reg_mem_with_imm,
    opcode_BTS_reg_mem_with_reg,
    opcode_CALL_direct_within_segment,
    opcode_CALL_indirect_within_segment,
    opcode_CALL_direct_intersegment,
    opcode_CALL_indirect_intersegment,
    opcode_JMP_short,
    opcode_JMP_direct_within_segment,
    opcode_JMP_indirect_within_segment,
    opcode_JMP_direct_intersegment,
    opcode_JMP_indirect_intersegment,
    opcode_RET_within_segment,
    opcode_RET_within_segment_adding_imm_to_SP,
    opcode_RET_intersegment,
    opcode_RET_intersegment_adding_imm_to_SP,
    opcode_JO_8bit_disp,
    opcode_JO_full_disp,
    opcode_JNO_8bit_disp,
    opcode_JNO_full_disp,
    opcode_JB_8bit_disp,
    opcode_JB_full_disp,
    opcode_JNB_8bit_disp,
    opcode_JNB_full_disp,
    opcode_JE_8bit_disp,
    opcode_JE_full_disp,
    opcode_JNE_8bit_disp,
    opcode_JNE_full_disp,
    opcode_JBE_8bit_disp,
    opcode_JBE_full_disp,
    opcode_JNBE_8bit_disp,
    opcode_JNBE_full_disp,
    opcode_JS_8bit_disp,
    opcode_JS_full_disp,
    opcode_JNS_8bit_disp,
    opcode_JNS_full_disp,
    opcode_JP_8bit_disp,
    opcode_JP_full_disp,
    opcode_JNP_8bit_disp,
    opcode_JNP_full_disp,
    opcode_JL_8bit_disp,
    opcode_JL_full_disp,
    opcode_JNL_8bit_disp,
    opcode_JNL_full_disp,
    opcode_JLE_8bit_disp,
    opcode_JLE_full_disp,
    opcode_JNLE_8bit_disp,
    opcode_JNLE_full_disp,
    opcode_JCXZ,
    opcode_LOOP,
    opcode_LOOPZ,
    opcode_LOOPNZ,
    opcode_SETO,
    opcode_SETNO,
    opcode_SETB,
    opcode_SETNB,
    opcode_SETE,
    opcode_SETNE,
    opcode_SETBE,
    opcode_SETNBE,
    opcode_SETS,
    opcode_SETNS,
    opcode_SETP,
    opcode_SETNP,
    opcode_SETL,
    opcode_SETNL,
    opcode_SETLE,
    opcode_SETNLE,
    opcode_ENTER,
    opcode_LEAVE,
    opcode_INT_type_3,
    opcode_INT_type_specified,
    opcode_INTO,
    opcode_BOUND,
    opcode_IRET,
    opcode_HLT,
    opcode_MOV_CR0_CR2_CR3_from_reg,
    opcode_MOV_reg_from_CR0_3,
    opcode_MOV_DR0_7_from_reg,
    opcode_MOV_reg_from_DR0_7,
    opcode_MOV_TR6_7_from_reg,
    opcode_MOV_reg_from_TR6_7,
    opcode_NOP,
    opcode_WAIT,
    opcode_processor_extension_escape,
    opcode_ARPL,
    opcode_LAR,
    opcode_LGDT,
    opcode_LIDT,
    opcode_LLDT,
    opcode_LMSW,
    opcode_LSL,
    opcode_LTR,
    opcode_SGDT,
    opcode_SIDT,
    opcode_SLDT,
    opcode_SMSW,
    opcode_STR,
    opcode_VERR,
    opcode_VERW
);
modport opcode_output (
    output
    opcode_MOV_reg_to_reg_mem,
    opcode_MOV_reg_mem_to_reg,
    opcode_MOV_imm_to_reg_mem,
    opcode_MOV_imm_to_reg_short,
    opcode_MOV_mem_to_acc,
    opcode_MOV_acc_to_mem,
    opcode_MOV_reg_mem_to_sreg,
    opcode_MOV_sreg_to_reg_mem,
    opcode_MOVSX,
    opcode_MOVZX,
    opcode_PUSH_reg_mem,
    opcode_PUSH_reg_short,
    opcode_PUSH_sreg_2,
    opcode_PUSH_sreg_3,
    opcode_PUSH_imm,
    opcode_PUSH_all,
    opcode_POP_reg_mem,
    opcode_POP_reg_short,
    opcode_POP_sreg_2,
    opcode_POP_sreg_3,
    opcode_POP_all,
    opcode_XCHG_reg_mem_with_reg,
    opcode_XCHG_reg_with_acc_short,
    opcode_IN_port_fixed,
    opcode_IN_port_variable,
    opcode_OUT_port_fixed,
    opcode_OUT_port_variable,
    opcode_LEA_load_ea_to_reg,
    opcode_LDS_load_ptr_to_DS,
    opcode_LES_load_ptr_to_ES,
    opcode_LFS_load_ptr_to_FS,
    opcode_LGS_load_ptr_to_GS,
    opcode_LSS_load_ptr_to_SS,
    opcode_CLC_clear_carry_flag,
    opcode_CLD_clear_direction_flag,
    opcode_CLI_clear_interrupt_enable_flag,
    opcode_CLTS_clear_task_switched_flag,
    opcode_CMC_complement_carry_flag,
    opcode_LAHF_load_ah_into_flag,
    opcode_POPF_pop_flags,
    opcode_PUSHF_push_flags,
    opcode_SAHF_store_ah_into_flag,
    opcode_STC_set_carry_flag,
    opcode_STD_set_direction_flag,
    opcode_STI_set_interrupt_enable_flag,
    opcode_ADD_reg_to_mem,
    opcode_ADD_mem_to_reg,
    opcode_ADD_imm_to_reg_mem,
    opcode_ADD_imm_to_acc,
    opcode_ADC_reg_to_mem,
    opcode_ADC_mem_to_reg,
    opcode_ADC_imm_to_reg_mem,
    opcode_ADC_imm_to_acc,
    opcode_INC_reg_mem,
    opcode_INC_reg,
    opcode_SUB_reg_to_mem,
    opcode_SUB_mem_to_reg,
    opcode_SUB_imm_to_reg_mem,
    opcode_SUB_imm_to_acc,
    opcode_SBB_reg_to_mem,
    opcode_SBB_mem_to_reg,
    opcode_SBB_imm_to_reg_mem,
    opcode_SBB_imm_to_acc,
    opcode_DEC_reg_mem,
    opcode_DEC_reg,
    opcode_CMP_mem_with_reg,
    opcode_CMP_reg_with_mem,
    opcode_CMP_imm_with_reg_mem,
    opcode_CMP_imm_with_acc,
    opcode_NEG_change_sign,
    opcode_AAA,
    opcode_AAS,
    opcode_DAA,
    opcode_DAS,
    opcode_MUL_acc_with_reg_mem,
    opcode_IMUL_acc_with_reg_mem,
    opcode_IMUL_reg_with_reg_mem,
    opcode_IMUL_reg_mem_with_imm_to_reg,
    opcode_DIV_acc_by_reg_mem,
    opcode_IDIV_acc_by_reg_mem,
    opcode_AAD,
    opcode_AAM,
    opcode_CBW,
    opcode_CWD,
    opcode_ROL_reg_mem_by_1,
    opcode_ROL_reg_mem_by_CL,
    opcode_ROL_reg_mem_by_imm,
    opcode_ROR_reg_mem_by_1,
    opcode_ROR_reg_mem_by_CL,
    opcode_ROR_reg_mem_by_imm,
    opcode_SHL_reg_mem_by_1,
    opcode_SHL_reg_mem_by_CL,
    opcode_SHL_reg_mem_by_imm,
    opcode_SAR_reg_mem_by_1,
    opcode_SAR_reg_mem_by_CL,
    opcode_SAR_reg_mem_by_imm,
    opcode_SHR_reg_mem_by_1,
    opcode_SHR_reg_mem_by_CL,
    opcode_SHR_reg_mem_by_imm,
    opcode_RCL_reg_mem_by_1,
    opcode_RCL_reg_mem_by_CL,
    opcode_RCL_reg_mem_by_imm,
    opcode_RCR_reg_mem_by_1,
    opcode_RCR_reg_mem_by_CL,
    opcode_RCR_reg_mem_by_imm,
    opcode_SHLD_reg_mem_by_imm,
    opcode_SHLD_reg_mem_by_CL,
    opcode_SHRD_reg_mem_by_imm,
    opcode_SHRD_reg_mem_by_CL,
    opcode_AND_reg_to_mem,
    opcode_AND_mem_to_reg,
    opcode_AND_imm_to_reg_mem,
    opcode_AND_imm_to_acc,
    opcode_TEST_reg_mem_and_reg,
    opcode_TEST_imm_to_reg_mem,
    opcode_TEST_imm_to_acc,
    opcode_OR_reg_to_mem,
    opcode_OR_mem_to_reg,
    opcode_OR_imm_to_reg_mem,
    opcode_OR_imm_to_acc,
    opcode_XOR_reg_to_mem,
    opcode_XOR_mem_to_reg,
    opcode_XOR_imm_to_reg_mem,
    opcode_XOR_imm_to_acc,
    opcode_NOT,
    opcode_CMPS,
    opcode_INS,
    opcode_LODS,
    opcode_MOVS,
    opcode_OUTS,
    opcode_SCAS,
    opcode_STOS,
    opcode_XLAT,
    opcode_REPE,
    opcode_REPNE,
    opcode_BSF,
    opcode_BSR,
    opcode_BT_reg_mem_with_imm,
    opcode_BT_reg_mem_with_reg,
    opcode_BTC_reg_mem_with_imm,
    opcode_BTC_reg_mem_with_reg,
    opcode_BTR_reg_mem_with_imm,
    opcode_BTR_reg_mem_with_reg,
    opcode_BTS_reg_mem_with_imm,
    opcode_BTS_reg_mem_with_reg,
    opcode_CALL_direct_within_segment,
    opcode_CALL_indirect_within_segment,
    opcode_CALL_direct_intersegment,
    opcode_CALL_indirect_intersegment,
    opcode_JMP_short,
    opcode_JMP_direct_within_segment,
    opcode_JMP_indirect_within_segment,
    opcode_JMP_direct_intersegment,
    opcode_JMP_indirect_intersegment,
    opcode_RET_within_segment,
    opcode_RET_within_segment_adding_imm_to_SP,
    opcode_RET_intersegment,
    opcode_RET_intersegment_adding_imm_to_SP,
    opcode_JO_8bit_disp,
    opcode_JO_full_disp,
    opcode_JNO_8bit_disp,
    opcode_JNO_full_disp,
    opcode_JB_8bit_disp,
    opcode_JB_full_disp,
    opcode_JNB_8bit_disp,
    opcode_JNB_full_disp,
    opcode_JE_8bit_disp,
    opcode_JE_full_disp,
    opcode_JNE_8bit_disp,
    opcode_JNE_full_disp,
    opcode_JBE_8bit_disp,
    opcode_JBE_full_disp,
    opcode_JNBE_8bit_disp,
    opcode_JNBE_full_disp,
    opcode_JS_8bit_disp,
    opcode_JS_full_disp,
    opcode_JNS_8bit_disp,
    opcode_JNS_full_disp,
    opcode_JP_8bit_disp,
    opcode_JP_full_disp,
    opcode_JNP_8bit_disp,
    opcode_JNP_full_disp,
    opcode_JL_8bit_disp,
    opcode_JL_full_disp,
    opcode_JNL_8bit_disp,
    opcode_JNL_full_disp,
    opcode_JLE_8bit_disp,
    opcode_JLE_full_disp,
    opcode_JNLE_8bit_disp,
    opcode_JNLE_full_disp,
    opcode_JCXZ,
    opcode_LOOP,
    opcode_LOOPZ,
    opcode_LOOPNZ,
    opcode_SETO,
    opcode_SETNO,
    opcode_SETB,
    opcode_SETNB,
    opcode_SETE,
    opcode_SETNE,
    opcode_SETBE,
    opcode_SETNBE,
    opcode_SETS,
    opcode_SETNS,
    opcode_SETP,
    opcode_SETNP,
    opcode_SETL,
    opcode_SETNL,
    opcode_SETLE,
    opcode_SETNLE,
    opcode_ENTER,
    opcode_LEAVE,
    opcode_INT_type_3,
    opcode_INT_type_specified,
    opcode_INTO,
    opcode_BOUND,
    opcode_IRET,
    opcode_HLT,
    opcode_MOV_CR0_CR2_CR3_from_reg,
    opcode_MOV_reg_from_CR0_3,
    opcode_MOV_DR0_7_from_reg,
    opcode_MOV_reg_from_DR0_7,
    opcode_MOV_TR6_7_from_reg,
    opcode_MOV_reg_from_TR6_7,
    opcode_NOP,
    opcode_WAIT,
    opcode_processor_extension_escape,
    opcode_ARPL,
    opcode_LAR,
    opcode_LGDT,
    opcode_LIDT,
    opcode_LLDT,
    opcode_LMSW,
    opcode_LSL,
    opcode_LTR,
    opcode_SGDT,
    opcode_SIDT,
    opcode_SLDT,
    opcode_SMSW,
    opcode_STR,
    opcode_VERR,
    opcode_VERW
);

endinterface
