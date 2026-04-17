/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_log_xor.
*/
module stage_3_exe_log_xor (
    input  logic [31: 0]  a,
    input  logic [31: 0]  b,
    output logic [31: 0] y
);
    stage_3_exe_log_execute_logic_xor u_impl (.operand_1(a), .operand_2(b), .result(y));
endmodule
