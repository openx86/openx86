/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: stage_3_uop wrapper for macro-instruction to micro-instruction conversion.
*/
// ============================================================================
// stage_3_uop
// ----------------------------------------------------------------------------
// Stage 3 UOP:
// - converts decoded macro-instructions to micro-operations
// - provides simplified internal instruction representation to execution stages
// - handles instruction fusion and micro-op sequencing
// ============================================================================

`include "openx86_defs.h.sv"

module stage_3_uop (
    // Stage handshake/control from stage_2_dec
    input  logic                i_stage2_valid, // 输入信号
    input  logic                i_flush, // 输入信号
    output logic                o_stage2_ready, // 输出信号
    output logic                o_stage_valid, // 输出信号

    // Decoded macro-instruction inputs from stage_2_dec
    input  logic                i_opcode_cpuid, // 输入信号
    input  logic                i_opcode_mov_reg_to_reg_mem, // 输入信号
    input  logic                i_opcode_mov_reg_mem_to_reg, // 输入信号
    input  logic                i_opcode_mov_mem_to_acc, // 输入信号
    input  logic                i_opcode_mov_acc_to_mem, // 输入信号
    input  logic                i_opcode_add_reg_to_reg_mem, // 输入信号
    input  logic                i_opcode_sub_reg_to_reg_mem, // 输入信号
    input  logic                i_opcode_jcc_short, // 输入信号
    input  logic                i_opcode_jcc_near, // 输入信号
    input  logic                i_opcode_x87_esc, // 输入信号

    input  logic [31: 0]        i_dec_displacement, // 输入信号
    input  logic [31: 0]        i_dec_immediate, // 输入信号
    input  logic                i_dec_base_reg_is_present, // 输入信号
    input  logic [ 2: 0]        i_dec_base_reg_index, // 输入信号
    input  logic                i_dec_index_reg_is_present, // 输入信号
    input  logic [ 2: 0]        i_dec_index_reg_index, // 输入信号
    input  logic [ 2: 0]        i_dec_segment_reg_index, // 输入信号
    input  logic [ 1: 0]        i_dec_sib_scale_factor, // 输入信号
    input  logic [ 1: 0]        i_dec_modrm_mod, // 输入信号

    // Micro-op outputs to stage_4_exu
    output micro_op_t           o_uop, // 输出信号

    input  logic                i_stage4_ready, // 输入信号

    input  logic                clk, // 时钟信号
    input  logic                rst_n // 复位信号
);

    // Micro-op pipeline register
    micro_op_t uop_reg;
    micro_op_t uop_next;

    // Stage valid/ready signals
    logic stage_valid;

    // Default micro-op (NOP)
    micro_op_t uop_default;
    assign uop_default = '{
        uop_opcode:      `UOP_NOP,
        uop_dest_reg:    3'b0,
        uop_src1_reg:    3'b0,
        uop_src2_reg:    3'b0,
        uop_immediate:   32'd0,
        uop_displacement: 32'd0,
        uop_has_imm:     1'b0,
        uop_has_disp:    1'b0,
        uop_mem_access:  1'b0,
        uop_is_store:    1'b0,
        uop_valid:       1'b0
    };

    // Macro-instruction to micro-op conversion logic
    always_comb begin
        uop_next = uop_default;

        if (i_stage2_valid) begin
            uop_next.uop_valid = 1'b1;

            // MOV instructions
            if (i_opcode_mov_reg_to_reg_mem) begin
                uop_next.uop_opcode = `UOP_MOV;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_mov_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_MOV;
                uop_next.uop_dest_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_mov_mem_to_acc || i_opcode_mov_acc_to_mem) begin
                uop_next.uop_opcode = `UOP_MOV;
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_is_store = i_opcode_mov_acc_to_mem;
                uop_next.uop_dest_reg = 3'b0; // EAX
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
            end

            // ADD instructions
            else if (i_opcode_add_reg_to_reg_mem) begin
                uop_next.uop_opcode = `UOP_ADD;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end

            // SUB instructions
            else if (i_opcode_sub_reg_to_reg_mem) begin
                uop_next.uop_opcode = `UOP_SUB;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end

            // Branch instructions
            else if (i_opcode_jcc_short || i_opcode_jcc_near) begin
                uop_next.uop_opcode = `UOP_BRANCH;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_dec_displacement;
            end

            // x87 instructions
            else if (i_opcode_x87_esc) begin
                uop_next.uop_opcode = `UOP_X87;
            end

            // CPUID
            else if (i_opcode_cpuid) begin
                uop_next.uop_opcode = `UOP_NOP; // CPUID handled separately
            end
        end
    end

    // Pipeline register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uop_reg <= uop_default;
            stage_valid <= 1'b0;
        end else if (i_flush) begin
            uop_reg <= uop_default;
            stage_valid <= 1'b0;
        end else if (i_stage4_ready) begin
            uop_reg <= uop_next;
            stage_valid <= i_stage2_valid;
        end
    end

    // Output assignments
    assign o_uop = uop_reg;
    assign o_stage_valid = stage_valid;
    assign o_stage2_ready = i_stage4_ready;

endmodule
