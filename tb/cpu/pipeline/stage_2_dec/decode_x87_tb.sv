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
//  File        : decode_x87_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : x87 fine-grained decode smoke (D8 C1 -> EXE_X87_FADD)
// ============================================================================

`timescale 1ns/1ns

`include "openx86_defs.h.sv"

module decode_x87_tb;

    logic [3: 0][7: 0] instruction;
    logic             fadd_flag;
    logic             fxch_flag;
    logic             any_flag;
    logic [4: 0]      exe_subop;
    logic [2: 0]      sti;
    logic             is_mem;
    logic             is_store;

    stage_2_dec_x87_opcode u_opcode (
        .i_instruction                              (instruction),
        .o_opcode_x87_FLD_load_real                 (),
        .o_opcode_x87_FST_store_real                (),
        .o_opcode_x87_FSTP_store_pop_real           (),
        .o_opcode_x87_FILD_load_int                 (),
        .o_opcode_x87_FIST_store_int                (),
        .o_opcode_x87_FISTP_store_pop_int           (),
        .o_opcode_x87_FADD                          (fadd_flag),
        .o_opcode_x87_FMUL                          (),
        .o_opcode_x87_FCOM                          (),
        .o_opcode_x87_FCOMP                         (),
        .o_opcode_x87_FSUB                          (),
        .o_opcode_x87_FSUBR                         (),
        .o_opcode_x87_FDIV                          (),
        .o_opcode_x87_FDIVR                         (),
        .o_opcode_x87_FLD_STi                       (),
        .o_opcode_x87_FXCH                          (fxch_flag),
        .o_opcode_x87_FFREE                         (),
        .o_opcode_x87_FST_STi                       (),
        .o_opcode_x87_FINCSTP                       (),
        .o_opcode_x87_FDECSTP                       (),
        .o_opcode_x87_FINIT                         (),
        .o_opcode_x87_FCLEX                         (),
        .o_opcode_x87_FNSTSW                        ()
    );

    stage_2_dec_x87_operand u_operand (
        .o_op_x87_is_memory                         (is_mem),
        .o_op_x87_is_reg_stack                      (),
        .o_op_x87_sti                               (sti),
        .o_op_x87_use_st0                           (),
        .o_op_x87_use_sti                           (),
        .o_op_x87_mem_real32                        (),
        .o_op_x87_mem_real64                        (),
        .o_op_x87_mem_int16                         (),
        .o_op_x87_mem_int32                         (),
        .o_op_x87_mem_int64                         (),
        .o_op_x87_mem_bcd                           (),
        .i_opcode_x87_FLD_load_real                 (1'b0),
        .i_opcode_x87_FST_store_real                (1'b0),
        .i_opcode_x87_FSTP_store_pop_real           (1'b0),
        .i_opcode_x87_FILD_load_int                 (1'b0),
        .i_opcode_x87_FIST_store_int                (1'b0),
        .i_opcode_x87_FISTP_store_pop_int           (1'b0),
        .i_opcode_x87_FADD                          (fadd_flag),
        .i_opcode_x87_FMUL                          (1'b0),
        .i_opcode_x87_FSUB                          (1'b0),
        .i_opcode_x87_FDIV                          (1'b0),
        .i_opcode_x87_FLD_STi                       (1'b0),
        .i_opcode_x87_FXCH                          (fxch_flag),
        .i_instruction                              (instruction)
    );

    stage_2_dec_x87_encode u_encode (
        .o_x87_any                                  (any_flag),
        .o_x87_exe_subop                            (exe_subop),
        .o_x87_mem_access                           (),
        .o_x87_is_store                             (is_store),
        .i_opcode_x87_FLD_load_real                 (1'b0),
        .i_opcode_x87_FST_store_real                (1'b0),
        .i_opcode_x87_FSTP_store_pop_real           (1'b0),
        .i_opcode_x87_FILD_load_int                 (1'b0),
        .i_opcode_x87_FIST_store_int                (1'b0),
        .i_opcode_x87_FISTP_store_pop_int           (1'b0),
        .i_opcode_x87_FADD                          (fadd_flag),
        .i_opcode_x87_FMUL                          (1'b0),
        .i_opcode_x87_FCOM                          (1'b0),
        .i_opcode_x87_FCOMP                         (1'b0),
        .i_opcode_x87_FSUB                          (1'b0),
        .i_opcode_x87_FSUBR                         (1'b0),
        .i_opcode_x87_FDIV                          (1'b0),
        .i_opcode_x87_FDIVR                         (1'b0),
        .i_opcode_x87_FLD_STi                       (1'b0),
        .i_opcode_x87_FXCH                          (fxch_flag),
        .i_opcode_x87_FST_STi                       (1'b0),
        .i_op_x87_is_memory                         (is_mem)
    );

    initial begin
        instruction[0] = 8'hD8;
        instruction[1] = 8'hC1;
        instruction[2] = 8'h00;
        instruction[3] = 8'h00;
        #1;
        if (!fadd_flag || !any_flag || (exe_subop != `EXE_X87_FADD) || (sti != 3'd1)) begin
            $display("FAIL D8 C1 FADD ST0,ST1 fadd=%b any=%b subop=%0d sti=%0d rm=%0d",
                     fadd_flag, any_flag, exe_subop, sti, instruction[1][2:0]);
            $finish(1);
        end

        instruction[0] = 8'hD9;
        instruction[1] = 8'hC9;
        #1;
        if (!fxch_flag || (exe_subop != `EXE_X87_FXCH)) begin
            $display("FAIL D9 C9 FXCH subop=%0d", exe_subop);
            $finish(1);
        end

        $display("PASS decode_x87_tb");
        $finish;
    end

endmodule
