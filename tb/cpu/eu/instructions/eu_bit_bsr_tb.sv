/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_bit_bsr_tb.
*/
`timescale 1ns/1ns

module eu_bit_bsr_tb;
    logic [31: 0] a;
    logic [31: 0] y;
    logic        zf;

    eu_alu_bitmanip_bit_bsr u_dut (
        .a ( a ),
        .y ( y ),
        .zf ( zf )
    );

    initial begin
        a = 32'h0000_0000; #1;
        if (zf !== 1'b1 || y !== 32'd0) begin
            $display("FAIL eu_alu_bitmanip_bit_bsr zero");
            $finish(1);
        end

        a = 32'h8010_0800; #1;
        if (zf !== 1'b0 || y !== 32'd31) begin
            $display("FAIL eu_alu_bitmanip_bit_bsr nonzero");
            $finish(1);
        end

        $display("eu_bit_bsr_tb PASS");
        $finish;
    end
endmodule
