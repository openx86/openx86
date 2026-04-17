/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_misc_stridx_step_tb.
*/
`timescale 1ns/1ns

module eu_misc_stridx_step_tb;
    logic [31: 0] idx;
    logic        df;
    logic [31: 0] y;

    stage_3_exe_misc_stridx_step u_dut (
        .idx ( idx ),
        .df ( df ),
        .y ( y )
    );

    task automatic check(input logic cond, input [127: 0] name);
        begin
            if (!cond) begin
                $display("FAIL stage_3_exe_misc_stridx_step %s", name);
                $finish(1);
            end
        end
    endtask

    initial begin
        idx = 32'h0000_1000;
        df = 1'b0;
        #1;
        check(y == 32'h0000_1001, "increment");

        idx = 32'h0000_1000;
        df = 1'b1;
        #1;
        check(y == 32'h0000_0FFF, "decrement");

        idx = 32'h0000_0000;
        df = 1'b1;
        #1;
        check(y == 32'hFFFF_FFFF, "underflow wrap");

        $display("eu_misc_stridx_step_tb PASS");
        $finish;
    end
endmodule
