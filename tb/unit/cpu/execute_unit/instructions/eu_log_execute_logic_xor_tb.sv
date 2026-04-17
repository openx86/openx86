/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_log_execute_logic_xor_tb.
*/
`timescale 1ns/1ns

module eu_log_execute_logic_xor_tb;
    logic [31:0] a, b, y;

    stage_3_exe_log_execute_logic_xor u_dut (
        .operand_1(a),
        .operand_2(b),
        .result(y)
    );

    initial begin
        a = 32'hF0F0_00FF; b = 32'h0FF0_F00F; #1;
        if (y !== 32'hFF00_F0F0) begin
            $display("FAIL xor");
            $finish(1);
        end
        $display("eu_log_execute_logic_xor_tb PASS");
        $finish;
    end
endmodule
