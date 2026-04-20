/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_misc_cr0_ctrl_tb.
*/
`timescale 1ns/1ns

module eu_misc_cr0_ctrl_tb;
    logic [31: 0] cr0;
    logic [31: 0] src;
    logic [31: 0] clts_y;
    logic [31: 0] lmsw_y;
    logic [31: 0] smsw_y;

    eu_alu_misc_clts u_clts (
        .cr0 ( cr0 ),
        .y ( clts_y )
    );

    eu_alu_misc_lmsw u_lmsw (
        .cr0 ( cr0 ),
        .src ( src ),
        .y ( lmsw_y )
    );

    eu_alu_misc_smsw u_smsw (
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
