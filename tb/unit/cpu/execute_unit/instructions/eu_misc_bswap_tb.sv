/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_misc_bswap_tb.
*/
`timescale 1ns/1ns

module eu_misc_bswap_tb;
    logic [31:  0] a;
    logic [31:  0] y;

    stage_3_exe_misc_bswap u_dut (
        .a ( a ),
        .y ( y )
    );

    initial begin
        a = 32'h1234_5678;
        #1;
        if (y !== 32'h7856_3412) begin
            $display("FAIL stage_3_exe_misc_bswap");
            $finish(1);
        end

        $display("eu_misc_bswap_tb PASS");
        $finish;
    end
endmodule
