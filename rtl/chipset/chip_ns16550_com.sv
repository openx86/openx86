/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_ns16550_com.
*/
// ============================================================================
// NS16550 兼容 UART — COM1
// 主机接口：nCS/nRD/nWR + A[ 2:  0]（相对基址 0x3F8 的寄存器偏移）
// 简化：无 FIFO 深度、无 divisor 时序；THR 写、RBR 读；MCR.4 为内部回环时 THR→RBR
// 可选 i_rx_push / i_rx_data 用于仿真注入接收字节
// ============================================================================

module chip_ns16550_com (
    input  logic        i_cs_n,
    input  logic        i_rd_n,
    input  logic        i_wr_n,
    input  logic [ 2:  0]  i_a,
    input  logic [ 7:  0]  i_d,
    output logic [ 7:  0]  o_d,
    input  logic        i_rx_push,
    input  logic [ 7:  0]  i_rx_data,
    input  logic        reset_n,
    input  logic        clock);

    wire [ 2:  0] off = i_a;

    logic [ 7:  0] rbr;
    logic       rbr_valid;
    logic [ 7:  0] ier;
    logic [ 7:  0] fcr;
    logic [ 7:  0] lcr;
    logic [ 7:  0] mcr;
    logic [ 7:  0] scr;
    logic [ 7:  0] dll, dlm;

    wire dlab = lcr[7];

    wire wr = !i_cs_n && !i_wr_n;
    wire rd = !i_cs_n && !i_rd_n;

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            rbr       <= 8'h0;
            rbr_valid <= 1'b0;
            ier       <= 8'h0;
            fcr       <= 8'h0;
            lcr       <= 8'h03;
            mcr       <= 8'h0;
            scr       <= 8'h0;
            dll       <= 8'h01;
            dlm       <= 8'h0;
        end else begin
            if (i_rx_push) begin
                rbr       <= i_rx_data;
                rbr_valid <= 1'b1;
            end
            if (wr) begin
                unique case (off)
                    3'd0: begin
                        if (dlab)
                            dll <= i_d;
                        else begin
                            if (mcr[4]) begin
                                rbr       <= i_d;
                                rbr_valid <= 1'b1;
                            end
                        end
                    end
                    3'd1: begin
                        if (dlab)
                            dlm <= i_d;
                        else
                            ier <= i_d;
                    end
                    3'd2: fcr <= i_d;
                    3'd3: lcr <= i_d;
                    3'd4: mcr <= i_d;
                    3'd5: ; // LSR read-only
                    3'd6: ; // MSR
                    3'd7: scr <= i_d;
                endcase
            end else if (rd && off == 3'd0 && !dlab && rbr_valid) begin
                rbr_valid <= 1'b0;
            end
        end
    end

    wire [ 7:  0] lsr = { 1'b0, 1'b0, 1'b1, 1'b1, 4'b0000, rbr_valid };

    always_comb begin
        o_d = 8'hFF;
        if (rd) begin
            unique case (off)
                3'd0: o_d = dlab ? dll : rbr;
                3'd1: o_d = dlab ? dlm : ier;
                3'd2: o_d = 8'hC1;
                3'd3: o_d = lcr;
                3'd4: o_d = mcr;
                3'd5: o_d = lsr;
                3'd6: o_d = 8'hB0;
                3'd7: o_d = scr;
            endcase
        end
    end

endmodule
