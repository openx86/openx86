/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_misc_flag_status_tb.
*/
`timescale 1ns/1ns

module eu_misc_flag_status_tb;

    logic [31: 0] flags_in;
    logic [ 5: 0] op;
    logic [31: 0] flags_out;

    stage_3_exe_misc_flag_status u_dut (
        .flags_in ( flags_in ),
        .op ( op ),
        .flags_out ( flags_out )
    );

    initial begin
        flags_in = 32'h0000_0001;

        op = stage_3_exe_execute_unit_pkg::INT_CLC;
        #1;
        if (flags_out[0] !== 1'b0) begin
            $display("FAIL stage_3_exe_misc_flag_status CLC");
            $finish(1);
        end

        op = stage_3_exe_execute_unit_pkg::INT_STC;
        #1;
        if (flags_out[0] !== 1'b1) begin
            $display("FAIL stage_3_exe_misc_flag_status STC");
            $finish(1);
        end

        op = stage_3_exe_execute_unit_pkg::INT_CMC;
        #1;
        if (flags_out[0] !== 1'b0) begin
            $display("FAIL stage_3_exe_misc_flag_status CMC");
            $finish(1);
        end

        flags_in = 32'h0000_0000;
        op = stage_3_exe_execute_unit_pkg::INT_STI;
        #1;
        if (flags_out[9] !== 1'b1) begin
            $display("FAIL stage_3_exe_misc_flag_status STI");
            $finish(1);
        end

        flags_in = 32'h0000_0200;
        op = stage_3_exe_execute_unit_pkg::INT_CLI;
        #1;
        if (flags_out[9] !== 1'b0) begin
            $display("FAIL stage_3_exe_misc_flag_status CLI");
            $finish(1);
        end

        flags_in = 32'h0000_0400;
        op = stage_3_exe_execute_unit_pkg::INT_CLD;
        #1;
        if (flags_out[10] !== 1'b0) begin
            $display("FAIL stage_3_exe_misc_flag_status CLD");
            $finish(1);
        end

        flags_in = 32'h0000_0000;
        op = stage_3_exe_execute_unit_pkg::INT_STD;
        #1;
        if (flags_out[10] !== 1'b1) begin
            $display("FAIL stage_3_exe_misc_flag_status STD");
            $finish(1);
        end

        $display("eu_misc_flag_status_tb PASS");
        $finish;
    end
endmodule
