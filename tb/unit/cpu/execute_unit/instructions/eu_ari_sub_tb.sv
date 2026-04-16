`timescale 1ns/1ns
module eu_ari_sub_tb; logic [31:0] a,b,y; eu_ari_sub u(.a(a),.b(b),.y(y)); initial begin a=9; b=4; #1; if(y!==5) begin $display("FAIL eu_ari_sub"); $finish(1); end $display("eu_ari_sub_tb PASS"); $finish; end endmodule
