/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Unit testbench for chip_8237_dma register-level behavior.
*/
// ============================================================================
// i8237_dma register-model testbench (ISA host-side accesses)
// ============================================================================
`timescale 1ns/1ps
module i8237_dma_tb;

    logic         clk = 0;
    logic         rst_n;
    logic         valid;
    logic         we;
    logic [15: 0] addr;
    logic [ 7: 0] wdata;
    logic [ 7: 0] rdata;

    integer fail_count;

    logic hit_lo;
    logic hit_page;
    logic hit_hi;
    logic hit;
    logic cs_n;
    logic wr_n;
    logic rd_n;

    always_comb begin
        hit_lo   = (addr <= 16'h000F);
        hit_page = (addr >= 16'h0080) && (addr <= 16'h008F);
        hit_hi   = (addr >= 16'h00C0) && (addr <= 16'h00DF);
        hit      = hit_lo | hit_page | hit_hi;
        cs_n     = !(valid && hit);
        wr_n     = !(valid && we && hit);
        rd_n     = !(valid && !we && hit);
    end

    chip_8237_dma dut (
        .i_cs_n  ( cs_n ),
        .i_rd_n  ( rd_n ),
        .i_wr_n  ( wr_n ),
        .i_addr  ( addr ),
        .i_d     ( wdata ),
        .o_d     ( rdata ),
        .clk   ( clk ),
        .rst_n ( rst_n )
    );

    always #5 clk = ~clk;

    task automatic io_write(input logic [15: 0] i_a, input logic [ 7: 0] i_d);
        @(negedge clk);
        valid = 1'b1;
        we    = 1'b1;
        addr  = i_a;
        wdata = i_d;
        @(posedge clk);
        @(negedge clk);
        valid = 1'b0;
        we    = 1'b0;
    endtask

    task automatic io_read(input logic [15: 0] i_a, output logic [ 7: 0] o_q);
        @(negedge clk);
        valid = 1'b1;
        we    = 1'b0;
        addr  = i_a;
        @(posedge clk);
        o_q = rdata;
        @(negedge clk);
        valid = 1'b0;
    endtask

    task automatic expect_eq(
        input string      i_tag,
        input logic [7: 0] i_got,
        input logic [7: 0] i_exp
    );
        if (i_got !== i_exp) begin
            fail_count = fail_count + 1;
            $display("FAIL %s got=%02h exp=%02h", i_tag, i_got, i_exp);
        end else begin
            $display("PASS %s value=%02h", i_tag, i_got);
        end
    endtask

    logic [7: 0] rb;

    initial begin
        fail_count = 0;
        rst_n    = 1'b0;
        valid      = 1'b0;
        we         = 1'b0;
        addr       = 16'h0000;
        wdata      = 8'h00;

        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        io_read(16'h000A, rb);
        expect_eq("reset mask", rb, 8'h0F);

        io_read(16'h0008, rb);
        expect_eq("reset status", rb, 8'h00);

        io_write(16'h0000, 8'h34);
        io_write(16'h0000, 8'h12);
        io_write(16'h000C, 8'h00);
        io_read(16'h0000, rb);
        expect_eq("ch0 addr lo", rb, 8'h34);
        io_read(16'h0000, rb);
        expect_eq("ch0 addr hi", rb, 8'h12);

        io_write(16'h0001, 8'h78);
        io_write(16'h0001, 8'h56);
        io_write(16'h000C, 8'h00);
        io_read(16'h0001, rb);
        expect_eq("ch0 count lo", rb, 8'h78);
        io_read(16'h0001, rb);
        expect_eq("ch0 count hi", rb, 8'h56);

        io_write(16'h000E, 8'h00);
        io_read(16'h000A, rb);
        expect_eq("clear mask", rb, 8'h00);

        io_write(16'h000F, 8'h05);
        io_read(16'h000A, rb);
        expect_eq("write all mask", rb, 8'h05);

        io_write(16'h000A, 8'h00);
        io_read(16'h000A, rb);
        expect_eq("single mask clear ch0", rb, 8'h04);

        io_write(16'h0009, 8'h05);
        io_read(16'h0008, rb);
        expect_eq("status request ch1", rb, 8'h20);

        io_write(16'h0009, 8'h01);
        io_read(16'h0008, rb);
        expect_eq("status request clear", rb, 8'h00);

        io_write(16'h000B, 8'hAB);
        io_read(16'h000B, rb);
        expect_eq("mode readback", rb, 8'hAB);

        io_write(16'h0080, 8'h11);
        io_write(16'h0088, 8'h22);
        io_read(16'h0080, rb);
        expect_eq("page 80h", rb, 8'h11);
        io_read(16'h0088, rb);
        expect_eq("page 88h", rb, 8'h22);

        io_write(16'h00C0, 8'h33);
        io_write(16'h00DF, 8'h44);
        io_read(16'h00C0, rb);
        expect_eq("dma16 c0", rb, 8'h33);
        io_read(16'h00DF, rb);
        expect_eq("dma16 df", rb, 8'h44);

        io_write(16'h0008, 8'h9A);
        io_write(16'h000D, 8'h00);
        io_read(16'h000A, rb);
        expect_eq("master clear mask", rb, 8'h0F);
        io_read(16'h0008, rb);
        expect_eq("master clear status", rb, 8'h00);
        io_write(16'h000C, 8'h00);
        io_read(16'h0000, rb);
        expect_eq("master clear addr lo", rb, 8'h00);

        if (fail_count == 0)
            $display("PASS i8237_dma_tb");
        else
            $display("FAIL i8237_dma_tb fail_count=%0d", fail_count);

        $finish;
    end

endmodule
