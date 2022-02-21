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
    output logic [241:0] o_opcode
);

wire opcode_MOV_reg_to_reg_mem                  = (i_instruction[0][7:1] == 7'b1000_100 );
wire opcode_MOV_reg_mem_to_reg                  = (i_instruction[0][7:1] == 7'b1000_101 );
wire opcode_MOV_imm_to_reg_mem                  = (i_instruction[0][7:1] == 7'b1100_011 ) & (i_instruction[1][5:3] == 3'b000);
wire opcode_MOV_imm_to_reg_short                = (i_instruction[0][7:4] == 4'b1011     );
wire opcode_MOV_mem_to_acc                      = (i_instruction[0][7:1] == 7'b1010_000 );
wire opcode_MOV_acc_to_mem                      = (i_instruction[0][7:1] == 7'b1010_001 );
wire opcode_MOV_reg_mem_to_sreg                 = (i_instruction[0][7:0] == 8'b1000_1110);
wire opcode_MOV_sreg_to_reg_mem                 = (i_instruction[0][7:0] == 8'b1000_1100);
wire opcode_MOVSX                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:1] == 7'b1011_111);
wire opcode_MOVZX                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:1] == 7'b1011_011);
wire opcode_PUSH_reg_mem                        = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b110);
wire opcode_PUSH_reg_short                      = (i_instruction[0][7:3] == 5'b0101_0   );
wire opcode_PUSH_sreg_2                         = (i_instruction[0][7:5] == 3'b000      ) & (i_instruction[0][2:0] == 3'b110);
wire opcode_PUSH_sreg_3                         = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:6] == 2'b10) & (i_instruction[1][5] == 1'b1) & (i_instruction[1][2:0] == 3'b000);
wire opcode_PUSH_imm                            = (i_instruction[0][7:2] == 6'b0110_10  ) & (i_instruction[0][0] == 1'b0);
wire opcode_PUSH_all                            = (i_instruction[0][7:0] == 8'b0110_0000);
wire opcode_POP_reg_mem                         = (i_instruction[0][7:0] == 8'b1000_1111) & (i_instruction[1][5:3] == 3'b000);
wire opcode_POP_reg_short                       = (i_instruction[0][7:3] == 5'b0101_1   );
wire opcode_POP_sreg_2                          = (i_instruction[0][7:5] == 3'b000      ) & (i_instruction[0][4:3] != 2'b01) & (i_instruction[0][2:0] == 3'b111) & (i_instruction[1][5:3] != 3'b110) & (i_instruction[1][5:3] != 3'b111);
wire opcode_POP_sreg_3                          = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:6] == 2'b10) & (i_instruction[1][5] == 1'b1) & (i_instruction[1][2:0] == 3'b001);
wire opcode_POP_all                             = (i_instruction[0][7:0] == 8'b0110_0001);
wire opcode_XCHG_reg_mem_with_reg               = (i_instruction[0][7:1] == 7'b1000_011 );
wire opcode_XCHG_reg_with_acc_short             = (i_instruction[0][7:3] == 5'b1001_0   ) & (i_instruction[0][2:0] != 3'b000);
wire opcode_IN_port_fixed                       = (i_instruction[0][7:1] == 7'b1110_010 );
wire opcode_IN_port_variable                    = (i_instruction[0][7:1] == 7'b1110_110 );
wire opcode_OUT_port_fixed                      = (i_instruction[0][7:1] == 7'b1110_011 );
wire opcode_OUT_port_variable                   = (i_instruction[0][7:1] == 7'b1110_111 );
wire opcode_LEA_load_ea_to_reg                  = (i_instruction[0][7:0] == 8'b1000_1101);
wire opcode_LDS_load_ptr_to_DS                  = (i_instruction[0][7:0] == 8'b1100_0101);
wire opcode_LES_load_ptr_to_ES                  = (i_instruction[0][7:0] == 8'b1100_0100);
wire opcode_LFS_load_ptr_to_FS                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0100);
wire opcode_LGS_load_ptr_to_GS                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0101);
wire opcode_LSS_load_ptr_to_SS                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0010);
wire opcode_CLC_clear_carry_flag                = (i_instruction[0][7:0] == 8'b1111_1000);
wire opcode_CLD_clear_direction_flag            = (i_instruction[0][7:0] == 8'b1111_1100);
wire opcode_CLI_clear_interrupt_enable_flag     = (i_instruction[0][7:0] == 8'b1111_1010);
wire opcode_CLTS_clear_task_switched_flag       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0110);
wire opcode_CMC_complement_carry_flag           = (i_instruction[0][7:0] == 8'b1111_0101);
wire opcode_LAHF_load_ah_into_flag              = (i_instruction[0][7:0] == 8'b1001_1111);
wire opcode_POPF_pop_flags                      = (i_instruction[0][7:0] == 8'b1001_1101);
wire opcode_PUSHF_push_flags                    = (i_instruction[0][7:0] == 8'b1001_1100);
wire opcode_SAHF_store_ah_into_flag             = (i_instruction[0][7:0] == 8'b1001_1110);
wire opcode_STC_set_carry_flag                  = (i_instruction[0][7:0] == 8'b1111_1001);
wire opcode_STD_set_direction_flag              = (i_instruction[0][7:0] == 8'b1111_1101);
wire opcode_STI_set_interrupt_enable_flag       = (i_instruction[0][7:0] == 8'b1111_1011);
wire opcode_ADD_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0000_000 );
wire opcode_ADD_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0000_001 );
wire opcode_ADD_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b000);
wire opcode_ADD_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0000_010 );
wire opcode_ADC_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0001_000 );
wire opcode_ADC_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0001_001 );
wire opcode_ADC_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b010);
wire opcode_ADC_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0001_010 );
wire opcode_INC_reg_mem                         = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b000);
wire opcode_INC_reg                             = (i_instruction[0][7:3] == 5'b0100_0   );
wire opcode_SUB_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0010_100 );
wire opcode_SUB_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0010_101 );
wire opcode_SUB_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b101);
wire opcode_SUB_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0010_110 );
wire opcode_SBB_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0001_100 );
wire opcode_SBB_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0001_101 );
wire opcode_SBB_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b011);
wire opcode_SBB_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0001_110 );
wire opcode_DEC_reg_mem                         = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b001);
wire opcode_DEC_reg                             = (i_instruction[0][7:3] == 5'b0100_1   );
wire opcode_CMP_mem_with_reg                    = (i_instruction[0][7:1] == 7'b0011_100 );
wire opcode_CMP_reg_with_mem                    = (i_instruction[0][7:1] == 7'b0011_101 );
wire opcode_CMP_imm_with_reg_mem                = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b111);
wire opcode_CMP_imm_with_acc                    = (i_instruction[0][7:1] == 7'b0011_110 );
wire opcode_NEG_change_sign                     = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b011);
wire opcode_AAA                                 = (i_instruction[0][7:0] == 8'b0011_0111);
wire opcode_AAS                                 = (i_instruction[0][7:0] == 8'b0011_1111);
wire opcode_DAA                                 = (i_instruction[0][7:0] == 8'b0010_0111);
wire opcode_DAS                                 = (i_instruction[0][7:0] == 8'b0010_1111);
wire opcode_MUL_acc_with_reg_mem                = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b100);
wire opcode_IMUL_acc_with_reg_mem               = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b101);
wire opcode_IMUL_reg_with_reg_mem               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1111);
wire opcode_IMUL_reg_mem_with_imm_to_reg        = (i_instruction[0][7:2] == 6'b0110_10  ) & (i_instruction[0][0] == 1'b1);
wire opcode_DIV_acc_by_reg_mem                  = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b110);
wire opcode_IDIV_acc_by_reg_mem                 = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b111);
wire opcode_AAD                                 = (i_instruction[0][7:0] == 8'b1101_0101) & (i_instruction[1][7:0] == 8'b0000_1010);
wire opcode_AAM                                 = (i_instruction[0][7:0] == 8'b1101_0100) & (i_instruction[1][7:0] == 8'b0000_1010);
wire opcode_CBW                                 = (i_instruction[0][7:0] == 8'b1001_1000);
wire opcode_CWD                                 = (i_instruction[0][7:0] == 8'b1001_1001);
wire opcode_ROL_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b000);
wire opcode_ROL_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b000);
wire opcode_ROL_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b000);
wire opcode_ROR_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b001);
wire opcode_ROR_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b001);
wire opcode_ROR_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b001);
wire opcode_SHL_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b100);
wire opcode_SHL_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b100);
wire opcode_SHL_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b100);
wire opcode_SAR_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b111);
wire opcode_SAR_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b111);
wire opcode_SAR_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b111);
wire opcode_SHR_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b101);
wire opcode_SHR_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b101);
wire opcode_SHR_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b101);
wire opcode_RCL_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b010);
wire opcode_RCL_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b010);
wire opcode_RCL_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b010);
wire opcode_RCR_reg_mem_by_1                    = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b011);
wire opcode_RCR_reg_mem_by_CL                   = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b011);
wire opcode_RCR_reg_mem_by_imm                  = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b011);
wire opcode_SHLD_reg_mem_by_imm                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_0100);
wire opcode_SHLD_reg_mem_by_CL                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_0101);
wire opcode_SHRD_reg_mem_by_imm                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1100);
wire opcode_SHRD_reg_mem_by_CL                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1101);
wire opcode_AND_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0010_000 );
wire opcode_AND_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0010_001 );
wire opcode_AND_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b100);
wire opcode_AND_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0010_010 );
wire opcode_TEST_reg_mem_and_reg                = (i_instruction[0][7:1] == 7'b1000_010 );
wire opcode_TEST_imm_to_reg_mem                 = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b000);
wire opcode_TEST_imm_to_acc                     = (i_instruction[0][7:1] == 7'b1010_100 );
wire opcode_OR_reg_to_mem                       = (i_instruction[0][7:1] == 7'b0000_100 );
wire opcode_OR_mem_to_reg                       = (i_instruction[0][7:1] == 7'b0000_101 );
wire opcode_OR_imm_to_reg_mem                   = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b001);
wire opcode_OR_imm_to_acc                       = (i_instruction[0][7:1] == 7'b0000_110 );
wire opcode_XOR_reg_to_mem                      = (i_instruction[0][7:1] == 7'b0011_000 );
wire opcode_XOR_mem_to_reg                      = (i_instruction[0][7:1] == 7'b0011_001 );
wire opcode_XOR_imm_to_reg_mem                  = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b110);
wire opcode_XOR_imm_to_acc                      = (i_instruction[0][7:1] == 7'b0011_010 );
wire opcode_NOT                                 = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b010);
wire opcode_CMPS                                = (i_instruction[0][7:1] == 7'b1010_011 );
wire opcode_INS                                 = (i_instruction[0][7:1] == 7'b0110_110 );
wire opcode_LODS                                = (i_instruction[0][7:1] == 7'b1010_110 );
wire opcode_MOVS                                = (i_instruction[0][7:1] == 7'b1010_010 );
wire opcode_OUTS                                = (i_instruction[0][7:1] == 7'b0110_111 );
wire opcode_SCAS                                = (i_instruction[0][7:1] == 7'b1010_111 );
wire opcode_STOS                                = (i_instruction[0][7:1] == 7'b1010_101 );
wire opcode_XLAT                                = (i_instruction[0][7:0] == 8'b1101_0111);
wire opcode_REPE                                = (i_instruction[0][7:0] == 8'b1111_0011);
wire opcode_REPNE                               = (i_instruction[0][7:0] == 8'b1111_0010);
wire opcode_BSF                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1100);
wire opcode_BSR                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1101);
wire opcode_BT_reg_mem_with_imm                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b100);
wire opcode_BT_reg_mem_with_reg                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_0011);
wire opcode_BTC_reg_mem_with_imm                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b111);
wire opcode_BTC_reg_mem_with_reg                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1011);
wire opcode_BTR_reg_mem_with_imm                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b110);
wire opcode_BTR_reg_mem_with_reg                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0011);
wire opcode_BTS_reg_mem_with_imm                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b101);
wire opcode_BTS_reg_mem_with_reg                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1011);
wire opcode_CALL_direct_within_segment          = (i_instruction[0][7:0] == 8'b1110_1000);
wire opcode_CALL_indirect_within_segment        = (i_instruction[0][7:1] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b010);
wire opcode_CALL_direct_intersegment            = (i_instruction[0][7:0] == 8'b1001_1010);
wire opcode_CALL_indirect_intersegment          = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b011);
wire opcode_JMP_short                           = (i_instruction[0][7:0] == 8'b1110_1011);
wire opcode_JMP_direct_within_segment           = (i_instruction[0][7:0] == 8'b1110_1001);
wire opcode_JMP_indirect_within_segment         = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b100);
wire opcode_JMP_direct_intersegment             = (i_instruction[0][7:0] == 8'b1110_1010);
wire opcode_JMP_indirect_intersegment           = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b101);
wire opcode_RET_within_segment                  = (i_instruction[0][7:0] == 8'b1100_0011);
wire opcode_RET_within_segment_adding_imm_to_SP = (i_instruction[0][7:0] == 8'b1100_0010);
wire opcode_RET_intersegment                    = (i_instruction[0][7:0] == 8'b1100_1011);
wire opcode_RET_intersegment_adding_imm_to_SP   = (i_instruction[0][7:0] == 8'b1100_1010);
wire opcode_JO_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_0000);
wire opcode_JO_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0000);
wire opcode_JNO_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_0001);
wire opcode_JNO_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0001);
wire opcode_JB_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_0010);
wire opcode_JB_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0010);
wire opcode_JNB_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_0011);
wire opcode_JNB_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0011);
wire opcode_JE_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_0100);
wire opcode_JE_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0100);
wire opcode_JNE_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_0101);
wire opcode_JNE_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0101);
wire opcode_JBE_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_0110);
wire opcode_JBE_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0110);
wire opcode_JNBE_8bit_disp                      = (i_instruction[0][7:0] == 8'b0111_0111);
wire opcode_JNBE_full_disp                      = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_0111);
wire opcode_JS_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_1000);
wire opcode_JS_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1000);
wire opcode_JNS_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_1001);
wire opcode_JNS_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1001);
wire opcode_JP_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_1010);
wire opcode_JP_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1010);
wire opcode_JNP_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_1011);
wire opcode_JNP_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1011);
wire opcode_JL_8bit_disp                        = (i_instruction[0][7:0] == 8'b0111_1100);
wire opcode_JL_full_disp                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1100);
wire opcode_JNL_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_1101);
wire opcode_JNL_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1101);
wire opcode_JLE_8bit_disp                       = (i_instruction[0][7:0] == 8'b0111_1110);
wire opcode_JLE_full_disp                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1110);
wire opcode_JNLE_8bit_disp                      = (i_instruction[0][7:0] == 8'b0111_1111);
wire opcode_JNLE_full_disp                      = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1000_1111);
wire opcode_JCXZ                                = (i_instruction[0][7:0] == 8'b1110_0011); // (JCXZ and JECXZ: Address Size Prefix Differentiates JCXZ from JECXZ)
wire opcode_LOOP                                = (i_instruction[0][7:0] == 8'b1110_0010);
wire opcode_LOOPZ                               = (i_instruction[0][7:0] == 8'b1110_0001);
wire opcode_LOOPNZ                              = (i_instruction[0][7:0] == 8'b1110_0000);
wire opcode_SETO                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0000);
wire opcode_SETNO                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0001);
wire opcode_SETB                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0010);
wire opcode_SETNB                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0011);
wire opcode_SETE                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0100);
wire opcode_SETNE                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0101);
wire opcode_SETBE                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0110);
wire opcode_SETNBE                              = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_0111);
wire opcode_SETS                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1000);
wire opcode_SETNS                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1001);
wire opcode_SETP                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1010);
wire opcode_SETNP                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1011);
wire opcode_SETL                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1100);
wire opcode_SETNL                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1101);
wire opcode_SETLE                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1110);
wire opcode_SETNLE                              = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1001_1111);
wire opcode_ENTER                               = (i_instruction[0][7:0] == 8'b1100_1000);
wire opcode_LEAVE                               = (i_instruction[0][7:0] == 8'b1100_1001);
wire opcode_INT_type_3                          = (i_instruction[0][7:0] == 8'b1100_1100);
wire opcode_INT_type_specified                  = (i_instruction[0][7:0] == 8'b1100_1101);
wire opcode_INTO                                = (i_instruction[0][7:0] == 8'b1100_1110);
wire opcode_BOUND                               = (i_instruction[0][7:0] == 8'b0110_0010);
wire opcode_IRET                                = (i_instruction[0][7:0] == 8'b1100_1111);
wire opcode_HLT                                 = (i_instruction[0][7:0] == 8'b1111_0100);
wire opcode_MOV_CR0_CR2_CR3_from_reg            = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0010) & (i_instruction[2][7:6] == 2'b11);
wire opcode_MOV_reg_from_CR0_3                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0000) & (i_instruction[2][7:6] == 2'b11);
wire opcode_MOV_DR0_7_from_reg                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0011) & (i_instruction[2][7:6] == 2'b11);
wire opcode_MOV_reg_from_DR0_7                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0001) & (i_instruction[2][7:6] == 2'b11);
wire opcode_MOV_TR6_7_from_reg                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0110) & (i_instruction[2][7:6] == 2'b11);
wire opcode_MOV_reg_from_TR6_7                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0100) & (i_instruction[2][7:6] == 2'b11);
wire opcode_NOP                                 = (i_instruction[0][7:0] == 8'b1001_0000);
wire opcode_WAIT                                = (i_instruction[0][7:0] == 8'b1001_1011);
wire opcode_processor_extension_escape          = (i_instruction[0][7:3] == 5'b1101_1   );
wire opcode_ARPL                                = (i_instruction[0][7:0] == 8'b0110_0011);
wire opcode_LAR                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0010);
wire opcode_LGDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b010);
wire opcode_LIDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b011);
wire opcode_LLDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b010);
wire opcode_LMSW                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b110);
wire opcode_LSL                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0011);
wire opcode_LTR                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b011);
wire opcode_SGDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b000);
wire opcode_SIDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b001);
wire opcode_SLDT                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b000);
wire opcode_SMSW                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b100);
wire opcode_STR                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b001);
wire opcode_VERR                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b100);
wire opcode_VERW                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b101);

assign o_opcode = {
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
};

endmodule
