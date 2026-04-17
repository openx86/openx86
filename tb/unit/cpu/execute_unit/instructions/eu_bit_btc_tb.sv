/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_bit_btc_tb.
*/
`timescale 1ns/1ns

module eu_bit_btc_tb;
    logic [31:  0] a;
    logic [31:  0] b;
    logic [31:  0] y;
    logic        cf;

    stage_3_exe_bit_btc u_dut (
        .a ( a ),
        .bit_index ( b ),
        .y ( y ),
        .cf ( cf )
    );

    initial begin
        a = 32'h0000_0000;
        b = 32'd1;
        #1;
        if (cf !== 1'b0 || y !== 32'h0000_0002) begin
            $display("FAIL stage_3_exe_bit_btc toggle1");
            $finish(1);
        end

        a = y;
        #1;
        if (cf !== 1'b1 || y !== 32'h0000_0000) begin
            $display("FAIL stage_3_exe_bit_btc toggle2");
            $finish(1);
        end

        $display("eu_bit_btc_tb PASS");
        $finish;
    end
endmodule
