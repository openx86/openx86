/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_flag_status.
*/
module stage_3_exe_misc_flag_status (
    input  logic [31: 0]  flags_in,  // 输入标志
    input  logic [ 5: 0]   op,  // 标志类微操作
    output logic [31: 0] flags_out  // 输出标志
);
    import stage_3_exe_execute_unit_pkg::*;

    // 组合逻辑：推导输出
    always_comb begin
        flags_out = flags_in;
        // CLC/STC/CMC/CLD/STD/CLI/STI：按位改写 FLAGS
        unique case (op)
            INT_CLC: flags_out = { flags_in[31:  1], 1'b0 };
            INT_STC: flags_out = { flags_in[31:  1], 1'b1 };
            INT_CMC: flags_out = { flags_in[31:  1], ~flags_in[0] };
            INT_CLD: flags_out = { flags_in[31: 11], 1'b0, flags_in[ 9: 0] };
            INT_STD: flags_out = { flags_in[31: 11], 1'b1, flags_in[ 9: 0] };
            INT_CLI: flags_out = { flags_in[31: 10], 1'b0, flags_in[ 8: 0] };
            INT_STI: flags_out = { flags_in[31: 10], 1'b1, flags_in[ 8: 0] };
            default: ;
        endcase
    end
endmodule
