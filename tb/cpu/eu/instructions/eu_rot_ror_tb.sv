/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_rot_ror_tb.
*/
`timescale 1ns/1ns
module eu_rot_ror_tb;
	logic [31: 0] a, c, y;

	rot_ror u (
		.a     ( a ),
		.count ( c ),
		.y     ( y )
	);

	initial begin
		a = 32'h1234_5678;
		c = 32'd8;
		#1;
		if (y !== 32'h7812_3456) begin
			$display("FAIL rot_ror");
			$finish(1);
		end
		$display("eu_rot_ror_tb PASS");
		$finish;
	end
endmodule
