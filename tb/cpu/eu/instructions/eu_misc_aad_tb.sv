/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_misc_aad_tb.
*/
`timescale 1ns/1ns

module eu_misc_aad_tb;
    logic [31: 0] a;
    logic [31: 0] y;

    misc_aad u_dut (
        .a ( a ),
        .y ( y )
    );

    initial begin
        a = 32'h0000_0203;
        #1;
        if (y !== 32'h0000_0017) begin
            $display("FAIL misc_aad");
            $finish(1);
        end

        $display("eu_misc_aad_tb PASS");
        $finish;
    end
endmodule
