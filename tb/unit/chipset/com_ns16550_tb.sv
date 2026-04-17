/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements com_ns16550_tb.
*/
// ============================================================================
// com_ns16550 testbench — 写 THR + 回环读 RBR，读 LSR（ISA 并行口）
// ============================================================================
`timescale 1ns/1ps

module com_ns16550_tb;

    logic        clock;
    logic        reset_n;
    logic        io_valid, io_we;
    logic [15: 0] io_addr;
    logic [ 7: 0] io_wdata, io_rdata;
    logic        rx_push;
    logic [ 7: 0] rx_data;

    logic com_hit;
    logic cs_n;
    logic wr_n;
    logic rd_n;

    assign com_hit = (io_addr >= 16'h03F8) && (io_addr <= 16'h03FF);
    assign cs_n    = !(io_valid && com_hit);
    assign wr_n    = !(io_valid && io_we && com_hit);
    assign rd_n    = !(io_valid && !io_we && com_hit);

    chip_ns16550_com dut (
        .clock    ( clock ),
        .reset_n  ( reset_n ),
        .i_cs_n     ( cs_n ),
        .i_rd_n     ( rd_n ),
        .i_wr_n     ( wr_n ),
        .i_a        ( io_addr[ 2: 0] ),
        .i_d        ( io_wdata ),
        .o_d        ( io_rdata ),
        .i_rx_push  ( rx_push ),
        .i_rx_data  ( rx_data )
    );

    always #5 clock = ~clock;

    task automatic wr(input logic [15: 0] a, input  logic [ 7: 0] d);
        @(posedge clock);
        io_valid = 1;
        io_we    = 1;
        io_addr  = a;
        io_wdata = d;
        @(posedge clock);
        io_valid = 0;
    endtask

    task automatic rd(input logic [15: 0] a, output logic [ 7: 0] d);
        @(posedge clock);
        io_valid = 1;
        io_we    = 0;
        io_addr  = a;
        @(posedge clock);
        d = io_rdata;
        io_valid = 0;
    endtask

    task automatic check_eq(
        input logic [ 7: 0] got,
        input logic [ 7: 0] exp,
        input string        tag
    );
        if (got !== exp) begin
            $display("FAIL %s got=%h exp=%h", tag, got, exp);
            $fatal(1);
        end else begin
            $display("PASS %s = %h", tag, got);
        end
    endtask

    task automatic check_mask_eq(
        input logic [ 7: 0] got,
        input logic [ 7: 0] mask,
        input logic [ 7: 0] exp,
        input string        tag
    );
        if ((got & mask) !== exp) begin
            $display("FAIL %s got=%h mask=%h exp=%h", tag, got, mask, exp);
            $fatal(1);
        end else begin
            $display("PASS %s got=%h", tag, got);
        end
    endtask

    task automatic inject_rx(input logic [ 7: 0] d);
        @(posedge clock);
        rx_data = d;
        rx_push = 1'b1;
        @(posedge clock);
        rx_push = 1'b0;
    endtask

    logic [ 7: 0] rb;
    initial begin
        clock    = 0;
        rx_push  = 0;
        rx_data  = 0;
        reset_n  = 0;
        io_valid = 0;
        repeat (4) @(posedge clock);
        reset_n = 1;
        repeat (2) @(posedge clock);

        // reset defaults: LSR bit5/bit6 set, DR cleared
        rd(16'h03FD, rb);
        check_eq(rb, 8'h60, "LSR reset value");

        // IER bits 4/5 are always zero on readback
        wr(16'h03F9, 8'hFF);
        rd(16'h03F9, rb);
        check_eq(rb, 8'hCF, "IER writable bits");

        // MCR bits 7:5 are hardwired to zero
        wr(16'h03FC, 8'hFF);
        rd(16'h03FC, rb);
        check_eq(rb, 8'h1F, "MCR writable bits");

        // DLAB path: DLL/DLM access through offsets 0/1
        wr(16'h03FB, 8'h80);
        wr(16'h03F8, 8'h34);
        wr(16'h03F9, 8'h12);
        rd(16'h03F8, rb);
        check_eq(rb, 8'h34, "DLL readback");
        rd(16'h03F9, rb);
        check_eq(rb, 8'h12, "DLM readback");
        wr(16'h03FB, 8'h03);

        // FIFO disabled -> IIR[7:6]=00, no pending interrupt -> bit0=1
        wr(16'h03FA, 8'h00);
        wr(16'h03F9, 8'h00);
        rd(16'h03FA, rb);
        check_eq(rb, 8'h01, "IIR none pending");

        // THRE interrupt pending when enabled; ISR read clears THRE interrupt latch
        wr(16'h03F9, 8'h02);
        rd(16'h03FA, rb);
        check_mask_eq(rb, 8'h0F, 8'h02, "IIR THRE pending");
        rd(16'h03FA, rb);
        check_mask_eq(rb, 8'h0F, 8'h01, "IIR THRE cleared by ISR read");

        // Data ready interrupt reports as highest priority when data is available
        wr(16'h03F9, 8'h01);
        inject_rx(8'hA5);
        rd(16'h03FA, rb);
        check_mask_eq(rb, 8'h0F, 8'h04, "IIR RDA pending");
        rd(16'h03F8, rb);
        check_eq(rb, 8'hA5, "RBR read injected data");
        rd(16'h03FA, rb);
        check_mask_eq(rb, 8'h0F, 8'h01, "IIR cleared after RBR read");

        // Loopback modem mapping: MSR[7:4] follows MCR[3],MCR[2],MCR[0],MCR[1]
        wr(16'h03FC, 8'h1F);
        rd(16'h03FE, rb);
        check_mask_eq(rb, 8'hF0, 8'hF0, "MSR loopback status high nibble");

        // Change loopback outputs to generate delta bits; second read clears deltas
        wr(16'h03FC, 8'h10);
        rd(16'h03FE, rb);
        check_mask_eq(rb, 8'hF0, 8'h00, "MSR status after loopback change");
        if ((rb & 8'h0F) == 8'h00) begin
            $display("FAIL MSR delta bits not set after loopback change rb=%h", rb);
            $fatal(1);
        end
        rd(16'h03FE, rb);
        check_mask_eq(rb, 8'h0F, 8'h00, "MSR deltas clear on read");

        wr(16'h03FC, 8'h10);
        wr(16'h03F8, 8'h55);
        rd(16'h03F8, rb);
        check_eq(rb, 8'h55, "THR->RBR loopback");

        rd(16'h03FD, rb);
        check_mask_eq(rb, 8'h01, 8'h00, "LSR DR clears after RBR read");

        $display("com_ns16550_tb done");
        $finish;
    end

endmodule
