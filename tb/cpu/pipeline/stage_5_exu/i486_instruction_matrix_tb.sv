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
//  File        : i486_instruction_matrix_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ROM-driven instruction matrix smoke test for exu_dispatcher
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module i486_instruction_matrix_tb;

    typedef struct packed {
        logic [ 5: 0] opcode;
        logic [31: 0] src1;
        logic [31: 0] src2;
        logic [31: 0] imm;
        logic [31: 0] disp;
        logic         has_imm;
        logic         has_disp;
        logic [ 3: 0] tttn;
        logic         cf_in;
        logic         pf_in;
        logic         zf_in;
        logic         sf_in;
        logic         of_in;
        logic [31: 0] exp_result;
        logic         exp_handled;
        logic         check_flags;
        logic         exp_cf;
        logic         exp_zf;
        logic         exp_write_ip;
        logic [31: 0] exp_ip;
        logic         exp_mem_valid;
        logic         exp_mem_we;
    } matrix_entry_t;

    localparam int LP_NUM_TESTS = 16;

    matrix_entry_t rom [0: LP_NUM_TESTS - 1];

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
        .i_ecx          (32'd0),
        .i_cf           (cf_in),
        .i_has_imm      (has_imm),
        .i_has_disp     (has_disp),
        .i_mem_access   (mem_access),
        .i_is_store     (is_store),
        .i_mem_size     (2'b10),
        .i_agu_base     (1'b0),
        .i_agu_index    (1'b0),
        .i_sib_scale    (2'b00),
        .i_tttn         (tttn),
        .i_pf           (pf_in),
        .i_af           (af_in),
        .i_zf           (zf_in),
        .i_sf           (sf_in),
        .i_of           (of_in),
        .i_df           (1'b0),
        .i_rep          (1'b0),
        .i_repne        (1'b0),
        .i_dividend     (dividend),
        .i_cpuid_eax    (cpuid_eax),
        .o_handled      (handled),
        .o_dispatch     (dispatch),
        .o_result_high  ()
    );

    task automatic init_rom;
        rom[0]  = '{opcode: `UOP_ADD, src1: 32'd100, src2: 32'd23, imm: 32'd0,
                    disp: 32'd0, has_imm: 1'b0, has_disp: 1'b0, tttn: 4'h0,
                    cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b0, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'd123, exp_handled: 1'b1, check_flags: 1'b0,
                    exp_cf: 1'b0, exp_zf: 1'b0, exp_write_ip: 1'b0, exp_ip: 32'd0,
                    exp_mem_valid: 1'b0, exp_mem_we: 1'b0};
        rom[1]  = '{opcode: `UOP_MUL, src1: 32'd1000, src2: 32'd7, imm: 32'd0,
                    disp: 32'd0, has_imm: 1'b0, has_disp: 1'b0, tttn: 4'h0,
                    cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b0, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'd7000, exp_handled: 1'b1, check_flags: 1'b1,
                    exp_cf: 1'b0, exp_zf: 1'b0, exp_write_ip: 1'b0, exp_ip: 32'd0,
                    exp_mem_valid: 1'b0, exp_mem_we: 1'b0};
        rom[2]  = '{opcode: `UOP_IMUL, src1: 32'hFFFF_FFFF, src2: 32'd2, imm: 32'd0,
                    disp: 32'd0, has_imm: 1'b0, has_disp: 1'b0, tttn: 4'h0,
                    cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b0, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'hFFFF_FFFE, exp_handled: 1'b1, check_flags: 1'b0,
                    exp_cf: 1'b0, exp_zf: 1'b0, exp_write_ip: 1'b0, exp_ip: 32'd0,
                    exp_mem_valid: 1'b0, exp_mem_we: 1'b0};
        rom[3]  = '{opcode: `UOP_DIV, src1: 32'h0000_0100, src2: 32'h0000_0100, imm: 32'd0,
                    disp: 32'd0, has_imm: 1'b0, has_disp: 1'b0, tttn: 4'h0,
                    cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b0, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'd1, exp_handled: 1'b1, check_flags: 1'b0,
                    exp_cf: 1'b0, exp_zf: 1'b0, exp_write_ip: 1'b0, exp_ip: 32'd0,
                    exp_mem_valid: 1'b0, exp_mem_we: 1'b0};
        rom[4]  = '{opcode: `UOP_BT, src1: 32'h0000_0008, src2: 32'd3, imm: 32'd0,
                    disp: 32'd0, has_imm: 1'b0, has_disp: 1'b0, tttn: 4'h0,
                    cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b0, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'd0, exp_handled: 1'b1, check_flags: 1'b1,
                    exp_cf: 1'b1, exp_zf: 1'b0, exp_write_ip: 1'b0, exp_ip: 32'd0,
                    exp_mem_valid: 1'b0, exp_mem_we: 1'b0};
        rom[5]  = '{opcode: `UOP_BSF, src1: 32'h0000_0010, src2: 32'd0, imm: 32'd0,
                    disp: 32'd0, has_imm: 1'b0, has_disp: 1'b0, tttn: 4'h0,
                    cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b0, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'd4, exp_handled: 1'b1, check_flags: 1'b1,
                    exp_cf: 1'b0, exp_zf: 1'b0, exp_write_ip: 1'b0, exp_ip: 32'd0,
                    exp_mem_valid: 1'b0, exp_mem_we: 1'b0};
        rom[6]  = '{opcode: `UOP_BSR, src1: 32'h8000_0000, src2: 32'd0, imm: 32'd0,
                    disp: 32'd0, has_imm: 1'b0, has_disp: 1'b0, tttn: 4'h0,
                    cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b0, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'd31, exp_handled: 1'b1, check_flags: 1'b0,
                    exp_cf: 1'b0, exp_zf: 1'b0, exp_write_ip: 1'b0, exp_ip: 32'd0,
                    exp_mem_valid: 1'b0, exp_mem_we: 1'b0};
        rom[7]  = '{opcode: `UOP_XADD, src1: 32'd5, src2: 32'd7, imm: 32'd0,
                    disp: 32'd0, has_imm: 1'b0, has_disp: 1'b0, tttn: 4'h0,
                    cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b0, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'd12, exp_handled: 1'b1, check_flags: 1'b0,
                    exp_cf: 1'b0, exp_zf: 1'b0, exp_write_ip: 1'b0, exp_ip: 32'd0,
                    exp_mem_valid: 1'b0, exp_mem_we: 1'b0};
        rom[8]  = '{opcode: `UOP_CMPXCHG, src1: 32'd10, src2: 32'd10, imm: 32'd0,
                    disp: 32'd0, has_imm: 1'b0, has_disp: 1'b0, tttn: 4'h0,
                    cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b0, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'd10, exp_handled: 1'b1, check_flags: 1'b1,
                    exp_cf: 1'b0, exp_zf: 1'b1, exp_write_ip: 1'b0, exp_ip: 32'd0,
                    exp_mem_valid: 1'b0, exp_mem_we: 1'b0};
        rom[9]  = '{opcode: `UOP_SETCC, src1: 32'd0, src2: 32'd0, imm: 32'd0,
                    disp: 32'd0, has_imm: 1'b0, has_disp: 1'b0, tttn: 4'h4,
                    cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b1, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'd1, exp_handled: 1'b1, check_flags: 1'b0,
                    exp_cf: 1'b0, exp_zf: 1'b0, exp_write_ip: 1'b0, exp_ip: 32'd0,
                    exp_mem_valid: 1'b0, exp_mem_we: 1'b0};
        // Unconditional JMP: has_imm && imm[0]; target in src1 (not imm).
        rom[10] = '{opcode: `UOP_BRANCH, src1: 32'h0000_2000, src2: 32'd0, imm: 32'h0000_0001,
                    disp: 32'd0, has_imm: 1'b1, has_disp: 1'b0, tttn: 4'h0,
                    cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b0, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'h0000_2000, exp_handled: 1'b1, check_flags: 1'b0,
                    exp_cf: 1'b0, exp_zf: 1'b0, exp_write_ip: 1'b1, exp_ip: 32'h0000_2000,
                    exp_mem_valid: 1'b0, exp_mem_we: 1'b0};
        rom[11] = '{opcode: `UOP_PUSH, src1: 32'hDEAD_BEEF, src2: 32'h0001_0000,
                    imm: 32'd0, disp: 32'd0, has_imm: 1'b0, has_disp: 1'b0, tttn: 4'h0,
                    cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b0, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'h0000_FFFC, exp_handled: 1'b1, check_flags: 1'b0,
                    exp_cf: 1'b0, exp_zf: 1'b0, exp_write_ip: 1'b0, exp_ip: 32'd0,
                    exp_mem_valid: 1'b1, exp_mem_we: 1'b1};
        rom[12] = '{opcode: `UOP_CALL, src1: 32'h0000_1004, src2: 32'h0000_1000,
                    imm: 32'h0000_2000, disp: 32'd0, has_imm: 1'b1, has_disp: 1'b0,
                    tttn: 4'h0, cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b0, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'h0000_0FFC, exp_handled: 1'b1, check_flags: 1'b0,
                    exp_cf: 1'b0, exp_zf: 1'b0, exp_write_ip: 1'b0, exp_ip: 32'h0000_2000,
                    exp_mem_valid: 1'b1, exp_mem_we: 1'b1};
        rom[13] = '{opcode: `UOP_MISC, src1: 32'h1234_5678, src2: 32'd0,
                    imm: {24'd0, `MISC_SUB_BSWAP}, disp: 32'd0,
                    has_imm: 1'b1, has_disp: 1'b0, tttn: 4'h0,
                    cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b0, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'h7856_3412, exp_handled: 1'b1, check_flags: 1'b0,
                    exp_cf: 1'b0, exp_zf: 1'b0, exp_write_ip: 1'b0, exp_ip: 32'd0,
                    exp_mem_valid: 1'b0, exp_mem_we: 1'b0};
        rom[14] = '{opcode: `UOP_MISC, src1: 32'd0, src2: 32'd0,
                    imm: {24'd0, `MISC_SUB_CPUID}, disp: 32'd0,
                    has_imm: 1'b1, has_disp: 1'b0, tttn: 4'h0,
                    cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b0, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'h0000_0001, exp_handled: 1'b1, check_flags: 1'b0,
                    exp_cf: 1'b0, exp_zf: 1'b0, exp_write_ip: 1'b0, exp_ip: 32'd0,
                    exp_mem_valid: 1'b0, exp_mem_we: 1'b0};
        rom[15] = '{opcode: `UOP_FLAG_CTRL, src1: 32'd0, src2: 32'd0,
                    imm: 32'h0000_0002, disp: 32'd0, has_imm: 1'b1, has_disp: 1'b0,
                    tttn: 4'h0, cf_in: 1'b0, pf_in: 1'b0, zf_in: 1'b0, sf_in: 1'b0, of_in: 1'b0,
                    exp_result: 32'd0, exp_handled: 1'b1, check_flags: 1'b1,
                    exp_cf: 1'b1, exp_zf: 1'b0, exp_write_ip: 1'b0, exp_ip: 32'd0,
                    exp_mem_valid: 1'b0, exp_mem_we: 1'b0};
    endtask

    task automatic run_case(input int idx);
        matrix_entry_t entry;
        begin
            entry = rom[idx];
            valid      = 1'b1;
            opcode     = entry.opcode;
            src1       = entry.src1;
            src2       = entry.src2;
            imm        = entry.imm;
            disp       = entry.disp;
            has_imm    = entry.has_imm;
            has_disp   = entry.has_disp;
            tttn       = entry.tttn;
            cf_in      = entry.cf_in;
            pf_in      = entry.pf_in;
            zf_in      = entry.zf_in;
            sf_in      = entry.sf_in;
            of_in      = entry.of_in;
            mem_access = 1'b0;
            is_store   = 1'b0;
            // DIV/IDIV: src1=divisor, DX:AX/EDX:EAX via i_dividend (use src2 as low half)
            if ((entry.opcode == `UOP_DIV) || (entry.opcode == `UOP_IDIV))
                dividend = {32'h0, entry.src2};
            else
                dividend = {entry.src1, entry.src2};
            cpuid_eax  = 32'h0000_0001;
            af_in      = 1'b0;
            #1;
            if (handled !== entry.exp_handled) begin
                $display("FAIL case %0d: handled=%b exp=%b opcode=%0d", idx, handled, entry.exp_handled, entry.opcode);
                $finish(1);
            end
            if (entry.exp_handled && (dispatch.data.result !== entry.exp_result)) begin
                $display("FAIL case %0d: result=%h exp=%h opcode=%0d", idx, dispatch.data.result, entry.exp_result, entry.opcode);
                $finish(1);
            end
            if (entry.check_flags && (dispatch.data.cf !== entry.exp_cf)) begin
                $display("FAIL case %0d: cf=%b exp=%b", idx, dispatch.data.cf, entry.exp_cf);
                $finish(1);
            end
            if (entry.check_flags && (dispatch.data.zf !== entry.exp_zf)) begin
                $display("FAIL case %0d: zf=%b exp=%b", idx, dispatch.data.zf, entry.exp_zf);
                $finish(1);
            end
            if (dispatch.write_ip !== entry.exp_write_ip) begin
                $display("FAIL case %0d: write_ip=%b exp=%b", idx, dispatch.write_ip, entry.exp_write_ip);
                $finish(1);
            end
            if (entry.exp_write_ip && (dispatch.ip_data !== entry.exp_ip)) begin
                $display("FAIL case %0d: ip=%h exp=%h", idx, dispatch.ip_data, entry.exp_ip);
                $finish(1);
            end
            if (dispatch.data.mem_valid !== entry.exp_mem_valid) begin
                $display("FAIL case %0d: mem_valid=%b exp=%b", idx, dispatch.data.mem_valid, entry.exp_mem_valid);
                $finish(1);
            end
            if (dispatch.data.mem_write_enable !== entry.exp_mem_we) begin
                $display("FAIL case %0d: mem_we=%b exp=%b", idx, dispatch.data.mem_write_enable, entry.exp_mem_we);
                $finish(1);
            end
            valid = 1'b0;
        end
    endtask

    initial begin
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
        init_rom();
        for (int i = 0; i < LP_NUM_TESTS; i++) begin
            run_case(i);
        end
        $display("PASS i486_instruction_matrix_tb (%0d cases)", LP_NUM_TESTS);
        $finish(0);
    end

endmodule
