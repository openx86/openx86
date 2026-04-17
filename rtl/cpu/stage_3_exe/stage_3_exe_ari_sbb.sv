/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_ari_sbb.
*/
module stage_3_exe_ari_sbb (
    input logic [31: 0]  a,    input logic [31: 0]  b,    input logic          cf,    output logic [31: 0] y);
    stage_3_exe_ari_execute_arithmetic_sbb u_impl (.operand_1(a), .operand_2(b), .carry_flag(cf), .result(y));
endmodule
