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
//  File        : eu_log_xor_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_log_xor_tb module
// ============================================================================

`timescale 1ns/1ns
module eu_log_xor_tb;
	logic [31: 0] a, b, y;

	log_xor u (
		.a ( a ),
		.b ( b ),
		.y ( y )
	);

	initial begin
		a = 32'hF0F0_00FF;
		b = 32'h0FF0_F00F;
		#1;
		if (y !== 32'hFF00_F0F0) begin
			$display("FAIL log_xor");
			$finish(1);
		end
		$display("eu_log_xor_tb PASS");
		$finish;
	end
endmodule
