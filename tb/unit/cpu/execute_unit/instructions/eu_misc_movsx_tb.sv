/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_misc_movsx_tb.
*/
`timescale 1ns/1ns

module eu_misc_movsx_tb;
    logic [31: 0] a;
    logic [ 1: 0] width;
    logic [31: 0] y;

    stage_3_exe_misc_movsx u_dut (
        .a ( a ),
        .width ( width ),
        .y ( y )
    );

    initial begin
        a = 32'h0000_0080;
        width = 2'b01;
        #1;
        if (y !== 32'hFFFF_FF80) begin
            $display("FAIL stage_3_exe_misc_movsx byte");
            $finish(1);
        end

        a = 32'h0000_8001;
        width = 2'b10;
        #1;
        if (y !== 32'hFFFF_8001) begin
            $display("FAIL stage_3_exe_misc_movsx word");
            $finish(1);
        end

        a = 32'h89AB_CDEF;
        width = 2'b11;
        #1;
        if (y !== 32'h89AB_CDEF) begin
            $display("FAIL stage_3_exe_misc_movsx dword");
            $finish(1);
        end

        $display("eu_misc_movsx_tb PASS");
        $finish;
    end
endmodule
