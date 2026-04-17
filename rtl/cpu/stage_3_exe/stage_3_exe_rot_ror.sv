/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_rot_ror.
*/
module stage_3_exe_rot_ror (
    input  logic [31: 0] a,
    input  logic [31: 0] count,
    output logic [31: 0] y
);
    stage_3_exe_rot_execute_rotate_right u_impl (.operand(a), .count(count), .result(y));
endmodule
