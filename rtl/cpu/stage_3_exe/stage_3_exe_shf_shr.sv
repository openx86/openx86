/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_shf_shr.
*/
module stage_3_exe_shf_shr (
    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [31: 0]  count,  // 移位或旋转计数值（低位有效）
    output logic [31: 0] y  // 结果输出
);
    stage_3_exe_shf_execute_shift_right u_impl (
        .operand   ( a      ),
        .count     ( count  ),
        .is_signed ( 32'd0  ),
        .result    ( y      )
    );
endmodule
