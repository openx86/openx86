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
//  File        : x87_fpu_core.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : x87 FPU control: decode EXE_X87 sub-ops, drive ST0/ST1
// ============================================================================

`include "openx86_defs.h.sv"

module x87_fpu_core (
    input  logic         i_valid,
    input  logic [ 4: 0] i_x87_subop,
    input  logic [ 2: 0] i_sti_index,
    input  logic [31: 0] i_mem_data,
    input  logic [79: 0] i_st0,
    input  logic [79: 0] i_st1,
    output logic [79: 0] o_st0,
    output logic [79: 0] o_st1,
    output logic         o_stack_push,
    output logic         o_stack_pop,
    output logic         o_mem_valid,
    output logic         o_mem_write_enable,
    output logic [31: 0] o_mem_wdata,
    output logic         o_fpu_exception,
    input  logic         clk,
    input  logic         rst_n
);

    logic [63: 0] st0_mant;
    logic [63: 0] st1_mant;
    logic [63: 0] sti_mant;
    logic         st0_sign;
    logic         sti_sign;
    logic [63: 0] alu_mant;
    logic         alu_sign;
    logic         alu_div0;
    logic [63: 0] ls_mant;
    logic [31: 0] ls_mem_data;
    logic         ls_mem_we;

    logic op_add;
    logic op_sub;
    logic op_mul;
    logic op_div;
    logic op_load;
    logic op_store;
    logic op_fld_sti;
    logic op_fxch;

    assign st0_mant = i_st0[62: 0];
    assign st1_mant = i_st1[62: 0];
    assign st0_sign = i_st0[79];
    assign sti_mant = (i_sti_index == 3'd1) ? st1_mant : st0_mant;
    assign sti_sign = (i_sti_index == 3'd1) ? i_st1[79] : i_st0[79];

    assign op_add     = i_x87_subop == `EXE_X87_FADD;
    assign op_sub     = (i_x87_subop == `EXE_X87_FSUB) | (i_x87_subop == `EXE_X87_FSUBR);
    assign op_mul     = i_x87_subop == `EXE_X87_FMUL;
    assign op_div     = (i_x87_subop == `EXE_X87_FDIV) | (i_x87_subop == `EXE_X87_FDIVR);
    assign op_load    = i_x87_subop == `EXE_X87_FLD;
    assign op_store   = (i_x87_subop == `EXE_X87_FST) | (i_x87_subop == `EXE_X87_FSTP);
    assign op_fld_sti = i_x87_subop == `EXE_X87_FLD_STI;
    assign op_fxch    = i_x87_subop == `EXE_X87_FXCH;

    x87_fpu_alu u_alu (
        .i_op_add         (op_add),
        .i_op_sub         (op_sub),
        .i_op_mul         (op_mul),
        .i_op_div         (op_div),
        .i_st0_mant       (st0_mant),
        .i_sti_mant       (sti_mant),
        .i_st0_sign       (st0_sign),
        .i_sti_sign       (sti_sign),
        .o_result_mant    (alu_mant),
        .o_result_sign    (alu_sign),
        .o_divide_by_zero (alu_div0),
        .o_invalid_op     ()
    );

    x87_fpu_load_store u_ls (
        .i_load           (op_load),
        .i_store          (op_store),
        .i_real64         (1'b0),
        .i_mem_data       (i_mem_data),
        .i_st_mant        (st0_mant),
        .o_st_mant        (ls_mant),
        .o_mem_data       (ls_mem_data),
        .o_mem_write_enable (ls_mem_we)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            o_st0           <= 80'h0;
            o_st1           <= 80'h0;
            o_fpu_exception <= 1'b0;
        end else if (i_valid) begin
            o_fpu_exception <= alu_div0;
            if (op_fxch) begin
                o_st0 <= i_st1;
                o_st1 <= i_st0;
            end else if (op_fld_sti) begin
                o_st0[62: 0] <= sti_mant;
                o_st0[79]    <= sti_sign;
            end else if (op_load) begin
                o_st0[62: 0] <= ls_mant;
                o_st0[79]    <= st0_sign;
            end else if (op_add | op_sub | op_mul | op_div) begin
                o_st0[62: 0] <= alu_mant;
                o_st0[79]    <= alu_sign;
            end
        end
    end

    always_comb begin
        o_stack_push       = 1'b0;
        o_stack_pop        = (i_x87_subop == `EXE_X87_FSTP);
        o_mem_valid        = 1'b0;
        o_mem_write_enable = ls_mem_we;
        o_mem_wdata        = ls_mem_data;
    end

endmodule
