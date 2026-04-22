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
//  File        : eu_misc_cr0_ctrl_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_misc_cr0_ctrl_tb module
// ============================================================================

`timescale 1ns/1ns

module eu_misc_cr0_ctrl_tb;
    logic [31: 0] cr0;
    logic [31: 0] src;
    logic [31: 0] clts_y;
    logic [31: 0] lmsw_y;
    logic [31: 0] smsw_y;

    misc_clts u_clts (
        .cr0 ( cr0 ),
        .y ( clts_y )
    );

    misc_lmsw u_lmsw (
        .cr0 ( cr0 ),
        .src ( src ),
        .y ( lmsw_y )
    );

    misc_smsw u_smsw (
        .cr0 ( cr0 ),
        .y ( smsw_y )
    );

    task automatic check(input logic cond, input [127: 0] name);
        begin
            if (!cond) begin
                $display("FAIL eu_misc_cr0_ctrl %s", name);
                $finish(1);
            end
        end
    endtask

    initial begin
        cr0 = 32'hFFFF_FFFF;
        src = 32'h0000_0005;
        #1;
        check(clts_y == 32'hFFFF_FFF7, "CLTS clear TS bit");
        check(lmsw_y == 32'hFFFF_FFF5, "LMSW low nibble update");
        check(smsw_y == 32'h0000_FFFF, "SMSW low 16 bits");

        cr0 = 32'h1234_5678;
        src = 32'h0000_000A;
        #1;
        check(clts_y == 32'h1234_5670, "CLTS preserve other bits");
        check(lmsw_y == 32'h1234_567A, "LMSW keep high bits");
        check(smsw_y == 32'h0000_5678, "SMSW truncation");

        $display("eu_misc_cr0_ctrl_tb PASS");
        $finish;
    end
endmodule
