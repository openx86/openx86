/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_ari_execute_arithmetic_adc_tb.
*/
`timescale 1ns/1ns

module eu_ari_execute_arithmetic_adc_tb;
    logic [31: 0] a, b, y;
    logic        cf;

    eu_alu_arithmetic_ari_execute_arithmetic_adc u_dut (
        .operand_1(a),
        .operand_2(b),
        .carry_flag(cf),
        .result(y)
    );

    initial begin
        a = 32'd2; b = 32'd3; cf = 1'b1; #1;
        if (y !== 32'd6) begin
            $display("FAIL adc");
            $finish(1);
        end
        $display("eu_ari_execute_arithmetic_adc_tb PASS");
        $finish;
    end
endmodule
