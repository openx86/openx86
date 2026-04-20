/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_alu_misc_setcc.
*/
module eu_alu_misc_setcc (
    input  logic [31: 0]  flags,  // 标志寄存器位域
    input  logic [ 3: 0]   tttn,  // 条件码 nibble（SETcc）
    output logic [31: 0] y  // 结果输出
);
    logic cond;  // 条件为真时 SET 目标字节为 1

    logic cf;  // 自 FLAGS 拆出
    logic pf;
    logic zf;
    logic sf;
    logic of;

    // 组合逻辑：推导输出
    always_comb begin
        cf = flags[0];
        pf = flags[2];
        zf = flags[6];
        sf = flags[7];
        of = flags[11];

        // SETcc：tttn 与 Jcc 低 4 位语义一致
        unique case (tttn)
            4'h0: cond = of;
            4'h1: cond = ~of;
            4'h2: cond = cf;
            4'h3: cond = ~cf;
            4'h4: cond = zf;
            4'h5: cond = ~zf;
            4'h6: cond = cf | zf;
            4'h7: cond = ~cf & ~zf;
            4'h8: cond = sf;
            4'h9: cond = ~sf;
            4'hA: cond = pf;
            4'hB: cond = ~pf;
            4'hC: cond = sf ^ of;
            4'hD: cond = ~(sf ^ of);
            4'hE: cond = zf | (sf ^ of);
            default: cond = ~zf & ~(sf ^ of);
        endcase

        y = { 31'd0, cond };
    end
endmodule
