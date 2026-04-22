// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : rot_rcr.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : rot_rcr module
// ============================================================================

module rot_rcr (    input  logic [31: 0]  a,  // 操作数 / 源 1
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
                next_cf = tmp[0];
                tmp = { cf, tmp[31:  1] };
                cf = next_cf;
            end
        end

        y = tmp;
        cf_out = cf;
    end
endmodule
