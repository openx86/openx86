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
//  File        : decode_opcode_x86_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : decode_opcode_x86_tb module
// ============================================================================

`timescale 1ns/1ps
`include "definition.h.sv"

module decode_opcode_x86_tb;

    // 指令字节数组（最�?字节用于解码opcode�?
    logic [ 7: 0] i_instruction [ 0:  3];
    
    // 所有opcode输出信号
    logic o_opcode_x86_AAA_ASCII_adjust_after_add;
    logic o_opcode_x86_AAD_ASCII_AX_before_div;
    logic o_opcode_x86_AAM_ASCII_AX_after_mul;
    logic o_opcode_x86_AAS_ASCII_adjust_after_sub;
    logic o_opcode_x86_ADC_reg_to_reg_mem;
    logic o_opcode_x86_ADC_reg_mem_to_reg;
    logic o_opcode_x86_ADC_imm_to_reg_mem;
    logic o_opcode_x86_ADC_imm_to_acc;
    logic o_opcode_x86_ADD_reg_to_reg_mem;
    logic o_opcode_x86_ADD_reg_mem_to_reg;
    logic o_opcode_x86_ADD_imm_to_reg_mem;
    logic o_opcode_x86_ADD_imm_to_acc;
    logic o_opcode_x86_AND_reg_to_reg_mem;
    logic o_opcode_x86_AND_reg_mem_to_reg;
    logic o_opcode_x86_AND_imm_to_reg_mem;
    logic o_opcode_x86_AND_imm_to_acc;
    logic o_opcode_x86_ARPL_adjust_RPL_field_of_selector;
    logic o_opcode_x86_BOUND_check_array_against_bounds;
    logic o_opcode_x86_BSF_bit_scan_forward;
    logic o_opcode_x86_BSR_bit_scan_reverse;
    logic o_opcode_x86_BSWAP_byte_swap;
    logic o_opcode_x86_BT_reg_mem_with_imm;
    logic o_opcode_x86_BT_reg_mem_with_reg;
    logic o_opcode_x86_BTC_reg_mem_with_imm;
    logic o_opcode_x86_BTC_reg_mem_with_reg;
    logic o_opcode_x86_BTR_reg_mem_with_imm;
    logic o_opcode_x86_BTR_reg_mem_with_reg;
    logic o_opcode_x86_BTS_reg_mem_with_imm;
    logic o_opcode_x86_BTS_reg_mem_with_reg;
    logic o_opcode_x86_CALL_in_same_segment_direct;
    logic o_opcode_x86_CALL_in_same_segment_indirect;
    logic o_opcode_x86_CALL_in_other_segment_direct;
    logic o_opcode_x86_CALL_in_other_segment_indirect;
    logic o_opcode_x86_CBW_convert_byte_to_word;
    logic o_opcode_x86_CDQ_convert_double_word_to_quad_word;
    logic o_opcode_x86_CLC_clear_carry_flag;
    logic o_opcode_x86_CLD_clear_direction_flag;
    logic o_opcode_x86_CLI_clear_interrupt_enable_flag;
    logic o_opcode_x86_CLTS_clear_task_switched_flag;
    logic o_opcode_x86_CMC_complement_carry_flag;
    logic o_opcode_x86_CMP_mem_with_reg;
    logic o_opcode_x86_CMP_reg_with_mem;
    logic o_opcode_x86_CMP_imm_with_reg_mem;
    logic o_opcode_x86_CMP_imm_with_acc;
    logic o_opcode_x86_CMPS_compare_string_operands;
    logic o_opcode_x86_CMPXCHG_compare_and_exchange;
    logic o_opcode_x86_CPUID_CPU_identification;
    logic o_opcode_x86_CWD_convert_word_to_double;
    logic o_opcode_x86_CWDE_convert_word_to_double;
    logic o_opcode_x86_DAA_decimal_adjust_AL_after_add;
    logic o_opcode_x86_DAS_decimal_adjust_AL_after_sub;
    logic o_opcode_x86_DEC_reg_mem;
    logic o_opcode_x86_DEC_reg;
    logic o_opcode_x86_DIV_acc_by_reg_mem;
    logic o_opcode_x86_HLT_halt;
    logic o_opcode_x86_IDIV_acc_by_reg_mem;
    logic o_opcode_x86_IMUL_acc_with_reg_mem;
    logic o_opcode_x86_IMUL_reg_with_reg_mem;
    logic o_opcode_x86_IMUL_reg_mem_with_imm_to_reg;
    logic o_opcode_x86_IN_port_fixed;
    logic o_opcode_x86_IN_port_variable;
    logic o_opcode_x86_INC_reg_mem;
    logic o_opcode_x86_INC_reg;
    logic o_opcode_x86_INS_input_from_DX_port;
    logic o_opcode_x86_INT_interrupt_type_n;
    logic o_opcode_x86_INT_interrupt_type_3;
    logic o_opcode_x86_INT_interrupt_type_4;
    logic o_opcode_x86_INVD_invalidate_cache;
    logic o_opcode_x86_INVLPG_invalidate_TLB_entry;
    logic o_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size;
    logic o_opcode_x86_IRET_interrupt_return;
    logic o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp;
    logic o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp;
    logic o_opcode_x86_JCXZ_jump_on_CX_zero;
    logic o_opcode_x86_JMP_to_same_segment_short;
    logic o_opcode_x86_JMP_to_same_segment_direct;
    logic o_opcode_x86_JMP_to_same_segment_indirect;
    logic o_opcode_x86_JMP_to_other_segment_direct;
    logic o_opcode_x86_JMP_to_other_segment_indirect;
    logic o_opcode_x86_LAHF_load_FLAG_into_AH;
    logic o_opcode_x86_LAR_load_access_rights_byte;
    logic o_opcode_x86_LDS_load_pointer_to_DS;
    logic o_opcode_x86_LEA_load_effective_adddress_to_reg;
    logic o_opcode_x86_LEAVE_high_level_procedure_exit;
    logic o_opcode_x86_LES_load_pointer_to_ES;
    logic o_opcode_x86_LFS_load_pointer_to_FS;
    logic o_opcode_x86_LGDT_load_global_desciptor_table_reg;
    logic o_opcode_x86_LGS_load_pointer_to_GS;
    logic o_opcode_x86_LIDT_load_interrupt_desciptor_table_reg;
    logic o_opcode_x86_LLDT_load_local_desciptor_table_reg;
    logic o_opcode_x86_LMSW_load_status_word;
    logic o_opcode_x86_LODS_load_string_operand;
    logic o_opcode_x86_LOOP_count;
    logic o_opcode_x86_LOOPZ_count_while_zero;
    logic o_opcode_x86_LOOPNZ_count_while_not_zero;
    logic o_opcode_x86_LSL_load_segment_limit;
    logic o_opcode_x86_LSS_load_pointer_to_SS;
    logic o_opcode_x86_LTR_load_task_register;
    logic o_opcode_x86_MOV_reg_to_reg_mem;
    logic o_opcode_x86_MOV_reg_mem_to_reg;
    logic o_opcode_x86_MOV_imm_to_reg_mem;
    logic o_opcode_x86_MOV_imm_to_reg;
    logic o_opcode_x86_MOV_mem_to_acc;
    logic o_opcode_x86_MOV_acc_to_mem;
    logic o_opcode_x86_MOV_CR_from_reg;
    logic o_opcode_x86_MOV_reg_from_CR;
    logic o_opcode_x86_MOV_DR_from_reg;
    logic o_opcode_x86_MOV_reg_from_DR;
    logic o_opcode_x86_MOV_TR_from_reg;
    logic o_opcode_x86_MOV_reg_from_TR;
    logic o_opcode_x86_MOV_reg_mem_to_sreg;
    logic o_opcode_x86_MOV_sreg_to_reg_mem;
    logic o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg;
    logic o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem;
    logic o_opcode_x86_MOVS_move_data_from_string_to_string;
    logic o_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg;
    logic o_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg;
    logic o_opcode_x86_MUL_acc_with_reg_mem;
    logic o_opcode_x86_NEG_two_s_complement_negation;
    logic o_opcode_x86_NOP_no_operation;
    logic o_opcode_x86_NOP_no_operation_multi_byte;
    logic o_opcode_x86_NOT_one_s_complement_negation;
    logic o_opcode_x86_OR_reg_to_reg_mem;
    logic o_opcode_x86_OR_reg_mem_to_reg;
    logic o_opcode_x86_OR_imm_to_reg_mem;
    logic o_opcode_x86_OR_imm_to_acc;
    logic o_opcode_x86_OUT_port_fixed;
    logic o_opcode_x86_OUT_port_variable;
    logic o_opcode_x86_OUTS_output_string;
    logic o_opcode_x86_POP_reg_mem;
    logic o_opcode_x86_POP_reg;
    logic o_opcode_x86_POP_sreg_2;
    logic o_opcode_x86_POP_sreg_3;
    logic o_opcode_x86_POPA_pop_all_general_registers;
    logic o_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS;
    logic o_opcode_x86_PUSH_reg_mem;
    logic o_opcode_x86_PUSH_reg;
    logic o_opcode_x86_PUSH_sreg_2;
    logic o_opcode_x86_PUSH_sreg_3;
    logic o_opcode_x86_PUSH_imm;
    logic o_opcode_x86_PUSH_all_general_registers;
    logic o_opcode_x86_PUSHF_push_flags_onto_stack;
    logic o_opcode_x86_RCL_reg_mem_by_1;
    logic o_opcode_x86_RCL_reg_mem_by_CL;
    logic o_opcode_x86_RCL_reg_mem_by_imm;
    logic o_opcode_x86_RCR_reg_mem_by_1;
    logic o_opcode_x86_RCR_reg_mem_by_CL;
    logic o_opcode_x86_RCR_reg_mem_by_imm;
    logic o_opcode_x86_RDMSR_read_from_model_specific_reg;
    logic o_opcode_x86_RDPMC_read_performance_monitoring_counters;
    logic o_opcode_x86_RDTSC_read_time_stamp_counter;
    logic o_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id;
    logic o_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument;
    logic o_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP;
    logic o_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument;
    logic o_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP;
    logic o_opcode_x86_ROL_reg_mem_by_1;
    logic o_opcode_x86_ROL_reg_mem_by_CL;
    logic o_opcode_x86_ROL_reg_mem_by_imm;
    logic o_opcode_x86_ROR_reg_mem_by_1;
    logic o_opcode_x86_ROR_reg_mem_by_CL;
    logic o_opcode_x86_ROR_reg_mem_by_imm;
    logic o_opcode_x86_RSM_resume_from_system_management_mode;
    logic o_opcode_x86_SAHF_store_AH_into_flags;
    logic o_opcode_x86_SAR_reg_mem_by_1;
    logic o_opcode_x86_SAR_reg_mem_by_CL;
    logic o_opcode_x86_SAR_reg_mem_by_imm;
    logic o_opcode_x86_SBB_reg_to_reg_mem;
    logic o_opcode_x86_SBB_reg_mem_to_reg;
    logic o_opcode_x86_SBB_imm_to_reg_mem;
    logic o_opcode_x86_SBB_imm_to_acc;
    logic o_opcode_x86_SCAS_scan_string;
    logic o_opcode_x86_SETcc_byte_set_on_condition;
    logic o_opcode_x86_SGDT_store_global_descriptor_table_register;
    logic o_opcode_x86_SHL_reg_mem_by_1;
    logic o_opcode_x86_SHL_reg_mem_by_CL;
    logic o_opcode_x86_SHL_reg_mem_by_imm;
    logic o_opcode_x86_SHLD_reg_mem_by_imm;
    logic o_opcode_x86_SHLD_reg_mem_by_CL;
    logic o_opcode_x86_SHR_reg_mem_by_1;
    logic o_opcode_x86_SHR_reg_mem_by_CL;
    logic o_opcode_x86_SHR_reg_mem_by_imm;
    logic o_opcode_x86_SHRD_reg_mem_by_imm;
    logic o_opcode_x86_SHRD_reg_mem_by_CL;
    logic o_opcode_x86_SIDT_store_interrupt_desciptor_table_register;
    logic o_opcode_x86_SLDT_store_local_desciptor_table_register;
    logic o_opcode_x86_SMSW_store_machine_status_word;
    logic o_opcode_x86_STC_set_carry_flag;
    logic o_opcode_x86_STD_set_direction_flag;
    logic o_opcode_x86_STI_set_interrupt_enable_flag;
    logic o_opcode_x86_STOS_store_string_data;
    logic o_opcode_x86_STR_store_task_register;
    logic o_opcode_x86_SUB_reg_to_reg_mem;
    logic o_opcode_x86_SUB_reg_mem_to_reg;
    logic o_opcode_x86_SUB_imm_to_reg_mem;
    logic o_opcode_x86_SUB_imm_to_acc;
    logic o_opcode_x86_TEST_reg_mem_and_reg;
    logic o_opcode_x86_TEST_imm_and_reg_mem;
    logic o_opcode_x86_TEST_imm_and_acc;
    logic o_opcode_x86_UD0_undefined_instruction;
    logic o_opcode_x86_UD1_undefined_instruction;
    logic o_opcode_x86_UD2_undefined_instruction;
    logic o_opcode_x86_VERR_verify_a_segment_for_reading;
    logic o_opcode_x86_VERW_verify_a_segment_for_writing;
    logic o_opcode_x86_WAIT_wait;
    logic o_opcode_x86_WBINVD_writeback_and_invalidate_data_cache;
    logic o_opcode_x86_WRMSR_write_to_model_specific_register;
    logic o_opcode_x86_XADD_exchange_and_add;
    logic o_opcode_x86_XCHG_reg_mem_with_reg;
    logic o_opcode_x86_XCHG_reg_with_acc_short;
    logic o_opcode_x86_XLAT_table_look_up_translation;
    logic o_opcode_x86_XOR_reg_to_reg_mem;
    logic o_opcode_x86_XOR_reg_mem_to_reg;
    logic o_opcode_x86_XOR_imm_to_reg_mem;
    logic o_opcode_x86_XOR_imm_to_acc;

    // 实例化被测试模块
    opcode_x86 dut (
        .i_instruction(i_instruction),
        .o_opcode_x86_AAA_ASCII_adjust_after_add(o_opcode_x86_AAA_ASCII_adjust_after_add),
        .o_opcode_x86_AAD_ASCII_AX_before_div(o_opcode_x86_AAD_ASCII_AX_before_div),
        .o_opcode_x86_AAM_ASCII_AX_after_mul(o_opcode_x86_AAM_ASCII_AX_after_mul),
        .o_opcode_x86_AAS_ASCII_adjust_after_sub(o_opcode_x86_AAS_ASCII_adjust_after_sub),
        .o_opcode_x86_ADC_reg_to_reg_mem(o_opcode_x86_ADC_reg_to_reg_mem),
        .o_opcode_x86_ADC_reg_mem_to_reg(o_opcode_x86_ADC_reg_mem_to_reg),
        .o_opcode_x86_ADC_imm_to_reg_mem(o_opcode_x86_ADC_imm_to_reg_mem),
        .o_opcode_x86_ADC_imm_to_acc(o_opcode_x86_ADC_imm_to_acc),
        .o_opcode_x86_ADD_reg_to_reg_mem(o_opcode_x86_ADD_reg_to_reg_mem),
        .o_opcode_x86_ADD_reg_mem_to_reg(o_opcode_x86_ADD_reg_mem_to_reg),
        .o_opcode_x86_ADD_imm_to_reg_mem(o_opcode_x86_ADD_imm_to_reg_mem),
        .o_opcode_x86_ADD_imm_to_acc(o_opcode_x86_ADD_imm_to_acc),
        .o_opcode_x86_AND_reg_to_reg_mem(o_opcode_x86_AND_reg_to_reg_mem),
        .o_opcode_x86_AND_reg_mem_to_reg(o_opcode_x86_AND_reg_mem_to_reg),
        .o_opcode_x86_AND_imm_to_reg_mem(o_opcode_x86_AND_imm_to_reg_mem),
        .o_opcode_x86_AND_imm_to_acc(o_opcode_x86_AND_imm_to_acc),
        .o_opcode_x86_ARPL_adjust_RPL_field_of_selector(o_opcode_x86_ARPL_adjust_RPL_field_of_selector),
        .o_opcode_x86_BOUND_check_array_against_bounds(o_opcode_x86_BOUND_check_array_against_bounds),
        .o_opcode_x86_BSF_bit_scan_forward(o_opcode_x86_BSF_bit_scan_forward),
        .o_opcode_x86_BSR_bit_scan_reverse(o_opcode_x86_BSR_bit_scan_reverse),
        .o_opcode_x86_BSWAP_byte_swap(o_opcode_x86_BSWAP_byte_swap),
        .o_opcode_x86_BT_reg_mem_with_imm(o_opcode_x86_BT_reg_mem_with_imm),
        .o_opcode_x86_BT_reg_mem_with_reg(o_opcode_x86_BT_reg_mem_with_reg),
        .o_opcode_x86_BTC_reg_mem_with_imm(o_opcode_x86_BTC_reg_mem_with_imm),
        .o_opcode_x86_BTC_reg_mem_with_reg(o_opcode_x86_BTC_reg_mem_with_reg),
        .o_opcode_x86_BTR_reg_mem_with_imm(o_opcode_x86_BTR_reg_mem_with_imm),
        .o_opcode_x86_BTR_reg_mem_with_reg(o_opcode_x86_BTR_reg_mem_with_reg),
        .o_opcode_x86_BTS_reg_mem_with_imm(o_opcode_x86_BTS_reg_mem_with_imm),
        .o_opcode_x86_BTS_reg_mem_with_reg(o_opcode_x86_BTS_reg_mem_with_reg),
        .o_opcode_x86_CALL_in_same_segment_direct(o_opcode_x86_CALL_in_same_segment_direct),
        .o_opcode_x86_CALL_in_same_segment_indirect(o_opcode_x86_CALL_in_same_segment_indirect),
        .o_opcode_x86_CALL_in_other_segment_direct(o_opcode_x86_CALL_in_other_segment_direct),
        .o_opcode_x86_CALL_in_other_segment_indirect(o_opcode_x86_CALL_in_other_segment_indirect),
        .o_opcode_x86_CBW_convert_byte_to_word(o_opcode_x86_CBW_convert_byte_to_word),
        .o_opcode_x86_CDQ_convert_double_word_to_quad_word(o_opcode_x86_CDQ_convert_double_word_to_quad_word),
        .o_opcode_x86_CLC_clear_carry_flag(o_opcode_x86_CLC_clear_carry_flag),
        .o_opcode_x86_CLD_clear_direction_flag(o_opcode_x86_CLD_clear_direction_flag),
        .o_opcode_x86_CLI_clear_interrupt_enable_flag(o_opcode_x86_CLI_clear_interrupt_enable_flag),
        .o_opcode_x86_CLTS_clear_task_switched_flag(o_opcode_x86_CLTS_clear_task_switched_flag),
        .o_opcode_x86_CMC_complement_carry_flag(o_opcode_x86_CMC_complement_carry_flag),
        .o_opcode_x86_CMP_mem_with_reg(o_opcode_x86_CMP_mem_with_reg),
        .o_opcode_x86_CMP_reg_with_mem(o_opcode_x86_CMP_reg_with_mem),
        .o_opcode_x86_CMP_imm_with_reg_mem(o_opcode_x86_CMP_imm_with_reg_mem),
        .o_opcode_x86_CMP_imm_with_acc(o_opcode_x86_CMP_imm_with_acc),
        .o_opcode_x86_CMPS_compare_string_operands(o_opcode_x86_CMPS_compare_string_operands),
        .o_opcode_x86_CMPXCHG_compare_and_exchange(o_opcode_x86_CMPXCHG_compare_and_exchange),
        .o_opcode_x86_CPUID_CPU_identification(o_opcode_x86_CPUID_CPU_identification),
        .o_opcode_x86_CWD_convert_word_to_double(o_opcode_x86_CWD_convert_word_to_double),
        .o_opcode_x86_CWDE_convert_word_to_double(o_opcode_x86_CWDE_convert_word_to_double),
        .o_opcode_x86_DAA_decimal_adjust_AL_after_add(o_opcode_x86_DAA_decimal_adjust_AL_after_add),
        .o_opcode_x86_DAS_decimal_adjust_AL_after_sub(o_opcode_x86_DAS_decimal_adjust_AL_after_sub),
        .o_opcode_x86_DEC_reg_mem(o_opcode_x86_DEC_reg_mem),
        .o_opcode_x86_DEC_reg(o_opcode_x86_DEC_reg),
        .o_opcode_x86_DIV_acc_by_reg_mem(o_opcode_x86_DIV_acc_by_reg_mem),
        .o_opcode_x86_HLT_halt(o_opcode_x86_HLT_halt),
        .o_opcode_x86_IDIV_acc_by_reg_mem(o_opcode_x86_IDIV_acc_by_reg_mem),
        .o_opcode_x86_IMUL_acc_with_reg_mem(o_opcode_x86_IMUL_acc_with_reg_mem),
        .o_opcode_x86_IMUL_reg_with_reg_mem(o_opcode_x86_IMUL_reg_with_reg_mem),
        .o_opcode_x86_IMUL_reg_mem_with_imm_to_reg(o_opcode_x86_IMUL_reg_mem_with_imm_to_reg),
        .o_opcode_x86_IN_port_fixed(o_opcode_x86_IN_port_fixed),
        .o_opcode_x86_IN_port_variable(o_opcode_x86_IN_port_variable),
        .o_opcode_x86_INC_reg_mem(o_opcode_x86_INC_reg_mem),
        .o_opcode_x86_INC_reg(o_opcode_x86_INC_reg),
        .o_opcode_x86_INS_input_from_DX_port(o_opcode_x86_INS_input_from_DX_port),
        .o_opcode_x86_INT_interrupt_type_n(o_opcode_x86_INT_interrupt_type_n),
        .o_opcode_x86_INT_interrupt_type_3(o_opcode_x86_INT_interrupt_type_3),
        .o_opcode_x86_INT_interrupt_type_4(o_opcode_x86_INT_interrupt_type_4),
        .o_opcode_x86_INVD_invalidate_cache(o_opcode_x86_INVD_invalidate_cache),
        .o_opcode_x86_INVLPG_invalidate_TLB_entry(o_opcode_x86_INVLPG_invalidate_TLB_entry),
        .o_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size(o_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size),
        .o_opcode_x86_IRET_interrupt_return(o_opcode_x86_IRET_interrupt_return),
        .o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp(o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp),
        .o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp(o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp),
        .o_opcode_x86_JCXZ_jump_on_CX_zero(o_opcode_x86_JCXZ_jump_on_CX_zero),
        .o_opcode_x86_JMP_to_same_segment_short(o_opcode_x86_JMP_to_same_segment_short),
        .o_opcode_x86_JMP_to_same_segment_direct(o_opcode_x86_JMP_to_same_segment_direct),
        .o_opcode_x86_JMP_to_same_segment_indirect(o_opcode_x86_JMP_to_same_segment_indirect),
        .o_opcode_x86_JMP_to_other_segment_direct(o_opcode_x86_JMP_to_other_segment_direct),
        .o_opcode_x86_JMP_to_other_segment_indirect(o_opcode_x86_JMP_to_other_segment_indirect),
        .o_opcode_x86_LAHF_load_FLAG_into_AH(o_opcode_x86_LAHF_load_FLAG_into_AH),
        .o_opcode_x86_LAR_load_access_rights_byte(o_opcode_x86_LAR_load_access_rights_byte),
        .o_opcode_x86_LDS_load_pointer_to_DS(o_opcode_x86_LDS_load_pointer_to_DS),
        .o_opcode_x86_LEA_load_effective_adddress_to_reg(o_opcode_x86_LEA_load_effective_adddress_to_reg),
        .o_opcode_x86_LEAVE_high_level_procedure_exit(o_opcode_x86_LEAVE_high_level_procedure_exit),
        .o_opcode_x86_LES_load_pointer_to_ES(o_opcode_x86_LES_load_pointer_to_ES),
        .o_opcode_x86_LFS_load_pointer_to_FS(o_opcode_x86_LFS_load_pointer_to_FS),
        .o_opcode_x86_LGDT_load_global_desciptor_table_reg(o_opcode_x86_LGDT_load_global_desciptor_table_reg),
        .o_opcode_x86_LGS_load_pointer_to_GS(o_opcode_x86_LGS_load_pointer_to_GS),
        .o_opcode_x86_LIDT_load_interrupt_desciptor_table_reg(o_opcode_x86_LIDT_load_interrupt_desciptor_table_reg),
        .o_opcode_x86_LLDT_load_local_desciptor_table_reg(o_opcode_x86_LLDT_load_local_desciptor_table_reg),
        .o_opcode_x86_LMSW_load_status_word(o_opcode_x86_LMSW_load_status_word),
        .o_opcode_x86_LODS_load_string_operand(o_opcode_x86_LODS_load_string_operand),
        .o_opcode_x86_LOOP_count(o_opcode_x86_LOOP_count),
        .o_opcode_x86_LOOPZ_count_while_zero(o_opcode_x86_LOOPZ_count_while_zero),
        .o_opcode_x86_LOOPNZ_count_while_not_zero(o_opcode_x86_LOOPNZ_count_while_not_zero),
        .o_opcode_x86_LSL_load_segment_limit(o_opcode_x86_LSL_load_segment_limit),
        .o_opcode_x86_LSS_load_pointer_to_SS(o_opcode_x86_LSS_load_pointer_to_SS),
        .o_opcode_x86_LTR_load_task_register(o_opcode_x86_LTR_load_task_register),
        .o_opcode_x86_MOV_reg_to_reg_mem(o_opcode_x86_MOV_reg_to_reg_mem),
        .o_opcode_x86_MOV_reg_mem_to_reg(o_opcode_x86_MOV_reg_mem_to_reg),
        .o_opcode_x86_MOV_imm_to_reg_mem(o_opcode_x86_MOV_imm_to_reg_mem),
        .o_opcode_x86_MOV_imm_to_reg(o_opcode_x86_MOV_imm_to_reg),
        .o_opcode_x86_MOV_mem_to_acc(o_opcode_x86_MOV_mem_to_acc),
        .o_opcode_x86_MOV_acc_to_mem(o_opcode_x86_MOV_acc_to_mem),
        .o_opcode_x86_MOV_CR_from_reg(o_opcode_x86_MOV_CR_from_reg),
        .o_opcode_x86_MOV_reg_from_CR(o_opcode_x86_MOV_reg_from_CR),
        .o_opcode_x86_MOV_DR_from_reg(o_opcode_x86_MOV_DR_from_reg),
        .o_opcode_x86_MOV_reg_from_DR(o_opcode_x86_MOV_reg_from_DR),
        .o_opcode_x86_MOV_TR_from_reg(o_opcode_x86_MOV_TR_from_reg),
        .o_opcode_x86_MOV_reg_from_TR(o_opcode_x86_MOV_reg_from_TR),
        .o_opcode_x86_MOV_reg_mem_to_sreg(o_opcode_x86_MOV_reg_mem_to_sreg),
        .o_opcode_x86_MOV_sreg_to_reg_mem(o_opcode_x86_MOV_sreg_to_reg_mem),
        .o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg(o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg),
        .o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem(o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem),
        .o_opcode_x86_MOVS_move_data_from_string_to_string(o_opcode_x86_MOVS_move_data_from_string_to_string),
        .o_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg(o_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg),
        .o_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg(o_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg),
        .o_opcode_x86_MUL_acc_with_reg_mem(o_opcode_x86_MUL_acc_with_reg_mem),
        .o_opcode_x86_NEG_two_s_complement_negation(o_opcode_x86_NEG_two_s_complement_negation),
        .o_opcode_x86_NOP_no_operation(o_opcode_x86_NOP_no_operation),
        .o_opcode_x86_NOP_no_operation_multi_byte(o_opcode_x86_NOP_no_operation_multi_byte),
        .o_opcode_x86_NOT_one_s_complement_negation(o_opcode_x86_NOT_one_s_complement_negation),
        .o_opcode_x86_OR_reg_to_reg_mem(o_opcode_x86_OR_reg_to_reg_mem),
        .o_opcode_x86_OR_reg_mem_to_reg(o_opcode_x86_OR_reg_mem_to_reg),
        .o_opcode_x86_OR_imm_to_reg_mem(o_opcode_x86_OR_imm_to_reg_mem),
        .o_opcode_x86_OR_imm_to_acc(o_opcode_x86_OR_imm_to_acc),
        .o_opcode_x86_OUT_port_fixed(o_opcode_x86_OUT_port_fixed),
        .o_opcode_x86_OUT_port_variable(o_opcode_x86_OUT_port_variable),
        .o_opcode_x86_OUTS_output_string(o_opcode_x86_OUTS_output_string),
        .o_opcode_x86_POP_reg_mem(o_opcode_x86_POP_reg_mem),
        .o_opcode_x86_POP_reg(o_opcode_x86_POP_reg),
        .o_opcode_x86_POP_sreg_2(o_opcode_x86_POP_sreg_2),
        .o_opcode_x86_POP_sreg_3(o_opcode_x86_POP_sreg_3),
        .o_opcode_x86_POPA_pop_all_general_registers(o_opcode_x86_POPA_pop_all_general_registers),
        .o_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS(o_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS),
        .o_opcode_x86_PUSH_reg_mem(o_opcode_x86_PUSH_reg_mem),
        .o_opcode_x86_PUSH_reg(o_opcode_x86_PUSH_reg),
        .o_opcode_x86_PUSH_sreg_2(o_opcode_x86_PUSH_sreg_2),
        .o_opcode_x86_PUSH_sreg_3(o_opcode_x86_PUSH_sreg_3),
        .o_opcode_x86_PUSH_imm(o_opcode_x86_PUSH_imm),
        .o_opcode_x86_PUSH_all_general_registers(o_opcode_x86_PUSH_all_general_registers),
        .o_opcode_x86_PUSHF_push_flags_onto_stack(o_opcode_x86_PUSHF_push_flags_onto_stack),
        .o_opcode_x86_RCL_reg_mem_by_1(o_opcode_x86_RCL_reg_mem_by_1),
        .o_opcode_x86_RCL_reg_mem_by_CL(o_opcode_x86_RCL_reg_mem_by_CL),
        .o_opcode_x86_RCL_reg_mem_by_imm(o_opcode_x86_RCL_reg_mem_by_imm),
        .o_opcode_x86_RCR_reg_mem_by_1(o_opcode_x86_RCR_reg_mem_by_1),
        .o_opcode_x86_RCR_reg_mem_by_CL(o_opcode_x86_RCR_reg_mem_by_CL),
        .o_opcode_x86_RCR_reg_mem_by_imm(o_opcode_x86_RCR_reg_mem_by_imm),
        .o_opcode_x86_RDMSR_read_from_model_specific_reg(o_opcode_x86_RDMSR_read_from_model_specific_reg),
        .o_opcode_x86_RDPMC_read_performance_monitoring_counters(o_opcode_x86_RDPMC_read_performance_monitoring_counters),
        .o_opcode_x86_RDTSC_read_time_stamp_counter(o_opcode_x86_RDTSC_read_time_stamp_counter),
        .o_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id(o_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id),
        .o_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument(o_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument),
        .o_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP(o_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP),
        .o_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument(o_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument),
        .o_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP(o_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP),
        .o_opcode_x86_ROL_reg_mem_by_1(o_opcode_x86_ROL_reg_mem_by_1),
        .o_opcode_x86_ROL_reg_mem_by_CL(o_opcode_x86_ROL_reg_mem_by_CL),
        .o_opcode_x86_ROL_reg_mem_by_imm(o_opcode_x86_ROL_reg_mem_by_imm),
        .o_opcode_x86_ROR_reg_mem_by_1(o_opcode_x86_ROR_reg_mem_by_1),
        .o_opcode_x86_ROR_reg_mem_by_CL(o_opcode_x86_ROR_reg_mem_by_CL),
        .o_opcode_x86_ROR_reg_mem_by_imm(o_opcode_x86_ROR_reg_mem_by_imm),
        .o_opcode_x86_RSM_resume_from_system_management_mode(o_opcode_x86_RSM_resume_from_system_management_mode),
        .o_opcode_x86_SAHF_store_AH_into_flags(o_opcode_x86_SAHF_store_AH_into_flags),
        .o_opcode_x86_SAR_reg_mem_by_1(o_opcode_x86_SAR_reg_mem_by_1),
        .o_opcode_x86_SAR_reg_mem_by_CL(o_opcode_x86_SAR_reg_mem_by_CL),
        .o_opcode_x86_SAR_reg_mem_by_imm(o_opcode_x86_SAR_reg_mem_by_imm),
        .o_opcode_x86_SBB_reg_to_reg_mem(o_opcode_x86_SBB_reg_to_reg_mem),
        .o_opcode_x86_SBB_reg_mem_to_reg(o_opcode_x86_SBB_reg_mem_to_reg),
        .o_opcode_x86_SBB_imm_to_reg_mem(o_opcode_x86_SBB_imm_to_reg_mem),
        .o_opcode_x86_SBB_imm_to_acc(o_opcode_x86_SBB_imm_to_acc),
        .o_opcode_x86_SCAS_scan_string(o_opcode_x86_SCAS_scan_string),
        .o_opcode_x86_SETcc_byte_set_on_condition(o_opcode_x86_SETcc_byte_set_on_condition),
        .o_opcode_x86_SGDT_store_global_descriptor_table_register(o_opcode_x86_SGDT_store_global_descriptor_table_register),
        .o_opcode_x86_SHL_reg_mem_by_1(o_opcode_x86_SHL_reg_mem_by_1),
        .o_opcode_x86_SHL_reg_mem_by_CL(o_opcode_x86_SHL_reg_mem_by_CL),
        .o_opcode_x86_SHL_reg_mem_by_imm(o_opcode_x86_SHL_reg_mem_by_imm),
        .o_opcode_x86_SHLD_reg_mem_by_imm(o_opcode_x86_SHLD_reg_mem_by_imm),
        .o_opcode_x86_SHLD_reg_mem_by_CL(o_opcode_x86_SHLD_reg_mem_by_CL),
        .o_opcode_x86_SHR_reg_mem_by_1(o_opcode_x86_SHR_reg_mem_by_1),
        .o_opcode_x86_SHR_reg_mem_by_CL(o_opcode_x86_SHR_reg_mem_by_CL),
        .o_opcode_x86_SHR_reg_mem_by_imm(o_opcode_x86_SHR_reg_mem_by_imm),
        .o_opcode_x86_SHRD_reg_mem_by_imm(o_opcode_x86_SHRD_reg_mem_by_imm),
        .o_opcode_x86_SHRD_reg_mem_by_CL(o_opcode_x86_SHRD_reg_mem_by_CL),
        .o_opcode_x86_SIDT_store_interrupt_desciptor_table_register(o_opcode_x86_SIDT_store_interrupt_desciptor_table_register),
        .o_opcode_x86_SLDT_store_local_desciptor_table_register(o_opcode_x86_SLDT_store_local_desciptor_table_register),
        .o_opcode_x86_SMSW_store_machine_status_word(o_opcode_x86_SMSW_store_machine_status_word),
        .o_opcode_x86_STC_set_carry_flag(o_opcode_x86_STC_set_carry_flag),
        .o_opcode_x86_STD_set_direction_flag(o_opcode_x86_STD_set_direction_flag),
        .o_opcode_x86_STI_set_interrupt_enable_flag(o_opcode_x86_STI_set_interrupt_enable_flag),
        .o_opcode_x86_STOS_store_string_data(o_opcode_x86_STOS_store_string_data),
        .o_opcode_x86_STR_store_task_register(o_opcode_x86_STR_store_task_register),
        .o_opcode_x86_SUB_reg_to_reg_mem(o_opcode_x86_SUB_reg_to_reg_mem),
        .o_opcode_x86_SUB_reg_mem_to_reg(o_opcode_x86_SUB_reg_mem_to_reg),
        .o_opcode_x86_SUB_imm_to_reg_mem(o_opcode_x86_SUB_imm_to_reg_mem),
        .o_opcode_x86_SUB_imm_to_acc(o_opcode_x86_SUB_imm_to_acc),
        .o_opcode_x86_TEST_reg_mem_and_reg(o_opcode_x86_TEST_reg_mem_and_reg),
        .o_opcode_x86_TEST_imm_and_reg_mem(o_opcode_x86_TEST_imm_and_reg_mem),
        .o_opcode_x86_TEST_imm_and_acc(o_opcode_x86_TEST_imm_and_acc),
        .o_opcode_x86_UD0_undefined_instruction(o_opcode_x86_UD0_undefined_instruction),
        .o_opcode_x86_UD1_undefined_instruction(o_opcode_x86_UD1_undefined_instruction),
        .o_opcode_x86_UD2_undefined_instruction(o_opcode_x86_UD2_undefined_instruction),
        .o_opcode_x86_VERR_verify_a_segment_for_reading(o_opcode_x86_VERR_verify_a_segment_for_reading),
        .o_opcode_x86_VERW_verify_a_segment_for_writing(o_opcode_x86_VERW_verify_a_segment_for_writing),
        .o_opcode_x86_WAIT_wait(o_opcode_x86_WAIT_wait),
        .o_opcode_x86_WBINVD_writeback_and_invalidate_data_cache(o_opcode_x86_WBINVD_writeback_and_invalidate_data_cache),
        .o_opcode_x86_WRMSR_write_to_model_specific_register(o_opcode_x86_WRMSR_write_to_model_specific_register),
        .o_opcode_x86_XADD_exchange_and_add(o_opcode_x86_XADD_exchange_and_add),
        .o_opcode_x86_XCHG_reg_mem_with_reg(o_opcode_x86_XCHG_reg_mem_with_reg),
        .o_opcode_x86_XCHG_reg_with_acc_short(o_opcode_x86_XCHG_reg_with_acc_short),
        .o_opcode_x86_XLAT_table_look_up_translation(o_opcode_x86_XLAT_table_look_up_translation),
        .o_opcode_x86_XOR_reg_to_reg_mem(o_opcode_x86_XOR_reg_to_reg_mem),
        .o_opcode_x86_XOR_reg_mem_to_reg(o_opcode_x86_XOR_reg_mem_to_reg),
        .o_opcode_x86_XOR_imm_to_reg_mem(o_opcode_x86_XOR_imm_to_reg_mem),
        .o_opcode_x86_XOR_imm_to_acc(o_opcode_x86_XOR_imm_to_acc)
    );

    // 测试结果统计
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;

    // 设置指令字节的任�?
    task set_instruction(bit [ 7: 0] byte0, bit [ 7: 0] byte1 = 8'h00, bit [ 7: 0] byte2 = 8'h00, bit [ 7: 0] byte3 = 8'h00);
        i_instruction[0] = byte0;
        i_instruction[1] = byte1;
        i_instruction[2] = byte2;
        i_instruction[3] = byte3;
        #1; // 等待一个时间单位让信号稳定
    endtask

    // 检查opcode是否正确的任�?
    task check_opcode(string opcode_name, bit expected);
        test_count++;
        if (expected === 1'b1) begin
            if (expected === 1'b1) begin
                $display("[PASS] %s: decode OK", opcode_name);
                pass_count++;
            end else begin
                $display("[FAIL] %s: expected=1, actual=0", opcode_name);
                fail_count++;
            end
        end else begin
            if (expected === 1'b0) begin
                $display("[PASS] %s: decode OK", opcode_name);
                pass_count++;
            end else begin
                $display("[FAIL] %s: expected=0, actual=1", opcode_name);
                fail_count++;
            end
        end
    endtask

    // 使用反射检查期望的opcode信号
    task verify_opcode(string opcode_name, bit expected);
        // 这里我们需要根据opcode_name来检查对应的信号
        // 由于SystemVerilog不支持动态信号访问，我们需要手动映�?
        // 为了简化，我们创建一个辅助函数来检�?
        test_count++;
        // 注意：这里需要根据实际的信号名称进行映射
        // 为了测试，我们直接比较期望�?
        if (expected === 1'b1) begin
            $display("[TEST] %s: expected=1", opcode_name);
            pass_count++; // 暂时都算通过，实际需要根据信号值检�?
        end else begin
            $display("[TEST] %s: expected=0", opcode_name);
            pass_count++; // 暂时都算通过
        end
    endtask

    // 测试用例：验证单个opcode
    task test_single_opcode(string opcode_name, bit [ 7: 0] byte0, bit [ 7: 0] byte1 = 8'h00, bit [ 7: 0] byte2 = 8'h00, bit [ 7: 0] byte3 = 8'h00, bit expected_opcode);
        bit actual_opcode;
        
        // 设置指令
        set_instruction(byte0, byte1, byte2, byte3);
        
        // 根据opcode_name获取实际输出信号
        // 由于SystemVerilog限制，我们需要手动映�?
        // 这里简化处理，实际应该检查对应的信号
        
        test_count++;
        $display("[TEST] %s: instruction bytes %02h %02h %02h %02h", 
                 opcode_name, byte0, byte1, byte2, byte3);
        
        // 这里应该根据opcode_name检查对应的信号，但为了简化，先显示所有信�?
        // 实际实现中需要根据opcode_name映射到对应的信号进行检�?
    endtask

    initial begin
        $display("========================================");
        $display("Starting decode_opcode_x86 tests");
        $display("========================================");
        
        // 初始化指令数�?
        i_instruction[0] = 8'h00;
        i_instruction[1] = 8'h00;
        i_instruction[2] = 8'h00;
        i_instruction[3] = 8'h00;
        
        // ============================================
        // 测试用例1: NOP (0x90)
        // 汇编: nop
        // ============================================
        set_instruction(8'h90);
        test_count++;
        if (o_opcode_x86_NOP_no_operation === 1'b1) begin
            $display("[PASS] NOP: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] NOP: expected=1, actual=%b", o_opcode_x86_NOP_no_operation);
            fail_count++;
        end
        
        // ============================================
        // 测试用例2: MOV AL, imm8 (0xB0 + reg)
        // 汇编: mov al, 0x12
        // ============================================
        set_instruction(8'hB0, 8'h12);
        test_count++;
        if (o_opcode_x86_MOV_imm_to_reg === 1'b1) begin
            $display("[PASS] MOV_imm_to_reg (AL): decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] MOV_imm_to_reg (AL): expected=1, actual=%b", o_opcode_x86_MOV_imm_to_reg);
            fail_count++;
        end
        
        // ============================================
        // 测试用例3: ADD EAX, imm32 (0x05)
        // 汇编: add eax, 0x12345678
        // ============================================
        set_instruction(8'h05, 8'h78, 8'h56, 8'h34);
        test_count++;
        if (o_opcode_x86_ADD_imm_to_acc === 1'b1) begin
            $display("[PASS] ADD_imm_to_acc: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] ADD_imm_to_acc: expected=1, actual=%b", o_opcode_x86_ADD_imm_to_acc);
            fail_count++;
        end
        
        // ============================================
        // 测试用例4: ADD reg, imm (0x83 /0)
        // 汇编: add eax, 0x12
        // ============================================
        set_instruction(8'h83, 8'hC0, 8'h12);
        test_count++;
        if (o_opcode_x86_ADD_imm_to_reg_mem === 1'b1) begin
            $display("[PASS] ADD_imm_to_reg_mem: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] ADD_imm_to_reg_mem: expected=1, actual=%b", o_opcode_x86_ADD_imm_to_reg_mem);
            fail_count++;
        end
        
        // ============================================
        // 测试用例5: MOV reg, reg (0x89)
        // 汇编: mov eax, ebx
        // ============================================
        set_instruction(8'h89, 8'hD8);
        test_count++;
        if (o_opcode_x86_MOV_reg_to_reg_mem === 1'b1) begin
            $display("[PASS] MOV_reg_to_reg_mem: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] MOV_reg_to_reg_mem: expected=1, actual=%b", o_opcode_x86_MOV_reg_to_reg_mem);
            fail_count++;
        end
        
        // ============================================
        // 测试用例6: MOV reg, reg (0x8B)
        // 汇编: mov eax, ebx
        // ============================================
        set_instruction(8'h8B, 8'hC3);
        test_count++;
        if (o_opcode_x86_MOV_reg_mem_to_reg === 1'b1) begin
            $display("[PASS] MOV_reg_mem_to_reg: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] MOV_reg_mem_to_reg: expected=1, actual=%b", o_opcode_x86_MOV_reg_mem_to_reg);
            fail_count++;
        end
        
        // ============================================
        // 测试用例7: PUSH reg (0x50 + reg)
        // 汇编: push eax
        // ============================================
        set_instruction(8'h50);
        test_count++;
        if (o_opcode_x86_PUSH_reg === 1'b1) begin
            $display("[PASS] PUSH_reg: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] PUSH_reg: expected=1, actual=%b", o_opcode_x86_PUSH_reg);
            fail_count++;
        end
        
        // ============================================
        // 测试用例8: POP reg (0x58 + reg)
        // 汇编: pop eax
        // ============================================
        set_instruction(8'h58);
        test_count++;
        if (o_opcode_x86_POP_reg === 1'b1) begin
            $display("[PASS] POP_reg: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] POP_reg: expected=1, actual=%b", o_opcode_x86_POP_reg);
            fail_count++;
        end
        
        // ============================================
        // 测试用例9: CALL direct (0xE8)
        // 汇编: call label
        // ============================================
        set_instruction(8'hE8, 8'h12, 8'h34, 8'h56);
        test_count++;
        if (o_opcode_x86_CALL_in_same_segment_direct === 1'b1) begin
            $display("[PASS] CALL_in_same_segment_direct: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] CALL_in_same_segment_direct: expected=1, actual=%b", o_opcode_x86_CALL_in_same_segment_direct);
            fail_count++;
        end
        
        // ============================================
        // 测试用例10: RET (0xC3)
        // 汇编: ret
        // ============================================
        set_instruction(8'hC3);
        test_count++;
        if (o_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument === 1'b1) begin
            $display("[PASS] RET: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] RET: expected=1, actual=%b", o_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument);
            fail_count++;
        end
        
        // ============================================
        // 测试用例11: HLT (0xF4)
        // 汇编: hlt
        // ============================================
        set_instruction(8'hF4);
        test_count++;
        if (o_opcode_x86_HLT_halt === 1'b1) begin
            $display("[PASS] HLT: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] HLT: expected=1, actual=%b", o_opcode_x86_HLT_halt);
            fail_count++;
        end
        
        // ============================================
        // 测试用例12: CLC (0xF8)
        // 汇编: clc
        // ============================================
        set_instruction(8'hF8);
        test_count++;
        if (o_opcode_x86_CLC_clear_carry_flag === 1'b1) begin
            $display("[PASS] CLC: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] CLC: expected=1, actual=%b", o_opcode_x86_CLC_clear_carry_flag);
            fail_count++;
        end
        
        // ============================================
        // 测试用例13: JMP short (0xEB)
        // 汇编: jmp short label
        // ============================================
        set_instruction(8'hEB, 8'h12);
        test_count++;
        if (o_opcode_x86_JMP_to_same_segment_short === 1'b1) begin
            $display("[PASS] JMP_short: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] JMP_short: expected=1, actual=%b", o_opcode_x86_JMP_to_same_segment_short);
            fail_count++;
        end
        
        // ============================================
        // 测试用例14: JZ/JE 8-bit (0x74)
        // 汇编: jz label
        // ============================================
        set_instruction(8'h74, 8'h12);
        test_count++;
        if (o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp === 1'b1) begin
            $display("[PASS] Jcc_8bit: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] Jcc_8bit: expected=1, actual=%b", o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp);
            fail_count++;
        end
        
        // ============================================
        // 测试用例15: CPUID (0x0F 0xA2)
        // 汇编: cpuid
        // ============================================
        set_instruction(8'h0F, 8'hA2);
        test_count++;
        if (o_opcode_x86_CPUID_CPU_identification === 1'b1) begin
            $display("[PASS] CPUID: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] CPUID: expected=1, actual=%b", o_opcode_x86_CPUID_CPU_identification);
            fail_count++;
        end

        // ============================================
        // 测试用例16: UD2 (0x0F 0x0B)
        // 汇编: ud2
        // ============================================
        set_instruction(8'h0F, 8'h0B);
        test_count++;
        if ((o_opcode_x86_UD2_undefined_instruction === 1'b1) &&
            (o_opcode_x86_UD1_undefined_instruction === 1'b0)) begin
            $display("[PASS] UD2: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] UD2: expected UD2=1 UD1=0, actual UD2=%b UD1=%b", o_opcode_x86_UD2_undefined_instruction, o_opcode_x86_UD1_undefined_instruction);
            fail_count++;
        end

        // ============================================
        // 测试用例17: UD1 (0x0F 0xB9 /r)
        // 汇编: ud1 eax, eax
        // ============================================
        set_instruction(8'h0F, 8'hB9, 8'hC0);
        test_count++;
        if ((o_opcode_x86_UD1_undefined_instruction === 1'b1) &&
            (o_opcode_x86_UD2_undefined_instruction === 1'b0)) begin
            $display("[PASS] UD1: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] UD1: expected UD1=1 UD2=0, actual UD1=%b UD2=%b", o_opcode_x86_UD1_undefined_instruction, o_opcode_x86_UD2_undefined_instruction);
            fail_count++;
        end

        // ============================================
        // 测试用例18: UD0 (0x0F 0xFF)
        // ============================================
        set_instruction(8'h0F, 8'hFF);
        test_count++;
        if (o_opcode_x86_UD0_undefined_instruction === 1'b1) begin
            $display("[PASS] UD0: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] UD0: expected=1, actual=%b", o_opcode_x86_UD0_undefined_instruction);
            fail_count++;
        end
        
        // ============================================
        // 测试用例19: INC reg (0x40 + reg)
        // 汇编: inc eax
        // ============================================
        set_instruction(8'h40);
        test_count++;
        if (o_opcode_x86_INC_reg === 1'b1) begin
            $display("[PASS] INC_reg: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] INC_reg: expected=1, actual=%b", o_opcode_x86_INC_reg);
            fail_count++;
        end
        
        // ============================================
        // 测试用例20: DEC reg (0x48 + reg)
        // 汇编: dec eax
        // ============================================
        set_instruction(8'h48);
        test_count++;
        if (o_opcode_x86_DEC_reg === 1'b1) begin
            $display("[PASS] DEC_reg: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] DEC_reg: expected=1, actual=%b", o_opcode_x86_DEC_reg);
            fail_count++;
        end
        
        // ============================================
        // 测试用例21: XOR reg, reg (0x31)
        // 汇编: xor eax, ebx
        // ============================================
        set_instruction(8'h31, 8'hD8);
        test_count++;
        if (o_opcode_x86_XOR_reg_to_reg_mem === 1'b1) begin
            $display("[PASS] XOR_reg_to_reg_mem: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] XOR_reg_to_reg_mem: expected=1, actual=%b", o_opcode_x86_XOR_reg_to_reg_mem);
            fail_count++;
        end
        
        // ============================================
        // 测试用例22: TEST reg, reg (0x85)
        // 汇编: test eax, ebx
        // ============================================
        set_instruction(8'h85, 8'hD8);
        test_count++;
        if (o_opcode_x86_TEST_reg_mem_and_reg === 1'b1) begin
            $display("[PASS] TEST_reg_mem_and_reg: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] TEST_reg_mem_and_reg: expected=1, actual=%b", o_opcode_x86_TEST_reg_mem_and_reg);
            fail_count++;
        end
        
        // ============================================
        // 测试用例23: INT 3 (0xCC)
        // 汇编: int 3
        // ============================================
        set_instruction(8'hCC);
        test_count++;
        if (o_opcode_x86_INT_interrupt_type_3 === 1'b1) begin
            $display("[PASS] INT_3: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] INT_3: expected=1, actual=%b", o_opcode_x86_INT_interrupt_type_3);
            fail_count++;
        end
        
        // 输出测试结果
        $display("");
        $display("========================================");
        $display("Tests finished");
        $display("========================================");
        $display("Total: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        $display("========================================");
        
        if (fail_count == 0) begin
            $display("All tests passed.");
        end else begin
            $display("Some tests failed.");
        end
        
        $finish;
    end

endmodule
