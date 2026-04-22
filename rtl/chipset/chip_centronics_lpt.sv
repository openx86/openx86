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
//  File        : chip_centronics_lpt.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : chip_centronics_lpt module
// ============================================================================

// ============================================================================
// IBM PC 并行口（LPT1）— Centronics 风格寄存器级模型
// 主机接口：nCS/nRD/nWR + A[ 2: 0]（相对基址 0x378）
// 状态位与 PC 一致：Busy/ACK 等为反相有效（读时按常见 BIOS 期望编码）
// ============================================================================

module chip_centronics_lpt (
    // =========================
    // CPU bus interface
    // =========================
    input  logic         i_cs_n,
    input  logic         i_rd_n,
    input  logic         i_wr_n,
    input  logic [ 2: 0] i_a,
    input  logic [ 7: 0] i_d,
    output logic [ 7: 0] o_d,

    // =========================
    // clock and reset
    // =========================
    input  logic         clk,
    input  logic         rst_n
);

    // ============================================================
    // register index
    // ============================================================
    logic [ 2: 0] off;

    assign off = i_a;

    // ============================================================
    // data and control registers
    // ============================================================
    logic [ 7: 0] data_reg;
    logic [ 7: 0] ctrl_reg;

    // ============================================================
    // write strobe
    // ============================================================
    logic wr;

    assign wr = !i_cs_n && !i_wr_n;

    // ============================================================
    // write data/control registers
    // ============================================================
    always_ff @(posedge clk or negedge rst_n) begin : ff_register_write
        if (~rst_n) begin
            data_reg <= 8'h0;
            ctrl_reg <= 8'h0C;
        end else if (wr) begin
            unique case (off)
                3'd0: data_reg <= i_d;
                3'd2: ctrl_reg <= i_d;
                default: ;
            endcase
        end
    end

    // ============================================================
    // fixed idle/ready status encoding
    // ============================================================
    logic [ 7: 0] status_read = {
        1'b0,
        1'b1,
        1'b1,
        1'b1,
        1'b1,
        1'b0,
        1'b1,
        1'b1
    };

    // ============================================================
    // read strobe
    // ============================================================
    logic rd;

    assign rd = !i_cs_n && !i_rd_n;

    // ============================================================
    // read data/status/control ports
    // ============================================================
    always_comb begin : comb_register_read
        o_d = 8'hFF;
        if (rd) begin
            unique case (off)
                3'd0: o_d = data_reg;
                3'd1: o_d = status_read;
                3'd2: o_d = ctrl_reg;
                default: o_d = 8'hFF;
            endcase
        end
    end

endmodule
