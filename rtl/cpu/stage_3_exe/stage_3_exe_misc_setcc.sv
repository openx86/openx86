/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_setcc.
*/
module stage_3_exe_misc_setcc (
    input  logic [31: 0] flags,
    input  logic [ 3:0] tttn,
    output logic [31: 0] y
);
    logic cond;

    logic cf;
    logic pf;
    logic zf;
    logic sf;
    logic of;

    always_comb begin
        cf = flags[0];
        pf = flags[2];
        zf = flags[6];
        sf = flags[7];
        of = flags[11];

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
