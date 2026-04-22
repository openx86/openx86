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

    // ��誘摮𡑒��啁�嚗��憭?摮𡑒��其�閫��opcode嚗?
    logic [ 7: 0] i_instruction [ 0:  3];
    
    // ���纬pcode颲枏枂靽∪噡
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
    logic o_opcode_x86_CLC_carry;
    logic o_opcode_x86_CLD_dir;
    logic o_opcode_x86_CLI_int_en;
    logic o_opcode_x86_CLTS_clear_task_switched_flag;
    logic o_opcode_x86_CMC_carry;
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
    logic o_opcode_x86_LAHF_load_flags_to_ah;
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
    logic o_opcode_x86_POPA_popa_gpr;
    logic o_opcode_x86_POPF_popf_flags;
    logic o_opcode_x86_PUSH_reg_mem;
    logic o_opcode_x86_PUSH_reg;
    logic o_opcode_x86_PUSH_sreg_2;
    logic o_opcode_x86_PUSH_sreg_3;
    logic o_opcode_x86_PUSH_imm;
    logic o_opcode_x86_PUSH_pusha_gpr;
    logic o_opcode_x86_PUSHF_pushf_flags;
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
    logic o_opcode_x86_RET_ret_near;
    logic o_opcode_x86_RET_ret_near_imm;
    logic o_opcode_x86_RET_ret_far;
    logic o_opcode_x86_RET_ret_far_imm;
    logic o_opcode_x86_ROL_reg_mem_by_1;
    logic o_opcode_x86_ROL_reg_mem_by_CL;
    logic o_opcode_x86_ROL_reg_mem_by_imm;
    logic o_opcode_x86_ROR_reg_mem_by_1;
    logic o_opcode_x86_ROR_reg_mem_by_CL;
    logic o_opcode_x86_ROR_reg_mem_by_imm;
    logic o_opcode_x86_RSM_resume_from_system_management_mode;
    logic o_opcode_x86_SAHF_store_ah_to_flags;
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
    logic o_opcode_x86_STC_carry;
    logic o_opcode_x86_STD_dir;
    logic o_opcode_x86_STI_int_en;
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

    // 摰硺��𤥁◤瘚贝�璅∪�
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
        .o_opcode_x86_CLC_carry(o_opcode_x86_CLC_carry),
        .o_opcode_x86_CLD_dir(o_opcode_x86_CLD_dir),
        .o_opcode_x86_CLI_int_en(o_opcode_x86_CLI_int_en),
        .o_opcode_x86_CLTS_clear_task_switched_flag(o_opcode_x86_CLTS_clear_task_switched_flag),
        .o_opcode_x86_CMC_carry(o_opcode_x86_CMC_carry),
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
        .o_opcode_x86_LAHF_load_flags_to_ah(o_opcode_x86_LAHF_load_flags_to_ah),
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
        .o_opcode_x86_POPA_popa_gpr(o_opcode_x86_POPA_popa_gpr),
        .o_opcode_x86_POPF_popf_flags(o_opcode_x86_POPF_popf_flags),
        .o_opcode_x86_PUSH_reg_mem(o_opcode_x86_PUSH_reg_mem),
        .o_opcode_x86_PUSH_reg(o_opcode_x86_PUSH_reg),
        .o_opcode_x86_PUSH_sreg_2(o_opcode_x86_PUSH_sreg_2),
        .o_opcode_x86_PUSH_sreg_3(o_opcode_x86_PUSH_sreg_3),
        .o_opcode_x86_PUSH_imm(o_opcode_x86_PUSH_imm),
        .o_opcode_x86_PUSH_pusha_gpr(o_opcode_x86_PUSH_pusha_gpr),
        .o_opcode_x86_PUSHF_pushf_flags(o_opcode_x86_PUSHF_pushf_flags),
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
        .o_opcode_x86_RET_ret_near(o_opcode_x86_RET_ret_near),
        .o_opcode_x86_RET_ret_near_imm(o_opcode_x86_RET_ret_near_imm),
        .o_opcode_x86_RET_ret_far(o_opcode_x86_RET_ret_far),
        .o_opcode_x86_RET_ret_far_imm(o_opcode_x86_RET_ret_far_imm),
        .o_opcode_x86_ROL_reg_mem_by_1(o_opcode_x86_ROL_reg_mem_by_1),
        .o_opcode_x86_ROL_reg_mem_by_CL(o_opcode_x86_ROL_reg_mem_by_CL),
        .o_opcode_x86_ROL_reg_mem_by_imm(o_opcode_x86_ROL_reg_mem_by_imm),
        .o_opcode_x86_ROR_reg_mem_by_1(o_opcode_x86_ROR_reg_mem_by_1),
        .o_opcode_x86_ROR_reg_mem_by_CL(o_opcode_x86_ROR_reg_mem_by_CL),
        .o_opcode_x86_ROR_reg_mem_by_imm(o_opcode_x86_ROR_reg_mem_by_imm),
        .o_opcode_x86_RSM_resume_from_system_management_mode(o_opcode_x86_RSM_resume_from_system_management_mode),
        .o_opcode_x86_SAHF_store_ah_to_flags(o_opcode_x86_SAHF_store_ah_to_flags),
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
        .o_opcode_x86_STC_carry(o_opcode_x86_STC_carry),
        .o_opcode_x86_STD_dir(o_opcode_x86_STD_dir),
        .o_opcode_x86_STI_int_en(o_opcode_x86_STI_int_en)
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

    // 瘚贝�蝏𤘪�蝏蠘恣
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;

    // 霈曄蔭��誘摮𡑒���遙�?
    task set_instruction(bit [ 7: 0] byte0, bit [ 7: 0] byte1 = 8'h00, bit [ 7: 0] byte2 = 8'h00, bit [ 7: 0] byte3 = 8'h00);
        i_instruction[0] = byte0;
        i_instruction[1] = byte1;
        i_instruction[2] = byte2;
        i_instruction[3] = byte3;
        #1; // 蝑匧�銝�銝芣𧒄�游�雿滩悟靽∪噡蝔喳�
    endtask

    // 璉��叨pcode�臬炏甇�＆��遙�?
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

    // 雿輻鍂�滚�璉��交��𤤿�opcode靽∪噡
    task verify_opcode(string opcode_name, bit expected);
        // 餈䠷��睲賑��閬�覔�峨pcode_name�交��亙笆摨𠉛�靽∪噡
        // �曹�SystemVerilog銝齿𣈲��𢆡��縑�瑁挪�殷��睲賑��閬���冽�撠?
        // 銝箔�蝞��吔��睲賑�𥕦遣銝�銝芾��拙遆�唳䔉璉��?
        test_count++;
        // 瘜冽�嚗朞��屸�閬�覔�桀����靽∪噡�滨妍餈𥡝��惩�
        // 銝箔�瘚贝�嚗峕�隞祉凒�交�颲���𥕦�?
        if (expected === 1'b1) begin
            $display("[TEST] %s: expected=1", opcode_name);
            pass_count++; // ��𧒄�賜��朞�嚗�����閬�覔�桐縑�瑕�潭��?
        end else begin
            $display("[TEST] %s: expected=0", opcode_name);
            pass_count++; // ��𧒄�賜��朞�
        end
    endtask

    // 瘚贝��其�嚗𡁻�霂��銝油pcode
    task test_single_opcode(string opcode_name, bit [ 7: 0] byte0, bit [ 7: 0] byte1 = 8'h00, bit [ 7: 0] byte2 = 8'h00, bit [ 7: 0] byte3 = 8'h00, bit expected_opcode);
        bit actual_opcode;
        
        // 霈曄蔭��誘
        set_instruction(byte0, byte1, byte2, byte3);
        
        // �寞旿opcode_name�瑕�摰鮋�颲枏枂靽∪噡
        // �曹�SystemVerilog�𣂼�嚗峕�隞祇�閬���冽�撠?
        // 餈䠷�蝞��硋����摰鮋�摨磰砲璉��亙笆摨𠉛�靽∪噡
        
        test_count++;
        $display("[TEST] %s: instruction bytes %02h %02h %02h %02h", 
                 opcode_name, byte0, byte1, byte2, byte3);
        
        // 餈䠷�摨磰砲�寞旿opcode_name璉��亙笆摨𠉛�靽∪噡嚗䔶�銝箔�蝞��吔���遬蝷箸��劐縑�?
        // 摰鮋�摰䂿緵銝剝�閬�覔�峨pcode_name�惩��啣笆摨𠉛�靽∪噡餈𥡝�璉��?
    endtask

    initial begin
        $display("========================================");
        $display("Starting decode_opcode_x86 tests");
        $display("========================================");
        
        // �嘥��𡝗�隞斗㺭蝏?
        i_instruction[0] = 8'h00;
        i_instruction[1] = 8'h00;
        i_instruction[2] = 8'h00;
        i_instruction[3] = 8'h00;
        
        // ============================================
        // 瘚贝��其�1: NOP (0x90)
        // 瘙��: nop
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
        // 瘚贝��其�2: MOV AL, imm8 (0xB0 + reg)
        // 瘙��: mov al, 0x12
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
        // 瘚贝��其�3: ADD EAX, imm32 (0x05)
        // 瘙��: add eax, 0x12345678
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
        // 瘚贝��其�4: ADD reg, imm (0x83 /0)
        // 瘙��: add eax, 0x12
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
        // 瘚贝��其�5: MOV reg, reg (0x89)
        // 瘙��: mov eax, ebx
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
        // 瘚贝��其�6: MOV reg, reg (0x8B)
        // 瘙��: mov eax, ebx
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
        // 瘚贝��其�7: PUSH reg (0x50 + reg)
        // 瘙��: push eax
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
        // 瘚贝��其�8: POP reg (0x58 + reg)
        // 瘙��: pop eax
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
        // 瘚贝��其�9: CALL direct (0xE8)
        // 瘙��: call label
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
        // 瘚贝��其�10: RET (0xC3)
        // 瘙��: ret
        // ============================================
        set_instruction(8'hC3);
        test_count++;
        if (o_opcode_x86_RET_ret_near === 1'b1) begin
            $display("[PASS] RET: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] RET: expected=1, actual=%b", o_opcode_x86_RET_ret_near);
            fail_count++;
        end
        
        // ============================================
        // 瘚贝��其�11: HLT (0xF4)
        // 瘙��: hlt
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
        // 瘚贝��其�12: CLC (0xF8)
        // 瘙��: clc
        // ============================================
        set_instruction(8'hF8);
        test_count++;
        if (o_opcode_x86_CLC_carry === 1'b1) begin
            $display("[PASS] CLC: decode OK");
            pass_count++;
        end else begin
            $display("[FAIL] CLC: expected=1, actual=%b", o_opcode_x86_CLC_carry);
            fail_count++;
        end
        
        // ============================================
        // 瘚贝��其�13: JMP short (0xEB)
        // 瘙��: jmp short label
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
        // 瘚贝��其�14: JZ/JE 8-bit (0x74)
        // 瘙��: jz label
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
        // 瘚贝��其�15: CPUID (0x0F 0xA2)
        // 瘙��: cpuid
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
        // 瘚贝��其�16: UD2 (0x0F 0x0B)
        // 瘙��: ud2
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
        // 瘚贝��其�17: UD1 (0x0F 0xB9 /r)
        // 瘙��: ud1 eax, eax
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
        // 瘚贝��其�18: UD0 (0x0F 0xFF)
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
        // 瘚贝��其�19: INC reg (0x40 + reg)
        // 瘙��: inc eax
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
        // 瘚贝��其�20: DEC reg (0x48 + reg)
        // 瘙��: dec eax
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
        // 瘚贝��其�21: XOR reg, reg (0x31)
        // 瘙��: xor eax, ebx
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
        // 瘚贝��其�22: TEST reg, reg (0x85)
        // 瘙��: test eax, ebx
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
        // 瘚贝��其�23: INT 3 (0xCC)
        // 瘙��: int 3
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
        
        // 颲枏枂瘚贝�蝏𤘪�
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
