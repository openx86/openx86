/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_log_not_tb.
*/
`timescale 1ns/1ns
module eu_log_not_tb;
	logic [31: 0] a, y;

	log_not u (
		.a ( a ),
		.y ( y )
	);

	initial begin
		a = 32'hFFFF_0000;
		#1;
		if (y !== 32'h0000_FFFF) begin
			$display("FAIL log_not");
			$finish(1);
		end
		$display("eu_log_not_tb PASS");
		$finish;
	end
endmodule
