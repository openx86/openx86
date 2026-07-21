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
//  File        : stage_2_dec_x86_operand.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_2_dec_x86_operand module
// ============================================================================

`include "openx86_defs.h.sv"

module stage_2_dec_x86_operand (
    // =========================
    // instruction inputs
    // =========================
    input  logic [ 7: 0][ 7: 0] i_instruction_bytes,
    input  logic [ 2: 0]        i_default_op_size,
    input  logic                i_opsz_override,

    // =========================
    // opcode hit signals (passed through to field module)
    // =========================
    input  logic                i_opcode_x86_AAA_ASCII_adjust_after_add,
    input  logic                i_opcode_x86_AAD_ASCII_AX_before_div,
    input  logic                i_opcode_x86_AAM_ASCII_AX_after_mul,
    input  logic                i_opcode_x86_AAS_ASCII_adjust_after_sub,
    input  logic                i_opcode_x86_ADC_reg_to_reg_mem,
    input  logic                i_opcode_x86_ADC_reg_mem_to_reg,
    input  logic                i_opcode_x86_ADC_imm_to_reg_mem,
    input  logic                i_opcode_x86_ADC_imm_to_acc,
    input  logic                i_opcode_x86_ADD_reg_to_reg_mem,
    input  logic                i_opcode_x86_ADD_reg_mem_to_reg,
    input  logic                i_opcode_x86_ADD_imm_to_reg_mem,
    input  logic                i_opcode_x86_ADD_imm_to_acc,
    input  logic                i_opcode_x86_AND_reg_to_reg_mem,
    input  logic                i_opcode_x86_AND_reg_mem_to_reg,
    input  logic                i_opcode_x86_AND_imm_to_reg_mem,
    input  logic                i_opcode_x86_AND_imm_to_acc,
    input  logic                i_opcode_x86_ARPL_adjust_RPL_field_of_selector,
    input  logic                i_opcode_x86_BOUND_check_array_against_bounds,
    input  logic                i_opcode_x86_BSF_bit_scan_forward,
    input  logic                i_opcode_x86_BSR_bit_scan_reverse,
    input  logic                i_opcode_x86_BSWAP_byte_swap,
    input  logic                i_opcode_x86_BT_reg_mem_with_imm,
    input  logic                i_opcode_x86_BT_reg_mem_with_reg,
    input  logic                i_opcode_x86_BTC_reg_mem_with_imm,
    input  logic                i_opcode_x86_BTC_reg_mem_with_reg,
    input  logic                i_opcode_x86_BTR_reg_mem_with_imm,
    input  logic                i_opcode_x86_BTR_reg_mem_with_reg,
    input  logic                i_opcode_x86_BTS_reg_mem_with_imm,
    input  logic                i_opcode_x86_BTS_reg_mem_with_reg,
    input  logic                i_opcode_x86_CALL_in_same_segment_direct,
    input  logic                i_opcode_x86_CALL_in_same_segment_indirect,
    input  logic                i_opcode_x86_CALL_in_other_segment_direct,
    input  logic                i_opcode_x86_CALL_in_other_segment_indirect,
    input  logic                i_opcode_x86_CBW_convert_byte_to_word,
    input  logic                i_opcode_x86_CDQ_convert_double_word_to_quad_word,
    input  logic                i_opcode_x86_CLC_carry,
    input  logic                i_opcode_x86_CLD_dir,
    input  logic                i_opcode_x86_CLI_int_en,
    input  logic                i_opcode_x86_CLTS_clear_task_switched_flag,
    input  logic                i_opcode_x86_CMC_carry,
    input  logic                i_opcode_x86_CMP_mem_with_reg,
    input  logic                i_opcode_x86_CMP_reg_with_mem,
    input  logic                i_opcode_x86_CMP_imm_with_reg_mem,
    input  logic                i_opcode_x86_CMP_imm_with_acc,
    input  logic                i_opcode_x86_CMPS_compare_string_operands,
    input  logic                i_opcode_x86_CMPXCHG_compare_and_exchange,
    input  logic                i_opcode_x86_CPUID_CPU_identification,
    input  logic                i_opcode_x86_CWD_convert_word_to_double,
    input  logic                i_opcode_x86_CWDE_convert_word_to_double,
    input  logic                i_opcode_x86_DAA_decimal_adjust_AL_after_add,
    input  logic                i_opcode_x86_DAS_decimal_adjust_AL_after_sub,
    input  logic                i_opcode_x86_DEC_reg_mem,
    input  logic                i_opcode_x86_DEC_reg,
    input  logic                i_opcode_x86_DIV_acc_by_reg_mem,
    input  logic                i_opcode_x86_HLT_halt,
    input  logic                i_opcode_x86_IDIV_acc_by_reg_mem,
    input  logic                i_opcode_x86_IMUL_acc_with_reg_mem,
    input  logic                i_opcode_x86_IMUL_reg_with_reg_mem,
    input  logic                i_opcode_x86_IMUL_reg_mem_with_imm_to_reg,
    input  logic                i_opcode_x86_IN_port_fixed,
    input  logic                i_opcode_x86_IN_port_variable,
    input  logic                i_opcode_x86_INC_reg_mem,
    input  logic                i_opcode_x86_INC_reg,
    input  logic                i_opcode_x86_INS_input_from_DX_port,
    input  logic                i_opcode_x86_INT_interrupt_type_n,
    input  logic                i_opcode_x86_INT_interrupt_type_3,
    input  logic                i_opcode_x86_INT_interrupt_type_4,
    input  logic                i_opcode_x86_INVD_invalidate_cache,
    input  logic                i_opcode_x86_INVLPG_invalidate_TLB_entry,
    input  logic                i_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size,
    input  logic                i_opcode_x86_IRET_interrupt_return,
    input  logic                i_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp,
    input  logic                i_opcode_x86_Jcc_jump_if_cond_is_met_full_disp,
    input  logic                i_opcode_x86_JCXZ_jump_on_CX_zero,
    input  logic                i_opcode_x86_JMP_to_same_segment_short,
    input  logic                i_opcode_x86_JMP_to_same_segment_direct,
    input  logic                i_opcode_x86_JMP_to_same_segment_indirect,
    input  logic                i_opcode_x86_JMP_to_other_segment_direct,
    input  logic                i_opcode_x86_JMP_to_other_segment_indirect,
    input  logic                i_opcode_x86_LAHF_load_flags_to_ah,
    input  logic                i_opcode_x86_LAR_load_access_rights_byte,
    input  logic                i_opcode_x86_LDS_load_pointer_to_DS,
    input  logic                i_opcode_x86_LEA_load_effective_adddress_to_reg,
    input  logic                i_opcode_x86_LEAVE_high_level_procedure_exit,
    input  logic                i_opcode_x86_LES_load_pointer_to_ES,
    input  logic                i_opcode_x86_LFS_load_pointer_to_FS,
    input  logic                i_opcode_x86_LGDT_load_global_desciptor_table_reg,
    input  logic                i_opcode_x86_LGS_load_pointer_to_GS,
    input  logic                i_opcode_x86_LIDT_load_interrupt_desciptor_table_reg,
    input  logic                i_opcode_x86_LLDT_load_local_desciptor_table_reg,
    input  logic                i_opcode_x86_LMSW_load_status_word,
    input  logic                i_opcode_x86_LODS_load_string_operand,
    input  logic                i_opcode_x86_LOOP_count,
    input  logic                i_opcode_x86_LOOPZ_count_while_zero,
    input  logic                i_opcode_x86_LOOPNZ_count_while_not_zero,
    input  logic                i_opcode_x86_LSL_load_segment_limit,
    input  logic                i_opcode_x86_LSS_load_pointer_to_SS,
    input  logic                i_opcode_x86_LTR_load_task_register,
    input  logic                i_opcode_x86_MOV_reg_to_reg_mem,
    input  logic                i_opcode_x86_MOV_reg_mem_to_reg,
    input  logic                i_opcode_x86_MOV_imm_to_reg_mem,
    input  logic                i_opcode_x86_MOV_imm_to_reg,
    input  logic                i_opcode_x86_MOV_mem_to_acc,
    input  logic                i_opcode_x86_MOV_acc_to_mem,
    input  logic                i_opcode_x86_MOV_CR_from_reg,
    input  logic                i_opcode_x86_MOV_reg_from_CR,
    input  logic                i_opcode_x86_MOV_DR_from_reg,
    input  logic                i_opcode_x86_MOV_reg_from_DR,
    input  logic                i_opcode_x86_MOV_TR_from_reg,
    input  logic                i_opcode_x86_MOV_reg_from_TR,
    input  logic                i_opcode_x86_MOV_reg_mem_to_sreg,
    input  logic                i_opcode_x86_MOV_sreg_to_reg_mem,
    input  logic                i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg,
    input  logic                i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem,
    input  logic                i_opcode_x86_MOVS_move_data_from_string_to_string,
    input  logic                i_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg,
    input  logic                i_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg,
    input  logic                i_opcode_x86_MUL_acc_with_reg_mem,
    input  logic                i_opcode_x86_NEG_two_s_complement_negation,
    input  logic                i_opcode_x86_NOP_no_operation,
    input  logic                i_opcode_x86_NOP_no_operation_multi_byte,
    input  logic                i_opcode_x86_NOT_one_s_complement_negation,
    input  logic                i_opcode_x86_OR_reg_to_reg_mem,
    input  logic                i_opcode_x86_OR_reg_mem_to_reg,
    input  logic                i_opcode_x86_OR_imm_to_reg_mem,
    input  logic                i_opcode_x86_OR_imm_to_acc,
    input  logic                i_opcode_x86_OUT_port_fixed,
    input  logic                i_opcode_x86_OUT_port_variable,
    input  logic                i_opcode_x86_OUTS_output_string,
    input  logic                i_opcode_x86_POP_reg_mem,
    input  logic                i_opcode_x86_POP_reg,
    input  logic                i_opcode_x86_POP_sreg_2,
    input  logic                i_opcode_x86_POP_sreg_3,
    input  logic                i_opcode_x86_POPA_popa_gpr,
    input  logic                i_opcode_x86_POPF_popf_flags,
    input  logic                i_opcode_x86_PUSH_reg_mem,
    input  logic                i_opcode_x86_PUSH_reg,
    input  logic                i_opcode_x86_PUSH_sreg_2,
    input  logic                i_opcode_x86_PUSH_sreg_3,
    input  logic                i_opcode_x86_PUSH_imm,
    input  logic                i_opcode_x86_PUSH_pusha_gpr,
    input  logic                i_opcode_x86_PUSHF_pushf_flags,
    input  logic                i_opcode_x86_RCL_reg_mem_by_1,
    input  logic                i_opcode_x86_RCL_reg_mem_by_CL,
    input  logic                i_opcode_x86_RCL_reg_mem_by_imm,
    input  logic                i_opcode_x86_RCR_reg_mem_by_1,
    input  logic                i_opcode_x86_RCR_reg_mem_by_CL,
    input  logic                i_opcode_x86_RCR_reg_mem_by_imm,
    input  logic                i_opcode_x86_RDMSR_read_from_model_specific_reg,
    input  logic                i_opcode_x86_RDPMC_read_performance_monitoring_counters,
    input  logic                i_opcode_x86_RDTSC_read_time_stamp_counter,
    input  logic                i_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id,
    input  logic                i_opcode_x86_RET_ret_near,
    input  logic                i_opcode_x86_RET_ret_near_imm,
    input  logic                i_opcode_x86_RET_ret_far,
    input  logic                i_opcode_x86_RET_ret_far_imm,
    input  logic                i_opcode_x86_ROL_reg_mem_by_1,
    input  logic                i_opcode_x86_ROL_reg_mem_by_CL,
    input  logic                i_opcode_x86_ROL_reg_mem_by_imm,
    input  logic                i_opcode_x86_ROR_reg_mem_by_1,
    input  logic                i_opcode_x86_ROR_reg_mem_by_CL,
    input  logic                i_opcode_x86_ROR_reg_mem_by_imm,
    input  logic                i_opcode_x86_RSM_resume_from_system_management_mode,
    input  logic                i_opcode_x86_SAHF_store_ah_to_flags,
    input  logic                i_opcode_x86_SAR_reg_mem_by_1,
    input  logic                i_opcode_x86_SAR_reg_mem_by_CL,
    input  logic                i_opcode_x86_SAR_reg_mem_by_imm,
    input  logic                i_opcode_x86_SBB_reg_to_reg_mem,
    input  logic                i_opcode_x86_SBB_reg_mem_to_reg,
    input  logic                i_opcode_x86_SBB_imm_to_reg_mem,
    input  logic                i_opcode_x86_SBB_imm_to_acc,
    input  logic                i_opcode_x86_SCAS_scan_string,
    input  logic                i_opcode_x86_SETcc_byte_set_on_condition,
    input  logic                i_opcode_x86_SLDT_store_local_desciptor_table_register_register,
    input  logic                i_opcode_x86_SHL_reg_mem_by_1,
    input  logic                i_opcode_x86_SHL_reg_mem_by_CL,
    input  logic                i_opcode_x86_SHL_reg_mem_by_imm,
    input  logic                i_opcode_x86_SHLD_reg_mem_by_imm,
    input  logic                i_opcode_x86_SHLD_reg_mem_by_CL,
    input  logic                i_opcode_x86_SHR_reg_mem_by_1,
    input  logic                i_opcode_x86_SHR_reg_mem_by_CL,
    input  logic                i_opcode_x86_SHR_reg_mem_by_imm,
    input  logic                i_opcode_x86_SHRD_reg_mem_by_imm,
    input  logic                i_opcode_x86_SHRD_reg_mem_by_CL,
    input  logic                i_opcode_x86_SIDT_store_interrupt_desciptor_table_register,
    input  logic                i_opcode_x86_SLDT_store_local_desciptor_table_register,
    input  logic                i_opcode_x86_SMSW_store_machine_status_word,
    input  logic                i_opcode_x86_STC_set_carry_flag,
    input  logic                i_opcode_x86_STD_set_direction_flag,
    input  logic                i_opcode_x86_STI_set_interrupt_enable_flag,
    input  logic                i_opcode_x86_STOS_store_string_data,
    input  logic                i_opcode_x86_STR_store_task_register,
    input  logic                i_opcode_x86_SUB_reg_to_reg_mem,
    input  logic                i_opcode_x86_SUB_reg_mem_to_reg,
    input  logic                i_opcode_x86_SUB_imm_to_reg_mem,
    input  logic                i_opcode_x86_SUB_imm_to_acc,
    input  logic                i_opcode_x86_PUSH_reg_mem_and_reg,
    input  logic                i_opcode_x86_TEST_reg_mem_and_reg,
    input  logic                i_opcode_x86_TEST_imm_and_reg_mem,
    input  logic                i_opcode_x86_TEST_imm_and_acc,
    input  logic                i_opcode_x86_UD0_undefined_instruction,
    input  logic                i_opcode_x86_UD1_undefined_instruction,
    input  logic                i_opcode_x86_UD2_undefined_instruction,
    input  logic                i_opcode_x86_VERR_verify_a_segment_for_reading,
    input  logic                i_opcode_x86_VERW_verify_a_segment_for_writing,
    input  logic                i_opcode_x86_WAIT_wait,
    input  logic                i_opcode_x86_WBINVD_writeback_and_invalidate_data_cache,
    input  logic                i_opcode_x86_WRMSR_write_to_model_specific_register,
    input  logic                i_opcode_x86_XADD_exchange_and_add,
    input  logic                i_opcode_x86_XCHG_reg_mem_with_reg,
    input  logic                i_opcode_x86_XCHG_reg_with_acc_short,
    input  logic                i_opcode_x86_XLAT_table_look_up_translation,
    input  logic                i_opcode_x86_XOR_reg_to_reg_mem,
    input  logic                i_opcode_x86_XOR_reg_mem_to_reg,
    input  logic                i_opcode_x86_XOR_imm_to_reg_mem,
    input  logic                i_opcode_x86_XOR_imm_to_acc,

    // Decoded operand outputs
    output logic [ 3: 0]        o_tttn,
    output logic                o_gpr_reg_index_valid,
    output logic [ 2: 0]        o_gpr_reg_index,
    output logic                o_seg_reg_index_valid,
    output logic [ 2: 0]        o_seg_reg_index,
    output logic                o_w_valid,
    output logic                o_w,
    output logic                o_s_valid,
    output logic                o_s,
    output logic [ 2: 0]        o_eee,
    output logic                o_modrm_present,
    output logic [ 1: 0]        o_mod,
    output logic [ 2: 0]        o_rm,
    output logic                o_imm_size_full,
    output logic                o_imm_size_16b,
    output logic                o_imm_size_8b,
    output logic                o_imm_present,
    output logic                o_disp_size_full,
    output logic                o_disp_size_8b,
    output logic                o_disp_present,
    output logic                o_opcode_byte_1,
    output logic                o_opcode_byte_2,
    output logic                o_opcode_byte_3,
    
    // Addressing mode outputs
    output logic [ 2: 0]        o_seg_reg_index_addr,
    output logic                o_base_reg_valid,
    output logic [ 2: 0]        o_base_reg_index,
    output logic                o_index_reg_valid,
    output logic [ 2: 0]        o_index_reg_index,
    output logic                o_gpr_reg_valid,
    output logic [ 2: 0]        o_gpr_reg_index_addr,
    output logic [ 2: 0]        o_gpr_reg_bit_width,
    output logic                o_disp_present_addr,
    output logic                o_disp_size_8b_addr,
    output logic                o_disp_size_16b,
    output logic                o_disp_size_32b,
    output logic                o_sib_present,
    output logic [ 1: 0]        o_scale,
    output logic                o_index_reg_valid_sib,
    output logic [ 2: 0]        o_index_reg_index_sib,
    output logic                o_base_reg_valid_sib,
    output logic [ 2: 0]        o_base_reg_index_sib,
    output logic                o_disp_size_1b_sib,
    output logic                o_disp_size_4b_sib,
    output logic                o_ea_undefined,
    
    // Displacement and immediate values
    output logic [31: 0]        o_disp_value,
    output logic [31: 0]        o_imm_value,
    output logic [ 3: 0]        o_consume_byte_count,
    output logic                o_decode_error
);

// Internal signals from field module
logic [ 3: 0] field_tttn;
logic        field_gpr_reg_index_valid;
logic [ 2: 0] field_gpr_reg_index;
logic        field_seg_reg_index_valid;
logic [ 2: 0] field_seg_reg_index;
logic        field_w_valid;
logic        field_w;
logic        field_s_valid;
logic        field_s;
logic [ 2: 0] field_eee;
logic        field_modrm_present;
logic [ 1: 0] field_mod;
logic [ 2: 0] field_rm;
logic        field_imm_size_full;
logic        field_imm_size_16b;
logic        field_imm_size_8b;
logic        field_imm_present;
logic        field_disp_size_full;
logic        field_disp_size_8b;
logic        field_disp_present;
logic        field_opcode_byte_1;
logic        field_opcode_byte_2;
logic        field_opcode_byte_3;
logic        field_decode_error;

// Internal signals from modrm module
logic [ 2: 0] modrm_seg_reg_index;
logic        modrm_base_reg_valid;
logic [ 2: 0] modrm_base_reg_index;
logic        modrm_index_reg_valid;
logic [ 2: 0] modrm_index_reg_index;
logic        modrm_gpr_reg_valid;
logic [ 2: 0] modrm_gpr_reg_index;
logic [ 2: 0] modrm_gpr_reg_bit_width;
logic        modrm_disp_present;
logic        modrm_disp_size_8b;
logic        modrm_disp_size_16b;
logic        modrm_disp_size_32b;
logic        modrm_sib_present;

// Internal signals from sib module
logic [ 1: 0] sib_scale;
logic [ 2: 0] sib_seg_reg_index;
logic        sib_index_reg_valid;
logic [ 2: 0] sib_index_reg_index;
logic        sib_base_reg_valid;
logic [ 2: 0] sib_base_reg_index;
logic        sib_disp_size_1b;
logic        sib_disp_size_4b;
logic        sib_ea_undefined;

// Internal signals from disp_imm module
logic [31: 0] disp_imm_disp_value;
logic [31: 0] disp_imm_imm_value;
logic [ 3: 0] disp_imm_consume_byte_count;
logic        disp_imm_decode_error;

// Field module instantiation
stage_2_dec_x86_operand_field u_field (
    .i_instruction                          (i_instruction_bytes[3:0]),
    .i_opcode_x86_AAA_ASCII_adjust_after_add (i_opcode_x86_AAA_ASCII_adjust_after_add),
    .i_opcode_x86_AAD_ASCII_AX_before_div    (i_opcode_x86_AAD_ASCII_AX_before_div),
    .i_opcode_x86_AAM_ASCII_AX_after_mul     (i_opcode_x86_AAM_ASCII_AX_after_mul),
    .i_opcode_x86_AAS_ASCII_adjust_after_sub (i_opcode_x86_AAS_ASCII_adjust_after_sub),
    .i_opcode_x86_ADC_reg_to_reg_mem        (i_opcode_x86_ADC_reg_to_reg_mem),
    .i_opcode_x86_ADC_reg_mem_to_reg        (i_opcode_x86_ADC_reg_mem_to_reg),
    .i_opcode_x86_ADC_imm_to_reg_mem        (i_opcode_x86_ADC_imm_to_reg_mem),
    .i_opcode_x86_ADC_imm_to_acc            (i_opcode_x86_ADC_imm_to_acc),
    .i_opcode_x86_ADD_reg_to_reg_mem        (i_opcode_x86_ADD_reg_to_reg_mem),
    .i_opcode_x86_ADD_reg_mem_to_reg        (i_opcode_x86_ADD_reg_mem_to_reg),
    .i_opcode_x86_ADD_imm_to_reg_mem        (i_opcode_x86_ADD_imm_to_reg_mem),
    .i_opcode_x86_ADD_imm_to_acc            (i_opcode_x86_ADD_imm_to_acc),
    .i_opcode_x86_AND_reg_to_reg_mem        (i_opcode_x86_AND_reg_to_reg_mem),
    .i_opcode_x86_AND_reg_mem_to_reg        (i_opcode_x86_AND_reg_mem_to_reg),
    .i_opcode_x86_AND_imm_to_reg_mem        (i_opcode_x86_AND_imm_to_reg_mem),
    .i_opcode_x86_AND_imm_to_acc            (i_opcode_x86_AND_imm_to_acc),
    .i_opcode_x86_ARPL_adjust_RPL_field_of_selector (i_opcode_x86_ARPL_adjust_RPL_field_of_selector),
    .i_opcode_x86_BOUND_check_array_against_bounds (i_opcode_x86_BOUND_check_array_against_bounds),
    .i_opcode_x86_BSF_bit_scan_forward      (i_opcode_x86_BSF_bit_scan_forward),
    .i_opcode_x86_BSR_bit_scan_reverse      (i_opcode_x86_BSR_bit_scan_reverse),
    .i_opcode_x86_BSWAP_byte_swap           (i_opcode_x86_BSWAP_byte_swap),
    .i_opcode_x86_BT_reg_mem_with_imm       (i_opcode_x86_BT_reg_mem_with_imm),
    .i_opcode_x86_BT_reg_mem_with_reg       (i_opcode_x86_BT_reg_mem_with_reg),
    .i_opcode_x86_BTC_reg_mem_with_imm      (i_opcode_x86_BTC_reg_mem_with_imm),
    .i_opcode_x86_BTC_reg_mem_with_reg      (i_opcode_x86_BTC_reg_mem_with_reg),
    .i_opcode_x86_BTR_reg_mem_with_imm      (i_opcode_x86_BTR_reg_mem_with_imm),
    .i_opcode_x86_BTR_reg_mem_with_reg      (i_opcode_x86_BTR_reg_mem_with_reg),
    .i_opcode_x86_BTS_reg_mem_with_imm      (i_opcode_x86_BTS_reg_mem_with_imm),
    .i_opcode_x86_BTS_reg_mem_with_reg      (i_opcode_x86_BTS_reg_mem_with_reg),
    .i_opcode_x86_CALL_in_same_segment_direct (i_opcode_x86_CALL_in_same_segment_direct),
    .i_opcode_x86_CALL_in_same_segment_indirect (i_opcode_x86_CALL_in_same_segment_indirect),
    .i_opcode_x86_CALL_in_other_segment_direct (i_opcode_x86_CALL_in_other_segment_direct),
    .i_opcode_x86_CALL_in_other_segment_indirect (i_opcode_x86_CALL_in_other_segment_indirect),
    .i_opcode_x86_CBW_convert_byte_to_word (i_opcode_x86_CBW_convert_byte_to_word),
    .i_opcode_x86_CDQ_convert_double_word_to_quad_word (i_opcode_x86_CDQ_convert_double_word_to_quad_word),
    .i_opcode_x86_CLC_carry      (i_opcode_x86_CLC_carry),
    .i_opcode_x86_CLD_dir  (i_opcode_x86_CLD_dir),
    .i_opcode_x86_CLI_int_en (i_opcode_x86_CLI_int_en),
    .i_opcode_x86_CLTS_clear_task_switched_flag (i_opcode_x86_CLTS_clear_task_switched_flag),
    .i_opcode_x86_CMC_carry  (i_opcode_x86_CMC_carry),
    .i_opcode_x86_CMP_mem_with_reg         (i_opcode_x86_CMP_mem_with_reg),
    .i_opcode_x86_CMP_reg_with_mem         (i_opcode_x86_CMP_reg_with_mem),
    .i_opcode_x86_CMP_imm_with_reg_mem     (i_opcode_x86_CMP_imm_with_reg_mem),
    .i_opcode_x86_CMP_imm_with_acc         (i_opcode_x86_CMP_imm_with_acc),
    .i_opcode_x86_CMPS_compare_string_operands (i_opcode_x86_CMPS_compare_string_operands),
    .i_opcode_x86_CMPXCHG_compare_and_exchange (i_opcode_x86_CMPXCHG_compare_and_exchange),
    .i_opcode_x86_CPUID_CPU_identification (i_opcode_x86_CPUID_CPU_identification),
    .i_opcode_x86_CWD_convert_word_to_double (i_opcode_x86_CWD_convert_word_to_double),
    .i_opcode_x86_CWDE_convert_word_to_double (i_opcode_x86_CWDE_convert_word_to_double),
    .i_opcode_x86_DAA_decimal_adjust_AL_after_add (i_opcode_x86_DAA_decimal_adjust_AL_after_add),
    .i_opcode_x86_DAS_decimal_adjust_AL_after_sub (i_opcode_x86_DAS_decimal_adjust_AL_after_sub),
    .i_opcode_x86_DEC_reg_mem               (i_opcode_x86_DEC_reg_mem),
    .i_opcode_x86_DEC_reg                  (i_opcode_x86_DEC_reg),
    .i_opcode_x86_DIV_acc_by_reg_mem       (i_opcode_x86_DIV_acc_by_reg_mem),
    .i_opcode_x86_HLT_halt                 (i_opcode_x86_HLT_halt),
    .i_opcode_x86_IDIV_acc_by_reg_mem      (i_opcode_x86_IDIV_acc_by_reg_mem),
    .i_opcode_x86_IMUL_acc_with_reg_mem     (i_opcode_x86_IMUL_acc_with_reg_mem),
    .i_opcode_x86_IMUL_reg_with_reg_mem    (i_opcode_x86_IMUL_reg_with_reg_mem),
    .i_opcode_x86_IMUL_reg_mem_with_imm_to_reg (i_opcode_x86_IMUL_reg_mem_with_imm_to_reg),
    .i_opcode_x86_IN_port_fixed            (i_opcode_x86_IN_port_fixed),
    .i_opcode_x86_IN_port_variable         (i_opcode_x86_IN_port_variable),
    .i_opcode_x86_INC_reg_mem              (i_opcode_x86_INC_reg_mem),
    .i_opcode_x86_INC_reg                  (i_opcode_x86_INC_reg),
    .i_opcode_x86_INS_input_from_DX_port   (i_opcode_x86_INS_input_from_DX_port),
    .i_opcode_x86_INT_interrupt_type_n     (i_opcode_x86_INT_interrupt_type_n),
    .i_opcode_x86_INT_interrupt_type_3     (i_opcode_x86_INT_interrupt_type_3),
    .i_opcode_x86_INT_interrupt_type_4     (i_opcode_x86_INT_interrupt_type_4),
    .i_opcode_x86_INVD_invalidate_cache    (i_opcode_x86_INVD_invalidate_cache),
    .i_opcode_x86_INVLPG_invalidate_TLB_entry (i_opcode_x86_INVLPG_invalidate_TLB_entry),
    .i_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size (i_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size),
    .i_opcode_x86_IRET_interrupt_return    (i_opcode_x86_IRET_interrupt_return),
    .i_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp (i_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp),
    .i_opcode_x86_Jcc_jump_if_cond_is_met_full_disp (i_opcode_x86_Jcc_jump_if_cond_is_met_full_disp),
    .i_opcode_x86_JCXZ_jump_on_CX_zero     (i_opcode_x86_JCXZ_jump_on_CX_zero),
    .i_opcode_x86_JMP_to_same_segment_short (i_opcode_x86_JMP_to_same_segment_short),
    .i_opcode_x86_JMP_to_same_segment_direct (i_opcode_x86_JMP_to_same_segment_direct),
    .i_opcode_x86_JMP_to_same_segment_indirect (i_opcode_x86_JMP_to_same_segment_indirect),
    .i_opcode_x86_JMP_to_other_segment_direct (i_opcode_x86_JMP_to_other_segment_direct),
    .i_opcode_x86_JMP_to_other_segment_indirect (i_opcode_x86_JMP_to_other_segment_indirect),
    .i_opcode_x86_LAHF_load_flags_to_ah    (i_opcode_x86_LAHF_load_flags_to_ah),
    .i_opcode_x86_LAR_load_access_rights_byte (i_opcode_x86_LAR_load_access_rights_byte),
    .i_opcode_x86_LDS_load_pointer_to_DS   (i_opcode_x86_LDS_load_pointer_to_DS),
    .i_opcode_x86_LEA_load_effective_adddress_to_reg (i_opcode_x86_LEA_load_effective_adddress_to_reg),
    .i_opcode_x86_LEAVE_high_level_procedure_exit (i_opcode_x86_LEAVE_high_level_procedure_exit),
    .i_opcode_x86_LES_load_pointer_to_ES   (i_opcode_x86_LES_load_pointer_to_ES),
    .i_opcode_x86_LFS_load_pointer_to_FS   (i_opcode_x86_LFS_load_pointer_to_FS),
    .i_opcode_x86_LGDT_load_global_desciptor_table_reg (i_opcode_x86_LGDT_load_global_desciptor_table_reg),
    .i_opcode_x86_LGS_load_pointer_to_GS   (i_opcode_x86_LGS_load_pointer_to_GS),
    .i_opcode_x86_LIDT_load_interrupt_desciptor_table_reg (i_opcode_x86_LIDT_load_interrupt_desciptor_table_reg),
    .i_opcode_x86_LLDT_load_local_desciptor_table_reg (i_opcode_x86_LLDT_load_local_desciptor_table_reg),
    .i_opcode_x86_LMSW_load_status_word    (i_opcode_x86_LMSW_load_status_word),
    .i_opcode_x86_LODS_load_string_operand (i_opcode_x86_LODS_load_string_operand),
    .i_opcode_x86_LOOP_count              (i_opcode_x86_LOOP_count),
    .i_opcode_x86_LOOPZ_count_while_zero   (i_opcode_x86_LOOPZ_count_while_zero),
    .i_opcode_x86_LOOPNZ_count_while_not_zero (i_opcode_x86_LOOPNZ_count_while_not_zero),
    .i_opcode_x86_LSL_load_segment_limit   (i_opcode_x86_LSL_load_segment_limit),
    .i_opcode_x86_LSS_load_pointer_to_SS   (i_opcode_x86_LSS_load_pointer_to_SS),
    .i_opcode_x86_LTR_load_task_register   (i_opcode_x86_LTR_load_task_register),
    .i_opcode_x86_MOV_reg_to_reg_mem       (i_opcode_x86_MOV_reg_to_reg_mem),
    .i_opcode_x86_MOV_reg_mem_to_reg       (i_opcode_x86_MOV_reg_mem_to_reg),
    .i_opcode_x86_MOV_imm_to_reg_mem       (i_opcode_x86_MOV_imm_to_reg_mem),
    .i_opcode_x86_MOV_imm_to_reg           (i_opcode_x86_MOV_imm_to_reg),
    .i_opcode_x86_MOV_mem_to_acc          (i_opcode_x86_MOV_mem_to_acc),
    .i_opcode_x86_MOV_acc_to_mem          (i_opcode_x86_MOV_acc_to_mem),
    .i_opcode_x86_MOV_CR_from_reg         (i_opcode_x86_MOV_CR_from_reg),
    .i_opcode_x86_MOV_reg_from_CR         (i_opcode_x86_MOV_reg_from_CR),
    .i_opcode_x86_MOV_DR_from_reg         (i_opcode_x86_MOV_DR_from_reg),
    .i_opcode_x86_MOV_reg_from_DR         (i_opcode_x86_MOV_reg_from_DR),
    .i_opcode_x86_MOV_TR_from_reg         (i_opcode_x86_MOV_TR_from_reg),
    .i_opcode_x86_MOV_reg_from_TR         (i_opcode_x86_MOV_reg_from_TR),
    .i_opcode_x86_MOV_reg_mem_to_sreg     (i_opcode_x86_MOV_reg_mem_to_sreg),
    .i_opcode_x86_MOV_sreg_to_reg_mem     (i_opcode_x86_MOV_sreg_to_reg_mem),
    .i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg (i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg),
    .i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem (i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem),
    .i_opcode_x86_MOVS_move_data_from_string_to_string (i_opcode_x86_MOVS_move_data_from_string_to_string),
    .i_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg (i_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg),
    .i_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg (i_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg),
    .i_opcode_x86_MUL_acc_with_reg_mem     (i_opcode_x86_MUL_acc_with_reg_mem),
    .i_opcode_x86_NEG_two_s_complement_negation (i_opcode_x86_NEG_two_s_complement_negation),
    .i_opcode_x86_NOP_no_operation         (i_opcode_x86_NOP_no_operation),
    .i_opcode_x86_NOP_no_operation_multi_byte (i_opcode_x86_NOP_no_operation_multi_byte),
    .i_opcode_x86_NOT_one_s_complement_negation (i_opcode_x86_NOT_one_s_complement_negation),
    .i_opcode_x86_OR_reg_to_reg_mem        (i_opcode_x86_OR_reg_to_reg_mem),
    .i_opcode_x86_OR_reg_mem_to_reg        (i_opcode_x86_OR_reg_mem_to_reg),
    .i_opcode_x86_OR_imm_to_reg_mem        (i_opcode_x86_OR_imm_to_reg_mem),
    .i_opcode_x86_OR_imm_to_acc            (i_opcode_x86_OR_imm_to_acc),
    .i_opcode_x86_OUT_port_fixed          (i_opcode_x86_OUT_port_fixed),
    .i_opcode_x86_OUT_port_variable       (i_opcode_x86_OUT_port_variable),
    .i_opcode_x86_OUTS_output_string      (i_opcode_x86_OUTS_output_string),
    .i_opcode_x86_POP_reg_mem              (i_opcode_x86_POP_reg_mem),
    .i_opcode_x86_POP_reg                  (i_opcode_x86_POP_reg),
    .i_opcode_x86_POP_sreg_2              (i_opcode_x86_POP_sreg_2),
    .i_opcode_x86_POP_sreg_3              (i_opcode_x86_POP_sreg_3),
    .i_opcode_x86_POPA_popa_gpr (i_opcode_x86_POPA_popa_gpr),
    .i_opcode_x86_POPF_popf_flags (i_opcode_x86_POPF_popf_flags),
    .i_opcode_x86_PUSH_reg_mem             (i_opcode_x86_PUSH_reg_mem),
    .i_opcode_x86_PUSH_reg                 (i_opcode_x86_PUSH_reg),
    .i_opcode_x86_PUSH_sreg_2             (i_opcode_x86_PUSH_sreg_2),
    .i_opcode_x86_PUSH_sreg_3             (i_opcode_x86_PUSH_sreg_3),
    .i_opcode_x86_PUSH_imm                (i_opcode_x86_PUSH_imm),
    .i_opcode_x86_PUSH_pusha_gpr (i_opcode_x86_PUSH_pusha_gpr),
    .i_opcode_x86_PUSHF_pushf_flags (i_opcode_x86_PUSHF_pushf_flags),
    .i_opcode_x86_RCL_reg_mem_by_1        (i_opcode_x86_RCL_reg_mem_by_1),
    .i_opcode_x86_RCL_reg_mem_by_CL        (i_opcode_x86_RCL_reg_mem_by_CL),
    .i_opcode_x86_RCL_reg_mem_by_imm       (i_opcode_x86_RCL_reg_mem_by_imm),
    .i_opcode_x86_RCR_reg_mem_by_1        (i_opcode_x86_RCR_reg_mem_by_1),
    .i_opcode_x86_RCR_reg_mem_by_CL        (i_opcode_x86_RCR_reg_mem_by_CL),
    .i_opcode_x86_RCR_reg_mem_by_imm       (i_opcode_x86_RCR_reg_mem_by_imm),
    .i_opcode_x86_RDMSR_read_from_model_specific_reg (i_opcode_x86_RDMSR_read_from_model_specific_reg),
    .i_opcode_x86_RDPMC_read_performance_monitoring_counters (i_opcode_x86_RDPMC_read_performance_monitoring_counters),
    .i_opcode_x86_RDTSC_read_time_stamp_counter (i_opcode_x86_RDTSC_read_time_stamp_counter),
    .i_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id (i_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id),
    .i_opcode_x86_RET_ret_near (i_opcode_x86_RET_ret_near),
    .i_opcode_x86_RET_ret_near_imm (i_opcode_x86_RET_ret_near_imm),
    .i_opcode_x86_RET_ret_far (i_opcode_x86_RET_ret_far),
    .i_opcode_x86_RET_ret_far_imm (i_opcode_x86_RET_ret_far_imm),
    .i_opcode_x86_ROL_reg_mem_by_1        (i_opcode_x86_ROL_reg_mem_by_1),
    .i_opcode_x86_ROL_reg_mem_by_CL        (i_opcode_x86_ROL_reg_mem_by_CL),
    .i_opcode_x86_ROL_reg_mem_by_imm       (i_opcode_x86_ROL_reg_mem_by_imm),
    .i_opcode_x86_ROR_reg_mem_by_1        (i_opcode_x86_ROR_reg_mem_by_1),
    .i_opcode_x86_ROR_reg_mem_by_CL        (i_opcode_x86_ROR_reg_mem_by_CL),
    .i_opcode_x86_ROR_reg_mem_by_imm       (i_opcode_x86_ROR_reg_mem_by_imm),
    .i_opcode_x86_RSM_resume_from_system_management_mode (i_opcode_x86_RSM_resume_from_system_management_mode),
    .i_opcode_x86_SAHF_store_ah_to_flags (i_opcode_x86_SAHF_store_ah_to_flags),
    .i_opcode_x86_SAR_reg_mem_by_1        (i_opcode_x86_SAR_reg_mem_by_1),
    .i_opcode_x86_SAR_reg_mem_by_CL        (i_opcode_x86_SAR_reg_mem_by_CL),
    .i_opcode_x86_SAR_reg_mem_by_imm       (i_opcode_x86_SAR_reg_mem_by_imm),
    .i_opcode_x86_SBB_reg_to_reg_mem       (i_opcode_x86_SBB_reg_to_reg_mem),
    .i_opcode_x86_SBB_reg_mem_to_reg       (i_opcode_x86_SBB_reg_mem_to_reg),
    .i_opcode_x86_SBB_imm_to_reg_mem       (i_opcode_x86_SBB_imm_to_reg_mem),
    .i_opcode_x86_SBB_imm_to_acc           (i_opcode_x86_SBB_imm_to_acc),
    .i_opcode_x86_SCAS_scan_string         (i_opcode_x86_SCAS_scan_string),
    .i_opcode_x86_SETcc_byte_set_on_condition (i_opcode_x86_SETcc_byte_set_on_condition),
    .i_opcode_x86_SLDT_store_local_desciptor_table_register_register (i_opcode_x86_SLDT_store_local_desciptor_table_register_register),
    .i_opcode_x86_SHL_reg_mem_by_1        (i_opcode_x86_SHL_reg_mem_by_1),
    .i_opcode_x86_SHL_reg_mem_by_CL        (i_opcode_x86_SHL_reg_mem_by_CL),
    .i_opcode_x86_SHL_reg_mem_by_imm       (i_opcode_x86_SHL_reg_mem_by_imm),
    .i_opcode_x86_SHLD_reg_mem_by_imm     (i_opcode_x86_SHLD_reg_mem_by_imm),
    .i_opcode_x86_SHLD_reg_mem_by_CL      (i_opcode_x86_SHLD_reg_mem_by_CL),
    .i_opcode_x86_SHR_reg_mem_by_1        (i_opcode_x86_SHR_reg_mem_by_1),
    .i_opcode_x86_SHR_reg_mem_by_CL        (i_opcode_x86_SHR_reg_mem_by_CL),
    .i_opcode_x86_SHR_reg_mem_by_imm       (i_opcode_x86_SHR_reg_mem_by_imm),
    .i_opcode_x86_SHRD_reg_mem_by_imm     (i_opcode_x86_SHRD_reg_mem_by_imm),
    .i_opcode_x86_SHRD_reg_mem_by_CL      (i_opcode_x86_SHRD_reg_mem_by_CL),
    .i_opcode_x86_SIDT_store_interrupt_desciptor_table_register (i_opcode_x86_SIDT_store_interrupt_desciptor_table_register),
    .i_opcode_x86_SLDT_store_local_desciptor_table_register (i_opcode_x86_SLDT_store_local_desciptor_table_register),
    .i_opcode_x86_SMSW_store_machine_status_word (i_opcode_x86_SMSW_store_machine_status_word),
    .i_opcode_x86_STC_set_carry_flag      (i_opcode_x86_STC_set_carry_flag),
    .i_opcode_x86_STD_set_direction_flag  (i_opcode_x86_STD_set_direction_flag),
    .i_opcode_x86_STI_set_interrupt_enable_flag (i_opcode_x86_STI_set_interrupt_enable_flag),
    .i_opcode_x86_STOS_store_string_data  (i_opcode_x86_STOS_store_string_data),
    .i_opcode_x86_STR_store_task_register (i_opcode_x86_STR_store_task_register),
    .i_opcode_x86_SUB_reg_to_reg_mem       (i_opcode_x86_SUB_reg_to_reg_mem),
    .i_opcode_x86_SUB_reg_mem_to_reg       (i_opcode_x86_SUB_reg_mem_to_reg),
    .i_opcode_x86_SUB_imm_to_reg_mem       (i_opcode_x86_SUB_imm_to_reg_mem),
    .i_opcode_x86_SUB_imm_to_acc           (i_opcode_x86_SUB_imm_to_acc),
    .i_opcode_x86_PUSH_reg_mem_and_reg    (i_opcode_x86_PUSH_reg_mem_and_reg),
    .i_opcode_x86_TEST_reg_mem_and_reg    (i_opcode_x86_TEST_reg_mem_and_reg),
    .i_opcode_x86_TEST_imm_and_reg_mem    (i_opcode_x86_TEST_imm_and_reg_mem),
    .i_opcode_x86_TEST_imm_and_acc        (i_opcode_x86_TEST_imm_and_acc),
    .i_opcode_x86_UD0_undefined_instruction (i_opcode_x86_UD0_undefined_instruction),
    .i_opcode_x86_UD1_undefined_instruction (i_opcode_x86_UD1_undefined_instruction),
    .i_opcode_x86_UD2_undefined_instruction (i_opcode_x86_UD2_undefined_instruction),
    .i_opcode_x86_VERR_verify_a_segment_for_reading (i_opcode_x86_VERR_verify_a_segment_for_reading),
    .i_opcode_x86_VERW_verify_a_segment_for_writing (i_opcode_x86_VERW_verify_a_segment_for_writing),
    .i_opcode_x86_WAIT_wait               (i_opcode_x86_WAIT_wait),
    .i_opcode_x86_WBINVD_writeback_and_invalidate_data_cache (i_opcode_x86_WBINVD_writeback_and_invalidate_data_cache),
    .i_opcode_x86_WRMSR_write_to_model_specific_register (i_opcode_x86_WRMSR_write_to_model_specific_register),
    .i_opcode_x86_XADD_exchange_and_add    (i_opcode_x86_XADD_exchange_and_add),
    .i_opcode_x86_XCHG_reg_mem_with_reg    (i_opcode_x86_XCHG_reg_mem_with_reg),
    .i_opcode_x86_XCHG_reg_with_acc_short  (i_opcode_x86_XCHG_reg_with_acc_short),
    .i_opcode_x86_XLAT_table_look_up_translation (i_opcode_x86_XLAT_table_look_up_translation),
    .i_opcode_x86_XOR_reg_to_reg_mem       (i_opcode_x86_XOR_reg_to_reg_mem),
    .i_opcode_x86_XOR_reg_mem_to_reg       (i_opcode_x86_XOR_reg_mem_to_reg),
    .i_opcode_x86_XOR_imm_to_reg_mem       (i_opcode_x86_XOR_imm_to_reg_mem),
    .i_opcode_x86_XOR_imm_to_acc           (i_opcode_x86_XOR_imm_to_acc),
    .o_tttn                                (field_tttn),
    .o_gpr_reg_index_valid                 (field_gpr_reg_index_valid),
    .o_gpr_reg_index                       (field_gpr_reg_index),
    .o_seg_reg_index_valid                 (field_seg_reg_index_valid),
    .o_seg_reg_index                       (field_seg_reg_index),
    .o_w_valid                             (field_w_valid),
    .o_w                                   (field_w),
    .o_s_valid                             (field_s_valid),
    .o_s                                   (field_s),
    .o_eee                                 (field_eee),
    .o_modrm_present                       (field_modrm_present),
    .o_mod                                 (field_mod),
    .o_rm                                  (field_rm),
    .o_imm_size_full                       (field_imm_size_full),
    .o_imm_size_16b                        (field_imm_size_16b),
    .o_imm_size_8b                         (field_imm_size_8b),
    .o_imm_present                         (field_imm_present),
    .o_disp_size_full                      (field_disp_size_full),
    .o_disp_size_8b                        (field_disp_size_8b),
    .o_disp_present                        (field_disp_present),
    .o_opcode_byte_1                       (field_opcode_byte_1),
    .o_opcode_byte_2                       (field_opcode_byte_2),
    .o_opcode_byte_3                       (field_opcode_byte_3),
    .o_decode_error                        (field_decode_error)
);

// ModRM module instantiation
stage_2_dec_x86_operand_mod_rm u_modrm (
    .i_mod               (field_mod),
    .i_rm                (field_rm),
    .i_w_present         (field_w_valid),
    .i_w                 (field_w),
    .i_default_op_size   (i_default_op_size),
    .o_seg_reg_index     (modrm_seg_reg_index),
    .o_base_reg_valid    (modrm_base_reg_valid),
    .o_base_reg_index    (modrm_base_reg_index),
    .o_index_reg_valid   (modrm_index_reg_valid),
    .o_index_reg_index   (modrm_index_reg_index),
    .o_gpr_reg_valid     (modrm_gpr_reg_valid),
    .o_gpr_reg_index     (modrm_gpr_reg_index),
    .o_gpr_reg_bit_width (modrm_gpr_reg_bit_width),
    .o_disp_present      (modrm_disp_present),
    .o_disp_size_8b      (modrm_disp_size_8b),
    .o_disp_size_16b     (modrm_disp_size_16b),
    .o_disp_size_32b     (modrm_disp_size_32b),
    .o_sib_present       (modrm_sib_present)
);

// SIB is only meaningful when the opcode actually has a ModR/M byte.
// Otherwise rel8/imm8 (e.g. Jcc 75 04) can look like mod=00 rm=100 and
// falsely add a SIB byte to the instruction length (75 04 84 → LEAVE).
logic sib_present_eff;
assign sib_present_eff = field_modrm_present & modrm_sib_present;

// SIB module instantiation (only when SIB is present)
logic [ 7: 0] sib_byte;
assign sib_byte = i_instruction_bytes[field_opcode_byte_1 ? 2 :
                     field_opcode_byte_2 ? 3 : 4];

stage_2_dec_x86_operand_sib u_sib (
    .i_sib_byte         (sib_byte),
    .i_mod_from_modrm   (field_mod),
    .o_scale            (sib_scale),
    .o_seg_reg_index    (sib_seg_reg_index),
    .o_index_reg_valid  (sib_index_reg_valid),
    .o_index_reg_index  (sib_index_reg_index),
    .o_base_reg_valid   (sib_base_reg_valid),
    .o_base_reg_index   (sib_base_reg_index),
    .o_disp_size_1b     (sib_disp_size_1b),
    .o_disp_size_4b     (sib_disp_size_4b),
    .o_ea_undefined     (sib_ea_undefined)
);

// Displacement and immediate size mapping for disp_imm module
logic disp_size_1b;
logic disp_size_2b;
logic disp_size_4b;
logic imm_size_1b;
logic imm_size_2b;
logic imm_size_4b;
logic imm_size_full;

// Combine displacement sizes from field, modrm, and sib.
// Far JMP/CALL direct: ptr16:16 (opsz16) or ptr16:32 (opsz32 / 0x66 in real mode).
// Near Jcc/JMP/CALL full displacement follows operand size (rel16 vs rel32).
// Note: 0x66 must NOT change ModRM address size (that is 0x67) — only opsz here.
logic far_direct_ptr;
logic far_direct_ptr16;
logic far_direct_ptr32;
logic near_rel_full_16;
logic effective_opsz32;
assign effective_opsz32 = (i_default_op_size[0] == `default_operation_size_32) ^ i_opsz_override;
assign far_direct_ptr =
    i_opcode_x86_JMP_to_other_segment_direct |
    i_opcode_x86_CALL_in_other_segment_direct;
assign far_direct_ptr16 = far_direct_ptr & ~effective_opsz32;
assign far_direct_ptr32 = far_direct_ptr &  effective_opsz32;
assign near_rel_full_16 =
    (i_opcode_x86_Jcc_jump_if_cond_is_met_full_disp |
     i_opcode_x86_JMP_to_same_segment_direct |
     i_opcode_x86_CALL_in_same_segment_direct) &
    ~effective_opsz32;

always_comb begin
    // Gate ModRM/SIB displacement sizes — raw mod/rm bits are don't-care
    // when the opcode has no ModRM (e.g. far JMP EA / Jcc rel8).
    disp_size_1b = field_disp_size_8b |
                   (field_modrm_present & modrm_disp_size_8b) |
                   (sib_present_eff & sib_disp_size_1b);
    disp_size_2b = (field_modrm_present & modrm_disp_size_16b) |
                   (field_disp_size_full & far_direct_ptr16) |
                   (field_disp_size_full & near_rel_full_16);
    disp_size_4b = (field_disp_size_full & ~far_direct_ptr & ~near_rel_full_16) |
                   (field_disp_size_full & far_direct_ptr32) |
                   (field_modrm_present & modrm_disp_size_32b) |
                   (sib_present_eff & sib_disp_size_4b);
end

// 80/82/83 : imm8; 81 : full imm (iw/id). Field marks the whole group as full.
logic alu_grp1_imm_ib;
assign alu_grp1_imm_ib =
    (i_opcode_x86_ADC_imm_to_reg_mem |
     i_opcode_x86_ADD_imm_to_reg_mem |
     i_opcode_x86_AND_imm_to_reg_mem |
     i_opcode_x86_CMP_imm_with_reg_mem |
     i_opcode_x86_OR_imm_to_reg_mem |
     i_opcode_x86_SBB_imm_to_reg_mem |
     i_opcode_x86_SUB_imm_to_reg_mem |
     i_opcode_x86_XOR_imm_to_reg_mem) &
    (i_instruction_bytes[0][1: 0] != 2'b01);

// Acc imm (04/0C/.../A8) and F6 TEST: W=0 → imm8; W=1 → full (iw/id).
logic alu_wbit_imm_ib;
assign alu_wbit_imm_ib =
    (i_opcode_x86_ADC_imm_to_acc |
     i_opcode_x86_ADD_imm_to_acc |
     i_opcode_x86_AND_imm_to_acc |
     i_opcode_x86_CMP_imm_with_acc |
     i_opcode_x86_OR_imm_to_acc |
     i_opcode_x86_SBB_imm_to_acc |
     i_opcode_x86_SUB_imm_to_acc |
     i_opcode_x86_XOR_imm_to_acc |
     i_opcode_x86_TEST_imm_and_acc |
     i_opcode_x86_TEST_imm_and_reg_mem) &
    ~i_instruction_bytes[0][0];

assign imm_size_1b   = field_imm_size_8b | alu_grp1_imm_ib | alu_wbit_imm_ib;
assign imm_size_2b   = field_imm_size_16b;
assign imm_size_4b   = field_imm_size_full & ~alu_grp1_imm_ib & ~alu_wbit_imm_ib;
assign imm_size_full = field_imm_size_full & ~alu_grp1_imm_ib & ~alu_wbit_imm_ib;

// Disp/imm window starts after opcode (+ ModRM + SIB when present)
logic [ 3: 0] disp_imm_byte_offset;
logic [ 7: 0][ 7: 0] disp_imm_instruction_bytes;
assign disp_imm_byte_offset =
    (field_opcode_byte_1 ? 4'd1 : field_opcode_byte_2 ? 4'd2 : field_opcode_byte_3 ? 4'd3 : 4'd1) +
    (field_modrm_present ? 4'd1 : 4'd0) +
    (sib_present_eff ? 4'd1 : 4'd0);

always_comb begin
    for (int unsigned i = 0; i < 8; i++) begin
        disp_imm_instruction_bytes[i] = i_instruction_bytes[disp_imm_byte_offset + 4'(i)];
    end
end

stage_2_dec_x86_operand_disp_imm u_disp_imm (
    .i_instruction_bytes (disp_imm_instruction_bytes),
    .i_disp_size_1b     (disp_size_1b),
    .i_disp_size_2b     (disp_size_2b),
    .i_disp_size_4b     (disp_size_4b),
    .i_imm_size_1b      (imm_size_1b),
    .i_imm_size_2b      (imm_size_2b),
    .i_imm_size_4b      (imm_size_4b),
    .i_imm_size_full    (imm_size_full),
    .o_disp_value           (disp_imm_disp_value),
    .o_imm_value            (disp_imm_imm_value),
    .o_consume_byte_count   (disp_imm_consume_byte_count),
    .o_decode_error         (disp_imm_decode_error)
);

// Output assignments
// Field outputs
assign o_tttn                = field_tttn;
assign o_gpr_reg_index_valid = field_gpr_reg_index_valid;
assign o_gpr_reg_index       = field_gpr_reg_index;
assign o_seg_reg_index_valid = field_seg_reg_index_valid;
assign o_seg_reg_index       = field_seg_reg_index;
assign o_w_valid             = field_w_valid;
assign o_w                   = field_w;
assign o_s_valid             = field_s_valid;
assign o_s                   = field_s;
assign o_eee                 = field_eee;
assign o_modrm_present       = field_modrm_present;
assign o_mod                 = field_mod;
assign o_rm                  = field_rm;
assign o_imm_size_full       = field_imm_size_full;
assign o_imm_size_16b        = field_imm_size_16b;
assign o_imm_size_8b         = field_imm_size_8b;
assign o_imm_present         = field_imm_present;
assign o_disp_size_full      = field_disp_size_full;
assign o_disp_size_8b        = field_disp_size_8b;
assign o_disp_present        = field_disp_present;
assign o_opcode_byte_1       = field_opcode_byte_1;
assign o_opcode_byte_2       = field_opcode_byte_2;
assign o_opcode_byte_3       = field_opcode_byte_3;

// Addressing mode outputs (select between modrm and sib based on sib_present)
assign o_seg_reg_index_addr   = sib_present_eff ? sib_seg_reg_index : modrm_seg_reg_index;
assign o_base_reg_valid       = sib_present_eff ? sib_base_reg_valid : modrm_base_reg_valid;
assign o_base_reg_index       = sib_present_eff ? sib_base_reg_index : modrm_base_reg_index;
assign o_index_reg_valid      = sib_present_eff ? sib_index_reg_valid : modrm_index_reg_valid;
assign o_index_reg_index      = sib_present_eff ? sib_index_reg_index : modrm_index_reg_index;
assign o_gpr_reg_valid        = modrm_gpr_reg_valid;
assign o_gpr_reg_index_addr   = modrm_gpr_reg_index;
assign o_gpr_reg_bit_width   = modrm_gpr_reg_bit_width;
assign o_disp_present_addr    = modrm_disp_present;
assign o_disp_size_8b_addr    = modrm_disp_size_8b;
assign o_disp_size_16b       = modrm_disp_size_16b;
assign o_disp_size_32b       = modrm_disp_size_32b;
assign o_sib_present          = sib_present_eff;
assign o_scale               = sib_scale;
assign o_index_reg_valid_sib  = sib_index_reg_valid;
assign o_index_reg_index_sib  = sib_index_reg_index;
assign o_base_reg_valid_sib   = sib_base_reg_valid;
assign o_base_reg_index_sib   = sib_base_reg_index;
assign o_disp_size_1b_sib     = sib_disp_size_1b;
assign o_disp_size_4b_sib     = sib_disp_size_4b;
assign o_ea_undefined        = sib_ea_undefined;

// Displacement and immediate values
assign o_disp_value           = disp_imm_disp_value;
assign o_imm_value            = disp_imm_imm_value;
// Count ModRM/SIB as well as displacement/immediate bytes
assign o_consume_byte_count   = disp_imm_consume_byte_count +
                                (field_modrm_present ? 4'd1 : 4'd0) +
                                (sib_present_eff ? 4'd1 : 4'd0);

// Aggregate error signals
assign o_decode_error         = field_decode_error | disp_imm_decode_error;

endmodule
