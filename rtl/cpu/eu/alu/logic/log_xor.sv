/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_alu_logic_log_xor.
*/
module eu_alu_logic_log_xor (
    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [31: 0]  b,  // 操作数 / 源 2
    output logic [31: 0] y  // 结果输出
);
    eu_alu_logic_log_execute_logic_xor u_impl (
        .operand_1 ( a ),
        .operand_2 ( b ),
        .result    ( y )
    );
endmodule
