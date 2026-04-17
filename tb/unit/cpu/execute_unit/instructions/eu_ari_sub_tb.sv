/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_ari_sub_tb.
*/
`timescale 1ns/1ns
module eu_ari_sub_tb; logic [31: 0] a,b,y; stage_3_exe_ari_sub u(.a(a),.b(b),.y(y)); initial begin a=9; b=4; #1; if(y!==5) begin $display("FAIL stage_3_exe_ari_sub"); $finish(1); end $display("eu_ari_sub_tb PASS"); $finish; end endmodule
