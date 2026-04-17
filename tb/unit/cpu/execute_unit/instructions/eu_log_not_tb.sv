`timescale 1ns/1ns
module eu_log_not_tb; logic [31:0] a,y; stage_3_exe_log_not u(.a(a),.y(y)); initial begin a=32'hFFFF_0000; #1; if(y!==32'h0000_FFFF) begin $display("FAIL stage_3_exe_log_not"); $finish(1); end $display("eu_log_not_tb PASS"); $finish; end endmodule
