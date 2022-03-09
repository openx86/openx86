/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode unit
create at: 2022-01-04 03:27:51
description: decode unit module
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"

module decode (
    input  logic [ 7:0] i_instruction [0:15],
    input  logic        i_default_operand_size,
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
    output logic [ 3:0] o_tttn,
    output logic [ 2:0] o_eee,
    output logic        o_gen_reg_index_is_present,
    output logic [ 2:0] o_gen_reg_index,
    output logic        o_seg_reg_index_is_present,
    output logic [ 2:0] o_seg_reg_index,
    output logic [ 2:0] o_segment_reg_index,
    output logic        o_base_reg_is_present,
    output logic [ 2:0] o_base_reg_index,
    output logic        o_index_reg_is_present,
    output logic [ 2:0] o_index_reg_index,
    output logic        o_gen_reg_is_present_from_mod_rm,
    output logic [ 2:0] o_gen_reg_index_from_mod_rm,
    output logic [ 2:0] o_gen_reg_bit_width_from_mod_rm,
    output logic [31:0] o_displacement,
    output logic [31:0] o_immediate,
    output logic [ 3:0] o_consume_bytes,
    output logic        o_error
);

logic [ 7:0] prefix_instruction [0:3];
logic        prefix_o_group_1_lock_bus;
logic        prefix_o_group_1_repeat_not_equal;
logic        prefix_o_group_1_repeat_equal;
logic        prefix_o_group_1_bound;
logic        prefix_o_group_2_segment_override;
logic        prefix_o_group_2_hint_branch_not_taken;
logic        prefix_o_group_2_hint_branch_taken;
logic        prefix_o_group_3_operand_size;
logic        prefix_o_group_4_address_size;
logic        prefix_o_group_1_is_present;
logic        prefix_o_group_2_is_present;
logic        prefix_o_group_3_is_present;
logic        prefix_o_group_4_is_present;
logic [ 2:0] prefix_o_segment_override_index;
logic        prefix_o_consume_bytes_prefix_1;
logic        prefix_o_consume_bytes_prefix_2;
logic        prefix_o_consume_bytes_prefix_3;
logic        prefix_o_consume_bytes_prefix_4;
logic        prefix_o_error;
assign prefix_instruction = i_instruction[0:3];
decode_prefix_all deocde_decode_prefix_all (
    .i_instruction ( prefix_instruction ),
    .o_group_1_lock_bus ( prefix_o_group_1_lock_bus ),
    .o_group_1_repeat_not_equal ( prefix_o_group_1_repeat_not_equal ),
    .o_group_1_repeat_equal ( prefix_o_group_1_repeat_equal ),
    .o_group_1_bound ( prefix_o_group_1_bound ),
    .o_group_2_segment_override ( prefix_o_group_2_segment_override ),
    .o_group_2_hint_branch_not_taken ( prefix_o_group_2_hint_branch_not_taken ),
    .o_group_2_hint_branch_taken ( prefix_o_group_2_hint_branch_taken ),
    .o_group_3_operand_size ( prefix_o_group_3_operand_size ),
    .o_group_4_address_size ( prefix_o_group_4_address_size ),
    .o_group_1_is_present ( prefix_o_group_1_is_present ),
    .o_group_2_is_present ( prefix_o_group_2_is_present ),
    .o_group_3_is_present ( prefix_o_group_3_is_present ),
    .o_group_4_is_present ( prefix_o_group_4_is_present ),
    .o_segment_override_index ( prefix_o_segment_override_index ),
    .o_consume_bytes_prefix_1 ( prefix_o_consume_bytes_prefix_1 ),
    .o_consume_bytes_prefix_2 ( prefix_o_consume_bytes_prefix_2 ),
    .o_consume_bytes_prefix_3 ( prefix_o_consume_bytes_prefix_3 ),
    .o_consume_bytes_prefix_4 ( prefix_o_consume_bytes_prefix_4 ),
    .o_error ( prefix_o_error )
);
logic [ 3:0] offset_opcode;
always_comb begin
    unique case (1'b1)
        prefix_o_consume_bytes_prefix_1: offset_opcode <= 4'h1;
        prefix_o_consume_bytes_prefix_2: offset_opcode <= 4'h2;
        prefix_o_consume_bytes_prefix_3: offset_opcode <= 4'h3;
        prefix_o_consume_bytes_prefix_4: offset_opcode <= 4'h4;
        default                        : offset_opcode <= 4'h0;
    endcase
end

logic [ 7:0] opcode_instruction [0:3];
always_comb begin
    unique case (1'b1)
        prefix_o_consume_bytes_prefix_1: opcode_instruction <= i_instruction[1:1+3];
        prefix_o_consume_bytes_prefix_2: opcode_instruction <= i_instruction[2:2+3];
        prefix_o_consume_bytes_prefix_3: opcode_instruction <= i_instruction[3:3+3];
        prefix_o_consume_bytes_prefix_4: opcode_instruction <= i_instruction[4:4+3];
        default                        : opcode_instruction <= i_instruction[0:0+3];
    endcase
end
decode_opcode_x86 deocde_decode_opcode_x86 (
    .o_opcode_x86_AAA_ASCII_adjust_after_add ( o_opcode_x86_AAA_ASCII_adjust_after_add ),
    .o_opcode_x86_AAD_ASCII_AX_before_div ( o_opcode_x86_AAD_ASCII_AX_before_div ),
    .o_opcode_x86_AAM_ASCII_AX_after_mul ( o_opcode_x86_AAM_ASCII_AX_after_mul ),
    .o_opcode_x86_AAS_ASCII_adjust_after_sub ( o_opcode_x86_AAS_ASCII_adjust_after_sub ),
    .o_opcode_x86_ADC_reg_to_reg_mem ( o_opcode_x86_ADC_reg_to_reg_mem ),
    .o_opcode_x86_ADC_reg_mem_to_reg ( o_opcode_x86_ADC_reg_mem_to_reg ),
    .o_opcode_x86_ADC_imm_to_reg_mem ( o_opcode_x86_ADC_imm_to_reg_mem ),
    .o_opcode_x86_ADC_imm_to_acc ( o_opcode_x86_ADC_imm_to_acc ),
    .o_opcode_x86_ADD_reg_to_reg_mem ( o_opcode_x86_ADD_reg_to_reg_mem ),
    .o_opcode_x86_ADD_reg_mem_to_reg ( o_opcode_x86_ADD_reg_mem_to_reg ),
    .o_opcode_x86_ADD_imm_to_reg_mem ( o_opcode_x86_ADD_imm_to_reg_mem ),
    .o_opcode_x86_ADD_imm_to_acc ( o_opcode_x86_ADD_imm_to_acc ),
    .o_opcode_x86_AND_reg_to_reg_mem ( o_opcode_x86_AND_reg_to_reg_mem ),
    .o_opcode_x86_AND_reg_mem_to_reg ( o_opcode_x86_AND_reg_mem_to_reg ),
    .o_opcode_x86_AND_imm_to_reg_mem ( o_opcode_x86_AND_imm_to_reg_mem ),
    .o_opcode_x86_AND_imm_to_acc ( o_opcode_x86_AND_imm_to_acc ),
    .o_opcode_x86_ARPL_adjust_RPL_field_of_selector ( o_opcode_x86_ARPL_adjust_RPL_field_of_selector ),
    .o_opcode_x86_BOUND_check_array_against_bounds ( o_opcode_x86_BOUND_check_array_against_bounds ),
    .o_opcode_x86_BSF_bit_scan_forward ( o_opcode_x86_BSF_bit_scan_forward ),
    .o_opcode_x86_BSR_bit_scan_reverse ( o_opcode_x86_BSR_bit_scan_reverse ),
    .o_opcode_x86_BSWAP_byte_swap ( o_opcode_x86_BSWAP_byte_swap ),
    .o_opcode_x86_BT_reg_mem_with_imm ( o_opcode_x86_BT_reg_mem_with_imm ),
    .o_opcode_x86_BT_reg_mem_with_reg ( o_opcode_x86_BT_reg_mem_with_reg ),
    .o_opcode_x86_BTC_reg_mem_with_imm ( o_opcode_x86_BTC_reg_mem_with_imm ),
    .o_opcode_x86_BTC_reg_mem_with_reg ( o_opcode_x86_BTC_reg_mem_with_reg ),
    .o_opcode_x86_BTR_reg_mem_with_imm ( o_opcode_x86_BTR_reg_mem_with_imm ),
    .o_opcode_x86_BTR_reg_mem_with_reg ( o_opcode_x86_BTR_reg_mem_with_reg ),
    .o_opcode_x86_BTS_reg_mem_with_imm ( o_opcode_x86_BTS_reg_mem_with_imm ),
    .o_opcode_x86_BTS_reg_mem_with_reg ( o_opcode_x86_BTS_reg_mem_with_reg ),
    .o_opcode_x86_CALL_in_same_segment_direct ( o_opcode_x86_CALL_in_same_segment_direct ),
    .o_opcode_x86_CALL_in_same_segment_indirect ( o_opcode_x86_CALL_in_same_segment_indirect ),
    .o_opcode_x86_CALL_in_other_segment_direct ( o_opcode_x86_CALL_in_other_segment_direct ),
    .o_opcode_x86_CALL_in_other_segment_indirect ( o_opcode_x86_CALL_in_other_segment_indirect ),
    .o_opcode_x86_CBW_convert_byte_to_word ( o_opcode_x86_CBW_convert_byte_to_word ),
    .o_opcode_x86_CDQ_convert_double_word_to_quad_word ( o_opcode_x86_CDQ_convert_double_word_to_quad_word ),
    .o_opcode_x86_CLC_clear_carry_flag ( o_opcode_x86_CLC_clear_carry_flag ),
    .o_opcode_x86_CLD_clear_direction_flag ( o_opcode_x86_CLD_clear_direction_flag ),
    .o_opcode_x86_CLI_clear_interrupt_enable_flag ( o_opcode_x86_CLI_clear_interrupt_enable_flag ),
    .o_opcode_x86_CLTS_clear_task_switched_flag ( o_opcode_x86_CLTS_clear_task_switched_flag ),
    .o_opcode_x86_CMC_complement_carry_flag ( o_opcode_x86_CMC_complement_carry_flag ),
    .o_opcode_x86_CMP_mem_with_reg ( o_opcode_x86_CMP_mem_with_reg ),
    .o_opcode_x86_CMP_reg_with_mem ( o_opcode_x86_CMP_reg_with_mem ),
    .o_opcode_x86_CMP_imm_with_reg_mem ( o_opcode_x86_CMP_imm_with_reg_mem ),
    .o_opcode_x86_CMP_imm_with_acc ( o_opcode_x86_CMP_imm_with_acc ),
    .o_opcode_x86_CMPS_compare_string_operands ( o_opcode_x86_CMPS_compare_string_operands ),
    .o_opcode_x86_CMPXCHG_compare_and_exchange ( o_opcode_x86_CMPXCHG_compare_and_exchange ),
    .o_opcode_x86_CPUID_CPU_identification ( o_opcode_x86_CPUID_CPU_identification ),
    .o_opcode_x86_CWD_convert_word_to_double ( o_opcode_x86_CWD_convert_word_to_double ),
    .o_opcode_x86_CWDE_convert_word_to_double ( o_opcode_x86_CWDE_convert_word_to_double ),
    .o_opcode_x86_DAA_decimal_adjust_AL_after_add ( o_opcode_x86_DAA_decimal_adjust_AL_after_add ),
    .o_opcode_x86_DAS_decimal_adjust_AL_after_sub ( o_opcode_x86_DAS_decimal_adjust_AL_after_sub ),
    .o_opcode_x86_DEC_reg_mem ( o_opcode_x86_DEC_reg_mem ),
    .o_opcode_x86_DEC_reg ( o_opcode_x86_DEC_reg ),
    .o_opcode_x86_DIV_acc_by_reg_mem ( o_opcode_x86_DIV_acc_by_reg_mem ),
    .o_opcode_x86_HLT_halt ( o_opcode_x86_HLT_halt ),
    .o_opcode_x86_IDIV_acc_by_reg_mem ( o_opcode_x86_IDIV_acc_by_reg_mem ),
    .o_opcode_x86_IMUL_acc_with_reg_mem ( o_opcode_x86_IMUL_acc_with_reg_mem ),
    .o_opcode_x86_IMUL_reg_with_reg_mem ( o_opcode_x86_IMUL_reg_with_reg_mem ),
    .o_opcode_x86_IMUL_reg_mem_with_imm_to_reg ( o_opcode_x86_IMUL_reg_mem_with_imm_to_reg ),
    .o_opcode_x86_IN_port_fixed ( o_opcode_x86_IN_port_fixed ),
    .o_opcode_x86_IN_port_variable ( o_opcode_x86_IN_port_variable ),
    .o_opcode_x86_INC_reg_mem ( o_opcode_x86_INC_reg_mem ),
    .o_opcode_x86_INC_reg ( o_opcode_x86_INC_reg ),
    .o_opcode_x86_INS_input_from_DX_port ( o_opcode_x86_INS_input_from_DX_port ),
    .o_opcode_x86_INT_interrupt_type_n ( o_opcode_x86_INT_interrupt_type_n ),
    .o_opcode_x86_INT_interrupt_type_3 ( o_opcode_x86_INT_interrupt_type_3 ),
    .o_opcode_x86_INT_interrupt_type_4 ( o_opcode_x86_INT_interrupt_type_4 ),
    .o_opcode_x86_INVD_invalidate_cache ( o_opcode_x86_INVD_invalidate_cache ),
    .o_opcode_x86_INVLPG_invalidate_TLB_entry ( o_opcode_x86_INVLPG_invalidate_TLB_entry ),
    .o_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size ( o_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size ),
    .o_opcode_x86_IRET_interrupt_return ( o_opcode_x86_IRET_interrupt_return ),
    .o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp ( o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp ),
    .o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp ( o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp ),
    .o_opcode_x86_JCXZ_jump_on_CX_zero ( o_opcode_x86_JCXZ_jump_on_CX_zero ),
    .o_opcode_x86_JMP_to_same_segment_short ( o_opcode_x86_JMP_to_same_segment_short ),
    .o_opcode_x86_JMP_to_same_segment_direct ( o_opcode_x86_JMP_to_same_segment_direct ),
    .o_opcode_x86_JMP_to_same_segment_indirect ( o_opcode_x86_JMP_to_same_segment_indirect ),
    .o_opcode_x86_JMP_to_other_segment_direct ( o_opcode_x86_JMP_to_other_segment_direct ),
    .o_opcode_x86_JMP_to_other_segment_indirect ( o_opcode_x86_JMP_to_other_segment_indirect ),
    .o_opcode_x86_LAHF_load_FLAG_into_AH ( o_opcode_x86_LAHF_load_FLAG_into_AH ),
    .o_opcode_x86_LAR_load_access_rights_byte ( o_opcode_x86_LAR_load_access_rights_byte ),
    .o_opcode_x86_LDS_load_pointer_to_DS ( o_opcode_x86_LDS_load_pointer_to_DS ),
    .o_opcode_x86_LEA_load_effective_adddress_to_reg ( o_opcode_x86_LEA_load_effective_adddress_to_reg ),
    .o_opcode_x86_LEAVE_high_level_procedure_exit ( o_opcode_x86_LEAVE_high_level_procedure_exit ),
    .o_opcode_x86_LES_load_pointer_to_ES ( o_opcode_x86_LES_load_pointer_to_ES ),
    .o_opcode_x86_LFS_load_pointer_to_FS ( o_opcode_x86_LFS_load_pointer_to_FS ),
    .o_opcode_x86_LGDT_load_global_desciptor_table_reg ( o_opcode_x86_LGDT_load_global_desciptor_table_reg ),
    .o_opcode_x86_LGS_load_pointer_to_GS ( o_opcode_x86_LGS_load_pointer_to_GS ),
    .o_opcode_x86_LIDT_load_interrupt_desciptor_table_reg ( o_opcode_x86_LIDT_load_interrupt_desciptor_table_reg ),
    .o_opcode_x86_LLDT_load_local_desciptor_table_reg ( o_opcode_x86_LLDT_load_local_desciptor_table_reg ),
    .o_opcode_x86_LMSW_load_status_word ( o_opcode_x86_LMSW_load_status_word ),
    .o_opcode_x86_LODS_load_string_operand ( o_opcode_x86_LODS_load_string_operand ),
    .o_opcode_x86_LOOP_count ( o_opcode_x86_LOOP_count ),
    .o_opcode_x86_LOOPZ_count_while_zero ( o_opcode_x86_LOOPZ_count_while_zero ),
    .o_opcode_x86_LOOPNZ_count_while_not_zero ( o_opcode_x86_LOOPNZ_count_while_not_zero ),
    .o_opcode_x86_LSL_load_segment_limit ( o_opcode_x86_LSL_load_segment_limit ),
    .o_opcode_x86_LSS_load_pointer_to_SS ( o_opcode_x86_LSS_load_pointer_to_SS ),
    .o_opcode_x86_LTR_load_task_register ( o_opcode_x86_LTR_load_task_register ),
    .o_opcode_x86_MOV_reg_to_reg_mem ( o_opcode_x86_MOV_reg_to_reg_mem ),
    .o_opcode_x86_MOV_reg_mem_to_reg ( o_opcode_x86_MOV_reg_mem_to_reg ),
    .o_opcode_x86_MOV_imm_to_reg_mem ( o_opcode_x86_MOV_imm_to_reg_mem ),
    .o_opcode_x86_MOV_imm_to_reg ( o_opcode_x86_MOV_imm_to_reg ),
    .o_opcode_x86_MOV_mem_to_acc ( o_opcode_x86_MOV_mem_to_acc ),
    .o_opcode_x86_MOV_acc_to_mem ( o_opcode_x86_MOV_acc_to_mem ),
    .o_opcode_x86_MOV_CR_from_reg ( o_opcode_x86_MOV_CR_from_reg ),
    .o_opcode_x86_MOV_reg_from_CR ( o_opcode_x86_MOV_reg_from_CR ),
    .o_opcode_x86_MOV_DR_from_reg ( o_opcode_x86_MOV_DR_from_reg ),
    .o_opcode_x86_MOV_reg_from_DR ( o_opcode_x86_MOV_reg_from_DR ),
    .o_opcode_x86_MOV_TR_from_reg ( o_opcode_x86_MOV_TR_from_reg ),
    .o_opcode_x86_MOV_reg_from_TR ( o_opcode_x86_MOV_reg_from_TR ),
    .o_opcode_x86_MOV_reg_mem_to_sreg ( o_opcode_x86_MOV_reg_mem_to_sreg ),
    .o_opcode_x86_MOV_sreg_to_reg_mem ( o_opcode_x86_MOV_sreg_to_reg_mem ),
    .o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg ( o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg ),
    .o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem ( o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem ),
    .o_opcode_x86_MOVS_move_data_from_string_to_string ( o_opcode_x86_MOVS_move_data_from_string_to_string ),
    .o_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg ( o_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg ),
    .o_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg ( o_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg ),
    .o_opcode_x86_MUL_acc_with_reg_mem ( o_opcode_x86_MUL_acc_with_reg_mem ),
    .o_opcode_x86_NEG_two_s_complement_negation ( o_opcode_x86_NEG_two_s_complement_negation ),
    .o_opcode_x86_NOP_no_operation ( o_opcode_x86_NOP_no_operation ),
    .o_opcode_x86_NOP_no_operation_multi_byte ( o_opcode_x86_NOP_no_operation_multi_byte ),
    .o_opcode_x86_NOT_one_s_complement_negation ( o_opcode_x86_NOT_one_s_complement_negation ),
    .o_opcode_x86_OR_reg_to_reg_mem ( o_opcode_x86_OR_reg_to_reg_mem ),
    .o_opcode_x86_OR_reg_mem_to_reg ( o_opcode_x86_OR_reg_mem_to_reg ),
    .o_opcode_x86_OR_imm_to_reg_mem ( o_opcode_x86_OR_imm_to_reg_mem ),
    .o_opcode_x86_OR_imm_to_acc ( o_opcode_x86_OR_imm_to_acc ),
    .o_opcode_x86_OUT_port_fixed ( o_opcode_x86_OUT_port_fixed ),
    .o_opcode_x86_OUT_port_variable ( o_opcode_x86_OUT_port_variable ),
    .o_opcode_x86_OUTS_output_string ( o_opcode_x86_OUTS_output_string ),
    .o_opcode_x86_POP_reg_mem ( o_opcode_x86_POP_reg_mem ),
    .o_opcode_x86_POP_reg ( o_opcode_x86_POP_reg ),
    .o_opcode_x86_POP_sreg_2 ( o_opcode_x86_POP_sreg_2 ),
    .o_opcode_x86_POP_sreg_3 ( o_opcode_x86_POP_sreg_3 ),
    .o_opcode_x86_POPA_pop_all_general_registers ( o_opcode_x86_POPA_pop_all_general_registers ),
    .o_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS ( o_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS ),
    .o_opcode_x86_PUSH_reg_mem ( o_opcode_x86_PUSH_reg_mem ),
    .o_opcode_x86_PUSH_reg ( o_opcode_x86_PUSH_reg ),
    .o_opcode_x86_PUSH_sreg_2 ( o_opcode_x86_PUSH_sreg_2 ),
    .o_opcode_x86_PUSH_sreg_3 ( o_opcode_x86_PUSH_sreg_3 ),
    .o_opcode_x86_PUSH_imm ( o_opcode_x86_PUSH_imm ),
    .o_opcode_x86_PUSH_all_general_registers ( o_opcode_x86_PUSH_all_general_registers ),
    .o_opcode_x86_PUSHF_push_flags_onto_stack ( o_opcode_x86_PUSHF_push_flags_onto_stack ),
    .o_opcode_x86_RCL_reg_mem_by_1 ( o_opcode_x86_RCL_reg_mem_by_1 ),
    .o_opcode_x86_RCL_reg_mem_by_CL ( o_opcode_x86_RCL_reg_mem_by_CL ),
    .o_opcode_x86_RCL_reg_mem_by_imm ( o_opcode_x86_RCL_reg_mem_by_imm ),
    .o_opcode_x86_RCR_reg_mem_by_1 ( o_opcode_x86_RCR_reg_mem_by_1 ),
    .o_opcode_x86_RCR_reg_mem_by_CL ( o_opcode_x86_RCR_reg_mem_by_CL ),
    .o_opcode_x86_RCR_reg_mem_by_imm ( o_opcode_x86_RCR_reg_mem_by_imm ),
    .o_opcode_x86_RDMSR_read_from_model_specific_reg ( o_opcode_x86_RDMSR_read_from_model_specific_reg ),
    .o_opcode_x86_RDPMC_read_performance_monitoring_counters ( o_opcode_x86_RDPMC_read_performance_monitoring_counters ),
    .o_opcode_x86_RDTSC_read_time_stamp_counter ( o_opcode_x86_RDTSC_read_time_stamp_counter ),
    .o_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id ( o_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id ),
    .o_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument ( o_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument ),
    .o_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP ( o_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP ),
    .o_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument ( o_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument ),
    .o_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP ( o_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP ),
    .o_opcode_x86_ROL_reg_mem_by_1 ( o_opcode_x86_ROL_reg_mem_by_1 ),
    .o_opcode_x86_ROL_reg_mem_by_CL ( o_opcode_x86_ROL_reg_mem_by_CL ),
    .o_opcode_x86_ROL_reg_mem_by_imm ( o_opcode_x86_ROL_reg_mem_by_imm ),
    .o_opcode_x86_ROR_reg_mem_by_1 ( o_opcode_x86_ROR_reg_mem_by_1 ),
    .o_opcode_x86_ROR_reg_mem_by_CL ( o_opcode_x86_ROR_reg_mem_by_CL ),
    .o_opcode_x86_ROR_reg_mem_by_imm ( o_opcode_x86_ROR_reg_mem_by_imm ),
    .o_opcode_x86_RSM_resume_from_system_management_mode ( o_opcode_x86_RSM_resume_from_system_management_mode ),
    .o_opcode_x86_SAHF_store_AH_into_flags ( o_opcode_x86_SAHF_store_AH_into_flags ),
    .o_opcode_x86_SAR_reg_mem_by_1 ( o_opcode_x86_SAR_reg_mem_by_1 ),
    .o_opcode_x86_SAR_reg_mem_by_CL ( o_opcode_x86_SAR_reg_mem_by_CL ),
    .o_opcode_x86_SAR_reg_mem_by_imm ( o_opcode_x86_SAR_reg_mem_by_imm ),
    .o_opcode_x86_SBB_reg_to_reg_mem ( o_opcode_x86_SBB_reg_to_reg_mem ),
    .o_opcode_x86_SBB_reg_mem_to_reg ( o_opcode_x86_SBB_reg_mem_to_reg ),
    .o_opcode_x86_SBB_imm_to_reg_mem ( o_opcode_x86_SBB_imm_to_reg_mem ),
    .o_opcode_x86_SBB_imm_to_acc ( o_opcode_x86_SBB_imm_to_acc ),
    .o_opcode_x86_SCAS_scan_string ( o_opcode_x86_SCAS_scan_string ),
    .o_opcode_x86_SETcc_byte_set_on_condition ( o_opcode_x86_SETcc_byte_set_on_condition ),
    .o_opcode_x86_SGDT_store_global_descriptor_table_register ( o_opcode_x86_SGDT_store_global_descriptor_table_register ),
    .o_opcode_x86_SHL_reg_mem_by_1 ( o_opcode_x86_SHL_reg_mem_by_1 ),
    .o_opcode_x86_SHL_reg_mem_by_CL ( o_opcode_x86_SHL_reg_mem_by_CL ),
    .o_opcode_x86_SHL_reg_mem_by_imm ( o_opcode_x86_SHL_reg_mem_by_imm ),
    .o_opcode_x86_SHLD_reg_mem_by_imm ( o_opcode_x86_SHLD_reg_mem_by_imm ),
    .o_opcode_x86_SHLD_reg_mem_by_CL ( o_opcode_x86_SHLD_reg_mem_by_CL ),
    .o_opcode_x86_SHR_reg_mem_by_1 ( o_opcode_x86_SHR_reg_mem_by_1 ),
    .o_opcode_x86_SHR_reg_mem_by_CL ( o_opcode_x86_SHR_reg_mem_by_CL ),
    .o_opcode_x86_SHR_reg_mem_by_imm ( o_opcode_x86_SHR_reg_mem_by_imm ),
    .o_opcode_x86_SHRD_reg_mem_by_imm ( o_opcode_x86_SHRD_reg_mem_by_imm ),
    .o_opcode_x86_SHRD_reg_mem_by_CL ( o_opcode_x86_SHRD_reg_mem_by_CL ),
    .o_opcode_x86_SIDT_store_interrupt_desciptor_table_register ( o_opcode_x86_SIDT_store_interrupt_desciptor_table_register ),
    .o_opcode_x86_SLDT_store_local_desciptor_table_register ( o_opcode_x86_SLDT_store_local_desciptor_table_register ),
    .o_opcode_x86_SMSW_store_machine_status_word ( o_opcode_x86_SMSW_store_machine_status_word ),
    .o_opcode_x86_STC_set_carry_flag ( o_opcode_x86_STC_set_carry_flag ),
    .o_opcode_x86_STD_set_direction_flag ( o_opcode_x86_STD_set_direction_flag ),
    .o_opcode_x86_STI_set_interrupt_enable_flag ( o_opcode_x86_STI_set_interrupt_enable_flag ),
    .o_opcode_x86_STOS_store_string_data ( o_opcode_x86_STOS_store_string_data ),
    .o_opcode_x86_STR_store_task_register ( o_opcode_x86_STR_store_task_register ),
    .o_opcode_x86_SUB_reg_to_reg_mem ( o_opcode_x86_SUB_reg_to_reg_mem ),
    .o_opcode_x86_SUB_reg_mem_to_reg ( o_opcode_x86_SUB_reg_mem_to_reg ),
    .o_opcode_x86_SUB_imm_to_reg_mem ( o_opcode_x86_SUB_imm_to_reg_mem ),
    .o_opcode_x86_SUB_imm_to_acc ( o_opcode_x86_SUB_imm_to_acc ),
    .o_opcode_x86_TEST_reg_mem_and_reg ( o_opcode_x86_TEST_reg_mem_and_reg ),
    .o_opcode_x86_TEST_imm_and_reg_mem ( o_opcode_x86_TEST_imm_and_reg_mem ),
    .o_opcode_x86_TEST_imm_and_acc ( o_opcode_x86_TEST_imm_and_acc ),
    .o_opcode_x86_UD0_undefined_instruction ( o_opcode_x86_UD0_undefined_instruction ),
    .o_opcode_x86_UD1_undefined_instruction ( o_opcode_x86_UD1_undefined_instruction ),
    .o_opcode_x86_UD2_undefined_instruction ( o_opcode_x86_UD2_undefined_instruction ),
    .o_opcode_x86_VERR_verify_a_segment_for_reading ( o_opcode_x86_VERR_verify_a_segment_for_reading ),
    .o_opcode_x86_VERW_verify_a_segment_for_writing ( o_opcode_x86_VERW_verify_a_segment_for_writing ),
    .o_opcode_x86_WAIT_wait ( o_opcode_x86_WAIT_wait ),
    .o_opcode_x86_WBINVD_writeback_and_invalidate_data_cache ( o_opcode_x86_WBINVD_writeback_and_invalidate_data_cache ),
    .o_opcode_x86_WRMSR_write_to_model_specific_register ( o_opcode_x86_WRMSR_write_to_model_specific_register ),
    .o_opcode_x86_XADD_exchange_and_add ( o_opcode_x86_XADD_exchange_and_add ),
    .o_opcode_x86_XCHG_reg_mem_with_reg ( o_opcode_x86_XCHG_reg_mem_with_reg ),
    .o_opcode_x86_XCHG_reg_with_acc_short ( o_opcode_x86_XCHG_reg_with_acc_short ),
    .o_opcode_x86_XLAT_table_look_up_translation ( o_opcode_x86_XLAT_table_look_up_translation ),
    .o_opcode_x86_XOR_reg_to_reg_mem ( o_opcode_x86_XOR_reg_to_reg_mem ),
    .o_opcode_x86_XOR_reg_mem_to_reg ( o_opcode_x86_XOR_reg_mem_to_reg ),
    .o_opcode_x86_XOR_imm_to_reg_mem ( o_opcode_x86_XOR_imm_to_reg_mem ),
    .o_opcode_x86_XOR_imm_to_acc ( o_opcode_x86_XOR_imm_to_acc ),
    .i_instruction ( opcode_instruction )
);

logic [ 7:0] field_instruction [0:3];
logic [ 3:0] field_o_tttn;
logic        field_o_gen_reg_index_is_present;
logic [ 2:0] field_o_gen_reg_index;
logic        field_o_seg_reg_index_is_present;
logic [ 2:0] field_o_seg_reg_index;
logic        field_o_w_is_present;
logic        field_o_w;
logic        field_o_s_is_present;
logic        field_o_s;
logic [ 2:0] field_o_eee;
logic        field_o_mod_rm_is_present;
logic [ 1:0] field_o_mod;
logic [ 2:0] field_o_rm;
logic        field_o_immediate_size_full;
logic        field_o_immediate_size_16;
logic        field_o_immediate_size_8;
logic        field_o_immediate_is_present;
logic        field_o_displacement_size_full;
logic        field_o_displacement_size_8;
logic        field_o_displacement_is_present;
logic        field_o_primary_opcode_byte_1;
logic        field_o_primary_opcode_byte_2;
logic        field_o_primary_opcode_byte_3;
logic        field_o_error;
assign field_instruction = opcode_instruction;
decode_field deocde_decode_field (
    .i_instruction ( field_instruction ),
    .i_opcode_x86_AAA_ASCII_adjust_after_add ( o_opcode_x86_AAA_ASCII_adjust_after_add ),
    .i_opcode_x86_AAD_ASCII_AX_before_div ( o_opcode_x86_AAD_ASCII_AX_before_div ),
    .i_opcode_x86_AAM_ASCII_AX_after_mul ( o_opcode_x86_AAM_ASCII_AX_after_mul ),
    .i_opcode_x86_AAS_ASCII_adjust_after_sub ( o_opcode_x86_AAS_ASCII_adjust_after_sub ),
    .i_opcode_x86_ADC_reg_to_reg_mem ( o_opcode_x86_ADC_reg_to_reg_mem ),
    .i_opcode_x86_ADC_reg_mem_to_reg ( o_opcode_x86_ADC_reg_mem_to_reg ),
    .i_opcode_x86_ADC_imm_to_reg_mem ( o_opcode_x86_ADC_imm_to_reg_mem ),
    .i_opcode_x86_ADC_imm_to_acc ( o_opcode_x86_ADC_imm_to_acc ),
    .i_opcode_x86_ADD_reg_to_reg_mem ( o_opcode_x86_ADD_reg_to_reg_mem ),
    .i_opcode_x86_ADD_reg_mem_to_reg ( o_opcode_x86_ADD_reg_mem_to_reg ),
    .i_opcode_x86_ADD_imm_to_reg_mem ( o_opcode_x86_ADD_imm_to_reg_mem ),
    .i_opcode_x86_ADD_imm_to_acc ( o_opcode_x86_ADD_imm_to_acc ),
    .i_opcode_x86_AND_reg_to_reg_mem ( o_opcode_x86_AND_reg_to_reg_mem ),
    .i_opcode_x86_AND_reg_mem_to_reg ( o_opcode_x86_AND_reg_mem_to_reg ),
    .i_opcode_x86_AND_imm_to_reg_mem ( o_opcode_x86_AND_imm_to_reg_mem ),
    .i_opcode_x86_AND_imm_to_acc ( o_opcode_x86_AND_imm_to_acc ),
    .i_opcode_x86_ARPL_adjust_RPL_field_of_selector ( o_opcode_x86_ARPL_adjust_RPL_field_of_selector ),
    .i_opcode_x86_BOUND_check_array_against_bounds ( o_opcode_x86_BOUND_check_array_against_bounds ),
    .i_opcode_x86_BSF_bit_scan_forward ( o_opcode_x86_BSF_bit_scan_forward ),
    .i_opcode_x86_BSR_bit_scan_reverse ( o_opcode_x86_BSR_bit_scan_reverse ),
    .i_opcode_x86_BSWAP_byte_swap ( o_opcode_x86_BSWAP_byte_swap ),
    .i_opcode_x86_BT_reg_mem_with_imm ( o_opcode_x86_BT_reg_mem_with_imm ),
    .i_opcode_x86_BT_reg_mem_with_reg ( o_opcode_x86_BT_reg_mem_with_reg ),
    .i_opcode_x86_BTC_reg_mem_with_imm ( o_opcode_x86_BTC_reg_mem_with_imm ),
    .i_opcode_x86_BTC_reg_mem_with_reg ( o_opcode_x86_BTC_reg_mem_with_reg ),
    .i_opcode_x86_BTR_reg_mem_with_imm ( o_opcode_x86_BTR_reg_mem_with_imm ),
    .i_opcode_x86_BTR_reg_mem_with_reg ( o_opcode_x86_BTR_reg_mem_with_reg ),
    .i_opcode_x86_BTS_reg_mem_with_imm ( o_opcode_x86_BTS_reg_mem_with_imm ),
    .i_opcode_x86_BTS_reg_mem_with_reg ( o_opcode_x86_BTS_reg_mem_with_reg ),
    .i_opcode_x86_CALL_in_same_segment_direct ( o_opcode_x86_CALL_in_same_segment_direct ),
    .i_opcode_x86_CALL_in_same_segment_indirect ( o_opcode_x86_CALL_in_same_segment_indirect ),
    .i_opcode_x86_CALL_in_other_segment_direct ( o_opcode_x86_CALL_in_other_segment_direct ),
    .i_opcode_x86_CALL_in_other_segment_indirect ( o_opcode_x86_CALL_in_other_segment_indirect ),
    .i_opcode_x86_CBW_convert_byte_to_word ( o_opcode_x86_CBW_convert_byte_to_word ),
    .i_opcode_x86_CDQ_convert_double_word_to_quad_word ( o_opcode_x86_CDQ_convert_double_word_to_quad_word ),
    .i_opcode_x86_CLC_clear_carry_flag ( o_opcode_x86_CLC_clear_carry_flag ),
    .i_opcode_x86_CLD_clear_direction_flag ( o_opcode_x86_CLD_clear_direction_flag ),
    .i_opcode_x86_CLI_clear_interrupt_enable_flag ( o_opcode_x86_CLI_clear_interrupt_enable_flag ),
    .i_opcode_x86_CLTS_clear_task_switched_flag ( o_opcode_x86_CLTS_clear_task_switched_flag ),
    .i_opcode_x86_CMC_complement_carry_flag ( o_opcode_x86_CMC_complement_carry_flag ),
    .i_opcode_x86_CMP_mem_with_reg ( o_opcode_x86_CMP_mem_with_reg ),
    .i_opcode_x86_CMP_reg_with_mem ( o_opcode_x86_CMP_reg_with_mem ),
    .i_opcode_x86_CMP_imm_with_reg_mem ( o_opcode_x86_CMP_imm_with_reg_mem ),
    .i_opcode_x86_CMP_imm_with_acc ( o_opcode_x86_CMP_imm_with_acc ),
    .i_opcode_x86_CMPS_compare_string_operands ( o_opcode_x86_CMPS_compare_string_operands ),
    .i_opcode_x86_CMPXCHG_compare_and_exchange ( o_opcode_x86_CMPXCHG_compare_and_exchange ),
    .i_opcode_x86_CPUID_CPU_identification ( o_opcode_x86_CPUID_CPU_identification ),
    .i_opcode_x86_CWD_convert_word_to_double ( o_opcode_x86_CWD_convert_word_to_double ),
    .i_opcode_x86_CWDE_convert_word_to_double ( o_opcode_x86_CWDE_convert_word_to_double ),
    .i_opcode_x86_DAA_decimal_adjust_AL_after_add ( o_opcode_x86_DAA_decimal_adjust_AL_after_add ),
    .i_opcode_x86_DAS_decimal_adjust_AL_after_sub ( o_opcode_x86_DAS_decimal_adjust_AL_after_sub ),
    .i_opcode_x86_DEC_reg_mem ( o_opcode_x86_DEC_reg_mem ),
    .i_opcode_x86_DEC_reg ( o_opcode_x86_DEC_reg ),
    .i_opcode_x86_DIV_acc_by_reg_mem ( o_opcode_x86_DIV_acc_by_reg_mem ),
    .i_opcode_x86_HLT_halt ( o_opcode_x86_HLT_halt ),
    .i_opcode_x86_IDIV_acc_by_reg_mem ( o_opcode_x86_IDIV_acc_by_reg_mem ),
    .i_opcode_x86_IMUL_acc_with_reg_mem ( o_opcode_x86_IMUL_acc_with_reg_mem ),
    .i_opcode_x86_IMUL_reg_with_reg_mem ( o_opcode_x86_IMUL_reg_with_reg_mem ),
    .i_opcode_x86_IMUL_reg_mem_with_imm_to_reg ( o_opcode_x86_IMUL_reg_mem_with_imm_to_reg ),
    .i_opcode_x86_IN_port_fixed ( o_opcode_x86_IN_port_fixed ),
    .i_opcode_x86_IN_port_variable ( o_opcode_x86_IN_port_variable ),
    .i_opcode_x86_INC_reg_mem ( o_opcode_x86_INC_reg_mem ),
    .i_opcode_x86_INC_reg ( o_opcode_x86_INC_reg ),
    .i_opcode_x86_INS_input_from_DX_port ( o_opcode_x86_INS_input_from_DX_port ),
    .i_opcode_x86_INT_interrupt_type_n ( o_opcode_x86_INT_interrupt_type_n ),
    .i_opcode_x86_INT_interrupt_type_3 ( o_opcode_x86_INT_interrupt_type_3 ),
    .i_opcode_x86_INT_interrupt_type_4 ( o_opcode_x86_INT_interrupt_type_4 ),
    .i_opcode_x86_INVD_invalidate_cache ( o_opcode_x86_INVD_invalidate_cache ),
    .i_opcode_x86_INVLPG_invalidate_TLB_entry ( o_opcode_x86_INVLPG_invalidate_TLB_entry ),
    .i_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size ( o_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size ),
    .i_opcode_x86_IRET_interrupt_return ( o_opcode_x86_IRET_interrupt_return ),
    .i_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp ( o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp ),
    .i_opcode_x86_Jcc_jump_if_cond_is_met_full_disp ( o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp ),
    .i_opcode_x86_JCXZ_jump_on_CX_zero ( o_opcode_x86_JCXZ_jump_on_CX_zero ),
    .i_opcode_x86_JMP_to_same_segment_short ( o_opcode_x86_JMP_to_same_segment_short ),
    .i_opcode_x86_JMP_to_same_segment_direct ( o_opcode_x86_JMP_to_same_segment_direct ),
    .i_opcode_x86_JMP_to_same_segment_indirect ( o_opcode_x86_JMP_to_same_segment_indirect ),
    .i_opcode_x86_JMP_to_other_segment_direct ( o_opcode_x86_JMP_to_other_segment_direct ),
    .i_opcode_x86_JMP_to_other_segment_indirect ( o_opcode_x86_JMP_to_other_segment_indirect ),
    .i_opcode_x86_LAHF_load_FLAG_into_AH ( o_opcode_x86_LAHF_load_FLAG_into_AH ),
    .i_opcode_x86_LAR_load_access_rights_byte ( o_opcode_x86_LAR_load_access_rights_byte ),
    .i_opcode_x86_LDS_load_pointer_to_DS ( o_opcode_x86_LDS_load_pointer_to_DS ),
    .i_opcode_x86_LEA_load_effective_adddress_to_reg ( o_opcode_x86_LEA_load_effective_adddress_to_reg ),
    .i_opcode_x86_LEAVE_high_level_procedure_exit ( o_opcode_x86_LEAVE_high_level_procedure_exit ),
    .i_opcode_x86_LES_load_pointer_to_ES ( o_opcode_x86_LES_load_pointer_to_ES ),
    .i_opcode_x86_LFS_load_pointer_to_FS ( o_opcode_x86_LFS_load_pointer_to_FS ),
    .i_opcode_x86_LGDT_load_global_desciptor_table_reg ( o_opcode_x86_LGDT_load_global_desciptor_table_reg ),
    .i_opcode_x86_LGS_load_pointer_to_GS ( o_opcode_x86_LGS_load_pointer_to_GS ),
    .i_opcode_x86_LIDT_load_interrupt_desciptor_table_reg ( o_opcode_x86_LIDT_load_interrupt_desciptor_table_reg ),
    .i_opcode_x86_LLDT_load_local_desciptor_table_reg ( o_opcode_x86_LLDT_load_local_desciptor_table_reg ),
    .i_opcode_x86_LMSW_load_status_word ( o_opcode_x86_LMSW_load_status_word ),
    .i_opcode_x86_LODS_load_string_operand ( o_opcode_x86_LODS_load_string_operand ),
    .i_opcode_x86_LOOP_count ( o_opcode_x86_LOOP_count ),
    .i_opcode_x86_LOOPZ_count_while_zero ( o_opcode_x86_LOOPZ_count_while_zero ),
    .i_opcode_x86_LOOPNZ_count_while_not_zero ( o_opcode_x86_LOOPNZ_count_while_not_zero ),
    .i_opcode_x86_LSL_load_segment_limit ( o_opcode_x86_LSL_load_segment_limit ),
    .i_opcode_x86_LSS_load_pointer_to_SS ( o_opcode_x86_LSS_load_pointer_to_SS ),
    .i_opcode_x86_LTR_load_task_register ( o_opcode_x86_LTR_load_task_register ),
    .i_opcode_x86_MOV_reg_to_reg_mem ( o_opcode_x86_MOV_reg_to_reg_mem ),
    .i_opcode_x86_MOV_reg_mem_to_reg ( o_opcode_x86_MOV_reg_mem_to_reg ),
    .i_opcode_x86_MOV_imm_to_reg_mem ( o_opcode_x86_MOV_imm_to_reg_mem ),
    .i_opcode_x86_MOV_imm_to_reg ( o_opcode_x86_MOV_imm_to_reg ),
    .i_opcode_x86_MOV_mem_to_acc ( o_opcode_x86_MOV_mem_to_acc ),
    .i_opcode_x86_MOV_acc_to_mem ( o_opcode_x86_MOV_acc_to_mem ),
    .i_opcode_x86_MOV_CR_from_reg ( o_opcode_x86_MOV_CR_from_reg ),
    .i_opcode_x86_MOV_reg_from_CR ( o_opcode_x86_MOV_reg_from_CR ),
    .i_opcode_x86_MOV_DR_from_reg ( o_opcode_x86_MOV_DR_from_reg ),
    .i_opcode_x86_MOV_reg_from_DR ( o_opcode_x86_MOV_reg_from_DR ),
    .i_opcode_x86_MOV_TR_from_reg ( o_opcode_x86_MOV_TR_from_reg ),
    .i_opcode_x86_MOV_reg_from_TR ( o_opcode_x86_MOV_reg_from_TR ),
    .i_opcode_x86_MOV_reg_mem_to_sreg ( o_opcode_x86_MOV_reg_mem_to_sreg ),
    .i_opcode_x86_MOV_sreg_to_reg_mem ( o_opcode_x86_MOV_sreg_to_reg_mem ),
    .i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg ( o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg ),
    .i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem ( o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem ),
    .i_opcode_x86_MOVS_move_data_from_string_to_string ( o_opcode_x86_MOVS_move_data_from_string_to_string ),
    .i_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg ( o_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg ),
    .i_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg ( o_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg ),
    .i_opcode_x86_MUL_acc_with_reg_mem ( o_opcode_x86_MUL_acc_with_reg_mem ),
    .i_opcode_x86_NEG_two_s_complement_negation ( o_opcode_x86_NEG_two_s_complement_negation ),
    .i_opcode_x86_NOP_no_operation ( o_opcode_x86_NOP_no_operation ),
    .i_opcode_x86_NOP_no_operation_multi_byte ( o_opcode_x86_NOP_no_operation_multi_byte ),
    .i_opcode_x86_NOT_one_s_complement_negation ( o_opcode_x86_NOT_one_s_complement_negation ),
    .i_opcode_x86_OR_reg_to_reg_mem ( o_opcode_x86_OR_reg_to_reg_mem ),
    .i_opcode_x86_OR_reg_mem_to_reg ( o_opcode_x86_OR_reg_mem_to_reg ),
    .i_opcode_x86_OR_imm_to_reg_mem ( o_opcode_x86_OR_imm_to_reg_mem ),
    .i_opcode_x86_OR_imm_to_acc ( o_opcode_x86_OR_imm_to_acc ),
    .i_opcode_x86_OUT_port_fixed ( o_opcode_x86_OUT_port_fixed ),
    .i_opcode_x86_OUT_port_variable ( o_opcode_x86_OUT_port_variable ),
    .i_opcode_x86_OUTS_output_string ( o_opcode_x86_OUTS_output_string ),
    .i_opcode_x86_POP_reg_mem ( o_opcode_x86_POP_reg_mem ),
    .i_opcode_x86_POP_reg ( o_opcode_x86_POP_reg ),
    .i_opcode_x86_POP_sreg_2 ( o_opcode_x86_POP_sreg_2 ),
    .i_opcode_x86_POP_sreg_3 ( o_opcode_x86_POP_sreg_3 ),
    .i_opcode_x86_POPA_pop_all_general_registers ( o_opcode_x86_POPA_pop_all_general_registers ),
    .i_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS ( o_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS ),
    .i_opcode_x86_PUSH_reg_mem ( o_opcode_x86_PUSH_reg_mem ),
    .i_opcode_x86_PUSH_reg ( o_opcode_x86_PUSH_reg ),
    .i_opcode_x86_PUSH_sreg_2 ( o_opcode_x86_PUSH_sreg_2 ),
    .i_opcode_x86_PUSH_sreg_3 ( o_opcode_x86_PUSH_sreg_3 ),
    .i_opcode_x86_PUSH_imm ( o_opcode_x86_PUSH_imm ),
    .i_opcode_x86_PUSH_all_general_registers ( o_opcode_x86_PUSH_all_general_registers ),
    .i_opcode_x86_PUSHF_push_flags_onto_stack ( o_opcode_x86_PUSHF_push_flags_onto_stack ),
    .i_opcode_x86_RCL_reg_mem_by_1 ( o_opcode_x86_RCL_reg_mem_by_1 ),
    .i_opcode_x86_RCL_reg_mem_by_CL ( o_opcode_x86_RCL_reg_mem_by_CL ),
    .i_opcode_x86_RCL_reg_mem_by_imm ( o_opcode_x86_RCL_reg_mem_by_imm ),
    .i_opcode_x86_RCR_reg_mem_by_1 ( o_opcode_x86_RCR_reg_mem_by_1 ),
    .i_opcode_x86_RCR_reg_mem_by_CL ( o_opcode_x86_RCR_reg_mem_by_CL ),
    .i_opcode_x86_RCR_reg_mem_by_imm ( o_opcode_x86_RCR_reg_mem_by_imm ),
    .i_opcode_x86_RDMSR_read_from_model_specific_reg ( o_opcode_x86_RDMSR_read_from_model_specific_reg ),
    .i_opcode_x86_RDPMC_read_performance_monitoring_counters ( o_opcode_x86_RDPMC_read_performance_monitoring_counters ),
    .i_opcode_x86_RDTSC_read_time_stamp_counter ( o_opcode_x86_RDTSC_read_time_stamp_counter ),
    .i_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id ( o_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id ),
    .i_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument ( o_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument ),
    .i_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP ( o_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP ),
    .i_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument ( o_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument ),
    .i_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP ( o_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP ),
    .i_opcode_x86_ROL_reg_mem_by_1 ( o_opcode_x86_ROL_reg_mem_by_1 ),
    .i_opcode_x86_ROL_reg_mem_by_CL ( o_opcode_x86_ROL_reg_mem_by_CL ),
    .i_opcode_x86_ROL_reg_mem_by_imm ( o_opcode_x86_ROL_reg_mem_by_imm ),
    .i_opcode_x86_ROR_reg_mem_by_1 ( o_opcode_x86_ROR_reg_mem_by_1 ),
    .i_opcode_x86_ROR_reg_mem_by_CL ( o_opcode_x86_ROR_reg_mem_by_CL ),
    .i_opcode_x86_ROR_reg_mem_by_imm ( o_opcode_x86_ROR_reg_mem_by_imm ),
    .i_opcode_x86_RSM_resume_from_system_management_mode ( o_opcode_x86_RSM_resume_from_system_management_mode ),
    .i_opcode_x86_SAHF_store_AH_into_flags ( o_opcode_x86_SAHF_store_AH_into_flags ),
    .i_opcode_x86_SAR_reg_mem_by_1 ( o_opcode_x86_SAR_reg_mem_by_1 ),
    .i_opcode_x86_SAR_reg_mem_by_CL ( o_opcode_x86_SAR_reg_mem_by_CL ),
    .i_opcode_x86_SAR_reg_mem_by_imm ( o_opcode_x86_SAR_reg_mem_by_imm ),
    .i_opcode_x86_SBB_reg_to_reg_mem ( o_opcode_x86_SBB_reg_to_reg_mem ),
    .i_opcode_x86_SBB_reg_mem_to_reg ( o_opcode_x86_SBB_reg_mem_to_reg ),
    .i_opcode_x86_SBB_imm_to_reg_mem ( o_opcode_x86_SBB_imm_to_reg_mem ),
    .i_opcode_x86_SBB_imm_to_acc ( o_opcode_x86_SBB_imm_to_acc ),
    .i_opcode_x86_SCAS_scan_string ( o_opcode_x86_SCAS_scan_string ),
    .i_opcode_x86_SETcc_byte_set_on_condition ( o_opcode_x86_SETcc_byte_set_on_condition ),
    .i_opcode_x86_SGDT_store_global_descriptor_table_register ( o_opcode_x86_SGDT_store_global_descriptor_table_register ),
    .i_opcode_x86_SHL_reg_mem_by_1 ( o_opcode_x86_SHL_reg_mem_by_1 ),
    .i_opcode_x86_SHL_reg_mem_by_CL ( o_opcode_x86_SHL_reg_mem_by_CL ),
    .i_opcode_x86_SHL_reg_mem_by_imm ( o_opcode_x86_SHL_reg_mem_by_imm ),
    .i_opcode_x86_SHLD_reg_mem_by_imm ( o_opcode_x86_SHLD_reg_mem_by_imm ),
    .i_opcode_x86_SHLD_reg_mem_by_CL ( o_opcode_x86_SHLD_reg_mem_by_CL ),
    .i_opcode_x86_SHR_reg_mem_by_1 ( o_opcode_x86_SHR_reg_mem_by_1 ),
    .i_opcode_x86_SHR_reg_mem_by_CL ( o_opcode_x86_SHR_reg_mem_by_CL ),
    .i_opcode_x86_SHR_reg_mem_by_imm ( o_opcode_x86_SHR_reg_mem_by_imm ),
    .i_opcode_x86_SHRD_reg_mem_by_imm ( o_opcode_x86_SHRD_reg_mem_by_imm ),
    .i_opcode_x86_SHRD_reg_mem_by_CL ( o_opcode_x86_SHRD_reg_mem_by_CL ),
    .i_opcode_x86_SIDT_store_interrupt_desciptor_table_register ( o_opcode_x86_SIDT_store_interrupt_desciptor_table_register ),
    .i_opcode_x86_SLDT_store_local_desciptor_table_register ( o_opcode_x86_SLDT_store_local_desciptor_table_register ),
    .i_opcode_x86_SMSW_store_machine_status_word ( o_opcode_x86_SMSW_store_machine_status_word ),
    .i_opcode_x86_STC_set_carry_flag ( o_opcode_x86_STC_set_carry_flag ),
    .i_opcode_x86_STD_set_direction_flag ( o_opcode_x86_STD_set_direction_flag ),
    .i_opcode_x86_STI_set_interrupt_enable_flag ( o_opcode_x86_STI_set_interrupt_enable_flag ),
    .i_opcode_x86_STOS_store_string_data ( o_opcode_x86_STOS_store_string_data ),
    .i_opcode_x86_STR_store_task_register ( o_opcode_x86_STR_store_task_register ),
    .i_opcode_x86_SUB_reg_to_reg_mem ( o_opcode_x86_SUB_reg_to_reg_mem ),
    .i_opcode_x86_SUB_reg_mem_to_reg ( o_opcode_x86_SUB_reg_mem_to_reg ),
    .i_opcode_x86_SUB_imm_to_reg_mem ( o_opcode_x86_SUB_imm_to_reg_mem ),
    .i_opcode_x86_SUB_imm_to_acc ( o_opcode_x86_SUB_imm_to_acc ),
    .i_opcode_x86_TEST_reg_mem_and_reg ( o_opcode_x86_TEST_reg_mem_and_reg ),
    .i_opcode_x86_TEST_imm_and_reg_mem ( o_opcode_x86_TEST_imm_and_reg_mem ),
    .i_opcode_x86_TEST_imm_and_acc ( o_opcode_x86_TEST_imm_and_acc ),
    .i_opcode_x86_UD0_undefined_instruction ( o_opcode_x86_UD0_undefined_instruction ),
    .i_opcode_x86_UD1_undefined_instruction ( o_opcode_x86_UD1_undefined_instruction ),
    .i_opcode_x86_UD2_undefined_instruction ( o_opcode_x86_UD2_undefined_instruction ),
    .i_opcode_x86_VERR_verify_a_segment_for_reading ( o_opcode_x86_VERR_verify_a_segment_for_reading ),
    .i_opcode_x86_VERW_verify_a_segment_for_writing ( o_opcode_x86_VERW_verify_a_segment_for_writing ),
    .i_opcode_x86_WAIT_wait ( o_opcode_x86_WAIT_wait ),
    .i_opcode_x86_WBINVD_writeback_and_invalidate_data_cache ( o_opcode_x86_WBINVD_writeback_and_invalidate_data_cache ),
    .i_opcode_x86_WRMSR_write_to_model_specific_register ( o_opcode_x86_WRMSR_write_to_model_specific_register ),
    .i_opcode_x86_XADD_exchange_and_add ( o_opcode_x86_XADD_exchange_and_add ),
    .i_opcode_x86_XCHG_reg_mem_with_reg ( o_opcode_x86_XCHG_reg_mem_with_reg ),
    .i_opcode_x86_XCHG_reg_with_acc_short ( o_opcode_x86_XCHG_reg_with_acc_short ),
    .i_opcode_x86_XLAT_table_look_up_translation ( o_opcode_x86_XLAT_table_look_up_translation ),
    .i_opcode_x86_XOR_reg_to_reg_mem ( o_opcode_x86_XOR_reg_to_reg_mem ),
    .i_opcode_x86_XOR_reg_mem_to_reg ( o_opcode_x86_XOR_reg_mem_to_reg ),
    .i_opcode_x86_XOR_imm_to_reg_mem ( o_opcode_x86_XOR_imm_to_reg_mem ),
    .i_opcode_x86_XOR_imm_to_acc ( o_opcode_x86_XOR_imm_to_acc ),
    .o_tttn ( field_o_tttn ),
    .o_gen_reg_index_is_present ( field_o_gen_reg_index_is_present ),
    .o_gen_reg_index ( field_o_gen_reg_index ),
    .o_seg_reg_index_is_present ( field_o_seg_reg_index_is_present ),
    .o_seg_reg_index ( field_o_seg_reg_index ),
    .o_w_is_present ( field_o_w_is_present ),
    .o_w ( field_o_w ),
    .o_s_is_present ( field_o_s_is_present ),
    .o_s ( field_o_s ),
    .o_eee ( field_o_eee ),
    .o_mod_rm_is_present ( field_o_mod_rm_is_present ),
    .o_mod ( field_o_mod ),
    .o_rm ( field_o_rm ),
    .o_immediate_size_full ( field_o_immediate_size_full ),
    .o_immediate_size_16 ( field_o_immediate_size_16 ),
    .o_immediate_size_8 ( field_o_immediate_size_8 ),
    .o_immediate_is_present ( field_o_immediate_is_present ),
    .o_displacement_size_full ( field_o_displacement_size_full ),
    .o_displacement_size_8 ( field_o_displacement_size_8 ),
    .o_displacement_is_present ( field_o_displacement_is_present ),
    .o_primary_opcode_byte_1 ( field_o_primary_opcode_byte_1 ),
    .o_primary_opcode_byte_2 ( field_o_primary_opcode_byte_2 ),
    .o_primary_opcode_byte_3 ( field_o_primary_opcode_byte_3 ),
    .o_error ( field_o_error )
);
logic [ 3:0] offset_mod_rm;
always_comb begin
    unique case (1'b1)
        field_o_primary_opcode_byte_1: offset_mod_rm <= offset_opcode + 4'h1;
        field_o_primary_opcode_byte_2: offset_mod_rm <= offset_opcode + 4'h2;
        field_o_primary_opcode_byte_3: offset_mod_rm <= offset_opcode + 4'h3;
        default                      : offset_mod_rm <= offset_opcode + 4'h0;
    endcase
end

logic [ 1:0] mod_rm_i_mod;
logic [ 2:0] mod_rm_i_rm;
logic        mod_rm_i_w_is_present;
logic        mod_rm_i_w;
logic        mod_rm_i_default_operand_size;
logic [ 2:0] mod_rm_o_segment_reg_index;
logic        mod_rm_o_base_reg_is_present;
logic [ 2:0] mod_rm_o_base_reg_index;
logic        mod_rm_o_index_reg_is_present;
logic [ 2:0] mod_rm_o_index_reg_index;
logic        mod_rm_o_gen_reg_is_present;
logic [ 2:0] mod_rm_o_gen_reg_index;
logic [ 2:0] mod_rm_o_gen_reg_bit_width;
logic        mod_rm_o_displacement_is_present;
logic        mod_rm_o_displacement_size_8;
logic        mod_rm_o_displacement_size_16;
logic        mod_rm_o_displacement_size_32;
logic        mod_rm_o_sib_is_present;
assign mod_rm_i_mod = field_o_mod;
assign mod_rm_i_rm = field_o_rm;
assign mod_rm_i_w_is_present = field_o_w_is_present;
assign mod_rm_i_w = field_o_w;
assign mod_rm_i_default_operand_size = i_default_operand_size;
decode_mod_rm deocde_decode_mod_rm (
    .i_mod ( mod_rm_i_mod ),
    .i_rm ( mod_rm_i_rm ),
    .i_w_is_present ( mod_rm_i_w_is_present ),
    .i_w ( mod_rm_i_w ),
    .i_default_operand_size ( mod_rm_i_default_operand_size ),
    .o_segment_reg_index ( mod_rm_o_segment_reg_index ),
    .o_base_reg_is_present ( mod_rm_o_base_reg_is_present ),
    .o_base_reg_index ( mod_rm_o_base_reg_index ),
    .o_index_reg_is_present ( mod_rm_o_index_reg_is_present ),
    .o_index_reg_index ( mod_rm_o_index_reg_index ),
    .o_gen_reg_is_present ( mod_rm_o_gen_reg_is_present ),
    .o_gen_reg_index ( mod_rm_o_gen_reg_index ),
    .o_gen_reg_bit_width ( mod_rm_o_gen_reg_bit_width ),
    .o_displacement_is_present ( mod_rm_o_displacement_is_present ),
    .o_displacement_size_8 ( mod_rm_o_displacement_size_8 ),
    .o_displacement_size_16 ( mod_rm_o_displacement_size_16 ),
    .o_displacement_size_32 ( mod_rm_o_displacement_size_32 ),
    .o_sib_is_present ( mod_rm_o_sib_is_present )
);
logic [ 3:0] offset_sib;
always_comb begin
    offset_sib <= offset_mod_rm + 4'h1;
end

logic [ 7:0] sib_i_sib;
logic [ 1:0] sib_i_mod;
logic [ 1:0] sib_o_scale_factor;
logic [ 2:0] sib_o_segment_reg_index;
logic        sib_o_index_reg_is_present;
logic [ 2:0] sib_o_index_reg_index;
logic        sib_o_base_reg_is_present;
logic [ 2:0] sib_o_base_reg_index;
logic        sib_o_displacement_size_1;
logic        sib_o_displacement_size_4;
logic        sib_o_effecitve_address_undefined;
assign sib_i_sib = i_instruction[offset_sib];
assign sib_i_mod = mod_rm_i_mod;
// always_comb begin
//     unique case (offset_sib)
//         4'h2: sib_i_sib <= i_instruction[2];
//         4'h3: sib_i_sib <= i_instruction[3];
//         4'h4: sib_i_sib <= i_instruction[4];
//         4'h5: sib_i_sib <= i_instruction[5];
//         4'h6: sib_i_sib <= i_instruction[6];
//         4'h7: sib_i_sib <= i_instruction[7];
//         4'h8: sib_i_sib <= i_instruction[8];
//         default: sib_i_sib <= 8'bzzzz_zzzz;
//     endcase
// end
decode_sib deocde_decode_sib (
    .i_sib ( sib_i_sib ),
    .i_mod ( sib_i_mod ),
    .o_scale_factor ( sib_o_scale_factor ),
    .o_segment_reg_index ( sib_o_segment_reg_index ),
    .o_index_reg_is_present ( sib_o_index_reg_is_present ),
    .o_index_reg_index ( sib_o_index_reg_index ),
    .o_base_reg_is_present ( sib_o_base_reg_is_present ),
    .o_base_reg_index ( sib_o_base_reg_index ),
    .o_displacement_size_1 ( sib_o_displacement_size_1 ),
    .o_displacement_size_4 ( sib_o_displacement_size_4 ),
    .o_effecitve_address_undefined ( sib_o_effecitve_address_undefined )
);
logic [ 3:0] offset_disp_imm, offset_disp_imm_end;
always_comb begin
    if (field_o_mod_rm_is_present) begin
        if (mod_rm_o_sib_is_present) begin
            offset_disp_imm <= offset_mod_rm + 4'h2;
        end else begin
            offset_disp_imm <= offset_mod_rm + 4'h1;
        end
    end else begin
        offset_disp_imm <= offset_mod_rm + 4'h0;
    end
    offset_disp_imm_end <= offset_disp_imm_end + 4'h8;
end

logic [ 7:0] disp_imm_i_instruction [0:7];
logic        disp_imm_i_displacement_size_1;
logic        disp_imm_i_displacement_size_2;
logic        disp_imm_i_displacement_size_4;
logic        disp_imm_i_immediate_size_1;
logic        disp_imm_i_immediate_size_2;
logic        disp_imm_i_immediate_size_4;
logic        disp_imm_i_immediate_size_f;
logic [31:0] disp_imm_o_displacement;
logic [31:0] disp_imm_o_immediate;
logic [ 3:0] disp_imm_o_consume_bytes;
logic        disp_imm_o_error;
// assign disp_imm_i_instruction = i_instruction[offset_disp_imm:+7];
assign disp_imm_i_instruction = '{
    i_instruction[offset_disp_imm + 0],
    i_instruction[offset_disp_imm + 1],
    i_instruction[offset_disp_imm + 2],
    i_instruction[offset_disp_imm + 3],
    i_instruction[offset_disp_imm + 4],
    i_instruction[offset_disp_imm + 5],
    i_instruction[offset_disp_imm + 6],
    i_instruction[offset_disp_imm + 7]
};
assign disp_imm_i_displacement_size_1 = mod_rm_o_sib_is_present ? sib_o_displacement_size_1 : mod_rm_o_displacement_size_8;
assign disp_imm_i_displacement_size_2 = mod_rm_o_sib_is_present ? mod_rm_o_displacement_size_16 : mod_rm_o_displacement_size_16;
assign disp_imm_i_displacement_size_4 = mod_rm_o_sib_is_present ? sib_o_displacement_size_4 : mod_rm_o_displacement_size_32;
assign disp_imm_i_immediate_size_1 = field_o_immediate_size_8;
assign disp_imm_i_immediate_size_2 = field_o_immediate_size_16;
assign disp_imm_i_immediate_size_4 = field_o_immediate_size_full;
assign disp_imm_i_immediate_size_f = field_o_immediate_size_full;
decode_disp_imm deocde_decode_disp_imm (
    .i_instruction ( disp_imm_i_instruction ),
    .i_displacement_size_1 ( disp_imm_i_displacement_size_1 ),
    .i_displacement_size_2 ( disp_imm_i_displacement_size_2 ),
    .i_displacement_size_4 ( disp_imm_i_displacement_size_4 ),
    .i_immediate_size_1 ( disp_imm_i_immediate_size_1 ),
    .i_immediate_size_2 ( disp_imm_i_immediate_size_2 ),
    .i_immediate_size_4 ( disp_imm_i_immediate_size_4 ),
    .i_immediate_size_f ( disp_imm_i_immediate_size_f ),
    .o_displacement ( disp_imm_o_displacement ),
    .o_immediate ( disp_imm_o_immediate ),
    .o_consume_bytes ( disp_imm_o_consume_bytes ),
    .o_error ( disp_imm_o_error )
);

always_comb begin

end

assign o_tttn = field_o_tttn;
assign o_eee = field_o_eee;
assign o_gen_reg_index_is_present = field_o_gen_reg_index_is_present;
assign o_gen_reg_index = field_o_gen_reg_index;
assign o_seg_reg_index_is_present = field_o_seg_reg_index_is_present;
assign o_seg_reg_index = field_o_seg_reg_index;
assign o_segment_reg_index = mod_rm_o_sib_is_present ? sib_o_segment_reg_index : mod_rm_o_segment_reg_index;
assign o_base_reg_is_present = mod_rm_o_sib_is_present ? sib_o_index_reg_is_present : mod_rm_o_index_reg_is_present;
assign o_base_reg_index = mod_rm_o_sib_is_present ? sib_o_index_reg_index : mod_rm_o_index_reg_index;
assign o_index_reg_is_present = mod_rm_o_sib_is_present ? sib_o_base_reg_is_present : mod_rm_o_base_reg_is_present;
assign o_index_reg_index = mod_rm_o_sib_is_present ? sib_o_base_reg_index : mod_rm_o_base_reg_index;
assign o_gen_reg_is_present_from_mod_rm = mod_rm_o_gen_reg_is_present;
assign o_gen_reg_index_from_mod_rm = mod_rm_o_gen_reg_index;
assign o_gen_reg_bit_width_from_mod_rm = mod_rm_o_gen_reg_bit_width;
assign o_displacement = disp_imm_o_displacement;
assign o_immediate = disp_imm_o_immediate;
assign o_consume_bytes = offset_disp_imm + disp_imm_o_consume_bytes;

endmodule
