/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_stage_0_opcode
create at: 2021-12-28 16:56:15
description: decode opcode from i_instruction
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_stage_opcode (
    input  logic  [ 7:0] i_instruction [0:2],
    output logic         o_opcode_MOV_reg_to_reg_mem,
    output logic         o_opcode_MOV_reg_mem_to_reg,
    output logic         o_opcode_MOV_imm_to_reg_mem,
    output logic         o_opcode_MOV_imm_to_reg_short,
    output logic         o_opcode_MOV_mem_to_acc,
    output logic         o_opcode_MOV_acc_to_mem,
    output logic         o_opcode_MOV_reg_mem_to_sreg,
    output logic         o_opcode_MOV_sreg_to_reg_mem,
    output logic         o_opcode_MOVSX,
    output logic         o_opcode_MOVZX,
    output logic         o_opcode_PUSH_reg_mem,
    output logic         o_opcode_PUSH_reg_short,
    output logic         o_opcode_PUSH_sreg_2,
    output logic         o_opcode_PUSH_sreg_3,
    output logic         o_opcode_PUSH_imm,
    output logic         o_opcode_PUSH_all,
    output logic         o_opcode_POP_reg_mem,
    output logic         o_opcode_POP_reg_short,
    output logic         o_opcode_POP_sreg_2,
    output logic         o_opcode_POP_sreg_3,
    output logic         o_opcode_POP_all,
    output logic         o_opcode_XCHG_reg_mem_with_reg,
    output logic         o_opcode_XCHG_reg_with_acc_short,
    output logic         o_opcode_IN_port_fixed,
    output logic         o_opcode_IN_port_variable,
    output logic         o_opcode_OUT_port_fixed,
    output logic         o_opcode_OUT_port_variable,
    output logic         o_opcode_LEA_load_ea_to_reg,
    output logic         o_opcode_LDS_load_ptr_to_DS,
    output logic         o_opcode_LES_load_ptr_to_ES,
    output logic         o_opcode_LFS_load_ptr_to_FS,
    output logic         o_opcode_LGS_load_ptr_to_GS,
    output logic         o_opcode_LSS_load_ptr_to_SS,
    output logic         o_opcode_CLC_clear_carry_flag,
    output logic         o_opcode_CLD_clear_direction_flag,
    output logic         o_opcode_CLI_clear_interrupt_enable_flag,
    output logic         o_opcode_CLTS_clear_task_switched_flag,
    output logic         o_opcode_CMC_complement_carry_flag,
    output logic         o_opcode_LAHF_load_ah_into_flag,
    output logic         o_opcode_POPF_pop_flags,
    output logic         o_opcode_PUSHF_push_flags,
    output logic         o_opcode_SAHF_store_ah_into_flag,
    output logic         o_opcode_STC_set_carry_flag,
    output logic         o_opcode_STD_set_direction_flag,
    output logic         o_opcode_STI_set_interrupt_enable_flag,
    output logic         o_opcode_ADD_reg_to_mem,
    output logic         o_opcode_ADD_mem_to_reg,
    output logic         o_opcode_ADD_imm_to_reg_mem,
    output logic         o_opcode_ADD_imm_to_acc,
    output logic         o_opcode_ADC_reg_to_mem,
    output logic         o_opcode_ADC_mem_to_reg,
    output logic         o_opcode_ADC_imm_to_reg_mem,
    output logic         o_opcode_ADC_imm_to_acc,
    output logic         o_opcode_INC_reg_mem,
    output logic         o_opcode_INC_reg,
    output logic         o_opcode_SUB_reg_to_mem,
    output logic         o_opcode_SUB_mem_to_reg,
    output logic         o_opcode_SUB_imm_to_reg_mem,
    output logic         o_opcode_SUB_imm_to_acc,
    output logic         o_opcode_SBB_reg_to_mem,
    output logic         o_opcode_SBB_mem_to_reg,
    output logic         o_opcode_SBB_imm_to_reg_mem,
    output logic         o_opcode_SBB_imm_to_acc,
    output logic         o_opcode_DEC_reg_mem,
    output logic         o_opcode_DEC_reg,
    output logic         o_opcode_CMP_mem_with_reg,
    output logic         o_opcode_CMP_reg_with_mem,
    output logic         o_opcode_CMP_imm_with_reg_mem,
    output logic         o_opcode_CMP_imm_with_acc,
    output logic         o_opcode_NEG_change_sign,
    output logic         o_opcode_AAA,
    output logic         o_opcode_AAS,
    output logic         o_opcode_DAA,
    output logic         o_opcode_DAS,
    output logic         o_opcode_MUL_acc_with_reg_mem,
    output logic         o_opcode_IMUL_acc_with_reg_mem,
    output logic         o_opcode_IMUL_reg_with_reg_mem,
    output logic         o_opcode_IMUL_reg_mem_with_imm_to_reg,
    output logic         o_opcode_DIV_acc_by_reg_mem,
    output logic         o_opcode_IDIV_acc_by_reg_mem,
    output logic         o_opcode_AAD,
    output logic         o_opcode_AAM,
    output logic         o_opcode_CBW,
    output logic         o_opcode_CWD,
    output logic         o_opcode_ROL_reg_mem_by_1,
    output logic         o_opcode_ROL_reg_mem_by_CL,
    output logic         o_opcode_ROL_reg_mem_by_imm,
    output logic         o_opcode_ROR_reg_mem_by_1,
    output logic         o_opcode_ROR_reg_mem_by_CL,
    output logic         o_opcode_ROR_reg_mem_by_imm,
    output logic         o_opcode_SHL_reg_mem_by_1,
    output logic         o_opcode_SHL_reg_mem_by_CL,
    output logic         o_opcode_SHL_reg_mem_by_imm,
    output logic         o_opcode_SAR_reg_mem_by_1,
    output logic         o_opcode_SAR_reg_mem_by_CL,
    output logic         o_opcode_SAR_reg_mem_by_imm,
    output logic         o_opcode_SHR_reg_mem_by_1,
    output logic         o_opcode_SHR_reg_mem_by_CL,
    output logic         o_opcode_SHR_reg_mem_by_imm,
    output logic         o_opcode_RCL_reg_mem_by_1,
    output logic         o_opcode_RCL_reg_mem_by_CL,
    output logic         o_opcode_RCL_reg_mem_by_imm,
    output logic         o_opcode_RCR_reg_mem_by_1,
    output logic         o_opcode_RCR_reg_mem_by_CL,
    output logic         o_opcode_RCR_reg_mem_by_imm,
    output logic         o_opcode_SHLD_reg_mem_by_imm,
    output logic         o_opcode_SHLD_reg_mem_by_CL,
    output logic         o_opcode_SHRD_reg_mem_by_imm,
    output logic         o_opcode_SHRD_reg_mem_by_CL,
    output logic         o_opcode_AND_reg_to_mem,
    output logic         o_opcode_AND_mem_to_reg,
    output logic         o_opcode_AND_imm_to_reg_mem,
    output logic         o_opcode_AND_imm_to_acc,
    output logic         o_opcode_TEST_reg_mem_and_reg,
    output logic         o_opcode_TEST_imm_to_reg_mem,
    output logic         o_opcode_TEST_imm_to_acc,
    output logic         o_opcode_OR_reg_to_mem,
    output logic         o_opcode_OR_mem_to_reg,
    output logic         o_opcode_OR_imm_to_reg_mem,
    output logic         o_opcode_OR_imm_to_acc,
    output logic         o_opcode_XOR_reg_to_mem,
    output logic         o_opcode_XOR_mem_to_reg,
    output logic         o_opcode_XOR_imm_to_reg_mem,
    output logic         o_opcode_XOR_imm_to_acc,
    output logic         o_opcode_NOT,
    output logic         o_opcode_CMPS,
    output logic         o_opcode_INS,
    output logic         o_opcode_LODS,
    output logic         o_opcode_MOVS,
    output logic         o_opcode_OUTS,
    output logic         o_opcode_SCAS,
    output logic         o_opcode_STOS,
    output logic         o_opcode_XLAT,
    output logic         o_opcode_REPE,
    output logic         o_opcode_REPNE,
    output logic         o_opcode_BSF,
    output logic         o_opcode_BSR,
    output logic         o_opcode_BT_reg_mem_with_imm,
    output logic         o_opcode_BT_reg_mem_with_reg,
    output logic         o_opcode_BTC_reg_mem_with_imm,
    output logic         o_opcode_BTC_reg_mem_with_reg,
    output logic         o_opcode_BTR_reg_mem_with_imm,
    output logic         o_opcode_BTR_reg_mem_with_reg,
    output logic         o_opcode_BTS_reg_mem_with_imm,
    output logic         o_opcode_BTS_reg_mem_with_reg,
    output logic         o_opcode_CALL_direct_within_segment,
    output logic         o_opcode_CALL_indirect_within_segment,
    output logic         o_opcode_CALL_direct_intersegment,
    output logic         o_opcode_CALL_indirect_intersegment,
    output logic         o_opcode_JMP_short,
    output logic         o_opcode_JMP_direct_within_segment,
    output logic         o_opcode_JMP_indirect_within_segment,
    output logic         o_opcode_JMP_direct_intersegment,
    output logic         o_opcode_JMP_indirect_intersegment,
    output logic         o_opcode_RET_within_segment,
    output logic         o_opcode_RET_within_segment_adding_imm_to_SP,
    output logic         o_opcode_RET_intersegment,
    output logic         o_opcode_RET_intersegment_adding_imm_to_SP,
    output logic         o_opcode_JO_8bit_disp,
    output logic         o_opcode_JO_full_disp,
    output logic         o_opcode_JNO_8bit_disp,
    output logic         o_opcode_JNO_full_disp,
    output logic         o_opcode_JB_8bit_disp,
    output logic         o_opcode_JB_full_disp,
    output logic         o_opcode_JNB_8bit_disp,
    output logic         o_opcode_JNB_full_disp,
    output logic         o_opcode_JE_8bit_disp,
    output logic         o_opcode_JE_full_disp,
    output logic         o_opcode_JNE_8bit_disp,
    output logic         o_opcode_JNE_full_disp,
    output logic         o_opcode_JBE_8bit_disp,
    output logic         o_opcode_JBE_full_disp,
    output logic         o_opcode_JNBE_8bit_disp,
    output logic         o_opcode_JNBE_full_disp,
    output logic         o_opcode_JS_8bit_disp,
    output logic         o_opcode_JS_full_disp,
    output logic         o_opcode_JNS_8bit_disp,
    output logic         o_opcode_JNS_full_disp,
    output logic         o_opcode_JP_8bit_disp,
    output logic         o_opcode_JP_full_disp,
    output logic         o_opcode_JNP_8bit_disp,
    output logic         o_opcode_JNP_full_disp,
    output logic         o_opcode_JL_8bit_disp,
    output logic         o_opcode_JL_full_disp,
    output logic         o_opcode_JNL_8bit_disp,
    output logic         o_opcode_JNL_full_disp,
    output logic         o_opcode_JLE_8bit_disp,
    output logic         o_opcode_JLE_full_disp,
    output logic         o_opcode_JNLE_8bit_disp,
    output logic         o_opcode_JNLE_full_disp,
    output logic         o_opcode_JCXZ,
    output logic         o_opcode_LOOP,
    output logic         o_opcode_LOOPZ,
    output logic         o_opcode_LOOPNZ,
    output logic         o_opcode_SETO,
    output logic         o_opcode_SETNO,
    output logic         o_opcode_SETB,
    output logic         o_opcode_SETNB,
    output logic         o_opcode_SETE,
    output logic         o_opcode_SETNE,
    output logic         o_opcode_SETBE,
    output logic         o_opcode_SETNBE,
    output logic         o_opcode_SETS,
    output logic         o_opcode_SETNS,
    output logic         o_opcode_SETP,
    output logic         o_opcode_SETNP,
    output logic         o_opcode_SETL,
    output logic         o_opcode_SETNL,
    output logic         o_opcode_SETLE,
    output logic         o_opcode_SETNLE,
    output logic         o_opcode_ENTER,
    output logic         o_opcode_LEAVE,
    output logic         o_opcode_INT_type_3,
    output logic         o_opcode_INT_type_specified,
    output logic         o_opcode_INTO,
    output logic         o_opcode_BOUND,
    output logic         o_opcode_IRET,
    output logic         o_opcode_HLT,
    output logic         o_opcode_MOV_CR0_CR2_CR3_from_reg,
    output logic         o_opcode_MOV_reg_from_CR0_3,
    output logic         o_opcode_MOV_DR0_7_from_reg,
    output logic         o_opcode_MOV_reg_from_DR0_7,
    output logic         o_opcode_MOV_TR6_7_from_reg,
    output logic         o_opcode_MOV_reg_from_TR6_7,
    output logic         o_opcode_NOP,
    output logic         o_opcode_WAIT,
    output logic         o_opcode_processor_extension_escape,
    output logic         o_opcode_ARPL,
    output logic         o_opcode_LAR,
    output logic         o_opcode_LGDT,
    output logic         o_opcode_LIDT,
    output logic         o_opcode_LLDT,
    output logic         o_opcode_LMSW,
    output logic         o_opcode_LSL,
    output logic         o_opcode_LTR,
    output logic         o_opcode_SGDT,
    output logic         o_opcode_SIDT,
    output logic         o_opcode_SLDT,
    output logic         o_opcode_SMSW,
    output logic         o_opcode_STR,
    output logic         o_opcode_VERR,
    output logic         o_opcode_VERW
);

assign o_opcode_MOV_reg_to_reg_mem                  = (i_instruction[0][7:1] == 7'b1000_100 );
assign o_opcode_MOV_reg_mem_to_reg                  = (i_instruction[0][7:1] == 7'b1000_101 );
assign o_opcode_MOV_imm_to_reg_mem                  = (i_instruction[0][7:1] == 7'b1100_011 ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_MOV_imm_to_reg_short                = (i_instruction[0][7:4] == 4'b1011     );
assign o_opcode_MOV_mem_to_acc                      = (i_instruction[0][7:1] == 7'b1010_000 );
assign o_opcode_MOV_acc_to_mem                      = (i_instruction[0][7:1] == 7'b1010_001 );
assign o_opcode_MOV_reg_mem_to_sreg                 = (i_instruction[0][7:0] == 8'b1000_1110);
assign o_opcode_MOV_sreg_to_reg_mem                 = (i_instruction[0][7:0] == 8'b1000_1100);
assign o_opcode_MOVSX                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:1] == 7'b1011_111);
assign o_opcode_MOVZX                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:1] == 7'b1011_011);
assign o_opcode_PUSH_reg_mem                        = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b110);
assign o_opcode_PUSH_reg_short                      = (i_instruction[0][7:3] == 5'b0101_0   );
assign o_opcode_PUSH_sreg_2                         = (i_instruction[0][7:5] == 3'b000      ) & (i_instruction[0][2:0] == 3'b110);
assign o_opcode_PUSH_sreg_3                         = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:6] == 2'b10) & (i_instruction[1][5] == 1'b1) & (i_instruction[1][2:0] == 3'b000);
assign o_opcode_PUSH_imm                            = (i_instruction[0][7:2] == 6'b0110_10  ) & (i_instruction[0][0] == 1'b0);
assign o_opcode_PUSH_all                            = (i_instruction[0][7:0] == 8'b0110_0000);
assign o_opcode_POP_reg_mem                         = (i_instruction[0][7:0] == 8'b1000_1111) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_POP_reg_short                       = (i_instruction[0][7:3] == 5'b0101_1   );
assign o_opcode_POP_sreg_2                          = (i_instruction[0][7:5] == 3'b000      ) & (i_instruction[0][4:3] != 2'b01) & (i_instruction[0][2:0] == 3'b111) & (i_instruction[1][5:3] != 3'b110) & (i_instruction[1][5:3] != 3'b111);
assign o_opcode_POP_sreg_3                          = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:6] == 2'b10) & (i_instruction[1][5] == 1'b1) & (i_instruction[1][2:0] == 3'b001);
assign o_opcode_POP_all                             = (i_instruction[0][7:0] == 8'b0110_0001);
assign o_opcode_XCHG_reg_mem_with_reg               = (i_instruction[0][7:1] == 7'b1000_011 );
assign o_opcode_XCHG_reg_with_acc_short             = (i_instruction[0][7:3] == 5'b1001_0   ) & (i_instruction[0][2:0] != 3'b000);
assign o_opcode_IN_port_fixed                       = (i_instruction[0][7:1] == 7'b1110_010 );
assign o_opcode_IN_port_variable                    = (i_instruction[0][7:1] == 7'b1110_110 );
assign o_opcode_OUT_port_fixed                      = (i_instruction[0][7:1] == 7'b1110_011 );
assign o_opcode_OUT_port_variable                   = (i_instruction[0][7:1] == 7'b1110_111 );
assign o_opcode_LEA_load_ea_to_reg                  = (i_instruction[0][7:0] == 8'b1000_1101);
assign o_opcode_LDS_load_ptr_to_DS                  = (i_instruction[0][7:0] == 8'b1100_0101);
assign o_opcode_LES_load_ptr_to_ES                  = (i_instruction[0][7:0] == 8'b1100_0100);
assign o_opcode_LFS_load_ptr_to_FS                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0100);
assign o_opcode_LGS_load_ptr_to_GS                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0101);
assign o_opcode_LSS_load_ptr_to_SS                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0010);
assign o_opcode_CLC_clear_carry_flag                = (i_instruction[0][7:0] == 8'b1111_1000);
assign o_opcode_CLD_clear_direction_flag            = (i_instruction[0][7:0] == 8'b1111_1100);
assign o_opcode_CLI_clear_interrupt_enable_flag     = (i_instruction[0][7:0] == 8'b1111_1010);
assign o_opcode_CLTS_clear_task_switched_flag       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0110);
assign o_opcode_CMC_complement_carry_flag           = (i_instruction[0][7:0] == 8'b1111_0101);
assign o_opcode_LAHF_load_ah_into_flag              = (i_instruction[0][7:0] == 8'b1001_1111);
assign o_opcode_POPF_pop_flags                      = (i_instruction[0][7:0] == 8'b1001_1101);
assign o_opcode_PUSHF_push_flags                    = (i_instruction[0][7:0] == 8'b1001_1100);
assign o_opcode_SAHF_store_ah_into_flag             = (i_instruction[0][7:0] == 8'b1001_1110);
assign o_opcode_STC_set_carry_flag                  = (i_instruction[0][7:0] == 8'b1111_1001);
assign o_opcode_STD_set_direction_flag              = (i_instruction[0][7:0] == 8'b1111_1101);
assign o_opcode_STI_set_interrupt_enable_flag       = (i_instruction[0][7:0] == 8'b1111_1011);
assign o_opcode_ADD_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0000_000 );
assign o_opcode_ADD_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0000_001 );
assign o_opcode_ADD_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_ADD_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0000_010 );
assign o_opcode_ADC_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0001_000 );
assign o_opcode_ADC_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0001_001 );
assign o_opcode_ADC_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_ADC_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0001_010 );
assign o_opcode_INC_reg_mem                         = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_INC_reg                             = (i_instruction[0][7:3] == 5'b0100_0   );
assign o_opcode_SUB_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0010_100 );
assign o_opcode_SUB_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0010_101 );
assign o_opcode_SUB_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_SUB_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0010_110 );
assign o_opcode_SBB_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0001_100 );
assign o_opcode_SBB_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0001_101 );
assign o_opcode_SBB_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b011);
assign o_opcode_SBB_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0001_110 );
assign o_opcode_DEC_reg_mem                         = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b001);
assign o_opcode_DEC_reg                             = (i_instruction[0][7:3] == 5'b0100_1   );
assign o_opcode_CMP_mem_with_reg                    = (i_instruction[0][7:1] == 7'b0011_100 );
assign o_opcode_CMP_reg_with_mem                    = (i_instruction[0][7:1] == 7'b0011_101 );
assign o_opcode_CMP_imm_with_reg_mem                = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b111);
assign o_opcode_CMP_imm_with_acc                    = (i_instruction[0][7:1] == 7'b0011_110 );
assign o_opcode_NEG_change_sign                     = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b011);
assign o_opcode_AAA                                 = (i_instruction[0][7:0] == 8'b0011_0111);
assign o_opcode_AAS                                 = (i_instruction[0][7:0] == 8'b0011_1111);
assign o_opcode_DAA                                 = (i_instruction[0][7:0] == 8'b0010_0111);
assign o_opcode_DAS                                 = (i_instruction[0][7:0] == 8'b0010_1111);
assign o_opcode_MUL_acc_with_reg_mem                = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_IMUL_acc_with_reg_mem               = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_IMUL_reg_with_reg_mem               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1111);
assign o_opcode_IMUL_reg_mem_with_imm_to_reg        = (i_instruction[0][7:2] == 6'b0110_10  ) & (i_instruction[0][0] == 1'b1);
assign o_opcode_DIV_acc_by_reg_mem                  = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b110);
assign o_opcode_IDIV_acc_by_reg_mem                 = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b111);
assign o_opcode_AAD                                 = (i_instruction[0][7:0] == 8'b1101_0101) & (i_instruction[1][7:0] == 8'b0000_1010);
assign o_opcode_AAM                                 = (i_instruction[0][7:0] == 8'b1101_0100) & (i_instruction[1][7:0] == 8'b0000_1010);
assign o_opcode_CBW                                 = (i_instruction[0][7:0] == 8'b1001_1000);
assign o_opcode_CWD                                 = (i_instruction[0][7:0] == 8'b1001_1001);
assign o_opcode_ROL_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_ROL_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_ROL_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_ROR_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b001);
assign o_opcode_ROR_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b001);
assign o_opcode_ROR_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b001);
assign o_opcode_SHL_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_SHL_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_SHL_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_SAR_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b111);
assign o_opcode_SAR_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b111);
assign o_opcode_SAR_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b111);
assign o_opcode_SHR_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_SHR_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_SHR_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_RCL_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_RCL_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_RCL_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_RCR_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b011);
assign o_opcode_RCR_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b011);
assign o_opcode_RCR_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b011);
assign o_opcode_SHLD_reg_mem_by_imm                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_0100);
assign o_opcode_SHLD_reg_mem_by_CL                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_0101);
assign o_opcode_SHRD_reg_mem_by_imm                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1100);
assign o_opcode_SHRD_reg_mem_by_CL                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1101);
assign o_opcode_AND_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0010_000 );
assign o_opcode_AND_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0010_001 );
assign o_opcode_AND_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_AND_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0010_010 );
assign o_opcode_TEST_reg_mem_and_reg                = (i_instruction[0][7:1] == 7'b1000_010 );
assign o_opcode_TEST_imm_to_reg_mem                 = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_TEST_imm_to_acc                     = (i_instruction[0][7:1] == 7'b1010_100 );
assign o_opcode_OR_reg_to_mem                       = (i_instruction[0][7:1] == 7'b0000_100 );
assign o_opcode_OR_mem_to_reg                       = (i_instruction[0][7:1] == 7'b0000_101 );
assign o_opcode_OR_imm_to_reg_mem                   = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b001);
assign o_opcode_OR_imm_to_acc                       = (i_instruction[0][7:1] == 7'b0000_110 );
assign o_opcode_XOR_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0011_000 );
assign o_opcode_XOR_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0011_001 );
assign o_opcode_XOR_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b110);
assign o_opcode_XOR_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0011_010 );
assign o_opcode_NOT                                 = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_CMPS                                = (i_instruction[0][7:1] == 7'b1010_011 );
assign o_opcode_INS                                 = (i_instruction[0][7:1] == 7'b0110_110 );
assign o_opcode_LODS                                = (i_instruction[0][7:1] == 7'b1010_110 );
assign o_opcode_MOVS                                = (i_instruction[0][7:1] == 7'b1010_010 );
assign o_opcode_OUTS                                = (i_instruction[0][7:1] == 7'b0110_111 );
assign o_opcode_SCAS                                = (i_instruction[0][7:1] == 7'b1010_111 );
assign o_opcode_STOS                                = (i_instruction[0][7:1] == 7'b1010_101 );
assign o_opcode_XLAT                                = (i_instruction[0][7:0] == 8'b1101_0111);
assign o_opcode_REPE                                = (i_instruction[0][7:0] == 8'b1111_0011);
assign o_opcode_REPNE                               = (i_instruction[0][7:0] == 8'b1111_0010);
assign o_opcode_BSF                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1100);
assign o_opcode_BSR                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1101);
assign o_opcode_BT_reg_mem_with_imm                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b100);
assign o_opcode_BT_reg_mem_with_reg                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_0011);
assign o_opcode_BTC_reg_mem_with_imm                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b111);
assign o_opcode_BTC_reg_mem_with_reg                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1011);
assign o_opcode_BTR_reg_mem_with_imm                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b110);
assign o_opcode_BTR_reg_mem_with_reg                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0011);
assign o_opcode_BTS_reg_mem_with_imm                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b101);
assign o_opcode_BTS_reg_mem_with_reg                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1011);
assign o_opcode_CALL_direct_within_segment          = (i_instruction[0][7:0] == 8'b1110_1000);
assign o_opcode_CALL_indirect_within_segment        = (i_instruction[0][7:1] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_CALL_direct_intersegment            = (i_instruction[0][7:0] == 8'b1001_1010);
assign o_opcode_CALL_indirect_intersegment          = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b011);
assign o_opcode_JMP_short                           = (i_instruction[0][7:0] == 8'b1110_1011);
assign o_opcode_JMP_direct_within_segment           = (i_instruction[0][7:0] == 8'b1110_1001);
assign o_opcode_JMP_indirect_within_segment         = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_JMP_direct_intersegment             = (i_instruction[0][7:0] == 8'b1110_1010);
assign o_opcode_JMP_indirect_intersegment           = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_RET_within_segment                  = (i_instruction[0][7:0] == 8'b1100_0011);
assign o_opcode_RET_within_segment_adding_imm_to_SP = (i_instruction[0][7:0] == 8'b1100_0010);
assign o_opcode_RET_intersegment                    = (i_instruction[0][7:0] == 8'b1100_1011);
assign o_opcode_RET_intersegment_adding_imm_to_SP   = (i_instruction[0][7:0] == 8'b1100_1010);
assign o_opcode_JO_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_0000);
assign o_opcode_JO_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0000);
assign o_opcode_JNO_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_0001);
assign o_opcode_JNO_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0001);
assign o_opcode_JB_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_0010);
assign o_opcode_JB_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0010);
assign o_opcode_JNB_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_0011);
assign o_opcode_JNB_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0011);
assign o_opcode_JE_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_0100);
assign o_opcode_JE_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0100);
assign o_opcode_JNE_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_0101);
assign o_opcode_JNE_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0101);
assign o_opcode_JBE_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_0110);
assign o_opcode_JBE_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0110);
assign o_opcode_JNBE_8bit_disp                      = (i_instruction[0][7:0] == 8'b0111_0111);
assign o_opcode_JNBE_full_disp                      = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0111);
assign o_opcode_JS_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_1000);
assign o_opcode_JS_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1000);
assign o_opcode_JNS_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_1001);
assign o_opcode_JNS_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1001);
assign o_opcode_JP_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_1010);
assign o_opcode_JP_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1010);
assign o_opcode_JNP_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_1011);
assign o_opcode_JNP_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1011);
assign o_opcode_JL_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_1100);
assign o_opcode_JL_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1100);
assign o_opcode_JNL_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_1101);
assign o_opcode_JNL_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1101);
assign o_opcode_JLE_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_1110);
assign o_opcode_JLE_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1110);
assign o_opcode_JNLE_8bit_disp                      = (i_instruction[0][7:0] == 8'b0111_1111);
assign o_opcode_JNLE_full_disp                      = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1111);
assign o_opcode_JCXZ                                = (i_instruction[0][7:0] == 8'b1110_0011); // (JCXZ and JECXZ: Address Size Prefix Differentiates JCXZ from JECXZ)
assign o_opcode_LOOP                                = (i_instruction[0][7:0] == 8'b1110_0010);
assign o_opcode_LOOPZ                               = (i_instruction[0][7:0] == 8'b1110_0001);
assign o_opcode_LOOPNZ                              = (i_instruction[0][7:0] == 8'b1110_0000);
assign o_opcode_SETO                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0000);
assign o_opcode_SETNO                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0001);
assign o_opcode_SETB                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0010);
assign o_opcode_SETNB                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0011);
assign o_opcode_SETE                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0100);
assign o_opcode_SETNE                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0101);
assign o_opcode_SETBE                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0110);
assign o_opcode_SETNBE                              = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0111);
assign o_opcode_SETS                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1000);
assign o_opcode_SETNS                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1001);
assign o_opcode_SETP                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1010);
assign o_opcode_SETNP                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1011);
assign o_opcode_SETL                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1100);
assign o_opcode_SETNL                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1101);
assign o_opcode_SETLE                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1110);
assign o_opcode_SETNLE                              = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1111);
assign o_opcode_ENTER                               = (i_instruction[0][7:0] == 8'b1100_1000);
assign o_opcode_LEAVE                               = (i_instruction[0][7:0] == 8'b1100_1001);
assign o_opcode_INT_type_3                          = (i_instruction[0][7:0] == 8'b1100_1100);
assign o_opcode_INT_type_specified                  = (i_instruction[0][7:0] == 8'b1100_1101);
assign o_opcode_INTO                                = (i_instruction[0][7:0] == 8'b1100_1110);
assign o_opcode_BOUND                               = (i_instruction[0][7:0] == 8'b0110_0010);
assign o_opcode_IRET                                = (i_instruction[0][7:0] == 8'b1100_1111);
assign o_opcode_HLT                                 = (i_instruction[0][7:0] == 8'b1111_0100);
assign o_opcode_MOV_CR0_CR2_CR3_from_reg            = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0010) & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_MOV_reg_from_CR0_3                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0000) & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_MOV_DR0_7_from_reg                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0011) & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_MOV_reg_from_DR0_7                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0001) & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_MOV_TR6_7_from_reg                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0110) & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_MOV_reg_from_TR6_7                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0100) & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_NOP                                 = (i_instruction[0][7:0] == 8'b1001_0000);
assign o_opcode_WAIT                                = (i_instruction[0][7:0] == 8'b1001_1011);
assign o_opcode_processor_extension_escape          = (i_instruction[0][7:3] == 5'b1101_1   );
assign o_opcode_ARPL                                = (i_instruction[0][7:0] == 8'b0110_0011);
assign o_opcode_LAR                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0010);
assign o_opcode_LGDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b010);
assign o_opcode_LIDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b011);
assign o_opcode_LLDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b010);
assign o_opcode_LMSW                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b110);
assign o_opcode_LSL                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0011);
assign o_opcode_LTR                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b011);
assign o_opcode_SGDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b000);
assign o_opcode_SIDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b001);
assign o_opcode_SLDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b000);
assign o_opcode_SMSW                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b100);
assign o_opcode_STR                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b001);
assign o_opcode_VERR                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b100);
assign o_opcode_VERW                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b101);


endmodule
