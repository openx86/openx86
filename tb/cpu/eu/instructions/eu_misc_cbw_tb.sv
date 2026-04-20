/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_misc_cbw_tb.
*/
`timescale 1ns/1ns

module eu_misc_cbw_tb;
    logic [31: 0] a;
    logic [31: 0] y;

    misc_cbw u_dut (
        .a ( a ),
        .y ( y )
    );

    initial begin
        a = 32'h0000_8001;
        #1;
        if (y !== 32'hFFFF_8001) begin
            $display("FAIL misc_cbw sign");
            $finish(1);
        end

        a = 32'h0000_7F01;
        #1;
        if (y !== 32'h0000_7F01) begin
            $display("FAIL misc_cbw positive");
            $finish(1);
        end

        $display("eu_misc_cbw_tb PASS");
        $finish;
    end
endmodule
