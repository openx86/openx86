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
    output logic [ 2:0] next_stage_decode_offset
);

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
wire opcode_length_1 =
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

wire opcode_length_2 =
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

wire opcode_length_3 =
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

wire opcode_length_4 =
opcode_SHLD_reg_mem_by_imm |
opcode_SHRD_reg_mem_by_imm |
opcode_BT_reg_mem_with_imm |
opcode_BTC_reg_mem_with_imm |
opcode_BTR_reg_mem_with_imm |
opcode_BTS_reg_mem_with_imm |
1'b0;

always_comb begin
    unique case (1'b1)
        opcode_length_1: next_stage_decode_offset <= 2'h0;
        opcode_length_2: next_stage_decode_offset <= 2'h1;
        opcode_length_3: next_stage_decode_offset <= 2'h2;
        opcode_length_4: next_stage_decode_offset <= 2'h3;
        default:         next_stage_decode_offset <= 2'h0;
    endcase
end

endmodule
