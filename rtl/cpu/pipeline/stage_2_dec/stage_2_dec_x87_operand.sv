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
//  File        : stage_2_dec_x87_operand.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_2_dec_x87_operand module
// ============================================================================

module stage_2_dec_x87_operand (

    // =========================
    // operand type
    // =========================
    output logic         o_op_x87_is_memory,
    output logic         o_op_x87_is_reg_stack,

    // =========================
    // stack operands
    // =========================
    output logic [ 2: 0] o_op_x87_sti,
    output logic         o_op_x87_use_st0,
    output logic         o_op_x87_use_sti,

    // =========================
    // memory operand size/type
    // =========================
    output logic         o_op_x87_mem_real32,
    output logic         o_op_x87_mem_real64,
    output logic         o_op_x87_mem_int16,
    output logic         o_op_x87_mem_int32,
    output logic         o_op_x87_mem_int64,
    output logic         o_op_x87_mem_bcd,

    // =========================
    // control from opcode decoder
    // =========================
    input  logic         i_opcode_x87_FLD_load_real,
    input  logic         i_opcode_x87_FST_store_real,
    input  logic         i_opcode_x87_FSTP_store_pop_real,
    input  logic         i_opcode_x87_FILD_load_int,
    input  logic         i_opcode_x87_FIST_store_int,
    input  logic         i_opcode_x87_FISTP_store_pop_int,
    input  logic         i_opcode_x87_FADD,
    input  logic         i_opcode_x87_FMUL,
    input  logic         i_opcode_x87_FSUB,
    input  logic         i_opcode_x87_FDIV,
    input  logic         i_opcode_x87_FLD_STi,
    input  logic         i_opcode_x87_FXCH,

    input  logic [ 3: 0][ 7: 0] i_instruction
);

    // ============================================================
    // decode ModR/M
    // ============================================================
    logic [1: 0] mod;
    logic [2: 0] rm;
    logic [2: 0] reg_field;

    assign mod       = i_instruction[1][7: 6];
    assign rm        = i_instruction[1][2: 0];
    assign reg_field = i_instruction[1][5: 3];

    logic is_mem;
    logic is_reg;

    assign is_mem = (mod != 2'b11);
    assign is_reg = (mod == 2'b11);

    // ============================================================
    // operand type classification
    // ============================================================
    assign o_op_x87_is_memory   = is_mem;
    assign o_op_x87_is_reg_stack = is_reg;

    // ============================================================
    // ST(i) decoding
    // ============================================================
    assign o_op_x87_sti     = rm;
    assign o_op_x87_use_st0 = is_reg;
    assign o_op_x87_use_sti = is_reg && (rm != 3'b000);

    // ============================================================
    // memory operand type (based on opcode group)
    // ============================================================
    assign o_op_x87_mem_real32 =
        i_opcode_x87_FLD_load_real |
        i_opcode_x87_FST_store_real |
        i_opcode_x87_FSTP_store_pop_real;

    assign o_op_x87_mem_real64 =
        i_opcode_x87_FADD |
        i_opcode_x87_FMUL |
        i_opcode_x87_FSUB |
        i_opcode_x87_FDIV;

    assign o_op_x87_mem_int16 =
        i_opcode_x87_FILD_load_int |
        i_opcode_x87_FIST_store_int |
        i_opcode_x87_FISTP_store_pop_int;

    assign o_op_x87_mem_int32 =
        i_opcode_x87_FILD_load_int;

    assign o_op_x87_mem_int64 =
        i_opcode_x87_FISTP_store_pop_int;

    assign o_op_x87_mem_bcd = 1'b0; // reserved for FBLD/FBSTP extension

endmodule
