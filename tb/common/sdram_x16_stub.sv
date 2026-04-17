/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements sdram_x16_stub.
*/
// ============================================================================
// 16-bit SDRAM 阵列仿真模型（与 sdram_controller 配套）
// - 写：根据 ACT 锁存行，在 WR AP 后随 host_dq_oe 两拍写入 {mem[lin], mem[lin+1]}
// - 读：在 RD AP 后经 CAS 延迟在 model_dq 上驱动两拍 16-bit 数据
// linear_halfword = {row[12: 0], bank[ 1: 0], col[ 7: 0]}
// ============================================================================

`timescale 1ns/1ps

module sdram_x16_stub #(
    parameter int CAS_LATENCY       = 2,
    parameter int MEM_HALFWORDS_LG2 = 21
) (
    input  logic        clk,
    input  logic        cs_n,
    input  logic        ras_n,
    input  logic        cas_n,
    input  logic        we_n,
    input  logic [ 1: 0]  ba,
    input  logic [12: 0] a,
    input  logic [15: 0] host_dq_out,
    input  logic        host_dq_oe,
    output logic [15: 0] model_dq,
    output logic        model_dq_oe
);

    localparam int AW = MEM_HALFWORDS_LG2;
    (* ram_style = "block" *)
    logic [15: 0] mem[0:(1<<AW)-1];

    logic [12: 0] active_row[ 0:  3];

    wire cmd_act = !cs_n && !ras_n && cas_n && we_n;
    wire cmd_rd  = !cs_n && ras_n && !cas_n && we_n;
    wire cmd_wr  = !cs_n && ras_n && !cas_n && !we_n;

    wire [AW-1:0] lin_cmd = {active_row[ba], ba, a[ 7: 0]};

    logic [AW-1:0] w_lin;
    int unsigned   w_phase;

    typedef enum logic [ 2: 0] {
        RD_IDLE,
        RD_WAIT,
        RD_D0,
        RD_D1
    } rd_st_t;

    rd_st_t          rd_st;
    int unsigned     rd_wait;
    logic [AW-1:0]   rd_lin;

    integer ii;
    initial begin
        for (ii = 0; ii < (1 << AW); ii++) mem[ii] = 16'h0;
        w_lin    = '0;
        w_phase  = 0;
        rd_st    = RD_IDLE;
        rd_wait  = 0;
        rd_lin   = '0;
        model_dq    = 16'h0;
        model_dq_oe = 1'b0;
    end

    always @(posedge clk) begin
        model_dq_oe <= 1'b0;
        model_dq    <= 16'h0;

        if (cmd_act) begin
            active_row[ba] <= a[12: 0];
        end

        // 写路径（阻塞赋值保证与 cmd_wr 同拍时序）
        if (cmd_wr) begin
            w_lin   = lin_cmd;
            w_phase = 0;
        end
        if (host_dq_oe) begin
            mem[w_lin + AW'(w_phase)] = host_dq_out;
            w_phase = w_phase + 1;
            if (w_phase == 2)
                w_phase = 0;
        end

        unique case (rd_st)
            RD_IDLE: begin
                if (cmd_rd) begin
                    rd_lin <= lin_cmd;
                    if (CAS_LATENCY <= 1) begin
                        rd_st <= RD_D0;
                    end else begin
                        rd_wait <= CAS_LATENCY - 1;
                        rd_st   <= RD_WAIT;
                    end
                end
            end
            RD_WAIT: begin
                if (rd_wait == 0)
                    rd_st <= RD_D0;
                else
                    rd_wait <= rd_wait - 1;
            end
            RD_D0: begin
                model_dq    <= mem[rd_lin];
                model_dq_oe <= 1'b1;
                rd_st       <= RD_D1;
            end
            RD_D1: begin
                model_dq    <= mem[rd_lin + AW'(1)];
                model_dq_oe <= 1'b1;
                rd_st       <= RD_IDLE;
            end
            default: rd_st <= RD_IDLE;
        endcase
    end

endmodule
