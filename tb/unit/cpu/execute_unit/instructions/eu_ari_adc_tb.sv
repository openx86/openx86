`timescale 1ns/1ns
module eu_ari_adc_tb; logic [31:0] a,b,y; logic cf; eu_ari_adc u(.a(a),.b(b),.cf(cf),.y(y)); initial begin a=2; b=3; cf=1; #1; if(y!==6) begin $display("FAIL eu_ari_adc"); $finish(1); end $display("eu_ari_adc_tb PASS"); $finish; end endmodule
