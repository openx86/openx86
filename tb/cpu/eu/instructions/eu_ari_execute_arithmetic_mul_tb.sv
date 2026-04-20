/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_ari_execute_arithmetic_mul_tb.
*/
`timescale 1ns/1ns

module eu_ari_execute_arithmetic_mul_tb;
    logic [31: 0] a, b, y;

    eu_alu_arithmetic_ari_execute_arithmetic_mul u_dut (
        .operand_1(a),
        .operand_2(b),
        .result(y)
    );

    initial begin
        a = 32'd7; b = 32'd6; #1;
        if (y !== 32'd42) begin
            $display("FAIL mul");
            $finish(1);
        end
        $display("eu_ari_execute_arithmetic_mul_tb PASS");
        $finish;
    end
endmodule
