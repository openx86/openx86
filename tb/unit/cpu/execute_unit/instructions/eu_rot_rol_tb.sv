`timescale 1ns/1ns
module eu_rot_rol_tb; logic [31:0] a,c,y; stage_3_exe_eu_rot_rol u(.a(a),.count(c),.y(y)); initial begin a=32'h1234_5678; c=32'd8; #1; if(y!==32'h3456_7812) begin $display("FAIL stage_3_exe_eu_rot_rol"); $finish(1); end $display("eu_rot_rol_tb PASS"); $finish; end endmodule
