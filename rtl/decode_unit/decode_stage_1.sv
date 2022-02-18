/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_stage_1
create at: 2021-12-28 16:56:15
description: decode stage-1
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_stage_1 (
    interface_opcode.opcode_output opcode,
    input  logic [ 7:0] instruction [0:15],
    output logic        is_prefix_segment,
    output logic        is_prefix,
    output logic        s_is_present,
    output logic        s,
    output logic        w_is_present,
    output logic        w,
    output logic        greg_is_present,
    output logic [ 2:0] greg,
    output logic        sreg_is_present,
    output logic [ 2:0] sreg,
    output logic        mod_rm_is_present,
    output logic [ 1:0] mod,
    output logic [ 2:0] rm,
    output logic        displacement_is_present,
    output logic [ 2:0] displacement_length, // 0 means displacement length is unknwon, 3 means full length
    output logic        immediate_is_present,
    output logic [ 1:0] immediate_length,
    output logic        unsigned_full_offset_or_selector_is_present,
    output logic        next_stage_decode_offset_1,
    output logic        next_stage_decode_offset_2,
    output logic        next_stage_decode_offset_3,
    output logic        next_stage_decode_offset_4
);

wire opcode_MOV_reg_to_reg_mem = opcode.opcode_MOV_reg_to_reg_mem;
wire opcode_MOV_reg_mem_to_reg = opcode.opcode_MOV_reg_mem_to_reg;
wire opcode_MOV_imm_to_reg_mem = opcode.opcode_MOV_imm_to_reg_mem;
wire opcode_MOV_imm_to_reg_short = opcode.opcode_MOV_imm_to_reg_short;
wire opcode_MOV_mem_to_acc = opcode.opcode_MOV_mem_to_acc;
wire opcode_MOV_acc_to_mem = opcode.opcode_MOV_acc_to_mem;
wire opcode_MOV_reg_mem_to_sreg = opcode.opcode_MOV_reg_mem_to_sreg;
wire opcode_MOV_sreg_to_reg_mem = opcode.opcode_MOV_sreg_to_reg_mem;
wire opcode_MOVSX = opcode.opcode_MOVSX;
wire opcode_MOVZX = opcode.opcode_MOVZX;
wire opcode_PUSH_reg_mem = opcode.opcode_PUSH_reg_mem;
wire opcode_PUSH_reg_short = opcode.opcode_PUSH_reg_short;
wire opcode_PUSH_sreg_2 = opcode.opcode_PUSH_sreg_2;
wire opcode_PUSH_sreg_3 = opcode.opcode_PUSH_sreg_3;
wire opcode_PUSH_imm = opcode.opcode_PUSH_imm;
wire opcode_PUSH_all = opcode.opcode_PUSH_all;
wire opcode_POP_reg_mem = opcode.opcode_POP_reg_mem;
wire opcode_POP_reg_short = opcode.opcode_POP_reg_short;
wire opcode_POP_sreg_2 = opcode.opcode_POP_sreg_2;
wire opcode_POP_sreg_3 = opcode.opcode_POP_sreg_3;
wire opcode_POP_all = opcode.opcode_POP_all;
wire opcode_XCHG_reg_mem_with_reg = opcode.opcode_XCHG_reg_mem_with_reg;
wire opcode_XCHG_reg_with_acc_short = opcode.opcode_XCHG_reg_with_acc_short;
wire opcode_IN_port_fixed = opcode.opcode_IN_port_fixed;
wire opcode_IN_port_variable = opcode.opcode_IN_port_variable;
wire opcode_OUT_port_fixed = opcode.opcode_OUT_port_fixed;
wire opcode_OUT_port_variable = opcode.opcode_OUT_port_variable;
wire opcode_LEA_load_ea_to_reg = opcode.opcode_LEA_load_ea_to_reg;
wire opcode_LDS_load_ptr_to_DS = opcode.opcode_LDS_load_ptr_to_DS;
wire opcode_LES_load_ptr_to_ES = opcode.opcode_LES_load_ptr_to_ES;
wire opcode_LFS_load_ptr_to_FS = opcode.opcode_LFS_load_ptr_to_FS;
wire opcode_LGS_load_ptr_to_GS = opcode.opcode_LGS_load_ptr_to_GS;
wire opcode_LSS_load_ptr_to_SS = opcode.opcode_LSS_load_ptr_to_SS;
wire opcode_CLC_clear_carry_flag = opcode.opcode_CLC_clear_carry_flag;
wire opcode_CLD_clear_direction_flag = opcode.opcode_CLD_clear_direction_flag;
wire opcode_CLI_clear_interrupt_enable_flag = opcode.opcode_CLI_clear_interrupt_enable_flag;
wire opcode_CLTS_clear_task_switched_flag = opcode.opcode_CLTS_clear_task_switched_flag;
wire opcode_CMC_complement_carry_flag = opcode.opcode_CMC_complement_carry_flag;
wire opcode_LAHF_load_ah_into_flag = opcode.opcode_LAHF_load_ah_into_flag;
wire opcode_POPF_pop_flags = opcode.opcode_POPF_pop_flags;
wire opcode_PUSHF_push_flags = opcode.opcode_PUSHF_push_flags;
wire opcode_SAHF_store_ah_into_flag = opcode.opcode_SAHF_store_ah_into_flag;
wire opcode_STC_set_carry_flag = opcode.opcode_STC_set_carry_flag;
wire opcode_STD_set_direction_flag = opcode.opcode_STD_set_direction_flag;
wire opcode_STI_set_interrupt_enable_flag = opcode.opcode_STI_set_interrupt_enable_flag;
wire opcode_ADD_reg_to_mem = opcode.opcode_ADD_reg_to_mem;
wire opcode_ADD_mem_to_reg = opcode.opcode_ADD_mem_to_reg;
wire opcode_ADD_imm_to_reg_mem = opcode.opcode_ADD_imm_to_reg_mem;
wire opcode_ADD_imm_to_acc = opcode.opcode_ADD_imm_to_acc;
wire opcode_ADC_reg_to_mem = opcode.opcode_ADC_reg_to_mem;
wire opcode_ADC_mem_to_reg = opcode.opcode_ADC_mem_to_reg;
wire opcode_ADC_imm_to_reg_mem = opcode.opcode_ADC_imm_to_reg_mem;
wire opcode_ADC_imm_to_acc = opcode.opcode_ADC_imm_to_acc;
wire opcode_INC_reg_mem = opcode.opcode_INC_reg_mem;
wire opcode_INC_reg = opcode.opcode_INC_reg;
wire opcode_SUB_reg_to_mem = opcode.opcode_SUB_reg_to_mem;
wire opcode_SUB_mem_to_reg = opcode.opcode_SUB_mem_to_reg;
wire opcode_SUB_imm_to_reg_mem = opcode.opcode_SUB_imm_to_reg_mem;
wire opcode_SUB_imm_to_acc = opcode.opcode_SUB_imm_to_acc;
wire opcode_SBB_reg_to_mem = opcode.opcode_SBB_reg_to_mem;
wire opcode_SBB_mem_to_reg = opcode.opcode_SBB_mem_to_reg;
wire opcode_SBB_imm_to_reg_mem = opcode.opcode_SBB_imm_to_reg_mem;
wire opcode_SBB_imm_to_acc = opcode.opcode_SBB_imm_to_acc;
wire opcode_DEC_reg_mem = opcode.opcode_DEC_reg_mem;
wire opcode_DEC_reg = opcode.opcode_DEC_reg;
wire opcode_CMP_mem_with_reg = opcode.opcode_CMP_mem_with_reg;
wire opcode_CMP_reg_with_mem = opcode.opcode_CMP_reg_with_mem;
wire opcode_CMP_imm_with_reg_mem = opcode.opcode_CMP_imm_with_reg_mem;
wire opcode_CMP_imm_with_acc = opcode.opcode_CMP_imm_with_acc;
wire opcode_NEG_change_sign = opcode.opcode_NEG_change_sign;
wire opcode_AAA = opcode.opcode_AAA;
wire opcode_AAS = opcode.opcode_AAS;
wire opcode_DAA = opcode.opcode_DAA;
wire opcode_DAS = opcode.opcode_DAS;
wire opcode_MUL_acc_with_reg_mem = opcode.opcode_MUL_acc_with_reg_mem;
wire opcode_IMUL_acc_with_reg_mem = opcode.opcode_IMUL_acc_with_reg_mem;
wire opcode_IMUL_reg_with_reg_mem = opcode.opcode_IMUL_reg_with_reg_mem;
wire opcode_IMUL_reg_mem_with_imm_to_reg = opcode.opcode_IMUL_reg_mem_with_imm_to_reg;
wire opcode_DIV_acc_by_reg_mem = opcode.opcode_DIV_acc_by_reg_mem;
wire opcode_IDIV_acc_by_reg_mem = opcode.opcode_IDIV_acc_by_reg_mem;
wire opcode_AAD = opcode.opcode_AAD;
wire opcode_AAM = opcode.opcode_AAM;
wire opcode_CBW = opcode.opcode_CBW;
wire opcode_CWD = opcode.opcode_CWD;
wire opcode_ROL_reg_mem_by_1 = opcode.opcode_ROL_reg_mem_by_1;
wire opcode_ROL_reg_mem_by_CL = opcode.opcode_ROL_reg_mem_by_CL;
wire opcode_ROL_reg_mem_by_imm = opcode.opcode_ROL_reg_mem_by_imm;
wire opcode_ROR_reg_mem_by_1 = opcode.opcode_ROR_reg_mem_by_1;
wire opcode_ROR_reg_mem_by_CL = opcode.opcode_ROR_reg_mem_by_CL;
wire opcode_ROR_reg_mem_by_imm = opcode.opcode_ROR_reg_mem_by_imm;
wire opcode_SHL_reg_mem_by_1 = opcode.opcode_SHL_reg_mem_by_1;
wire opcode_SHL_reg_mem_by_CL = opcode.opcode_SHL_reg_mem_by_CL;
wire opcode_SHL_reg_mem_by_imm = opcode.opcode_SHL_reg_mem_by_imm;
wire opcode_SAR_reg_mem_by_1 = opcode.opcode_SAR_reg_mem_by_1;
wire opcode_SAR_reg_mem_by_CL = opcode.opcode_SAR_reg_mem_by_CL;
wire opcode_SAR_reg_mem_by_imm = opcode.opcode_SAR_reg_mem_by_imm;
wire opcode_SHR_reg_mem_by_1 = opcode.opcode_SHR_reg_mem_by_1;
wire opcode_SHR_reg_mem_by_CL = opcode.opcode_SHR_reg_mem_by_CL;
wire opcode_SHR_reg_mem_by_imm = opcode.opcode_SHR_reg_mem_by_imm;
wire opcode_RCL_reg_mem_by_1 = opcode.opcode_RCL_reg_mem_by_1;
wire opcode_RCL_reg_mem_by_CL = opcode.opcode_RCL_reg_mem_by_CL;
wire opcode_RCL_reg_mem_by_imm = opcode.opcode_RCL_reg_mem_by_imm;
wire opcode_RCR_reg_mem_by_1 = opcode.opcode_RCR_reg_mem_by_1;
wire opcode_RCR_reg_mem_by_CL = opcode.opcode_RCR_reg_mem_by_CL;
wire opcode_RCR_reg_mem_by_imm = opcode.opcode_RCR_reg_mem_by_imm;
wire opcode_SHLD_reg_mem_by_imm = opcode.opcode_SHLD_reg_mem_by_imm;
wire opcode_SHLD_reg_mem_by_CL = opcode.opcode_SHLD_reg_mem_by_CL;
wire opcode_SHRD_reg_mem_by_imm = opcode.opcode_SHRD_reg_mem_by_imm;
wire opcode_SHRD_reg_mem_by_CL = opcode.opcode_SHRD_reg_mem_by_CL;
wire opcode_AND_reg_to_mem = opcode.opcode_AND_reg_to_mem;
wire opcode_AND_mem_to_reg = opcode.opcode_AND_mem_to_reg;
wire opcode_AND_imm_to_reg_mem = opcode.opcode_AND_imm_to_reg_mem;
wire opcode_AND_imm_to_acc = opcode.opcode_AND_imm_to_acc;
wire opcode_TEST_reg_mem_and_reg = opcode.opcode_TEST_reg_mem_and_reg;
wire opcode_TEST_imm_to_reg_mem = opcode.opcode_TEST_imm_to_reg_mem;
wire opcode_TEST_imm_to_acc = opcode.opcode_TEST_imm_to_acc;
wire opcode_OR_reg_to_mem = opcode.opcode_OR_reg_to_mem;
wire opcode_OR_mem_to_reg = opcode.opcode_OR_mem_to_reg;
wire opcode_OR_imm_to_reg_mem = opcode.opcode_OR_imm_to_reg_mem;
wire opcode_OR_imm_to_acc = opcode.opcode_OR_imm_to_acc;
wire opcode_XOR_reg_to_mem = opcode.opcode_XOR_reg_to_mem;
wire opcode_XOR_mem_to_reg = opcode.opcode_XOR_mem_to_reg;
wire opcode_XOR_imm_to_reg_mem = opcode.opcode_XOR_imm_to_reg_mem;
wire opcode_XOR_imm_to_acc = opcode.opcode_XOR_imm_to_acc;
wire opcode_NOT = opcode.opcode_NOT;
wire opcode_CMPS = opcode.opcode_CMPS;
wire opcode_INS = opcode.opcode_INS;
wire opcode_LODS = opcode.opcode_LODS;
wire opcode_MOVS = opcode.opcode_MOVS;
wire opcode_OUTS = opcode.opcode_OUTS;
wire opcode_SCAS = opcode.opcode_SCAS;
wire opcode_STOS = opcode.opcode_STOS;
wire opcode_XLAT = opcode.opcode_XLAT;
wire opcode_REPE = opcode.opcode_REPE;
wire opcode_REPNE = opcode.opcode_REPNE;
wire opcode_BSF = opcode.opcode_BSF;
wire opcode_BSR = opcode.opcode_BSR;
wire opcode_BT_reg_mem_with_imm = opcode.opcode_BT_reg_mem_with_imm;
wire opcode_BT_reg_mem_with_reg = opcode.opcode_BT_reg_mem_with_reg;
wire opcode_BTC_reg_mem_with_imm = opcode.opcode_BTC_reg_mem_with_imm;
wire opcode_BTC_reg_mem_with_reg = opcode.opcode_BTC_reg_mem_with_reg;
wire opcode_BTR_reg_mem_with_imm = opcode.opcode_BTR_reg_mem_with_imm;
wire opcode_BTR_reg_mem_with_reg = opcode.opcode_BTR_reg_mem_with_reg;
wire opcode_BTS_reg_mem_with_imm = opcode.opcode_BTS_reg_mem_with_imm;
wire opcode_BTS_reg_mem_with_reg = opcode.opcode_BTS_reg_mem_with_reg;
wire opcode_CALL_direct_within_segment = opcode.opcode_CALL_direct_within_segment;
wire opcode_CALL_indirect_within_segment = opcode.opcode_CALL_indirect_within_segment;
wire opcode_CALL_direct_intersegment = opcode.opcode_CALL_direct_intersegment;
wire opcode_CALL_indirect_intersegment = opcode.opcode_CALL_indirect_intersegment;
wire opcode_JMP_short = opcode.opcode_JMP_short;
wire opcode_JMP_direct_within_segment = opcode.opcode_JMP_direct_within_segment;
wire opcode_JMP_indirect_within_segment = opcode.opcode_JMP_indirect_within_segment;
wire opcode_JMP_direct_intersegment = opcode.opcode_JMP_direct_intersegment;
wire opcode_JMP_indirect_intersegment = opcode.opcode_JMP_indirect_intersegment;
wire opcode_RET_within_segment = opcode.opcode_RET_within_segment;
wire opcode_RET_within_segment_adding_imm_to_SP = opcode.opcode_RET_within_segment_adding_imm_to_SP;
wire opcode_RET_intersegment = opcode.opcode_RET_intersegment;
wire opcode_RET_intersegment_adding_imm_to_SP = opcode.opcode_RET_intersegment_adding_imm_to_SP;
wire opcode_JO_8bit_disp = opcode.opcode_JO_8bit_disp;
wire opcode_JO_full_disp = opcode.opcode_JO_full_disp;
wire opcode_JNO_8bit_disp = opcode.opcode_JNO_8bit_disp;
wire opcode_JNO_full_disp = opcode.opcode_JNO_full_disp;
wire opcode_JB_8bit_disp = opcode.opcode_JB_8bit_disp;
wire opcode_JB_full_disp = opcode.opcode_JB_full_disp;
wire opcode_JNB_8bit_disp = opcode.opcode_JNB_8bit_disp;
wire opcode_JNB_full_disp = opcode.opcode_JNB_full_disp;
wire opcode_JE_8bit_disp = opcode.opcode_JE_8bit_disp;
wire opcode_JE_full_disp = opcode.opcode_JE_full_disp;
wire opcode_JNE_8bit_disp = opcode.opcode_JNE_8bit_disp;
wire opcode_JNE_full_disp = opcode.opcode_JNE_full_disp;
wire opcode_JBE_8bit_disp = opcode.opcode_JBE_8bit_disp;
wire opcode_JBE_full_disp = opcode.opcode_JBE_full_disp;
wire opcode_JNBE_8bit_disp = opcode.opcode_JNBE_8bit_disp;
wire opcode_JNBE_full_disp = opcode.opcode_JNBE_full_disp;
wire opcode_JS_8bit_disp = opcode.opcode_JS_8bit_disp;
wire opcode_JS_full_disp = opcode.opcode_JS_full_disp;
wire opcode_JNS_8bit_disp = opcode.opcode_JNS_8bit_disp;
wire opcode_JNS_full_disp = opcode.opcode_JNS_full_disp;
wire opcode_JP_8bit_disp = opcode.opcode_JP_8bit_disp;
wire opcode_JP_full_disp = opcode.opcode_JP_full_disp;
wire opcode_JNP_8bit_disp = opcode.opcode_JNP_8bit_disp;
wire opcode_JNP_full_disp = opcode.opcode_JNP_full_disp;
wire opcode_JL_8bit_disp = opcode.opcode_JL_8bit_disp;
wire opcode_JL_full_disp = opcode.opcode_JL_full_disp;
wire opcode_JNL_8bit_disp = opcode.opcode_JNL_8bit_disp;
wire opcode_JNL_full_disp = opcode.opcode_JNL_full_disp;
wire opcode_JLE_8bit_disp = opcode.opcode_JLE_8bit_disp;
wire opcode_JLE_full_disp = opcode.opcode_JLE_full_disp;
wire opcode_JNLE_8bit_disp = opcode.opcode_JNLE_8bit_disp;
wire opcode_JNLE_full_disp = opcode.opcode_JNLE_full_disp;
wire opcode_JCXZ = opcode.opcode_JCXZ;
wire opcode_LOOP = opcode.opcode_LOOP;
wire opcode_LOOPZ = opcode.opcode_LOOPZ;
wire opcode_LOOPNZ = opcode.opcode_LOOPNZ;
wire opcode_SETO = opcode.opcode_SETO;
wire opcode_SETNO = opcode.opcode_SETNO;
wire opcode_SETB = opcode.opcode_SETB;
wire opcode_SETNB = opcode.opcode_SETNB;
wire opcode_SETE = opcode.opcode_SETE;
wire opcode_SETNE = opcode.opcode_SETNE;
wire opcode_SETBE = opcode.opcode_SETBE;
wire opcode_SETNBE = opcode.opcode_SETNBE;
wire opcode_SETS = opcode.opcode_SETS;
wire opcode_SETNS = opcode.opcode_SETNS;
wire opcode_SETP = opcode.opcode_SETP;
wire opcode_SETNP = opcode.opcode_SETNP;
wire opcode_SETL = opcode.opcode_SETL;
wire opcode_SETNL = opcode.opcode_SETNL;
wire opcode_SETLE = opcode.opcode_SETLE;
wire opcode_SETNLE = opcode.opcode_SETNLE;
wire opcode_ENTER = opcode.opcode_ENTER;
wire opcode_LEAVE = opcode.opcode_LEAVE;
wire opcode_INT_type_3 = opcode.opcode_INT_type_3;
wire opcode_INT_type_specified = opcode.opcode_INT_type_specified;
wire opcode_INTO = opcode.opcode_INTO;
wire opcode_BOUND = opcode.opcode_BOUND;
wire opcode_IRET = opcode.opcode_IRET;
wire opcode_HLT = opcode.opcode_HLT;
wire opcode_MOV_CR0_CR2_CR3_from_reg = opcode.opcode_MOV_CR0_CR2_CR3_from_reg;
wire opcode_MOV_reg_from_CR0_3 = opcode.opcode_MOV_reg_from_CR0_3;
wire opcode_MOV_DR0_7_from_reg = opcode.opcode_MOV_DR0_7_from_reg;
wire opcode_MOV_reg_from_DR0_7 = opcode.opcode_MOV_reg_from_DR0_7;
wire opcode_MOV_TR6_7_from_reg = opcode.opcode_MOV_TR6_7_from_reg;
wire opcode_MOV_reg_from_TR6_7 = opcode.opcode_MOV_reg_from_TR6_7;
wire opcode_NOP = opcode.opcode_NOP;
wire opcode_WAIT = opcode.opcode_WAIT;
wire opcode_processor_extension_escape = opcode.opcode_processor_extension_escape;
wire opcode_prefix_address_size = opcode.opcode_prefix_address_size;
wire opcode_prefix_bus_lock = opcode.opcode_prefix_bus_lock;
wire opcode_prefix_operand_size = opcode.opcode_prefix_operand_size;
wire opcode_prefix_segment_override_CS = opcode.opcode_prefix_segment_override_CS;
wire opcode_prefix_segment_override_DS = opcode.opcode_prefix_segment_override_DS;
wire opcode_prefix_segment_override_ES = opcode.opcode_prefix_segment_override_ES;
wire opcode_prefix_segment_override_FS = opcode.opcode_prefix_segment_override_FS;
wire opcode_prefix_segment_override_GS = opcode.opcode_prefix_segment_override_GS;
wire opcode_prefix_segment_override_SS = opcode.opcode_prefix_segment_override_SS;
wire opcode_ARPL = opcode.opcode_ARPL;
wire opcode_LAR = opcode.opcode_LAR;
wire opcode_LGDT = opcode.opcode_LGDT;
wire opcode_LIDT = opcode.opcode_LIDT;
wire opcode_LLDT = opcode.opcode_LLDT;
wire opcode_LMSW = opcode.opcode_LMSW;
wire opcode_LSL = opcode.opcode_LSL;
wire opcode_LTR = opcode.opcode_LTR;
wire opcode_SGDT = opcode.opcode_SGDT;
wire opcode_SIDT = opcode.opcode_SIDT;
wire opcode_SLDT = opcode.opcode_SLDT;
wire opcode_SMSW = opcode.opcode_SMSW;
wire opcode_STR = opcode.opcode_STR;
wire opcode_VERR = opcode.opcode_VERR;
wire opcode_VERW = opcode.opcode_VERW;

// prefix
assign is_prefix_segment =
opcode_prefix_segment_override_CS |
opcode_prefix_segment_override_DS |
opcode_prefix_segment_override_ES |
opcode_prefix_segment_override_FS |
opcode_prefix_segment_override_GS |
opcode_prefix_segment_override_SS |
1'b0;

assign is_prefix =
opcode_prefix_address_size |
opcode_prefix_bus_lock |
opcode_prefix_operand_size |
is_prefix_segment |
1'b0;


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
        s_at_0_1: begin s_is_present <= 1'b1; s <= instruction[0][1]; end
        default:  begin s_is_present <= 1'b0; s <= 0; end
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
        w_at_0_0: begin w_is_present <= 1'b1; w <= instruction[0][0]; end
        w_at_0_3: begin w_is_present <= 1'b1; w <= instruction[0][3]; end
        w_at_1_0: begin w_is_present <= 1'b1; w <= instruction[1][0]; end
        default:  begin w_is_present <= 1'b0; w <= 0; end
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
        reg_at_0_2_0: begin greg_is_present <= 1'b1; greg <= instruction[0][2:0]; end
        reg_at_1_5_3: begin greg_is_present <= 1'b1; greg <= instruction[1][5:3]; end
        reg_at_2_5_3: begin greg_is_present <= 1'b1; greg <= instruction[2][5:3]; end
        reg_at_2_2_0: begin greg_is_present <= 1'b1; greg <= instruction[2][2:0]; end
        default:      begin greg_is_present <= 1'b0; greg <= 0; end
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
        sreg3_at_1_5_3: begin sreg_is_present <= 1'b1; sreg <= instruction[1][5:3]; end
        sreg2_at_1_4_3: begin sreg_is_present <= 1'b1; sreg <= {1'b0, instruction[1][4:3]}; end
        default:        begin sreg_is_present <= 1'b0; sreg <= 0; end
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
        mod_rm_at_1: begin mod_rm_is_present <= 1'b1; mod <= instruction[1][7:6]; rm <= instruction[1][2:0]; end
        mod_rm_at_2: begin mod_rm_is_present <= 1'b1; mod <= instruction[2][7:6]; rm <= instruction[2][2:0]; end
        default:     begin mod_rm_is_present <= 1'b0; mod <= 0; rm <= 0; end
    endcase
end


// displacement
wire displacement_full =
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

wire displacement__8 =
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

wire displacement_16 =
opcode_RET_within_segment_adding_imm_to_SP |
opcode_RET_intersegment_adding_imm_to_SP |
opcode_ENTER |
1'b0;

assign displacement_is_present = displacement_full | displacement__8 | displacement_16;
assign displacement_length = {displacement__8, displacement_16, 1'b0, displacement_full};


// unsigned full offset or selector
assign unsigned_full_offset_or_selector_is_present =
opcode_CALL_direct_intersegment |
opcode_JMP_direct_intersegment |
1'b0;


// immediate
wire immediate_full =
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
wire immediate__8 =
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

assign immediate_is_present = immediate_full | immediate__8;
assign immediate_length = {immediate_full, immediate__8};


// length (include {mod {3-bytes opcode | greg} r/m})
assign next_stage_decode_offset_1 =
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
opcode_prefix_address_size |
opcode_prefix_bus_lock |
opcode_prefix_operand_size |
opcode_prefix_segment_override_CS |
opcode_prefix_segment_override_DS |
opcode_prefix_segment_override_ES |
opcode_prefix_segment_override_FS |
opcode_prefix_segment_override_GS |
opcode_prefix_segment_override_SS |
1'b0;

assign next_stage_decode_offset_2 =
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

assign next_stage_decode_offset_3 =
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

assign next_stage_decode_offset_4 =
opcode_SHLD_reg_mem_by_imm |
opcode_SHRD_reg_mem_by_imm |
opcode_BT_reg_mem_with_imm |
opcode_BTC_reg_mem_with_imm |
opcode_BTR_reg_mem_with_imm |
opcode_BTS_reg_mem_with_imm |
1'b0;

endmodule
