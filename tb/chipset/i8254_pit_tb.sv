/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements i8254_pit_tb.
*/
// ============================================================================
// i8254_pit testbench
// ============================================================================
`timescale 1ns/1ps
module i8254_pit_tb;

    logic        clk = 0;
    logic        rst_n;
    logic        valid;
    logic        we;
    logic [15: 0] addr;
    logic [ 7: 0] wdata;
    logic [ 7: 0] rdata;
    logic        out0, out1, out2;

    logic hit = (addr >= 16'h0040) && (addr <= 16'h0043);
    logic cs_n = !(valid && hit);
    logic wr_n = !(valid && we && hit);
    logic rd_n = !(valid && !we && hit);

    int fail_cnt;
    int high_len;
    int low_len;


    chip_8254_pit dut (
        .clk      ( clk ),
        .rst_n    ( rst_n ),
        .i_cs_n     ( cs_n ),
        .i_rd_n     ( rd_n ),
        .i_wr_n     ( wr_n ),
        .i_a        ( addr[ 1: 0] ),
        .i_d        ( wdata ),
        .o_d        ( rdata ),
        .o_out0     ( out0 ),
        .o_out1     ( out1 ),
        .o_out2     ( out2 )
    );

    always #5 clk = ~clk;

    task automatic wr(input logic [15: 0] a, input logic [ 7: 0] d);
        @(posedge clk);
        valid = 1;
        we    = 1;
        addr  = a;
        wdata = d;
        @(posedge clk);
        valid = 0;
    endtask

    task automatic rd(input logic [15: 0] a, output logic [ 7: 0] d);
        @(posedge clk);
        valid = 1;
        we    = 0;
        addr  = a;
        @(posedge clk);
        d     = rdata;
        valid = 0;
    endtask

    task automatic check(input logic cond, input string msg);
        if (!cond) begin
            fail_cnt++;
            $error("FAIL: %s", msg);
        end else begin
            $display("PASS: %s", msg);
        end
    endtask

    task automatic program_ch0(input logic [ 7: 0] ctrl, input logic [15: 0] init_count);
        wr(16'h0043, ctrl);
        unique case (ctrl[ 5: 4])
            2'b01: begin
                wr(16'h0040, init_count[ 7: 0]);
            end
            2'b10: begin
                wr(16'h0040, init_count[15: 8]);
            end
            2'b11: begin
                wr(16'h0040, init_count[ 7: 0]);
                wr(16'h0040, init_count[15: 8]);
            end
            default: ;
        endcase
    endtask

    task automatic measure_phase_lengths(output int o_high_len, output int o_low_len);
        o_high_len = 0;
        o_low_len  = 0;

        while ((out0 === 1'b1) && (o_high_len < 64)) begin
            @(posedge clk);
            o_high_len++;
        end

        while ((out0 === 1'b0) && (o_low_len < 64)) begin
            @(posedge clk);
            o_low_len++;
        end
    endtask

    task automatic wait_first_low(input int max_cycles, output logic seen_low);
        int n;
        seen_low = 1'b0;
        for (n = 0; n < max_cycles; n = n + 1) begin
            if (out0 === 1'b0) begin
                seen_low = 1'b1;
                break;
            end
            @(posedge clk);
        end
    endtask

    logic seen_low;

    initial begin
        rst_n = 1'b0;
        valid = 0;
        we    = 0;
        addr  = '0;
        wdata = '0;
        fail_cnt = 0;

        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        // Mode 0, RW=LSB/MSB, count=3:
        // OUT low after programming, high at terminal count (N+1 clocks from write).
        program_ch0(8'h30, 16'd3);
        check(out0 === 1'b0, "mode0: OUT low immediately after programming");
        repeat (3) @(posedge clk);
        check(out0 === 1'b0, "mode0: OUT still low before terminal count");
        @(posedge clk);
        check(out0 === 1'b1, "mode0: OUT high on terminal count");

        // Mode 2, RW=LSB/MSB, count=4:
        // OUT high by default, generates one-clock low pulses.
        program_ch0(8'h34, 16'd4);
        check(out0 === 1'b1, "mode2: OUT high after programming");
        wait_first_low(64, seen_low);
        check(seen_low, "mode2: low pulse observed");
        if (seen_low) begin
            check(out0 === 1'b0, "mode2: low pulse asserted");
            @(posedge clk);
            check(out0 === 1'b1, "mode2: low pulse width is one clock");
        end

        // Mode 3 odd count=5:
        // High phase=(N+1)/2=3, low phase=(N-1)/2=2.
        program_ch0(8'h36, 16'd5);
        @(posedge clk);
        measure_phase_lengths(high_len, low_len);
        check(high_len == 3, "mode3 odd: high width should be 3 clocks");
        check(low_len == 2, "mode3 odd: low width should be 2 clocks");

        // Mode alias check: M2:M1:M0=111 should alias Mode 3.
        program_ch0(8'h3E, 16'd4);
        @(posedge clk);
        measure_phase_lengths(high_len, low_len);
        check(high_len == 2, "mode alias 111: high width should be 2 clocks");
        check(low_len == 2, "mode alias 111: low width should be 2 clocks");

        // RW format check: LSB-only should load count with MSB=0.
        program_ch0(8'h10, 16'd3);
        check(out0 === 1'b0, "rw lsb-only: mode0 OUT low after write");
        repeat (3) @(posedge clk);
        check(out0 === 1'b0, "rw lsb-only: still low before terminal count");
        @(posedge clk);
        check(out0 === 1'b1, "rw lsb-only: OUT high on terminal count");

        if (fail_cnt == 0) begin
            $display("i8254_pit_tb PASS");
            $finish;
        end else begin
            $fatal(1, "i8254_pit_tb FAIL: %0d checks failed", fail_cnt);
        end
    end

endmodule
