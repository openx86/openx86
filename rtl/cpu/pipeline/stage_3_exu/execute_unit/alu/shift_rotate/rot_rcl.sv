/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements rot_rcl.
*/

    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [31: 0]  count, // 移位或旋转计数值（低位有效）
    input  logic          cf_in, // 输入进位
    output logic [31: 0] y, // 结果输出
    output logic         cf_out // 输出进位
);
    logic [31: 0] tmp;
    logic [ 4: 0]  sh;
    logic        cf;
    logic        next_cf;

    // 组合逻辑：推导输出
    always_comb begin
        tmp = a;
        sh = count[ 4: 0];
        cf = cf_in;
        next_cf = cf_in;

        for (int i = 0; i < 32; i++) begin
            if (i < sh) begin
                next_cf = tmp[31];
                tmp = { tmp[30: 0], cf };
                cf = next_cf;
            end
        end

        y = tmp;
        cf_out = cf;
    end
endmodule
