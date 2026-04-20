/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_ari_add_tb.
*/
`timescale 1ns/1ns
module eu_ari_add_tb;
	logic [31: 0] a, b, y;

	ari_add u (
		.a ( a ),
		.b ( b ),
		.y ( y )
	);

	initial begin
		a = 2;
		b = 3;
		#1;
		if (y !== 5) begin
			$display("FAIL ari_add");
			$finish(1);
		end
		$display("eu_ari_add_tb PASS");
		$finish;
	end
endmodule
