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
//  File        : stage_4_reg_read_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Testbench for stage_4_reg_read module
// ============================================================================

`timescale 1ns/1ps

module stage_4_reg_read_tb;

    // ============================================================
    // Clock and reset
    // ============================================================
    logic clk;
    logic rst_n;

    // ============================================================
    // Pipeline handshake
    // ============================================================
    logic i_uop_valid;
    micro_op_t i_uop;
    logic o_stage3_ready;
    logic o_stage_ready;
    logic o_stage_valid;
    logic i_exu_ready;

    // ============================================================
    // Pipeline control
    // ============================================================
    logic i_flush;

    // ============================================================
    // GPR read data
    // ============================================================
    logic [31: 0] i_gpr_eax;
    logic [31: 0] i_gpr_ebx;
    logic [31: 0] i_gpr_ecx;
    logic [31: 0] i_gpr_edx;
    logic [31: 0] i_gpr_esp;
    logic [31: 0] i_gpr_ebp;
    logic [31: 0] i_gpr_esi;
    logic [31: 0] i_gpr_edi;

    // ============================================================
    // Flags
    // ============================================================
    logic i_flag_cf;
    logic i_flag_pf;
    logic i_flag_af;
    logic i_flag_zf;
    logic i_flag_sf;
    logic i_flag_of;

    // ============================================================
    // Outputs
    // ============================================================
    micro_op_t o_uop;
    logic [31: 0] o_src1_data;
    logic [31: 0] o_src2_data;
    logic o_flag_cf;
    logic o_flag_pf;
    logic o_flag_af;
    logic o_flag_zf;
    logic o_flag_sf;
    logic o_flag_of;

    // ============================================================
    // DUT instantiation
    // ============================================================
    stage_4_reg dut (
        .i_uop_valid   ( i_uop_valid   ),
        .i_uop         ( i_uop         ),
        .o_stage3_ready( o_stage3_ready),
        .o_stage_ready ( o_stage_ready ),
        .o_stage_valid ( o_stage_valid ),
        .i_exu_ready   ( i_exu_ready   ),
        .i_flush       ( i_flush       ),
        .i_gpr_eax     ( i_gpr_eax     ),
        .i_gpr_ebx     ( i_gpr_ebx     ),
        .i_gpr_ecx     ( i_gpr_ecx     ),
        .i_gpr_edx     ( i_gpr_edx     ),
        .i_gpr_esp     ( i_gpr_esp     ),
        .i_gpr_ebp     ( i_gpr_ebp     ),
        .i_gpr_esi     ( i_gpr_esi     ),
        .i_gpr_edi     ( i_gpr_edi     ),
        .i_flag_cf     ( i_flag_cf     ),
        .i_flag_pf     ( i_flag_pf     ),
        .i_flag_af     ( i_flag_af     ),
        .i_flag_zf     ( i_flag_zf     ),
        .i_flag_sf     ( i_flag_sf     ),
        .i_flag_of     ( i_flag_of     ),
        .o_uop         ( o_uop         ),
        .o_src1_data   ( o_src1_data   ),
        .o_src2_data   ( o_src2_data   ),
        .o_flag_cf     ( o_flag_cf     ),
        .o_flag_pf     ( o_flag_pf     ),
        .o_flag_af     ( o_flag_af     ),
        .o_flag_zf     ( o_flag_zf     ),
        .o_flag_sf     ( o_flag_sf     ),
        .o_flag_of     ( o_flag_of     ),
        .clk           ( clk           ),
        .rst_n         ( rst_n         )
    );

    // ============================================================
    // Clock generation
    // ============================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ============================================================
    // Test stimulus
    // ============================================================
    initial begin
        // Reset
        rst_n = 0;
        i_uop_valid = 0;
        i_uop = '0;
        i_exu_ready = 0;
        i_flush = 0;
        i_gpr_eax = 32'h11111111;
        i_gpr_ebx = 32'h22222222;
        i_gpr_ecx = 32'h33333333;
        i_gpr_edx = 32'h44444444;
        i_gpr_esp = 32'h55555555;
        i_gpr_ebp = 32'h66666666;
        i_gpr_esi = 32'h77777777;
        i_gpr_edi = 32'h88888888;
        i_flag_cf = 0;
        i_flag_pf = 0;
        i_flag_af = 0;
        i_flag_zf = 0;
        i_flag_sf = 0;
        i_flag_of = 0;

        #20;
        rst_n = 1;
        #20;

        // Test 1: Read from EAX (index 0) and ECX (index 1)
        $display("Test 1: Read from EAX and ECX");
        i_uop_valid = 1;
        i_uop.uop_opcode = `UOP_ADD;
        i_uop.uop_src1_reg = 3'b000;  // EAX
        i_uop.uop_src2_reg = 3'b001;  // ECX
        i_exu_ready = 1;
        #20;
        i_uop_valid = 0;
        #20;
        $display("src1_data = %h (expected 11111111)", o_src1_data);
        $display("src2_data = %h (expected 33333333)", o_src2_data);
        assert(o_src1_data == 32'h11111111) else $error("src1_data mismatch");
        assert(o_src2_data == 32'h33333333) else $error("src2_data mismatch");

        // Test 2: Read from EDX (index 2) and EBX (index 3)
        $display("Test 2: Read from EDX and EBX");
        i_uop_valid = 1;
        i_uop.uop_src1_reg = 3'b010;  // EDX
        i_uop.uop_src2_reg = 3'b011;  // EBX
        #20;
        i_uop_valid = 0;
        #20;
        $display("src1_data = %h (expected 44444444)", o_src1_data);
        $display("src2_data = %h (expected 22222222)", o_src2_data);
        assert(o_src1_data == 32'h44444444) else $error("src1_data mismatch");
        assert(o_src2_data == 32'h22222222) else $error("src2_data mismatch");

        // Test 3: Read from ESP (index 4) and EBP (index 5)
        $display("Test 3: Read from ESP and EBP");
        i_uop_valid = 1;
        i_uop.uop_src1_reg = 3'b100;  // ESP
        i_uop.uop_src2_reg = 3'b101;  // EBP
        #20;
        i_uop_valid = 0;
        #20;
        $display("src1_data = %h (expected 55555555)", o_src1_data);
        $display("src2_data = %h (expected 66666666)", o_src2_data);
        assert(o_src1_data == 32'h55555555) else $error("src1_data mismatch");
        assert(o_src2_data == 32'h66666666) else $error("src2_data mismatch");

        // Test 4: Read from ESI (index 6) and EDI (index 7)
        $display("Test 4: Read from ESI and EDI");
        i_uop_valid = 1;
        i_uop.uop_src1_reg = 3'b110;  // ESI
        i_uop.uop_src2_reg = 3'b111;  // EDI
        #20;
        i_uop_valid = 0;
        #20;
        $display("src1_data = %h (expected 77777777)", o_src1_data);
        $display("src2_data = %h (expected 88888888)", o_src2_data);
        assert(o_src1_data == 32'h77777777) else $error("src1_data mismatch");
        assert(o_src2_data == 32'h88888888) else $error("src2_data mismatch");

        // Test 5: Flush
        $display("Test 5: Flush");
        i_uop_valid = 1;
        i_flush = 1;
        #20;
        i_flush = 0;
        i_uop_valid = 0;
        #20;
        assert(o_stage_valid == 0) else $error("stage_valid should be 0 after flush");

        $display("PASS stage_4_reg_read");
        $finish;
    end

endmodule
