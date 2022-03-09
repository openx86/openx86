/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_opcode_x86
create at: 2022-03-02 00:41:18
description: decode x86(IA-32) opcode selection signal from instruction bytes
some tricks:
- for MOV – Move to/from Control Registers and MOV – Move to/from Debug Registers instructions
instruction[2][7:6] is not used
we could decode it as a mod/rm field, allowing the control/debug register to transfer data to memory
*/

module decode_opcode_x86 (
    output logic        o_opcode_x86_AAA_ASCII_adjust_after_add,
    output logic        o_opcode_x86_AAD_ASCII_AX_before_div,
    output logic        o_opcode_x86_AAM_ASCII_AX_after_mul,
    output logic        o_opcode_x86_AAS_ASCII_adjust_after_sub,
    output logic        o_opcode_x86_ADC_reg_to_reg_mem,
    output logic        o_opcode_x86_ADC_reg_mem_to_reg,
    output logic        o_opcode_x86_ADC_imm_to_reg_mem,
    output logic        o_opcode_x86_ADC_imm_to_acc,
    output logic        o_opcode_x86_ADD_reg_to_reg_mem,
    output logic        o_opcode_x86_ADD_reg_mem_to_reg,
    output logic        o_opcode_x86_ADD_imm_to_reg_mem,
    output logic        o_opcode_x86_ADD_imm_to_acc,
    output logic        o_opcode_x86_AND_reg_to_reg_mem,
    output logic        o_opcode_x86_AND_reg_mem_to_reg,
    output logic        o_opcode_x86_AND_imm_to_reg_mem,
    output logic        o_opcode_x86_AND_imm_to_acc,
    output logic        o_opcode_x86_ARPL_adjust_RPL_field_of_selector,
    output logic        o_opcode_x86_BOUND_check_array_against_bounds,
    output logic        o_opcode_x86_BSF_bit_scan_forward,
    output logic        o_opcode_x86_BSR_bit_scan_reverse,
    output logic        o_opcode_x86_BSWAP_byte_swap,
    output logic        o_opcode_x86_BT_reg_mem_with_imm,
    output logic        o_opcode_x86_BT_reg_mem_with_reg,
    output logic        o_opcode_x86_BTC_reg_mem_with_imm,
    output logic        o_opcode_x86_BTC_reg_mem_with_reg,
    output logic        o_opcode_x86_BTR_reg_mem_with_imm,
    output logic        o_opcode_x86_BTR_reg_mem_with_reg,
    output logic        o_opcode_x86_BTS_reg_mem_with_imm,
    output logic        o_opcode_x86_BTS_reg_mem_with_reg,
    output logic        o_opcode_x86_CALL_in_same_segment_direct,
    output logic        o_opcode_x86_CALL_in_same_segment_indirect,
    output logic        o_opcode_x86_CALL_in_other_segment_direct,
    output logic        o_opcode_x86_CALL_in_other_segment_indirect,
    output logic        o_opcode_x86_CBW_convert_byte_to_word,
    output logic        o_opcode_x86_CDQ_convert_double_word_to_quad_word,
    output logic        o_opcode_x86_CLC_clear_carry_flag,
    output logic        o_opcode_x86_CLD_clear_direction_flag,
    output logic        o_opcode_x86_CLI_clear_interrupt_enable_flag,
    output logic        o_opcode_x86_CLTS_clear_task_switched_flag,
    output logic        o_opcode_x86_CMC_complement_carry_flag,
    output logic        o_opcode_x86_CMP_mem_with_reg,
    output logic        o_opcode_x86_CMP_reg_with_mem,
    output logic        o_opcode_x86_CMP_imm_with_reg_mem,
    output logic        o_opcode_x86_CMP_imm_with_acc,
    output logic        o_opcode_x86_CMPS_compare_string_operands,
    output logic        o_opcode_x86_CMPXCHG_compare_and_exchange,
    output logic        o_opcode_x86_CPUID_CPU_identification,
    output logic        o_opcode_x86_CWD_convert_word_to_double,
    output logic        o_opcode_x86_CWDE_convert_word_to_double,
    output logic        o_opcode_x86_DAA_decimal_adjust_AL_after_add,
    output logic        o_opcode_x86_DAS_decimal_adjust_AL_after_sub,
    output logic        o_opcode_x86_DEC_reg_mem,
    output logic        o_opcode_x86_DEC_reg,
    output logic        o_opcode_x86_DIV_acc_by_reg_mem,
    output logic        o_opcode_x86_HLT_halt,
    output logic        o_opcode_x86_IDIV_acc_by_reg_mem,
    output logic        o_opcode_x86_IMUL_acc_with_reg_mem,
    output logic        o_opcode_x86_IMUL_reg_with_reg_mem,
    output logic        o_opcode_x86_IMUL_reg_mem_with_imm_to_reg,
    output logic        o_opcode_x86_IN_port_fixed,
    output logic        o_opcode_x86_IN_port_variable,
    output logic        o_opcode_x86_INC_reg_mem,
    output logic        o_opcode_x86_INC_reg,
    output logic        o_opcode_x86_INS_input_from_DX_port,
    output logic        o_opcode_x86_INT_interrupt_type_n,
    output logic        o_opcode_x86_INT_interrupt_type_3,
    output logic        o_opcode_x86_INT_interrupt_type_4,
    output logic        o_opcode_x86_INVD_invalidate_cache,
    output logic        o_opcode_x86_INVLPG_invalidate_TLB_entry,
    output logic        o_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size,
    output logic        o_opcode_x86_IRET_interrupt_return,
    output logic        o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp,
    output logic        o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp,
    output logic        o_opcode_x86_JCXZ_jump_on_CX_zero,
    output logic        o_opcode_x86_JMP_to_same_segment_short,
    output logic        o_opcode_x86_JMP_to_same_segment_direct,
    output logic        o_opcode_x86_JMP_to_same_segment_indirect,
    output logic        o_opcode_x86_JMP_to_other_segment_direct,
    output logic        o_opcode_x86_JMP_to_other_segment_indirect,
    output logic        o_opcode_x86_LAHF_load_FLAG_into_AH,
    output logic        o_opcode_x86_LAR_load_access_rights_byte,
    output logic        o_opcode_x86_LDS_load_pointer_to_DS,
    output logic        o_opcode_x86_LEA_load_effective_adddress_to_reg,
    output logic        o_opcode_x86_LEAVE_high_level_procedure_exit,
    output logic        o_opcode_x86_LES_load_pointer_to_ES,
    output logic        o_opcode_x86_LFS_load_pointer_to_FS,
    output logic        o_opcode_x86_LGDT_load_global_desciptor_table_reg,
    output logic        o_opcode_x86_LGS_load_pointer_to_GS,
    output logic        o_opcode_x86_LIDT_load_interrupt_desciptor_table_reg,
    output logic        o_opcode_x86_LLDT_load_local_desciptor_table_reg,
    output logic        o_opcode_x86_LMSW_load_status_word,
    output logic        o_opcode_x86_LODS_load_string_operand,
    output logic        o_opcode_x86_LOOP_count,
    output logic        o_opcode_x86_LOOPZ_count_while_zero,
    output logic        o_opcode_x86_LOOPNZ_count_while_not_zero,
    output logic        o_opcode_x86_LSL_load_segment_limit,
    output logic        o_opcode_x86_LSS_load_pointer_to_SS,
    output logic        o_opcode_x86_LTR_load_task_register,
    output logic        o_opcode_x86_MOV_reg_to_reg_mem,
    output logic        o_opcode_x86_MOV_reg_mem_to_reg,
    output logic        o_opcode_x86_MOV_imm_to_reg_mem,
    output logic        o_opcode_x86_MOV_imm_to_reg,
    output logic        o_opcode_x86_MOV_mem_to_acc,
    output logic        o_opcode_x86_MOV_acc_to_mem,
    output logic        o_opcode_x86_MOV_CR_from_reg,
    output logic        o_opcode_x86_MOV_reg_from_CR,
    output logic        o_opcode_x86_MOV_DR_from_reg,
    output logic        o_opcode_x86_MOV_reg_from_DR,
    output logic        o_opcode_x86_MOV_TR_from_reg,
    output logic        o_opcode_x86_MOV_reg_from_TR,
    output logic        o_opcode_x86_MOV_reg_mem_to_sreg,
    output logic        o_opcode_x86_MOV_sreg_to_reg_mem,
    output logic        o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg,
    output logic        o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem,
    output logic        o_opcode_x86_MOVS_move_data_from_string_to_string,
    output logic        o_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg,
    output logic        o_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg,
    output logic        o_opcode_x86_MUL_acc_with_reg_mem,
    output logic        o_opcode_x86_NEG_two_s_complement_negation,
    output logic        o_opcode_x86_NOP_no_operation,
    output logic        o_opcode_x86_NOP_no_operation_multi_byte,
    output logic        o_opcode_x86_NOT_one_s_complement_negation,
    output logic        o_opcode_x86_OR_reg_to_reg_mem,
    output logic        o_opcode_x86_OR_reg_mem_to_reg,
    output logic        o_opcode_x86_OR_imm_to_reg_mem,
    output logic        o_opcode_x86_OR_imm_to_acc,
    output logic        o_opcode_x86_OUT_port_fixed,
    output logic        o_opcode_x86_OUT_port_variable,
    output logic        o_opcode_x86_OUTS_output_string,
    output logic        o_opcode_x86_POP_reg_mem,
    output logic        o_opcode_x86_POP_reg,
    output logic        o_opcode_x86_POP_sreg_2,
    output logic        o_opcode_x86_POP_sreg_3,
    output logic        o_opcode_x86_POPA_pop_all_general_registers,
    output logic        o_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS,
    output logic        o_opcode_x86_PUSH_reg_mem,
    output logic        o_opcode_x86_PUSH_reg,
    output logic        o_opcode_x86_PUSH_sreg_2,
    output logic        o_opcode_x86_PUSH_sreg_3,
    output logic        o_opcode_x86_PUSH_imm,
    output logic        o_opcode_x86_PUSH_all_general_registers,
    output logic        o_opcode_x86_PUSHF_push_flags_onto_stack,
    output logic        o_opcode_x86_RCL_reg_mem_by_1,
    output logic        o_opcode_x86_RCL_reg_mem_by_CL,
    output logic        o_opcode_x86_RCL_reg_mem_by_imm,
    output logic        o_opcode_x86_RCR_reg_mem_by_1,
    output logic        o_opcode_x86_RCR_reg_mem_by_CL,
    output logic        o_opcode_x86_RCR_reg_mem_by_imm,
    output logic        o_opcode_x86_RDMSR_read_from_model_specific_reg,
    output logic        o_opcode_x86_RDPMC_read_performance_monitoring_counters,
    output logic        o_opcode_x86_RDTSC_read_time_stamp_counter,
    output logic        o_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id,
    output logic        o_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument,
    output logic        o_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP,
    output logic        o_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument,
    output logic        o_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP,
    output logic        o_opcode_x86_ROL_reg_mem_by_1,
    output logic        o_opcode_x86_ROL_reg_mem_by_CL,
    output logic        o_opcode_x86_ROL_reg_mem_by_imm,
    output logic        o_opcode_x86_ROR_reg_mem_by_1,
    output logic        o_opcode_x86_ROR_reg_mem_by_CL,
    output logic        o_opcode_x86_ROR_reg_mem_by_imm,
    output logic        o_opcode_x86_RSM_resume_from_system_management_mode,
    output logic        o_opcode_x86_SAHF_store_AH_into_flags,
    output logic        o_opcode_x86_SAR_reg_mem_by_1,
    output logic        o_opcode_x86_SAR_reg_mem_by_CL,
    output logic        o_opcode_x86_SAR_reg_mem_by_imm,
    output logic        o_opcode_x86_SBB_reg_to_reg_mem,
    output logic        o_opcode_x86_SBB_reg_mem_to_reg,
    output logic        o_opcode_x86_SBB_imm_to_reg_mem,
    output logic        o_opcode_x86_SBB_imm_to_acc,
    output logic        o_opcode_x86_SCAS_scan_string,
    output logic        o_opcode_x86_SETcc_byte_set_on_condition,
    output logic        o_opcode_x86_SGDT_store_global_descriptor_table_register,
    output logic        o_opcode_x86_SHL_reg_mem_by_1,
    output logic        o_opcode_x86_SHL_reg_mem_by_CL,
    output logic        o_opcode_x86_SHL_reg_mem_by_imm,
    output logic        o_opcode_x86_SHLD_reg_mem_by_imm,
    output logic        o_opcode_x86_SHLD_reg_mem_by_CL,
    output logic        o_opcode_x86_SHR_reg_mem_by_1,
    output logic        o_opcode_x86_SHR_reg_mem_by_CL,
    output logic        o_opcode_x86_SHR_reg_mem_by_imm,
    output logic        o_opcode_x86_SHRD_reg_mem_by_imm,
    output logic        o_opcode_x86_SHRD_reg_mem_by_CL,
    output logic        o_opcode_x86_SIDT_store_interrupt_desciptor_table_register,
    output logic        o_opcode_x86_SLDT_store_local_desciptor_table_register,
    output logic        o_opcode_x86_SMSW_store_machine_status_word,
    output logic        o_opcode_x86_STC_set_carry_flag,
    output logic        o_opcode_x86_STD_set_direction_flag,
    output logic        o_opcode_x86_STI_set_interrupt_enable_flag,
    output logic        o_opcode_x86_STOS_store_string_data,
    output logic        o_opcode_x86_STR_store_task_register,
    output logic        o_opcode_x86_SUB_reg_to_reg_mem,
    output logic        o_opcode_x86_SUB_reg_mem_to_reg,
    output logic        o_opcode_x86_SUB_imm_to_reg_mem,
    output logic        o_opcode_x86_SUB_imm_to_acc,
    output logic        o_opcode_x86_TEST_reg_mem_and_reg,
    output logic        o_opcode_x86_TEST_imm_and_reg_mem,
    output logic        o_opcode_x86_TEST_imm_and_acc,
    output logic        o_opcode_x86_UD0_undefined_instruction,
    output logic        o_opcode_x86_UD1_undefined_instruction,
    output logic        o_opcode_x86_UD2_undefined_instruction,
    output logic        o_opcode_x86_VERR_verify_a_segment_for_reading,
    output logic        o_opcode_x86_VERW_verify_a_segment_for_writing,
    output logic        o_opcode_x86_WAIT_wait,
    output logic        o_opcode_x86_WBINVD_writeback_and_invalidate_data_cache,
    output logic        o_opcode_x86_WRMSR_write_to_model_specific_register,
    output logic        o_opcode_x86_XADD_exchange_and_add,
    output logic        o_opcode_x86_XCHG_reg_mem_with_reg,
    output logic        o_opcode_x86_XCHG_reg_with_acc_short,
    output logic        o_opcode_x86_XLAT_table_look_up_translation,
    output logic        o_opcode_x86_XOR_reg_to_reg_mem,
    output logic        o_opcode_x86_XOR_reg_mem_to_reg,
    output logic        o_opcode_x86_XOR_imm_to_reg_mem,
    output logic        o_opcode_x86_XOR_imm_to_acc,
    input  logic [ 7:0] i_instruction [0:3]
);

assign o_opcode_x86_AAA_ASCII_adjust_after_add                                  = (i_instruction[0][7:0] == 8'b0011_0111);

assign o_opcode_x86_AAD_ASCII_AX_before_div                                     = (i_instruction[0][7:0] == 8'b1101_0101) & (i_instruction[1][7:0] == 8'b0000_1010);

assign o_opcode_x86_AAM_ASCII_AX_after_mul                                      = (i_instruction[0][7:0] == 8'b1101_0100) & (i_instruction[1][7:0] == 8'b0000_1010);

assign o_opcode_x86_AAS_ASCII_adjust_after_sub                                  = (i_instruction[0][7:0] == 8'b0011_1111);

assign o_opcode_x86_ADC_reg_to_reg_mem                                          = (i_instruction[0][7:1] == 7'b0001_000 );
assign o_opcode_x86_ADC_reg_mem_to_reg                                          = (i_instruction[0][7:1] == 7'b0001_001 );
assign o_opcode_x86_ADC_imm_to_reg_mem                                          = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_x86_ADC_imm_to_acc                                              = (i_instruction[0][7:1] == 7'b0001_010 );

assign o_opcode_x86_ADD_reg_to_reg_mem                                          = (i_instruction[0][7:1] == 7'b0000_000 );
assign o_opcode_x86_ADD_reg_mem_to_reg                                          = (i_instruction[0][7:1] == 7'b0000_001 );
assign o_opcode_x86_ADD_imm_to_reg_mem                                          = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_x86_ADD_imm_to_acc                                              = (i_instruction[0][7:1] == 7'b0000_010 );

assign o_opcode_x86_AND_reg_to_reg_mem                                          = (i_instruction[0][7:1] == 7'b0010_000 );
assign o_opcode_x86_AND_reg_mem_to_reg                                          = (i_instruction[0][7:1] == 7'b0010_001 );
assign o_opcode_x86_AND_imm_to_reg_mem                                          = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_x86_AND_imm_to_acc                                              = (i_instruction[0][7:1] == 7'b0010_010 );

assign o_opcode_x86_ARPL_adjust_RPL_field_of_selector                           = (i_instruction[0][7:0] == 8'b0110_0011);

assign o_opcode_x86_BOUND_check_array_against_bounds                            = (i_instruction[0][7:0] == 8'b0110_0010);

assign o_opcode_x86_BSF_bit_scan_forward                                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1100);

assign o_opcode_x86_BSR_bit_scan_reverse                                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1101);

assign o_opcode_x86_BSWAP_byte_swap                                             = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:3] == 5'b1100_1);

assign o_opcode_x86_BT_reg_mem_with_imm                                         = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b100);
assign o_opcode_x86_BT_reg_mem_with_reg                                         = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_0011);

assign o_opcode_x86_BTC_reg_mem_with_imm                                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b111);
assign o_opcode_x86_BTC_reg_mem_with_reg                                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1011);

assign o_opcode_x86_BTR_reg_mem_with_imm                                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b110);
assign o_opcode_x86_BTR_reg_mem_with_reg                                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0011);

assign o_opcode_x86_BTS_reg_mem_with_imm                                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_1010) & (i_instruction[2][5:3] == 3'b101);
assign o_opcode_x86_BTS_reg_mem_with_reg                                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1011);

assign o_opcode_x86_CALL_in_same_segment_direct                                 = (i_instruction[0][7:0] == 8'b1110_1000);
assign o_opcode_x86_CALL_in_same_segment_indirect                               = (i_instruction[0][7:1] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_x86_CALL_in_other_segment_direct                                = (i_instruction[0][7:0] == 8'b1001_1010);
assign o_opcode_x86_CALL_in_other_segment_indirect                              = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b011);

assign o_opcode_x86_CBW_convert_byte_to_word                                    = (i_instruction[0][7:0] == 8'b1001_1000);

assign o_opcode_x86_CDQ_convert_double_word_to_quad_word                        = (i_instruction[0][7:0] == 8'b1001_1001);

assign o_opcode_x86_CLC_clear_carry_flag                                        = (i_instruction[0][7:0] == 8'b1111_1000);

assign o_opcode_x86_CLD_clear_direction_flag                                    = (i_instruction[0][7:0] == 8'b1111_1100);

assign o_opcode_x86_CLI_clear_interrupt_enable_flag                             = (i_instruction[0][7:0] == 8'b1111_1010);

assign o_opcode_x86_CLTS_clear_task_switched_flag                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0110);

assign o_opcode_x86_CMC_complement_carry_flag                                   = (i_instruction[0][7:0] == 8'b1111_0101);

assign o_opcode_x86_CMP_mem_with_reg                                            = (i_instruction[0][7:1] == 7'b0011_100 );
assign o_opcode_x86_CMP_reg_with_mem                                            = (i_instruction[0][7:1] == 7'b0011_101 );
assign o_opcode_x86_CMP_imm_with_reg_mem                                        = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b111);
assign o_opcode_x86_CMP_imm_with_acc                                            = (i_instruction[0][7:1] == 7'b0011_110 );

assign o_opcode_x86_CMPS_compare_string_operands                                = (i_instruction[0][7:1] == 7'b1010_011);

assign o_opcode_x86_CMPXCHG_compare_and_exchange                                = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:1] == 7'b1011_000);

assign o_opcode_x86_CPUID_CPU_identification                                    = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_0010);

assign o_opcode_x86_CWD_convert_word_to_double                                  = (i_instruction[0][7:0] == 8'b1001_1000); // opcode is same as CBW

assign o_opcode_x86_CWDE_convert_word_to_double                                 = (i_instruction[0][7:0] == 8'b1001_1001); // opcode is same as CDQ

assign o_opcode_x86_DAA_decimal_adjust_AL_after_add                             = (i_instruction[0][7:0] == 8'b0010_0111);

assign o_opcode_x86_DAS_decimal_adjust_AL_after_sub                             = (i_instruction[0][7:0] == 8'b0010_1111);

assign o_opcode_x86_DEC_reg_mem                                                 = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b001);
assign o_opcode_x86_DEC_reg                                                     = (i_instruction[0][7:3] == 5'b0100_1   );

assign o_opcode_x86_DIV_acc_by_reg_mem                                          = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b110);

assign o_opcode_x86_HLT_halt                                                    = (i_instruction[0][7:0] == 8'b1111_0100);

assign o_opcode_x86_IDIV_acc_by_reg_mem                                         = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b111);

assign o_opcode_x86_IMUL_acc_with_reg_mem                                       = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_x86_IMUL_reg_with_reg_mem                                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1111);
assign o_opcode_x86_IMUL_reg_mem_with_imm_to_reg                                = (i_instruction[0][7:2] == 6'b0110_10  ) & (i_instruction[0][0] == 1'b1);

assign o_opcode_x86_IN_port_fixed                                               = (i_instruction[0][7:1] == 7'b1110_010 );
assign o_opcode_x86_IN_port_variable                                            = (i_instruction[0][7:1] == 7'b1110_110 );

assign o_opcode_x86_INC_reg_mem                                                 = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_x86_INC_reg                                                     = (i_instruction[0][7:3] == 5'b0100_0   );

assign o_opcode_x86_INS_input_from_DX_port                                      = (i_instruction[0][7:1] == 7'b0110_110 );

assign o_opcode_x86_INT_interrupt_type_n                                        = (i_instruction[0][7:0] == 8'b1100_1101);
assign o_opcode_x86_INT_interrupt_type_3                                        = (i_instruction[0][7:0] == 8'b1100_1100);
assign o_opcode_x86_INT_interrupt_type_4                                        = (i_instruction[0][7:0] == 8'b1100_1110);

assign o_opcode_x86_INVD_invalidate_cache                                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_1000);

assign o_opcode_x86_INVLPG_invalidate_TLB_entry                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b111);

assign o_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0011_1000) & (i_instruction[2][7:0] == 8'b1000_0010);

assign o_opcode_x86_IRET_interrupt_return                                       = (i_instruction[0][7:0] == 8'b1100_1111);

assign o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp                          = (i_instruction[0][7:4] == 4'b0111);
assign o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp                           = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:4] == 4'b1000);

assign o_opcode_x86_JCXZ_jump_on_CX_zero                                        = (i_instruction[0][7:0] == 8'b1110_0011); // (JCXZ and JECXZ: Address Size Prefix Differentiates JCXZ from JECXZ)

assign o_opcode_x86_JMP_to_same_segment_short                                   = (i_instruction[0][7:0] == 8'b1110_1011);
assign o_opcode_x86_JMP_to_same_segment_direct                                  = (i_instruction[0][7:0] == 8'b1110_1001);
assign o_opcode_x86_JMP_to_same_segment_indirect                                = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_x86_JMP_to_other_segment_direct                                 = (i_instruction[0][7:0] == 8'b1110_1010);
assign o_opcode_x86_JMP_to_other_segment_indirect                               = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b101);

assign o_opcode_x86_LAHF_load_FLAG_into_AH                                      = (i_instruction[0][7:0] == 8'b1001_1111);

assign o_opcode_x86_LAR_load_access_rights_byte                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0010);

assign o_opcode_x86_LDS_load_pointer_to_DS                                      = (i_instruction[0][7:0] == 8'b1100_0101);

assign o_opcode_x86_LEA_load_effective_adddress_to_reg                          = (i_instruction[0][7:0] == 8'b1000_1101);

assign o_opcode_x86_LEAVE_high_level_procedure_exit                             = (i_instruction[0][7:0] == 8'b1100_1001);

assign o_opcode_x86_LES_load_pointer_to_ES                                      = (i_instruction[0][7:0] == 8'b1100_0100);

assign o_opcode_x86_LFS_load_pointer_to_FS                                      = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0100);

assign o_opcode_x86_LGDT_load_global_desciptor_table_reg                        = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b010);

assign o_opcode_x86_LGS_load_pointer_to_GS                                      = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0101);

assign o_opcode_x86_LIDT_load_interrupt_desciptor_table_reg                     = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b011);

assign o_opcode_x86_LLDT_load_local_desciptor_table_reg                         = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b010);

assign o_opcode_x86_LMSW_load_status_word                                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b110);

assign o_opcode_x86_LODS_load_string_operand                                    = (i_instruction[0][7:1] == 7'b1010_110 );

assign o_opcode_x86_LOOP_count                                                  = (i_instruction[0][7:0] == 8'b1110_0010);
assign o_opcode_x86_LOOPZ_count_while_zero                                      = (i_instruction[0][7:0] == 8'b1110_0001);
assign o_opcode_x86_LOOPNZ_count_while_not_zero                                 = (i_instruction[0][7:0] == 8'b1110_0000);

assign o_opcode_x86_LSL_load_segment_limit                                      = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0011);

assign o_opcode_x86_LSS_load_pointer_to_SS                                      = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1011_0010);

assign o_opcode_x86_LTR_load_task_register                                      = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b011);

assign o_opcode_x86_MOV_reg_to_reg_mem                                          = (i_instruction[0][7:1] == 7'b1000_100 );
assign o_opcode_x86_MOV_reg_mem_to_reg                                          = (i_instruction[0][7:1] == 7'b1000_101 );
assign o_opcode_x86_MOV_imm_to_reg_mem                                          = (i_instruction[0][7:1] == 7'b1100_011 ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_x86_MOV_imm_to_reg                                              = (i_instruction[0][7:4] == 4'b1011     );
assign o_opcode_x86_MOV_mem_to_acc                                              = (i_instruction[0][7:1] == 7'b1010_000 );
assign o_opcode_x86_MOV_acc_to_mem                                              = (i_instruction[0][7:1] == 7'b1010_001 );

assign o_opcode_x86_MOV_CR_from_reg                                             = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0010); // & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_x86_MOV_reg_from_CR                                             = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0000); // & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_x86_MOV_DR_from_reg                                             = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0011); // & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_x86_MOV_reg_from_DR                                             = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0001); // & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_x86_MOV_TR_from_reg                                             = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0110); // & (i_instruction[2][7:6] == 2'b11);
assign o_opcode_x86_MOV_reg_from_TR                                             = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0010_0100); // & (i_instruction[2][7:6] == 2'b11);

assign o_opcode_x86_MOV_reg_mem_to_sreg                                         = (i_instruction[0][7:0] == 8'b1000_1110);
assign o_opcode_x86_MOV_sreg_to_reg_mem                                         = (i_instruction[0][7:0] == 8'b1000_1100);

assign o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg         = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0011_1000) & (i_instruction[2][7:0] == 8'b1111_0000);
assign o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem         = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0011_1000) & (i_instruction[2][7:0] == 8'b1111_0001);

assign o_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:1] == 7'b1011_111);
assign o_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:1] == 7'b1011_011);

assign o_opcode_x86_MUL_acc_with_reg_mem                                        = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b100);

assign o_opcode_x86_NEG_two_s_complement_negation                               = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b011);

assign o_opcode_x86_NOP_no_operation                                            = (i_instruction[0][7:0] == 8'b1001_0000);
assign o_opcode_x86_NOP_no_operation_multi_byte                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0001_1111) & (i_instruction[2][5:3] == 3'b000);

assign o_opcode_x86_NOT_one_s_complement_negation                               = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b010);

assign o_opcode_x86_OR_reg_to_reg_mem                                           = (i_instruction[0][7:1] == 7'b0000_100 );
assign o_opcode_x86_OR_reg_mem_to_reg                                           = (i_instruction[0][7:1] == 7'b0000_101 );
assign o_opcode_x86_OR_imm_to_reg_mem                                           = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b001);
assign o_opcode_x86_OR_imm_to_acc                                               = (i_instruction[0][7:1] == 7'b0000_110 );

assign o_opcode_x86_OUT_port_fixed                                              = (i_instruction[0][7:1] == 7'b1110_011 );
assign o_opcode_x86_OUT_port_variable                                           = (i_instruction[0][7:1] == 7'b1110_111 );

assign o_opcode_x86_OUTS_output_string                                          = (i_instruction[0][7:1] == 7'b0110_111 );

assign o_opcode_x86_POP_reg_mem                                                 = (i_instruction[0][7:0] == 8'b1000_1111) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_x86_POP_reg                                                     = (i_instruction[0][7:3] == 5'b0101_1   );
assign o_opcode_x86_POP_sreg_2                                                  = (i_instruction[0][7:5] == 3'b000      ) & (i_instruction[0][4:3] != 2'b01) & (i_instruction[0][2:0] == 3'b111) & (i_instruction[1][5:3] != 3'b110) & (i_instruction[1][5:3] != 3'b111);
assign o_opcode_x86_POP_sreg_3                                                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:6] == 2'b10) & (i_instruction[1][5:4] == 2'b10) & (i_instruction[1][2:0] == 3'b001);
assign o_opcode_x86_POPA_pop_all_general_registers                              = (i_instruction[0][7:0] == 8'b0110_0001);
assign o_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS                         = (i_instruction[0][7:0] == 8'b1001_1101);

assign o_opcode_x86_PUSH_reg_mem                                                = (i_instruction[0][7:0] == 8'b1111_1111) & (i_instruction[1][5:3] == 3'b110);
assign o_opcode_x86_PUSH_reg                                                    = (i_instruction[0][7:3] == 5'b0101_0   );
assign o_opcode_x86_PUSH_sreg_2                                                 = (i_instruction[0][7:5] == 3'b000      ) & (i_instruction[0][2:0] == 3'b110);
assign o_opcode_x86_PUSH_sreg_3                                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:6] == 2'b10) & (i_instruction[1][5:4] == 2'b10) & (i_instruction[1][2:0] == 3'b000);
assign o_opcode_x86_PUSH_imm                                                    = (i_instruction[0][7:2] == 6'b0110_10  ) & (i_instruction[0][0] == 1'b0);
assign o_opcode_x86_PUSH_all_general_registers                                  = (i_instruction[0][7:0] == 8'b0110_0000);
assign o_opcode_x86_PUSHF_push_flags_onto_stack                                 = (i_instruction[0][7:0] == 8'b1001_1100);

assign o_opcode_x86_RCL_reg_mem_by_1                                            = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_x86_RCL_reg_mem_by_CL                                           = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b010);
assign o_opcode_x86_RCL_reg_mem_by_imm                                          = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b010);

assign o_opcode_x86_RCR_reg_mem_by_1                                            = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b011);
assign o_opcode_x86_RCR_reg_mem_by_CL                                           = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b011);
assign o_opcode_x86_RCR_reg_mem_by_imm                                          = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b011);

assign o_opcode_x86_RDMSR_read_from_model_specific_reg                          = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0011_0010);
assign o_opcode_x86_RDPMC_read_performance_monitoring_counters                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0011_0011);
assign o_opcode_x86_RDTSC_read_time_stamp_counter                               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0011_0001);
assign o_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id              = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][7:0] == 8'b1111_1001);

assign o_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument       = (i_instruction[0][7:0] == 8'b1100_0011);
assign o_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP  = (i_instruction[0][7:0] == 8'b1100_0010);
assign o_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument      = (i_instruction[0][7:0] == 8'b1100_1011);
assign o_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP = (i_instruction[0][7:0] == 8'b1100_1010);

assign o_opcode_x86_ROL_reg_mem_by_1                                            = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_x86_ROL_reg_mem_by_CL                                           = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_x86_ROL_reg_mem_by_imm                                          = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b000);

assign o_opcode_x86_ROR_reg_mem_by_1                                            = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b001);
assign o_opcode_x86_ROR_reg_mem_by_CL                                           = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b001);
assign o_opcode_x86_ROR_reg_mem_by_imm                                          = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b001);

assign o_opcode_x86_RSM_resume_from_system_management_mode                      = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1010);

assign o_opcode_x86_SAHF_store_AH_into_flags                                    = (i_instruction[0][7:0] == 8'b1001_1110);

assign o_opcode_x86_SAR_reg_mem_by_1                                            = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b111);
assign o_opcode_x86_SAR_reg_mem_by_CL                                           = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b111);
assign o_opcode_x86_SAR_reg_mem_by_imm                                          = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b111);

assign o_opcode_x86_SBB_reg_to_reg_mem                                          = (i_instruction[0][7:1] == 7'b0001_100 );
assign o_opcode_x86_SBB_reg_mem_to_reg                                          = (i_instruction[0][7:1] == 7'b0001_101 );
assign o_opcode_x86_SBB_imm_to_reg_mem                                          = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b011);
assign o_opcode_x86_SBB_imm_to_acc                                              = (i_instruction[0][7:1] == 7'b0001_110 );

assign o_opcode_x86_SCAS_scan_string                                            = (i_instruction[0][7:1] == 7'b1010_111 );

assign o_opcode_x86_SETcc_byte_set_on_condition                                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:4] == 4'b1001) & (i_instruction[2][5:3] == 3'b000);

assign o_opcode_x86_SGDT_store_global_descriptor_table_register                 = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001);

assign o_opcode_x86_SHL_reg_mem_by_1                                            = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_x86_SHL_reg_mem_by_CL                                           = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b100);
assign o_opcode_x86_SHL_reg_mem_by_imm                                          = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b100);

assign o_opcode_x86_SHLD_reg_mem_by_imm                                         = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_0100);
assign o_opcode_x86_SHLD_reg_mem_by_CL                                          = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_0101);

assign o_opcode_x86_SHR_reg_mem_by_1                                            = (i_instruction[0][7:1] == 7'b1101_000 ) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_x86_SHR_reg_mem_by_CL                                           = (i_instruction[0][7:1] == 7'b1101_001 ) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_x86_SHR_reg_mem_by_imm                                          = (i_instruction[0][7:1] == 7'b1100_000 ) & (i_instruction[1][5:3] == 3'b101);

assign o_opcode_x86_SHRD_reg_mem_by_imm                                         = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1100);
assign o_opcode_x86_SHRD_reg_mem_by_CL                                          = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1010_1101);

assign o_opcode_x86_SIDT_store_interrupt_desciptor_table_register               = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b001);

assign o_opcode_x86_SLDT_store_local_desciptor_table_register                   = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b000);

assign o_opcode_x86_SMSW_store_machine_status_word                              = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0001) & (i_instruction[2][5:3] == 3'b100);

assign o_opcode_x86_STC_set_carry_flag                                          = (i_instruction[0][7:0] == 8'b1111_1001);

assign o_opcode_x86_STD_set_direction_flag                                      = (i_instruction[0][7:0] == 8'b1111_1101);

assign o_opcode_x86_STI_set_interrupt_enable_flag                               = (i_instruction[0][7:0] == 8'b1111_1011);

assign o_opcode_x86_STOS_store_string_data                                      = (i_instruction[0][7:1] == 7'b1010_101 );

assign o_opcode_x86_STR_store_task_register                                     = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b001);

assign o_opcode_x86_SUB_reg_to_reg_mem                                          = (i_instruction[0][7:1] == 7'b0010_100 );
assign o_opcode_x86_SUB_reg_mem_to_reg                                          = (i_instruction[0][7:1] == 7'b0010_101 );
assign o_opcode_x86_SUB_imm_to_reg_mem                                          = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b101);
assign o_opcode_x86_SUB_imm_to_acc                                              = (i_instruction[0][7:1] == 7'b0010_110 );

assign o_opcode_x86_TEST_reg_mem_and_reg                                        = (i_instruction[0][7:1] == 7'b1000_010 );
assign o_opcode_x86_TEST_imm_and_reg_mem                                        = (i_instruction[0][7:1] == 7'b1111_011 ) & (i_instruction[1][5:3] == 3'b000);
assign o_opcode_x86_TEST_imm_and_acc                                            = (i_instruction[0][7:1] == 7'b1010_100 );

assign o_opcode_x86_UD0_undefined_instruction                                   = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1111_1111);
assign o_opcode_x86_UD1_undefined_instruction                                   = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b1111_1011);
assign o_opcode_x86_UD2_undefined_instruction                                   = (i_instruction[0][7:0] == 8'b0000_xxxx) & (i_instruction[1][7:0] == 8'b1111_1011);

assign o_opcode_x86_VERR_verify_a_segment_for_reading                           = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b100);
assign o_opcode_x86_VERW_verify_a_segment_for_writing                           = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_0000) & (i_instruction[2][5:3] == 3'b101);

assign o_opcode_x86_WAIT_wait                                                   = (i_instruction[0][7:0] == 8'b1001_1011);

assign o_opcode_x86_WBINVD_writeback_and_invalidate_data_cache                  = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0000_1001);

assign o_opcode_x86_WRMSR_write_to_model_specific_register                      = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:0] == 8'b0011_0000);

assign o_opcode_x86_XADD_exchange_and_add                                       = (i_instruction[0][7:0] == 8'b0000_1111) & (i_instruction[1][7:1] == 7'b1100_000);

assign o_opcode_x86_XCHG_reg_mem_with_reg                                       = (i_instruction[0][7:1] == 7'b1000_011 );
assign o_opcode_x86_XCHG_reg_with_acc_short                                     = (i_instruction[0][7:3] == 5'b1001_0   ) & (i_instruction[0][2:0] != 3'b000);

assign o_opcode_x86_XLAT_table_look_up_translation                              = (i_instruction[0][7:0] == 8'b1101_0111);

assign o_opcode_x86_XOR_reg_to_reg_mem                                          = (i_instruction[0][7:1] == 7'b0011_000 );
assign o_opcode_x86_XOR_reg_mem_to_reg                                          = (i_instruction[0][7:1] == 7'b0011_001 );
assign o_opcode_x86_XOR_imm_to_reg_mem                                          = (i_instruction[0][7:2] == 6'b1000_00  ) & (i_instruction[1][5:3] == 3'b110);
assign o_opcode_x86_XOR_imm_to_acc                                              = (i_instruction[0][7:1] == 7'b0011_010 );


// assign o_opcode_x86_processor_extension_escape          = (i_instruction[0][7:3] == 5'b1101_1   );
// ESC instruction is used for co-processor like X87 FPU, but now we dont need it. (actually I cant find this instruction opcode from the latest Intel SDM)

endmodule
