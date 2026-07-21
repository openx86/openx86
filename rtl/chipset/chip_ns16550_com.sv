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
//  File        : chip_ns16550_com.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : chip_ns16550_com module
// ============================================================================

// ============================================================================
// NS16550 兼容 UART — COM1
// 主机接口：nCS/nRD/nWR + A[ 2: 0]（相对基址 0x3F8 的寄存器偏移）
// 简化：无 FIFO 深度、无 divisor 时序；THR 写、RBR 读；MCR.4 为内部回环时 THR→RBR
// 可选 i_rx_push / i_rx_data 用于仿真注入接收字节
// ============================================================================

module chip_ns16550_com (
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
    // simulation injection interface
    // =========================
    input  logic         i_rx_push,
    input  logic [ 7: 0] i_rx_data,

    // =========================
    // clock and reset
    // =========================
    input  logic         clk,
    input  logic         rst_n
);

    localparam int LP_FIFO_D = 16;
    localparam int LP_DIV_W = 16;
    localparam int LP_BAUD_W = 16;
    localparam logic [ 3: 0] LP_IIR_NONE = 4'b0001;
    localparam logic [ 3: 0] LP_IIR_MS   = 4'b0000;
    localparam logic [ 3: 0] LP_IIR_THRE = 4'b0010;
    localparam logic [ 3: 0] LP_IIR_RDA  = 4'b0100;

    // ============================================================
    // register index
    // ============================================================
    logic [ 2: 0] off;

    assign off = i_a;

    // ============================================================
    // UART registers
    // ============================================================
    logic [ 7: 0] rbr;
    logic         rbr_valid;
    logic [ 7: 0] ier;
    logic [ 7: 0] fcr;
    logic [ 7: 0] lcr;
    logic [ 7: 0] mcr;
    logic [ 7: 0] scr;
    logic [ 7: 0] dll;
    logic [ 7: 0] dlm;

    // ============================================================
    // control signals
    // ============================================================
    logic         dlab;
    logic         wr;
    logic         rd;

    assign dlab = lcr[7];
    assign wr   = !i_cs_n && !i_wr_n;
    assign rd   = !i_cs_n && !i_rd_n;
    // Bus may hold WR# for multiple clocks; treat writes as one-cycle edges.
    logic         wr_r;
    logic         wr_posedge;
    assign wr_posedge = wr & ~wr_r;

    // ============================================================
    // transmit status
    // ============================================================
    logic         thr_empty;
    logic         tx_empty;
    logic         tx_drain_pending;
    logic         thre_irq_pending;

    // ============================================================
    // modem status register
    // ============================================================
    logic [ 3: 0] msr_status;
    logic [ 3: 0] msr_status_prev;
    logic [ 3: 0] msr_delta;
    logic [ 7: 0] msr;

    assign msr = {msr_status, msr_delta};

    // ============================================================
    // interrupt conditions
    // ============================================================
    logic         irq_rda;
    logic         irq_thre;
    logic         irq_ms;
    logic [ 3: 0] iir_code;
    logic [ 1: 0] iir_fifo_bits;
    logic [ 7: 0] iir;

    // ============================================================
    // line status register
    // ============================================================
    logic [ 7: 0] lsr;

    assign irq_rda       = ier[0] && rbr_valid;
    assign irq_thre      = ier[1] && thre_irq_pending;
    assign irq_ms        = ier[3] && (|msr_delta);
    assign iir_fifo_bits = fcr[0] ? 2'b11 : 2'b00;
    assign iir           = {iir_fifo_bits, 2'b00, iir_code[3: 1], iir_code[0]};
    assign lsr           = {1'b0, tx_empty, thr_empty, 1'b0, 1'b0, 1'b0, 1'b0, rbr_valid};

    // MSR 高半字节：回环时反映 MCR 位；否则外部调制解调器输入未建模为 0。
    always_comb begin
        if (mcr[4])
            // loopback mode: MSR[7: 4] reflects internal modem outputs
            msr_status = {mcr[3], mcr[2], mcr[0], mcr[1]};
        else
            // external modem inputs are not modeled in this chipset bridge
            msr_status = 4'b0000;
    end

    // IIR 中断类型优先级：RDA > THRE > 调制解调器状态。
    always_comb begin
        // implemented priorities: RDA > THRE > Modem Status
        if (irq_rda)
            iir_code = LP_IIR_RDA;
        else if (irq_thre)
            iir_code = LP_IIR_THRE;
        else if (irq_ms)
            iir_code = LP_IIR_MS;
        else
            iir_code = LP_IIR_NONE;
    end

    // Simulation TX probe — hierarchical path:
    //   dut.u_bus_controller.u_chip_com1.thr_shadow
    //   dut.u_bus_controller.u_chip_com1.thr_write_pulse
    logic [ 7: 0] thr_shadow;
    logic         thr_write_pulse;

    // 寄存器与简化发送/接收路径、MSR 边沿与读清逻辑。
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            rbr       <= 8'h0;
            rbr_valid <= 1'b0;
            ier       <= 8'h0;
            fcr       <= 8'h0;
            lcr       <= 8'h03;
            mcr       <= 8'h0;
            scr       <= 8'h0;
            dll       <= 8'h01;
            dlm       <= 8'h0;

            thr_empty        <= 1'b1;
            tx_empty         <= 1'b1;
            tx_drain_pending <= 1'b0;
            thre_irq_pending <= 1'b1;
            thr_shadow       <= 8'h0;
            thr_write_pulse  <= 1'b0;
            wr_r             <= 1'b0;
            msr_status_prev <= 4'b0000;
            msr_delta       <= 4'b0000;
        end else begin
            thr_write_pulse <= 1'b0;
            wr_r            <= wr;
            if (tx_drain_pending) begin
                tx_drain_pending <= 1'b0;
                thr_empty        <= 1'b1;
                tx_empty         <= 1'b1;
                thre_irq_pending <= 1'b1;
            end

            if (msr_status[0] != msr_status_prev[0])
                msr_delta[0] <= 1'b1;
            if (msr_status[1] != msr_status_prev[1])
                msr_delta[1] <= 1'b1;
            if (msr_status_prev[2] && !msr_status[2])
                msr_delta[2] <= 1'b1;
            if (msr_status[3] != msr_status_prev[3])
                msr_delta[3] <= 1'b1;
            msr_status_prev <= msr_status;

            if (i_rx_push) begin
                rbr       <= i_rx_data;
                rbr_valid <= 1'b1;
            end
            if (wr_posedge) begin
                unique case (off)
                    3'd0: begin
                        if (dlab)
                            dll <= i_d;
                        else begin
                            thr_empty        <= 1'b0;
                            tx_empty         <= 1'b0;
                            tx_drain_pending <= 1'b1;
                            thre_irq_pending <= 1'b0;
                            thr_shadow       <= i_d;
                            thr_write_pulse  <= 1'b1;

                            if (mcr[4]) begin
                                rbr       <= i_d;
                                rbr_valid <= 1'b1;
                            end
                        end
                    end
                    3'd1: begin
                        if (dlab)
                            dlm <= i_d;
                        else begin
                            ier <= {i_d[7: 6], 2'b00, i_d[3: 0]};
                            if (!ier[1] && i_d[1] && thr_empty)
                                thre_irq_pending <= 1'b1;
                        end
                    end
                    3'd2: begin
                        // FCR is write-only; bit[0] gates FIFO-specific controls,
                        // bit[4] (DMA-end signaling) remains directly writable.
                        fcr <= {
                            (i_d[0] ? i_d[7: 6] : 2'b00),
                            1'b0,
                            i_d[4],
                            (i_d[0] ? i_d[3] : 1'b0),
                            2'b00,
                            i_d[0]
                        };

                        if (i_d[0] && i_d[1])
                            rbr_valid <= 1'b0;
                        if (i_d[0] && i_d[2]) begin
                            thr_empty        <= 1'b1;
                            tx_empty         <= 1'b1;
                            tx_drain_pending <= 1'b0;
                            thre_irq_pending <= 1'b1;
                        end
                    end
                    3'd3: lcr <= i_d;
                    3'd4: mcr <= {3'b000, i_d[4: 0]};
                    3'd5: ; // LSR read-only
                    3'd6: ; // MSR
                    3'd7: scr <= i_d;
                endcase
            end

            if (rd && off == 3'd0 && !dlab && !i_rx_push)
                rbr_valid <= 1'b0;

            if (rd && off == 3'd6)
                msr_delta <= 4'b0000;

            if (rd && off == 3'd2 && iir_code == LP_IIR_THRE)
                thre_irq_pending <= 1'b0;
        end
    end

    // 读寄存器：DLAB 影响 DLL/DLM 与 THR 选择。
    always_comb begin
        o_d = 8'hFF;
        if (rd) begin
            unique case (off)
                3'd0: o_d = dlab ? dll : rbr;
                3'd1: o_d = dlab ? dlm : ier;
                3'd2: o_d = iir;
                3'd3: o_d = lcr;
                3'd4: o_d = mcr;
                3'd5: o_d = lsr;
                3'd6: o_d = msr;
                3'd7: o_d = scr;
            endcase
        end
    end

endmodule
