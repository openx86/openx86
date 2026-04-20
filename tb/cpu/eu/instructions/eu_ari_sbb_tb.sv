/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_ari_sbb_tb.
*/
`timescale 1ns/1ns
module eu_ari_sbb_tb;
	logic [31: 0] a, b, y;
	logic         cf;

	ari_sbb u (
		.a  ( a  ),
		.b  ( b  ),
		.cf ( cf ),
		.y  ( y  )
	);

	initial begin
		a  = 9;
		b  = 4;
		cf = 1;
		#1;
		if (y !== 4) begin
			$display("FAIL ari_sbb");
			$finish(1);
		end
		$display("eu_ari_sbb_tb PASS");
		$finish;
	end
endmodule
