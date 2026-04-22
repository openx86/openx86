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
//  File        : execute_unit_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : execute_unit_tb module
// ============================================================================

// ============================================================================
// execute_unit 瀛愭ā鍧楀啋鐑熶豢鐪燂紙闇€ iverilog -g2012锛?
// ============================================================================

`timescale 1ns/1ns

module execute_unit_tb;

    logic clk;

    logic [31: 0] eff;
    logic [31: 0] br_tgt;
    logic        br_taken;
    logic [31: 0] md_lo, md_hi;
    logic        md_div0;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    agu_lsu_address_generation_unit u_agu (
        .i_base              ( 32'h1000 ),
        .i_index             ( 32'h2 ),
        .i_scale             ( 2'd2 ),
        .i_disp              ( -32'sd4 ),
        .o_effective_address ( eff )
    );

    branch_execute_branch_unit u_br (
        .i_is_jcc     ( 1'b1 ),
        .i_jcc_nibble ( 4'h4 ),
        .i_CF         ( 1'b0 ),
        .i_PF         ( 1'b0 ),
        .i_ZF         ( 1'b1 ),
        .i_SF         ( 1'b0 ),
        .i_OF         ( 1'b0 ),
        .i_eip        ( 32'h1000 ),
        .i_rel32      ( 32'h10 ),
        .i_rel8       ( 8'h0 ),
        .i_use_rel8   ( 1'b0 ),
        .o_taken      ( br_taken ),
        .o_target_eip ( br_tgt )
    );

    muldiv_execute_muldiv_unit u_md (
        .i_op   ( 3'd1 ),
        .i_lo   ( 32'd1000 ),
        .i_hi   ( 32'h0 ),
        .i_src  ( 32'd7 ),
        .o_lo   ( md_lo ),
        .o_hi   ( md_hi ),
        .o_div0 ( md_div0 )
    );

    initial begin
        #1;
        if (eff !== 32'h1004) begin
            $display("FAIL AGU eff=%h", eff);
            $finish(1);
        end
        if (!br_taken || br_tgt !== 32'h1010) begin
            $display("FAIL branch");
            $finish(1);
        end
        if (md_lo !== 32'd7000 || md_hi !== 32'h0) begin
            $display("FAIL mul %h %h", md_lo, md_hi);
            $finish(1);
        end
        $display("execute_unit_tb PASS");
        $finish;
    end

endmodule

