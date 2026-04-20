/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_ari_execute_arithmetic_add_tb.
*/
`timescale 1ns/1ns

module eu_ari_execute_arithmetic_add_tb;
    logic [31: 0] a, b, y;

    eu_alu_arithmetic_ari_execute_arithmetic_add u_dut (
        .operand_1(a),
        .operand_2(b),
        .result(y)
    );

    initial begin
        a = 32'd2; b = 32'd3; #1;
        if (y !== 32'd5) begin
            $display("FAIL add");
            $finish(1);
        end
        $display("eu_ari_execute_arithmetic_add_tb PASS");
        $finish;
    end
endmodule
