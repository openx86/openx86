`timescale 1ns/1ns
module eu_ari_sbb_tb; logic [31:0] a,b,y; logic cf; stage_3_exe_ari_sbb u(.a(a),.b(b),.cf(cf),.y(y)); initial begin a=9; b=4; cf=1; #1; if(y!==4) begin $display("FAIL stage_3_exe_ari_sbb"); $finish(1); end $display("eu_ari_sbb_tb PASS"); $finish; end endmodule
