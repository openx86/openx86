`timescale 1ns/1ns
module eu_shf_shl_tb; logic [31:0] a,c,y; stage_3_exe_eu_shf_shl u(.a(a),.count(c),.y(y)); initial begin a=32'h1; c=32'd4; #1; if(y!==32'h10) begin $display("FAIL stage_3_exe_eu_shf_shl"); $finish(1); end $display("eu_shf_shl_tb PASS"); $finish; end endmodule
