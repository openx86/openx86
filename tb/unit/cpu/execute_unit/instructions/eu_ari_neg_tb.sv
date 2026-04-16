`timescale 1ns/1ns
module eu_ari_neg_tb; logic [31:0] a,y; eu_ari_neg u(.a(a),.y(y)); initial begin a=32'd1; #1; if(y!==32'hFFFF_FFFF) begin $display("FAIL eu_ari_neg"); $finish(1); end $display("eu_ari_neg_tb PASS"); $finish; end endmodule
