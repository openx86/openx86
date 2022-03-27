/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_field
create at: 2022-02-25 02:54:27
description: decode fileds include w, s, reg, mod_r/m, imm, disp
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"

module decode_field (
    input  logic [ 7:0] i_instruction [0:3],
    input  logic        i_opcode_x86_AAA_ASCII_adjust_after_add,
    input  logic        i_opcode_x86_AAD_ASCII_AX_before_div,
    input  logic        i_opcode_x86_AAM_ASCII_AX_after_mul,
    input  logic        i_opcode_x86_AAS_ASCII_adjust_after_sub,
    input  logic        i_opcode_x86_ADC_reg_to_reg_mem,
    input  logic        i_opcode_x86_ADC_reg_mem_to_reg,
    input  logic        i_opcode_x86_ADC_imm_to_reg_mem,
    input  logic        i_opcode_x86_ADC_imm_to_acc,
    input  logic        i_opcode_x86_ADD_reg_to_reg_mem,
    input  logic        i_opcode_x86_ADD_reg_mem_to_reg,
    input  logic        i_opcode_x86_ADD_imm_to_reg_mem,
    input  logic        i_opcode_x86_ADD_imm_to_acc,
    input  logic        i_opcode_x86_AND_reg_to_reg_mem,
    input  logic        i_opcode_x86_AND_reg_mem_to_reg,
    input  logic        i_opcode_x86_AND_imm_to_reg_mem,
    input  logic        i_opcode_x86_AND_imm_to_acc,
    input  logic        i_opcode_x86_ARPL_adjust_RPL_field_of_selector,
    input  logic        i_opcode_x86_BOUND_check_array_against_bounds,
    input  logic        i_opcode_x86_BSF_bit_scan_forward,
    input  logic        i_opcode_x86_BSR_bit_scan_reverse,
    input  logic        i_opcode_x86_BSWAP_byte_swap,
    input  logic        i_opcode_x86_BT_reg_mem_with_imm,
    input  logic        i_opcode_x86_BT_reg_mem_with_reg,
    input  logic        i_opcode_x86_BTC_reg_mem_with_imm,
    input  logic        i_opcode_x86_BTC_reg_mem_with_reg,
    input  logic        i_opcode_x86_BTR_reg_mem_with_imm,
    input  logic        i_opcode_x86_BTR_reg_mem_with_reg,
    input  logic        i_opcode_x86_BTS_reg_mem_with_imm,
    input  logic        i_opcode_x86_BTS_reg_mem_with_reg,
    input  logic        i_opcode_x86_CALL_in_same_segment_direct,
    input  logic        i_opcode_x86_CALL_in_same_segment_indirect,
    input  logic        i_opcode_x86_CALL_in_other_segment_direct,
    input  logic        i_opcode_x86_CALL_in_other_segment_indirect,
    input  logic        i_opcode_x86_CBW_convert_byte_to_word,
    input  logic        i_opcode_x86_CDQ_convert_double_word_to_quad_word,
    input  logic        i_opcode_x86_CLC_clear_carry_flag,
    input  logic        i_opcode_x86_CLD_clear_direction_flag,
    input  logic        i_opcode_x86_CLI_clear_interrupt_enable_flag,
    input  logic        i_opcode_x86_CLTS_clear_task_switched_flag,
    input  logic        i_opcode_x86_CMC_complement_carry_flag,
    input  logic        i_opcode_x86_CMP_mem_with_reg,
    input  logic        i_opcode_x86_CMP_reg_with_mem,
    input  logic        i_opcode_x86_CMP_imm_with_reg_mem,
    input  logic        i_opcode_x86_CMP_imm_with_acc,
    input  logic        i_opcode_x86_CMPS_compare_string_operands,
    input  logic        i_opcode_x86_CMPXCHG_compare_and_exchange,
    input  logic        i_opcode_x86_CPUID_CPU_identification,
    input  logic        i_opcode_x86_CWD_convert_word_to_double,
    input  logic        i_opcode_x86_CWDE_convert_word_to_double,
    input  logic        i_opcode_x86_DAA_decimal_adjust_AL_after_add,
    input  logic        i_opcode_x86_DAS_decimal_adjust_AL_after_sub,
    input  logic        i_opcode_x86_DEC_reg_mem,
    input  logic        i_opcode_x86_DEC_reg,
    input  logic        i_opcode_x86_DIV_acc_by_reg_mem,
    input  logic        i_opcode_x86_HLT_halt,
    input  logic        i_opcode_x86_IDIV_acc_by_reg_mem,
    input  logic        i_opcode_x86_IMUL_acc_with_reg_mem,
    input  logic        i_opcode_x86_IMUL_reg_with_reg_mem,
    input  logic        i_opcode_x86_IMUL_reg_mem_with_imm_to_reg,
    input  logic        i_opcode_x86_IN_port_fixed,
    input  logic        i_opcode_x86_IN_port_variable,
    input  logic        i_opcode_x86_INC_reg_mem,
    input  logic        i_opcode_x86_INC_reg,
    input  logic        i_opcode_x86_INS_input_from_DX_port,
    input  logic        i_opcode_x86_INT_interrupt_type_n,
    input  logic        i_opcode_x86_INT_interrupt_type_3,
    input  logic        i_opcode_x86_INT_interrupt_type_4,
    input  logic        i_opcode_x86_INVD_invalidate_cache,
    input  logic        i_opcode_x86_INVLPG_invalidate_TLB_entry,
    input  logic        i_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size,
    input  logic        i_opcode_x86_IRET_interrupt_return,
    input  logic        i_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp,
    input  logic        i_opcode_x86_Jcc_jump_if_cond_is_met_full_disp,
    input  logic        i_opcode_x86_JCXZ_jump_on_CX_zero,
    input  logic        i_opcode_x86_JMP_to_same_segment_short,
    input  logic        i_opcode_x86_JMP_to_same_segment_direct,
    input  logic        i_opcode_x86_JMP_to_same_segment_indirect,
    input  logic        i_opcode_x86_JMP_to_other_segment_direct,
    input  logic        i_opcode_x86_JMP_to_other_segment_indirect,
    input  logic        i_opcode_x86_LAHF_load_FLAG_into_AH,
    input  logic        i_opcode_x86_LAR_load_access_rights_byte,
    input  logic        i_opcode_x86_LDS_load_pointer_to_DS,
    input  logic        i_opcode_x86_LEA_load_effective_adddress_to_reg,
    input  logic        i_opcode_x86_LEAVE_high_level_procedure_exit,
    input  logic        i_opcode_x86_LES_load_pointer_to_ES,
    input  logic        i_opcode_x86_LFS_load_pointer_to_FS,
    input  logic        i_opcode_x86_LGDT_load_global_desciptor_table_reg,
    input  logic        i_opcode_x86_LGS_load_pointer_to_GS,
    input  logic        i_opcode_x86_LIDT_load_interrupt_desciptor_table_reg,
    input  logic        i_opcode_x86_LLDT_load_local_desciptor_table_reg,
    input  logic        i_opcode_x86_LMSW_load_status_word,
    input  logic        i_opcode_x86_LODS_load_string_operand,
    input  logic        i_opcode_x86_LOOP_count,
    input  logic        i_opcode_x86_LOOPZ_count_while_zero,
    input  logic        i_opcode_x86_LOOPNZ_count_while_not_zero,
    input  logic        i_opcode_x86_LSL_load_segment_limit,
    input  logic        i_opcode_x86_LSS_load_pointer_to_SS,
    input  logic        i_opcode_x86_LTR_load_task_register,
    input  logic        i_opcode_x86_MOV_reg_to_reg_mem,
    input  logic        i_opcode_x86_MOV_reg_mem_to_reg,
    input  logic        i_opcode_x86_MOV_imm_to_reg_mem,
    input  logic        i_opcode_x86_MOV_imm_to_reg,
    input  logic        i_opcode_x86_MOV_mem_to_acc,
    input  logic        i_opcode_x86_MOV_acc_to_mem,
    input  logic        i_opcode_x86_MOV_CR_from_reg,
    input  logic        i_opcode_x86_MOV_reg_from_CR,
    input  logic        i_opcode_x86_MOV_DR_from_reg,
    input  logic        i_opcode_x86_MOV_reg_from_DR,
    input  logic        i_opcode_x86_MOV_TR_from_reg,
    input  logic        i_opcode_x86_MOV_reg_from_TR,
    input  logic        i_opcode_x86_MOV_reg_mem_to_sreg,
    input  logic        i_opcode_x86_MOV_sreg_to_reg_mem,
    input  logic        i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg,
    input  logic        i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem,
    input  logic        i_opcode_x86_MOVS_move_data_from_string_to_string,
    input  logic        i_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg,
    input  logic        i_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg,
    input  logic        i_opcode_x86_MUL_acc_with_reg_mem,
    input  logic        i_opcode_x86_NEG_two_s_complement_negation,
    input  logic        i_opcode_x86_NOP_no_operation,
    input  logic        i_opcode_x86_NOP_no_operation_multi_byte,
    input  logic        i_opcode_x86_NOT_one_s_complement_negation,
    input  logic        i_opcode_x86_OR_reg_to_reg_mem,
    input  logic        i_opcode_x86_OR_reg_mem_to_reg,
    input  logic        i_opcode_x86_OR_imm_to_reg_mem,
    input  logic        i_opcode_x86_OR_imm_to_acc,
    input  logic        i_opcode_x86_OUT_port_fixed,
    input  logic        i_opcode_x86_OUT_port_variable,
    input  logic        i_opcode_x86_OUTS_output_string,
    input  logic        i_opcode_x86_POP_reg_mem,
    input  logic        i_opcode_x86_POP_reg,
    input  logic        i_opcode_x86_POP_sreg_2,
    input  logic        i_opcode_x86_POP_sreg_3,
    input  logic        i_opcode_x86_POPA_pop_all_general_registers,
    input  logic        i_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS,
    input  logic        i_opcode_x86_PUSH_reg_mem,
    input  logic        i_opcode_x86_PUSH_reg,
    input  logic        i_opcode_x86_PUSH_sreg_2,
    input  logic        i_opcode_x86_PUSH_sreg_3,
    input  logic        i_opcode_x86_PUSH_imm,
    input  logic        i_opcode_x86_PUSH_all_general_registers,
    input  logic        i_opcode_x86_PUSHF_push_flags_onto_stack,
    input  logic        i_opcode_x86_RCL_reg_mem_by_1,
    input  logic        i_opcode_x86_RCL_reg_mem_by_CL,
    input  logic        i_opcode_x86_RCL_reg_mem_by_imm,
    input  logic        i_opcode_x86_RCR_reg_mem_by_1,
    input  logic        i_opcode_x86_RCR_reg_mem_by_CL,
    input  logic        i_opcode_x86_RCR_reg_mem_by_imm,
    input  logic        i_opcode_x86_RDMSR_read_from_model_specific_reg,
    input  logic        i_opcode_x86_RDPMC_read_performance_monitoring_counters,
    input  logic        i_opcode_x86_RDTSC_read_time_stamp_counter,
    input  logic        i_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id,
    input  logic        i_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument,
    input  logic        i_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP,
    input  logic        i_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument,
    input  logic        i_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP,
    input  logic        i_opcode_x86_ROL_reg_mem_by_1,
    input  logic        i_opcode_x86_ROL_reg_mem_by_CL,
    input  logic        i_opcode_x86_ROL_reg_mem_by_imm,
    input  logic        i_opcode_x86_ROR_reg_mem_by_1,
    input  logic        i_opcode_x86_ROR_reg_mem_by_CL,
    input  logic        i_opcode_x86_ROR_reg_mem_by_imm,
    input  logic        i_opcode_x86_RSM_resume_from_system_management_mode,
    input  logic        i_opcode_x86_SAHF_store_AH_into_flags,
    input  logic        i_opcode_x86_SAR_reg_mem_by_1,
    input  logic        i_opcode_x86_SAR_reg_mem_by_CL,
    input  logic        i_opcode_x86_SAR_reg_mem_by_imm,
    input  logic        i_opcode_x86_SBB_reg_to_reg_mem,
    input  logic        i_opcode_x86_SBB_reg_mem_to_reg,
    input  logic        i_opcode_x86_SBB_imm_to_reg_mem,
    input  logic        i_opcode_x86_SBB_imm_to_acc,
    input  logic        i_opcode_x86_SCAS_scan_string,
    input  logic        i_opcode_x86_SETcc_byte_set_on_condition,
    input  logic        i_opcode_x86_SGDT_store_global_descriptor_table_register,
    input  logic        i_opcode_x86_SHL_reg_mem_by_1,
    input  logic        i_opcode_x86_SHL_reg_mem_by_CL,
    input  logic        i_opcode_x86_SHL_reg_mem_by_imm,
    input  logic        i_opcode_x86_SHLD_reg_mem_by_imm,
    input  logic        i_opcode_x86_SHLD_reg_mem_by_CL,
    input  logic        i_opcode_x86_SHR_reg_mem_by_1,
    input  logic        i_opcode_x86_SHR_reg_mem_by_CL,
    input  logic        i_opcode_x86_SHR_reg_mem_by_imm,
    input  logic        i_opcode_x86_SHRD_reg_mem_by_imm,
    input  logic        i_opcode_x86_SHRD_reg_mem_by_CL,
    input  logic        i_opcode_x86_SIDT_store_interrupt_desciptor_table_register,
    input  logic        i_opcode_x86_SLDT_store_local_desciptor_table_register,
    input  logic        i_opcode_x86_SMSW_store_machine_status_word,
    input  logic        i_opcode_x86_STC_set_carry_flag,
    input  logic        i_opcode_x86_STD_set_direction_flag,
    input  logic        i_opcode_x86_STI_set_interrupt_enable_flag,
    input  logic        i_opcode_x86_STOS_store_string_data,
    input  logic        i_opcode_x86_STR_store_task_register,
    input  logic        i_opcode_x86_SUB_reg_to_reg_mem,
    input  logic        i_opcode_x86_SUB_reg_mem_to_reg,
    input  logic        i_opcode_x86_SUB_imm_to_reg_mem,
    input  logic        i_opcode_x86_SUB_imm_to_acc,
    input  logic        i_opcode_x86_TEST_reg_mem_and_reg,
    input  logic        i_opcode_x86_TEST_imm_and_reg_mem,
    input  logic        i_opcode_x86_TEST_imm_and_acc,
    input  logic        i_opcode_x86_UD0_undefined_instruction,
    input  logic        i_opcode_x86_UD1_undefined_instruction,
    input  logic        i_opcode_x86_UD2_undefined_instruction,
    input  logic        i_opcode_x86_VERR_verify_a_segment_for_reading,
    input  logic        i_opcode_x86_VERW_verify_a_segment_for_writing,
    input  logic        i_opcode_x86_WAIT_wait,
    input  logic        i_opcode_x86_WBINVD_writeback_and_invalidate_data_cache,
    input  logic        i_opcode_x86_WRMSR_write_to_model_specific_register,
    input  logic        i_opcode_x86_XADD_exchange_and_add,
    input  logic        i_opcode_x86_XCHG_reg_mem_with_reg,
    input  logic        i_opcode_x86_XCHG_reg_with_acc_short,
    input  logic        i_opcode_x86_XLAT_table_look_up_translation,
    input  logic        i_opcode_x86_XOR_reg_to_reg_mem,
    input  logic        i_opcode_x86_XOR_reg_mem_to_reg,
    input  logic        i_opcode_x86_XOR_imm_to_reg_mem,
    input  logic        i_opcode_x86_XOR_imm_to_acc,
    output logic [ 3:0] o_tttn,
    output logic        o_gen_reg_index_is_present,
    output logic [ 2:0] o_gen_reg_index,
    output logic        o_seg_reg_index_is_present,
    output logic [ 2:0] o_seg_reg_index,
    output logic        o_w_is_present,
    output logic        o_w,
    output logic        o_s_is_present,
    output logic        o_s,
    output logic [ 2:0] o_eee,
    output logic        o_mod_rm_is_present,
    output logic [ 1:0] o_mod,
    output logic [ 2:0] o_rm,
    output logic        o_immediate_size_full,
    output logic        o_immediate_size_16,
    output logic        o_immediate_size_8,
    output logic        o_immediate_is_present,
    output logic        o_displacement_size_full,
    output logic        o_displacement_size_8,
    output logic        o_displacement_is_present,
    output logic        o_primary_opcode_byte_1,
    output logic        o_primary_opcode_byte_2,
    output logic        o_primary_opcode_byte_3,
    output logic        o_error
);

wire tttn_at_1_3_0 =
i_opcode_x86_SETcc_byte_set_on_condition |
0;
assign o_tttn = tttn_at_1_3_0 ? i_instruction[1][3:0] : 4'b0000;

wire sreg3_at_1_5_3 =
i_opcode_x86_MOV_reg_mem_to_sreg |
i_opcode_x86_MOV_sreg_to_reg_mem |
i_opcode_x86_POP_sreg_3 |
i_opcode_x86_PUSH_sreg_3 |
0;
wire sreg2_at_0_4_3 =
i_opcode_x86_POP_sreg_2 |
i_opcode_x86_PUSH_sreg_2 |
0;
assign o_seg_reg_index_is_present =
sreg3_at_1_5_3 |
sreg2_at_0_4_3 |
0;
always_comb begin
    case (1'b1)
        sreg3_at_1_5_3: o_seg_reg_index <= i_instruction[1][5:3];
        sreg2_at_0_4_3: o_seg_reg_index <= {1'b0, i_instruction[0][4:3]};
        default       : o_seg_reg_index <= 3'b0;
    endcase
end

wire eee_at_2_5_3 =
i_opcode_x86_MOV_CR_from_reg |
i_opcode_x86_MOV_reg_from_CR |
i_opcode_x86_MOV_DR_from_reg |
i_opcode_x86_MOV_reg_from_DR |
i_opcode_x86_MOV_TR_from_reg |
i_opcode_x86_MOV_reg_from_TR |
0;
assign o_eee = i_instruction[2][5:3];

wire reg_1_at_0_2_0 =
i_opcode_x86_DEC_reg |
i_opcode_x86_INC_reg |
i_opcode_x86_MOV_imm_to_reg |
i_opcode_x86_POP_reg |
i_opcode_x86_PUSH_reg |
i_opcode_x86_XCHG_reg_with_acc_short |
0;
wire reg_1_at_1_5_3 =
i_opcode_x86_ADC_reg_to_reg_mem |
i_opcode_x86_ADC_reg_mem_to_reg |
i_opcode_x86_ADD_reg_to_reg_mem |
i_opcode_x86_ADD_reg_mem_to_reg |
i_opcode_x86_AND_reg_to_reg_mem |
i_opcode_x86_AND_reg_mem_to_reg |
0;
wire reg_1_at_1_2_0 =
i_opcode_x86_BSWAP_byte_swap |
0;
wire reg_1_at_2_2_0 =
i_opcode_x86_MOV_CR_from_reg |
i_opcode_x86_MOV_reg_from_CR |
i_opcode_x86_MOV_DR_from_reg |
i_opcode_x86_MOV_reg_from_DR |
i_opcode_x86_MOV_TR_from_reg |
i_opcode_x86_MOV_reg_from_TR |
0;
assign o_gen_reg_index_is_present =
reg_1_at_0_2_0 |
reg_1_at_1_5_3 |
reg_1_at_1_2_0 |
reg_1_at_2_2_0 |
0;
always_comb begin
    unique case (1'b1)
        reg_1_at_0_2_0 : o_gen_reg_index <= i_instruction[0][2:0];
        reg_1_at_1_5_3 : o_gen_reg_index <= i_instruction[1][5:3];
        reg_1_at_1_2_0 : o_gen_reg_index <= i_instruction[1][2:0];
        reg_1_at_2_2_0 : o_gen_reg_index <= i_instruction[2][2:0];
        default        : o_gen_reg_index <= 3'b000;
    endcase
end

wire w_at_0_0 =
i_opcode_x86_ADC_reg_to_reg_mem |
i_opcode_x86_ADC_reg_mem_to_reg |
i_opcode_x86_ADC_imm_to_reg_mem |
i_opcode_x86_ADC_imm_to_acc |
i_opcode_x86_ADD_reg_to_reg_mem |
i_opcode_x86_ADD_reg_mem_to_reg |
i_opcode_x86_ADD_imm_to_reg_mem |
i_opcode_x86_ADD_imm_to_acc |
i_opcode_x86_AND_reg_to_reg_mem |
i_opcode_x86_AND_reg_mem_to_reg |
i_opcode_x86_AND_imm_to_reg_mem |
i_opcode_x86_AND_imm_to_acc |
i_opcode_x86_CMP_mem_with_reg |
i_opcode_x86_CMP_reg_with_mem |
i_opcode_x86_CMP_imm_with_reg_mem |
i_opcode_x86_CMP_imm_with_acc |
i_opcode_x86_DEC_reg_mem |
i_opcode_x86_DIV_acc_by_reg_mem |
i_opcode_x86_IDIV_acc_by_reg_mem |
i_opcode_x86_IMUL_acc_with_reg_mem |
i_opcode_x86_IN_port_fixed |
i_opcode_x86_IN_port_variable |
i_opcode_x86_INC_reg_mem |
i_opcode_x86_INC_reg_mem |
i_opcode_x86_LODS_load_string_operand |
i_opcode_x86_MOV_reg_to_reg_mem |
i_opcode_x86_MOV_reg_mem_to_reg |
i_opcode_x86_MOV_imm_to_reg_mem |
i_opcode_x86_MOV_mem_to_acc |
i_opcode_x86_MOV_acc_to_mem |
i_opcode_x86_MOVS_move_data_from_string_to_string |
i_opcode_x86_MUL_acc_with_reg_mem |
i_opcode_x86_NEG_two_s_complement_negation |
i_opcode_x86_NOT_one_s_complement_negation |
i_opcode_x86_OR_reg_to_reg_mem |
i_opcode_x86_OR_reg_mem_to_reg |
i_opcode_x86_OR_imm_to_reg_mem |
i_opcode_x86_OR_imm_to_acc |
i_opcode_x86_OUT_port_fixed |
i_opcode_x86_OUT_port_variable |
i_opcode_x86_OUTS_output_string |
i_opcode_x86_RCL_reg_mem_by_1 |
i_opcode_x86_RCL_reg_mem_by_CL |
i_opcode_x86_RCL_reg_mem_by_imm |
i_opcode_x86_RCR_reg_mem_by_1 |
i_opcode_x86_RCR_reg_mem_by_CL |
i_opcode_x86_RCR_reg_mem_by_imm |
i_opcode_x86_ROL_reg_mem_by_1 |
i_opcode_x86_ROL_reg_mem_by_CL |
i_opcode_x86_ROL_reg_mem_by_imm |
i_opcode_x86_ROR_reg_mem_by_1 |
i_opcode_x86_ROR_reg_mem_by_CL |
i_opcode_x86_ROR_reg_mem_by_imm |
i_opcode_x86_SAR_reg_mem_by_1 |
i_opcode_x86_SAR_reg_mem_by_CL |
i_opcode_x86_SAR_reg_mem_by_imm |
i_opcode_x86_SBB_reg_to_reg_mem |
i_opcode_x86_SBB_reg_mem_to_reg |
i_opcode_x86_SBB_imm_to_reg_mem |
i_opcode_x86_SBB_imm_to_acc |
i_opcode_x86_SCAS_scan_string |
i_opcode_x86_SHL_reg_mem_by_1 |
i_opcode_x86_SHL_reg_mem_by_CL |
i_opcode_x86_SHL_reg_mem_by_imm |
i_opcode_x86_SHR_reg_mem_by_1 |
i_opcode_x86_SHR_reg_mem_by_CL |
i_opcode_x86_SHR_reg_mem_by_imm |
i_opcode_x86_STOS_store_string_data |
i_opcode_x86_SUB_reg_to_reg_mem |
i_opcode_x86_SUB_reg_mem_to_reg |
i_opcode_x86_SUB_imm_to_reg_mem |
i_opcode_x86_SUB_imm_to_acc |
i_opcode_x86_TEST_reg_mem_and_reg |
i_opcode_x86_TEST_imm_and_reg_mem |
i_opcode_x86_TEST_imm_and_acc |
i_opcode_x86_XCHG_reg_mem_with_reg |
i_opcode_x86_XOR_reg_to_reg_mem |
i_opcode_x86_XOR_reg_mem_to_reg |
i_opcode_x86_XOR_imm_to_reg_mem |
i_opcode_x86_XOR_imm_to_acc |
0;
wire w_at_0_3 =
i_opcode_x86_MOV_imm_to_reg |
0;
wire w_at_1_0 =
i_opcode_x86_CMPXCHG_compare_and_exchange |
i_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg |
i_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg |
i_opcode_x86_XADD_exchange_and_add |
0;
assign o_w_is_present =
w_at_0_0 |
w_at_0_3 |
w_at_1_0 |
0;
always_comb begin
    case (1'b1)
        w_at_0_0: o_w <= i_instruction[0][0];
        w_at_0_3: o_w <= i_instruction[0][3];
        w_at_1_0: o_w <= i_instruction[1][0];
        default : o_w <= 1'b0;
    endcase
end

wire s_at_0_1 =
i_opcode_x86_ADC_imm_to_reg_mem |
i_opcode_x86_ADD_imm_to_reg_mem |
i_opcode_x86_AND_imm_to_reg_mem |
i_opcode_x86_CMP_imm_with_reg_mem |
i_opcode_x86_IMUL_reg_mem_with_imm_to_reg |
i_opcode_x86_OR_imm_to_reg_mem |
i_opcode_x86_PUSH_imm |
i_opcode_x86_SBB_imm_to_reg_mem |
i_opcode_x86_SUB_imm_to_reg_mem |
i_opcode_x86_XOR_imm_to_reg_mem |
0;
assign o_s_is_present =
s_at_0_1 |
0;
always_comb begin
    case (1'b1)
        s_at_0_1: o_s <= i_instruction[0][1];
        default : o_s <= 1'b0;
    endcase
end

assign o_mod_rm_is_present =
i_opcode_x86_ADC_reg_to_reg_mem |
i_opcode_x86_ADC_reg_mem_to_reg |
i_opcode_x86_ADC_imm_to_reg_mem |
i_opcode_x86_ADD_reg_to_reg_mem |
i_opcode_x86_ADD_reg_mem_to_reg |
i_opcode_x86_ADD_imm_to_reg_mem |
i_opcode_x86_AND_reg_to_reg_mem |
i_opcode_x86_AND_reg_mem_to_reg |
i_opcode_x86_AND_imm_to_reg_mem |
i_opcode_x86_ARPL_adjust_RPL_field_of_selector |
i_opcode_x86_BOUND_check_array_against_bounds |
i_opcode_x86_BSF_bit_scan_forward |
i_opcode_x86_BSR_bit_scan_reverse |
i_opcode_x86_BT_reg_mem_with_imm |
i_opcode_x86_BT_reg_mem_with_reg |
i_opcode_x86_BTC_reg_mem_with_imm |
i_opcode_x86_BTC_reg_mem_with_reg |
i_opcode_x86_BTR_reg_mem_with_imm |
i_opcode_x86_BTR_reg_mem_with_reg |
i_opcode_x86_BTS_reg_mem_with_imm |
i_opcode_x86_BTS_reg_mem_with_reg |
i_opcode_x86_CALL_in_same_segment_indirect |
i_opcode_x86_CALL_in_other_segment_indirect |
i_opcode_x86_CMP_mem_with_reg |
i_opcode_x86_CMP_reg_with_mem |
i_opcode_x86_CMP_imm_with_reg_mem |
i_opcode_x86_CMPXCHG_compare_and_exchange |
i_opcode_x86_DEC_reg_mem |
i_opcode_x86_DIV_acc_by_reg_mem |
i_opcode_x86_IDIV_acc_by_reg_mem |
i_opcode_x86_IMUL_acc_with_reg_mem |
i_opcode_x86_IMUL_reg_with_reg_mem |
i_opcode_x86_IMUL_reg_mem_with_imm_to_reg |
i_opcode_x86_INVLPG_invalidate_TLB_entry |
i_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size |
i_opcode_x86_JMP_to_same_segment_indirect |
i_opcode_x86_JMP_to_other_segment_indirect |
i_opcode_x86_LAR_load_access_rights_byte |
i_opcode_x86_LDS_load_pointer_to_DS |
i_opcode_x86_LEA_load_effective_adddress_to_reg |
i_opcode_x86_LES_load_pointer_to_ES |
i_opcode_x86_LFS_load_pointer_to_FS |
i_opcode_x86_LGDT_load_global_desciptor_table_reg |
i_opcode_x86_LGS_load_pointer_to_GS |
i_opcode_x86_LIDT_load_interrupt_desciptor_table_reg |
i_opcode_x86_LLDT_load_local_desciptor_table_reg |
i_opcode_x86_LMSW_load_status_word |
i_opcode_x86_LSL_load_segment_limit |
i_opcode_x86_LSS_load_pointer_to_SS |
i_opcode_x86_LTR_load_task_register |
i_opcode_x86_MOV_reg_to_reg_mem |
i_opcode_x86_MOV_reg_mem_to_reg |
i_opcode_x86_MOV_imm_to_reg_mem |
i_opcode_x86_MOV_CR_from_reg |
i_opcode_x86_MOV_reg_from_CR |
i_opcode_x86_MOV_DR_from_reg |
i_opcode_x86_MOV_reg_from_DR |
i_opcode_x86_MOV_TR_from_reg |
i_opcode_x86_MOV_reg_from_TR |
i_opcode_x86_MOV_reg_mem_to_sreg |
i_opcode_x86_MOV_sreg_to_reg_mem |
i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg |
i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem |
i_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg |
i_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg |
i_opcode_x86_MUL_acc_with_reg_mem |
i_opcode_x86_NEG_two_s_complement_negation |
i_opcode_x86_NOP_no_operation_multi_byte |
i_opcode_x86_NOT_one_s_complement_negation |
i_opcode_x86_OR_reg_to_reg_mem |
i_opcode_x86_OR_reg_mem_to_reg |
i_opcode_x86_OR_imm_to_reg_mem |
i_opcode_x86_POP_reg_mem |
i_opcode_x86_PUSH_reg_mem |
i_opcode_x86_RCL_reg_mem_by_1 |
i_opcode_x86_RCL_reg_mem_by_CL |
i_opcode_x86_RCL_reg_mem_by_imm |
i_opcode_x86_RCR_reg_mem_by_1 |
i_opcode_x86_RCR_reg_mem_by_CL |
i_opcode_x86_RCR_reg_mem_by_imm |
i_opcode_x86_ROL_reg_mem_by_1 |
i_opcode_x86_ROL_reg_mem_by_CL |
i_opcode_x86_ROL_reg_mem_by_imm |
i_opcode_x86_ROR_reg_mem_by_1 |
i_opcode_x86_ROR_reg_mem_by_CL |
i_opcode_x86_ROR_reg_mem_by_imm |
i_opcode_x86_SAR_reg_mem_by_1 |
i_opcode_x86_SAR_reg_mem_by_CL |
i_opcode_x86_SAR_reg_mem_by_imm |
i_opcode_x86_SBB_reg_to_reg_mem |
i_opcode_x86_SBB_reg_mem_to_reg |
i_opcode_x86_SBB_imm_to_reg_mem |
i_opcode_x86_SETcc_byte_set_on_condition |
i_opcode_x86_SGDT_store_global_descriptor_table_register |
i_opcode_x86_SHL_reg_mem_by_1 |
i_opcode_x86_SHL_reg_mem_by_CL |
i_opcode_x86_SHL_reg_mem_by_imm |
i_opcode_x86_SHLD_reg_mem_by_imm |
i_opcode_x86_SHLD_reg_mem_by_CL |
i_opcode_x86_SHR_reg_mem_by_1 |
i_opcode_x86_SHR_reg_mem_by_CL |
i_opcode_x86_SHR_reg_mem_by_imm |
i_opcode_x86_SHRD_reg_mem_by_imm |
i_opcode_x86_SHRD_reg_mem_by_CL |
i_opcode_x86_SIDT_store_interrupt_desciptor_table_register |
i_opcode_x86_SLDT_store_local_desciptor_table_register |
i_opcode_x86_SMSW_store_machine_status_word |
i_opcode_x86_STR_store_task_register |
i_opcode_x86_SUB_reg_to_reg_mem |
i_opcode_x86_SUB_reg_mem_to_reg |
i_opcode_x86_SUB_imm_to_reg_mem |
i_opcode_x86_TEST_reg_mem_and_reg |
i_opcode_x86_TEST_imm_and_reg_mem |
i_opcode_x86_VERR_verify_a_segment_for_reading |
i_opcode_x86_VERW_verify_a_segment_for_writing |
i_opcode_x86_XADD_exchange_and_add |
i_opcode_x86_XCHG_reg_mem_with_reg |
i_opcode_x86_XOR_reg_to_reg_mem |
i_opcode_x86_XOR_reg_mem_to_reg |
i_opcode_x86_XOR_imm_to_reg_mem |
0;
logic [7:0] mod_rm_instruction;
assign { o_mod, o_rm } = { mod_rm_instruction[7:6], mod_rm_instruction[2:0] };
always_comb begin
    case (1'b1)
        o_primary_opcode_byte_1: mod_rm_instruction <= i_instruction[1];
        o_primary_opcode_byte_2: mod_rm_instruction <= i_instruction[2];
        o_primary_opcode_byte_3: mod_rm_instruction <= i_instruction[3];
        default                : mod_rm_instruction <= 8'b0;
    endcase
end

wire unsigned_full_offset_selector_is_present =
i_opcode_x86_CALL_in_other_segment_direct |
i_opcode_x86_JMP_to_other_segment_direct |
0;

assign o_immediate_size_full =
i_opcode_x86_ADC_imm_to_reg_mem |
i_opcode_x86_ADC_imm_to_acc |
i_opcode_x86_ADD_imm_to_reg_mem |
i_opcode_x86_ADD_imm_to_acc |
i_opcode_x86_AND_imm_to_reg_mem |
i_opcode_x86_AND_imm_to_acc |
i_opcode_x86_CMP_imm_with_reg_mem |
i_opcode_x86_CMP_imm_with_acc |
i_opcode_x86_IMUL_reg_mem_with_imm_to_reg |
i_opcode_x86_MOV_imm_to_reg_mem |
i_opcode_x86_MOV_imm_to_reg |
i_opcode_x86_OR_imm_to_reg_mem |
i_opcode_x86_OR_imm_to_acc |
i_opcode_x86_PUSH_imm |
i_opcode_x86_SBB_imm_to_reg_mem |
i_opcode_x86_SBB_imm_to_acc |
i_opcode_x86_SUB_imm_to_reg_mem |
i_opcode_x86_SUB_imm_to_acc |
i_opcode_x86_TEST_imm_and_reg_mem |
i_opcode_x86_TEST_imm_and_acc |
i_opcode_x86_XOR_imm_to_reg_mem |
i_opcode_x86_XOR_imm_to_acc |
0;
assign o_immediate_size_16 =
i_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP |
i_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP |
unsigned_full_offset_selector_is_present |
0;
assign o_immediate_size_8 =
i_opcode_x86_BT_reg_mem_with_imm |
i_opcode_x86_BTC_reg_mem_with_imm |
i_opcode_x86_BTR_reg_mem_with_imm |
i_opcode_x86_BTS_reg_mem_with_imm |
i_opcode_x86_IN_port_fixed |
i_opcode_x86_INT_interrupt_type_n |
i_opcode_x86_RCL_reg_mem_by_imm |
i_opcode_x86_RCR_reg_mem_by_imm |
i_opcode_x86_ROL_reg_mem_by_imm |
i_opcode_x86_ROR_reg_mem_by_imm |
i_opcode_x86_SAR_reg_mem_by_imm |
i_opcode_x86_SHL_reg_mem_by_imm |
i_opcode_x86_SHR_reg_mem_by_imm |
i_opcode_x86_SHRD_reg_mem_by_imm |
0;
assign o_immediate_is_present =
o_immediate_size_full |
o_immediate_size_16 |
o_immediate_size_8 |
0;

assign o_displacement_size_full =
i_opcode_x86_CALL_in_same_segment_direct |
i_opcode_x86_Jcc_jump_if_cond_is_met_full_disp |
i_opcode_x86_JMP_to_same_segment_direct |
i_opcode_x86_MOV_mem_to_acc |
i_opcode_x86_MOV_acc_to_mem |
unsigned_full_offset_selector_is_present |
0;
assign o_displacement_size_8 =
i_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp |
i_opcode_x86_JCXZ_jump_on_CX_zero |
i_opcode_x86_JMP_to_same_segment_short |
i_opcode_x86_LOOP_count |
i_opcode_x86_LOOPZ_count_while_zero |
i_opcode_x86_LOOPNZ_count_while_not_zero |
i_opcode_x86_OUT_port_fixed |
0;
assign o_displacement_is_present =
o_displacement_size_full |
o_displacement_size_8 |
0;

// wire mod_rm_at_1 =
// i_opcode_x86_ADC_reg_to_reg_mem |
// i_opcode_x86_ADC_reg_mem_to_reg |
// i_opcode_x86_ADC_imm_to_reg_mem |
// i_opcode_x86_ADC_imm_to_acc |
// i_opcode_x86_ADD_reg_to_reg_mem |
// i_opcode_x86_ADD_reg_mem_to_reg |
// i_opcode_x86_ADD_imm_to_reg_mem |
// i_opcode_x86_ADD_imm_to_acc |
// i_opcode_x86_AND_reg_to_reg_mem |
// i_opcode_x86_AND_reg_mem_to_reg |
// i_opcode_x86_AND_imm_to_reg_mem |
// i_opcode_x86_AND_imm_to_acc |
// i_opcode_x86_ARPL_adjust_RPL_field_of_selector |
// i_opcode_x86_BOUND_check_array_against_bounds |
// i_opcode_x86_BSWAP_byte_swap |
// i_opcode_x86_CALL_in_same_segment_direct |
// i_opcode_x86_CALL_in_same_segment_indirect |
// i_opcode_x86_CALL_in_other_segment_direct |
// i_opcode_x86_CALL_in_other_segment_indirect |
// i_opcode_x86_CBW_convert_byte_to_word |
// i_opcode_x86_CDQ_convert_double_word_to_quad_word |
// i_opcode_x86_CLC_clear_carry_flag |
// i_opcode_x86_CLD_clear_direction_flag |
// i_opcode_x86_CLI_clear_interrupt_enable_flag |
// i_opcode_x86_CMC_complement_carry_flag |
// i_opcode_x86_CMP_mem_with_reg |
// i_opcode_x86_CMP_reg_with_mem |
// i_opcode_x86_CMP_imm_with_reg_mem |
// i_opcode_x86_CMP_imm_with_acc |
// i_opcode_x86_CMPS_compare_string_operands |
// i_opcode_x86_CWD_convert_word_to_double |
// i_opcode_x86_CWDE_convert_word_to_double |
// i_opcode_x86_DAA_decimal_adjust_AL_after_add |
// i_opcode_x86_DAS_decimal_adjust_AL_after_sub |
// i_opcode_x86_DEC_reg_mem |
// i_opcode_x86_DEC_reg |
// i_opcode_x86_DIV_acc_by_reg_mem |
// i_opcode_x86_HLT_halt |
// i_opcode_x86_IDIV_acc_by_reg_mem |
// i_opcode_x86_IMUL_acc_with_reg_mem |
// i_opcode_x86_IN_port_fixed |
// i_opcode_x86_IN_port_variable |
// i_opcode_x86_INC_reg_mem |
// i_opcode_x86_INC_reg |
// i_opcode_x86_INS_input_from_DX_port |
// i_opcode_x86_INT_interrupt_type_n |
// i_opcode_x86_INT_interrupt_type_3 |
// i_opcode_x86_INT_interrupt_type_4 |
// i_opcode_x86_IRET_interrupt_return |
// i_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp |
// i_opcode_x86_JCXZ_jump_on_CX_zero |
// i_opcode_x86_JMP_to_same_segment_short |
// i_opcode_x86_JMP_to_same_segment_direct |
// i_opcode_x86_JMP_to_same_segment_indirect |
// i_opcode_x86_JMP_to_other_segment_direct |
// i_opcode_x86_JMP_to_other_segment_indirect |
// i_opcode_x86_LAHF_load_FLAG_into_AH |
// i_opcode_x86_LDS_load_pointer_to_DS |
// i_opcode_x86_LEA_load_effective_adddress_to_reg |
// i_opcode_x86_LES_load_pointer_to_ES |
// i_opcode_x86_LEAVE_high_level_procedure_exit |
// i_opcode_x86_LODS_load_string_operand |
// i_opcode_x86_LOOP_count |
// i_opcode_x86_LOOPZ_count_while_zero |
// i_opcode_x86_LOOPNZ_count_while_not_zero |
// i_opcode_x86_MOV_reg_to_reg_mem |
// i_opcode_x86_MOV_reg_mem_to_reg |
// i_opcode_x86_MOV_imm_to_reg_mem |
// i_opcode_x86_MOV_imm_to_reg |
// i_opcode_x86_MOV_mem_to_acc |
// i_opcode_x86_MOV_acc_to_mem |
// i_opcode_x86_MOV_reg_mem_to_sreg |
// i_opcode_x86_MOV_sreg_to_reg_mem |
// i_opcode_x86_MOVS_move_data_from_string_to_string |
// i_opcode_x86_MUL_acc_with_reg_mem |
// i_opcode_x86_NEG_two_s_complement_negation |
// i_opcode_x86_NOP_no_operation |
// i_opcode_x86_NOT_one_s_complement_negation |
// i_opcode_x86_OR_reg_to_reg_mem |
// i_opcode_x86_OR_reg_mem_to_reg |
// i_opcode_x86_OR_imm_to_reg_mem |
// i_opcode_x86_OUT_port_fixed |
// i_opcode_x86_OUT_port_variable |
// i_opcode_x86_OUTS_output_string |
// i_opcode_x86_POP_reg_mem |
// i_opcode_x86_POP_reg |
// i_opcode_x86_POP_sreg_2 |
// i_opcode_x86_POPA_pop_all_general_registers |
// i_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS |
// i_opcode_x86_PUSH_reg_mem |
// i_opcode_x86_PUSH_reg |
// i_opcode_x86_PUSH_sreg_2 |
// i_opcode_x86_PUSH_imm |
// i_opcode_x86_PUSH_all_general_registers |
// i_opcode_x86_PUSHF_push_flags_onto_stack |
// i_opcode_x86_RCL_reg_mem_by_1 |
// i_opcode_x86_RCL_reg_mem_by_CL |
// i_opcode_x86_RCL_reg_mem_by_imm |
// i_opcode_x86_RCR_reg_mem_by_1 |
// i_opcode_x86_RCR_reg_mem_by_CL |
// i_opcode_x86_RCR_reg_mem_by_imm |
// i_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument |
// i_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP |
// i_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument |
// i_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP |
// i_opcode_x86_ROL_reg_mem_by_1 |
// i_opcode_x86_ROL_reg_mem_by_CL |
// i_opcode_x86_ROL_reg_mem_by_imm |
// i_opcode_x86_ROR_reg_mem_by_1 |
// i_opcode_x86_ROR_reg_mem_by_CL |
// i_opcode_x86_ROR_reg_mem_by_imm |
// i_opcode_x86_SAHF_store_AH_into_flags |
// i_opcode_x86_SAR_reg_mem_by_1 |
// i_opcode_x86_SAR_reg_mem_by_CL |
// i_opcode_x86_SAR_reg_mem_by_imm |
// i_opcode_x86_SBB_reg_to_reg_mem |
// i_opcode_x86_SBB_reg_mem_to_reg |
// i_opcode_x86_SBB_imm_to_reg_mem |
// i_opcode_x86_SBB_imm_to_acc |
// i_opcode_x86_SCAS_scan_string |
// i_opcode_x86_SHR_reg_mem_by_1 |
// i_opcode_x86_SHR_reg_mem_by_CL |
// i_opcode_x86_SHR_reg_mem_by_imm |
// i_opcode_x86_STC_set_carry_flag |
// i_opcode_x86_STD_set_direction_flag |
// i_opcode_x86_STI_set_interrupt_enable_flag |
// i_opcode_x86_STOS_store_string_data |
// i_opcode_x86_SUB_reg_to_reg_mem |
// i_opcode_x86_SUB_reg_mem_to_reg |
// i_opcode_x86_SUB_imm_to_reg_mem |
// i_opcode_x86_SUB_imm_to_acc |
// i_opcode_x86_TEST_reg_mem_and_reg |
// i_opcode_x86_TEST_imm_and_reg_mem |
// i_opcode_x86_TEST_imm_and_acc |
// i_opcode_x86_WAIT_wait |
// i_opcode_x86_XCHG_reg_mem_with_reg |
// i_opcode_x86_XCHG_reg_with_acc_short |
// i_opcode_x86_XLAT_table_look_up_translation |
// i_opcode_x86_XOR_reg_to_reg_mem |
// i_opcode_x86_XOR_reg_mem_to_reg |
// i_opcode_x86_XOR_imm_to_reg_mem |
// i_opcode_x86_XOR_imm_to_acc |
// 0;
// wire mod_rm_at_2 =
// i_opcode_x86_BSF_bit_scan_forward |
// i_opcode_x86_BSR_bit_scan_reverse |
// i_opcode_x86_BT_reg_mem_with_imm |
// i_opcode_x86_BT_reg_mem_with_reg |
// i_opcode_x86_BTC_reg_mem_with_imm |
// i_opcode_x86_BTC_reg_mem_with_reg |
// i_opcode_x86_BTR_reg_mem_with_imm |
// i_opcode_x86_BTR_reg_mem_with_reg |
// i_opcode_x86_BTS_reg_mem_with_imm |
// i_opcode_x86_BTS_reg_mem_with_reg |
// i_opcode_x86_CLTS_clear_task_switched_flag |
// i_opcode_x86_CMPXCHG_compare_and_exchange |
// i_opcode_x86_CPUID_CPU_identification |
// i_opcode_x86_IMUL_reg_with_reg_mem |
// i_opcode_x86_INVD_invalidate_cache |
// i_opcode_x86_INVLPG_invalidate_TLB_entry |
// i_opcode_x86_Jcc_jump_if_cond_is_met_full_disp |
// i_opcode_x86_LAR_load_access_rights_byte |
// i_opcode_x86_LES_load_pointer_to_ES |
// i_opcode_x86_LFS_load_pointer_to_FS |
// i_opcode_x86_LGDT_load_global_desciptor_table_reg |
// i_opcode_x86_LGS_load_pointer_to_GS |
// i_opcode_x86_LIDT_load_interrupt_desciptor_table_reg |
// i_opcode_x86_LLDT_load_local_desciptor_table_reg |
// i_opcode_x86_LMSW_load_status_word |
// i_opcode_x86_LSL_load_segment_limit |
// i_opcode_x86_LSS_load_pointer_to_SS |
// i_opcode_x86_LTR_load_task_register |
// i_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg |
// i_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg |
// i_opcode_x86_NOP_no_operation_multi_byte |
// i_opcode_x86_POP_sreg_3 |
// i_opcode_x86_PUSH_sreg_3 |
// i_opcode_x86_RDMSR_read_from_model_specific_reg |
// i_opcode_x86_RDPMC_read_performance_monitoring_counters |
// i_opcode_x86_RDTSC_read_time_stamp_counter |
// i_opcode_x86_RSM_resume_from_system_management_mode |
// i_opcode_x86_SETcc_byte_set_on_condition |
// i_opcode_x86_SGDT_store_global_descriptor_table_register |
// i_opcode_x86_SHLD_reg_mem_by_imm |
// i_opcode_x86_SHLD_reg_mem_by_CL |
// i_opcode_x86_SHRD_reg_mem_by_imm |
// i_opcode_x86_SHRD_reg_mem_by_CL |
// i_opcode_x86_SIDT_store_interrupt_desciptor_table_register |
// i_opcode_x86_SLDT_store_local_desciptor_table_register |
// i_opcode_x86_SMSW_store_machine_status_word |
// i_opcode_x86_STR_store_task_register |
// i_opcode_x86_UD0_undefined_instruction |
// i_opcode_x86_UD1_undefined_instruction |
// i_opcode_x86_UD2_undefined_instruction |
// i_opcode_x86_VERR_verify_a_segment_for_reading |
// i_opcode_x86_VERW_verify_a_segment_for_writing |
// i_opcode_x86_WBINVD_writeback_and_invalidate_data_cache |
// i_opcode_x86_WRMSR_write_to_model_specific_register |
// i_opcode_x86_XADD_exchange_and_add |
// 0;
// wire mod_rm_at_3 =
// i_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size |
// i_opcode_x86_MOV_CR_from_reg |
// i_opcode_x86_MOV_reg_from_CR |
// i_opcode_x86_MOV_DR_from_reg |
// i_opcode_x86_MOV_reg_from_DR |
// i_opcode_x86_MOV_TR_from_reg |
// i_opcode_x86_MOV_reg_from_TR |
// i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg |
// i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem |
// i_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id |
// 0;

assign o_primary_opcode_byte_1 =
i_opcode_x86_AAA_ASCII_adjust_after_add |
i_opcode_x86_AAS_ASCII_adjust_after_sub |
i_opcode_x86_ADC_reg_to_reg_mem |
i_opcode_x86_ADC_reg_mem_to_reg |
i_opcode_x86_ADC_imm_to_reg_mem |
i_opcode_x86_ADC_imm_to_acc |
i_opcode_x86_ADD_reg_to_reg_mem |
i_opcode_x86_ADD_reg_mem_to_reg |
i_opcode_x86_ADD_imm_to_reg_mem |
i_opcode_x86_ADD_imm_to_acc |
i_opcode_x86_AND_reg_to_reg_mem |
i_opcode_x86_AND_reg_mem_to_reg |
i_opcode_x86_AND_imm_to_reg_mem |
i_opcode_x86_AND_imm_to_acc |
i_opcode_x86_ARPL_adjust_RPL_field_of_selector |
i_opcode_x86_BOUND_check_array_against_bounds |
i_opcode_x86_CALL_in_same_segment_direct |
i_opcode_x86_CALL_in_same_segment_indirect |
i_opcode_x86_CALL_in_other_segment_direct |
i_opcode_x86_CALL_in_other_segment_indirect |
i_opcode_x86_CBW_convert_byte_to_word |
i_opcode_x86_CDQ_convert_double_word_to_quad_word |
i_opcode_x86_CLC_clear_carry_flag |
i_opcode_x86_CLD_clear_direction_flag |
i_opcode_x86_CLI_clear_interrupt_enable_flag |
i_opcode_x86_CMC_complement_carry_flag |
i_opcode_x86_CMP_mem_with_reg |
i_opcode_x86_CMP_reg_with_mem |
i_opcode_x86_CMP_imm_with_reg_mem |
i_opcode_x86_CMP_imm_with_acc |
i_opcode_x86_CMPS_compare_string_operands |
i_opcode_x86_CWD_convert_word_to_double |
i_opcode_x86_CWDE_convert_word_to_double |
i_opcode_x86_DAA_decimal_adjust_AL_after_add |
i_opcode_x86_DAS_decimal_adjust_AL_after_sub |
i_opcode_x86_DEC_reg_mem |
i_opcode_x86_DEC_reg |
i_opcode_x86_DIV_acc_by_reg_mem |
i_opcode_x86_HLT_halt |
i_opcode_x86_IDIV_acc_by_reg_mem |
i_opcode_x86_IMUL_acc_with_reg_mem |
i_opcode_x86_IMUL_reg_mem_with_imm_to_reg |
i_opcode_x86_IN_port_fixed |
i_opcode_x86_IN_port_variable |
i_opcode_x86_INC_reg |
i_opcode_x86_INS_input_from_DX_port |
i_opcode_x86_INT_interrupt_type_n |
i_opcode_x86_INT_interrupt_type_3 |
i_opcode_x86_INT_interrupt_type_4 |
i_opcode_x86_IRET_interrupt_return |
i_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp |
i_opcode_x86_JCXZ_jump_on_CX_zero |
i_opcode_x86_JMP_to_same_segment_short |
i_opcode_x86_JMP_to_same_segment_direct |
i_opcode_x86_JMP_to_same_segment_indirect |
i_opcode_x86_JMP_to_other_segment_direct |
i_opcode_x86_JMP_to_other_segment_indirect |
i_opcode_x86_LAHF_load_FLAG_into_AH |
i_opcode_x86_LDS_load_pointer_to_DS |
i_opcode_x86_LEA_load_effective_adddress_to_reg |
i_opcode_x86_LEAVE_high_level_procedure_exit |
i_opcode_x86_LES_load_pointer_to_ES |
i_opcode_x86_LODS_load_string_operand |
i_opcode_x86_LOOP_count |
i_opcode_x86_LOOPZ_count_while_zero |
i_opcode_x86_LOOPNZ_count_while_not_zero |
i_opcode_x86_MOV_reg_to_reg_mem |
i_opcode_x86_MOV_reg_mem_to_reg |
i_opcode_x86_MOV_imm_to_reg_mem |
i_opcode_x86_MOV_imm_to_reg |
i_opcode_x86_MOV_mem_to_acc |
i_opcode_x86_MOV_acc_to_mem |
i_opcode_x86_MOV_reg_mem_to_sreg |
i_opcode_x86_MOV_sreg_to_reg_mem |
i_opcode_x86_MOVS_move_data_from_string_to_string |
i_opcode_x86_MUL_acc_with_reg_mem |
i_opcode_x86_NEG_two_s_complement_negation |
i_opcode_x86_NOP_no_operation |
i_opcode_x86_NOT_one_s_complement_negation |
i_opcode_x86_OR_reg_to_reg_mem |
i_opcode_x86_OR_reg_mem_to_reg |
i_opcode_x86_OR_imm_to_reg_mem |
i_opcode_x86_OR_imm_to_acc |
i_opcode_x86_OUT_port_fixed |
i_opcode_x86_OUT_port_variable |
i_opcode_x86_OUTS_output_string |
i_opcode_x86_POP_reg_mem |
i_opcode_x86_POP_reg |
i_opcode_x86_POP_sreg_2 |
i_opcode_x86_POPA_pop_all_general_registers |
i_opcode_x86_POPF_pop_stack_into_FLAGS_or_EFLAGS |
i_opcode_x86_PUSH_reg_mem |
i_opcode_x86_PUSH_reg |
i_opcode_x86_PUSH_sreg_2 |
i_opcode_x86_PUSH_imm |
i_opcode_x86_PUSH_all_general_registers |
i_opcode_x86_PUSHF_push_flags_onto_stack |
i_opcode_x86_RCL_reg_mem_by_1 |
i_opcode_x86_RCL_reg_mem_by_CL |
i_opcode_x86_RCL_reg_mem_by_imm |
i_opcode_x86_RCR_reg_mem_by_1 |
i_opcode_x86_RCR_reg_mem_by_CL |
i_opcode_x86_RCR_reg_mem_by_imm |
i_opcode_x86_RET_return_from_procedure_to_same_segment_no_argument |
i_opcode_x86_RET_return_from_procedure_to_same_segment_adding_imm_to_SP |
i_opcode_x86_RET_return_from_procedure_to_other_segment_no_argument |
i_opcode_x86_RET_return_from_procedure_to_other_segment_adding_imm_to_SP |
i_opcode_x86_ROL_reg_mem_by_1 |
i_opcode_x86_ROL_reg_mem_by_CL |
i_opcode_x86_ROL_reg_mem_by_imm |
i_opcode_x86_ROR_reg_mem_by_1 |
i_opcode_x86_ROR_reg_mem_by_CL |
i_opcode_x86_ROR_reg_mem_by_imm |
i_opcode_x86_SAHF_store_AH_into_flags |
i_opcode_x86_SAR_reg_mem_by_1 |
i_opcode_x86_SAR_reg_mem_by_CL |
i_opcode_x86_SAR_reg_mem_by_imm |
i_opcode_x86_SBB_reg_to_reg_mem |
i_opcode_x86_SBB_reg_mem_to_reg |
i_opcode_x86_SBB_imm_to_reg_mem |
i_opcode_x86_SBB_imm_to_acc |
i_opcode_x86_SCAS_scan_string |
i_opcode_x86_SHL_reg_mem_by_1 |
i_opcode_x86_SHL_reg_mem_by_CL |
i_opcode_x86_SHL_reg_mem_by_imm |
i_opcode_x86_SHR_reg_mem_by_1 |
i_opcode_x86_SHR_reg_mem_by_CL |
i_opcode_x86_SHR_reg_mem_by_imm |
i_opcode_x86_STC_set_carry_flag |
i_opcode_x86_STD_set_direction_flag |
i_opcode_x86_STI_set_interrupt_enable_flag |
i_opcode_x86_STOS_store_string_data |
i_opcode_x86_SUB_reg_to_reg_mem |
i_opcode_x86_SUB_reg_mem_to_reg |
i_opcode_x86_SUB_imm_to_reg_mem |
i_opcode_x86_SUB_imm_to_acc |
i_opcode_x86_TEST_reg_mem_and_reg |
i_opcode_x86_TEST_imm_and_reg_mem |
i_opcode_x86_TEST_imm_and_acc |
i_opcode_x86_WAIT_wait |
i_opcode_x86_XCHG_reg_mem_with_reg |
i_opcode_x86_XCHG_reg_with_acc_short |
i_opcode_x86_XLAT_table_look_up_translation |
i_opcode_x86_XOR_reg_to_reg_mem |
i_opcode_x86_XOR_reg_mem_to_reg |
i_opcode_x86_XOR_imm_to_reg_mem |
i_opcode_x86_XOR_imm_to_acc |
0;
assign o_primary_opcode_byte_2 =
i_opcode_x86_AAD_ASCII_AX_before_div |
i_opcode_x86_AAM_ASCII_AX_after_mul |
i_opcode_x86_BSF_bit_scan_forward |
i_opcode_x86_BSR_bit_scan_reverse |
i_opcode_x86_BSWAP_byte_swap |
i_opcode_x86_BT_reg_mem_with_imm |
i_opcode_x86_BT_reg_mem_with_reg |
i_opcode_x86_BTC_reg_mem_with_imm |
i_opcode_x86_BTC_reg_mem_with_reg |
i_opcode_x86_BTR_reg_mem_with_imm |
i_opcode_x86_BTR_reg_mem_with_reg |
i_opcode_x86_BTS_reg_mem_with_imm |
i_opcode_x86_BTS_reg_mem_with_reg |
i_opcode_x86_CLTS_clear_task_switched_flag |
i_opcode_x86_CMPXCHG_compare_and_exchange |
i_opcode_x86_CPUID_CPU_identification |
i_opcode_x86_IMUL_reg_with_reg_mem |
i_opcode_x86_INC_reg_mem |
i_opcode_x86_INVD_invalidate_cache |
i_opcode_x86_INVLPG_invalidate_TLB_entry |
i_opcode_x86_Jcc_jump_if_cond_is_met_full_disp |
i_opcode_x86_LAR_load_access_rights_byte |
i_opcode_x86_LFS_load_pointer_to_FS |
i_opcode_x86_LGDT_load_global_desciptor_table_reg |
i_opcode_x86_LGS_load_pointer_to_GS |
i_opcode_x86_LIDT_load_interrupt_desciptor_table_reg |
i_opcode_x86_LLDT_load_local_desciptor_table_reg |
i_opcode_x86_LMSW_load_status_word |
i_opcode_x86_LSL_load_segment_limit |
i_opcode_x86_LSS_load_pointer_to_SS |
i_opcode_x86_LTR_load_task_register |
i_opcode_x86_MOV_CR_from_reg |
i_opcode_x86_MOV_reg_from_CR |
i_opcode_x86_MOV_DR_from_reg |
i_opcode_x86_MOV_reg_from_DR |
i_opcode_x86_MOV_TR_from_reg |
i_opcode_x86_MOV_reg_from_TR |
i_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg |
i_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg |
i_opcode_x86_NOP_no_operation_multi_byte |
i_opcode_x86_POP_sreg_3 |
i_opcode_x86_PUSH_sreg_3 |
i_opcode_x86_RDMSR_read_from_model_specific_reg |
i_opcode_x86_RDPMC_read_performance_monitoring_counters |
i_opcode_x86_RDTSC_read_time_stamp_counter |
i_opcode_x86_RSM_resume_from_system_management_mode |
i_opcode_x86_SETcc_byte_set_on_condition |
i_opcode_x86_SGDT_store_global_descriptor_table_register |
i_opcode_x86_SHLD_reg_mem_by_imm |
i_opcode_x86_SHLD_reg_mem_by_CL |
i_opcode_x86_SHRD_reg_mem_by_imm |
i_opcode_x86_SHRD_reg_mem_by_CL |
i_opcode_x86_SIDT_store_interrupt_desciptor_table_register |
i_opcode_x86_SLDT_store_local_desciptor_table_register |
i_opcode_x86_SMSW_store_machine_status_word |
i_opcode_x86_STR_store_task_register |
i_opcode_x86_UD0_undefined_instruction |
i_opcode_x86_UD1_undefined_instruction |
i_opcode_x86_UD2_undefined_instruction |
i_opcode_x86_VERR_verify_a_segment_for_reading |
i_opcode_x86_VERW_verify_a_segment_for_writing |
i_opcode_x86_WBINVD_writeback_and_invalidate_data_cache |
i_opcode_x86_WRMSR_write_to_model_specific_register |
i_opcode_x86_XADD_exchange_and_add |
0;
assign o_primary_opcode_byte_3 =
i_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size |
i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg |
i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem |
i_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id |
0;

endmodule
