/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_ari_execute_arithmetic_div_tb.
*/
`timescale 1ns/1ns

module eu_ari_execute_arithmetic_div_tb;
    logic [31: 0] a, b, y;

    ari_execute_arithmetic_div u_dut (
        .operand_1(a),
        .operand_2(b),
        .result(y)
    );

    initial begin
        a = 32'd42; b = 32'd7; #1;
        if (y !== 32'd6) begin
            $display("FAIL div");
            $finish(1);
        end
        $display("eu_ari_execute_arithmetic_div_tb PASS");
        $finish;
    end
endmodule
