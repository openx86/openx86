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
    output logic        o_opcode_MOV_reg_to_reg_mem,
    output logic        o_opcode_MOV_reg_mem_to_reg,
    output logic        o_opcode_MOV_imm_to_reg_mem,
    output logic        o_opcode_MOV_imm_to_reg_short,
    output logic        o_opcode_MOV_mem_to_acc,
    output logic        o_opcode_MOV_acc_to_mem,
    output logic        o_opcode_MOV_reg_mem_to_sreg,
    output logic        o_opcode_MOV_sreg_to_reg_mem,
    output logic        o_opcode_MOVSX,
    output logic        o_opcode_MOVZX,
    output logic        o_opcode_PUSH_reg_mem,
    output logic        o_opcode_PUSH_reg_short,
    output logic        o_opcode_PUSH_sreg_2,
    output logic        o_opcode_PUSH_sreg_3,
    output logic        o_opcode_PUSH_imm,
    output logic        o_opcode_PUSH_all,
    output logic        o_opcode_POP_reg_mem,
    output logic        o_opcode_POP_reg_short,
    output logic        o_opcode_POP_sreg_2,
    output logic        o_opcode_POP_sreg_3,
    output logic        o_opcode_POP_all,
    output logic        o_opcode_XCHG_reg_mem_with_reg,
    output logic        o_opcode_XCHG_reg_with_acc_short,
    output logic        o_opcode_IN_port_fixed,
    output logic        o_opcode_IN_port_variable,
    output logic        o_opcode_OUT_port_fixed,
    output logic        o_opcode_OUT_port_variable,
    output logic        o_opcode_LEA_load_ea_to_reg,
    output logic        o_opcode_LDS_load_ptr_to_DS,
    output logic        o_opcode_LES_load_ptr_to_ES,
    output logic        o_opcode_LFS_load_ptr_to_FS,
    output logic        o_opcode_LGS_load_ptr_to_GS,
    output logic        o_opcode_LSS_load_ptr_to_SS,
    output logic        o_opcode_CLC_clear_carry_flag,
    output logic        o_opcode_CLD_clear_direction_flag,
    output logic        o_opcode_CLI_clear_interrupt_enable_flag,
    output logic        o_opcode_CLTS_clear_task_switched_flag,
    output logic        o_opcode_CMC_complement_carry_flag,
    output logic        o_opcode_LAHF_load_ah_into_flag,
    output logic        o_opcode_POPF_pop_flags,
    output logic        o_opcode_PUSHF_push_flags,
    output logic        o_opcode_SAHF_store_ah_into_flag,
    output logic        o_opcode_STC_set_carry_flag,
    output logic        o_opcode_STD_set_direction_flag,
    output logic        o_opcode_STI_set_interrupt_enable_flag,
    output logic        o_opcode_ADD_reg_to_mem,
    output logic        o_opcode_ADD_mem_to_reg,
    output logic        o_opcode_ADD_imm_to_reg_mem,
    output logic        o_opcode_ADD_imm_to_acc,
    output logic        o_opcode_ADC_reg_to_mem,
    output logic        o_opcode_ADC_mem_to_reg,
    output logic        o_opcode_ADC_imm_to_reg_mem,
    output logic        o_opcode_ADC_imm_to_acc,
    output logic        o_opcode_INC_reg_mem,
    output logic        o_opcode_INC_reg,
    output logic        o_opcode_SUB_reg_to_mem,
    output logic        o_opcode_SUB_mem_to_reg,
    output logic        o_opcode_SUB_imm_to_reg_mem,
    output logic        o_opcode_SUB_imm_to_acc,
    output logic        o_opcode_SBB_reg_to_mem,
    output logic        o_opcode_SBB_mem_to_reg,
    output logic        o_opcode_SBB_imm_to_reg_mem,
    output logic        o_opcode_SBB_imm_to_acc,
    output logic        o_opcode_DEC_reg_mem,
    output logic        o_opcode_DEC_reg,
    output logic        o_opcode_CMP_mem_with_reg,
    output logic        o_opcode_CMP_reg_with_mem,
    output logic        o_opcode_CMP_imm_with_reg_mem,
    output logic        o_opcode_CMP_imm_with_acc,
    output logic        o_opcode_NEG_change_sign,
    output logic        o_opcode_AAA,
    output logic        o_opcode_AAS,
    output logic        o_opcode_DAA,
    output logic        o_opcode_DAS,
    output logic        o_opcode_MUL_acc_with_reg_mem,
    output logic        o_opcode_IMUL_acc_with_reg_mem,
    output logic        o_opcode_IMUL_reg_with_reg_mem,
    output logic        o_opcode_IMUL_reg_mem_with_imm_to_reg,
    output logic        o_opcode_DIV_acc_by_reg_mem,
    output logic        o_opcode_IDIV_acc_by_reg_mem,
    output logic        o_opcode_AAD,
    output logic        o_opcode_AAM,
    output logic        o_opcode_CBW,
    output logic        o_opcode_CWD,
    output logic        o_opcode_ROL_reg_mem_by_1,
    output logic        o_opcode_ROL_reg_mem_by_CL,
    output logic        o_opcode_ROL_reg_mem_by_imm,
    output logic        o_opcode_ROR_reg_mem_by_1,
    output logic        o_opcode_ROR_reg_mem_by_CL,
    output logic        o_opcode_ROR_reg_mem_by_imm,
    output logic        o_opcode_SHL_reg_mem_by_1,
    output logic        o_opcode_SHL_reg_mem_by_CL,
    output logic        o_opcode_SHL_reg_mem_by_imm,
    output logic        o_opcode_SAR_reg_mem_by_1,
    output logic        o_opcode_SAR_reg_mem_by_CL,
    output logic        o_opcode_SAR_reg_mem_by_imm,
    output logic        o_opcode_SHR_reg_mem_by_1,
    output logic        o_opcode_SHR_reg_mem_by_CL,
    output logic        o_opcode_SHR_reg_mem_by_imm,
    output logic        o_opcode_RCL_reg_mem_by_1,
    output logic        o_opcode_RCL_reg_mem_by_CL,
    output logic        o_opcode_RCL_reg_mem_by_imm,
    output logic        o_opcode_RCR_reg_mem_by_1,
    output logic        o_opcode_RCR_reg_mem_by_CL,
    output logic        o_opcode_RCR_reg_mem_by_imm,
    output logic        o_opcode_SHLD_reg_mem_by_imm,
    output logic        o_opcode_SHLD_reg_mem_by_CL,
    output logic        o_opcode_SHRD_reg_mem_by_imm,
    output logic        o_opcode_SHRD_reg_mem_by_CL,
    output logic        o_opcode_AND_reg_to_mem,
    output logic        o_opcode_AND_mem_to_reg,
    output logic        o_opcode_AND_imm_to_reg_mem,
    output logic        o_opcode_AND_imm_to_acc,
    output logic        o_opcode_TEST_reg_mem_and_reg,
    output logic        o_opcode_TEST_imm_to_reg_mem,
    output logic        o_opcode_TEST_imm_to_acc,
    output logic        o_opcode_OR_reg_to_mem,
    output logic        o_opcode_OR_mem_to_reg,
    output logic        o_opcode_OR_imm_to_reg_mem,
    output logic        o_opcode_OR_imm_to_acc,
    output logic        o_opcode_XOR_reg_to_mem,
    output logic        o_opcode_XOR_mem_to_reg,
    output logic        o_opcode_XOR_imm_to_reg_mem,
    output logic        o_opcode_XOR_imm_to_acc,
    output logic        o_opcode_NOT,
    output logic        o_opcode_CMPS,
    output logic        o_opcode_INS,
    output logic        o_opcode_LODS,
    output logic        o_opcode_MOVS,
    output logic        o_opcode_OUTS,
    output logic        o_opcode_SCAS,
    output logic        o_opcode_STOS,
    output logic        o_opcode_XLAT,
    output logic        o_opcode_REPE,
    output logic        o_opcode_REPNE,
    output logic        o_opcode_BSF,
    output logic        o_opcode_BSR,
    output logic        o_opcode_BT_reg_mem_with_imm,
    output logic        o_opcode_BT_reg_mem_with_reg,
    output logic        o_opcode_BTC_reg_mem_with_imm,
    output logic        o_opcode_BTC_reg_mem_with_reg,
    output logic        o_opcode_BTR_reg_mem_with_imm,
    output logic        o_opcode_BTR_reg_mem_with_reg,
    output logic        o_opcode_BTS_reg_mem_with_imm,
    output logic        o_opcode_BTS_reg_mem_with_reg,
    output logic        o_opcode_CALL_direct_within_segment,
    output logic        o_opcode_CALL_indirect_within_segment,
    output logic        o_opcode_CALL_direct_intersegment,
    output logic        o_opcode_CALL_indirect_intersegment,
    output logic        o_opcode_JMP_short,
    output logic        o_opcode_JMP_direct_within_segment,
    output logic        o_opcode_JMP_indirect_within_segment,
    output logic        o_opcode_JMP_direct_intersegment,
    output logic        o_opcode_JMP_indirect_intersegment,
    output logic        o_opcode_RET_within_segment,
    output logic        o_opcode_RET_within_segment_adding_imm_to_SP,
    output logic        o_opcode_RET_intersegment,
    output logic        o_opcode_RET_intersegment_adding_imm_to_SP,
    output logic        o_opcode_JO_8bit_disp,
    output logic        o_opcode_JO_full_disp,
    output logic        o_opcode_JNO_8bit_disp,
    output logic        o_opcode_JNO_full_disp,
    output logic        o_opcode_JB_8bit_disp,
    output logic        o_opcode_JB_full_disp,
    output logic        o_opcode_JNB_8bit_disp,
    output logic        o_opcode_JNB_full_disp,
    output logic        o_opcode_JE_8bit_disp,
    output logic        o_opcode_JE_full_disp,
    output logic        o_opcode_JNE_8bit_disp,
    output logic        o_opcode_JNE_full_disp,
    output logic        o_opcode_JBE_8bit_disp,
    output logic        o_opcode_JBE_full_disp,
    output logic        o_opcode_JNBE_8bit_disp,
    output logic        o_opcode_JNBE_full_disp,
    output logic        o_opcode_JS_8bit_disp,
    output logic        o_opcode_JS_full_disp,
    output logic        o_opcode_JNS_8bit_disp,
    output logic        o_opcode_JNS_full_disp,
    output logic        o_opcode_JP_8bit_disp,
    output logic        o_opcode_JP_full_disp,
    output logic        o_opcode_JNP_8bit_disp,
    output logic        o_opcode_JNP_full_disp,
    output logic        o_opcode_JL_8bit_disp,
    output logic        o_opcode_JL_full_disp,
    output logic        o_opcode_JNL_8bit_disp,
    output logic        o_opcode_JNL_full_disp,
    output logic        o_opcode_JLE_8bit_disp,
    output logic        o_opcode_JLE_full_disp,
    output logic        o_opcode_JNLE_8bit_disp,
    output logic        o_opcode_JNLE_full_disp,
    output logic        o_opcode_JCXZ,
    output logic        o_opcode_LOOP,
    output logic        o_opcode_LOOPZ,
    output logic        o_opcode_LOOPNZ,
    output logic        o_opcode_SETO,
    output logic        o_opcode_SETNO,
    output logic        o_opcode_SETB,
    output logic        o_opcode_SETNB,
    output logic        o_opcode_SETE,
    output logic        o_opcode_SETNE,
    output logic        o_opcode_SETBE,
    output logic        o_opcode_SETNBE,
    output logic        o_opcode_SETS,
    output logic        o_opcode_SETNS,
    output logic        o_opcode_SETP,
    output logic        o_opcode_SETNP,
    output logic        o_opcode_SETL,
    output logic        o_opcode_SETNL,
    output logic        o_opcode_SETLE,
    output logic        o_opcode_SETNLE,
    output logic        o_opcode_ENTER,
    output logic        o_opcode_LEAVE,
    output logic        o_opcode_INT_type_3,
    output logic        o_opcode_INT_type_specified,
    output logic        o_opcode_INTO,
    output logic        o_opcode_BOUND,
    output logic        o_opcode_IRET,
    output logic        o_opcode_HLT,
    output logic        o_opcode_MOV_CR0_CR2_CR3_from_reg,
    output logic        o_opcode_MOV_reg_from_CR0_3,
    output logic        o_opcode_MOV_DR0_7_from_reg,
    output logic        o_opcode_MOV_reg_from_DR0_7,
    output logic        o_opcode_MOV_TR6_7_from_reg,
    output logic        o_opcode_MOV_reg_from_TR6_7,
    output logic        o_opcode_NOP,
    output logic        o_opcode_WAIT,
    output logic        o_opcode_processor_extension_escape,
    output logic        o_opcode_ARPL,
    output logic        o_opcode_LAR,
    output logic        o_opcode_LGDT,
    output logic        o_opcode_LIDT,
    output logic        o_opcode_LLDT,
    output logic        o_opcode_LMSW,
    output logic        o_opcode_LSL,
    output logic        o_opcode_LTR,
    output logic        o_opcode_SGDT,
    output logic        o_opcode_SIDT,
    output logic        o_opcode_SLDT,
    output logic        o_opcode_SMSW,
    output logic        o_opcode_STR,
    output logic        o_opcode_VERR,
    output logic        o_opcode_VERW,
    output logic        o_prefix_lock_bus,
    output logic        o_prefix_repeat_not_equal,
    output logic        o_prefix_repeat_equal,
    output logic        o_prefix_bound,
    output logic        o_prefix_hint_branch_not_taken,
    output logic        o_prefix_hint_branch_taken,
    output logic        o_field_gen_reg_is_present,
    output logic [ 2:0] o_field_gen_reg_index,
    output logic [ 2:0] o_segment_reg_index,
    output logic [ 1:0] o_scale_factor,
    output logic        o_base_reg_is_present,
    output logic [ 2:0] o_base_reg_index,
    output logic        o_index_reg_is_present,
    output logic [ 2:0] o_index_reg_index,
    output logic        o_mod_rm_gen_reg_is_present,
    output logic [ 2:0] o_mod_rm_gen_reg_index,
    output logic [ 2:0] o_mod_rm_gen_reg_bit_width,
    output logic        o_displacement_is_present,
    output logic [31:0] o_displacement,
    output logic        o_immediate_is_present,
    output logic [31:0] o_immediate,
    output logic [ 4:0] o_bytes_consumed,
    output logic        o_error
);

logic [ 7:0] stage_prefix_i_instruction [0:3];
logic        stage_prefix_o_group_1_lock_bus;
logic        stage_prefix_o_group_1_repeat_not_equal;
logic        stage_prefix_o_group_1_repeat_equal;
logic        stage_prefix_o_group_1_bound;
logic        stage_prefix_o_group_2_segment_override;
logic        stage_prefix_o_group_2_hint_branch_not_taken;
logic        stage_prefix_o_group_2_hint_branch_taken;
logic        stage_prefix_o_group_3_operand_size;
logic        stage_prefix_o_group_4_address_size;
logic        stage_prefix_o_group_1_is_present;
logic        stage_prefix_o_group_2_is_present;
logic        stage_prefix_o_group_3_is_present;
logic        stage_prefix_o_group_4_is_present;
logic [ 2:0] stage_prefix_o_segment_override_index;
logic        stage_prefix_o_error;
logic [ 2:0] stage_prefix_o_bytes_consumed;

logic [ 7:0] stage_opcode_i_instruction [0:2];

logic [ 7:0] stage_field_i_instruction [0:2];
logic        stage_field_o_s_is_present;
logic        stage_field_o_s;
logic        stage_field_o_w_is_present;
logic        stage_field_o_w;
logic        stage_field_o_gen_reg_is_present;
logic [ 2:0] stage_field_o_gen_reg_index;
logic        stage_field_o_seg_reg_is_present;
logic [ 2:0] stage_field_o_seg_reg_index;
logic        stage_field_o_mod_rm_is_present;
logic [ 1:0] stage_field_o_mod;
logic [ 2:0] stage_field_o_rm;
logic        stage_field_o_displacement_is_present;
logic        stage_field_o_displacement_size_default;
logic        stage_field_o_displacement_size_8;
logic        stage_field_o_displacement_size_16;
logic        stage_field_o_immediate_is_present;
logic        stage_field_o_immediate_size_default;
logic        stage_field_o_immediate_size_8;
logic        stage_field_o_unsigned_full_offset_or_selector_is_present;
logic [ 2:0] stage_field_o_bytes_consumed;
logic        stage_field_o_error;

logic [ 1:0] stage_mod_rm_i_mod;
logic [ 2:0] stage_mod_rm_i_rm;
logic        stage_mod_rm_i_w_is_present;
logic        stage_mod_rm_i_w;
logic        stage_mod_rm_i_default_operand_size;
logic [ 2:0] stage_mod_rm_o_segment_reg_index;
logic        stage_mod_rm_o_base_reg_is_present;
logic [ 2:0] stage_mod_rm_o_base_reg_index;
logic        stage_mod_rm_o_index_reg_is_present;
logic [ 2:0] stage_mod_rm_o_index_reg_index;
logic        stage_mod_rm_o_gen_reg_is_present;
logic [ 2:0] stage_mod_rm_o_gen_reg_index;
logic [ 2:0] stage_mod_rm_o_gen_reg_bit_width;
logic        stage_mod_rm_o_displacement_is_present;
logic        stage_mod_rm_o_displacement_size_8;
logic        stage_mod_rm_o_displacement_size_16;
logic        stage_mod_rm_o_displacement_size_32;
logic        stage_mod_rm_o_sib_is_present;

logic [ 7:0] stage_sib_i_sib;
logic [ 1:0] stage_sib_i_mod;
logic [ 1:0] stage_sib_o_scale_factor;
logic        stage_sib_o_index_reg_is_present;
logic [ 2:0] stage_sib_o_index_reg_index;
logic        stage_sib_o_base_reg_is_present;
logic [ 2:0] stage_sib_o_base_reg_index;
logic        stage_sib_o_displacement_is_present;
logic [ 3:0] stage_sib_o_displacement_length;
logic        stage_sib_o_effecitve_address_undefined;

logic [ 7:0] stage_disp_imm_i_instruction [0:7];
logic        stage_disp_imm_i_displacement_is_present;
logic [ 3:0] stage_disp_imm_i_displacement_length;
logic        stage_disp_imm_i_immediate_is_present;
logic [ 3:0] stage_disp_imm_i_immediate_length;
logic [31:0] stage_disp_imm_o_displacement;
logic [31:0] stage_disp_imm_o_immediate;
logic [ 3:0] stage_disp_imm_o_bytes_consumed;

assign stage_prefix_i_instruction = i_instruction [0:3];

wire   default_operand_size = stage_prefix_o_group_3_operand_size ? ~i_default_operand_size : i_default_operand_size;

always_comb begin
    case (stage_prefix_o_bytes_consumed)
        1      : stage_opcode_i_instruction <= i_instruction[0+1:2+1];
        2      : stage_opcode_i_instruction <= i_instruction[0+2:2+2];
        3      : stage_opcode_i_instruction <= i_instruction[0+3:2+3];
        4      : stage_opcode_i_instruction <= i_instruction[0+4:2+4];
        default: stage_opcode_i_instruction <= i_instruction[0+0:2+0];
    endcase
end

assign stage_field_i_instruction = stage_opcode_i_instruction;

logic [7:0] mod_rm;
always_comb begin
    case (stage_field_o_bytes_consumed)
        1      : mod_rm <= i_instruction[0+0];
        2      : mod_rm <= i_instruction[0+1];
        3      : mod_rm <= i_instruction[0+2];
        4      : mod_rm <= i_instruction[0+3];
        default: mod_rm <= i_instruction[0+0];
    endcase
end
assign stage_mod_rm_i_mod = mod_rm[7:6];
assign stage_mod_rm_i_rm  = mod_rm[2:0];
assign stage_mod_rm_i_w_is_present = stage_field_o_w_is_present;
assign stage_mod_rm_i_w = stage_field_o_w;
assign stage_mod_rm_i_default_operand_size = default_operand_size;

wire  [ 3:0] bytes_offset_mod_rm = stage_prefix_o_bytes_consumed + stage_field_o_bytes_consumed;
// wire  [ 3:0] bytes_offset_sib    = bytes_offset_mod_rm + 1;
always_comb begin
    unique case (bytes_offset_mod_rm)
        1: begin stage_sib_i_sib <= i_instruction[2]; stage_sib_i_mod <= i_instruction[1][7:6]; end
        2: begin stage_sib_i_sib <= i_instruction[3]; stage_sib_i_mod <= i_instruction[2][7:6]; end
        3: begin stage_sib_i_sib <= i_instruction[4]; stage_sib_i_mod <= i_instruction[3][7:6]; end
        4: begin stage_sib_i_sib <= i_instruction[5]; stage_sib_i_mod <= i_instruction[4][7:6]; end
        default: begin stage_sib_i_sib <= 0; stage_sib_i_mod <= 0; end
    endcase
end

always_comb begin
    case (stage_field_o_bytes_consumed)
        1      : stage_disp_imm_i_instruction <= stage_sib_i_sib ? i_instruction[0+1+1:7+1+1] : i_instruction[0+1:7+1];
        2      : stage_disp_imm_i_instruction <= stage_sib_i_sib ? i_instruction[0+2+1:7+2+1] : i_instruction[0+2:7+2];
        3      : stage_disp_imm_i_instruction <= stage_sib_i_sib ? i_instruction[0+3+1:7+3+1] : i_instruction[0+3:7+3];
        4      : stage_disp_imm_i_instruction <= stage_sib_i_sib ? i_instruction[0+4+1:7+4+1] : i_instruction[0+4:7+4];
        default: stage_disp_imm_i_instruction <= stage_sib_i_sib ? i_instruction[0+0+1:7+0+1] : i_instruction[0+0:7+0];
    endcase
end
always_comb begin
    if (stage_field_o_displacement_is_present) begin
        stage_disp_imm_i_displacement_is_present <= stage_field_o_displacement_is_present;
        stage_disp_imm_i_displacement_length <= stage_field_o_displacement_length;
    end else if (stage_mod_rm_o_displacement_is_present) begin
        if (stage_sib_o_displacement_is_present) begin
            stage_disp_imm_i_displacement_is_present <= stage_sib_o_displacement_is_present;
            stage_disp_imm_i_displacement_length <= stage_sib_o_displacement_length;
        end else begin
            stage_disp_imm_i_displacement_is_present <= stage_mod_rm_o_displacement_is_present;
            stage_disp_imm_i_displacement_length <= stage_mod_rm_o_displacement_length;
        end
    end else begin
        stage_disp_imm_i_displacement_is_present <= 0;
        stage_disp_imm_i_displacement_length <= 0;
    end
end

assign stage_disp_imm_i_immediate_is_present = stage_field_o_immediate_is_present;
assign stage_disp_imm_i_immediate_length = stage_field_o_immediate_length;


// port

assign o_prefix_lock_bus              = stage_prefix_o_group_1_lock_bus;
assign o_prefix_repeat_not_equal      = stage_prefix_o_group_1_repeat_not_equal;
assign o_prefix_repeat_equal          = stage_prefix_o_group_1_repeat_equal;
assign o_prefix_bound                 = stage_prefix_o_group_1_bound;
assign o_prefix_hint_branch_not_taken = stage_prefix_o_group_2_hint_branch_not_taken;
assign o_prefix_hint_branch_taken     = stage_prefix_o_group_2_hint_branch_taken;

assign o_field_gen_reg_is_present = stage_field_o_gen_reg_is_present;
assign o_field_gen_reg_index = stage_field_o_gen_reg_index;

wire segment_reg_from_prefix = stage_prefix_o_group_2_segment_override;
wire segment_reg_from_opcode = stage_field_o_seg_reg_is_present;
wire segment_reg_from_mod_rm = stage_field_o_mod_rm_is_present;
// assign o_segment_reg_used = segment_reg_from_prefix | segment_reg_from_opcode | segment_reg_from_mod_rm;
always_comb begin
    if (segment_reg_from_prefix) begin
        o_segment_reg_index <= stage_prefix_o_segment_override_index;
    end else if (segment_reg_from_opcode) begin
        o_segment_reg_index <= stage_field_o_seg_reg_index;
    end else if (segment_reg_from_mod_rm) begin
        o_segment_reg_index <= stage_mod_rm_o_segment_reg_index;
    end else begin
        o_segment_reg_index <= 3'b111;
    end
end

assign o_scale_factor = stage_sib_o_scale_factor;

assign o_base_reg_is_present = stage_mod_rm_o_sib_is_present ? stage_sib_o_base_reg_is_present : stage_mod_rm_o_base_reg_is_present;
assign o_base_reg_index = stage_mod_rm_o_sib_is_present ? stage_sib_o_base_reg_index : stage_mod_rm_o_base_reg_index;

assign o_index_reg_is_present = stage_mod_rm_o_sib_is_present ? stage_sib_o_index_reg_is_present : stage_mod_rm_o_index_reg_is_present;
assign o_index_reg_index = stage_mod_rm_o_sib_is_present ? stage_sib_o_index_reg_index : stage_mod_rm_o_index_reg_index;

assign o_mod_rm_gen_reg_is_present = stage_mod_rm_o_gen_reg_is_present;
assign o_mod_rm_gen_reg_index = stage_mod_rm_o_gen_reg_index;
assign o_mod_rm_gen_reg_bit_width = stage_mod_rm_o_gen_reg_bit_width;

assign o_displacement_is_present = stage_mod_rm_o_sib_is_present ? stage_sib_o_displacement_is_present : stage_mod_rm_o_displacement_is_present;
assign o_displacement = stage_disp_imm_o_displacement;

assign o_immediate_is_present = stage_field_o_immediate_is_present | stage_disp_imm_i_immediate_is_present;
assign o_immediate = stage_disp_imm_o_immediate;

assign o_bytes_consumed =
stage_prefix_o_bytes_consumed +
stage_field_o_bytes_consumed +
stage_mod_rm_o_sib_is_present +
stage_disp_imm_o_bytes_consumed +
0;

assign o_error = stage_prefix_o_error | stage_field_o_error;


decode_stage_prefix decode_stage_1_prefix_in_decode (
    .i_instruction                   ( stage_prefix_i_instruction ),
    .o_group_1_lock_bus              ( stage_prefix_o_group_1_lock_bus ),
    .o_group_1_repeat_not_equal      ( stage_prefix_o_group_1_repeat_not_equal ),
    .o_group_1_repeat_equal          ( stage_prefix_o_group_1_repeat_equal ),
    .o_group_1_bound                 ( stage_prefix_o_group_1_bound ),
    .o_group_2_segment_override      ( stage_prefix_o_group_2_segment_override ),
    .o_group_2_hint_branch_not_taken ( stage_prefix_o_group_2_hint_branch_not_taken ),
    .o_group_2_hint_branch_taken     ( stage_prefix_o_group_2_hint_branch_taken ),
    .o_group_3_operand_size          ( stage_prefix_o_group_3_operand_size ),
    .o_group_4_address_size          ( stage_prefix_o_group_4_address_size ),
    .o_group_1_is_present            ( stage_prefix_o_group_1_is_present ),
    .o_group_2_is_present            ( stage_prefix_o_group_2_is_present ),
    .o_group_3_is_present            ( stage_prefix_o_group_3_is_present ),
    .o_group_4_is_present            ( stage_prefix_o_group_4_is_present ),
    .o_segment_override_index        ( stage_prefix_o_segment_override_index ),
    .o_error                         ( stage_prefix_o_error ),
    .o_bytes_consumed                ( stage_prefix_o_bytes_consumed )
);

decode_stage_opcode decode_stage_2_opcode_instance_in_decode (
    .i_instruction                                ( stage_opcode_i_instruction ),
    .o_opcode_MOV_reg_to_reg_mem                  ( o_opcode_MOV_reg_to_reg_mem ),
    .o_opcode_MOV_reg_mem_to_reg                  ( o_opcode_MOV_reg_mem_to_reg ),
    .o_opcode_MOV_imm_to_reg_mem                  ( o_opcode_MOV_imm_to_reg_mem ),
    .o_opcode_MOV_imm_to_reg_short                ( o_opcode_MOV_imm_to_reg_short ),
    .o_opcode_MOV_mem_to_acc                      ( o_opcode_MOV_mem_to_acc ),
    .o_opcode_MOV_acc_to_mem                      ( o_opcode_MOV_acc_to_mem ),
    .o_opcode_MOV_reg_mem_to_sreg                 ( o_opcode_MOV_reg_mem_to_sreg ),
    .o_opcode_MOV_sreg_to_reg_mem                 ( o_opcode_MOV_sreg_to_reg_mem ),
    .o_opcode_MOVSX                               ( o_opcode_MOVSX ),
    .o_opcode_MOVZX                               ( o_opcode_MOVZX ),
    .o_opcode_PUSH_reg_mem                        ( o_opcode_PUSH_reg_mem ),
    .o_opcode_PUSH_reg_short                      ( o_opcode_PUSH_reg_short ),
    .o_opcode_PUSH_sreg_2                         ( o_opcode_PUSH_sreg_2 ),
    .o_opcode_PUSH_sreg_3                         ( o_opcode_PUSH_sreg_3 ),
    .o_opcode_PUSH_imm                            ( o_opcode_PUSH_imm ),
    .o_opcode_PUSH_all                            ( o_opcode_PUSH_all ),
    .o_opcode_POP_reg_mem                         ( o_opcode_POP_reg_mem ),
    .o_opcode_POP_reg_short                       ( o_opcode_POP_reg_short ),
    .o_opcode_POP_sreg_2                          ( o_opcode_POP_sreg_2 ),
    .o_opcode_POP_sreg_3                          ( o_opcode_POP_sreg_3 ),
    .o_opcode_POP_all                             ( o_opcode_POP_all ),
    .o_opcode_XCHG_reg_mem_with_reg               ( o_opcode_XCHG_reg_mem_with_reg ),
    .o_opcode_XCHG_reg_with_acc_short             ( o_opcode_XCHG_reg_with_acc_short ),
    .o_opcode_IN_port_fixed                       ( o_opcode_IN_port_fixed ),
    .o_opcode_IN_port_variable                    ( o_opcode_IN_port_variable ),
    .o_opcode_OUT_port_fixed                      ( o_opcode_OUT_port_fixed ),
    .o_opcode_OUT_port_variable                   ( o_opcode_OUT_port_variable ),
    .o_opcode_LEA_load_ea_to_reg                  ( o_opcode_LEA_load_ea_to_reg ),
    .o_opcode_LDS_load_ptr_to_DS                  ( o_opcode_LDS_load_ptr_to_DS ),
    .o_opcode_LES_load_ptr_to_ES                  ( o_opcode_LES_load_ptr_to_ES ),
    .o_opcode_LFS_load_ptr_to_FS                  ( o_opcode_LFS_load_ptr_to_FS ),
    .o_opcode_LGS_load_ptr_to_GS                  ( o_opcode_LGS_load_ptr_to_GS ),
    .o_opcode_LSS_load_ptr_to_SS                  ( o_opcode_LSS_load_ptr_to_SS ),
    .o_opcode_CLC_clear_carry_flag                ( o_opcode_CLC_clear_carry_flag ),
    .o_opcode_CLD_clear_direction_flag            ( o_opcode_CLD_clear_direction_flag ),
    .o_opcode_CLI_clear_interrupt_enable_flag     ( o_opcode_CLI_clear_interrupt_enable_flag ),
    .o_opcode_CLTS_clear_task_switched_flag       ( o_opcode_CLTS_clear_task_switched_flag ),
    .o_opcode_CMC_complement_carry_flag           ( o_opcode_CMC_complement_carry_flag ),
    .o_opcode_LAHF_load_ah_into_flag              ( o_opcode_LAHF_load_ah_into_flag ),
    .o_opcode_POPF_pop_flags                      ( o_opcode_POPF_pop_flags ),
    .o_opcode_PUSHF_push_flags                    ( o_opcode_PUSHF_push_flags ),
    .o_opcode_SAHF_store_ah_into_flag             ( o_opcode_SAHF_store_ah_into_flag ),
    .o_opcode_STC_set_carry_flag                  ( o_opcode_STC_set_carry_flag ),
    .o_opcode_STD_set_direction_flag              ( o_opcode_STD_set_direction_flag ),
    .o_opcode_STI_set_interrupt_enable_flag       ( o_opcode_STI_set_interrupt_enable_flag ),
    .o_opcode_ADD_reg_to_mem                      ( o_opcode_ADD_reg_to_mem ),
    .o_opcode_ADD_mem_to_reg                      ( o_opcode_ADD_mem_to_reg ),
    .o_opcode_ADD_imm_to_reg_mem                  ( o_opcode_ADD_imm_to_reg_mem ),
    .o_opcode_ADD_imm_to_acc                      ( o_opcode_ADD_imm_to_acc ),
    .o_opcode_ADC_reg_to_mem                      ( o_opcode_ADC_reg_to_mem ),
    .o_opcode_ADC_mem_to_reg                      ( o_opcode_ADC_mem_to_reg ),
    .o_opcode_ADC_imm_to_reg_mem                  ( o_opcode_ADC_imm_to_reg_mem ),
    .o_opcode_ADC_imm_to_acc                      ( o_opcode_ADC_imm_to_acc ),
    .o_opcode_INC_reg_mem                         ( o_opcode_INC_reg_mem ),
    .o_opcode_INC_reg                             ( o_opcode_INC_reg ),
    .o_opcode_SUB_reg_to_mem                      ( o_opcode_SUB_reg_to_mem ),
    .o_opcode_SUB_mem_to_reg                      ( o_opcode_SUB_mem_to_reg ),
    .o_opcode_SUB_imm_to_reg_mem                  ( o_opcode_SUB_imm_to_reg_mem ),
    .o_opcode_SUB_imm_to_acc                      ( o_opcode_SUB_imm_to_acc ),
    .o_opcode_SBB_reg_to_mem                      ( o_opcode_SBB_reg_to_mem ),
    .o_opcode_SBB_mem_to_reg                      ( o_opcode_SBB_mem_to_reg ),
    .o_opcode_SBB_imm_to_reg_mem                  ( o_opcode_SBB_imm_to_reg_mem ),
    .o_opcode_SBB_imm_to_acc                      ( o_opcode_SBB_imm_to_acc ),
    .o_opcode_DEC_reg_mem                         ( o_opcode_DEC_reg_mem ),
    .o_opcode_DEC_reg                             ( o_opcode_DEC_reg ),
    .o_opcode_CMP_mem_with_reg                    ( o_opcode_CMP_mem_with_reg ),
    .o_opcode_CMP_reg_with_mem                    ( o_opcode_CMP_reg_with_mem ),
    .o_opcode_CMP_imm_with_reg_mem                ( o_opcode_CMP_imm_with_reg_mem ),
    .o_opcode_CMP_imm_with_acc                    ( o_opcode_CMP_imm_with_acc ),
    .o_opcode_NEG_change_sign                     ( o_opcode_NEG_change_sign ),
    .o_opcode_AAA                                 ( o_opcode_AAA ),
    .o_opcode_AAS                                 ( o_opcode_AAS ),
    .o_opcode_DAA                                 ( o_opcode_DAA ),
    .o_opcode_DAS                                 ( o_opcode_DAS ),
    .o_opcode_MUL_acc_with_reg_mem                ( o_opcode_MUL_acc_with_reg_mem ),
    .o_opcode_IMUL_acc_with_reg_mem               ( o_opcode_IMUL_acc_with_reg_mem ),
    .o_opcode_IMUL_reg_with_reg_mem               ( o_opcode_IMUL_reg_with_reg_mem ),
    .o_opcode_IMUL_reg_mem_with_imm_to_reg        ( o_opcode_IMUL_reg_mem_with_imm_to_reg ),
    .o_opcode_DIV_acc_by_reg_mem                  ( o_opcode_DIV_acc_by_reg_mem ),
    .o_opcode_IDIV_acc_by_reg_mem                 ( o_opcode_IDIV_acc_by_reg_mem ),
    .o_opcode_AAD                                 ( o_opcode_AAD ),
    .o_opcode_AAM                                 ( o_opcode_AAM ),
    .o_opcode_CBW                                 ( o_opcode_CBW ),
    .o_opcode_CWD                                 ( o_opcode_CWD ),
    .o_opcode_ROL_reg_mem_by_1                    ( o_opcode_ROL_reg_mem_by_1 ),
    .o_opcode_ROL_reg_mem_by_CL                   ( o_opcode_ROL_reg_mem_by_CL ),
    .o_opcode_ROL_reg_mem_by_imm                  ( o_opcode_ROL_reg_mem_by_imm ),
    .o_opcode_ROR_reg_mem_by_1                    ( o_opcode_ROR_reg_mem_by_1 ),
    .o_opcode_ROR_reg_mem_by_CL                   ( o_opcode_ROR_reg_mem_by_CL ),
    .o_opcode_ROR_reg_mem_by_imm                  ( o_opcode_ROR_reg_mem_by_imm ),
    .o_opcode_SHL_reg_mem_by_1                    ( o_opcode_SHL_reg_mem_by_1 ),
    .o_opcode_SHL_reg_mem_by_CL                   ( o_opcode_SHL_reg_mem_by_CL ),
    .o_opcode_SHL_reg_mem_by_imm                  ( o_opcode_SHL_reg_mem_by_imm ),
    .o_opcode_SAR_reg_mem_by_1                    ( o_opcode_SAR_reg_mem_by_1 ),
    .o_opcode_SAR_reg_mem_by_CL                   ( o_opcode_SAR_reg_mem_by_CL ),
    .o_opcode_SAR_reg_mem_by_imm                  ( o_opcode_SAR_reg_mem_by_imm ),
    .o_opcode_SHR_reg_mem_by_1                    ( o_opcode_SHR_reg_mem_by_1 ),
    .o_opcode_SHR_reg_mem_by_CL                   ( o_opcode_SHR_reg_mem_by_CL ),
    .o_opcode_SHR_reg_mem_by_imm                  ( o_opcode_SHR_reg_mem_by_imm ),
    .o_opcode_RCL_reg_mem_by_1                    ( o_opcode_RCL_reg_mem_by_1 ),
    .o_opcode_RCL_reg_mem_by_CL                   ( o_opcode_RCL_reg_mem_by_CL ),
    .o_opcode_RCL_reg_mem_by_imm                  ( o_opcode_RCL_reg_mem_by_imm ),
    .o_opcode_RCR_reg_mem_by_1                    ( o_opcode_RCR_reg_mem_by_1 ),
    .o_opcode_RCR_reg_mem_by_CL                   ( o_opcode_RCR_reg_mem_by_CL ),
    .o_opcode_RCR_reg_mem_by_imm                  ( o_opcode_RCR_reg_mem_by_imm ),
    .o_opcode_SHLD_reg_mem_by_imm                 ( o_opcode_SHLD_reg_mem_by_imm ),
    .o_opcode_SHLD_reg_mem_by_CL                  ( o_opcode_SHLD_reg_mem_by_CL ),
    .o_opcode_SHRD_reg_mem_by_imm                 ( o_opcode_SHRD_reg_mem_by_imm ),
    .o_opcode_SHRD_reg_mem_by_CL                  ( o_opcode_SHRD_reg_mem_by_CL ),
    .o_opcode_AND_reg_to_mem                      ( o_opcode_AND_reg_to_mem ),
    .o_opcode_AND_mem_to_reg                      ( o_opcode_AND_mem_to_reg ),
    .o_opcode_AND_imm_to_reg_mem                  ( o_opcode_AND_imm_to_reg_mem ),
    .o_opcode_AND_imm_to_acc                      ( o_opcode_AND_imm_to_acc ),
    .o_opcode_TEST_reg_mem_and_reg                ( o_opcode_TEST_reg_mem_and_reg ),
    .o_opcode_TEST_imm_to_reg_mem                 ( o_opcode_TEST_imm_to_reg_mem ),
    .o_opcode_TEST_imm_to_acc                     ( o_opcode_TEST_imm_to_acc ),
    .o_opcode_OR_reg_to_mem                       ( o_opcode_OR_reg_to_mem ),
    .o_opcode_OR_mem_to_reg                       ( o_opcode_OR_mem_to_reg ),
    .o_opcode_OR_imm_to_reg_mem                   ( o_opcode_OR_imm_to_reg_mem ),
    .o_opcode_OR_imm_to_acc                       ( o_opcode_OR_imm_to_acc ),
    .o_opcode_XOR_reg_to_mem                      ( o_opcode_XOR_reg_to_mem ),
    .o_opcode_XOR_mem_to_reg                      ( o_opcode_XOR_mem_to_reg ),
    .o_opcode_XOR_imm_to_reg_mem                  ( o_opcode_XOR_imm_to_reg_mem ),
    .o_opcode_XOR_imm_to_acc                      ( o_opcode_XOR_imm_to_acc ),
    .o_opcode_NOT                                 ( o_opcode_NOT ),
    .o_opcode_CMPS                                ( o_opcode_CMPS ),
    .o_opcode_INS                                 ( o_opcode_INS ),
    .o_opcode_LODS                                ( o_opcode_LODS ),
    .o_opcode_MOVS                                ( o_opcode_MOVS ),
    .o_opcode_OUTS                                ( o_opcode_OUTS ),
    .o_opcode_SCAS                                ( o_opcode_SCAS ),
    .o_opcode_STOS                                ( o_opcode_STOS ),
    .o_opcode_XLAT                                ( o_opcode_XLAT ),
    .o_opcode_REPE                                ( o_opcode_REPE ),
    .o_opcode_REPNE                               ( o_opcode_REPNE ),
    .o_opcode_BSF                                 ( o_opcode_BSF ),
    .o_opcode_BSR                                 ( o_opcode_BSR ),
    .o_opcode_BT_reg_mem_with_imm                 ( o_opcode_BT_reg_mem_with_imm ),
    .o_opcode_BT_reg_mem_with_reg                 ( o_opcode_BT_reg_mem_with_reg ),
    .o_opcode_BTC_reg_mem_with_imm                ( o_opcode_BTC_reg_mem_with_imm ),
    .o_opcode_BTC_reg_mem_with_reg                ( o_opcode_BTC_reg_mem_with_reg ),
    .o_opcode_BTR_reg_mem_with_imm                ( o_opcode_BTR_reg_mem_with_imm ),
    .o_opcode_BTR_reg_mem_with_reg                ( o_opcode_BTR_reg_mem_with_reg ),
    .o_opcode_BTS_reg_mem_with_imm                ( o_opcode_BTS_reg_mem_with_imm ),
    .o_opcode_BTS_reg_mem_with_reg                ( o_opcode_BTS_reg_mem_with_reg ),
    .o_opcode_CALL_direct_within_segment          ( o_opcode_CALL_direct_within_segment ),
    .o_opcode_CALL_indirect_within_segment        ( o_opcode_CALL_indirect_within_segment ),
    .o_opcode_CALL_direct_intersegment            ( o_opcode_CALL_direct_intersegment ),
    .o_opcode_CALL_indirect_intersegment          ( o_opcode_CALL_indirect_intersegment ),
    .o_opcode_JMP_short                           ( o_opcode_JMP_short ),
    .o_opcode_JMP_direct_within_segment           ( o_opcode_JMP_direct_within_segment ),
    .o_opcode_JMP_indirect_within_segment         ( o_opcode_JMP_indirect_within_segment ),
    .o_opcode_JMP_direct_intersegment             ( o_opcode_JMP_direct_intersegment ),
    .o_opcode_JMP_indirect_intersegment           ( o_opcode_JMP_indirect_intersegment ),
    .o_opcode_RET_within_segment                  ( o_opcode_RET_within_segment ),
    .o_opcode_RET_within_segment_adding_imm_to_SP ( o_opcode_RET_within_segment_adding_imm_to_SP ),
    .o_opcode_RET_intersegment                    ( o_opcode_RET_intersegment ),
    .o_opcode_RET_intersegment_adding_imm_to_SP   ( o_opcode_RET_intersegment_adding_imm_to_SP ),
    .o_opcode_JO_8bit_disp                        ( o_opcode_JO_8bit_disp ),
    .o_opcode_JO_full_disp                        ( o_opcode_JO_full_disp ),
    .o_opcode_JNO_8bit_disp                       ( o_opcode_JNO_8bit_disp ),
    .o_opcode_JNO_full_disp                       ( o_opcode_JNO_full_disp ),
    .o_opcode_JB_8bit_disp                        ( o_opcode_JB_8bit_disp ),
    .o_opcode_JB_full_disp                        ( o_opcode_JB_full_disp ),
    .o_opcode_JNB_8bit_disp                       ( o_opcode_JNB_8bit_disp ),
    .o_opcode_JNB_full_disp                       ( o_opcode_JNB_full_disp ),
    .o_opcode_JE_8bit_disp                        ( o_opcode_JE_8bit_disp ),
    .o_opcode_JE_full_disp                        ( o_opcode_JE_full_disp ),
    .o_opcode_JNE_8bit_disp                       ( o_opcode_JNE_8bit_disp ),
    .o_opcode_JNE_full_disp                       ( o_opcode_JNE_full_disp ),
    .o_opcode_JBE_8bit_disp                       ( o_opcode_JBE_8bit_disp ),
    .o_opcode_JBE_full_disp                       ( o_opcode_JBE_full_disp ),
    .o_opcode_JNBE_8bit_disp                      ( o_opcode_JNBE_8bit_disp ),
    .o_opcode_JNBE_full_disp                      ( o_opcode_JNBE_full_disp ),
    .o_opcode_JS_8bit_disp                        ( o_opcode_JS_8bit_disp ),
    .o_opcode_JS_full_disp                        ( o_opcode_JS_full_disp ),
    .o_opcode_JNS_8bit_disp                       ( o_opcode_JNS_8bit_disp ),
    .o_opcode_JNS_full_disp                       ( o_opcode_JNS_full_disp ),
    .o_opcode_JP_8bit_disp                        ( o_opcode_JP_8bit_disp ),
    .o_opcode_JP_full_disp                        ( o_opcode_JP_full_disp ),
    .o_opcode_JNP_8bit_disp                       ( o_opcode_JNP_8bit_disp ),
    .o_opcode_JNP_full_disp                       ( o_opcode_JNP_full_disp ),
    .o_opcode_JL_8bit_disp                        ( o_opcode_JL_8bit_disp ),
    .o_opcode_JL_full_disp                        ( o_opcode_JL_full_disp ),
    .o_opcode_JNL_8bit_disp                       ( o_opcode_JNL_8bit_disp ),
    .o_opcode_JNL_full_disp                       ( o_opcode_JNL_full_disp ),
    .o_opcode_JLE_8bit_disp                       ( o_opcode_JLE_8bit_disp ),
    .o_opcode_JLE_full_disp                       ( o_opcode_JLE_full_disp ),
    .o_opcode_JNLE_8bit_disp                      ( o_opcode_JNLE_8bit_disp ),
    .o_opcode_JNLE_full_disp                      ( o_opcode_JNLE_full_disp ),
    .o_opcode_JCXZ                                ( o_opcode_JCXZ ),
    .o_opcode_LOOP                                ( o_opcode_LOOP ),
    .o_opcode_LOOPZ                               ( o_opcode_LOOPZ ),
    .o_opcode_LOOPNZ                              ( o_opcode_LOOPNZ ),
    .o_opcode_SETO                                ( o_opcode_SETO ),
    .o_opcode_SETNO                               ( o_opcode_SETNO ),
    .o_opcode_SETB                                ( o_opcode_SETB ),
    .o_opcode_SETNB                               ( o_opcode_SETNB ),
    .o_opcode_SETE                                ( o_opcode_SETE ),
    .o_opcode_SETNE                               ( o_opcode_SETNE ),
    .o_opcode_SETBE                               ( o_opcode_SETBE ),
    .o_opcode_SETNBE                              ( o_opcode_SETNBE ),
    .o_opcode_SETS                                ( o_opcode_SETS ),
    .o_opcode_SETNS                               ( o_opcode_SETNS ),
    .o_opcode_SETP                                ( o_opcode_SETP ),
    .o_opcode_SETNP                               ( o_opcode_SETNP ),
    .o_opcode_SETL                                ( o_opcode_SETL ),
    .o_opcode_SETNL                               ( o_opcode_SETNL ),
    .o_opcode_SETLE                               ( o_opcode_SETLE ),
    .o_opcode_SETNLE                              ( o_opcode_SETNLE ),
    .o_opcode_ENTER                               ( o_opcode_ENTER ),
    .o_opcode_LEAVE                               ( o_opcode_LEAVE ),
    .o_opcode_INT_type_3                          ( o_opcode_INT_type_3 ),
    .o_opcode_INT_type_specified                  ( o_opcode_INT_type_specified ),
    .o_opcode_INTO                                ( o_opcode_INTO ),
    .o_opcode_BOUND                               ( o_opcode_BOUND ),
    .o_opcode_IRET                                ( o_opcode_IRET ),
    .o_opcode_HLT                                 ( o_opcode_HLT ),
    .o_opcode_MOV_CR0_CR2_CR3_from_reg            ( o_opcode_MOV_CR0_CR2_CR3_from_reg ),
    .o_opcode_MOV_reg_from_CR0_3                  ( o_opcode_MOV_reg_from_CR0_3 ),
    .o_opcode_MOV_DR0_7_from_reg                  ( o_opcode_MOV_DR0_7_from_reg ),
    .o_opcode_MOV_reg_from_DR0_7                  ( o_opcode_MOV_reg_from_DR0_7 ),
    .o_opcode_MOV_TR6_7_from_reg                  ( o_opcode_MOV_TR6_7_from_reg ),
    .o_opcode_MOV_reg_from_TR6_7                  ( o_opcode_MOV_reg_from_TR6_7 ),
    .o_opcode_NOP                                 ( o_opcode_NOP ),
    .o_opcode_WAIT                                ( o_opcode_WAIT ),
    .o_opcode_processor_extension_escape          ( o_opcode_processor_extension_escape ),
    .o_opcode_ARPL                                ( o_opcode_ARPL ),
    .o_opcode_LAR                                 ( o_opcode_LAR ),
    .o_opcode_LGDT                                ( o_opcode_LGDT ),
    .o_opcode_LIDT                                ( o_opcode_LIDT ),
    .o_opcode_LLDT                                ( o_opcode_LLDT ),
    .o_opcode_LMSW                                ( o_opcode_LMSW ),
    .o_opcode_LSL                                 ( o_opcode_LSL ),
    .o_opcode_LTR                                 ( o_opcode_LTR ),
    .o_opcode_SGDT                                ( o_opcode_SGDT ),
    .o_opcode_SIDT                                ( o_opcode_SIDT ),
    .o_opcode_SLDT                                ( o_opcode_SLDT ),
    .o_opcode_SMSW                                ( o_opcode_SMSW ),
    .o_opcode_STR                                 ( o_opcode_STR ),
    .o_opcode_VERR                                ( o_opcode_VERR ),
    .o_opcode_VERW                                ( o_opcode_VERW )
);

decode_stage_field decode_stage_3_field_instance_in_decode (
    .i_instruction                                 ( stage_field_i_instruction ),
    .i_opcode_MOV_reg_to_reg_mem                   ( o_opcode_MOV_reg_to_reg_mem ),
    .i_opcode_MOV_reg_mem_to_reg                   ( o_opcode_MOV_reg_mem_to_reg ),
    .i_opcode_MOV_imm_to_reg_mem                   ( o_opcode_MOV_imm_to_reg_mem ),
    .i_opcode_MOV_imm_to_reg_short                 ( o_opcode_MOV_imm_to_reg_short ),
    .i_opcode_MOV_mem_to_acc                       ( o_opcode_MOV_mem_to_acc ),
    .i_opcode_MOV_acc_to_mem                       ( o_opcode_MOV_acc_to_mem ),
    .i_opcode_MOV_reg_mem_to_sreg                  ( o_opcode_MOV_reg_mem_to_sreg ),
    .i_opcode_MOV_sreg_to_reg_mem                  ( o_opcode_MOV_sreg_to_reg_mem ),
    .i_opcode_MOVSX                                ( o_opcode_MOVSX ),
    .i_opcode_MOVZX                                ( o_opcode_MOVZX ),
    .i_opcode_PUSH_reg_mem                         ( o_opcode_PUSH_reg_mem ),
    .i_opcode_PUSH_reg_short                       ( o_opcode_PUSH_reg_short ),
    .i_opcode_PUSH_sreg_2                          ( o_opcode_PUSH_sreg_2 ),
    .i_opcode_PUSH_sreg_3                          ( o_opcode_PUSH_sreg_3 ),
    .i_opcode_PUSH_imm                             ( o_opcode_PUSH_imm ),
    .i_opcode_PUSH_all                             ( o_opcode_PUSH_all ),
    .i_opcode_POP_reg_mem                          ( o_opcode_POP_reg_mem ),
    .i_opcode_POP_reg_short                        ( o_opcode_POP_reg_short ),
    .i_opcode_POP_sreg_2                           ( o_opcode_POP_sreg_2 ),
    .i_opcode_POP_sreg_3                           ( o_opcode_POP_sreg_3 ),
    .i_opcode_POP_all                              ( o_opcode_POP_all ),
    .i_opcode_XCHG_reg_mem_with_reg                ( o_opcode_XCHG_reg_mem_with_reg ),
    .i_opcode_XCHG_reg_with_acc_short              ( o_opcode_XCHG_reg_with_acc_short ),
    .i_opcode_IN_port_fixed                        ( o_opcode_IN_port_fixed ),
    .i_opcode_IN_port_variable                     ( o_opcode_IN_port_variable ),
    .i_opcode_OUT_port_fixed                       ( o_opcode_OUT_port_fixed ),
    .i_opcode_OUT_port_variable                    ( o_opcode_OUT_port_variable ),
    .i_opcode_LEA_load_ea_to_reg                   ( o_opcode_LEA_load_ea_to_reg ),
    .i_opcode_LDS_load_ptr_to_DS                   ( o_opcode_LDS_load_ptr_to_DS ),
    .i_opcode_LES_load_ptr_to_ES                   ( o_opcode_LES_load_ptr_to_ES ),
    .i_opcode_LFS_load_ptr_to_FS                   ( o_opcode_LFS_load_ptr_to_FS ),
    .i_opcode_LGS_load_ptr_to_GS                   ( o_opcode_LGS_load_ptr_to_GS ),
    .i_opcode_LSS_load_ptr_to_SS                   ( o_opcode_LSS_load_ptr_to_SS ),
    .i_opcode_CLC_clear_carry_flag                 ( o_opcode_CLC_clear_carry_flag ),
    .i_opcode_CLD_clear_direction_flag             ( o_opcode_CLD_clear_direction_flag ),
    .i_opcode_CLI_clear_interrupt_enable_flag      ( o_opcode_CLI_clear_interrupt_enable_flag ),
    .i_opcode_CLTS_clear_task_switched_flag        ( o_opcode_CLTS_clear_task_switched_flag ),
    .i_opcode_CMC_complement_carry_flag            ( o_opcode_CMC_complement_carry_flag ),
    .i_opcode_LAHF_load_ah_into_flag               ( o_opcode_LAHF_load_ah_into_flag ),
    .i_opcode_POPF_pop_flags                       ( o_opcode_POPF_pop_flags ),
    .i_opcode_PUSHF_push_flags                     ( o_opcode_PUSHF_push_flags ),
    .i_opcode_SAHF_store_ah_into_flag              ( o_opcode_SAHF_store_ah_into_flag ),
    .i_opcode_STC_set_carry_flag                   ( o_opcode_STC_set_carry_flag ),
    .i_opcode_STD_set_direction_flag               ( o_opcode_STD_set_direction_flag ),
    .i_opcode_STI_set_interrupt_enable_flag        ( o_opcode_STI_set_interrupt_enable_flag ),
    .i_opcode_ADD_reg_to_mem                       ( o_opcode_ADD_reg_to_mem ),
    .i_opcode_ADD_mem_to_reg                       ( o_opcode_ADD_mem_to_reg ),
    .i_opcode_ADD_imm_to_reg_mem                   ( o_opcode_ADD_imm_to_reg_mem ),
    .i_opcode_ADD_imm_to_acc                       ( o_opcode_ADD_imm_to_acc ),
    .i_opcode_ADC_reg_to_mem                       ( o_opcode_ADC_reg_to_mem ),
    .i_opcode_ADC_mem_to_reg                       ( o_opcode_ADC_mem_to_reg ),
    .i_opcode_ADC_imm_to_reg_mem                   ( o_opcode_ADC_imm_to_reg_mem ),
    .i_opcode_ADC_imm_to_acc                       ( o_opcode_ADC_imm_to_acc ),
    .i_opcode_INC_reg_mem                          ( o_opcode_INC_reg_mem ),
    .i_opcode_INC_reg                              ( o_opcode_INC_reg ),
    .i_opcode_SUB_reg_to_mem                       ( o_opcode_SUB_reg_to_mem ),
    .i_opcode_SUB_mem_to_reg                       ( o_opcode_SUB_mem_to_reg ),
    .i_opcode_SUB_imm_to_reg_mem                   ( o_opcode_SUB_imm_to_reg_mem ),
    .i_opcode_SUB_imm_to_acc                       ( o_opcode_SUB_imm_to_acc ),
    .i_opcode_SBB_reg_to_mem                       ( o_opcode_SBB_reg_to_mem ),
    .i_opcode_SBB_mem_to_reg                       ( o_opcode_SBB_mem_to_reg ),
    .i_opcode_SBB_imm_to_reg_mem                   ( o_opcode_SBB_imm_to_reg_mem ),
    .i_opcode_SBB_imm_to_acc                       ( o_opcode_SBB_imm_to_acc ),
    .i_opcode_DEC_reg_mem                          ( o_opcode_DEC_reg_mem ),
    .i_opcode_DEC_reg                              ( o_opcode_DEC_reg ),
    .i_opcode_CMP_mem_with_reg                     ( o_opcode_CMP_mem_with_reg ),
    .i_opcode_CMP_reg_with_mem                     ( o_opcode_CMP_reg_with_mem ),
    .i_opcode_CMP_imm_with_reg_mem                 ( o_opcode_CMP_imm_with_reg_mem ),
    .i_opcode_CMP_imm_with_acc                     ( o_opcode_CMP_imm_with_acc ),
    .i_opcode_NEG_change_sign                      ( o_opcode_NEG_change_sign ),
    .i_opcode_AAA                                  ( o_opcode_AAA ),
    .i_opcode_AAS                                  ( o_opcode_AAS ),
    .i_opcode_DAA                                  ( o_opcode_DAA ),
    .i_opcode_DAS                                  ( o_opcode_DAS ),
    .i_opcode_MUL_acc_with_reg_mem                 ( o_opcode_MUL_acc_with_reg_mem ),
    .i_opcode_IMUL_acc_with_reg_mem                ( o_opcode_IMUL_acc_with_reg_mem ),
    .i_opcode_IMUL_reg_with_reg_mem                ( o_opcode_IMUL_reg_with_reg_mem ),
    .i_opcode_IMUL_reg_mem_with_imm_to_reg         ( o_opcode_IMUL_reg_mem_with_imm_to_reg ),
    .i_opcode_DIV_acc_by_reg_mem                   ( o_opcode_DIV_acc_by_reg_mem ),
    .i_opcode_IDIV_acc_by_reg_mem                  ( o_opcode_IDIV_acc_by_reg_mem ),
    .i_opcode_AAD                                  ( o_opcode_AAD ),
    .i_opcode_AAM                                  ( o_opcode_AAM ),
    .i_opcode_CBW                                  ( o_opcode_CBW ),
    .i_opcode_CWD                                  ( o_opcode_CWD ),
    .i_opcode_ROL_reg_mem_by_1                     ( o_opcode_ROL_reg_mem_by_1 ),
    .i_opcode_ROL_reg_mem_by_CL                    ( o_opcode_ROL_reg_mem_by_CL ),
    .i_opcode_ROL_reg_mem_by_imm                   ( o_opcode_ROL_reg_mem_by_imm ),
    .i_opcode_ROR_reg_mem_by_1                     ( o_opcode_ROR_reg_mem_by_1 ),
    .i_opcode_ROR_reg_mem_by_CL                    ( o_opcode_ROR_reg_mem_by_CL ),
    .i_opcode_ROR_reg_mem_by_imm                   ( o_opcode_ROR_reg_mem_by_imm ),
    .i_opcode_SHL_reg_mem_by_1                     ( o_opcode_SHL_reg_mem_by_1 ),
    .i_opcode_SHL_reg_mem_by_CL                    ( o_opcode_SHL_reg_mem_by_CL ),
    .i_opcode_SHL_reg_mem_by_imm                   ( o_opcode_SHL_reg_mem_by_imm ),
    .i_opcode_SAR_reg_mem_by_1                     ( o_opcode_SAR_reg_mem_by_1 ),
    .i_opcode_SAR_reg_mem_by_CL                    ( o_opcode_SAR_reg_mem_by_CL ),
    .i_opcode_SAR_reg_mem_by_imm                   ( o_opcode_SAR_reg_mem_by_imm ),
    .i_opcode_SHR_reg_mem_by_1                     ( o_opcode_SHR_reg_mem_by_1 ),
    .i_opcode_SHR_reg_mem_by_CL                    ( o_opcode_SHR_reg_mem_by_CL ),
    .i_opcode_SHR_reg_mem_by_imm                   ( o_opcode_SHR_reg_mem_by_imm ),
    .i_opcode_RCL_reg_mem_by_1                     ( o_opcode_RCL_reg_mem_by_1 ),
    .i_opcode_RCL_reg_mem_by_CL                    ( o_opcode_RCL_reg_mem_by_CL ),
    .i_opcode_RCL_reg_mem_by_imm                   ( o_opcode_RCL_reg_mem_by_imm ),
    .i_opcode_RCR_reg_mem_by_1                     ( o_opcode_RCR_reg_mem_by_1 ),
    .i_opcode_RCR_reg_mem_by_CL                    ( o_opcode_RCR_reg_mem_by_CL ),
    .i_opcode_RCR_reg_mem_by_imm                   ( o_opcode_RCR_reg_mem_by_imm ),
    .i_opcode_SHLD_reg_mem_by_imm                  ( o_opcode_SHLD_reg_mem_by_imm ),
    .i_opcode_SHLD_reg_mem_by_CL                   ( o_opcode_SHLD_reg_mem_by_CL ),
    .i_opcode_SHRD_reg_mem_by_imm                  ( o_opcode_SHRD_reg_mem_by_imm ),
    .i_opcode_SHRD_reg_mem_by_CL                   ( o_opcode_SHRD_reg_mem_by_CL ),
    .i_opcode_AND_reg_to_mem                       ( o_opcode_AND_reg_to_mem ),
    .i_opcode_AND_mem_to_reg                       ( o_opcode_AND_mem_to_reg ),
    .i_opcode_AND_imm_to_reg_mem                   ( o_opcode_AND_imm_to_reg_mem ),
    .i_opcode_AND_imm_to_acc                       ( o_opcode_AND_imm_to_acc ),
    .i_opcode_TEST_reg_mem_and_reg                 ( o_opcode_TEST_reg_mem_and_reg ),
    .i_opcode_TEST_imm_to_reg_mem                  ( o_opcode_TEST_imm_to_reg_mem ),
    .i_opcode_TEST_imm_to_acc                      ( o_opcode_TEST_imm_to_acc ),
    .i_opcode_OR_reg_to_mem                        ( o_opcode_OR_reg_to_mem ),
    .i_opcode_OR_mem_to_reg                        ( o_opcode_OR_mem_to_reg ),
    .i_opcode_OR_imm_to_reg_mem                    ( o_opcode_OR_imm_to_reg_mem ),
    .i_opcode_OR_imm_to_acc                        ( o_opcode_OR_imm_to_acc ),
    .i_opcode_XOR_reg_to_mem                       ( o_opcode_XOR_reg_to_mem ),
    .i_opcode_XOR_mem_to_reg                       ( o_opcode_XOR_mem_to_reg ),
    .i_opcode_XOR_imm_to_reg_mem                   ( o_opcode_XOR_imm_to_reg_mem ),
    .i_opcode_XOR_imm_to_acc                       ( o_opcode_XOR_imm_to_acc ),
    .i_opcode_NOT                                  ( o_opcode_NOT ),
    .i_opcode_CMPS                                 ( o_opcode_CMPS ),
    .i_opcode_INS                                  ( o_opcode_INS ),
    .i_opcode_LODS                                 ( o_opcode_LODS ),
    .i_opcode_MOVS                                 ( o_opcode_MOVS ),
    .i_opcode_OUTS                                 ( o_opcode_OUTS ),
    .i_opcode_SCAS                                 ( o_opcode_SCAS ),
    .i_opcode_STOS                                 ( o_opcode_STOS ),
    .i_opcode_XLAT                                 ( o_opcode_XLAT ),
    .i_opcode_REPE                                 ( o_opcode_REPE ),
    .i_opcode_REPNE                                ( o_opcode_REPNE ),
    .i_opcode_BSF                                  ( o_opcode_BSF ),
    .i_opcode_BSR                                  ( o_opcode_BSR ),
    .i_opcode_BT_reg_mem_with_imm                  ( o_opcode_BT_reg_mem_with_imm ),
    .i_opcode_BT_reg_mem_with_reg                  ( o_opcode_BT_reg_mem_with_reg ),
    .i_opcode_BTC_reg_mem_with_imm                 ( o_opcode_BTC_reg_mem_with_imm ),
    .i_opcode_BTC_reg_mem_with_reg                 ( o_opcode_BTC_reg_mem_with_reg ),
    .i_opcode_BTR_reg_mem_with_imm                 ( o_opcode_BTR_reg_mem_with_imm ),
    .i_opcode_BTR_reg_mem_with_reg                 ( o_opcode_BTR_reg_mem_with_reg ),
    .i_opcode_BTS_reg_mem_with_imm                 ( o_opcode_BTS_reg_mem_with_imm ),
    .i_opcode_BTS_reg_mem_with_reg                 ( o_opcode_BTS_reg_mem_with_reg ),
    .i_opcode_CALL_direct_within_segment           ( o_opcode_CALL_direct_within_segment ),
    .i_opcode_CALL_indirect_within_segment         ( o_opcode_CALL_indirect_within_segment ),
    .i_opcode_CALL_direct_intersegment             ( o_opcode_CALL_direct_intersegment ),
    .i_opcode_CALL_indirect_intersegment           ( o_opcode_CALL_indirect_intersegment ),
    .i_opcode_JMP_short                            ( o_opcode_JMP_short ),
    .i_opcode_JMP_direct_within_segment            ( o_opcode_JMP_direct_within_segment ),
    .i_opcode_JMP_indirect_within_segment          ( o_opcode_JMP_indirect_within_segment ),
    .i_opcode_JMP_direct_intersegment              ( o_opcode_JMP_direct_intersegment ),
    .i_opcode_JMP_indirect_intersegment            ( o_opcode_JMP_indirect_intersegment ),
    .i_opcode_RET_within_segment                   ( o_opcode_RET_within_segment ),
    .i_opcode_RET_within_segment_adding_imm_to_SP  ( o_opcode_RET_within_segment_adding_imm_to_SP ),
    .i_opcode_RET_intersegment                     ( o_opcode_RET_intersegment ),
    .i_opcode_RET_intersegment_adding_imm_to_SP    ( o_opcode_RET_intersegment_adding_imm_to_SP ),
    .i_opcode_JO_8bit_disp                         ( o_opcode_JO_8bit_disp ),
    .i_opcode_JO_full_disp                         ( o_opcode_JO_full_disp ),
    .i_opcode_JNO_8bit_disp                        ( o_opcode_JNO_8bit_disp ),
    .i_opcode_JNO_full_disp                        ( o_opcode_JNO_full_disp ),
    .i_opcode_JB_8bit_disp                         ( o_opcode_JB_8bit_disp ),
    .i_opcode_JB_full_disp                         ( o_opcode_JB_full_disp ),
    .i_opcode_JNB_8bit_disp                        ( o_opcode_JNB_8bit_disp ),
    .i_opcode_JNB_full_disp                        ( o_opcode_JNB_full_disp ),
    .i_opcode_JE_8bit_disp                         ( o_opcode_JE_8bit_disp ),
    .i_opcode_JE_full_disp                         ( o_opcode_JE_full_disp ),
    .i_opcode_JNE_8bit_disp                        ( o_opcode_JNE_8bit_disp ),
    .i_opcode_JNE_full_disp                        ( o_opcode_JNE_full_disp ),
    .i_opcode_JBE_8bit_disp                        ( o_opcode_JBE_8bit_disp ),
    .i_opcode_JBE_full_disp                        ( o_opcode_JBE_full_disp ),
    .i_opcode_JNBE_8bit_disp                       ( o_opcode_JNBE_8bit_disp ),
    .i_opcode_JNBE_full_disp                       ( o_opcode_JNBE_full_disp ),
    .i_opcode_JS_8bit_disp                         ( o_opcode_JS_8bit_disp ),
    .i_opcode_JS_full_disp                         ( o_opcode_JS_full_disp ),
    .i_opcode_JNS_8bit_disp                        ( o_opcode_JNS_8bit_disp ),
    .i_opcode_JNS_full_disp                        ( o_opcode_JNS_full_disp ),
    .i_opcode_JP_8bit_disp                         ( o_opcode_JP_8bit_disp ),
    .i_opcode_JP_full_disp                         ( o_opcode_JP_full_disp ),
    .i_opcode_JNP_8bit_disp                        ( o_opcode_JNP_8bit_disp ),
    .i_opcode_JNP_full_disp                        ( o_opcode_JNP_full_disp ),
    .i_opcode_JL_8bit_disp                         ( o_opcode_JL_8bit_disp ),
    .i_opcode_JL_full_disp                         ( o_opcode_JL_full_disp ),
    .i_opcode_JNL_8bit_disp                        ( o_opcode_JNL_8bit_disp ),
    .i_opcode_JNL_full_disp                        ( o_opcode_JNL_full_disp ),
    .i_opcode_JLE_8bit_disp                        ( o_opcode_JLE_8bit_disp ),
    .i_opcode_JLE_full_disp                        ( o_opcode_JLE_full_disp ),
    .i_opcode_JNLE_8bit_disp                       ( o_opcode_JNLE_8bit_disp ),
    .i_opcode_JNLE_full_disp                       ( o_opcode_JNLE_full_disp ),
    .i_opcode_JCXZ                                 ( o_opcode_JCXZ ),
    .i_opcode_LOOP                                 ( o_opcode_LOOP ),
    .i_opcode_LOOPZ                                ( o_opcode_LOOPZ ),
    .i_opcode_LOOPNZ                               ( o_opcode_LOOPNZ ),
    .i_opcode_SETO                                 ( o_opcode_SETO ),
    .i_opcode_SETNO                                ( o_opcode_SETNO ),
    .i_opcode_SETB                                 ( o_opcode_SETB ),
    .i_opcode_SETNB                                ( o_opcode_SETNB ),
    .i_opcode_SETE                                 ( o_opcode_SETE ),
    .i_opcode_SETNE                                ( o_opcode_SETNE ),
    .i_opcode_SETBE                                ( o_opcode_SETBE ),
    .i_opcode_SETNBE                               ( o_opcode_SETNBE ),
    .i_opcode_SETS                                 ( o_opcode_SETS ),
    .i_opcode_SETNS                                ( o_opcode_SETNS ),
    .i_opcode_SETP                                 ( o_opcode_SETP ),
    .i_opcode_SETNP                                ( o_opcode_SETNP ),
    .i_opcode_SETL                                 ( o_opcode_SETL ),
    .i_opcode_SETNL                                ( o_opcode_SETNL ),
    .i_opcode_SETLE                                ( o_opcode_SETLE ),
    .i_opcode_SETNLE                               ( o_opcode_SETNLE ),
    .i_opcode_ENTER                                ( o_opcode_ENTER ),
    .i_opcode_LEAVE                                ( o_opcode_LEAVE ),
    .i_opcode_INT_type_3                           ( o_opcode_INT_type_3 ),
    .i_opcode_INT_type_specified                   ( o_opcode_INT_type_specified ),
    .i_opcode_INTO                                 ( o_opcode_INTO ),
    .i_opcode_BOUND                                ( o_opcode_BOUND ),
    .i_opcode_IRET                                 ( o_opcode_IRET ),
    .i_opcode_HLT                                  ( o_opcode_HLT ),
    .i_opcode_MOV_CR0_CR2_CR3_from_reg             ( o_opcode_MOV_CR0_CR2_CR3_from_reg ),
    .i_opcode_MOV_reg_from_CR0_3                   ( o_opcode_MOV_reg_from_CR0_3 ),
    .i_opcode_MOV_DR0_7_from_reg                   ( o_opcode_MOV_DR0_7_from_reg ),
    .i_opcode_MOV_reg_from_DR0_7                   ( o_opcode_MOV_reg_from_DR0_7 ),
    .i_opcode_MOV_TR6_7_from_reg                   ( o_opcode_MOV_TR6_7_from_reg ),
    .i_opcode_MOV_reg_from_TR6_7                   ( o_opcode_MOV_reg_from_TR6_7 ),
    .i_opcode_NOP                                  ( o_opcode_NOP ),
    .i_opcode_WAIT                                 ( o_opcode_WAIT ),
    .i_opcode_processor_extension_escape           ( o_opcode_processor_extension_escape ),
    .i_opcode_ARPL                                 ( o_opcode_ARPL ),
    .i_opcode_LAR                                  ( o_opcode_LAR ),
    .i_opcode_LGDT                                 ( o_opcode_LGDT ),
    .i_opcode_LIDT                                 ( o_opcode_LIDT ),
    .i_opcode_LLDT                                 ( o_opcode_LLDT ),
    .i_opcode_LMSW                                 ( o_opcode_LMSW ),
    .i_opcode_LSL                                  ( o_opcode_LSL ),
    .i_opcode_LTR                                  ( o_opcode_LTR ),
    .i_opcode_SGDT                                 ( o_opcode_SGDT ),
    .i_opcode_SIDT                                 ( o_opcode_SIDT ),
    .i_opcode_SLDT                                 ( o_opcode_SLDT ),
    .i_opcode_SMSW                                 ( o_opcode_SMSW ),
    .i_opcode_STR                                  ( o_opcode_STR ),
    .i_opcode_VERR                                 ( o_opcode_VERR ),
    .i_opcode_VERW                                 ( o_opcode_VERW ),
    .o_s_is_present                                ( stage_field_o_s_is_present ),
    .o_s                                           ( stage_field_o_s ),
    .o_w_is_present                                ( stage_field_o_w_is_present ),
    .o_w                                           ( stage_field_o_w ),
    .o_gen_reg_is_present                          ( stage_field_o_gen_reg_is_present ),
    .o_gen_reg_index                               ( stage_field_o_gen_reg_index ),
    .o_seg_reg_is_present                          ( stage_field_o_seg_reg_is_present ),
    .o_seg_reg_index                               ( stage_field_o_seg_reg_index ),
    .o_mod_rm_is_present                           ( stage_field_o_mod_rm_is_present ),
    .o_mod                                         ( stage_field_o_mod ),
    .o_rm                                          ( stage_field_o_rm ),
    .o_displacement_is_present                     ( stage_field_o_displacement_is_present ),
    .o_displacement_size_default                   ( stage_field_o_displacement_size_default ),
    .o_displacement_size_8                         ( stage_field_o_displacement_size_8 ),
    .o_displacement_size_16                        ( stage_field_o_displacement_size_16 ),
    .o_immediate_is_present                        ( stage_field_o_immediate_is_present ),
    .o_immediate_size_default                      ( stage_field_o_immediate_size_default ),
    .o_immediate_size_8                            ( stage_field_o_immediate_size_8 ),
    .o_unsigned_full_offset_or_selector_is_present ( stage_field_o_unsigned_full_offset_or_selector_is_present ),
    .o_bytes_consumed                              ( stage_field_o_bytes_consumed ),
    .o_error                                       ( stage_field_o_error )
);

decode_stage_mod_rm decode_stage_4_mod_rm_instance_in_decode (
    .i_mod                     ( stage_mod_rm_i_mod ),
    .i_rm                      ( stage_mod_rm_i_rm ),
    .i_w_is_present            ( stage_mod_rm_i_w_is_present ),
    .i_w                       ( stage_mod_rm_i_w ),
    .i_default_operand_size    ( stage_mod_rm_i_default_operand_size ),
    .o_segment_reg_index       ( stage_mod_rm_o_segment_reg_index ),
    .o_base_reg_is_present     ( stage_mod_rm_o_base_reg_is_present ),
    .o_base_reg_index          ( stage_mod_rm_o_base_reg_index ),
    .o_index_reg_is_present    ( stage_mod_rm_o_index_reg_is_present ),
    .o_index_reg_index         ( stage_mod_rm_o_index_reg_index ),
    .o_gen_reg_is_present      ( stage_mod_rm_o_gen_reg_is_present ),
    .o_gen_reg_index           ( stage_mod_rm_o_gen_reg_index ),
    .o_gen_reg_bit_width       ( stage_mod_rm_o_gen_reg_bit_width ),
    .o_displacement_is_present ( stage_mod_rm_o_displacement_is_present ),
    .o_displacement_size_8     ( stage_mod_rm_o_displacement_size_8 ),
    .o_displacement_size_16    ( stage_mod_rm_o_displacement_size_16 ),
    .o_displacement_size_32    ( stage_mod_rm_o_displacement_size_32 ),
    .o_sib_is_present          ( stage_mod_rm_o_sib_is_present )
);

decode_stage_sib decode_stage_5_sib_instance_in_decode (
    .i_sib                         ( stage_sib_i_sib ),
    .i_mod                         ( stage_sib_i_mod ),
    .o_scale_factor                ( stage_sib_o_scale_factor ),
    .o_index_reg_is_present        ( stage_sib_o_index_reg_is_present ),
    .o_index_reg_index             ( stage_sib_o_index_reg_index ),
    .o_base_reg_is_present         ( stage_sib_o_base_reg_is_present ),
    .o_base_reg_index              ( stage_sib_o_base_reg_index ),
    .o_displacement_is_present     ( stage_sib_o_displacement_is_present ),
    .o_displacement_length         ( stage_sib_o_displacement_length ),
    .o_effecitve_address_undefined ( stage_sib_o_effecitve_address_undefined )
);

decode_stage_disp_imm decode_stage_6_disp_imm_instance_in_decode (
    .i_instruction             ( stage_disp_imm_i_instruction ),
    .i_displacement_is_present ( stage_disp_imm_i_displacement_is_present ),
    .i_displacement_length     ( stage_disp_imm_i_displacement_length ),
    .i_immediate_is_present    ( stage_disp_imm_i_immediate_is_present ),
    .i_immediate_length        ( stage_disp_imm_i_immediate_length ),
    .o_displacement            ( stage_disp_imm_o_displacement ),
    .o_immediate               ( stage_disp_imm_o_immediate ),
    .o_bytes_consumed          ( stage_disp_imm_o_bytes_consumed )
);

endmodule
