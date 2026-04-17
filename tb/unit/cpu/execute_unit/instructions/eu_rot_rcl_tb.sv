/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_rot_rcl_tb.
*/
`timescale 1ns/1ns

module eu_rot_rcl_tb;
    logic [31: 0] a;
    logic [31: 0] c;
    logic        cf_in;
    logic [31: 0] y;
    logic        cf_out;

    stage_3_exe_rot_rcl u_dut (
        .a ( a ),
        .count ( c ),
        .cf_in ( cf_in ),
        .y ( y ),
        .cf_out ( cf_out )
    );

    initial begin
        a = 32'h8000_0000;
        c = 32'd1;
        cf_in = 1'b1;
        #1;
        if (y !== 32'h0000_0001 || cf_out !== 1'b1) begin
            $display("FAIL stage_3_exe_rot_rcl step1");
            $finish(1);
        end

        a = 32'h0000_0001;
        c = 32'd1;
        cf_in = 1'b0;
        #1;
        if (y !== 32'h0000_0002 || cf_out !== 1'b0) begin
            $display("FAIL stage_3_exe_rot_rcl step2");
            $finish(1);
        end

        $display("eu_rot_rcl_tb PASS");
        $finish;
    end
endmodule
