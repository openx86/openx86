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
//  File        : exu_dispatcher_alu_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Smoke test for exu_dispatcher ALU/MOV datapath
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_dispatcher_alu_tb;

    logic         clk;
    logic         rst_n;
    logic         valid;
    logic [ 5: 0] opcode;
    logic [31: 0] src1;
    logic [31: 0] src2;
    logic [31: 0] imm;
    logic [31: 0] disp;
    logic         cf_in;
    logic         pf_in;
    logic         af_in;
    logic         zf_in;
    logic         sf_in;
    logic         of_in;
    logic         has_imm;
    logic         has_disp;
    logic         mem_access;
    logic         is_store;
    logic [ 3: 0] tttn;
    logic [63: 0] dividend;
    logic [31: 0] cpuid_eax;
    logic         handled;
    exu_dispatch_out_t dispatch;

    exu_dispatcher u_dut (
        .i_valid        (valid),
        .i_uop_opcode   (opcode),
        .i_src1_data    (src1),
        .i_src2_data    (src2),
        .i_immediate    (imm),
        .i_displacement (disp),
        .i_cf           (cf_in),
        .i_has_imm      (has_imm),
        .i_has_disp     (has_disp),
        .i_mem_access   (mem_access),
        .i_is_store     (is_store),
        .i_tttn         (tttn),
        .i_pf           (pf_in),
        .i_af           (af_in),
        .i_zf           (zf_in),
        .i_sf           (sf_in),
        .i_of           (of_in),
        .i_dividend     (dividend),
        .i_cpuid_eax    (cpuid_eax),
        .o_handled      (handled),
        .o_dispatch     (dispatch)
    );

    task automatic check_add;
        valid      = 1'b1;
        opcode     = `UOP_ADD;
        src1       = 32'd10;
        src2       = 32'd32;
        imm        = 32'd0;
        disp       = 32'd0;
        cf_in      = 1'b0;
        pf_in      = 1'b0;
        af_in      = 1'b0;
        zf_in      = 1'b0;
        sf_in      = 1'b0;
        of_in      = 1'b0;
        has_imm    = 1'b0;
        has_disp   = 1'b0;
        mem_access = 1'b0;
        is_store   = 1'b0;
        tttn       = 4'h0;
        dividend   = 64'd0;
        cpuid_eax  = 32'd0;
        #1;
        if (~handled) begin
            $display("FAIL: ADD not handled");
            $finish(1);
        end
        if (dispatch.data.result !== 32'd42) begin
            $display("FAIL: ADD result %0d", dispatch.data.result);
            $finish(1);
        end
        if (~dispatch.write_gpr || ~dispatch.write_flags) begin
            $display("FAIL: ADD write enables");
            $finish(1);
        end
        valid = 1'b0;
    endtask

    task automatic check_mov_imm;
        valid      = 1'b1;
        opcode     = `UOP_MOV;
        src1       = 32'd0;
        src2       = 32'd0;
        imm        = 32'h12345678;
        disp       = 32'd0;
        has_imm    = 1'b1;
        mem_access = 1'b0;
        #1;
        if (~handled) begin
            $display("FAIL: MOV imm not handled");
            $finish(1);
        end
        if (dispatch.data.result !== 32'h12345678) begin
            $display("FAIL: MOV imm result %h", dispatch.data.result);
            $finish(1);
        end
        valid = 1'b0;
    endtask

    task automatic check_cmp;
        valid      = 1'b1;
        opcode     = `UOP_CMP;
        src1       = 32'd5;
        src2       = 32'd5;
        has_imm    = 1'b0;
        mem_access = 1'b0;
        #1;
        if (~handled) begin
            $display("FAIL: CMP not handled");
            $finish(1);
        end
        if (~dispatch.write_flags || dispatch.write_gpr) begin
            $display("FAIL: CMP should only write flags");
            $finish(1);
        end
        if (~dispatch.data.zf) begin
            $display("FAIL: CMP ZF not set");
            $finish(1);
        end
        valid = 1'b0;
    endtask

    initial begin
        clk        = 1'b0;
        rst_n      = 1'b1;
        valid      = 1'b0;
        opcode     = 6'd0;
        src1       = 32'd0;
        src2       = 32'd0;
        imm        = 32'd0;
        disp       = 32'd0;
        cf_in      = 1'b0;
        pf_in      = 1'b0;
        af_in      = 1'b0;
        zf_in      = 1'b0;
        sf_in      = 1'b0;
        of_in      = 1'b0;
        has_imm    = 1'b0;
        has_disp   = 1'b0;
        mem_access = 1'b0;
        is_store   = 1'b0;
        tttn       = 4'h0;
        dividend   = 64'd0;
        cpuid_eax  = 32'd0;
        check_add();
        check_mov_imm();
        check_cmp();
        $display("PASS exu_dispatcher_alu");
        $finish(0);
    end

endmodule
