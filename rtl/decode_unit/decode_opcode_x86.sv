/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_opcode_x86
create at: 2022-03-02 00:41:18
description: decode x86(IA-32) opcode selection signal from instruction bytes
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"

module decode_opcode_x86 (
    input  logic [ 7:0] i_instruction [0:3],
    output logic        o_opcode_x86_MOV_reg_to_reg_mem,
    output logic        o_opcode_x86_MOV_reg_mem_to_reg,
    output logic        o_opcode_x86_MOV_imm_to_reg_mem,
    output logic        o_opcode_x86_MOV_imm_to_reg_short,
    output logic        o_opcode_x86_MOV_mem_to_acc,
    output logic        o_opcode_x86_MOV_acc_to_mem,
    output logic        o_opcode_x86_MOV_reg_mem_to_sreg,
    output logic        o_opcode_x86_MOV_sreg_to_reg_mem,
    output logic        o_opcode_x86_MOVSX,
    output logic        o_opcode_x86_MOVZX,
    output logic        o_opcode_x86_PUSH_reg_mem,
    output logic        o_opcode_x86_PUSH_reg_short,
    output logic        o_opcode_x86_PUSH_sreg_2,
    output logic        o_opcode_x86_PUSH_sreg_3,
    output logic        o_opcode_x86_PUSH_imm,
    output logic        o_opcode_x86_PUSH_all,
    output logic        o_opcode_x86_POP_reg_mem,
    output logic        o_opcode_x86_POP_reg_short,
    output logic        o_opcode_x86_POP_sreg_2,
    output logic        o_opcode_x86_POP_sreg_3,
    output logic        o_opcode_x86_POP_all,
    output logic        o_opcode_x86_XCHG_reg_mem_with_reg,
    output logic        o_opcode_x86_XCHG_reg_with_acc_short,
    output logic        o_opcode_x86_IN_port_fixed,
    output logic        o_opcode_x86_IN_port_variable,
    output logic        o_opcode_x86_OUT_port_fixed,
    output logic        o_opcode_x86_OUT_port_variable,
    output logic        o_opcode_x86_LEA_load_ea_to_reg,
    output logic        o_opcode_x86_LDS_load_ptr_to_DS,
    output logic        o_opcode_x86_LES_load_ptr_to_ES,
    output logic        o_opcode_x86_LFS_load_ptr_to_FS,
    output logic        o_opcode_x86_LGS_load_ptr_to_GS,
    output logic        o_opcode_x86_LSS_load_ptr_to_SS,
    output logic        o_opcode_x86_CLC_clear_carry_flag,
    output logic        o_opcode_x86_CLD_clear_direction_flag,
    output logic        o_opcode_x86_CLI_clear_interrupt_enable_flag,
    output logic        o_opcode_x86_CLTS_clear_task_switched_flag,
    output logic        o_opcode_x86_CMC_complement_carry_flag,
    output logic        o_opcode_x86_LAHF_load_ah_into_flag,
    output logic        o_opcode_x86_POPF_pop_flags,
    output logic        o_opcode_x86_PUSHF_push_flags,
    output logic        o_opcode_x86_SAHF_store_ah_into_flag,
    output logic        o_opcode_x86_STC_set_carry_flag,
    output logic        o_opcode_x86_STD_set_direction_flag,
    output logic        o_opcode_x86_STI_set_interrupt_enable_flag,
    output logic        o_opcode_x86_ADD_reg_to_mem,
    output logic        o_opcode_x86_ADD_mem_to_reg,
    output logic        o_opcode_x86_ADD_imm_to_reg_mem,
    output logic        o_opcode_x86_ADD_imm_to_acc,
    output logic        o_opcode_x86_ADC_reg_to_mem,
    output logic        o_opcode_x86_ADC_mem_to_reg,
    output logic        o_opcode_x86_ADC_imm_to_reg_mem,
    output logic        o_opcode_x86_ADC_imm_to_acc,
    output logic        o_opcode_x86_INC_reg_mem,
    output logic        o_opcode_x86_INC_reg,
    output logic        o_opcode_x86_SUB_reg_to_mem,
    output logic        o_opcode_x86_SUB_mem_to_reg,
    output logic        o_opcode_x86_SUB_imm_to_reg_mem,
    output logic        o_opcode_x86_SUB_imm_to_acc,
    output logic        o_opcode_x86_SBB_reg_to_mem,
    output logic        o_opcode_x86_SBB_mem_to_reg,
    output logic        o_opcode_x86_SBB_imm_to_reg_mem,
    output logic        o_opcode_x86_SBB_imm_to_acc,
    output logic        o_opcode_x86_DEC_reg_mem,
    output logic        o_opcode_x86_DEC_reg,
    output logic        o_opcode_x86_CMP_mem_with_reg,
    output logic        o_opcode_x86_CMP_reg_with_mem,
    output logic        o_opcode_x86_CMP_imm_with_reg_mem,
    output logic        o_opcode_x86_CMP_imm_with_acc,
    output logic        o_opcode_x86_NEG_change_sign,
    output logic        o_opcode_x86_AAA,
    output logic        o_opcode_x86_AAS,
    output logic        o_opcode_x86_DAA,
    output logic        o_opcode_x86_DAS,
    output logic        o_opcode_x86_MUL_acc_with_reg_mem,
    output logic        o_opcode_x86_IMUL_acc_with_reg_mem,
    output logic        o_opcode_x86_IMUL_reg_with_reg_mem,
    output logic        o_opcode_x86_IMUL_reg_mem_with_imm_to_reg,
    output logic        o_opcode_x86_DIV_acc_by_reg_mem,
    output logic        o_opcode_x86_IDIV_acc_by_reg_mem,
    output logic        o_opcode_x86_AAD,
    output logic        o_opcode_x86_AAM,
    output logic        o_opcode_x86_CBW,
    output logic        o_opcode_x86_CWD,
    output logic        o_opcode_x86_ROL_reg_mem_by_1,
    output logic        o_opcode_x86_ROL_reg_mem_by_CL,
    output logic        o_opcode_x86_ROL_reg_mem_by_imm,
    output logic        o_opcode_x86_ROR_reg_mem_by_1,
    output logic        o_opcode_x86_ROR_reg_mem_by_CL,
    output logic        o_opcode_x86_ROR_reg_mem_by_imm,
    output logic        o_opcode_x86_SHL_reg_mem_by_1,
    output logic        o_opcode_x86_SHL_reg_mem_by_CL,
    output logic        o_opcode_x86_SHL_reg_mem_by_imm,
    output logic        o_opcode_x86_SAR_reg_mem_by_1,
    output logic        o_opcode_x86_SAR_reg_mem_by_CL,
    output logic        o_opcode_x86_SAR_reg_mem_by_imm,
    output logic        o_opcode_x86_SHR_reg_mem_by_1,
    output logic        o_opcode_x86_SHR_reg_mem_by_CL,
    output logic        o_opcode_x86_SHR_reg_mem_by_imm,
    output logic        o_opcode_x86_RCL_reg_mem_by_1,
    output logic        o_opcode_x86_RCL_reg_mem_by_CL,
    output logic        o_opcode_x86_RCL_reg_mem_by_imm,
    output logic        o_opcode_x86_RCR_reg_mem_by_1,
    output logic        o_opcode_x86_RCR_reg_mem_by_CL,
    output logic        o_opcode_x86_RCR_reg_mem_by_imm,
    output logic        o_opcode_x86_SHLD_reg_mem_by_imm,
    output logic        o_opcode_x86_SHLD_reg_mem_by_CL,
    output logic        o_opcode_x86_SHRD_reg_mem_by_imm,
    output logic        o_opcode_x86_SHRD_reg_mem_by_CL,
    output logic        o_opcode_x86_AND_reg_to_mem,
    output logic        o_opcode_x86_AND_mem_to_reg,
    output logic        o_opcode_x86_AND_imm_to_reg_mem,
    output logic        o_opcode_x86_AND_imm_to_acc,
    output logic        o_opcode_x86_TEST_reg_mem_and_reg,
    output logic        o_opcode_x86_TEST_imm_to_reg_mem,
    output logic        o_opcode_x86_TEST_imm_to_acc,
    output logic        o_opcode_x86_OR_reg_to_mem,
    output logic        o_opcode_x86_OR_mem_to_reg,
    output logic        o_opcode_x86_OR_imm_to_reg_mem,
    output logic        o_opcode_x86_OR_imm_to_acc,
    output logic        o_opcode_x86_XOR_reg_to_mem,
    output logic        o_opcode_x86_XOR_mem_to_reg,
    output logic        o_opcode_x86_XOR_imm_to_reg_mem,
    output logic        o_opcode_x86_XOR_imm_to_acc,
    output logic        o_opcode_x86_NOT,
    output logic        o_opcode_x86_CMPS,
    output logic        o_opcode_x86_INS,
    output logic        o_opcode_x86_LODS,
    output logic        o_opcode_x86_MOVS,
    output logic        o_opcode_x86_OUTS,
    output logic        o_opcode_x86_SCAS,
    output logic        o_opcode_x86_STOS,
    output logic        o_opcode_x86_XLAT,
    output logic        o_opcode_x86_REPE,
    output logic        o_opcode_x86_REPNE,
    output logic        o_opcode_x86_BSF,
    output logic        o_opcode_x86_BSR,
    output logic        o_opcode_x86_BT_reg_mem_with_imm,
    output logic        o_opcode_x86_BT_reg_mem_with_reg,
    output logic        o_opcode_x86_BTC_reg_mem_with_imm,
    output logic        o_opcode_x86_BTC_reg_mem_with_reg,
    output logic        o_opcode_x86_BTR_reg_mem_with_imm,
    output logic        o_opcode_x86_BTR_reg_mem_with_reg,
    output logic        o_opcode_x86_BTS_reg_mem_with_imm,
    output logic        o_opcode_x86_BTS_reg_mem_with_reg,
    output logic        o_opcode_x86_CALL_direct_within_segment,
    output logic        o_opcode_x86_CALL_indirect_within_segment,
    output logic        o_opcode_x86_CALL_direct_intersegment,
    output logic        o_opcode_x86_CALL_indirect_intersegment,
    output logic        o_opcode_x86_JMP_short,
    output logic        o_opcode_x86_JMP_direct_within_segment,
    output logic        o_opcode_x86_JMP_indirect_within_segment,
    output logic        o_opcode_x86_JMP_direct_intersegment,
    output logic        o_opcode_x86_JMP_indirect_intersegment,
    output logic        o_opcode_x86_RET_within_segment,
    output logic        o_opcode_x86_RET_within_segment_adding_imm_to_SP,
    output logic        o_opcode_x86_RET_intersegment,
    output logic        o_opcode_x86_RET_intersegment_adding_imm_to_SP,
    output logic        o_opcode_x86_JO_8bit_disp,
    output logic        o_opcode_x86_JO_full_disp,
    output logic        o_opcode_x86_JNO_8bit_disp,
    output logic        o_opcode_x86_JNO_full_disp,
    output logic        o_opcode_x86_JB_8bit_disp,
    output logic        o_opcode_x86_JB_full_disp,
    output logic        o_opcode_x86_JNB_8bit_disp,
    output logic        o_opcode_x86_JNB_full_disp,
    output logic        o_opcode_x86_JE_8bit_disp,
    output logic        o_opcode_x86_JE_full_disp,
    output logic        o_opcode_x86_JNE_8bit_disp,
    output logic        o_opcode_x86_JNE_full_disp,
    output logic        o_opcode_x86_JBE_8bit_disp,
    output logic        o_opcode_x86_JBE_full_disp,
    output logic        o_opcode_x86_JNBE_8bit_disp,
    output logic        o_opcode_x86_JNBE_full_disp,
    output logic        o_opcode_x86_JS_8bit_disp,
    output logic        o_opcode_x86_JS_full_disp,
    output logic        o_opcode_x86_JNS_8bit_disp,
    output logic        o_opcode_x86_JNS_full_disp,
    output logic        o_opcode_x86_JP_8bit_disp,
    output logic        o_opcode_x86_JP_full_disp,
    output logic        o_opcode_x86_JNP_8bit_disp,
    output logic        o_opcode_x86_JNP_full_disp,
    output logic        o_opcode_x86_JL_8bit_disp,
    output logic        o_opcode_x86_JL_full_disp,
    output logic        o_opcode_x86_JNL_8bit_disp,
    output logic        o_opcode_x86_JNL_full_disp,
    output logic        o_opcode_x86_JLE_8bit_disp,
    output logic        o_opcode_x86_JLE_full_disp,
    output logic        o_opcode_x86_JNLE_8bit_disp,
    output logic        o_opcode_x86_JNLE_full_disp,
    output logic        o_opcode_x86_JCXZ,
    output logic        o_opcode_x86_LOOP,
    output logic        o_opcode_x86_LOOPZ,
    output logic        o_opcode_x86_LOOPNZ,
    output logic        o_opcode_x86_SETO,
    output logic        o_opcode_x86_SETNO,
    output logic        o_opcode_x86_SETB,
    output logic        o_opcode_x86_SETNB,
    output logic        o_opcode_x86_SETE,
    output logic        o_opcode_x86_SETNE,
    output logic        o_opcode_x86_SETBE,
    output logic        o_opcode_x86_SETNBE,
    output logic        o_opcode_x86_SETS,
    output logic        o_opcode_x86_SETNS,
    output logic        o_opcode_x86_SETP,
    output logic        o_opcode_x86_SETNP,
    output logic        o_opcode_x86_SETL,
    output logic        o_opcode_x86_SETNL,
    output logic        o_opcode_x86_SETLE,
    output logic        o_opcode_x86_SETNLE,
    output logic        o_opcode_x86_ENTER,
    output logic        o_opcode_x86_LEAVE,
    output logic        o_opcode_x86_INT_type_3,
    output logic        o_opcode_x86_INT_type_specified,
    output logic        o_opcode_x86_INTO,
    output logic        o_opcode_x86_BOUND,
    output logic        o_opcode_x86_IRET,
    output logic        o_opcode_x86_HLT,
    output logic        o_opcode_x86_MOV_CR0_CR2_CR3_from_reg,
    output logic        o_opcode_x86_MOV_reg_from_CR0_3,
    output logic        o_opcode_x86_MOV_DR0_7_from_reg,
    output logic        o_opcode_x86_MOV_reg_from_DR0_7,
    output logic        o_opcode_x86_MOV_TR6_7_from_reg,
    output logic        o_opcode_x86_MOV_reg_from_TR6_7,
    output logic        o_opcode_x86_NOP,
    output logic        o_opcode_x86_WAIT,
    output logic        o_opcode_x86_processor_extension_escape,
    output logic        o_opcode_x86_ARPL,
    output logic        o_opcode_x86_LAR,
    output logic        o_opcode_x86_LGDT,
    output logic        o_opcode_x86_LIDT,
    output logic        o_opcode_x86_LLDT,
    output logic        o_opcode_x86_LMSW,
    output logic        o_opcode_x86_LSL,
    output logic        o_opcode_x86_LTR,
    output logic        o_opcode_x86_SGDT,
    output logic        o_opcode_x86_SIDT,
    output logic        o_opcode_x86_SLDT,
    output logic        o_opcode_x86_SMSW,
    output logic        o_opcode_x86_STR,
    output logic        o_opcode_x86_VERR,
    output logic        o_opcode_x86_VERW,
    output logic        o_error
);

assign o_opcode_x86_MOV_reg_to_reg_mem                  = (i_instruction[0][7:1] == 7'b1000_100 );
assign o_opcode_x86_MOV_reg_mem_to_reg                  = (i_instruction[0][7:1] == 7'b1000_101 );
assign o_opcode_x86_MOV_imm_to_reg_mem                  = (i_instruction[0][7:1] == 7'b1100_011 ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_x86_MOV_imm_to_reg_short                = (i_instruction[0][7:4] == 4'b1011     );
assign o_opcode_x86_MOV_mem_to_acc                      = (i_instruction[0][7:1] == 7'b1010_000 );
assign o_opcode_x86_MOV_acc_to_mem                      = (i_instruction[0][7:1] == 7'b1010_001 );
assign o_opcode_x86_MOV_reg_mem_to_sreg                 = (i_instruction[0][7:0] == 8'b1000_1110);
assign o_opcode_x86_MOV_sreg_to_reg_mem                 = (i_instruction[0][7:0] == 8'b1000_1100);
assign o_opcode_x86_MOVSX                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:1] == 7'b1011_111);
assign o_opcode_x86_MOVZX                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:1] == 7'b1011_011);
assign o_opcode_x86_PUSH_reg_mem                        = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b110);
assign o_opcode_x86_PUSH_reg_short                      = (i_instruction[0][7:3] == 5'b0101_0   );
assign o_opcode_x86_PUSH_sreg_2                         = (i_instruction[0][7:5] == 3'b000      ) & (i_instruction[0][2:0] == 3'b110);
assign o_opcode_x86_PUSH_sreg_3                         = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:6] == 2'b10) & (i_instruction[1][5] == 1'b1) & (i_instruction[1][2:0] == 3'b000);
assign o_opcode_x86_PUSH_imm                            = (i_instruction[0][7:2] == 6'b0110_10  ) & (i_instruction[0][0] == 1'b0);
assign o_opcode_x86_PUSH_all                            = (i_instruction[0][7:0] == 8'b0110_0000);
assign o_opcode_x86_POP_reg_mem                         = (i_instruction[0][7:0] == 8'b1000_1111) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_x86_POP_reg_short                       = (i_instruction[0][7:3] == 5'b0101_1   );
assign o_opcode_x86_POP_sreg_2                          = (i_instruction[0][7:5] == 3'b000      ) & (i_instruction[0][4:3] != 2'b01) & (i_instruction[0][2:0] == 3'b111) & (i_instruction[1][5:3] != 3'b110) & (i_instruction[1][5:3] != 3'b111);
assign o_opcode_x86_POP_sreg_3                          = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:6] == 2'b10) & (i_instruction[1][5] == 1'b1) & (i_instruction[1][2:0] == 3'b001);
assign o_opcode_x86_POP_all                             = (i_instruction[0][7:0] == 8'b0110_0001);
assign o_opcode_x86_XCHG_reg_mem_with_reg               = (i_instruction[0][7:1] == 7'b1000_011 );
assign o_opcode_x86_XCHG_reg_with_acc_short             = (i_instruction[0][7:3] == 5'b1001_0   ) & (i_instruction[0][2:0] != 3'b000);
assign o_opcode_x86_IN_port_fixed                       = (i_instruction[0][7:1] == 7'b1110_010 );
assign o_opcode_x86_IN_port_variable                    = (i_instruction[0][7:1] == 7'b1110_110 );
assign o_opcode_x86_OUT_port_fixed                      = (i_instruction[0][7:1] == 7'b1110_011 );
assign o_opcode_x86_OUT_port_variable                   = (i_instruction[0][7:1] == 7'b1110_111 );
assign o_opcode_x86_LEA_load_ea_to_reg                  = (i_instruction[0][7:0] == 8'b1000_1101);
assign o_opcode_x86_LDS_load_ptr_to_DS                  = (i_instruction[0][7:0] == 8'b1100_0101);
assign o_opcode_x86_LES_load_ptr_to_ES                  = (i_instruction[0][7:0] == 8'b1100_0100);
assign o_opcode_x86_LFS_load_ptr_to_FS                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0100);
assign o_opcode_x86_LGS_load_ptr_to_GS                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0101);
assign o_opcode_x86_LSS_load_ptr_to_SS                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0010);
assign o_opcode_x86_CLC_clear_carry_flag                = (i_instruction[0][7:0] == 8'b1111_1000);
assign o_opcode_x86_CLD_clear_direction_flag            = (i_instruction[0][7:0] == 8'b1111_1100);
assign o_opcode_x86_CLI_clear_interrupt_enable_flag     = (i_instruction[0][7:0] == 8'b1111_1010);
assign o_opcode_x86_CLTS_clear_task_switched_flag       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0110);
assign o_opcode_x86_CMC_complement_carry_flag           = (i_instruction[0][7:0] == 8'b1111_0101);
assign o_opcode_x86_LAHF_load_ah_into_flag              = (i_instruction[0][7:0] == 8'b1001_1111);
assign o_opcode_x86_POPF_pop_flags                      = (i_instruction[0][7:0] == 8'b1001_1101);
assign o_opcode_x86_PUSHF_push_flags                    = (i_instruction[0][7:0] == 8'b1001_1100);
assign o_opcode_x86_SAHF_store_ah_into_flag             = (i_instruction[0][7:0] == 8'b1001_1110);
assign o_opcode_x86_STC_set_carry_flag                  = (i_instruction[0][7:0] == 8'b1111_1001);
assign o_opcode_x86_STD_set_direction_flag              = (i_instruction[0][7:0] == 8'b1111_1101);
assign o_opcode_x86_STI_set_interrupt_enable_flag       = (i_instruction[0][7:0] == 8'b1111_1011);
assign o_opcode_x86_ADD_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0000_000 );
assign o_opcode_x86_ADD_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0000_001 );
assign o_opcode_x86_ADD_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_x86_ADD_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0000_010 );
assign o_opcode_x86_ADC_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0001_000 );
assign o_opcode_x86_ADC_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0001_001 );
assign o_opcode_x86_ADC_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_x86_ADC_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0001_010 );
assign o_opcode_x86_INC_reg_mem                         = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_x86_INC_reg                             = (i_instruction[0][7:3] == 5'b0100_0   );
assign o_opcode_x86_SUB_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0010_100 );
assign o_opcode_x86_SUB_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0010_101 );
assign o_opcode_x86_SUB_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_x86_SUB_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0010_110 );
assign o_opcode_x86_SBB_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0001_100 );
assign o_opcode_x86_SBB_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0001_101 );
assign o_opcode_x86_SBB_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b011);
assign o_opcode_x86_SBB_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0001_110 );
assign o_opcode_x86_DEC_reg_mem                         = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b001);
assign o_opcode_x86_DEC_reg                             = (i_instruction[0][7:3] == 5'b0100_1   );
assign o_opcode_x86_CMP_mem_with_reg                    = (i_instruction[0][7:1] == 7'b0011_100 );
assign o_opcode_x86_CMP_reg_with_mem                    = (i_instruction[0][7:1] == 7'b0011_101 );
assign o_opcode_x86_CMP_imm_with_reg_mem                = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b111);
assign o_opcode_x86_CMP_imm_with_acc                    = (i_instruction[0][7:1] == 7'b0011_110 );
assign o_opcode_x86_NEG_change_sign                     = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b011);
assign o_opcode_x86_AAA                                 = (i_instruction[0][7:0] == 8'b0011_0111);
assign o_opcode_x86_AAS                                 = (i_instruction[0][7:0] == 8'b0011_1111);
assign o_opcode_x86_DAA                                 = (i_instruction[0][7:0] == 8'b0010_0111);
assign o_opcode_x86_DAS                                 = (i_instruction[0][7:0] == 8'b0010_1111);
assign o_opcode_x86_MUL_acc_with_reg_mem                = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_x86_IMUL_acc_with_reg_mem               = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_x86_IMUL_reg_with_reg_mem               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1111);
assign o_opcode_x86_IMUL_reg_mem_with_imm_to_reg        = (i_instruction[0][7:2] == 6'b0110_10  ) & (i_instruction[0][0] == 1'b1);
assign o_opcode_x86_DIV_acc_by_reg_mem                  = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b110);
assign o_opcode_x86_IDIV_acc_by_reg_mem                 = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b111);
assign o_opcode_x86_AAD                                 = (i_instruction[0][7:0] == 8'b1101_0101) & (i_instruction[1][7:0] == 8'b0000_1010);
assign o_opcode_x86_AAM                                 = (i_instruction[0][7:0] == 8'b1101_0100) & (i_instruction[1][7:0] == 8'b0000_1010);
assign o_opcode_x86_CBW                                 = (i_instruction[0][7:0] == 8'b1001_1000);
assign o_opcode_x86_CWD                                 = (i_instruction[0][7:0] == 8'b1001_1001);
assign o_opcode_x86_ROL_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_x86_ROL_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_x86_ROL_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_x86_ROR_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b001);
assign o_opcode_x86_ROR_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b001);
assign o_opcode_x86_ROR_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b001);
assign o_opcode_x86_SHL_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_x86_SHL_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_x86_SHL_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_x86_SAR_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b111);
assign o_opcode_x86_SAR_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b111);
assign o_opcode_x86_SAR_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b111);
assign o_opcode_x86_SHR_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_x86_SHR_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_x86_SHR_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_x86_RCL_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_x86_RCL_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_x86_RCL_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_x86_RCR_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b011);
assign o_opcode_x86_RCR_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b011);
assign o_opcode_x86_RCR_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b011);
assign o_opcode_x86_SHLD_reg_mem_by_imm                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_0100);
assign o_opcode_x86_SHLD_reg_mem_by_CL                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_0101);
assign o_opcode_x86_SHRD_reg_mem_by_imm                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1100);
assign o_opcode_x86_SHRD_reg_mem_by_CL                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1101);
assign o_opcode_x86_AND_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0010_000 );
assign o_opcode_x86_AND_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0010_001 );
assign o_opcode_x86_AND_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_x86_AND_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0010_010 );
assign o_opcode_x86_TEST_reg_mem_and_reg                = (i_instruction[0][7:1] == 7'b1000_010 );
assign o_opcode_x86_TEST_imm_to_reg_mem                 = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_x86_TEST_imm_to_acc                     = (i_instruction[0][7:1] == 7'b1010_100 );
assign o_opcode_x86_OR_reg_to_mem                       = (i_instruction[0][7:1] == 7'b0000_100 );
assign o_opcode_x86_OR_mem_to_reg                       = (i_instruction[0][7:1] == 7'b0000_101 );
assign o_opcode_x86_OR_imm_to_reg_mem                   = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b001);
assign o_opcode_x86_OR_imm_to_acc                       = (i_instruction[0][7:1] == 7'b0000_110 );
assign o_opcode_x86_XOR_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0011_000 );
assign o_opcode_x86_XOR_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0011_001 );
assign o_opcode_x86_XOR_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b110);
assign o_opcode_x86_XOR_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0011_010 );
assign o_opcode_x86_NOT                                 = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_x86_CMPS                                = (i_instruction[0][7:1] == 7'b1010_011 );
assign o_opcode_x86_INS                                 = (i_instruction[0][7:1] == 7'b0110_110 );
assign o_opcode_x86_LODS                                = (i_instruction[0][7:1] == 7'b1010_110 );
assign o_opcode_x86_MOVS                                = (i_instruction[0][7:1] == 7'b1010_010 );
assign o_opcode_x86_OUTS                                = (i_instruction[0][7:1] == 7'b0110_111 );
assign o_opcode_x86_SCAS                                = (i_instruction[0][7:1] == 7'b1010_111 );
assign o_opcode_x86_STOS                                = (i_instruction[0][7:1] == 7'b1010_101 );
assign o_opcode_x86_XLAT                                = (i_instruction[0][7:0] == 8'b1101_0111);
assign o_opcode_x86_REPE                                = (i_instruction[0][7:0] == 8'b1111_0011);
assign o_opcode_x86_REPNE                               = (i_instruction[0][7:0] == 8'b1111_0010);
assign o_opcode_x86_BSF                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1100);
assign o_opcode_x86_BSR                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1101);
assign o_opcode_x86_BT_reg_mem_with_imm                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b100);
assign o_opcode_x86_BT_reg_mem_with_reg                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_0011);
assign o_opcode_x86_BTC_reg_mem_with_imm                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b111);
assign o_opcode_x86_BTC_reg_mem_with_reg                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1011);
assign o_opcode_x86_BTR_reg_mem_with_imm                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b110);
assign o_opcode_x86_BTR_reg_mem_with_reg                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0011);
assign o_opcode_x86_BTS_reg_mem_with_imm                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b101);
assign o_opcode_x86_BTS_reg_mem_with_reg                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1011);
assign o_opcode_x86_CALL_direct_within_segment          = (i_instruction[0][7:0] == 8'b1110_1000);
assign o_opcode_x86_CALL_indirect_within_segment        = (i_instruction[0][7:1] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_x86_CALL_direct_intersegment            = (i_instruction[0][7:0] == 8'b1001_1010);
assign o_opcode_x86_CALL_indirect_intersegment          = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b011);
assign o_opcode_x86_JMP_short                           = (i_instruction[0][7:0] == 8'b1110_1011);
assign o_opcode_x86_JMP_direct_within_segment           = (i_instruction[0][7:0] == 8'b1110_1001);
assign o_opcode_x86_JMP_indirect_within_segment         = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_x86_JMP_direct_intersegment             = (i_instruction[0][7:0] == 8'b1110_1010);
assign o_opcode_x86_JMP_indirect_intersegment           = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_x86_RET_within_segment                  = (i_instruction[0][7:0] == 8'b1100_0011);
assign o_opcode_x86_RET_within_segment_adding_imm_to_SP = (i_instruction[0][7:0] == 8'b1100_0010);
assign o_opcode_x86_RET_intersegment                    = (i_instruction[0][7:0] == 8'b1100_1011);
assign o_opcode_x86_RET_intersegment_adding_imm_to_SP   = (i_instruction[0][7:0] == 8'b1100_1010);
assign o_opcode_x86_JO_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_0000);
assign o_opcode_x86_JO_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0000);
assign o_opcode_x86_JNO_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_0001);
assign o_opcode_x86_JNO_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0001);
assign o_opcode_x86_JB_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_0010);
assign o_opcode_x86_JB_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0010);
assign o_opcode_x86_JNB_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_0011);
assign o_opcode_x86_JNB_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0011);
assign o_opcode_x86_JE_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_0100);
assign o_opcode_x86_JE_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0100);
assign o_opcode_x86_JNE_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_0101);
assign o_opcode_x86_JNE_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0101);
assign o_opcode_x86_JBE_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_0110);
assign o_opcode_x86_JBE_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0110);
assign o_opcode_x86_JNBE_8bit_disp                      = (i_instruction[0][7:0] == 8'b0111_0111);
assign o_opcode_x86_JNBE_full_disp                      = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0111);
assign o_opcode_x86_JS_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_1000);
assign o_opcode_x86_JS_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1000);
assign o_opcode_x86_JNS_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_1001);
assign o_opcode_x86_JNS_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1001);
assign o_opcode_x86_JP_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_1010);
assign o_opcode_x86_JP_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1010);
assign o_opcode_x86_JNP_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_1011);
assign o_opcode_x86_JNP_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1011);
assign o_opcode_x86_JL_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_1100);
assign o_opcode_x86_JL_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1100);
assign o_opcode_x86_JNL_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_1101);
assign o_opcode_x86_JNL_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1101);
assign o_opcode_x86_JLE_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_1110);
assign o_opcode_x86_JLE_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1110);
assign o_opcode_x86_JNLE_8bit_disp                      = (i_instruction[0][7:0] == 8'b0111_1111);
assign o_opcode_x86_JNLE_full_disp                      = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1111);
assign o_opcode_x86_JCXZ                                = (i_instruction[0][7:0] == 8'b1110_0011); // (JCXZ and JECXZ: Address Size Prefix Differentiates JCXZ from JECXZ)
assign o_opcode_x86_LOOP                                = (i_instruction[0][7:0] == 8'b1110_0010);
assign o_opcode_x86_LOOPZ                               = (i_instruction[0][7:0] == 8'b1110_0001);
assign o_opcode_x86_LOOPNZ                              = (i_instruction[0][7:0] == 8'b1110_0000);
assign o_opcode_x86_SETO                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0000);
assign o_opcode_x86_SETNO                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0001);
assign o_opcode_x86_SETB                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0010);
assign o_opcode_x86_SETNB                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0011);
assign o_opcode_x86_SETE                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0100);
assign o_opcode_x86_SETNE                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0101);
assign o_opcode_x86_SETBE                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0110);
assign o_opcode_x86_SETNBE                              = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0111);
assign o_opcode_x86_SETS                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1000);
assign o_opcode_x86_SETNS                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1001);
assign o_opcode_x86_SETP                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1010);
assign o_opcode_x86_SETNP                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1011);
assign o_opcode_x86_SETL                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1100);
assign o_opcode_x86_SETNL                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1101);
assign o_opcode_x86_SETLE                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1110);
assign o_opcode_x86_SETNLE                              = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1111);
assign o_opcode_x86_ENTER                               = (i_instruction[0][7:0] == 8'b1100_1000);
assign o_opcode_x86_LEAVE                               = (i_instruction[0][7:0] == 8'b1100_1001);
assign o_opcode_x86_INT_type_3                          = (i_instruction[0][7:0] == 8'b1100_1100);
assign o_opcode_x86_INT_type_specified                  = (i_instruction[0][7:0] == 8'b1100_1101);
assign o_opcode_x86_INTO                                = (i_instruction[0][7:0] == 8'b1100_1110);
assign o_opcode_x86_BOUND                               = (i_instruction[0][7:0] == 8'b0110_0010);
assign o_opcode_x86_IRET                                = (i_instruction[0][7:0] == 8'b1100_1111);
assign o_opcode_x86_HLT                                 = (i_instruction[0][7:0] == 8'b1111_0100);
assign o_opcode_x86_MOV_CR0_CR2_CR3_from_reg            = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0010) & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_x86_MOV_reg_from_CR0_3                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0000) & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_x86_MOV_DR0_7_from_reg                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0011) & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_x86_MOV_reg_from_DR0_7                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0001) & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_x86_MOV_TR6_7_from_reg                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0110) & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_x86_MOV_reg_from_TR6_7                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0100) & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_x86_NOP                                 = (i_instruction[0][7:0] == 8'b1001_0000);
assign o_opcode_x86_WAIT                                = (i_instruction[0][7:0] == 8'b1001_1011);
assign o_opcode_x86_processor_extension_escape          = (i_instruction[0][7:3] == 5'b1101_1   );
assign o_opcode_x86_ARPL                                = (i_instruction[0][7:0] == 8'b0110_0011);
assign o_opcode_x86_LAR                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0010);
assign o_opcode_x86_LGDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b010);
assign o_opcode_x86_LIDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b011);
assign o_opcode_x86_LLDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b010);
assign o_opcode_x86_LMSW                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b110);
assign o_opcode_x86_LSL                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0011);
assign o_opcode_x86_LTR                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b011);
assign o_opcode_x86_SGDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b000);
assign o_opcode_x86_SIDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b001);
assign o_opcode_x86_SLDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b000);
assign o_opcode_x86_SMSW                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b100);
assign o_opcode_x86_STR                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b001);
assign o_opcode_x86_VERR                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b100);
assign o_opcode_x86_VERW                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b101);

endmodule
