/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_misc_exchange_status_tb.
*/
`timescale 1ns/1ns

module eu_misc_exchange_status_tb;
    logic [31: 0] eax_in;
    logic [31: 0] flags_in;
    logic [31: 0] eax_out;
    logic [31: 0] flags_out;

    logic [31: 0] xchg_a;
    logic [31: 0] xchg_b;
    logic [31: 0] xchg_y;

    logic [31: 0] xadd_a;
    logic [31: 0] xadd_b;
    logic [31: 0] xadd_y;

    logic [31: 0] cmpxchg_acc;
    logic [31: 0] cmpxchg_dst;
    logic [31: 0] cmpxchg_src;
    logic [31: 0] cmpxchg_y;
    logic        cmpxchg_zf;

    stage_3_exe_misc_lahf u_lahf (
        .eax_in ( eax_in ),
        .flags_in ( flags_in ),
        .eax_out ( eax_out )
    );

    stage_3_exe_misc_sahf u_sahf (
        .flags_in ( flags_in ),
        .eax_in ( eax_in ),
        .flags_out ( flags_out )
    );

    stage_3_exe_misc_xchg u_xchg (
        .a ( xchg_a ),
        .b ( xchg_b ),
        .y ( xchg_y )
    );

    stage_3_exe_misc_xadd u_xadd (
        .a ( xadd_a ),
        .b ( xadd_b ),
        .y ( xadd_y )
    );

    stage_3_exe_misc_cmpxchg u_cmpxchg (
        .acc ( cmpxchg_acc ),
        .dst ( cmpxchg_dst ),
        .src ( cmpxchg_src ),
        .y ( cmpxchg_y ),
        .zf ( cmpxchg_zf )
    );

    initial begin
        eax_in = 32'hA1B2_C3D4;
        flags_in = 32'h0000_00D4;
        #1;
        if (eax_out !== 32'hA1B2_D5D4) begin
            $display("FAIL stage_3_exe_misc_lahf");
            $finish(1);
        end

        eax_in = 32'h0000_A500;
        flags_in = 32'hFFFF_FFFF;
        #1;
        if (flags_out[7] !== eax_in[15] ||
            flags_out[6] !== eax_in[14] ||
            flags_out[4] !== eax_in[12] ||
            flags_out[2] !== eax_in[10] ||
            flags_out[0] !== eax_in[8]) begin
            $display("FAIL stage_3_exe_misc_sahf flag bits");
            $finish(1);
        end
        if (flags_out[11] !== flags_in[11] || flags_out[1] !== flags_in[1]) begin
            $display("FAIL stage_3_exe_misc_sahf preserved bits");
            $finish(1);
        end

        xchg_a = 32'h1122_3344;
        xchg_b = 32'hAABB_CCDD;
        #1;
        if (xchg_y !== 32'hAABB_CCDD) begin
            $display("FAIL stage_3_exe_misc_xchg");
            $finish(1);
        end

        xadd_a = 32'h0000_1234;
        xadd_b = 32'h0000_0002;
        #1;
        if (xadd_y !== 32'h0000_1236) begin
            $display("FAIL stage_3_exe_misc_xadd");
            $finish(1);
        end

        cmpxchg_acc = 32'h0000_1234;
        cmpxchg_dst = 32'h0000_1234;
        cmpxchg_src = 32'hAABB_CCDD;
        #1;
        if (cmpxchg_zf !== 1'b1 || cmpxchg_y !== 32'hAABB_CCDD) begin
            $display("FAIL stage_3_exe_misc_cmpxchg equal path");
            $finish(1);
        end

        cmpxchg_acc = 32'h0000_5678;
        cmpxchg_dst = 32'h0000_1234;
        cmpxchg_src = 32'hAABB_CCDD;
        #1;
        if (cmpxchg_zf !== 1'b0 || cmpxchg_y !== 32'h0000_1234) begin
            $display("FAIL stage_3_exe_misc_cmpxchg mismatch path");
            $finish(1);
        end

        $display("eu_misc_exchange_status_tb PASS");
        $finish;
    end
endmodule
