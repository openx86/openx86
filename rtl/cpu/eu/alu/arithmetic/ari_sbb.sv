/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_alu_arithmetic_ari_sbb.
*/
module eu_alu_arithmetic_ari_sbb (
    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [31: 0]  b,  // 操作数 / 源 2
    input  logic          cf,  // 进位标志
    output logic [31: 0] y  // 结果输出
);
    eu_alu_arithmetic_ari_execute_arithmetic_sbb u_impl (
        .operand_1  ( a  ),
        .operand_2  ( b  ),
        .carry_flag ( cf ),
        .result     ( y  )
    );
endmodule
