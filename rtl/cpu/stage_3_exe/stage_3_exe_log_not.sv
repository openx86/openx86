/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_log_not.
*/
module stage_3_exe_log_not (
    input  logic [31:0] a,
    output logic [31:0] y
);
    stage_3_exe_log_execute_logic_not u_impl (.operand_1(a), .result(y));
endmodule
