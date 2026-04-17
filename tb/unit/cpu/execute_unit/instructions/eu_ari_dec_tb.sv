/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_ari_dec_tb.
*/
`timescale 1ns/1ns
module eu_ari_dec_tb; logic [31:0] a,y; stage_3_exe_ari_dec u(.a(a),.y(y)); initial begin a=32'd42; #1; if(y!==32'd41) begin $display("FAIL stage_3_exe_ari_dec"); $finish(1); end $display("eu_ari_dec_tb PASS"); $finish; end endmodule
