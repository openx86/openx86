/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_operand
create at: 2021-12-28 16:56:15
description: decode operand from instruction
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_operand #(
    // parameters
) (
    // ports
    input  logic        opcode_MOV_reg_to_reg_mem,
    input  logic        opcode_MOV_reg_mem_to_reg,
    input  logic        opcode_MOV_imm_to_reg_mem,
    input  logic        opcode_MOV_imm_to_reg_short,
    input  logic        opcode_MOV_mem_to_acc,
    input  logic        opcode_MOV_acc_to_mem,
    input  logic        opcode_MOV_reg_mem_to_sreg,
    input  logic        opcode_MOV_sreg_to_reg_mem,
    input  logic        opcode_MOVSX,
    input  logic        opcode_MOVZX,
    input  logic        opcode_PUSH_reg_mem,
    input  logic        opcode_PUSH_reg_short,
    input  logic        opcode_PUSH_sreg_2,
    input  logic        opcode_PUSH_sreg_3,
    input  logic        opcode_PUSH_imm,
    input  logic        opcode_PUSH_all,
    input  logic        opcode_POP_reg_mem,
    input  logic        opcode_POP_reg_short,
    input  logic        opcode_POP_sreg_2,
    input  logic        opcode_POP_sreg_3,
    input  logic        opcode_POP_all,
    input  logic        opcode_XCHG_reg_mem_with_reg,
    input  logic        opcode_XCHG_reg_with_acc_short,
    input  logic        opcode_IN_port_fixed,
    input  logic        opcode_IN_port_variable,
    input  logic        opcode_OUT_port_fixed,
    input  logic        opcode_OUT_port_variable,
    input  logic        opcode_LEA_load_ea_to_reg,
    input  logic        opcode_LDS_load_ptr_to_DS,
    input  logic        opcode_LES_load_ptr_to_ES,
    input  logic        opcode_LFS_load_ptr_to_FS,
    input  logic        opcode_LGS_load_ptr_to_GS,
    input  logic        opcode_LSS_load_ptr_to_SS,
    input  logic        opcode_CLC_clear_carry_flag,
    input  logic        opcode_CLD_clear_direction_flag,
    input  logic        opcode_CLI_clear_interrupt_enable_flag,
    input  logic        opcode_CLTS_clear_task_switched_flag,
    input  logic        opcode_CMC_complement_carry_flag,
    input  logic        opcode_LAHF_load_ah_into_flag,
    input  logic        opcode_POPF_pop_flags,
    input  logic        opcode_PUSHF_push_flags,
    input  logic        opcode_SAHF_store_ah_into_flag,
    input  logic        opcode_STC_set_carry_flag,
    input  logic        opcode_STD_set_direction_flag,
    input  logic        opcode_STI_set_interrupt_enable_flag,
    input  logic        opcode_ADD_reg_to_mem,
    input  logic        opcode_ADD_mem_to_reg,
    input  logic        opcode_ADD_imm_to_reg_mem,
    input  logic        opcode_ADD_imm_to_acc,
    input  logic        opcode_ADC_reg_to_mem,
    input  logic        opcode_ADC_mem_to_reg,
    input  logic        opcode_ADC_imm_to_reg_mem,
    input  logic        opcode_ADC_imm_to_acc,
    input  logic        opcode_INC_reg_mem,
    input  logic        opcode_INC_reg,
    input  logic        opcode_SUB_reg_to_mem,
    input  logic        opcode_SUB_mem_to_reg,
    input  logic        opcode_SUB_imm_to_reg_mem,
    input  logic        opcode_SUB_imm_to_acc,
    input  logic        opcode_SBB_reg_to_mem,
    input  logic        opcode_SBB_mem_to_reg,
    input  logic        opcode_SBB_imm_to_reg_mem,
    input  logic        opcode_SBB_imm_to_acc,
    input  logic        opcode_DEC_reg_mem,
    input  logic        opcode_DEC_reg,
    input  logic        opcode_CMP_mem_with_reg,
    input  logic        opcode_CMP_reg_with_mem,
    input  logic        opcode_CMP_imm_with_reg_mem,
    input  logic        opcode_CMP_imm_with_acc,
    input  logic        opcode_NEG_change_sign,
    input  logic        opcode_AAA,
    input  logic        opcode_AAS,
    input  logic        opcode_DAA,
    input  logic        opcode_DAS,
    input  logic        opcode_MUL_acc_with_reg_mem,
    input  logic        opcode_IMUL_acc_with_reg_mem,
    input  logic        opcode_IMUL_reg_with_reg_mem,
    input  logic        opcode_IMUL_reg_mem_with_imm_to_reg,
    input  logic        opcode_DIV_acc_by_reg_mem,
    input  logic        opcode_IDIV_acc_by_reg_mem,
    input  logic        opcode_AAD,
    input  logic        opcode_AAM,
    input  logic        opcode_CBW,
    input  logic        opcode_CWD,
    input  logic        opcode_ROL_reg_mem_by_1,
    input  logic        opcode_ROL_reg_mem_by_CL,
    input  logic        opcode_ROL_reg_mem_by_imm,
    input  logic        opcode_ROR_reg_mem_by_1,
    input  logic        opcode_ROR_reg_mem_by_CL,
    input  logic        opcode_ROR_reg_mem_by_imm,
    input  logic        opcode_SHL_reg_mem_by_1,
    input  logic        opcode_SHL_reg_mem_by_CL,
    input  logic        opcode_SHL_reg_mem_by_imm,
    input  logic        opcode_SAR_reg_mem_by_1,
    input  logic        opcode_SAR_reg_mem_by_CL,
    input  logic        opcode_SAR_reg_mem_by_imm,
    input  logic        opcode_SHR_reg_mem_by_1,
    input  logic        opcode_SHR_reg_mem_by_CL,
    input  logic        opcode_SHR_reg_mem_by_imm,
    input  logic        opcode_RCL_reg_mem_by_1,
    input  logic        opcode_RCL_reg_mem_by_CL,
    input  logic        opcode_RCL_reg_mem_by_imm,
    input  logic        opcode_RCR_reg_mem_by_1,
    input  logic        opcode_RCR_reg_mem_by_CL,
    input  logic        opcode_RCR_reg_mem_by_imm,
    input  logic        opcode_SHLD_reg_mem_by_imm,
    input  logic        opcode_SHLD_reg_mem_by_CL,
    input  logic        opcode_SHRD_reg_mem_by_imm,
    input  logic        opcode_SHRD_reg_mem_by_CL,
    input  logic        opcode_AND_reg_to_mem,
    input  logic        opcode_AND_mem_to_reg,
    input  logic        opcode_AND_imm_to_reg_mem,
    input  logic        opcode_AND_imm_to_acc,
    input  logic        opcode_TEST_reg_mem_and_reg,
    input  logic        opcode_TEST_imm_to_reg_mem,
    input  logic        opcode_TEST_imm_to_acc,
    input  logic        opcode_OR_reg_to_mem,
    input  logic        opcode_OR_mem_to_reg,
    input  logic        opcode_OR_imm_to_reg_mem,
    input  logic        opcode_OR_imm_to_acc,
    input  logic        opcode_XOR_reg_to_mem,
    input  logic        opcode_XOR_mem_to_reg,
    input  logic        opcode_XOR_imm_to_reg_mem,
    input  logic        opcode_XOR_imm_to_acc,
    input  logic        opcode_NOT,
    input  logic        opcode_CMPS,
    input  logic        opcode_INS,
    input  logic        opcode_LODS,
    input  logic        opcode_MOVS,
    input  logic        opcode_OUTS,
    input  logic        opcode_SCAS,
    input  logic        opcode_STOS,
    input  logic        opcode_XLAT,
    input  logic        opcode_REPE,
    input  logic        opcode_REPNE,
    input  logic        opcode_BSF,
    input  logic        opcode_BSR,
    input  logic        opcode_BT_reg_mem_with_imm,
    input  logic        opcode_BT_reg_mem_with_reg,
    input  logic        opcode_BTC_reg_mem_with_imm,
    input  logic        opcode_BTC_reg_mem_with_reg,
    input  logic        opcode_BTR_reg_mem_with_imm,
    input  logic        opcode_BTR_reg_mem_with_reg,
    input  logic        opcode_BTS_reg_mem_with_imm,
    input  logic        opcode_BTS_reg_mem_with_reg,
    input  logic        opcode_CALL_direct_within_segment,
    input  logic        opcode_CALL_indirect_within_segment,
    input  logic        opcode_CALL_direct_intersegment,
    input  logic        opcode_CALL_indirect_intersegment,
    input  logic        opcode_JMP_short,
    input  logic        opcode_JMP_direct_within_segment,
    input  logic        opcode_JMP_indirect_within_segment,
    input  logic        opcode_JMP_direct_intersegment,
    input  logic        opcode_JMP_indirect_intersegment,
    input  logic        opcode_RET_within_segment,
    input  logic        opcode_RET_within_segment_adding_imm_to_SP,
    input  logic        opcode_RET_intersegment,
    input  logic        opcode_RET_intersegment_adding_imm_to_SP,
    input  logic        opcode_JO_8bit_disp,
    input  logic        opcode_JO_full_disp,
    input  logic        opcode_JNO_8bit_disp,
    input  logic        opcode_JNO_full_disp,
    input  logic        opcode_JB_8bit_disp,
    input  logic        opcode_JB_full_disp,
    input  logic        opcode_JNB_8bit_disp,
    input  logic        opcode_JNB_full_disp,
    input  logic        opcode_JE_8bit_disp,
    input  logic        opcode_JE_full_disp,
    input  logic        opcode_JNE_8bit_disp,
    input  logic        opcode_JNE_full_disp,
    input  logic        opcode_JBE_8bit_disp,
    input  logic        opcode_JBE_full_disp,
    input  logic        opcode_JNBE_8bit_disp,
    input  logic        opcode_JNBE_full_disp,
    input  logic        opcode_JS_8bit_disp,
    input  logic        opcode_JS_full_disp,
    input  logic        opcode_JNS_8bit_disp,
    input  logic        opcode_JNS_full_disp,
    input  logic        opcode_JP_8bit_disp,
    input  logic        opcode_JP_full_disp,
    input  logic        opcode_JNP_8bit_disp,
    input  logic        opcode_JNP_full_disp,
    input  logic        opcode_JL_8bit_disp,
    input  logic        opcode_JL_full_disp,
    input  logic        opcode_JNL_8bit_disp,
    input  logic        opcode_JNL_full_disp,
    input  logic        opcode_JLE_8bit_disp,
    input  logic        opcode_JLE_full_disp,
    input  logic        opcode_JNLE_8bit_disp,
    input  logic        opcode_JNLE_full_disp,
    input  logic        opcode_JCXZ,
    input  logic        opcode_LOOP,
    input  logic        opcode_LOOPZ,
    input  logic        opcode_LOOPNZ,
    input  logic        opcode_SETO,
    input  logic        opcode_SETNO,
    input  logic        opcode_SETB,
    input  logic        opcode_SETNB,
    input  logic        opcode_SETE,
    input  logic        opcode_SETNE,
    input  logic        opcode_SETBE,
    input  logic        opcode_SETNBE,
    input  logic        opcode_SETS,
    input  logic        opcode_SETNS,
    input  logic        opcode_SETP,
    input  logic        opcode_SETNP,
    input  logic        opcode_SETL,
    input  logic        opcode_SETNL,
    input  logic        opcode_SETLE,
    input  logic        opcode_SETNLE,
    input  logic        opcode_ENTER,
    input  logic        opcode_LEAVE,
    input  logic        opcode_INT_type_3,
    input  logic        opcode_INT_type_specified,
    input  logic        opcode_INTO,
    input  logic        opcode_BOUND,
    input  logic        opcode_IRET,
    input  logic        opcode_HLT,
    input  logic        opcode_MOV_CR0_CR2_CR3_from_reg,
    input  logic        opcode_MOV_reg_from_CR0_3,
    input  logic        opcode_MOV_DR0_7_from_reg,
    input  logic        opcode_MOV_reg_from_DR0_7,
    input  logic        opcode_MOV_TR6_7_from_reg,
    input  logic        opcode_MOV_reg_from_TR6_7,
    input  logic        opcode_NOP,
    input  logic        opcode_WAIT,
    input  logic        opcode_processor_extension_escape,
    input  logic        opcode_prefix_address_size,
    input  logic        opcode_prefix_bus_lock,
    input  logic        opcode_prefix_operand_size,
    input  logic        opcode_prefix_segment_override_CS,
    input  logic        opcode_prefix_segment_override_DS,
    input  logic        opcode_prefix_segment_override_ES,
    input  logic        opcode_prefix_segment_override_FS,
    input  logic        opcode_prefix_segment_override_GS,
    input  logic        opcode_prefix_segment_override_SS,
    input  logic        opcode_ARPL,
    input  logic        opcode_LAR,
    input  logic        opcode_LGDT,
    input  logic        opcode_LIDT,
    input  logic        opcode_LLDT,
    input  logic        opcode_LMSW,
    input  logic        opcode_LSL,
    input  logic        opcode_LTR,
    input  logic        opcode_SGDT,
    input  logic        opcode_SIDT,
    input  logic        opcode_SLDT,
    input  logic        opcode_SMSW,
    input  logic        opcode_STR,
    input  logic        opcode_VERR,
    input  logic        opcode_VERW,
    input  logic [ 7:0] instruction[0:9],
    output logic [ 1:0] length,
    output logic [31:0] operand_1,
    output logic [31:0] operand_2
);

always_comb begin
    case (1'b1)
        opcode_MOV_reg_to_reg_mem: begin

        end
        opcode_MOV_reg_mem_to_reg: begin

        end
        opcode_MOV_imm_to_reg_mem: begin

        end
        opcode_MOV_imm_to_reg_short: begin

        end
        opcode_MOV_mem_to_acc: begin

        end
        opcode_MOV_acc_to_mem: begin

        end
        opcode_MOV_reg_mem_to_sreg: begin

        end
        opcode_MOV_sreg_to_reg_mem: begin

        end
        opcode_MOVSX: begin

        end
        opcode_MOVZX: begin

        end
        opcode_PUSH_reg_mem: begin

        end
        opcode_PUSH_reg_short: begin

        end
        opcode_PUSH_sreg_2: begin

        end
        opcode_PUSH_sreg_3: begin

        end
        opcode_PUSH_imm: begin

        end
        opcode_PUSH_all: begin

        end
        opcode_POP_reg_mem: begin

        end
        opcode_POP_reg_short: begin

        end
        opcode_POP_sreg_2: begin

        end
        opcode_POP_sreg_3: begin

        end
        opcode_POP_all: begin

        end
        opcode_XCHG_reg_mem_with_reg: begin

        end
        opcode_XCHG_reg_with_acc_short: begin

        end
        opcode_IN_port_fixed: begin

        end
        opcode_IN_port_variable: begin

        end
        opcode_OUT_port_fixed: begin

        end
        opcode_OUT_port_variable: begin

        end
        opcode_LEA_load_ea_to_reg: begin

        end
        opcode_LDS_load_ptr_to_DS: begin

        end
        opcode_LES_load_ptr_to_ES: begin

        end
        opcode_LFS_load_ptr_to_FS: begin

        end
        opcode_LGS_load_ptr_to_GS: begin

        end
        opcode_LSS_load_ptr_to_SS: begin

        end
        opcode_CLC_clear_carry_flag: begin

        end
        opcode_CLD_clear_direction_flag: begin

        end
        opcode_CLI_clear_interrupt_enable_flag: begin

        end
        opcode_CLTS_clear_task_switched_flag: begin

        end
        opcode_CMC_complement_carry_flag: begin

        end
        opcode_LAHF_load_ah_into_flag: begin

        end
        opcode_POPF_pop_flags: begin

        end
        opcode_PUSHF_push_flags: begin

        end
        opcode_SAHF_store_ah_into_flag: begin

        end
        opcode_STC_set_carry_flag: begin

        end
        opcode_STD_set_direction_flag: begin

        end
        opcode_STI_set_interrupt_enable_flag: begin

        end
        opcode_ADD_reg_to_mem: begin

        end
        opcode_ADD_mem_to_reg: begin

        end
        opcode_ADD_imm_to_reg_mem: begin

        end
        opcode_ADD_imm_to_acc: begin

        end
        opcode_ADC_reg_to_mem: begin

        end
        opcode_ADC_mem_to_reg: begin

        end
        opcode_ADC_imm_to_reg_mem: begin

        end
        opcode_ADC_imm_to_acc: begin

        end
        opcode_INC_reg_mem: begin

        end
        opcode_INC_reg: begin

        end
        opcode_SUB_reg_to_mem: begin

        end
        opcode_SUB_mem_to_reg: begin

        end
        opcode_SUB_imm_to_reg_mem: begin

        end
        opcode_SUB_imm_to_acc: begin

        end
        opcode_SBB_reg_to_mem: begin

        end
        opcode_SBB_mem_to_reg: begin

        end
        opcode_SBB_imm_to_reg_mem: begin

        end
        opcode_SBB_imm_to_acc: begin

        end
        opcode_DEC_reg_mem: begin

        end
        opcode_DEC_reg: begin

        end
        opcode_CMP_mem_with_reg: begin

        end
        opcode_CMP_reg_with_mem: begin

        end
        opcode_CMP_imm_with_reg_mem: begin

        end
        opcode_CMP_imm_with_acc: begin

        end
        opcode_NEG_change_sign: begin

        end
        opcode_AAA: begin

        end
        opcode_AAS: begin

        end
        opcode_DAA: begin

        end
        opcode_DAS: begin

        end
        opcode_MUL_acc_with_reg_mem: begin

        end
        opcode_IMUL_acc_with_reg_mem: begin

        end
        opcode_IMUL_reg_with_reg_mem: begin

        end
        opcode_IMUL_reg_mem_with_imm_to_reg: begin

        end
        opcode_DIV_acc_by_reg_mem: begin

        end
        opcode_IDIV_acc_by_reg_mem: begin

        end
        opcode_AAD: begin

        end
        opcode_AAM: begin

        end
        opcode_CBW: begin

        end
        opcode_CWD: begin

        end
        opcode_ROL_reg_mem_by_1: begin

        end
        opcode_ROL_reg_mem_by_CL: begin

        end
        opcode_ROL_reg_mem_by_imm: begin

        end
        opcode_ROR_reg_mem_by_1: begin

        end
        opcode_ROR_reg_mem_by_CL: begin

        end
        opcode_ROR_reg_mem_by_imm: begin

        end
        opcode_SHL_reg_mem_by_1: begin

        end
        opcode_SHL_reg_mem_by_CL: begin

        end
        opcode_SHL_reg_mem_by_imm: begin

        end
        opcode_SAR_reg_mem_by_1: begin

        end
        opcode_SAR_reg_mem_by_CL: begin

        end
        opcode_SAR_reg_mem_by_imm: begin

        end
        opcode_SHR_reg_mem_by_1: begin

        end
        opcode_SHR_reg_mem_by_CL: begin

        end
        opcode_SHR_reg_mem_by_imm: begin

        end
        opcode_RCL_reg_mem_by_1: begin

        end
        opcode_RCL_reg_mem_by_CL: begin

        end
        opcode_RCL_reg_mem_by_imm: begin

        end
        opcode_RCR_reg_mem_by_1: begin

        end
        opcode_RCR_reg_mem_by_CL: begin

        end
        opcode_RCR_reg_mem_by_imm: begin

        end
        opcode_SHLD_reg_mem_by_imm: begin

        end
        opcode_SHLD_reg_mem_by_CL: begin

        end
        opcode_SHRD_reg_mem_by_imm: begin

        end
        opcode_SHRD_reg_mem_by_CL: begin

        end
        opcode_AND_reg_to_mem: begin

        end
        opcode_AND_mem_to_reg: begin

        end
        opcode_AND_imm_to_reg_mem: begin

        end
        opcode_AND_imm_to_acc: begin

        end
        opcode_TEST_reg_mem_and_reg: begin

        end
        opcode_TEST_imm_to_reg_mem: begin

        end
        opcode_TEST_imm_to_acc: begin

        end
        opcode_OR_reg_to_mem: begin

        end
        opcode_OR_mem_to_reg: begin

        end
        opcode_OR_imm_to_reg_mem: begin

        end
        opcode_OR_imm_to_acc: begin

        end
        opcode_XOR_reg_to_mem: begin

        end
        opcode_XOR_mem_to_reg: begin

        end
        opcode_XOR_imm_to_reg_mem: begin

        end
        opcode_XOR_imm_to_acc: begin

        end
        opcode_NOT: begin

        end
        opcode_CMPS: begin

        end
        opcode_INS: begin

        end
        opcode_LODS: begin

        end
        opcode_MOVS: begin

        end
        opcode_OUTS: begin

        end
        opcode_SCAS: begin

        end
        opcode_STOS: begin

        end
        opcode_XLAT: begin

        end
        opcode_REPE: begin

        end
        opcode_REPNE: begin

        end
        opcode_BSF: begin

        end
        opcode_BSR: begin

        end
        opcode_BT_reg_mem_with_imm: begin

        end
        opcode_BT_reg_mem_with_reg: begin

        end
        opcode_BTC_reg_mem_with_imm: begin

        end
        opcode_BTC_reg_mem_with_reg: begin

        end
        opcode_BTR_reg_mem_with_imm: begin

        end
        opcode_BTR_reg_mem_with_reg: begin

        end
        opcode_BTS_reg_mem_with_imm: begin

        end
        opcode_BTS_reg_mem_with_reg: begin

        end
        opcode_CALL_direct_within_segment: begin

        end
        opcode_CALL_indirect_within_segment: begin

        end
        opcode_CALL_direct_intersegment: begin

        end
        opcode_CALL_indirect_intersegment: begin

        end
        opcode_JMP_short: begin

        end
        opcode_JMP_direct_within_segment: begin

        end
        opcode_JMP_indirect_within_segment: begin

        end
        opcode_JMP_direct_intersegment: begin

        end
        opcode_JMP_indirect_intersegment: begin

        end
        opcode_RET_within_segment: begin

        end
        opcode_RET_within_segment_adding_imm_to_SP: begin

        end
        opcode_RET_intersegment: begin

        end
        opcode_RET_intersegment_adding_imm_to_SP: begin

        end
        opcode_JO_8bit_disp: begin

        end
        opcode_JO_full_disp: begin

        end
        opcode_JNO_8bit_disp: begin

        end
        opcode_JNO_full_disp: begin

        end
        opcode_JB_8bit_disp: begin

        end
        opcode_JB_full_disp: begin

        end
        opcode_JNB_8bit_disp: begin

        end
        opcode_JNB_full_disp: begin

        end
        opcode_JE_8bit_disp: begin

        end
        opcode_JE_full_disp: begin

        end
        opcode_JNE_8bit_disp: begin

        end
        opcode_JNE_full_disp: begin

        end
        opcode_JBE_8bit_disp: begin

        end
        opcode_JBE_full_disp: begin

        end
        opcode_JNBE_8bit_disp: begin

        end
        opcode_JNBE_full_disp: begin

        end
        opcode_JS_8bit_disp: begin

        end
        opcode_JS_full_disp: begin

        end
        opcode_JNS_8bit_disp: begin

        end
        opcode_JNS_full_disp: begin

        end
        opcode_JP_8bit_disp: begin

        end
        opcode_JP_full_disp: begin

        end
        opcode_JNP_8bit_disp: begin

        end
        opcode_JNP_full_disp: begin

        end
        opcode_JL_8bit_disp: begin

        end
        opcode_JL_full_disp: begin

        end
        opcode_JNL_8bit_disp: begin

        end
        opcode_JNL_full_disp: begin

        end
        opcode_JLE_8bit_disp: begin

        end
        opcode_JLE_full_disp: begin

        end
        opcode_JNLE_8bit_disp: begin

        end
        opcode_JNLE_full_disp: begin

        end
        opcode_JCXZ: begin

        end
        opcode_LOOP: begin

        end
        opcode_LOOPZ: begin

        end
        opcode_LOOPNZ: begin

        end
        opcode_SETO: begin

        end
        opcode_SETNO: begin

        end
        opcode_SETB: begin

        end
        opcode_SETNB: begin

        end
        opcode_SETE: begin

        end
        opcode_SETNE: begin

        end
        opcode_SETBE: begin

        end
        opcode_SETNBE: begin

        end
        opcode_SETS: begin

        end
        opcode_SETNS: begin

        end
        opcode_SETP: begin

        end
        opcode_SETNP: begin

        end
        opcode_SETL: begin

        end
        opcode_SETNL: begin

        end
        opcode_SETLE: begin

        end
        opcode_SETNLE: begin

        end
        opcode_ENTER: begin

        end
        opcode_LEAVE: begin

        end
        opcode_INT_type_3: begin

        end
        opcode_INT_type_specified: begin

        end
        opcode_INTO: begin

        end
        opcode_BOUND: begin

        end
        opcode_IRET: begin

        end
        opcode_HLT: begin

        end
        opcode_MOV_CR0_CR2_CR3_from_reg: begin

        end
        opcode_MOV_reg_from_CR0_3: begin

        end
        opcode_MOV_DR0_7_from_reg: begin

        end
        opcode_MOV_reg_from_DR0_7: begin

        end
        opcode_MOV_TR6_7_from_reg: begin

        end
        opcode_MOV_reg_from_TR6_7: begin

        end
        opcode_NOP: begin

        end
        opcode_WAIT: begin

        end
        opcode_processor_extension_escape: begin

        end
        opcode_prefix_address_size: begin

        end
        opcode_prefix_bus_lock: begin

        end
        opcode_prefix_operand_size: begin

        end
        opcode_prefix_segment_override_CS: begin

        end
        opcode_prefix_segment_override_DS: begin

        end
        opcode_prefix_segment_override_ES: begin

        end
        opcode_prefix_segment_override_FS: begin

        end
        opcode_prefix_segment_override_GS: begin

        end
        opcode_prefix_segment_override_SS: begin

        end
        opcode_ARPL: begin

        end
        opcode_LAR: begin

        end
        opcode_LGDT: begin

        end
        opcode_LIDT: begin

        end
        opcode_LLDT: begin

        end
        opcode_LMSW: begin

        end
        opcode_LSL: begin

        end
        opcode_LTR: begin

        end
        opcode_SGDT: begin

        end
        opcode_SIDT: begin

        end
        opcode_SLDT: begin

        end
        opcode_SMSW: begin

        end
        opcode_STR: begin

        end
        opcode_VERR: begin

        end
        opcode_VERW: begin

        end
        default: begin
        end
    endcase
end

endmodule
