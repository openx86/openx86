/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_misc_cdq_tb.
*/
`timescale 1ns/1ns

module eu_misc_cdq_tb;
    logic [31: 0] a;
    logic [31: 0] y;

    stage_3_exe_misc_cdq u_dut (
        .a ( a ),
        .y ( y )
    );

    initial begin
        a = 32'h8000_0000;
        #1;
        if (y !== 32'hFFFF_FFFF) begin
            $display("FAIL stage_3_exe_misc_cdq neg");
            $finish(1);
        end

        a = 32'h7FFF_FFFF;
        #1;
        if (y !== 32'h0000_0000) begin
            $display("FAIL stage_3_exe_misc_cdq pos");
            $finish(1);
        end

        $display("eu_misc_cdq_tb PASS");
        $finish;
    end
endmodule
