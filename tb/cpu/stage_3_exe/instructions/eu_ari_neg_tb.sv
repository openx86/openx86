/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_ari_neg_tb.
*/
`timescale 1ns/1ns
module eu_ari_neg_tb;
	logic [31: 0] a, y;

	stage_3_exe_ari_neg u (
		.a ( a ),
		.y ( y )
	);

	initial begin
		a = 32'd1;
		#1;
		if (y !== 32'hFFFF_FFFF) begin
			$display("FAIL stage_3_exe_ari_neg");
			$finish(1);
		end
		$display("eu_ari_neg_tb PASS");
		$finish;
	end
endmodule
