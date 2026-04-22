// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : eu_ari_neg_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_ari_neg_tb module
// ============================================================================

`timescale 1ns/1ns
module ari_neg_tb;
	logic [31: 0] a, y;

	alu_arithmetic_ari_neg u (
		.a ( a ),
		.y ( y )
	);

	initial begin
		a = 32'd1;
		#1;
		if (y !== 32'hFFFF_FFFF) begin
			$display("FAIL ari_neg");
			$finish(1);
		end
		$display("eu_ari_neg_tb PASS");
		$finish;
	end
endmodule
