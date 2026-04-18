/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_shf_shr_tb.
*/
`timescale 1ns/1ns
module eu_shf_shr_tb;
	logic [31: 0] a, c, y;

	stage_3_exe_shf_shr u (
		.a     ( a ),
		.count ( c ),
		.y     ( y )
	);

	initial begin
		a = 32'h8000_0000;
		c = 32'd1;
		#1;
		if (y !== 32'h4000_0000) begin
			$display("FAIL stage_3_exe_shf_shr");
			$finish(1);
		end
		$display("eu_shf_shr_tb PASS");
		$finish;
	end
endmodule
