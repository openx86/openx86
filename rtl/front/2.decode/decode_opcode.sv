/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_opcode
create at: 2021-12-28 16:56:15
description: decode opcode from instruction
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_opcode #(
    // parameters
) (
    // ports
    input  logic [ 7:0] instruction[0:9],
    // output logic [ 1:0] used_instruction_count
    output logic [0:`info_opcode_len-1] info_opcode
);

// always_comb begin
//     unique casez (instruction[0])
//         8'b1000_100? : info_opcode <= `info_opcode_mov_reg_to_reg_mem;
//         8'b1000_101? : info_opcode <= `info_opcode_mov_reg_mem_to_reg;
//         8'b1100_011? : begin
//             unique casez (instruction[1][5:3])
//                 3'b000 : info_opcode <= `info_opcode_mov_imm_to_reg_mem;
//                 default : info_opcode <= `info_opcode_invalid;
//             endcase
//         end
//         8'b1011_???? : info_opcode <= `info_opcode_mov_imm_to_reg_short;
//         8'b1010_000? : info_opcode <= `info_opcode_mov_mem_to_acc;
//         8'b1010_001? : info_opcode <= `info_opcode_mov_acc_to_mem;
//         8'b1000_1110 : info_opcode <= `info_opcode_mov_reg_mem_to_sreg;
//         8'b1000_1100 : info_opcode <= `info_opcode_mov_sreg_to_reg_mem;

//         8'b0000_1111 : begin
//             unique casez (instruction[1])
//                 8'b1011_111? : info_opcode <= `info_opcode_movsx;
//                 8'b1011_011? : info_opcode <= `info_opcode_movzx;
//                 default : info_opcode <= `info_opcode_invalid;
//             endcase
//         end

//         8'b1111_1111 : begin
//             unique casez (instruction[1][5:3])
//                 3'b110 : info_opcode <= `info_opcode_push_reg_mem;
//                 default : info_opcode <= `info_opcode_invalid;
//             endcase
//         end
//         8'b0101_0??? :  info_opcode <= `info_opcode_push_reg_short;
//         8'b000?_?110 :  info_opcode <= `info_opcode_push_sreg_2;
//         8'b0000_1111 :  begin
//             unique casez (instruction[1])
//                 8'b10??_?000 : info_opcode <= `info_opcode_push_sreg_3;
//                 default : info_opcode <= `info_opcode_invalid;
//             endcase
//         end
//         8'b0110_10?0 :  info_opcode <= `info_opcode_push_imm;
//         8'b0110_0000 :  info_opcode <= `info_opcode_push_a;

//         8'b1000_1111 : begin
//             unique casez (instruction[1][5:3])
//                 3'b000 : info_opcode <= `info_opcode_pop_reg_mem;
//                 default : info_opcode <= `info_opcode_invalid;
//             endcase
//         end
//         8'b0101_1??? :  info_opcode <= `info_opcode_pop_reg_short;
//         8'b000?_?111 :  info_opcode <= `info_opcode_pop_sreg_2;
//         8'b0000_1111 :  begin
//             unique casez (instruction[1])
//                 8'b10??_?001 : info_opcode <= `info_opcode_pop_sreg_3;
//                 default : info_opcode <= `info_opcode_invalid;
//             endcase
//         end
//         8'b0110_0001 :  info_opcode <= `info_opcode_pop_a;

//         8'b0101_0??? :  info_opcode <= `info_opcode_push_reg_short;
//         default : info_opcode <= `info_opcode_invalid;
//     endcase
// end

// wire opcode_invalid                 = 0;
wire opcode_MOV_reg_to_reg_mem                  = (instruction[0][7:1] == 7'b1000_100);
wire opcode_MOV_reg_mem_to_reg                  = (instruction[0][7:1] == 7'b1000_101);
wire opcode_MOV_imm_to_reg_mem                  = (instruction[0][7:1] == 7'b1100_011) & (instruction[1][5:3] == 3'b000);
wire opcode_MOV_imm_to_reg_short                = (instruction[0][7:4] == 4'b1011);
wire opcode_MOV_mem_to_acc                      = (instruction[0][7:1] == 7'b1010_000);
wire opcode_MOV_acc_to_mem                      = (instruction[0][7:1] == 7'b1010_001);
wire opcode_MOV_reg_mem_to_sreg                 = (instruction[0][7:0] == 8'b1000_1110);
wire opcode_MOV_sreg_to_reg_mem                 = (instruction[0][7:0] == 8'b1000_1100);
wire opcode_MOVSX                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:1] == 7'b1011_111);
wire opcode_MOVZX                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:1] == 7'b1011_011);
wire opcode_PUSH_reg_mem                        = (instruction[0][7:0] == 8'b1111_1111) & (instruction[1][5:3] == 3'b110);
wire opcode_PUSH_reg_short                      = (instruction[0][7:3] == 5'b0101_0);
wire opcode_PUSH_sreg_2                         = (instruction[0][7:5] == 3'b000) & (instruction[0][2:0] == 3'b110);
wire opcode_PUSH_sreg_3                         = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:6] == 2'b10) & (instruction[1][5] == 1'b1) & (instruction[1][2:0] == 3'b000);
wire opcode_PUSH_imm                            = (instruction[0][7:2] == 6'b0110_10) & (instruction[0][0] == 1'b0);
wire opcode_PUSH_all                            = (instruction[0][7:0] == 8'b0110_0000);
wire opcode_POP_reg_mem                         = (instruction[0][7:0] == 8'b1000_1111) & (instruction[1][5:3] == 3'b000);
wire opcode_POP_reg_short                       = (instruction[0][7:3] == 5'b0101_1);
wire opcode_POP_sreg_2                          = (instruction[0][7:5] == 3'b000) & (instruction[0][4:3] != 2'b01) & (instruction[0][2:0] == 3'b111) & (instruction[1][5:3] != 3'b110) & (instruction[1][5:3] != 3'b111);
wire opcode_POP_sreg_3                          = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:6] == 2'b10) & (instruction[1][5] == 1'b1) & (instruction[1][2:0] == 3'b001);
wire opcode_POP_all                             = (instruction[0][7:0] == 8'b0110_0001);
wire opcode_XCHG_reg_mem_with_reg               = (instruction[0][7:1] == 7'b1000_011);
wire opcode_XCHG_reg_with_acc_short             = (instruction[0][7:3] == 5'b1001_0) & (instruction[0][2:0] != 3'b000);
wire opcode_IN_port_fixed                       = (instruction[0][7:1] == 7'b1110_010);
wire opcode_IN_port_variable                    = (instruction[0][7:1] == 7'b1110_110);
wire opcode_OUT_port_fixed                      = (instruction[0][7:1] == 7'b1110_011);
wire opcode_OUT_port_variable                   = (instruction[0][7:1] == 7'b1110_111);
wire opcode_LEA_load_ea_to_reg                  = (instruction[0][7:0] == 8'b1000_1101);
wire opcode_LDS_load_ptr_to_DS                  = (instruction[0][7:0] == 8'b1100_0101);
wire opcode_LES_load_ptr_to_ES                  = (instruction[0][7:0] == 8'b1100_0100);
wire opcode_LFS_load_ptr_to_FS                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_0100);
wire opcode_LGS_load_ptr_to_GS                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_0101);
wire opcode_LSS_load_ptr_to_SS                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_0010);
wire opcode_CLC_clear_carry_flag                = (instruction[0][7:0] == 8'b1111_1000);
wire opcode_CLD_clear_direction_flag            = (instruction[0][7:0] == 8'b1111_1100);
wire opcode_CLI_clear_interrupt_enable_flag     = (instruction[0][7:0] == 8'b1111_1010);
wire opcode_CLTS_clear_task_switched_flag       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0110);
wire opcode_CMC_complement_carry_flag           = (instruction[0][7:0] == 8'b1111_0101);
wire opcode_LAHF_load_ah_into_flag              = (instruction[0][7:0] == 8'b1001_1111);
wire opcode_POPF_pop_flags                      = (instruction[0][7:0] == 8'b1001_1101);
wire opcode_PUSHF_push_flags                    = (instruction[0][7:0] == 8'b1001_1100);
wire opcode_SAHF_store_ah_into_flag             = (instruction[0][7:0] == 8'b1001_1110);
wire opcode_STC_set_carry_flag                  = (instruction[0][7:0] == 8'b1111_1001);
wire opcode_STD_set_direction_flag              = (instruction[0][7:0] == 8'b1111_1101);
wire opcode_STI_set_interrupt_enable_flag       = (instruction[0][7:0] == 8'b1111_1011);
// wire opcode_ADD_reg_to_reg                      = (instruction[0][7:2] == 6'b0000_00) & (instruction[1][7:6] == 2'b11);
wire opcode_ADD_reg_to_mem                      = (instruction[0][7:1] == 7'b0000_000);
wire opcode_ADD_mem_to_reg                      = (instruction[0][7:1] == 7'b0000_001);
wire opcode_ADD_imm_to_reg_mem                  = (instruction[0][7:2] == 6'b1000_00) & (instruction[1][5:3] == 3'b000);
wire opcode_ADD_imm_to_acc                      = (instruction[0][7:1] == 7'b0000_010);
// wire opcode_ADC_reg_to_reg                      = (instruction[0][7:2] == 6'b0001_00) & (instruction[1][7:6] == 2'b11);
wire opcode_ADC_reg_to_mem                      = (instruction[0][7:1] == 7'b0001_000);
wire opcode_ADC_mem_to_reg                      = (instruction[0][7:1] == 7'b0001_001);
wire opcode_ADC_imm_to_reg_mem                  = (instruction[0][7:2] == 6'b1000_00) & (instruction[1][5:3] == 3'b010);
wire opcode_ADC_imm_to_acc                      = (instruction[0][7:1] == 7'b0001_010);
wire opcode_INC_reg_mem                         = (instruction[0][7:0] == 8'b1111_1111) & (instruction[1][5:3] == 3'b000);
wire opcode_INC_reg                             = (instruction[0][7:3] == 5'b0100_0);
// wire opcode_SUB_reg_to_reg                      = (instruction[0][7:2] == 6'b0010_10) & (instruction[1][7:6] == 2'b11);
wire opcode_SUB_reg_to_mem                      = (instruction[0][7:1] == 7'b0010_100);
wire opcode_SUB_mem_to_reg                      = (instruction[0][7:1] == 7'b0010_101);
wire opcode_SUB_imm_to_reg_mem                  = (instruction[0][7:2] == 6'b1000_00) & (instruction[1][5:3] == 3'b101);
wire opcode_SUB_imm_to_acc                      = (instruction[0][7:1] == 7'b0010_110);
// wire opcode_SBB_reg_to_reg                      = (instruction[0][7:2] == 6'b0001_10) & (instruction[1][7:6] == 2'b11);
wire opcode_SBB_reg_to_mem                      = (instruction[0][7:1] == 7'b0001_100);
wire opcode_SBB_mem_to_reg                      = (instruction[0][7:1] == 7'b0001_101);
wire opcode_SBB_imm_to_reg_mem                  = (instruction[0][7:2] == 6'b1000_00) & (instruction[1][5:3] == 3'b011);
wire opcode_SBB_imm_to_acc                      = (instruction[0][7:1] == 7'b0001_110);
wire opcode_DEC_reg_mem                         = (instruction[0][7:0] == 8'b1111_1111) & (instruction[1][5:3] == 3'b001);
wire opcode_DEC_reg                             = (instruction[0][7:3] == 5'b0100_1);
wire opcode_CMP_reg_with_reg                    = (instruction[0][7:2] == 6'b0011_10) & (instruction[1][7:6] == 2'b11);
wire opcode_CMP_mem_with_reg                    = (instruction[0][7:1] == 7'b0011_100);
wire opcode_CMP_reg_with_mem                    = (instruction[0][7:1] == 7'b0011_101);
wire opcode_CMP_imm_with_reg_mem                = (instruction[0][7:2] == 6'b1000_00) & (instruction[1][5:3] == 3'b111);
wire opcode_CMP_imm_with_acc                    = (instruction[0][7:1] == 7'b0011_110);
wire opcode_NEG_change_sign                     = (instruction[0][7:1] == 7'b1111_011) & (instruction[1][5:3] == 3'b011);
wire opcode_AAA                                 = (instruction[0][7:0] == 8'b0011_0111);
wire opcode_AAS                                 = (instruction[0][7:0] == 8'b0011_1111);
wire opcode_DAA                                 = (instruction[0][7:0] == 8'b0010_0111);
wire opcode_DAS                                 = (instruction[0][7:0] == 8'b0010_1111);
wire opcode_MUL_acc_with_reg_mem                = (instruction[0][7:1] == 7'b1111_011) & (instruction[1][5:3] == 3'b100);
wire opcode_IMUL_acc_with_reg_mem               = (instruction[0][7:1] == 7'b1111_011) & (instruction[1][5:3] == 3'b101);
wire opcode_IMUL_reg_with_reg_mem               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1010_1111);
wire opcode_IMUL_reg_mem_with_imm_to_mem        = (instruction[0][7:2] == 6'b0110_10) & (instruction[0][0] == 1'b1);
wire opcode_DIV_acc_by_reg_mem                  = (instruction[0][7:1] == 7'b1111_011) & (instruction[1][5:3] == 3'b110);
wire opcode_IDIV_acc_by_reg_mem                 = (instruction[0][7:1] == 7'b1111_011) & (instruction[1][5:3] == 3'b111);
wire opcode_AAD                                 = (instruction[0][7:0] == 8'b1101_0101) & (instruction[1][7:0] == 8'b0000_1010);
wire opcode_AAM                                 = (instruction[0][7:0] == 8'b1101_0100) & (instruction[1][7:0] == 8'b0000_1010);
wire opcode_CBW                                 = (instruction[0][7:0] == 8'b1001_1000);
wire opcode_CWD                                 = (instruction[0][7:0] == 8'b1001_1001);
wire opcode_ROL_reg_mem_by_1                    = (instruction[0][7:1] == 7'b1101_000) & (instruction[1][5:3] == 3'b000);
wire opcode_ROL_reg_mem_by_CL                   = (instruction[0][7:1] == 7'b1101_001) & (instruction[1][5:3] == 3'b000);
wire opcode_ROL_reg_mem_by_imm                  = (instruction[0][7:1] == 7'b1100_000) & (instruction[1][5:3] == 3'b000);
wire opcode_ROR_reg_mem_by_1                    = (instruction[0][7:1] == 7'b1101_000) & (instruction[1][5:3] == 3'b001);
wire opcode_ROR_reg_mem_by_CL                   = (instruction[0][7:1] == 7'b1101_001) & (instruction[1][5:3] == 3'b001);
wire opcode_ROR_reg_mem_by_imm                  = (instruction[0][7:1] == 7'b1100_000) & (instruction[1][5:3] == 3'b001);
wire opcode_SHL_reg_mem_by_1                    = (instruction[0][7:1] == 7'b1101_000) & (instruction[1][5:3] == 3'b100);
wire opcode_SHL_reg_mem_by_CL                   = (instruction[0][7:1] == 7'b1101_001) & (instruction[1][5:3] == 3'b100);
wire opcode_SHL_reg_mem_by_imm                  = (instruction[0][7:1] == 7'b1100_000) & (instruction[1][5:3] == 3'b100);
wire opcode_SAR_reg_mem_by_1                    = (instruction[0][7:1] == 7'b1101_000) & (instruction[1][5:3] == 3'b111);
wire opcode_SAR_reg_mem_by_CL                   = (instruction[0][7:1] == 7'b1101_001) & (instruction[1][5:3] == 3'b111);
wire opcode_SAR_reg_mem_by_imm                  = (instruction[0][7:1] == 7'b1100_000) & (instruction[1][5:3] == 3'b111);
wire opcode_SHR_reg_mem_by_1                    = (instruction[0][7:1] == 7'b1101_000) & (instruction[1][5:3] == 3'b101);
wire opcode_SHR_reg_mem_by_CL                   = (instruction[0][7:1] == 7'b1101_001) & (instruction[1][5:3] == 3'b101);
wire opcode_SHR_reg_mem_by_imm                  = (instruction[0][7:1] == 7'b1100_000) & (instruction[1][5:3] == 3'b101);
wire opcode_RCL_reg_mem_by_1                    = (instruction[0][7:1] == 7'b1101_000) & (instruction[1][5:3] == 3'b010);
wire opcode_RCL_reg_mem_by_CL                   = (instruction[0][7:1] == 7'b1101_001) & (instruction[1][5:3] == 3'b010);
wire opcode_RCL_reg_mem_by_imm                  = (instruction[0][7:1] == 7'b1100_000) & (instruction[1][5:3] == 3'b010);
wire opcode_RCR_reg_mem_by_1                    = (instruction[0][7:1] == 7'b1101_000) & (instruction[1][5:3] == 3'b011);
wire opcode_RCR_reg_mem_by_CL                   = (instruction[0][7:1] == 7'b1101_001) & (instruction[1][5:3] == 3'b011);
wire opcode_RCR_reg_mem_by_imm                  = (instruction[0][7:1] == 7'b1100_000) & (instruction[1][5:3] == 3'b011);
wire opcode_SHLD_reg_mem_by_imm                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1010_0100);
wire opcode_SHLD_reg_mem_by_CL                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1010_0101);
wire opcode_SHRD_reg_mem_by_imm                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1010_1100);
wire opcode_SHRD_reg_mem_by_CL                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1010_1101);
// wire opcode_AND_reg_to_reg                      = (instruction[0][7:2] == 6'b0010_00) & (instruction[1][7:6] == 2'b11);
wire opcode_AND_reg_to_mem                      = (instruction[0][7:1] == 7'b0010_000);
wire opcode_AND_mem_to_reg                      = (instruction[0][7:1] == 7'b0010_001);
wire opcode_AND_imm_to_reg_mem                  = (instruction[0][7:2] == 6'b1000_00) & (instruction[1][5:3] == 3'b100);
wire opcode_AND_imm_to_acc                      = (instruction[0][7:1] == 7'b0010_010);
wire opcode_TEST_reg_mem_and_reg                = (instruction[0][7:1] == 7'b1000_010);
wire opcode_TEST_imm_to_reg_mem                 = (instruction[0][7:1] == 7'b1111_011) & (instruction[1][5:3] == 3'b000);
wire opcode_TEST_imm_to_acc                     = (instruction[0][7:1] == 7'b1010_100);
// wire opcode_OR_reg_to_reg                       = (instruction[0][7:2] == 6'b0000_10) & (instruction[1][7:6] == 2'b11);
wire opcode_OR_reg_to_mem                       = (instruction[0][7:1] == 7'b0000_100);
wire opcode_OR_mem_to_reg                       = (instruction[0][7:1] == 7'b0000_101);
wire opcode_OR_imm_to_reg_mem                   = (instruction[0][7:2] == 6'b1000_00) & (instruction[1][5:3] == 3'b001);
wire opcode_OR_imm_to_acc                       = (instruction[0][7:1] == 7'b0000_110);
// wire opcode_XOR_reg_to_reg                      = (instruction[0][7:2] == 6'b0011_00) & (instruction[1][7:6] == 2'b11);
wire opcode_XOR_reg_to_mem                      = (instruction[0][7:1] == 7'b0011_000);
wire opcode_XOR_mem_to_reg                      = (instruction[0][7:1] == 7'b0011_001);
wire opcode_XOR_imm_to_reg_mem                  = (instruction[0][7:2] == 6'b1000_00) & (instruction[1][5:3] == 3'b110);
wire opcode_XOR_imm_to_acc                      = (instruction[0][7:1] == 7'b0011_010);
wire opcode_NOT                                 = (instruction[0][7:1] == 7'b1111_011) & (instruction[1][5:3] == 3'b010);
wire opcode_CMPS                                = (instruction[0][7:1] == 7'b1010_011);
wire opcode_INS                                 = (instruction[0][7:1] == 7'b0110_110);
wire opcode_LODS                                = (instruction[0][7:1] == 7'b1010_110);
wire opcode_MOVS                                = (instruction[0][7:1] == 7'b1010_010);
wire opcode_OUTS                                = (instruction[0][7:1] == 7'b0110_111);
wire opcode_SCAS                                = (instruction[0][7:1] == 7'b1010_111);
wire opcode_STOS                                = (instruction[0][7:1] == 7'b1010_101);
wire opcode_XLAT                                = (instruction[0][7:0] == 8'b1101_0111);
wire opcode_REPE                                = (instruction[0][7:0] == 8'b1111_0011);
wire opcode_REPNE                               = (instruction[0][7:0] == 8'b1111_0010);
wire opcode_BSF                                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_1100);
wire opcode_BSR                                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_1101);
wire opcode_BT_reg_mem_with_imm                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_1010) & (instruction[2][5:3] == 3'b100);;
wire opcode_BT_reg_mem_with_reg                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1010_0011);
wire opcode_BTC_reg_mem_with_imm                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_1010) & (instruction[2][5:3] == 3'b111);;
wire opcode_BTC_reg_mem_with_reg                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_1011);
wire opcode_BTR_reg_mem_with_imm                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_1010) & (instruction[2][5:3] == 3'b110);;
wire opcode_BTR_reg_mem_with_reg                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_0011);
wire opcode_BTS_reg_mem_with_imm                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1011_1010) & (instruction[2][5:3] == 3'b101);;
wire opcode_BTS_reg_mem_with_reg                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1010_1011);
wire opcode_CALL_direct_within_segment          = (instruction[0][7:0] == 8'b1110_1000);
wire opcode_CALL_indirect_within_segment        = (instruction[0][7:1] == 8'b1111_1111) & (instruction[1][5:3] == 3'b010);
wire opcode_CALL_direct_intersegment            = (instruction[0][7:0] == 8'b1001_1010);
wire opcode_CALL_indirect_intersegment          = (instruction[0][7:0] == 8'b1111_1111) & (instruction[1][5:3] == 3'b011);
wire opcode_JMP_short                           = (instruction[0][7:0] == 8'b1110_1011);
wire opcode_JMP_direct_within_segment           = (instruction[0][7:0] == 8'b1110_1001);
wire opcode_JMP_indirect_within_segment         = (instruction[0][7:0] == 8'b1111_1111) & (instruction[1][5:3] == 3'b100);
wire opcode_JMP_direct_intersegment             = (instruction[0][7:0] == 8'b1110_1010);
wire opcode_JMP_indirect_intersegment           = (instruction[0][7:0] == 8'b1111_1111) & (instruction[1][5:3] == 3'b101);
wire opcode_RET_within_segment                  = (instruction[0][7:0] == 8'b1100_0011);
wire opcode_RET_within_segment_adding_imm_to_SP = (instruction[0][7:0] == 8'b1100_0010);
wire opcode_RET_intersegment                    = (instruction[0][7:0] == 8'b1100_1011);
wire opcode_RET_intersegment_adding_imm_to_SP   = (instruction[0][7:0] == 8'b1100_1010);
wire opcode_JO_8bit_disp                        = (instruction[0][7:0] == 8'b0111_0000);
wire opcode_JO_full_disp                        = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0000);
wire opcode_JNO_8bit_disp                       = (instruction[0][7:0] == 8'b0111_0001);
wire opcode_JNO_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0001);
wire opcode_JB_8bit_disp                        = (instruction[0][7:0] == 8'b0111_0010);
wire opcode_JB_full_disp                        = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0010);
wire opcode_JNB_8bit_disp                       = (instruction[0][7:0] == 8'b0111_0011);
wire opcode_JNB_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0011);
wire opcode_JE_8bit_disp                        = (instruction[0][7:0] == 8'b0111_0100);
wire opcode_JE_full_disp                        = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0100);
wire opcode_JNE_8bit_disp                       = (instruction[0][7:0] == 8'b0111_0101);
wire opcode_JNE_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0101);
wire opcode_JBE_8bit_disp                       = (instruction[0][7:0] == 8'b0111_0110);
wire opcode_JBE_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0110);
wire opcode_JNBE_8bit_disp                      = (instruction[0][7:0] == 8'b0111_0111);
wire opcode_JNBE_full_disp                      = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_0111);
wire opcode_JS_8bit_disp                        = (instruction[0][7:0] == 8'b0111_1000);
wire opcode_JS_full_disp                        = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1000);
wire opcode_JNS_8bit_disp                       = (instruction[0][7:0] == 8'b0111_1001);
wire opcode_JNS_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1001);
wire opcode_JP_8bit_disp                        = (instruction[0][7:0] == 8'b0111_1010);
wire opcode_JP_full_disp                        = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1010);
wire opcode_JNP_8bit_disp                       = (instruction[0][7:0] == 8'b0111_1011);
wire opcode_JNP_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1011);
wire opcode_JL_8bit_disp                        = (instruction[0][7:0] == 8'b0111_1100);
wire opcode_JL_full_disp                        = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1100);
wire opcode_JNL_8bit_disp                       = (instruction[0][7:0] == 8'b0111_1101);
wire opcode_JNL_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1101);
wire opcode_JLE_8bit_disp                       = (instruction[0][7:0] == 8'b0111_1110);
wire opcode_JLE_full_disp                       = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1110);
wire opcode_JNLE_8bit_disp                      = (instruction[0][7:0] == 8'b0111_1111);
wire opcode_JNLE_full_disp                      = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1000_1111);
wire opcode_JCXZ                                = (instruction[0][7:0] == 8'b1110_0011); // (JCXZ and JECXZ: Address Size Prefix Differentiates JCXZ from JECXZ)
wire opcode_LOOP                                = (instruction[0][7:0] == 8'b1110_0010);
wire opcode_LOOPZ                               = (instruction[0][7:0] == 8'b1110_0001);
wire opcode_LOOPNZ                              = (instruction[0][7:0] == 8'b1110_0000);
wire opcode_SETO                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0000);
wire opcode_SETNO                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0001);
wire opcode_SETB                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0010);
wire opcode_SETNB                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0011);
wire opcode_SETE                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0100);
wire opcode_SETNE                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0101);
wire opcode_SETBE                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0110);
wire opcode_SETNBE                              = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_0111);
wire opcode_SETS                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1000);
wire opcode_SETNS                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1001);
wire opcode_SETP                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1010);
wire opcode_SETNP                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1011);
wire opcode_SETL                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1100);
wire opcode_SETNL                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1101);
wire opcode_SETLE                               = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1110);
wire opcode_SETNLE                              = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b1001_1111);
wire opcode_ENTER                               = (instruction[0][7:0] == 8'b1100_1000);
wire opcode_LEAVE                               = (instruction[0][7:0] == 8'b1100_1001);
wire opcode_INT_type_3                          = (instruction[0][7:0] == 8'b1100_1100);
wire opcode_INT_type_specified                  = (instruction[0][7:0] == 8'b1100_1101);
wire opcode_INTO                                = (instruction[0][7:0] == 8'b1100_1110);
wire opcode_BOUND                               = (instruction[0][7:0] == 8'b0110_0010);
wire opcode_IRET                                = (instruction[0][7:0] == 8'b1100_1111);
wire opcode_HLT                                 = (instruction[0][7:0] == 8'b1111_0100);
wire opcode_MOV_CR0_CR2_CR3_from_reg            = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0010_0010) & (instruction[2][7:6] == 2'b11);
wire opcode_MOV_reg_from_CR0_3                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0010_0000) & (instruction[2][7:6] == 2'b11);
wire opcode_MOV_DR0_7_from_reg                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0010_0011) & (instruction[2][7:6] == 2'b11);
wire opcode_MOV_reg_from_DR0_7                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0010_0001) & (instruction[2][7:6] == 2'b11);
wire opcode_MOV_TR6_7_from_reg                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0010_0110) & (instruction[2][7:6] == 2'b11);
wire opcode_MOV_reg_from_TR6_7                  = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0010_0100) & (instruction[2][7:6] == 2'b11);
wire opcode_NOP                                 = (instruction[0][7:0] == 8'b1001_0000);
wire opcode_WAIT                                = (instruction[0][7:0] == 8'b1001_1011);
wire opcode_processor_extension_escape          = (instruction[0][7:3] == 5'b1101_1);
wire opcode_prefix_address_size                 = (instruction[0][7:0] == 8'b0110_0111);
wire opcode_prefix_bus_lock                     = (instruction[0][7:0] == 8'b1111_0000);
wire opcode_prefix_operand_size                 = (instruction[0][7:0] == 8'b0110_0110);
wire opcode_prefix_segment_override_CS          = (instruction[0][7:0] == 8'b0010_1110);
wire opcode_prefix_segment_override_DS          = (instruction[0][7:0] == 8'b0011_1110);
wire opcode_prefix_segment_override_ES          = (instruction[0][7:0] == 8'b0010_0110);
wire opcode_prefix_segment_override_FS          = (instruction[0][7:0] == 8'b0110_0100);
wire opcode_prefix_segment_override_GS          = (instruction[0][7:0] == 8'b0110_0101);
wire opcode_prefix_segment_override_SS          = (instruction[0][7:0] == 8'b0011_0110);
wire opcode_ARPL                                = (instruction[0][7:0] == 8'b0110_0011);
wire opcode_LAR                                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0010);
wire opcode_LGDT                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0001) & (instruction[2][5:3] == 3'b010);
wire opcode_LIDT                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0001) & (instruction[2][5:3] == 3'b011);
wire opcode_LLDT                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0000) & (instruction[2][5:3] == 3'b010);
wire opcode_LMSW                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0001) & (instruction[2][5:3] == 3'b110);
wire opcode_LSL                                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0011);
wire opcode_LTR                                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0000) & (instruction[2][5:3] == 3'b011);
wire opcode_SGDT                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0001) & (instruction[2][5:3] == 3'b000);
wire opcode_SIDT                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0001) & (instruction[2][5:3] == 3'b001);
wire opcode_SLDT                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0000) & (instruction[2][5:3] == 3'b000);
wire opcode_SMSW                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0001) & (instruction[2][5:3] == 3'b100);
wire opcode_STR                                 = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0000) & (instruction[2][5:3] == 3'b001);
wire opcode_VERR                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0000) & (instruction[2][5:3] == 3'b100);
wire opcode_VERW                                = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:0] == 8'b0000_0000) & (instruction[2][5:3] == 3'b101);


// assign info_opcode = {
// };

// logic [ 1:0] mod;
// logic [ 2:0] rm;
// logic        w;
// logic [ 1:0] segment;
// logic [24:0] base;
// logic [24:0] index;
// logic [24:0] scale;
// logic [ 3:0] imm;
// logic [ 7:0] instruction_mod_rm;
// logic        w;
// logic [`info_bit_width_len-1:0] info_bit_width = `info_bit_width_16;
// logic [`info_reg_seg_len-1:0] info_segment_reg;
// logic [`info_reg_gpr_len-1:0] info_base_reg;
// logic [`info_reg_gpr_len-1:0] info_index_reg;
// logic [`info_displacement_len-1:0] info_displacement;
// logic        sib_is_present;
// decode_mod_rm decode_mod_rm_inst (
//     // input
//     .instruction ( instruction_mod_rm ) ,
//     .w ( w ) ,
//     .info_bit_width ( info_bit_width ),
//     // output
//     .info_segment_reg ( info_segment_reg ),
//     .info_base_reg ( info_base_reg ),
//     .info_index_reg ( info_index_reg ),
//     .info_displacement ( info_displacement ),
//     .sib_is_present ( sib_is_present )
// );

// always_comb begin
//     unique casez (instruction[0])
//         8'b1000_100? : begin
//             info_opcode <= `info_opcode_mov_reg_to_reg_mem;
//             w <= instruction[0][0];
//             instruction_mod_rm <= instruction[0];
//         end
//         8'b1000_101? : begin
//             info_opcode <= `info_opcode_mov_reg_mem_to_reg;
//             w <= instruction[0][0];
//         end
//         8'b1100_011? : begin
//             unique casez (instruction[1][5:3])
//                 3'b000 : begin
//                     info_opcode <= `info_opcode_mov_imm_to_reg_mem;
//                     w <= instruction[0][0];
//                 end
//                 default: begin
//                     info_opcode <= `info_opcode_invalid;
//                 end
//             endcase
//         end
//         default: begin
//             info_opcode <= `info_opcode_invalid;
//         end
//     endcase
// end

// logic [7:0] instr_slice [4] = {
//     instruction[31:24],
//     instruction[23:16],
//     instruction[15: 8],
//     instruction[ 7: 0]
// };

// localparam
// i386_op_mov_r_to_rm = 3'b001 << 2,
// i386_op_mov_rm_to_r = 3'b001 << 1,
// i386_op_mov_imm_to_rm = 3'b001 << 0,
// i386_op_invalid = 3'b000
// ;

// always_comb begin
//     unique casez (op_info)
//         i386_op_mov_r_to_rm : begin
//             mod <= instr_slice[1][7:5];
//             rm <= instr_slice[1][2:0];
//         end
//         i386_op_mov_rm_to_r : begin
//             mod <= instr_slice[1][7:5];
//             rm <= instr_slice[1][2:0];
//         end
//         i386_op_mov_imm_to_rm : begin
//             mod <= instr_slice[1][7:5];
//             rm <= instr_slice[1][2:0];
//         end
//         default: begin
//             default_case
//         end
//     endcase
// end

endmodule