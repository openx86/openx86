/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_misc_movzx_tb.
*/
`timescale 1ns/1ns

module eu_misc_movzx_tb;
    logic [31: 0] a;
    logic [ 1: 0] width;
    logic [31: 0] y;

    misc_movzx u_dut (
        .a ( a ),
        .width ( width ),
        .y ( y )
    );

    initial begin
        a = 32'h0000_00FF;
        width = 2'b01;
        #1;
        if (y !== 32'h0000_00FF) begin
            $display("FAIL misc_movzx byte");
            $finish(1);
        end

        a = 32'h0000_FF01;
        width = 2'b10;
        #1;
        if (y !== 32'h0000_FF01) begin
            $display("FAIL misc_movzx word");
            $finish(1);
        end

        a = 32'h89AB_CDEF;
        width = 2'b11;
        #1;
        if (y !== 32'h89AB_CDEF) begin
            $display("FAIL misc_movzx dword");
            $finish(1);
        end

        $display("eu_misc_movzx_tb PASS");
        $finish;
    end
endmodule
