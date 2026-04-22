// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : stage_2_dec_x86_opcode_186.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_2_dec_x86_opcode_186 module
// ============================================================================

module stage_2_dec_x86_opcode_186 (
    output logic                o_opcode_x86_AAA_ASCII_adjust_after_add,
    output logic                o_opcode_x86_AAD_ASCII_AX_before_div,
    output logic                o_opcode_x86_AAM_ASCII_AX_after_mul,
    output logic                o_opcode_x86_AAS_ASCII_adjust_after_sub,
    output logic                o_opcode_x86_ADC_reg_to_reg_mem,
    output logic                o_opcode_x86_ADC_reg_mem_to_reg,
    output logic                o_opcode_x86_ADC_imm_to_reg_mem,
    output logic                o_opcode_x86_ADC_imm_to_acc,
    output logic                o_opcode_x86_ADD_reg_to_reg_mem,
    output logic                o_opcode_x86_ADD_reg_mem_to_reg,
    output logic                o_opcode_x86_ADD_imm_to_reg_mem,
    output logic                o_opcode_x86_ADD_imm_to_acc,
    output logic                o_opcode_x86_AND_reg_to_reg_mem,
    output logic                o_opcode_x86_AND_reg_mem_to_reg,
    output logic                o_opcode_x86_AND_imm_to_reg_mem,
    output logic                o_opcode_x86_AND_imm_to_acc,
    output logic                o_opcode_x86_BOUND_check_array_against_bounds,
    output logic                o_opcode_x86_CALL_in_same_segment_direct,
    output logic                o_opcode_x86_CALL_in_same_segment_indirect,
    output logic                o_opcode_x86_CALL_in_other_segment_direct,
    output logic                o_opcode_x86_CALL_in_other_segment_indirect,
    output logic                o_opcode_x86_CBW_convert_byte_to_word,
    output logic                o_opcode_x86_CLC_clear_carry_flag,
    output logic                o_opcode_x86_CLD_clear_direction_flag,
    output logic                o_opcode_x86_CLI_clear_interrupt_enable_flag,
    output logic                o_opcode_x86_CMC_complement_carry_flag,
    output logic                o_opcode_x86_CMP_mem_with_reg,
    output logic                o_opcode_x86_CMP_reg_with_mem,
    output logic                o_opcode_x86_CMP_imm_with_reg_mem,
    output logic                o_opcode_x86_CMP_imm_with_acc,
    output logic                o_opcode_x86_CMPS_compare_string_operands,
    output logic                o_opcode_x86_CWD_convert_word_to_double,
    output logic                o_opcode_x86_DAA_decimal_adjust_AL_after_add,
    output logic                o_opcode_x86_DAS_decimal_adjust_AL_after_sub,
    output logic                o_opcode_x86_DEC_reg_mem,
    output logic                o_opcode_x86_DEC_reg,
    output logic                o_opcode_x86_DIV_acc_by_reg_mem,
    output logic                o_opcode_x86_HLT_halt,
    output logic                o_opcode_x86_IDIV_acc_by_reg_mem,
    output logic                o_opcode_x86_IMUL_acc_with_reg_mem,
    output logic                o_opcode_x86_IMUL_reg_mem_with_imm_to_reg,
    output logic                o_opcode_x86_IN_port_fixed,
    output logic                o_opcode_x86_IN_port_variable,
    output logic                o_opcode_x86_INC_reg_mem,
    output logic                o_opcode_x86_INC_reg,
    output logic                o_opcode_x86_INS_input_from_DX_port,
    output logic                o_opcode_x86_INT_interrupt_type_n,
    output logic                o_opcode_x86_INT_interrupt_type_3,
    output logic                o_opcode_x86_INT_interrupt_type_4,
    output logic                o_opcode_x86_IRET_interrupt_return,
    output logic                o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp,
    output logic                o_opcode_x86_JCXZ_jump_on_CX_zero,
    output logic                o_opcode_x86_JMP_to_same_segment_short,
    output logic                o_opcode_x86_JMP_to_same_segment_direct,
    output logic                o_opcode_x86_JMP_to_same_segment_indirect,
    output logic                o_opcode_x86_JMP_to_other_segment_direct,
    output logic                o_opcode_x86_JMP_to_other_segment_indirect,
    output logic                o_opcode_x86_LAHF_load_FLAG_into_AH,
    output logic                o_opcode_x86_LDS_load_pointer_to_DS,
    output logic                o_opcode_x86_LEA_load_effective_adddress_to_reg,
    output logic                o_opcode_x86_LEAVE_high_level_procedure_exit,
    output logic                o_opcode_x86_LES_load_pointer_to_ES,
    output logic                o_opcode_x86_LODS_load_string_operand,
    output logic                o_opcode_x86_LOOP_count,
    output logic                o_opcode_x86_LOOPZ_count_while_zero,
    output logic                o_opcode_x86_LOOPNZ_count_while_not_zero,
    output logic                o_opcode_x86_MOV_reg_to_reg_mem,
    output logic                o_opcode_x86_MOV_reg_mem_to_reg,
    output logic                o_opcode_x86_MOV_imm_to_reg_mem,
    output logic                o_opcode_x86_MOV_imm_to_reg,
    output logic                o_opcode_x86_MOV_mem_to_acc,
    output logic                o_opcode_x86_MOV_acc_to_mem,
    output logic                o_opcode_x86_MOV_reg_mem_to_sreg,
    output logic                o_opcode_x86_MOV_sreg_to_reg_mem,
    output logic                o_opcode_x86_MOVS_move_data_from_string_to_string,
    output logic                o_opcode_x86_MUL_acc_with_reg_mem,
    output logic                o_opcode_x86_NEG_two_s_complement_negation,
    output logic                o_opcode_x86_NOP_no_operation,
    output logic                o_opcode_x86_NOT_one_s_complement_negation,
    output logic                o_opcode_x86_OR_reg_to_reg_mem,
    output logic                o_opcode_x86_OR_reg_mem_to_reg,
    output logic                o_opcode_x86_OR_imm_to_reg_mem,
    output logic                o_opcode_x86_OR_imm_to_acc,
    output logic                o_opcode_x86_OUT_port_fixed,
    output logic                o_opcode_x86_OUT_port_variable,
    output logic                o_opcode_x86_OUTS_output_string,
    output logic                o_opcode_x86_POP_reg_mem,
    output logic                o_opcode_x86_POP_reg,
    output logic                o_opcode_x86_POP_sreg_2,
    output logic                o_opcode_x86_POPA_pop_all_general_registers,
    output logic                o_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS,
    output logic                o_opcode_x86_PUSH_reg_mem,
    output logic                o_opcode_x86_PUSH_reg,
    output logic                o_opcode_x86_PUSH_sreg_2,
    output logic                o_opcode_x86_PUSH_imm,
    output logic                o_opcode_x86_PUSH_all_general_registers,
    output logic                o_opcode_x86_PUSHF_push_flags_onto_stack,
    output logic                o_opcode_x86_RCL_reg_mem_by_1,
    output logic                o_opcode_x86_RCL_reg_mem_by_CL,
    output logic                o_opcode_x86_RCL_reg_mem_by_imm,
    output logic                o_opcode_x86_RCR_reg_mem_by_1,
    output logic                o_opcode_x86_RCR_reg_mem_by_CL,
    output logic                o_opcode_x86_RCR_reg_mem_by_imm,
    output logic                o_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument,
    output logic                o_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP,
    output logic                o_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument,
    output logic                o_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP,
    output logic                o_opcode_x86_ROL_reg_mem_by_1,
    output logic                o_opcode_x86_ROL_reg_mem_by_CL,
    output logic                o_opcode_x86_ROL_reg_mem_by_imm,
    output logic                o_opcode_x86_ROR_reg_mem_by_1,
    output logic                o_opcode_x86_ROR_reg_mem_by_CL,
    output logic                o_opcode_x86_ROR_reg_mem_by_imm,
    output logic                o_opcode_x86_SAHF_store_AH_into_flags,
    output logic                o_opcode_x86_SAR_reg_mem_by_1,
    output logic                o_opcode_x86_SAR_reg_mem_by_CL,
    output logic                o_opcode_x86_SAR_reg_mem_by_imm,
    output logic                o_opcode_x86_SBB_reg_to_reg_mem,
    output logic                o_opcode_x86_SBB_reg_mem_to_reg,
    output logic                o_opcode_x86_SBB_imm_to_reg_mem,
    output logic                o_opcode_x86_SBB_imm_to_acc,
    output logic                o_opcode_x86_SCAS_scan_string,
    output logic                o_opcode_x86_SHL_reg_mem_by_1,
    output logic                o_opcode_x86_SHL_reg_mem_by_CL,
    output logic                o_opcode_x86_SHL_reg_mem_by_imm,
    output logic                o_opcode_x86_SHR_reg_mem_by_1,
    output logic                o_opcode_x86_SHR_reg_mem_by_CL,
    output logic                o_opcode_x86_SHR_reg_mem_by_imm,
    output logic                o_opcode_x86_STC_set_carry_flag,
    output logic                o_opcode_x86_STD_set_direction_flag,
    output logic                o_opcode_x86_STI_set_interrupt_enable_flag,
    output logic                o_opcode_x86_STOS_store_string_data,
    output logic                o_opcode_x86_SUB_reg_to_reg_mem,
    output logic                o_opcode_x86_SUB_reg_mem_to_reg,
    output logic                o_opcode_x86_SUB_imm_to_reg_mem,
    output logic                o_opcode_x86_SUB_imm_to_acc,
    output logic                o_opcode_x86_TEST_reg_mem_and_reg,
    output logic                o_opcode_x86_TEST_imm_and_reg_mem,
    output logic                o_opcode_x86_TEST_imm_and_acc,
    output logic                o_opcode_x86_WAIT_wait,
    output logic                o_opcode_x86_XCHG_reg_mem_with_reg,
    output logic                o_opcode_x86_XCHG_reg_with_acc_short,
    output logic                o_opcode_x86_XLAT_table_look_up_translation,
    output logic                o_opcode_x86_XOR_reg_to_reg_mem,
    output logic                o_opcode_x86_XOR_reg_mem_to_reg,
    output logic                o_opcode_x86_XOR_imm_to_reg_mem,
    output logic                o_opcode_x86_XOR_imm_to_acc,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

// 8086 base + 80186 instructions

assign o_opcode_x86_AAA_ASCII_adjust_after_add     = (i_instruction[0][7: 0] == 8'b0011_0111);
assign o_opcode_x86_AAD_ASCII_AX_before_div        = (i_instruction[0][7: 0] == 8'b1101_0101) & (i_instruction[1][7: 0] == 8'b0000_1010);
assign o_opcode_x86_AAM_ASCII_AX_after_mul         = (i_instruction[0][7: 0] == 8'b1101_0100) & (i_instruction[1][7: 0] == 8'b0000_1010);
assign o_opcode_x86_AAS_ASCII_adjust_after_sub     = (i_instruction[0][7: 0] == 8'b0011_1111);

assign o_opcode_x86_ADC_reg_to_reg_mem             = (i_instruction[0][7: 1] == 7'b0001_000);
assign o_opcode_x86_ADC_reg_mem_to_reg             = (i_instruction[0][7: 1] == 7'b0001_001);
assign o_opcode_x86_ADC_imm_to_reg_mem            = (i_instruction[0][7: 2] == 6'b1000_00) & (i_instruction[1][5: 3] == 3'b010);
assign o_opcode_x86_ADC_imm_to_acc                 = (i_instruction[0][7: 1] == 7'b0001_010);

assign o_opcode_x86_ADD_reg_to_reg_mem             = (i_instruction[0][7: 1] == 7'b0000_000);
assign o_opcode_x86_ADD_reg_mem_to_reg             = (i_instruction[0][7: 1] == 7'b0000_001);
assign o_opcode_x86_ADD_imm_to_reg_mem            = (i_instruction[0][7: 2] == 6'b1000_00) & (i_instruction[1][5: 3] == 3'b000);
assign o_opcode_x86_ADD_imm_to_acc                 = (i_instruction[0][7: 1] == 7'b0000_010);

assign o_opcode_x86_AND_reg_to_reg_mem             = (i_instruction[0][7: 1] == 7'b0010_000);
assign o_opcode_x86_AND_reg_mem_to_reg             = (i_instruction[0][7: 1] == 7'b0010_001);
assign o_opcode_x86_AND_imm_to_reg_mem            = (i_instruction[0][7: 2] == 6'b1000_00) & (i_instruction[1][5: 3] == 3'b100);
assign o_opcode_x86_AND_imm_to_acc                 = (i_instruction[0][7: 1] == 7'b0010_010);

assign o_opcode_x86_BOUND_check_array_against_bounds = (i_instruction[0][7: 0] == 8'b0110_0010);

assign o_opcode_x86_CALL_in_same_segment_direct    = (i_instruction[0][7: 0] == 8'b1110_1000);
assign o_opcode_x86_CALL_in_same_segment_indirect   = (i_instruction[0][7: 0] == 8'b1111_1111) & (i_instruction[1][5: 3] == 3'b010);
assign o_opcode_x86_CALL_in_other_segment_direct   = (i_instruction[0][7: 0] == 8'b1001_1010);
assign o_opcode_x86_CALL_in_other_segment_indirect  = (i_instruction[0][7: 0] == 8'b1111_1111) & (i_instruction[1][5: 3] == 3'b011);

assign o_opcode_x86_CBW_convert_byte_to_word        = (i_instruction[0][7: 0] == 8'b1001_1000);

assign o_opcode_x86_CLC_clear_carry_flag            = (i_instruction[0][7: 0] == 8'b1111_1000);
assign o_opcode_x86_CLD_clear_direction_flag        = (i_instruction[0][7: 0] == 8'b1111_1100);
assign o_opcode_x86_CLI_clear_interrupt_enable_flag = (i_instruction[0][7: 0] == 8'b1111_1010);
assign o_opcode_x86_CMC_complement_carry_flag       = (i_instruction[0][7: 0] == 8'b1111_0101);

assign o_opcode_x86_CMP_mem_with_reg                = (i_instruction[0][7: 1] == 7'b0011_100);
assign o_opcode_x86_CMP_reg_with_mem                = (i_instruction[0][7: 1] == 7'b0011_101);
assign o_opcode_x86_CMP_imm_with_reg_mem            = (i_instruction[0][7: 2] == 6'b1000_00) & (i_instruction[1][5: 3] == 3'b111);
assign o_opcode_x86_CMP_imm_to_acc                  = (i_instruction[0][7: 1] == 7'b0011_110);

assign o_opcode_x86_CMPS_compare_string_operands    = (i_instruction[0][7: 1] == 7'b1010_011);

assign o_opcode_x86_CWD_convert_word_to_double      = (i_instruction[0][7: 0] == 8'b1001_1000);

assign o_opcode_x86_DAA_decimal_adjust_AL_after_add = (i_instruction[0][7: 0] == 8'b0010_0111);
assign o_opcode_x86_DAS_decimal_adjust_AL_after_sub = (i_instruction[0][7: 0] == 8'b0010_1111);

assign o_opcode_x86_DEC_reg_mem                    = (i_instruction[0][7: 0] == 8'b1111_1111) & (i_instruction[1][5: 3] == 3'b001);
assign o_opcode_x86_DEC_reg                        = (i_instruction[0][7: 3] == 5'b0100_1);

assign o_opcode_x86_DIV_acc_by_reg_mem             = (i_instruction[0][7: 1] == 7'b1111_011) & (i_instruction[1][5: 3] == 3'b110);

assign o_opcode_x86_HLT_halt                       = (i_instruction[0][7: 0] == 8'b1111_0100);

assign o_opcode_x86_IDIV_acc_by_reg_mem              = (i_instruction[0][7: 1] == 7'b1111_011) & (i_instruction[1][5: 3] == 3'b111);

assign o_opcode_x86_IMUL_acc_with_reg_mem           = (i_instruction[0][7: 1] == 7'b1111_011) & (i_instruction[1][5: 3] == 3'b101);
assign o_opcode_x86_IMUL_reg_mem_with_imm_to_reg    = (i_instruction[0][7: 2] == 6'b0110_10) & (i_instruction[0][0] == 1'b1);

assign o_opcode_x86_IN_port_fixed                  = (i_instruction[0][7: 1] == 7'b1110_010);
assign o_opcode_x86_IN_port_variable                 = (i_instruction[0][7: 1] == 7'b1110_110);

assign o_opcode_x86_INC_reg_mem                      = (i_instruction[0][7: 0] == 8'b1111_1111) & (i_instruction[1][5: 3] == 3'b000);
assign o_opcode_x86_INC_reg                          = (i_instruction[0][7: 3] == 5'b0100_0);

assign o_opcode_x86_INS_input_from_DX_port           = (i_instruction[0][7: 1] == 7'b0110_110);

assign o_opcode_x86_INT_interrupt_type_n             = (i_instruction[0][7: 0] == 8'b1100_1101);
assign o_opcode_x86_INT_interrupt_type_3             = (i_instruction[0][7: 0] == 8'b1100_1100);
assign o_opcode_x86_INT_interrupt_type_4             = (i_instruction[0][7: 0] == 8'b1100_1110);

assign o_opcode_x86_IRET_interrupt_return            = (i_instruction[0][7: 0] == 8'b1100_1111);

assign o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp = (i_instruction[0][7: 4] == 4'b0111);

assign o_opcode_x86_JCXZ_jump_on_CX_zero              = (i_instruction[0][7: 0] == 8'b1110_0011);

assign o_opcode_x86_JMP_to_same_segment_short         = (i_instruction[0][7: 0] == 8'b1110_1011);
assign o_opcode_x86_JMP_to_same_segment_direct        = (i_instruction[0][7: 0] == 8'b1110_1001);
assign o_opcode_x86_JMP_to_same_segment_indirect      = (i_instruction[0][7: 0] == 8'b1111_1111) & (i_instruction[1][5: 3] == 3'b100);
assign o_opcode_x86_JMP_to_other_segment_direct       = (i_instruction[0][7: 0] == 8'b1110_1010);
assign o_opcode_x86_JMP_to_other_segment_indirect      = (i_instruction[0][7: 0] == 8'b1111_1111) & (i_instruction[1][5: 3] == 3'b101);

assign o_opcode_x86_LAHF_load_FLAG_into_AH            = (i_instruction[0][7: 0] == 8'b1001_1111);

assign o_opcode_x86_LDS_load_pointer_to_DS            = (i_instruction[0][7: 0] == 8'b1100_0101);
assign o_opcode_x86_LEA_load_effective_adddress_to_reg = (i_instruction[0][7: 0] == 8'b1000_1101);
assign o_opcode_x86_LEAVE_high_level_procedure_exit    = (i_instruction[0][7: 0] == 8'b1100_1001);
assign o_opcode_x86_LES_load_pointer_to_ES            = (i_instruction[0][7: 0] == 8'b1100_0100);

assign o_opcode_x86_LODS_load_string_operand           = (i_instruction[0][7: 1] == 7'b1010_110);

assign o_opcode_x86_LOOP_count                       = (i_instruction[0][7: 0] == 8'b1110_0010);
assign o_opcode_x86_LOOPZ_count_while_zero            = (i_instruction[0][7: 0] == 8'b1110_0001);
assign o_opcode_x86_LOOPNZ_count_while_not_zero       = (i_instruction[0][7: 0] == 8'b1110_0000);

assign o_opcode_x86_MOV_reg_to_reg_mem                = (i_instruction[0][7: 1] == 7'b1000_100);
assign o_opcode_x86_MOV_reg_mem_to_reg                = (i_instruction[0][7: 1] == 7'b1000_101);
assign o_opcode_x86_MOV_imm_to_reg_mem                = (i_instruction[0][7: 1] == 7'b1100_011) & (i_instruction[1][5: 3] == 3'b000);
assign o_opcode_x86_MOV_imm_to_reg                    = (i_instruction[0][7: 4] == 4'b1011);
assign o_opcode_x86_MOV_mem_to_acc                    = (i_instruction[0][7: 1] == 7'b1010_000);
assign o_opcode_x86_MOV_acc_to_mem                    = (i_instruction[0][7: 1] == 7'b1010_001);
assign o_opcode_x86_MOV_reg_mem_to_sreg               = (i_instruction[0][7: 0] == 8'b1000_1110);
assign o_opcode_x86_MOV_sreg_to_reg_mem               = (i_instruction[0][7: 0] == 8'b1000_1100);

assign o_opcode_x86_MOVS_move_data_from_string_to_string = (i_instruction[0][7: 1] == 7'b1010_010);

assign o_opcode_x86_MUL_acc_with_reg_mem              = (i_instruction[0][7: 1] == 7'b1111_011) & (i_instruction[1][5: 3] == 3'b100);

assign o_opcode_x86_NEG_two_s_complement_negation     = (i_instruction[0][7: 1] == 7'b1111_011) & (i_instruction[1][5: 3] == 3'b011);
assign o_opcode_x86_NOP_no_operation                  = (i_instruction[0][7: 0] == 8'b1001_0000);
assign o_opcode_x86_NOT_one_s_complement_negation     = (i_instruction[0][7: 1] == 7'b1111_011) & (i_instruction[1][5: 3] == 3'b010);

assign o_opcode_x86_OR_reg_to_reg_mem                 = (i_instruction[0][7: 1] == 7'b0000_100);
assign o_opcode_x86_OR_reg_mem_to_reg                 = (i_instruction[0][7: 1] == 7'b0000_101);
assign o_opcode_x86_OR_imm_to_reg_mem                 = (i_instruction[0][7: 2] == 6'b1000_00) & (i_instruction[1][5: 3] == 3'b001);
assign o_opcode_x86_OR_imm_to_acc                      = (i_instruction[0][7: 1] == 7'b0000_110);

assign o_opcode_x86_OUT_port_fixed                    = (i_instruction[0][7: 1] == 7'b1110_011);
assign o_opcode_x86_OUT_port_variable                 = (i_instruction[0][7: 1] == 7'b1110_111);
assign o_opcode_x86_OUTS_output_string                 = (i_instruction[0][7: 1] == 7'b0110_111);

assign o_opcode_x86_POP_reg_mem                    = (i_instruction[0][7: 0] == 8'b1000_1111) & (i_instruction[1][5: 3] == 3'b000);
assign o_opcode_x86_POP_reg                        = (i_instruction[0][7: 3] == 5'b0101_1);
assign o_opcode_x86_POP_sreg_2                     = (i_instruction[0][7: 5] == 3'b000) & (i_instruction[0][4: 3] != 2'b01) & (i_instruction[0][2: 0] == 3'b111) & (i_instruction[1][5: 3] != 3'b110) & (i_instruction[1][5: 3] != 3'b111);
assign o_opcode_x86_POPA_pop_all_general_registers  = (i_instruction[0][7: 0] == 8'b0110_0001);
assign o_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS = (i_instruction[0][7: 0] == 8'b1001_1101);

assign o_opcode_x86_PUSH_reg_mem                   = (i_instruction[0][7: 0] == 8'b1111_1111) & (i_instruction[1][5: 3] == 3'b110);
assign o_opcode_x86_PUSH_reg                       = (i_instruction[0][7: 3] == 5'b0101_0);
assign o_opcode_x86_PUSH_sreg_2                    = (i_instruction[0][7: 5] == 3'b000) & (i_instruction[0][2: 0] == 3'b110);
assign o_opcode_x86_PUSH_imm                       = (i_instruction[0][7: 2] == 6'b0110_10) & (i_instruction[0][0] == 1'b0);
assign o_opcode_x86_PUSH_all_general_registers     = (i_instruction[0][7: 0] == 8'b0110_0000);
assign o_opcode_x86_PUSHF_push_flags_onto_stack    = (i_instruction[0][7: 0] == 8'b1001_1100);

assign o_opcode_x86_RCL_reg_mem_by_1                = (i_instruction[0][7: 1] == 7'b1101_000) & (i_instruction[1][5: 3] == 3'b010);
assign o_opcode_x86_RCL_reg_mem_by_CL               = (i_instruction[0][7: 1] == 7'b1101_001) & (i_instruction[1][5: 3] == 3'b010);
assign o_opcode_x86_RCL_reg_mem_by_imm              = (i_instruction[0][7: 1] == 7'b1100_000) & (i_instruction[1][5: 3] == 3'b010);

assign o_opcode_x86_RCR_reg_mem_by_1                = (i_instruction[0][7: 1] == 7'b1101_000) & (i_instruction[1][5: 3] == 3'b011);
assign o_opcode_x86_RCR_reg_mem_by_CL               = (i_instruction[0][7: 1] == 7'b1101_001) & (i_instruction[1][5: 3] == 3'b011);
assign o_opcode_x86_RCR_reg_mem_by_imm              = (i_instruction[0][7: 1] == 7'b1100_000) & (i_instruction[1][5: 3] == 3'b011);

assign o_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument       = (i_instruction[0][7: 0] == 8'b1100_0011);
assign o_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP  = (i_instruction[0][7: 0] == 8'b1100_0010);
assign o_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument      = (i_instruction[0][7: 0] == 8'b1100_1011);
assign o_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP = (i_instruction[0][7: 0] == 8'b1100_1010);

assign o_opcode_x86_ROL_reg_mem_by_1                = (i_instruction[0][7: 1] == 7'b1101_000) & (i_instruction[1][5: 3] == 3'b000);
assign o_opcode_x86_ROL_reg_mem_by_CL               = (i_instruction[0][7: 1] == 7'b1101_001) & (i_instruction[1][5: 3] == 3'b000);
assign o_opcode_x86_ROL_reg_mem_by_imm              = (i_instruction[0][7: 1] == 7'b1100_000) & (i_instruction[1][5: 3] == 3'b000);

assign o_opcode_x86_ROR_reg_mem_by_1                = (i_instruction[0][7: 1] == 7'b1101_000) & (i_instruction[1][5: 3] == 3'b001);
assign o_opcode_x86_ROR_reg_mem_by_CL               = (i_instruction[0][7: 1] == 7'b1101_001) & (i_instruction[1][5: 3] == 3'b001);
assign o_opcode_x86_ROR_reg_mem_by_imm              = (i_instruction[0][7: 1] == 7'b1100_000) & (i_instruction[1][5: 3] == 3'b001);

assign o_opcode_x86_SAHF_store_AH_into_flags        = (i_instruction[0][7: 0] == 8'b1001_1110);

assign o_opcode_x86_SAR_reg_mem_by_1                = (i_instruction[0][7: 1] == 7'b1101_000) & (i_instruction[1][5: 3] == 3'b111);
assign o_opcode_x86_SAR_reg_mem_by_CL               = (i_instruction[0][7: 1] == 7'b1101_001) & (i_instruction[1][5: 3] == 3'b111);
assign o_opcode_x86_SAR_reg_mem_by_imm              = (i_instruction[0][7: 1] == 7'b1100_000) & (i_instruction[1][5: 3] == 3'b111);

assign o_opcode_x86_SBB_reg_to_reg_mem               = (i_instruction[0][7: 1] == 7'b0001_100);
assign o_opcode_x86_SBB_reg_mem_to_reg               = (i_instruction[0][7: 1] == 7'b0001_101);
assign o_opcode_x86_SBB_imm_to_reg_mem              = (i_instruction[0][7: 2] == 6'b1000_00) & (i_instruction[1][5: 3] == 3'b011);
assign o_opcode_x86_SBB_imm_to_acc                   = (i_instruction[0][7: 1] == 7'b0001_110);

assign o_opcode_x86_SCAS_scan_string                 = (i_instruction[0][7: 1] == 7'b1010_111);

assign o_opcode_x86_SHL_reg_mem_by_1                = (i_instruction[0][7: 1] == 7'b1101_000) & (i_instruction[1][5: 3] == 3'b100);
assign o_opcode_x86_SHL_reg_mem_by_CL               = (i_instruction[0][7: 1] == 7'b1101_001) & (i_instruction[1][5: 3] == 3'b100);
assign o_opcode_x86_SHL_reg_mem_by_imm              = (i_instruction[0][7: 1] == 7'b1100_000) & (i_instruction[1][5: 3] == 3'b100);

assign o_opcode_x86_SHR_reg_mem_by_1                = (i_instruction[0][7: 1] == 7'b1101_000) & (i_instruction[1][5: 3] == 3'b101);
assign o_opcode_x86_SHR_reg_mem_by_CL               = (i_instruction[0][7: 1] == 7'b1101_001) & (i_instruction[1][5: 3] == 3'b101);
assign o_opcode_x86_SHR_reg_mem_by_imm              = (i_instruction[0][7: 1] == 7'b1100_000) & (i_instruction[1][5: 3] == 3'b101);

assign o_opcode_x86_STC_set_carry_flag               = (i_instruction[0][7: 0] == 8'b1111_1001);
assign o_opcode_x86_STD_set_direction_flag           = (i_instruction[0][7: 0] == 8'b1111_1101);
assign o_opcode_x86_STI_set_interrupt_enable_flag    = (i_instruction[0][7: 0] == 8'b1111_1011);

assign o_opcode_x86_STOS_store_string_data           = (i_instruction[0][7: 1] == 7'b1010_101);

assign o_opcode_x86_SUB_reg_to_reg_mem               = (i_instruction[0][7: 1] == 7'b0010_100);
assign o_opcode_x86_SUB_reg_mem_to_reg               = (i_instruction[0][7: 1] == 7'b0010_101);
assign o_opcode_x86_SUB_imm_to_reg_mem              = (i_instruction[0][7: 2] == 6'b1000_00) & (i_instruction[1][5: 3] == 3'b101);
assign o_opcode_x86_SUB_imm_to_acc                   = (i_instruction[0][7: 1] == 7'b0010_110);

assign o_opcode_x86_TEST_reg_mem_and_reg             = (i_instruction[0][7: 1] == 7'b1000_010);
assign o_opcode_x86_TEST_imm_and_reg_mem             = (i_instruction[0][7: 1] == 7'b1111_011) & (i_instruction[1][5: 3] == 3'b000);
assign o_opcode_x86_TEST_imm_to_acc                  = (i_instruction[0][7: 1] == 7'b1010_100);

assign o_opcode_x86_WAIT_wait                       = (i_instruction[0][7: 0] == 8'b1001_1011);

assign o_opcode_x86_XCHG_reg_mem_with_reg            = (i_instruction[0][7: 1] == 7'b1000_011);
assign o_opcode_x86_XCHG_reg_with_acc_short           = (i_instruction[0][7: 3] == 5'b1001_0) & (i_instruction[0][2: 0] != 3'b000);

assign o_opcode_x86_XLAT_table_look_up_translation   = (i_instruction[0][7: 0] == 8'b1101_0111);

assign o_opcode_x86_XOR_reg_to_reg_mem               = (i_instruction[0][7: 1] == 7'b0011_000);
assign o_opcode_x86_XOR_reg_mem_to_reg               = (i_instruction[0][7: 1] == 7'b0011_001);
assign o_opcode_x86_XOR_imm_to_reg_mem              = (i_instruction[0][7: 2] == 6'b1000_00) & (i_instruction[1][5: 3] == 3'b110);
assign o_opcode_x86_XOR_imm_to_acc                   = (i_instruction[0][7: 1] == 7'b0011_010);

endmodule
