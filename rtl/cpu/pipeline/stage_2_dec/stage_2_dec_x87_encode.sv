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
//  File        : stage_2_dec_x87_encode.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Map x87 opcode/operand decode flags to EXE_X87 sub-opcodes
// ============================================================================

`include "openx86_defs.h.sv"

module stage_2_dec_x87_encode (
    output logic            o_x87_any,
    output logic [ 4: 0]    o_x87_exe_subop,
    output logic            o_x87_mem_access,
    output logic            o_x87_is_store,

    input  logic            i_opcode_x87_FLD_load_real,
    input  logic            i_opcode_x87_FST_store_real,
    input  logic            i_opcode_x87_FSTP_store_pop_real,
    input  logic            i_opcode_x87_FILD_load_int,
    input  logic            i_opcode_x87_FIST_store_int,
    input  logic            i_opcode_x87_FISTP_store_pop_int,
    input  logic            i_opcode_x87_FADD,
    input  logic            i_opcode_x87_FMUL,
    input  logic            i_opcode_x87_FCOM,
    input  logic            i_opcode_x87_FCOMP,
    input  logic            i_opcode_x87_FSUB,
    input  logic            i_opcode_x87_FSUBR,
    input  logic            i_opcode_x87_FDIV,
    input  logic            i_opcode_x87_FDIVR,
    input  logic            i_opcode_x87_FLD_STi,
    input  logic            i_opcode_x87_FXCH,
    input  logic            i_opcode_x87_FST_STi,
    input  logic            i_op_x87_is_memory
);

    always_comb begin
        o_x87_any        = 1'b0;
        o_x87_exe_subop  = `EXE_X87_NOP;
        o_x87_mem_access = 1'b0;
        o_x87_is_store   = 1'b0;

        if (i_opcode_x87_FADD) begin
            o_x87_any       = 1'b1;
            o_x87_exe_subop = `EXE_X87_FADD;
        end else if (i_opcode_x87_FSUB) begin
            o_x87_any       = 1'b1;
            o_x87_exe_subop = `EXE_X87_FSUB;
        end else if (i_opcode_x87_FSUBR) begin
            o_x87_any       = 1'b1;
            o_x87_exe_subop = `EXE_X87_FSUBR;
        end else if (i_opcode_x87_FMUL) begin
            o_x87_any       = 1'b1;
            o_x87_exe_subop = `EXE_X87_FMUL;
        end else if (i_opcode_x87_FDIV) begin
            o_x87_any       = 1'b1;
            o_x87_exe_subop = `EXE_X87_FDIV;
        end else if (i_opcode_x87_FDIVR) begin
            o_x87_any       = 1'b1;
            o_x87_exe_subop = `EXE_X87_FDIVR;
        end else if (i_opcode_x87_FLD_load_real | i_opcode_x87_FILD_load_int) begin
            o_x87_any        = 1'b1;
            o_x87_exe_subop  = `EXE_X87_FLD;
            o_x87_mem_access = i_op_x87_is_memory;
        end else if (i_opcode_x87_FLD_STi) begin
            o_x87_any       = 1'b1;
            o_x87_exe_subop = `EXE_X87_FLD_STI;
        end else if (i_opcode_x87_FST_store_real | i_opcode_x87_FIST_store_int) begin
            o_x87_any        = 1'b1;
            o_x87_exe_subop  = `EXE_X87_FST;
            o_x87_mem_access = i_op_x87_is_memory;
            o_x87_is_store   = i_op_x87_is_memory;
        end else if (i_opcode_x87_FSTP_store_pop_real | i_opcode_x87_FISTP_store_pop_int) begin
            o_x87_any        = 1'b1;
            o_x87_exe_subop  = `EXE_X87_FSTP;
            o_x87_mem_access = i_op_x87_is_memory;
            o_x87_is_store   = i_op_x87_is_memory;
        end else if (i_opcode_x87_FST_STi) begin
            o_x87_any       = 1'b1;
            o_x87_exe_subop = `EXE_X87_FST;
        end else if (i_opcode_x87_FXCH) begin
            o_x87_any       = 1'b1;
            o_x87_exe_subop = `EXE_X87_FXCH;
        end else if (i_opcode_x87_FCOM) begin
            o_x87_any       = 1'b1;
            o_x87_exe_subop = `EXE_X87_FCOM;
        end else if (i_opcode_x87_FCOMP) begin
            o_x87_any       = 1'b1;
            o_x87_exe_subop = `EXE_X87_FCOMP;
        end
    end

endmodule
