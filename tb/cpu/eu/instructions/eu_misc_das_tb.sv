/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_misc_das_tb.
*/
`timescale 1ns/1ns

module eu_misc_das_tb;
    logic [31: 0] a;
    logic        af_in;
    logic        cf_in;
    logic [31: 0] y;
    logic        af_out;
    logic        cf_out;

    misc_das u_dut (
        .a ( a ),
        .af_in ( af_in ),
        .cf_in ( cf_in ),
        .y ( y ),
        .af_out ( af_out ),
        .cf_out ( cf_out )
    );

    initial begin
        a = 32'h0000_009A;
        af_in = 1'b0;
        cf_in = 1'b0;
        #1;
        if ((y !== 32'h0000_0034) || (af_out !== 1'b1) || (cf_out !== 1'b1)) begin
            $display("FAIL misc_das double-adjust");
            $finish(1);
        end

        a = 32'h0000_0015;
        af_in = 1'b0;
        cf_in = 1'b0;
        #1;
        if ((y !== 32'h0000_0015) || (af_out !== 1'b0) || (cf_out !== 1'b0)) begin
            $display("FAIL misc_das no-adjust");
            $finish(1);
        end

        $display("eu_misc_das_tb PASS");
        $finish;
    end
endmodule
