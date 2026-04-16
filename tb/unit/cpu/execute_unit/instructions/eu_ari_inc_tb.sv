`timescale 1ns/1ns
module eu_ari_inc_tb; logic [31:0] a,y; eu_ari_inc u(.a(a),.y(y)); initial begin a=32'd41; #1; if(y!==32'd42) begin $display("FAIL eu_ari_inc"); $finish(1); end $display("eu_ari_inc_tb PASS"); $finish; end endmodule
