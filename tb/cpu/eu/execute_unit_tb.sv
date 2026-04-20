/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements execute_unit_tb.
*/
// ============================================================================
// execute_unit 子模块冒烟仿真（需 iverilog -g2012）
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

    eu_agu_lsu_address_generation_unit u_agu (
        .i_base              ( 32'h1000 ),
        .i_index             ( 32'h2 ),
        .i_scale             ( 2'd2 ),
        .i_disp              ( -32'sd4 ),
        .o_effective_address ( eff )
    );

    eu_branch_execute_branch_unit u_br (
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

    eu_muldiv_execute_muldiv_unit u_md (
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
