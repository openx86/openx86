/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: stage_2_dec with decode + IFU/EXU handshake.
*/
// ============================================================================
// stage_2_dec
// ----------------------------------------------------------------------------
// Stage 2 DEC:
// - decodes opcode/prefix/operand candidates through legacy unit decoder
// - provides consume-bytes feedback to IFU
// - handshakes with EXU via dec_to_exe boundary
// ============================================================================

module stage_2_dec (
    input  logic [15: 0][ 7: 0] i_instruction, // 输入信号
    input  logic                i_instruction_valid, // 输入信号
    input  logic                i_default_operand_size, // 输入信号

    input  logic                i_exu_ready, // 输入信号
    input  logic                i_flush, // 输入信号
    output logic                o_ifu_ready, // 输出信号
    output logic                o_instruction_fire, // 输出信号
    output logic                o_stage_valid, // 输出信号

    output logic [ 3: 0]        o_consume_bytes, // 输出信号
    output logic                o_decode_error, // 输出信号

    // Decoded opcode (subset for stage interface)
    output logic                o_opcode_cpuid, // 输出信号
    output logic                o_opcode_mov_reg_to_reg_mem, // 输出信号
    output logic                o_opcode_mov_reg_mem_to_reg, // 输出信号
    output logic                o_opcode_add_reg_to_reg_mem, // 输出信号
    output logic                o_opcode_sub_reg_to_reg_mem, // 输出信号
    output logic                o_opcode_jcc_short, // 输出信号
    output logic                o_opcode_jcc_near, // 输出信号
    output logic                o_opcode_x87_esc, // 输出信号

    // Decoded operand fields (subset)
    output logic [31: 0]        o_dec_displacement, // 输出信号
    output logic [31: 0]        o_dec_immediate, // 输出信号
    output logic                o_dec_base_reg_is_present, // 输出信号
    output logic [ 2: 0]        o_dec_base_reg_index, // 输出信号
    output logic                o_dec_index_reg_is_present, // 输出信号
    output logic [ 2: 0]        o_dec_index_reg_index, // 输出信号
    output logic [ 2: 0]        o_dec_segment_reg_index, // 输出信号
    output logic [ 1: 0]        o_dec_sib_scale_factor, // 输出信号
    output logic [ 1: 0]        o_dec_modrm_mod, // 输出信号

    input  logic                clk, // 时钟信号
    input  logic                rst_n // 复位信号
);

    logic dec_if_ready;

    unit u_stage_2_dec_unit (
        .i_instruction                                 ( i_instruction ),
        .i_default_operand_size                        ( i_default_operand_size ),
        .o_opcode_x86_CPUID_CPU_identification        ( o_opcode_cpuid ),
        .o_opcode_x86_MOV_reg_to_reg_mem              ( o_opcode_mov_reg_to_reg_mem ),
        .o_opcode_x86_MOV_reg_mem_to_reg              ( o_opcode_mov_reg_mem_to_reg ),
        .o_opcode_x86_ADD_reg_to_reg_mem              ( o_opcode_add_reg_to_reg_mem ),
        .o_opcode_x86_SUB_reg_to_reg_mem              ( o_opcode_sub_reg_to_reg_mem ),
        .o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp ( o_opcode_jcc_short ),
        .o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp  ( o_opcode_jcc_near ),
        .o_x87_is_esc                                  ( o_opcode_x87_esc ),
        .o_displacement                                ( o_dec_displacement ),
        .o_immediate                                   ( o_dec_immediate ),
        .o_base_reg_is_present                         ( o_dec_base_reg_is_present ),
        .o_base_reg_index                              ( o_dec_base_reg_index ),
        .o_index_reg_is_present                        ( o_dec_index_reg_is_present ),
        .o_index_reg_index                             ( o_dec_index_reg_index ),
        .o_segment_reg_index                           ( o_dec_segment_reg_index ),
        .o_sib_scale_factor                            ( o_dec_sib_scale_factor ),
        .o_dbg_modrm_mod                               ( o_dec_modrm_mod ),
        .o_consume_bytes                               ( o_consume_bytes ),
        .o_error                                       ( o_decode_error )
    );

    // 译码成功后再向 EXU 发射，避免错误指令占用执行流水。
    dec_to_exe u_stage_2_dec_to_exe (
        .i_instruction_ready ( i_instruction_valid & ~o_decode_error ),
        .i_exe_ready         ( i_exu_ready ),
        .o_dec_ready         ( dec_if_ready ),
        .o_insn_fire         ( o_instruction_fire ),
        .o_stage_valid       ( o_stage_valid ),
        .i_flush             ( i_flush ),
        .clk                 ( clk ),
        .rst_n               ( rst_n )
    );

    assign o_ifu_ready = dec_if_ready;

endmodule
