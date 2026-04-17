`timescale 1ns/1ns
module eu_log_xor_tb; logic [31:0] a,b,y; stage_3_exe_log_xor u(.a(a),.b(b),.y(y)); initial begin a=32'hF0F0_00FF; b=32'h0FF0_F00F; #1; if(y!==32'hFF00_F0F0) begin $display("FAIL stage_3_exe_log_xor"); $finish(1); end $display("eu_log_xor_tb PASS"); $finish; end endmodule
