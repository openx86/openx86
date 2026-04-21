/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements unit.
*/
/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: unit
create at: 2022-01-04 03:27:51
description: decode unit (模块名与文件名 unit 一致)
*/

`include "openx86_defs.h.sv"

// 顶层译码单元：前缀解析 → 主操作码 one-hot → 域提取 → ModRM/SIB → 位移/立即数 → 字节消耗
module unit (
    input  logic [15: 0][ 7: 0] i_instruction, // 16B 指令滑窗（低字节为首字节）
    input  logic          i_default_operand_size, // 默认操作数宽度（16/32）
    output logic         o_opcode_x86_AAA_ASCII_adjust_after_add, // 输出信号
    output logic         o_opcode_x86_AAD_ASCII_AX_before_div, // 输出信号
    output logic         o_opcode_x86_AAM_ASCII_AX_after_mul, // 输出信号
    output logic         o_opcode_x86_AAS_ASCII_adjust_after_sub, // 输出信号
    output logic         o_opcode_x86_ADC_reg_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_ADC_reg_mem_to_reg, // 输出信号
    output logic         o_opcode_x86_ADC_imm_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_ADC_imm_to_acc, // 输出信号
    output logic         o_opcode_x86_ADD_reg_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_ADD_reg_mem_to_reg, // 输出信号
    output logic         o_opcode_x86_ADD_imm_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_ADD_imm_to_acc, // 输出信号
    output logic         o_opcode_x86_AND_reg_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_AND_reg_mem_to_reg, // 输出信号
    output logic         o_opcode_x86_AND_imm_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_AND_imm_to_acc, // 输出信号
    output logic         o_opcode_x86_ARPL_adjust_RPL_field_of_selector, // 输出信号
    output logic         o_opcode_x86_BOUND_check_array_against_bounds, // 输出信号
    output logic         o_opcode_x86_BSF_bit_scan_forward, // 输出信号
    output logic         o_opcode_x86_BSR_bit_scan_reverse, // 输出信号
    output logic         o_opcode_x86_BSWAP_byte_swap, // 输出信号
    output logic         o_opcode_x86_BT_reg_mem_with_imm, // 输出信号
    output logic         o_opcode_x86_BT_reg_mem_with_reg, // 输出信号
    output logic         o_opcode_x86_BTC_reg_mem_with_imm, // 输出信号
    output logic         o_opcode_x86_BTC_reg_mem_with_reg, // 输出信号
    output logic         o_opcode_x86_BTR_reg_mem_with_imm, // 输出信号
    output logic         o_opcode_x86_BTR_reg_mem_with_reg, // 输出信号
    output logic         o_opcode_x86_BTS_reg_mem_with_imm, // 输出信号
    output logic         o_opcode_x86_BTS_reg_mem_with_reg, // 输出信号
    output logic         o_opcode_x86_CALL_in_same_segment_direct, // 输出信号
    output logic         o_opcode_x86_CALL_in_same_segment_indirect, // 输出信号
    output logic         o_opcode_x86_CALL_in_other_segment_direct, // 输出信号
    output logic         o_opcode_x86_CALL_in_other_segment_indirect, // 输出信号
    output logic         o_opcode_x86_CBW_convert_byte_to_word, // 输出信号
    output logic         o_opcode_x86_CDQ_convert_double_word_to_quad_word, // 输出信号
    output logic         o_opcode_x86_CLC_clear_carry_flag, // 输出信号
    output logic         o_opcode_x86_CLD_clear_direction_flag, // 输出信号
    output logic         o_opcode_x86_CLI_clear_interrupt_enable_flag, // 输出信号
    output logic         o_opcode_x86_CLTS_clear_task_switched_flag, // 输出信号
    output logic         o_opcode_x86_CMC_complement_carry_flag, // 输出信号
    output logic         o_opcode_x86_CMP_mem_with_reg, // 输出信号
    output logic         o_opcode_x86_CMP_reg_with_mem, // 输出信号
    output logic         o_opcode_x86_CMP_imm_with_reg_mem, // 输出信号
    output logic         o_opcode_x86_CMP_imm_with_acc, // 输出信号
    output logic         o_opcode_x86_CMPS_compare_string_operands, // 输出信号
    output logic         o_opcode_x86_CMPXCHG_compare_and_exchange, // 输出信号
    output logic         o_opcode_x86_CPUID_CPU_identification, // 输出信号
    output logic         o_opcode_x86_CWD_convert_word_to_double, // 输出信号
    output logic         o_opcode_x86_CWDE_convert_word_to_double, // 输出信号
    output logic         o_opcode_x86_DAA_decimal_adjust_AL_after_add, // 输出信号
    output logic         o_opcode_x86_DAS_decimal_adjust_AL_after_sub, // 输出信号
    output logic         o_opcode_x86_DEC_reg_mem, // 输出信号
    output logic         o_opcode_x86_DEC_reg, // 输出信号
    output logic         o_opcode_x86_DIV_acc_by_reg_mem, // 输出信号
    output logic         o_opcode_x86_HLT_halt, // 输出信号
    output logic         o_opcode_x86_IDIV_acc_by_reg_mem, // 输出信号
    output logic         o_opcode_x86_IMUL_acc_with_reg_mem, // 输出信号
    output logic         o_opcode_x86_IMUL_reg_with_reg_mem, // 输出信号
    output logic         o_opcode_x86_IMUL_reg_mem_with_imm_to_reg, // 输出信号
    output logic         o_opcode_x86_IN_port_fixed, // 输出信号
    output logic         o_opcode_x86_IN_port_variable, // 输出信号
    output logic         o_opcode_x86_INC_reg_mem, // 输出信号
    output logic         o_opcode_x86_INC_reg, // 输出信号
    output logic         o_opcode_x86_INS_input_from_DX_port, // 输入信号
    output logic         o_opcode_x86_INT_interrupt_type_n, // 输出信号
    output logic         o_opcode_x86_INT_interrupt_type_3, // 输出信号
    output logic         o_opcode_x86_INT_interrupt_type_4, // 输出信号
    output logic         o_opcode_x86_INVD_invalidate_cache, // 输出信号
    output logic         o_opcode_x86_INVLPG_invalidate_TLB_entry, // 输出信号
    output logic         o_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size, // 输出信号
    output logic         o_opcode_x86_IRET_interrupt_return, // 输出信号
    output logic         o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp, // 输出信号
    output logic         o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp, // 输出信号
    output logic         o_opcode_x86_JCXZ_jump_on_CX_zero, // 输出信号
    output logic         o_opcode_x86_JMP_to_same_segment_short, // 输出信号
    output logic         o_opcode_x86_JMP_to_same_segment_direct, // 输出信号
    output logic         o_opcode_x86_JMP_to_same_segment_indirect, // 输出信号
    output logic         o_opcode_x86_JMP_to_other_segment_direct, // 输出信号
    output logic         o_opcode_x86_JMP_to_other_segment_indirect, // 输出信号
    output logic         o_opcode_x86_LAHF_load_FLAG_into_AH, // 输出信号
    output logic         o_opcode_x86_LAR_load_access_rights_byte, // 输出信号
    output logic         o_opcode_x86_LDS_load_pointer_to_DS, // 输出信号
    output logic         o_opcode_x86_LEA_load_effective_adddress_to_reg, // 输出信号
    output logic         o_opcode_x86_LEAVE_high_level_procedure_exit, // 输出信号
    output logic         o_opcode_x86_LES_load_pointer_to_ES, // 输出信号
    output logic         o_opcode_x86_LFS_load_pointer_to_FS, // 输出信号
    output logic         o_opcode_x86_LGDT_load_global_desciptor_table_reg, // 输出信号
    output logic         o_opcode_x86_LGS_load_pointer_to_GS, // 输出信号
    output logic         o_opcode_x86_LIDT_load_interrupt_desciptor_table_reg, // 输出信号
    output logic         o_opcode_x86_LLDT_load_local_desciptor_table_reg, // 输出信号
    output logic         o_opcode_x86_LMSW_load_status_word, // 输出信号
    output logic         o_opcode_x86_LODS_load_string_operand, // 输出信号
    output logic         o_opcode_x86_LOOP_count, // 输出信号
    output logic         o_opcode_x86_LOOPZ_count_while_zero, // 输出信号
    output logic         o_opcode_x86_LOOPNZ_count_while_not_zero, // 输出信号
    output logic         o_opcode_x86_LSL_load_segment_limit, // 输出信号
    output logic         o_opcode_x86_LSS_load_pointer_to_SS, // 输出信号
    output logic         o_opcode_x86_LTR_load_task_register, // 输出信号
    output logic         o_opcode_x86_MOV_reg_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_MOV_reg_mem_to_reg, // 输出信号
    output logic         o_opcode_x86_MOV_imm_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_MOV_imm_to_reg, // 输出信号
    output logic         o_opcode_x86_MOV_mem_to_acc, // 输出信号
    output logic         o_opcode_x86_MOV_acc_to_mem, // 输出信号
    output logic         o_opcode_x86_MOV_CR_from_reg, // 输出信号
    output logic         o_opcode_x86_MOV_reg_from_CR, // 输出信号
    output logic         o_opcode_x86_MOV_DR_from_reg, // 输出信号
    output logic         o_opcode_x86_MOV_reg_from_DR, // 输出信号
    output logic         o_opcode_x86_MOV_TR_from_reg, // 输出信号
    output logic         o_opcode_x86_MOV_reg_from_TR, // 输出信号
    output logic         o_opcode_x86_MOV_reg_mem_to_sreg, // 输出信号
    output logic         o_opcode_x86_MOV_sreg_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg, // 输出信号
    output logic         o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_MOVS_move_data_from_string_to_string, // 输出信号
    output logic         o_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg, // 输出信号
    output logic         o_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg, // 输出信号
    output logic         o_opcode_x86_MUL_acc_with_reg_mem, // 输出信号
    output logic         o_opcode_x86_NEG_two_s_complement_negation, // 输出信号
    output logic         o_opcode_x86_NOP_no_operation, // 输出信号
    output logic         o_opcode_x86_NOP_no_operation_multi_byte, // 输出信号
    output logic         o_opcode_x86_NOT_one_s_complement_negation, // 输出信号
    output logic         o_opcode_x86_OR_reg_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_OR_reg_mem_to_reg, // 输出信号
    output logic         o_opcode_x86_OR_imm_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_OR_imm_to_acc, // 输出信号
    output logic         o_opcode_x86_OUT_port_fixed, // 输出信号
    output logic         o_opcode_x86_OUT_port_variable, // 输出信号
    output logic         o_opcode_x86_OUTS_output_string, // 输出信号
    output logic         o_opcode_x86_POP_reg_mem, // 输出信号
    output logic         o_opcode_x86_POP_reg, // 输出信号
    output logic         o_opcode_x86_POP_sreg_2, // 输出信号
    output logic         o_opcode_x86_POP_sreg_3, // 输出信号
    output logic         o_opcode_x86_POPA_pop_all_general_registers, // 输出信号
    output logic         o_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS, // 输出信号
    output logic         o_opcode_x86_PUSH_reg_mem, // 输出信号
    output logic         o_opcode_x86_PUSH_reg, // 输出信号
    output logic         o_opcode_x86_PUSH_sreg_2, // 输出信号
    output logic         o_opcode_x86_PUSH_sreg_3, // 输出信号
    output logic         o_opcode_x86_PUSH_imm, // 输出信号
    output logic         o_opcode_x86_PUSH_all_general_registers, // 输出信号
    output logic         o_opcode_x86_PUSHF_push_flags_onto_stack, // 输出信号
    output logic         o_opcode_x86_RCL_reg_mem_by_1, // 输出信号
    output logic         o_opcode_x86_RCL_reg_mem_by_CL, // 输出信号
    output logic         o_opcode_x86_RCL_reg_mem_by_imm, // 输出信号
    output logic         o_opcode_x86_RCR_reg_mem_by_1, // 输出信号
    output logic         o_opcode_x86_RCR_reg_mem_by_CL, // 输出信号
    output logic         o_opcode_x86_RCR_reg_mem_by_imm, // 输出信号
    output logic         o_opcode_x86_RDMSR_read_from_model_specific_reg, // 输出信号
    output logic         o_opcode_x86_RDPMC_read_performance_monitoring_counters, // 输出信号
    output logic         o_opcode_x86_RDTSC_read_time_stamp_counter, // 输出信号
    output logic         o_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id, // 输出信号
    output logic         o_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument, // 输出信号
    output logic         o_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP, // 输出信号
    output logic         o_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument, // 输出信号
    output logic         o_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP, // 输出信号
    output logic         o_opcode_x86_ROL_reg_mem_by_1, // 输出信号
    output logic         o_opcode_x86_ROL_reg_mem_by_CL, // 输出信号
    output logic         o_opcode_x86_ROL_reg_mem_by_imm, // 输出信号
    output logic         o_opcode_x86_ROR_reg_mem_by_1, // 输出信号
    output logic         o_opcode_x86_ROR_reg_mem_by_CL, // 输出信号
    output logic         o_opcode_x86_ROR_reg_mem_by_imm, // 输出信号
    output logic         o_opcode_x86_RSM_resume_from_system_management_mode, // 输出信号
    output logic         o_opcode_x86_SAHF_store_AH_into_flags, // 输出信号
    output logic         o_opcode_x86_SAR_reg_mem_by_1, // 输出信号
    output logic         o_opcode_x86_SAR_reg_mem_by_CL, // 输出信号
    output logic         o_opcode_x86_SAR_reg_mem_by_imm, // 输出信号
    output logic         o_opcode_x86_SBB_reg_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_SBB_reg_mem_to_reg, // 输出信号
    output logic         o_opcode_x86_SBB_imm_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_SBB_imm_to_acc, // 输出信号
    output logic         o_opcode_x86_SCAS_scan_string, // 输出信号
    output logic         o_opcode_x86_SETcc_byte_set_on_condition, // 输出信号
    output logic         o_opcode_x86_SGDT_store_global_descriptor_table_register, // 输出信号
    output logic         o_opcode_x86_SHL_reg_mem_by_1, // 输出信号
    output logic         o_opcode_x86_SHL_reg_mem_by_CL, // 输出信号
    output logic         o_opcode_x86_SHL_reg_mem_by_imm, // 输出信号
    output logic         o_opcode_x86_SHLD_reg_mem_by_imm, // 输出信号
    output logic         o_opcode_x86_SHLD_reg_mem_by_CL, // 输出信号
    output logic         o_opcode_x86_SHR_reg_mem_by_1, // 输出信号
    output logic         o_opcode_x86_SHR_reg_mem_by_CL, // 输出信号
    output logic         o_opcode_x86_SHR_reg_mem_by_imm, // 输出信号
    output logic         o_opcode_x86_SHRD_reg_mem_by_imm, // 输出信号
    output logic         o_opcode_x86_SHRD_reg_mem_by_CL, // 输出信号
    output logic         o_opcode_x86_SIDT_store_interrupt_desciptor_table_register, // 输出信号
    output logic         o_opcode_x86_SLDT_store_local_desciptor_table_register, // 输出信号
    output logic         o_opcode_x86_SMSW_store_machine_status_word, // 输出信号
    output logic         o_opcode_x86_STC_set_carry_flag, // 输出信号
    output logic         o_opcode_x86_STD_set_direction_flag, // 输出信号
    output logic         o_opcode_x86_STI_set_interrupt_enable_flag, // 输出信号
    output logic         o_opcode_x86_STOS_store_string_data, // 输出信号
    output logic         o_opcode_x86_STR_store_task_register, // 输出信号
    output logic         o_opcode_x86_SUB_reg_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_SUB_reg_mem_to_reg, // 输出信号
    output logic         o_opcode_x86_SUB_imm_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_SUB_imm_to_acc, // 输出信号
    output logic         o_opcode_x86_TEST_reg_mem_and_reg, // 输出信号
    output logic         o_opcode_x86_TEST_imm_and_reg_mem, // 输出信号
    output logic         o_opcode_x86_TEST_imm_and_acc, // 输出信号
    output logic         o_opcode_x86_UD0_undefined_instruction, // 输出信号
    output logic         o_opcode_x86_UD1_undefined_instruction, // 输出信号
    output logic         o_opcode_x86_UD2_undefined_instruction, // 输出信号
    output logic         o_opcode_x86_VERR_verify_a_segment_for_reading, // 输出信号
    output logic         o_opcode_x86_VERW_verify_a_segment_for_writing, // 输出信号
    output logic         o_opcode_x86_WAIT_wait, // 输出信号
    output logic         o_opcode_x86_WBINVD_writeback_and_invalidate_data_cache, // 输出信号
    output logic         o_opcode_x86_WRMSR_write_to_model_specific_register, // 输出信号
    output logic         o_opcode_x86_XADD_exchange_and_add, // 输出信号
    output logic         o_opcode_x86_XCHG_reg_mem_with_reg, // 输出信号
    output logic         o_opcode_x86_XCHG_reg_with_acc_short, // 输出信号
    output logic         o_opcode_x86_XLAT_table_look_up_translation, // 输出信号
    output logic         o_opcode_x86_XOR_reg_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_XOR_reg_mem_to_reg, // 输出信号
    output logic         o_opcode_x86_XOR_imm_to_reg_mem, // 输出信号
    output logic         o_opcode_x86_XOR_imm_to_acc, // 输出信号
    output logic [ 3: 0] o_tttn, // 输出信号
    output logic [ 2: 0] o_eee, // 输出信号
    output logic         o_gen_reg_index_is_present, // 输出信号
    output logic [ 2: 0] o_gen_reg_index, // 输出信号
    output logic         o_seg_reg_index_is_present, // 输出信号
    output logic [ 2: 0] o_seg_reg_index, // 输出信号
    output logic [ 2: 0] o_segment_reg_index, // 输出信号
    output logic         o_base_reg_is_present, // 输出信号
    output logic [ 2: 0] o_base_reg_index, // 输出信号
    output logic         o_index_reg_is_present, // 输出信号
    output logic [ 2: 0] o_index_reg_index, // 输出信号
    output logic         o_gen_reg_is_present_from_mod_rm, // 输出信号
    output logic [ 2: 0] o_gen_reg_index_from_mod_rm, // 输出信号
    output logic [ 2: 0] o_gen_reg_bit_width_from_mod_rm, // 输出信号
    output logic [31: 0] o_displacement, // 输出信号
    output logic [31: 0] o_immediate, // 输出信号
    output logic [ 3: 0] o_consume_bytes, // 输出信号
    output logic         o_error, // 输出信号
    output logic         o_x87_is_esc, // 输出信号
    output logic [ 2: 0] o_x87_esc_group, // 输出信号
    output logic [31: 0] o_x87_opmask, // 输出信号
    output logic         o_x87_memory_operand, // 输出信号
    output logic         o_x87_modrm_required, // 输出信号
    output logic [ 1: 0] o_x87_mod, // 输出信号
    output logic [ 2: 0] o_x87_reg, // 输出信号
    output logic [ 2: 0] o_x87_rm, // 输出信号
    output logic [ 1: 0] o_dbg_modrm_mod, // 输出信号
    output logic [ 1: 0] o_sib_scale_factor // SIB scale（无 SIB 时输出 0）
);

// 前缀字节窗口（最多 4 个前缀槽）
logic [ 3: 0][ 7: 0] prefix_instruction;
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
logic [ 2: 0] prefix_o_segment_override_index;
logic        prefix_o_consume_bytes_prefix_1;
logic        prefix_o_consume_bytes_prefix_2;
logic        prefix_o_consume_bytes_prefix_3;
logic        prefix_o_consume_bytes_prefix_4;
logic        prefix_o_error;
assign prefix_instruction[0] = i_instruction[0];
assign prefix_instruction[1] = i_instruction[1];
assign prefix_instruction[2] = i_instruction[2];
assign prefix_instruction[3] = i_instruction[3];
// 解析四组前缀并给出消费字节数/错误（非法重复前缀）
stage_2_dec_x86_prefix_all deocde_decode_prefix_all (
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
// 主 opcode 相对首字节的偏移（0..4，取决于吃掉多少前缀）
logic [ 3: 0] offset_opcode;
// 组合逻辑块
always_comb begin
    unique case (1'b1)
        prefix_o_consume_bytes_prefix_1: offset_opcode = 4'h1;
        prefix_o_consume_bytes_prefix_2: offset_opcode = 4'h2;
        prefix_o_consume_bytes_prefix_3: offset_opcode = 4'h3;
        prefix_o_consume_bytes_prefix_4: offset_opcode = 4'h4;
        default                        : offset_opcode = 4'h0;
    endcase
end

// 对齐到主 opcode 起始位置的 4B 窗口，供 opcode/域译码使用
logic [ 3: 0][ 7: 0] opcode_instruction;
// 组合逻辑块
always_comb begin
    unique case (1'b1)
        prefix_o_consume_bytes_prefix_1: begin
            opcode_instruction[0] = i_instruction[1];
            opcode_instruction[1] = i_instruction[2];
            opcode_instruction[2] = i_instruction[3];
            opcode_instruction[3] = i_instruction[4];
        end
        prefix_o_consume_bytes_prefix_2: begin
            opcode_instruction[0] = i_instruction[2];
            opcode_instruction[1] = i_instruction[3];
            opcode_instruction[2] = i_instruction[4];
            opcode_instruction[3] = i_instruction[5];
        end
        prefix_o_consume_bytes_prefix_3: begin
            opcode_instruction[0] = i_instruction[3];
            opcode_instruction[1] = i_instruction[4];
            opcode_instruction[2] = i_instruction[5];
            opcode_instruction[3] = i_instruction[6];
        end
        prefix_o_consume_bytes_prefix_4: begin
            opcode_instruction[0] = i_instruction[4];
            opcode_instruction[1] = i_instruction[5];
            opcode_instruction[2] = i_instruction[6];
            opcode_instruction[3] = i_instruction[7];
        end
        default: begin
            opcode_instruction[0] = i_instruction[0];
            opcode_instruction[1] = i_instruction[1];
            opcode_instruction[2] = i_instruction[2];
            opcode_instruction[3] = i_instruction[3];
        end
    endcase
end

// x87 ESC（D8–DF）快速识别与 ModR/M 拆分
logic        x87_esc_int;
logic [31: 0] x87_opmask_int;
logic [ 2: 0] x87_grp_int;
logic        x87_mem_int;
logic        x87_modrm_req_int;
logic [ 1: 0] x87_mod_int;
logic [ 2: 0] x87_reg_int;
logic [ 2: 0] x87_rm_int;

x87_esc u_decode_x87_esc (
    .i_b0               ( opcode_instruction[0] ),
    .i_b1               ( opcode_instruction[1] ),
    .o_is_esc           ( x87_esc_int ),
    .o_mod              ( x87_mod_int ),
    .o_reg              ( x87_reg_int ),
    .o_rm               ( x87_rm_int ),
    .o_esc_group        ( x87_grp_int ),
    .o_opmask           ( x87_opmask_int ),
    .o_modrm_required   ( x87_modrm_req_int ),
    .o_memory_operand   ( x87_mem_int )
);

// IA-32 主 opcode → 各指令 one-hot（大表，纯组合）
stage_2_dec_x86_opcode_x86 deocde_decode_opcode_x86 (
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

// 依据 opcode one-hot 选择寄存器/ModRM/立即数/位移等字段规则
logic [ 3: 0] field_o_tttn;
logic        field_o_gen_reg_index_is_present;
logic [ 2: 0] field_o_gen_reg_index;
logic        field_o_seg_reg_index_is_present;
logic [ 2: 0] field_o_seg_reg_index;
logic        field_o_w_is_present;
logic        field_o_w;
logic        field_o_s_is_present;
logic        field_o_s;
logic [ 2: 0] field_o_eee;
logic        field_o_mod_rm_is_present;
logic [ 1: 0] field_o_mod;
logic [ 2: 0] field_o_rm;
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
stage_2_dec_x86_operand_field deocde_decode_field (
    .i_instruction ( opcode_instruction ),
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

// ModRM 相对指令首字节的偏移（随主 opcode 长度变化）
logic [ 3: 0] offset_mod_rm;
// 组合逻辑块
always_comb begin
    unique case (1'b1)
        field_o_primary_opcode_byte_1: offset_mod_rm = offset_opcode + 4'h1;
        field_o_primary_opcode_byte_2: offset_mod_rm = offset_opcode + 4'h2;
        field_o_primary_opcode_byte_3: offset_mod_rm = offset_opcode + 4'h3;
        default                      : offset_mod_rm = offset_opcode + 4'h0;
    endcase
end

logic [ 1: 0] mod_rm_i_mod;
logic [ 2: 0] mod_rm_i_rm;
logic        mod_rm_i_w_is_present;
logic        mod_rm_i_w;
logic        mod_rm_i_default_operand_size;
logic [ 2: 0] mod_rm_o_segment_reg_index;
logic        mod_rm_o_base_reg_is_present;
logic [ 2: 0] mod_rm_o_base_reg_index;
logic        mod_rm_o_index_reg_is_present;
logic [ 2: 0] mod_rm_o_index_reg_index;
logic        mod_rm_o_gen_reg_is_present;
logic [ 2: 0] mod_rm_o_gen_reg_index;
logic [ 2: 0] mod_rm_o_gen_reg_bit_width;
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

// ModR/M：解析寻址模式、寄存器/段、位移宽度、是否需要 SIB
stage_2_dec_x86_operand_mod_rm deocde_decode_mod_rm (
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

// SIB 紧跟 ModRM 后一字节
logic [ 3: 0] offset_sib;
// 组合逻辑块
always_comb begin
    offset_sib = offset_mod_rm + 4'h1;
end

logic [ 7: 0] sib_i_sib;
logic [ 1: 0] sib_i_mod;
logic [ 1: 0] sib_o_scale_factor;
logic [ 2: 0] sib_o_segment_reg_index;
logic        sib_o_index_reg_is_present;
logic [ 2: 0] sib_o_index_reg_index;
logic        sib_o_base_reg_is_present;
logic [ 2: 0] sib_o_base_reg_index;
logic        sib_o_displacement_size_1;
logic        sib_o_displacement_size_4;
logic        sib_o_effecitve_address_undefined;

assign sib_i_sib = i_instruction[offset_sib];
assign sib_i_mod = mod_rm_i_mod;

//     unique case (offset_sib)
//         4'h2: sib_i_sib = i_instruction[2];
//         4'h3: sib_i_sib = i_instruction[3];
//         4'h4: sib_i_sib = i_instruction[4];
//         4'h5: sib_i_sib = i_instruction[5];
//         4'h6: sib_i_sib = i_instruction[6];
//         4'h7: sib_i_sib = i_instruction[7];
//         4'h8: sib_i_sib = i_instruction[8];
//     endcase
// SIB：scale/index/base 与 disp8/disp32 特例（mod=00,base=101）
stage_2_dec_x86_operand_sib deocde_decode_sib (
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

// 位移/立即数起点：有 ModRM 时 +1；若有 SIB 再 +1
logic [ 3: 0] offset_disp_imm;
// 组合逻辑块
always_comb begin
    if (field_o_mod_rm_is_present) begin
        if (mod_rm_o_sib_is_present) begin
            offset_disp_imm = offset_mod_rm + 4'h2;
        end else begin
            offset_disp_imm = offset_mod_rm + 4'h1;
        end
    end else begin
        offset_disp_imm = offset_mod_rm + 4'h0;
    end
end

logic [ 7: 0][ 7: 0] disp_imm_i_instruction;
logic        disp_imm_i_displacement_size_1;
logic        disp_imm_i_displacement_size_2;
logic        disp_imm_i_displacement_size_4;
logic        disp_imm_i_immediate_size_1;
logic        disp_imm_i_immediate_size_2;
logic        disp_imm_i_immediate_size_4;
logic        disp_imm_i_immediate_size_f;
logic [31: 0] disp_imm_o_displacement;
logic [31: 0] disp_imm_o_immediate;
logic [ 3: 0] disp_imm_o_consume_bytes;
logic        disp_imm_o_error;

assign disp_imm_i_displacement_size_1 = mod_rm_o_sib_is_present ? sib_o_displacement_size_1 : mod_rm_o_displacement_size_8;
assign disp_imm_i_displacement_size_2 = mod_rm_o_sib_is_present ? mod_rm_o_displacement_size_16 : mod_rm_o_displacement_size_16;
assign disp_imm_i_displacement_size_4 = mod_rm_o_sib_is_present ? sib_o_displacement_size_4 : mod_rm_o_displacement_size_32;
assign disp_imm_i_immediate_size_1 = field_o_immediate_size_8;
assign disp_imm_i_immediate_size_2 = field_o_immediate_size_16;
assign disp_imm_i_immediate_size_4 = field_o_immediate_size_full;
assign disp_imm_i_immediate_size_f = field_o_immediate_size_full;

// 组合逻辑块
always_comb begin
    disp_imm_i_instruction[0] = i_instruction[offset_disp_imm + 0];
    disp_imm_i_instruction[1] = i_instruction[offset_disp_imm + 1];
    disp_imm_i_instruction[2] = i_instruction[offset_disp_imm + 2];
    disp_imm_i_instruction[3] = i_instruction[offset_disp_imm + 3];
    disp_imm_i_instruction[4] = i_instruction[offset_disp_imm + 4];
    disp_imm_i_instruction[5] = i_instruction[offset_disp_imm + 5];
    disp_imm_i_instruction[6] = i_instruction[offset_disp_imm + 6];
    disp_imm_i_instruction[7] = i_instruction[offset_disp_imm + 7];
end
// 从位移/立即数起点顺序拼接变长字段
stage_2_dec_x86_operand_disp_imm deocde_decode_disp_imm (
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

// 预留：后续可在此汇总更多组合约束（当前为空）
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

assign o_x87_is_esc         = x87_esc_int;
assign o_x87_esc_group      = x87_grp_int;
assign o_x87_opmask         = x87_opmask_int;
assign o_x87_memory_operand = x87_mem_int;
assign o_x87_modrm_required = x87_modrm_req_int;
assign o_x87_mod            = x87_mod_int;
assign o_x87_reg            = x87_reg_int;
assign o_x87_rm             = x87_rm_int;

assign o_error = prefix_o_error | field_o_error | disp_imm_o_error;

assign o_dbg_modrm_mod = mod_rm_i_mod;

assign o_sib_scale_factor = mod_rm_o_sib_is_present ? sib_o_scale_factor : 2'b00;

endmodule
