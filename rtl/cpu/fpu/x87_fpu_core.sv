// ============================================================================
// Copyright (c) 2026 Chang Wei
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
// File : x87_fpu_core.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : x87 FPU control: decode EXE_X87 sub-ops, drive ST0-ST7
// ============================================================================

`include "openx86_defs.h.sv"

module x87_fpu_core (
    input  logic         i_valid,
    input  logic [ 5: 0] i_x87_subop,
    input  logic [ 2: 0] i_sti_index,
    input  logic [31: 0] i_mem_data,
    input  logic [79: 0] i_st0,
    input  logic [79: 0] i_st1,
    input  logic [79: 0] i_st2,
    input  logic [79: 0] i_st3,
    input  logic [79: 0] i_st4,
    input  logic [79: 0] i_st5,
    input  logic [79: 0] i_st6,
    input  logic [79: 0] i_st7,
    input  logic [15: 0] i_fcw,
    input  logic [15: 0] i_fsw,
    output logic [79: 0] o_st0,
    output logic [79: 0] o_st1,
    output logic [79: 0] o_st2,
    output logic [79: 0] o_st3,
    output logic [79: 0] o_st4,
    output logic [79: 0] o_st5,
    output logic [79: 0] o_st6,
    output logic [79: 0] o_st7,
    output logic         o_st0_we,
    output logic         o_st1_we,
    output logic         o_st2_we,
    output logic         o_st3_we,
    output logic         o_st4_we,
    output logic         o_st5_we,
    output logic         o_st6_we,
    output logic         o_st7_we,
    output logic [15: 0] o_fsw,
    output logic         o_fsw_we,
    output logic [15: 0] o_fcw,
    output logic         o_fcw_we,
    output logic         o_stack_push,
    output logic         o_stack_pop,
    output logic         o_mem_valid,
    output logic         o_mem_write_enable,
    output logic [31: 0] o_mem_wdata,
    output logic         o_fpu_exception,
    input  logic         clk,
    input  logic         rst_n
);

    logic [79: 0] st_phys [0: 7];
    logic [79: 0] st_next  [0: 7];
    logic [ 7: 0] st_we;
    logic [ 2: 0] stack_top;
    logic [ 2: 0] phys_sti;
    logic [79: 0] st0_val;
    logic [79: 0] sti_val;
    logic [79: 0] alu_result;
    logic [79: 0] ls_result;
    logic         alu_div0;
    logic [31: 0] ls_mem_data;
    logic         ls_mem_we;
    logic [15: 0] fsw_next;
    logic [ 2: 0] top_next;
    logic [15: 0] fcw_next;

    logic op_add;
    logic op_sub;
    logic op_mul;
    logic op_div;
    logic op_load;
    logic op_store;
    logic op_fld_sti;
    logic op_fxch;
    logic op_fldcw;
    logic op_fstcw;
    logic op_fstsw;
    logic op_finit;

    assign stack_top = i_fsw[11: 13];
    assign phys_sti  = stack_top + i_sti_index;

    assign st_phys[0] = i_st0;
    assign st_phys[1] = i_st1;
    assign st_phys[2] = i_st2;
    assign st_phys[3] = i_st3;
    assign st_phys[4] = i_st4;
    assign st_phys[5] = i_st5;
    assign st_phys[6] = i_st6;
    assign st_phys[7] = i_st7;

    assign st0_val = st_phys[stack_top];
    assign sti_val = st_phys[phys_sti[2: 0]];

    assign op_add     = i_x87_subop == `EXE_X87_FADD;
    assign op_sub     = (i_x87_subop == `EXE_X87_FSUB) | (i_x87_subop == `EXE_X87_FSUBR);
    assign op_mul     = i_x87_subop == `EXE_X87_FMUL;
    assign op_div     = (i_x87_subop == `EXE_X87_FDIV) | (i_x87_subop == `EXE_X87_FDIVR);
    assign op_load    = i_x87_subop == `EXE_X87_FLD;
    assign op_store   = (i_x87_subop == `EXE_X87_FST) | (i_x87_subop == `EXE_X87_FSTP);
    assign op_fld_sti = i_x87_subop == `EXE_X87_FLD_STI;
    assign op_fxch    = i_x87_subop == `EXE_X87_FXCH;
    assign op_fldcw   = i_x87_subop == `EXE_X87_FLDCW;
    assign op_fstcw   = i_x87_subop == `EXE_X87_FSTCW;
    assign op_fstsw   = i_x87_subop == `EXE_X87_FSTSW;
    assign op_finit   = i_x87_subop == `EXE_X87_FINIT;

    x87_fpu_alu u_alu (
        .i_op_add         (op_add),
        .i_op_sub         (op_sub),
        .i_op_mul         (op_mul),
        .i_op_div         (op_div),
        .i_st0            (st0_val),
        .i_sti            (sti_val),
        .o_result         (alu_result),
        .o_divide_by_zero (alu_div0),
        .o_invalid_op     ()
    );

    x87_fpu_load_store u_ls (
        .i_load             (op_load),
        .i_store            (op_store),
        .i_real64           (1'b0),
        .i_mem_data         (i_mem_data),
        .i_st_val           (st0_val),
        .o_st_val           (ls_result),
        .o_mem_data         (ls_mem_data),
        .o_mem_write_enable (ls_mem_we)
    );

    always_comb begin
        for (int k = 0; k < 8; k++) begin
            st_next[k] = st_phys[k];
        end
        st_we      = 8'h0;
        fsw_next   = i_fsw;
        fcw_next   = i_fcw;
        top_next   = stack_top;
        o_fsw_we   = 1'b0;
        o_fcw_we   = 1'b0;
        o_fpu_exception = 1'b0;

        if (i_valid) begin
            o_fpu_exception = alu_div0;
            if (alu_div0)
                fsw_next[14] = 1'b1;

            if (op_finit) begin
                fcw_next = 16'h037F;
                fsw_next = 16'h0000;
                o_fcw_we = 1'b1;
                o_fsw_we = 1'b1;
            end else if (op_fldcw) begin
                fcw_next = i_mem_data[15: 0];
                o_fcw_we = 1'b1;
            end else if (op_fxch) begin
                st_next[stack_top]       = st_phys[phys_sti[2: 0]];
                st_next[phys_sti[2: 0]]  = st_phys[stack_top];
                st_we[stack_top]         = 1'b1;
                st_we[phys_sti[2: 0]]    = 1'b1;
            end else if (op_fld_sti) begin
                st_next[stack_top] = sti_val;
                st_we[stack_top]   = 1'b1;
            end else if (op_load) begin
                st_next[stack_top] = ls_result;
                st_we[stack_top]   = 1'b1;
            end else if (op_add | op_sub | op_mul | op_div) begin
                st_next[stack_top] = alu_result;
                st_we[stack_top]   = 1'b1;
            end

            if (i_x87_subop == `EXE_X87_FSTP) begin
                top_next         = stack_top + 3'd1;
                fsw_next[11: 13] = top_next;
                o_fsw_we         = 1'b1;
            end
        end
    end

    assign o_st0 = st_next[0];
    assign o_st1 = st_next[1];
    assign o_st2 = st_next[2];
    assign o_st3 = st_next[3];
    assign o_st4 = st_next[4];
    assign o_st5 = st_next[5];
    assign o_st6 = st_next[6];
    assign o_st7 = st_next[7];
    assign o_fsw = fsw_next;
    assign o_fcw = fcw_next;

    assign o_st0_we = i_valid & st_we[0];
    assign o_st1_we = i_valid & st_we[1];
    assign o_st2_we = i_valid & st_we[2];
    assign o_st3_we = i_valid & st_we[3];
    assign o_st4_we = i_valid & st_we[4];
    assign o_st5_we = i_valid & st_we[5];
    assign o_st6_we = i_valid & st_we[6];
    assign o_st7_we = i_valid & st_we[7];

    always_comb begin
        o_stack_push       = 1'b0;
        o_stack_pop        = (i_x87_subop == `EXE_X87_FSTP);
        o_mem_valid        = i_valid & (op_fstcw | op_fstsw | ls_mem_we);
        o_mem_write_enable = op_fstcw | op_fstsw | ls_mem_we;
        if (op_fstcw)
            o_mem_wdata = {16'h0, i_fcw};
        else if (op_fstsw)
            o_mem_wdata = {16'h0, i_fsw};
        else
            o_mem_wdata = ls_mem_data;
    end

endmodule
