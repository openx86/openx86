/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_ns16550_com.
*/
// ============================================================================
// NS16550 兼容 UART — COM1
// 主机接口：nCS/nRD/nWR + A[ 2: 0]（相对基址 0x3F8 的寄存器偏移）
// 简化：无 FIFO 深度、无 divisor 时序；THR 写、RBR 读；MCR.4 为内部回环时 THR→RBR
// 可选 i_rx_push / i_rx_data 用于仿真注入接收字节
// ============================================================================

module chip_ns16550_com (
    input  logic         i_cs_n, // 低有效片选
    input  logic         i_rd_n, // 低有效读
    input  logic         i_wr_n, // 低有效写
    input  logic [ 2: 0] i_a, // 寄存器偏移（相对 0x3F8）
    input  logic [ 7: 0] i_d, // 写数据
    output logic [ 7: 0] o_d, // 读数据
    input  logic         i_rx_push, // 仿真/注入：推入一字节到接收缓冲
    input  logic [ 7: 0] i_rx_data, // 注入数据
    input  logic         rst_n, // 异步低有效复位
    input  logic         clk // 系统时钟
);

    localparam logic [ 3: 0] LP_IIR_NONE = 4'b0001;
    localparam logic [ 3: 0] LP_IIR_MS   = 4'b0000;
    localparam logic [ 3: 0] LP_IIR_THRE = 4'b0010;
    localparam logic [ 3: 0] LP_IIR_RDA  = 4'b0100;

    logic [ 2: 0] off;  // 当前寄存器索引

    assign off = i_a;

    logic [ 7: 0] rbr;         // 接收缓冲（读）
    logic         rbr_valid;   // RBR 有数据
    logic [ 7: 0] ier;         // 中断允许
    logic [ 7: 0] fcr;         // FIFO 控制（简化模型）
    logic [ 7: 0] lcr;         // 线路控制（含 DLAB）
    logic [ 7: 0] mcr;         // 调制解调器控制（含回环）
    logic [ 7: 0] scr;         // 暂存寄存器
    logic [ 7: 0] dll;         // 除数锁存低字节
    logic [ 7: 0] dlm;         // 除数锁存高字节

    logic         dlab;  // 除数锁存访问位
    logic         wr;
    logic         rd;

    assign dlab = lcr[7];
    assign wr = !i_cs_n && !i_wr_n;
    assign rd = !i_cs_n && !i_rd_n;

    logic         thr_empty;         // THR 空（简化 TX）
    logic         tx_empty;          // 发送移位路径空
    logic         tx_drain_pending;  // 写 THR 后一拍排空
    logic         thre_irq_pending;  // THRE 中断挂起

    logic [ 3: 0] msr_status;       // MSR 高半字节（状态）
    logic [ 3: 0] msr_status_prev;  // 上一拍状态（边沿检测）
    logic [ 3: 0] msr_delta;        // MSR 低半字节（变化锁存）
    logic [ 7: 0] msr;

    assign msr = {msr_status, msr_delta};

    logic         irq_rda;       // 接收数据可用中断条件
    logic         irq_thre;      // THRE 中断条件
    logic         irq_ms;        // 调制解调器状态中断条件
    logic [ 3: 0] iir_code;      // IIR 优先级编码结果
    logic [ 1: 0] iir_fifo_bits; // IIR 中 FIFO 使能位占位
    logic [ 7: 0] iir;

    logic [ 7: 0] lsr;  // 线路状态（简化）

    assign irq_rda = ier[0] && rbr_valid;
    assign irq_thre = ier[1] && thre_irq_pending;
    assign irq_ms = ier[3] && (|msr_delta);
    assign iir_fifo_bits = fcr[0] ? 2'b11 : 2'b00;
    assign iir = {iir_fifo_bits, 2'b00, iir_code[3: 1], iir_code[0]};
    assign lsr = {1'b0, tx_empty, thr_empty, 1'b0, 1'b0, 1'b0, 1'b0, rbr_valid};



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


    // 寄存器与简化发送/接收路径、MSR 边沿与读清逻辑。
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            rbr       <= 8'h0;
            rbr_valid <= 1'b0;
            ier       <= 8'h0;
            fcr       <= 8'h0;
            lcr       <= 8'h00;
            mcr       <= 8'h0;
            scr       <= 8'h0;
            dll       <= 8'h01;
            dlm       <= 8'h0;

            thr_empty        <= 1'b1;
            tx_empty         <= 1'b1;
            tx_drain_pending <= 1'b0;
            thre_irq_pending <= 1'b1;

            msr_status_prev <= 4'b0000;
            msr_delta       <= 4'b0000;
        end else begin
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
            if (wr) begin
                unique case (off)
                    3'd0: begin
                        if (dlab)
                            dll <= i_d;
                        else begin
                            thr_empty        <= 1'b0;
                            tx_empty         <= 1'b0;
                            tx_drain_pending <= 1'b1;
                            thre_irq_pending <= 1'b0;

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
