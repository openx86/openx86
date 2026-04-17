/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements rtc_mc146818_tb.
*/
// ============================================================================
// rtc_mc146818 仿真：小 CLK_HZ 加速秒进位、SET、BCD 年、读 Reg C 清中断
// ============================================================================
`timescale 1ns/1ps

module rtc_mc146818_tb;

    localparam int RTC_HZ = 256;

    logic        clock = 0;
    logic        reset_n;
    logic        io_valid;
    logic        io_we;
    logic [15: 0] io_addr;
    logic [ 7: 0]  io_wdata;
    logic [ 7: 0]  io_rdata;
    logic        rtc_irq;

    wire rtc_hit = (io_addr == 16'h0070) | (io_addr == 16'h0071);
    wire cs_n    = !(io_valid && rtc_hit);
    wire wr_n    = !(io_valid && io_we && rtc_hit);
    wire rd_n    = !(io_valid && !io_we && rtc_hit);

    always #1 clock = ~clock;

    chip_mc146818_rtc #(
        .CLK_HZ ( RTC_HZ )
    ) dut (
        .clock    ( clock ),
        .reset_n    ( reset_n ),
        .i_cs_n     ( cs_n ),
        .i_rd_n     ( rd_n ),
        .i_wr_n     ( wr_n ),
        .i_a0       ( io_addr[0] ),
        .i_d        ( io_wdata ),
        .o_d        ( io_rdata ),
        .o_rtc_irq  ( rtc_irq )
    );

    task automatic io_write(input logic [15: 0] a, input logic [ 7: 0] d);
        io_valid = 1;
        io_we    = 1;
        io_addr  = a;
        io_wdata = d;
        @(posedge clock);
        io_valid = 0;
        @(posedge clock);
    endtask

    task automatic io_read(input logic [15: 0] a, output logic [ 7: 0] d);
        io_valid = 1;
        io_we    = 0;
        io_addr  = a;
        @(posedge clock);
        d = io_rdata;
        io_valid = 0;
        @(posedge clock);
    endtask

    task automatic set_index(input logic [ 6: 0] idx);
        io_write(16'h0070, {1'b0, idx});
    endtask

    task automatic read_data(output logic [ 7: 0] d);
        io_read(16'h0071, d);
    endtask

    initial begin
        logic [ 7: 0] v;
        reset_n  = 0;
        io_valid = 0;
        io_we    = 0;
        repeat (4) @(posedge clock);
        reset_n = 1;
        @(posedge clock);

        set_index(7'h00);
        read_data(v);
        if (v !== 8'h00)
            $fatal(1, "FAIL sec0 got %h", v);

        set_index(7'h09);
        read_data(v);
        if (v !== 8'h97)
            $fatal(1, "FAIL year BCD got %h", v);

        set_index(7'h32);
        read_data(v);
        if (v !== 8'h19)
            $fatal(1, "FAIL century got %h", v);

        repeat (RTC_HZ + 20) @(posedge clock);
        set_index(7'h00);
        read_data(v);
        if (v !== 8'h01)
            $fatal(1, "FAIL sec after 1s got %h", v);

        io_write(16'h0070, 8'h8B);
        io_write(16'h0071, 8'h82);
        repeat (RTC_HZ + 20) @(posedge clock);
        set_index(7'h00);
        read_data(v);
        if (v !== 8'h01)
            $fatal(1, "FAIL SET freeze sec got %h", v);

        io_write(16'h0070, 8'h0B);
        io_write(16'h0071, 8'h02);
        repeat (RTC_HZ + 20) @(posedge clock);
        set_index(7'h00);
        read_data(v);
        if (v !== 8'h02)
            $fatal(1, "FAIL sec after SET clear got %h", v);

        io_write(16'h0070, 8'h0B);
        io_write(16'h0071, 8'h12);
        repeat (RTC_HZ + 20) @(posedge clock);
        if (!rtc_irq)
            $fatal(1, "FAIL o_rtc_irq after UIE tick");

        set_index(7'h0C);
        read_data(v);
        if (v[4] !== 1'b1)
            $fatal(1, "FAIL RegC UF bit got %h", v);

        read_data(v);
        if (v !== 8'h00 || rtc_irq !== 1'b0)
            $fatal(1, "FAIL RegC clear got %h irq=%b", v, rtc_irq);

        $display("PASS rtc_mc146818_tb");
        $finish;
    end

endmodule
