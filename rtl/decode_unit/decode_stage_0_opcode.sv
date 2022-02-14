/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_stage_0_opcode
create at: 2021-12-28 16:56:15
description: decode opcode from instruction
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_stage_0_opcode (
    // ports
    output logic        opcode_MOV_reg_to_reg_mem,
    output logic        opcode_MOV_reg_mem_to_reg,
    output logic        opcode_MOV_imm_to_reg_mem,
    output logic        opcode_MOV_imm_to_reg_short,
    output logic        opcode_MOV_mem_to_acc,
    output logic        opcode_MOV_acc_to_mem,
    output logic        opcode_MOV_reg_mem_to_sreg,
    output logic        opcode_MOV_sreg_to_reg_mem,
    output logic        opcode_MOVSX,
    output logic        opcode_MOVZX,
    output logic        opcode_PUSH_reg_mem,
    output logic        opcode_PUSH_reg_short,
    output logic        opcode_PUSH_sreg_2,
    output logic        opcode_PUSH_sreg_3,
    output logic        opcode_PUSH_imm,
    output logic        opcode_PUSH_all,
    output logic        opcode_POP_reg_mem,
    output logic        opcode_POP_reg_short,
    output logic        opcode_POP_sreg_2,
    output logic        opcode_POP_sreg_3,
    output logic        opcode_POP_all,
    output logic        opcode_XCHG_reg_mem_with_reg,
    output logic        opcode_XCHG_reg_with_acc_short,
    output logic        opcode_IN_port_fixed,
    output logic        opcode_IN_port_variable,
    output logic        opcode_OUT_port_fixed,
    output logic        opcode_OUT_port_variable,
    output logic        opcode_LEA_load_ea_to_reg,
    output logic        opcode_LDS_load_ptr_to_DS,
    output logic        opcode_LES_load_ptr_to_ES,
    output logic        opcode_LFS_load_ptr_to_FS,
    output logic        opcode_LGS_load_ptr_to_GS,
    output logic        opcode_LSS_load_ptr_to_SS,
    output logic        opcode_CLC_clear_carry_flag,
    output logic        opcode_CLD_clear_direction_flag,
    output logic        opcode_CLI_clear_interrupt_enable_flag,
    output logic        opcode_CLTS_clear_task_switched_flag,
    output logic        opcode_CMC_complement_carry_flag,
    output logic        opcode_LAHF_load_ah_into_flag,
    output logic        opcode_POPF_pop_flags,
    output logic        opcode_PUSHF_push_flags,
    output logic        opcode_SAHF_store_ah_into_flag,
    output logic        opcode_STC_set_carry_flag,
    output logic        opcode_STD_set_direction_flag,
    output logic        opcode_STI_set_interrupt_enable_flag,
    output logic        opcode_ADD_reg_to_mem,
    output logic        opcode_ADD_mem_to_reg,
    output logic        opcode_ADD_imm_to_reg_mem,
    output logic        opcode_ADD_imm_to_acc,
    output logic        opcode_ADC_reg_to_mem,
    output logic        opcode_ADC_mem_to_reg,
    output logic        opcode_ADC_imm_to_reg_mem,
    output logic        opcode_ADC_imm_to_acc,
    output logic        opcode_INC_reg_mem,
    output logic        opcode_INC_reg,
    output logic        opcode_SUB_reg_to_mem,
    output logic        opcode_SUB_mem_to_reg,
    output logic        opcode_SUB_imm_to_reg_mem,
    output logic        opcode_SUB_imm_to_acc,
    output logic        opcode_SBB_reg_to_mem,
    output logic        opcode_SBB_mem_to_reg,
    output logic        opcode_SBB_imm_to_reg_mem,
    output logic        opcode_SBB_imm_to_acc,
    output logic        opcode_DEC_reg_mem,
    output logic        opcode_DEC_reg,
    output logic        opcode_CMP_mem_with_reg,
    output logic        opcode_CMP_reg_with_mem,
    output logic        opcode_CMP_imm_with_reg_mem,
    output logic        opcode_CMP_imm_with_acc,
    output logic        opcode_NEG_change_sign,
    output logic        opcode_AAA,
    output logic        opcode_AAS,
    output logic        opcode_DAA,
    output logic        opcode_DAS,
    output logic        opcode_MUL_acc_with_reg_mem,
    output logic        opcode_IMUL_acc_with_reg_mem,
    output logic        opcode_IMUL_reg_with_reg_mem,
    output logic        opcode_IMUL_reg_mem_with_imm_to_reg,
    output logic        opcode_DIV_acc_by_reg_mem,
    output logic        opcode_IDIV_acc_by_reg_mem,
    output logic        opcode_AAD,
    output logic        opcode_AAM,
    output logic        opcode_CBW,
    output logic        opcode_CWD,
    output logic        opcode_ROL_reg_mem_by_1,
    output logic        opcode_ROL_reg_mem_by_CL,
    output logic        opcode_ROL_reg_mem_by_imm,
    output logic        opcode_ROR_reg_mem_by_1,
    output logic        opcode_ROR_reg_mem_by_CL,
    output logic        opcode_ROR_reg_mem_by_imm,
    output logic        opcode_SHL_reg_mem_by_1,
    output logic        opcode_SHL_reg_mem_by_CL,
    output logic        opcode_SHL_reg_mem_by_imm,
    output logic        opcode_SAR_reg_mem_by_1,
    output logic        opcode_SAR_reg_mem_by_CL,
    output logic        opcode_SAR_reg_mem_by_imm,
    output logic        opcode_SHR_reg_mem_by_1,
    output logic        opcode_SHR_reg_mem_by_CL,
    output logic        opcode_SHR_reg_mem_by_imm,
    output logic        opcode_RCL_reg_mem_by_1,
    output logic        opcode_RCL_reg_mem_by_CL,
    output logic        opcode_RCL_reg_mem_by_imm,
    output logic        opcode_RCR_reg_mem_by_1,
    output logic        opcode_RCR_reg_mem_by_CL,
    output logic        opcode_RCR_reg_mem_by_imm,
    output logic        opcode_SHLD_reg_mem_by_imm,
    output logic        opcode_SHLD_reg_mem_by_CL,
    output logic        opcode_SHRD_reg_mem_by_imm,
    output logic        opcode_SHRD_reg_mem_by_CL,
    output logic        opcode_AND_reg_to_mem,
    output logic        opcode_AND_mem_to_reg,
    output logic        opcode_AND_imm_to_reg_mem,
    output logic        opcode_AND_imm_to_acc,
    output logic        opcode_TEST_reg_mem_and_reg,
    output logic        opcode_TEST_imm_to_reg_mem,
    output logic        opcode_TEST_imm_to_acc,
    output logic        opcode_OR_reg_to_mem,
    output logic        opcode_OR_mem_to_reg,
    output logic        opcode_OR_imm_to_reg_mem,
    output logic        opcode_OR_imm_to_acc,
    output logic        opcode_XOR_reg_to_mem,
    output logic        opcode_XOR_mem_to_reg,
    output logic        opcode_XOR_imm_to_reg_mem,
    output logic        opcode_XOR_imm_to_acc,
    output logic        opcode_NOT,
    output logic        opcode_CMPS,
    output logic        opcode_INS,
    output logic        opcode_LODS,
    output logic        opcode_MOVS,
    output logic        opcode_OUTS,
    output logic        opcode_SCAS,
    output logic        opcode_STOS,
    output logic        opcode_XLAT,
    output logic        opcode_REPE,
    output logic        opcode_REPNE,
    output logic        opcode_BSF,
    output logic        opcode_BSR,
    output logic        opcode_BT_reg_mem_with_imm,
    output logic        opcode_BT_reg_mem_with_reg,
    output logic        opcode_BTC_reg_mem_with_imm,
    output logic        opcode_BTC_reg_mem_with_reg,
    output logic        opcode_BTR_reg_mem_with_imm,
    output logic        opcode_BTR_reg_mem_with_reg,
    output logic        opcode_BTS_reg_mem_with_imm,
    output logic        opcode_BTS_reg_mem_with_reg,
    output logic        opcode_CALL_direct_within_segment,
    output logic        opcode_CALL_indirect_within_segment,
    output logic        opcode_CALL_direct_intersegment,
    output logic        opcode_CALL_indirect_intersegment,
    output logic        opcode_JMP_short,
    output logic        opcode_JMP_direct_within_segment,
    output logic        opcode_JMP_indirect_within_segment,
    output logic        opcode_JMP_direct_intersegment,
    output logic        opcode_JMP_indirect_intersegment,
    output logic        opcode_RET_within_segment,
    output logic        opcode_RET_within_segment_adding_imm_to_SP,
    output logic        opcode_RET_intersegment,
    output logic        opcode_RET_intersegment_adding_imm_to_SP,
    output logic        opcode_JO_8bit_disp,
    output logic        opcode_JO_full_disp,
    output logic        opcode_JNO_8bit_disp,
    output logic        opcode_JNO_full_disp,
    output logic        opcode_JB_8bit_disp,
    output logic        opcode_JB_full_disp,
    output logic        opcode_JNB_8bit_disp,
    output logic        opcode_JNB_full_disp,
    output logic        opcode_JE_8bit_disp,
    output logic        opcode_JE_full_disp,
    output logic        opcode_JNE_8bit_disp,
    output logic        opcode_JNE_full_disp,
    output logic        opcode_JBE_8bit_disp,
    output logic        opcode_JBE_full_disp,
    output logic        opcode_JNBE_8bit_disp,
    output logic        opcode_JNBE_full_disp,
    output logic        opcode_JS_8bit_disp,
    output logic        opcode_JS_full_disp,
    output logic        opcode_JNS_8bit_disp,
    output logic        opcode_JNS_full_disp,
    output logic        opcode_JP_8bit_disp,
    output logic        opcode_JP_full_disp,
    output logic        opcode_JNP_8bit_disp,
    output logic        opcode_JNP_full_disp,
    output logic        opcode_JL_8bit_disp,
    output logic        opcode_JL_full_disp,
    output logic        opcode_JNL_8bit_disp,
    output logic        opcode_JNL_full_disp,
    output logic        opcode_JLE_8bit_disp,
    output logic        opcode_JLE_full_disp,
    output logic        opcode_JNLE_8bit_disp,
    output logic        opcode_JNLE_full_disp,
    output logic        opcode_JCXZ,
    output logic        opcode_LOOP,
    output logic        opcode_LOOPZ,
    output logic        opcode_LOOPNZ,
    output logic        opcode_SETO,
    output logic        opcode_SETNO,
    output logic        opcode_SETB,
    output logic        opcode_SETNB,
    output logic        opcode_SETE,
    output logic        opcode_SETNE,
    output logic        opcode_SETBE,
    output logic        opcode_SETNBE,
    output logic        opcode_SETS,
    output logic        opcode_SETNS,
    output logic        opcode_SETP,
    output logic        opcode_SETNP,
    output logic        opcode_SETL,
    output logic        opcode_SETNL,
    output logic        opcode_SETLE,
    output logic        opcode_SETNLE,
    output logic        opcode_ENTER,
    output logic        opcode_LEAVE,
    output logic        opcode_INT_type_3,
    output logic        opcode_INT_type_specified,
    output logic        opcode_INTO,
    output logic        opcode_BOUND,
    output logic        opcode_IRET,
    output logic        opcode_HLT,
    output logic        opcode_MOV_CR0_CR2_CR3_from_reg,
    output logic        opcode_MOV_reg_from_CR0_3,
    output logic        opcode_MOV_DR0_7_from_reg,
    output logic        opcode_MOV_reg_from_DR0_7,
    output logic        opcode_MOV_TR6_7_from_reg,
    output logic        opcode_MOV_reg_from_TR6_7,
    output logic        opcode_NOP,
    output logic        opcode_WAIT,
    output logic        opcode_processor_extension_escape,
    output logic        opcode_prefix_address_size,
    output logic        opcode_prefix_bus_lock,
    output logic        opcode_prefix_operand_size,
    output logic        opcode_prefix_segment_override_CS,
    output logic        opcode_prefix_segment_override_DS,
    output logic        opcode_prefix_segment_override_ES,
    output logic        opcode_prefix_segment_override_FS,
    output logic        opcode_prefix_segment_override_GS,
    output logic        opcode_prefix_segment_override_SS,
    output logic        opcode_ARPL,
    output logic        opcode_LAR,
    output logic        opcode_LGDT,
    output logic        opcode_LIDT,
    output logic        opcode_LLDT,
    output logic        opcode_LMSW,
    output logic        opcode_LSL,
    output logic        opcode_LTR,
    output logic        opcode_SGDT,
    output logic        opcode_SIDT,
    output logic        opcode_SLDT,
    output logic        opcode_SMSW,
    output logic        opcode_STR,
    output logic        opcode_VERR,
    output logic        opcode_VERW,
    input  logic [ 7:0] instruction[0:2]
);

assign opcode_MOV_reg_to_reg_mem                  = (instruction[0][7:1] == 7'b1000_100 );
assign opcode_MOV_reg_mem_to_reg                  = (instruction[0][7:1] == 7'b1000_101 );
assign opcode_MOV_imm_to_reg_mem                  = (instruction[0][7:1] == 7'b1100_011 ) & (instruction[1][5:3] == 3'b000);
assign opcode_MOV_imm_to_reg_short                = (instruction[0][7:4] == 4'b1011     );
assign opcode_MOV_mem_to_acc                      = (instruction[0][7:1] == 7'b1010_000 );
assign opcode_MOV_acc_to_mem                      = (instruction[0][7:1] == 7'b1010_001 );
assign opcode_MOV_reg_mem_to_sreg                 = (instruction[0][7:0] == 8'b1000_1110);
assign opcode_MOV_sreg_to_reg_mem                 = (instruction[0][7:0] == 8'b1000_1100);
assign opcode_MOVSX                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:1] == 7'b1011_111);
assign opcode_MOVZX                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:1] == 7'b1011_011);
assign opcode_PUSH_reg_mem                        = (instruction[0][7:0] == 8'b1111_1111) & (instruction[1][5:3] == 3'b110);
assign opcode_PUSH_reg_short                      = (instruction[0][7:3] == 5'b0101_0   );
assign opcode_PUSH_sreg_2                         = (instruction[0][7:5] == 3'b000      ) & (instruction[0][2:0] == 3'b110);
assign opcode_PUSH_sreg_3                         = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:6] == 2'b10) & (instruction[1][5] == 1'b1) & (instruction[1][2:0] == 3'b000);
assign opcode_PUSH_imm                            = (instruction[0][7:2] == 6'b0110_10  ) & (instruction[0][0] == 1'b0);
assign opcode_PUSH_all                            = (instruction[0][7:0] == 8'b0110_0000);
assign opcode_POP_reg_mem                         = (instruction[0][7:0] == 8'b1000_1111) & (instruction[1][5:3] == 3'b000);
assign opcode_POP_reg_short                       = (instruction[0][7:3] == 5'b0101_1   );
assign opcode_POP_sreg_2                          = (instruction[0][7:5] == 3'b000      ) & (instruction[0][4:3] != 2'b01) & (instruction[0][2:0] == 3'b111) & (instruction[1][5:3] != 3'b110) & (instruction[1][5:3] != 3'b111);
assign opcode_POP_sreg_3                          = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:6] == 2'b10) & (instruction[1][5] == 1'b1) & (instruction[1][2:0] == 3'b001);
assign opcode_POP_all                             = (instruction[0][7:0] == 8'b0110_0001);
assign opcode_XCHG_reg_mem_with_reg               = (instruction[0][7:1] == 7'b1000_011 );
assign opcode_XCHG_reg_with_acc_short             = (instruction[0][7:3] == 5'b1001_0   ) & (instruction[0][2:0] != 3'b000);
assign opcode_IN_port_fixed                       = (instruction[0][7:1] == 7'b1110_010 );
assign opcode_IN_port_variable                    = (instruction[0][7:1] == 7'b1110_110 );
assign opcode_OUT_port_fixed                      = (instruction[0][7:1] == 7'b1110_011 );
assign opcode_OUT_port_variable                   = (instruction[0][7:1] == 7'b1110_111 );
assign opcode_LEA_load_ea_to_reg                  = (instruction[0][7:0] == 8'b1000_1101);
assign opcode_LDS_load_ptr_to_DS                  = (instruction[0][7:0] == 8'b1100_0101);
assign opcode_LES_load_ptr_to_ES                  = (instruction[0][7:0] == 8'b1100_0100);
assign opcode_LFS_load_ptr_to_FS                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_0100);
assign opcode_LGS_load_ptr_to_GS                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_0101);
assign opcode_LSS_load_ptr_to_SS                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_0010);
assign opcode_CLC_clear_carry_flag                = (instruction[0][7:0] == 8'b1111_1000);
assign opcode_CLD_clear_direction_flag            = (instruction[0][7:0] == 8'b1111_1100);
assign opcode_CLI_clear_interrupt_enable_flag     = (instruction[0][7:0] == 8'b1111_1010);
assign opcode_CLTS_clear_task_switched_flag       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0110);
assign opcode_CMC_complement_carry_flag           = (instruction[0][7:0] == 8'b1111_0101);
assign opcode_LAHF_load_ah_into_flag              = (instruction[0][7:0] == 8'b1001_1111);
assign opcode_POPF_pop_flags                      = (instruction[0][7:0] == 8'b1001_1101);
assign opcode_PUSHF_push_flags                    = (instruction[0][7:0] == 8'b1001_1100);
assign opcode_SAHF_store_ah_into_flag             = (instruction[0][7:0] == 8'b1001_1110);
assign opcode_STC_set_carry_flag                  = (instruction[0][7:0] == 8'b1111_1001);
assign opcode_STD_set_direction_flag              = (instruction[0][7:0] == 8'b1111_1101);
assign opcode_STI_set_interrupt_enable_flag       = (instruction[0][7:0] == 8'b1111_1011);
assign opcode_ADD_reg_to_mem                      = (instruction[0][7:1] == 7'b0000_000 );
assign opcode_ADD_mem_to_reg                      = (instruction[0][7:1] == 7'b0000_001 );
assign opcode_ADD_imm_to_reg_mem                  = (instruction[0][7:2] == 6'b1000_00  ) & (instruction[1][5:3] == 3'b000);
assign opcode_ADD_imm_to_acc                      = (instruction[0][7:1] == 7'b0000_010 );
assign opcode_ADC_reg_to_mem                      = (instruction[0][7:1] == 7'b0001_000 );
assign opcode_ADC_mem_to_reg                      = (instruction[0][7:1] == 7'b0001_001 );
assign opcode_ADC_imm_to_reg_mem                  = (instruction[0][7:2] == 6'b1000_00  ) & (instruction[1][5:3] == 3'b010);
assign opcode_ADC_imm_to_acc                      = (instruction[0][7:1] == 7'b0001_010 );
assign opcode_INC_reg_mem                         = (instruction[0][7:0] == 8'b1111_1111) & (instruction[1][5:3] == 3'b000);
assign opcode_INC_reg                             = (instruction[0][7:3] == 5'b0100_0   );
assign opcode_SUB_reg_to_mem                      = (instruction[0][7:1] == 7'b0010_100 );
assign opcode_SUB_mem_to_reg                      = (instruction[0][7:1] == 7'b0010_101 );
assign opcode_SUB_imm_to_reg_mem                  = (instruction[0][7:2] == 6'b1000_00  ) & (instruction[1][5:3] == 3'b101);
assign opcode_SUB_imm_to_acc                      = (instruction[0][7:1] == 7'b0010_110 );
assign opcode_SBB_reg_to_mem                      = (instruction[0][7:1] == 7'b0001_100 );
assign opcode_SBB_mem_to_reg                      = (instruction[0][7:1] == 7'b0001_101 );
assign opcode_SBB_imm_to_reg_mem                  = (instruction[0][7:2] == 6'b1000_00  ) & (instruction[1][5:3] == 3'b011);
assign opcode_SBB_imm_to_acc                      = (instruction[0][7:1] == 7'b0001_110 );
assign opcode_DEC_reg_mem                         = (instruction[0][7:0] == 8'b1111_1111) & (instruction[1][5:3] == 3'b001);
assign opcode_DEC_reg                             = (instruction[0][7:3] == 5'b0100_1   );
assign opcode_CMP_mem_with_reg                    = (instruction[0][7:1] == 7'b0011_100 );
assign opcode_CMP_reg_with_mem                    = (instruction[0][7:1] == 7'b0011_101 );
assign opcode_CMP_imm_with_reg_mem                = (instruction[0][7:2] == 6'b1000_00  ) & (instruction[1][5:3] == 3'b111);
assign opcode_CMP_imm_with_acc                    = (instruction[0][7:1] == 7'b0011_110 );
assign opcode_NEG_change_sign                     = (instruction[0][7:1] == 7'b1111_011 ) & (instruction[1][5:3] == 3'b011);
assign opcode_AAA                                 = (instruction[0][7:0] == 8'b0011_0111);
assign opcode_AAS                                 = (instruction[0][7:0] == 8'b0011_1111);
assign opcode_DAA                                 = (instruction[0][7:0] == 8'b0010_0111);
assign opcode_DAS                                 = (instruction[0][7:0] == 8'b0010_1111);
assign opcode_MUL_acc_with_reg_mem                = (instruction[0][7:1] == 7'b1111_011 ) & (instruction[1][5:3] == 3'b100);
assign opcode_IMUL_acc_with_reg_mem               = (instruction[0][7:1] == 7'b1111_011 ) & (instruction[1][5:3] == 3'b101);
assign opcode_IMUL_reg_with_reg_mem               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1010_1111);
assign opcode_IMUL_reg_mem_with_imm_to_reg        = (instruction[0][7:2] == 6'b0110_10  ) & (instruction[0][0] == 1'b1);
assign opcode_DIV_acc_by_reg_mem                  = (instruction[0][7:1] == 7'b1111_011 ) & (instruction[1][5:3] == 3'b110);
assign opcode_IDIV_acc_by_reg_mem                 = (instruction[0][7:1] == 7'b1111_011 ) & (instruction[1][5:3] == 3'b111);
assign opcode_AAD                                 = (instruction[0][7:0] == 8'b1101_0101) & (instruction[1][7:0] == 8'b0000_1010);
assign opcode_AAM                                 = (instruction[0][7:0] == 8'b1101_0100) & (instruction[1][7:0] == 8'b0000_1010);
assign opcode_CBW                                 = (instruction[0][7:0] == 8'b1001_1000);
assign opcode_CWD                                 = (instruction[0][7:0] == 8'b1001_1001);
assign opcode_ROL_reg_mem_by_1                    = (instruction[0][7:1] == 7'b1101_000 ) & (instruction[1][5:3] == 3'b000);
assign opcode_ROL_reg_mem_by_CL                   = (instruction[0][7:1] == 7'b1101_001 ) & (instruction[1][5:3] == 3'b000);
assign opcode_ROL_reg_mem_by_imm                  = (instruction[0][7:1] == 7'b1100_000 ) & (instruction[1][5:3] == 3'b000);
assign opcode_ROR_reg_mem_by_1                    = (instruction[0][7:1] == 7'b1101_000 ) & (instruction[1][5:3] == 3'b001);
assign opcode_ROR_reg_mem_by_CL                   = (instruction[0][7:1] == 7'b1101_001 ) & (instruction[1][5:3] == 3'b001);
assign opcode_ROR_reg_mem_by_imm                  = (instruction[0][7:1] == 7'b1100_000 ) & (instruction[1][5:3] == 3'b001);
assign opcode_SHL_reg_mem_by_1                    = (instruction[0][7:1] == 7'b1101_000 ) & (instruction[1][5:3] == 3'b100);
assign opcode_SHL_reg_mem_by_CL                   = (instruction[0][7:1] == 7'b1101_001 ) & (instruction[1][5:3] == 3'b100);
assign opcode_SHL_reg_mem_by_imm                  = (instruction[0][7:1] == 7'b1100_000 ) & (instruction[1][5:3] == 3'b100);
assign opcode_SAR_reg_mem_by_1                    = (instruction[0][7:1] == 7'b1101_000 ) & (instruction[1][5:3] == 3'b111);
assign opcode_SAR_reg_mem_by_CL                   = (instruction[0][7:1] == 7'b1101_001 ) & (instruction[1][5:3] == 3'b111);
assign opcode_SAR_reg_mem_by_imm                  = (instruction[0][7:1] == 7'b1100_000 ) & (instruction[1][5:3] == 3'b111);
assign opcode_SHR_reg_mem_by_1                    = (instruction[0][7:1] == 7'b1101_000 ) & (instruction[1][5:3] == 3'b101);
assign opcode_SHR_reg_mem_by_CL                   = (instruction[0][7:1] == 7'b1101_001 ) & (instruction[1][5:3] == 3'b101);
assign opcode_SHR_reg_mem_by_imm                  = (instruction[0][7:1] == 7'b1100_000 ) & (instruction[1][5:3] == 3'b101);
assign opcode_RCL_reg_mem_by_1                    = (instruction[0][7:1] == 7'b1101_000 ) & (instruction[1][5:3] == 3'b010);
assign opcode_RCL_reg_mem_by_CL                   = (instruction[0][7:1] == 7'b1101_001 ) & (instruction[1][5:3] == 3'b010);
assign opcode_RCL_reg_mem_by_imm                  = (instruction[0][7:1] == 7'b1100_000 ) & (instruction[1][5:3] == 3'b010);
assign opcode_RCR_reg_mem_by_1                    = (instruction[0][7:1] == 7'b1101_000 ) & (instruction[1][5:3] == 3'b011);
assign opcode_RCR_reg_mem_by_CL                   = (instruction[0][7:1] == 7'b1101_001 ) & (instruction[1][5:3] == 3'b011);
assign opcode_RCR_reg_mem_by_imm                  = (instruction[0][7:1] == 7'b1100_000 ) & (instruction[1][5:3] == 3'b011);
assign opcode_SHLD_reg_mem_by_imm                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1010_0100);
assign opcode_SHLD_reg_mem_by_CL                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1010_0101);
assign opcode_SHRD_reg_mem_by_imm                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1010_1100);
assign opcode_SHRD_reg_mem_by_CL                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1010_1101);
assign opcode_AND_reg_to_mem                      = (instruction[0][7:1] == 7'b0010_000 );
assign opcode_AND_mem_to_reg                      = (instruction[0][7:1] == 7'b0010_001 );
assign opcode_AND_imm_to_reg_mem                  = (instruction[0][7:2] == 6'b1000_00  ) & (instruction[1][5:3] == 3'b100);
assign opcode_AND_imm_to_acc                      = (instruction[0][7:1] == 7'b0010_010 );
assign opcode_TEST_reg_mem_and_reg                = (instruction[0][7:1] == 7'b1000_010 );
assign opcode_TEST_imm_to_reg_mem                 = (instruction[0][7:1] == 7'b1111_011 ) & (instruction[1][5:3] == 3'b000);
assign opcode_TEST_imm_to_acc                     = (instruction[0][7:1] == 7'b1010_100 );
assign opcode_OR_reg_to_mem                       = (instruction[0][7:1] == 7'b0000_100 );
assign opcode_OR_mem_to_reg                       = (instruction[0][7:1] == 7'b0000_101 );
assign opcode_OR_imm_to_reg_mem                   = (instruction[0][7:2] == 6'b1000_00  ) & (instruction[1][5:3] == 3'b001);
assign opcode_OR_imm_to_acc                       = (instruction[0][7:1] == 7'b0000_110 );
assign opcode_XOR_reg_to_mem                      = (instruction[0][7:1] == 7'b0011_000 );
assign opcode_XOR_mem_to_reg                      = (instruction[0][7:1] == 7'b0011_001 );
assign opcode_XOR_imm_to_reg_mem                  = (instruction[0][7:2] == 6'b1000_00  ) & (instruction[1][5:3] == 3'b110);
assign opcode_XOR_imm_to_acc                      = (instruction[0][7:1] == 7'b0011_010 );
assign opcode_NOT                                 = (instruction[0][7:1] == 7'b1111_011 ) & (instruction[1][5:3] == 3'b010);
assign opcode_CMPS                                = (instruction[0][7:1] == 7'b1010_011 );
assign opcode_INS                                 = (instruction[0][7:1] == 7'b0110_110 );
assign opcode_LODS                                = (instruction[0][7:1] == 7'b1010_110 );
assign opcode_MOVS                                = (instruction[0][7:1] == 7'b1010_010 );
assign opcode_OUTS                                = (instruction[0][7:1] == 7'b0110_111 );
assign opcode_SCAS                                = (instruction[0][7:1] == 7'b1010_111 );
assign opcode_STOS                                = (instruction[0][7:1] == 7'b1010_101 );
assign opcode_XLAT                                = (instruction[0][7:0] == 8'b1101_0111);
assign opcode_REPE                                = (instruction[0][7:0] == 8'b1111_0011);
assign opcode_REPNE                               = (instruction[0][7:0] == 8'b1111_0010);
assign opcode_BSF                                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_1100);
assign opcode_BSR                                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_1101);
assign opcode_BT_reg_mem_with_imm                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_1010) & (instruction[2][5:3] == 3'b100);
assign opcode_BT_reg_mem_with_reg                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1010_0011);
assign opcode_BTC_reg_mem_with_imm                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_1010) & (instruction[2][5:3] == 3'b111);
assign opcode_BTC_reg_mem_with_reg                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_1011);
assign opcode_BTR_reg_mem_with_imm                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_1010) & (instruction[2][5:3] == 3'b110);
assign opcode_BTR_reg_mem_with_reg                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_0011);
assign opcode_BTS_reg_mem_with_imm                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_1010) & (instruction[2][5:3] == 3'b101);
assign opcode_BTS_reg_mem_with_reg                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1010_1011);
assign opcode_CALL_direct_within_segment          = (instruction[0][7:0] == 8'b1110_1000);
assign opcode_CALL_indirect_within_segment        = (instruction[0][7:1] == 8'b1111_1111) & (instruction[1][5:3] == 3'b010);
assign opcode_CALL_direct_intersegment            = (instruction[0][7:0] == 8'b1001_1010);
assign opcode_CALL_indirect_intersegment          = (instruction[0][7:0] == 8'b1111_1111) & (instruction[1][5:3] == 3'b011);
assign opcode_JMP_short                           = (instruction[0][7:0] == 8'b1110_1011);
assign opcode_JMP_direct_within_segment           = (instruction[0][7:0] == 8'b1110_1001);
assign opcode_JMP_indirect_within_segment         = (instruction[0][7:0] == 8'b1111_1111) & (instruction[1][5:3] == 3'b100);
assign opcode_JMP_direct_intersegment             = (instruction[0][7:0] == 8'b1110_1010);
assign opcode_JMP_indirect_intersegment           = (instruction[0][7:0] == 8'b1111_1111) & (instruction[1][5:3] == 3'b101);
assign opcode_RET_within_segment                  = (instruction[0][7:0] == 8'b1100_0011);
assign opcode_RET_within_segment_adding_imm_to_SP = (instruction[0][7:0] == 8'b1100_0010);
assign opcode_RET_intersegment                    = (instruction[0][7:0] == 8'b1100_1011);
assign opcode_RET_intersegment_adding_imm_to_SP   = (instruction[0][7:0] == 8'b1100_1010);
assign opcode_JO_8bit_disp                        = (instruction[0][7:0] == 8'b0111_0000);
assign opcode_JO_full_disp                        = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0000);
assign opcode_JNO_8bit_disp                       = (instruction[0][7:0] == 8'b0111_0001);
assign opcode_JNO_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0001);
assign opcode_JB_8bit_disp                        = (instruction[0][7:0] == 8'b0111_0010);
assign opcode_JB_full_disp                        = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0010);
assign opcode_JNB_8bit_disp                       = (instruction[0][7:0] == 8'b0111_0011);
assign opcode_JNB_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0011);
assign opcode_JE_8bit_disp                        = (instruction[0][7:0] == 8'b0111_0100);
assign opcode_JE_full_disp                        = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0100);
assign opcode_JNE_8bit_disp                       = (instruction[0][7:0] == 8'b0111_0101);
assign opcode_JNE_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0101);
assign opcode_JBE_8bit_disp                       = (instruction[0][7:0] == 8'b0111_0110);
assign opcode_JBE_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0110);
assign opcode_JNBE_8bit_disp                      = (instruction[0][7:0] == 8'b0111_0111);
assign opcode_JNBE_full_disp                      = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0111);
assign opcode_JS_8bit_disp                        = (instruction[0][7:0] == 8'b0111_1000);
assign opcode_JS_full_disp                        = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1000);
assign opcode_JNS_8bit_disp                       = (instruction[0][7:0] == 8'b0111_1001);
assign opcode_JNS_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1001);
assign opcode_JP_8bit_disp                        = (instruction[0][7:0] == 8'b0111_1010);
assign opcode_JP_full_disp                        = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1010);
assign opcode_JNP_8bit_disp                       = (instruction[0][7:0] == 8'b0111_1011);
assign opcode_JNP_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1011);
assign opcode_JL_8bit_disp                        = (instruction[0][7:0] == 8'b0111_1100);
assign opcode_JL_full_disp                        = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1100);
assign opcode_JNL_8bit_disp                       = (instruction[0][7:0] == 8'b0111_1101);
assign opcode_JNL_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1101);
assign opcode_JLE_8bit_disp                       = (instruction[0][7:0] == 8'b0111_1110);
assign opcode_JLE_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1110);
assign opcode_JNLE_8bit_disp                      = (instruction[0][7:0] == 8'b0111_1111);
assign opcode_JNLE_full_disp                      = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1111);
assign opcode_JCXZ                                = (instruction[0][7:0] == 8'b1110_0011); // (JCXZ and JECXZ: Address Size Prefix Differentiates JCXZ from JECXZ)
assign opcode_LOOP                                = (instruction[0][7:0] == 8'b1110_0010);
assign opcode_LOOPZ                               = (instruction[0][7:0] == 8'b1110_0001);
assign opcode_LOOPNZ                              = (instruction[0][7:0] == 8'b1110_0000);
assign opcode_SETO                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0000);
assign opcode_SETNO                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0001);
assign opcode_SETB                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0010);
assign opcode_SETNB                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0011);
assign opcode_SETE                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0100);
assign opcode_SETNE                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0101);
assign opcode_SETBE                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0110);
assign opcode_SETNBE                              = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0111);
assign opcode_SETS                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1000);
assign opcode_SETNS                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1001);
assign opcode_SETP                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1010);
assign opcode_SETNP                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1011);
assign opcode_SETL                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1100);
assign opcode_SETNL                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1101);
assign opcode_SETLE                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1110);
assign opcode_SETNLE                              = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1111);
assign opcode_ENTER                               = (instruction[0][7:0] == 8'b1100_1000);
assign opcode_LEAVE                               = (instruction[0][7:0] == 8'b1100_1001);
assign opcode_INT_type_3                          = (instruction[0][7:0] == 8'b1100_1100);
assign opcode_INT_type_specified                  = (instruction[0][7:0] == 8'b1100_1101);
assign opcode_INTO                                = (instruction[0][7:0] == 8'b1100_1110);
assign opcode_BOUND                               = (instruction[0][7:0] == 8'b0110_0010);
assign opcode_IRET                                = (instruction[0][7:0] == 8'b1100_1111);
assign opcode_HLT                                 = (instruction[0][7:0] == 8'b1111_0100);
assign opcode_MOV_CR0_CR2_CR3_from_reg            = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0010_0010) & (instruction[2][7:6] == 2'b11);
assign opcode_MOV_reg_from_CR0_3                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0010_0000) & (instruction[2][7:6] == 2'b11);
assign opcode_MOV_DR0_7_from_reg                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0010_0011) & (instruction[2][7:6] == 2'b11);
assign opcode_MOV_reg_from_DR0_7                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0010_0001) & (instruction[2][7:6] == 2'b11);
assign opcode_MOV_TR6_7_from_reg                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0010_0110) & (instruction[2][7:6] == 2'b11);
assign opcode_MOV_reg_from_TR6_7                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0010_0100) & (instruction[2][7:6] == 2'b11);
assign opcode_NOP                                 = (instruction[0][7:0] == 8'b1001_0000);
assign opcode_WAIT                                = (instruction[0][7:0] == 8'b1001_1011);
assign opcode_processor_extension_escape          = (instruction[0][7:3] == 5'b1101_1   );
assign opcode_prefix_address_size                 = (instruction[0][7:0] == 8'b0110_0111);
assign opcode_prefix_bus_lock                     = (instruction[0][7:0] == 8'b1111_0000);
assign opcode_prefix_operand_size                 = (instruction[0][7:0] == 8'b0110_0110);
assign opcode_prefix_segment_override_CS          = (instruction[0][7:0] == 8'b0010_1110);
assign opcode_prefix_segment_override_DS          = (instruction[0][7:0] == 8'b0011_1110);
assign opcode_prefix_segment_override_ES          = (instruction[0][7:0] == 8'b0010_0110);
assign opcode_prefix_segment_override_FS          = (instruction[0][7:0] == 8'b0110_0100);
assign opcode_prefix_segment_override_GS          = (instruction[0][7:0] == 8'b0110_0101);
assign opcode_prefix_segment_override_SS          = (instruction[0][7:0] == 8'b0011_0110);
assign opcode_ARPL                                = (instruction[0][7:0] == 8'b0110_0011);
assign opcode_LAR                                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0010);
assign opcode_LGDT                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0001) & (instruction[2][5:3] == 3'b010);
assign opcode_LIDT                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0001) & (instruction[2][5:3] == 3'b011);
assign opcode_LLDT                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0000) & (instruction[2][5:3] == 3'b010);
assign opcode_LMSW                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0001) & (instruction[2][5:3] == 3'b110);
assign opcode_LSL                                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0011);
assign opcode_LTR                                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0000) & (instruction[2][5:3] == 3'b011);
assign opcode_SGDT                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0001) & (instruction[2][5:3] == 3'b000);
assign opcode_SIDT                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0001) & (instruction[2][5:3] == 3'b001);
assign opcode_SLDT                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0000) & (instruction[2][5:3] == 3'b000);
assign opcode_SMSW                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0001) & (instruction[2][5:3] == 3'b100);
assign opcode_STR                                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0000) & (instruction[2][5:3] == 3'b001);
assign opcode_VERR                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0000) & (instruction[2][5:3] == 3'b100);
assign opcode_VERW                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0000) & (instruction[2][5:3] == 3'b101);


endmodule
