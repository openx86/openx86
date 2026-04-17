/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_shf_shrd_tb.
*/
`timescale 1ns/1ns

module eu_shf_shrd_tb;
    logic [31:  0] a;
    logic [31:  0] b;
    logic [31:  0] c;
    logic [31:  0] y;

    stage_3_exe_shf_shrd u_dut (
        .a ( a ),
        .b ( b ),
        .count ( c ),
        .y ( y )
    );

    initial begin
        a = 32'h1234_5678;
        b = 32'h9ABC_DEF0;
        c = 32'd4;
        #1;
        if (y !== 32'h0123_4567) begin
            $display("FAIL stage_3_exe_shf_shrd");
            $finish(1);
        end

        c = 32'd0;
        #1;
        if (y !== a) begin
            $display("FAIL stage_3_exe_shf_shrd count0");
            $finish(1);
        end

        $display("eu_shf_shrd_tb PASS");
        $finish;
    end
endmodule
