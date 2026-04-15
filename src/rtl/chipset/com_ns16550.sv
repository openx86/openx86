// ============================================================================
// NS16550 兼容 UART — COM1 端口 0x3F8–0x3FF（8 寄存器，DLAB 切换波特率锁存）
// 简化：无 FIFO 深度、无 divisor 时序；THR 写、RBR 读；MCR.4 为内部回环时 THR→RBR
// 可选 i_rx_push / i_rx_data 用于仿真注入接收字节
// ============================================================================

module com_ns16550 #(
    parameter logic [15:0] PORT_BASE = 16'h03F8
) (
    input  logic        i_clock,
    input  logic        i_reset,
    input  logic        i_io_valid,
    input  logic        i_io_we,
    input  logic [15:0] i_io_addr,
    input  logic [7:0]  i_io_wdata,
    output logic [7:0]  o_io_rdata,
    output logic        o_io_hit,
    input  logic        i_rx_push,
    input  logic [7:0]  i_rx_data
);

    assign o_io_hit = (i_io_addr >= PORT_BASE) && (i_io_addr <= PORT_BASE + 16'h7);

    wire [2:0] off = i_io_addr[2:0];

    logic [7:0] rbr;
    logic       rbr_valid;
    logic [7:0] ier;
    logic [7:0] fcr;
    logic [7:0] lcr;
    logic [7:0] mcr;
    logic [7:0] scr;
    logic [7:0] dll, dlm;

    wire dlab = lcr[7];

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
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
            if (i_io_valid && i_io_we && o_io_hit) begin
                unique case (off)
                    3'd0: begin
                        if (dlab)
                            dll <= i_io_wdata;
                        else begin
                            if (mcr[4]) begin
                                rbr       <= i_io_wdata;
                                rbr_valid <= 1'b1;
                            end
                        end
                    end
                    3'd1: begin
                        if (dlab)
                            dlm <= i_io_wdata;
                        else
                            ier <= i_io_wdata;
                    end
                    3'd2: fcr <= i_io_wdata;
                    3'd3: lcr <= i_io_wdata;
                    3'd4: mcr <= i_io_wdata;
                    3'd5: ; // LSR read-only
                    3'd6: ; // MSR
                    3'd7: scr <= i_io_wdata;
                endcase
            end else if (i_io_valid && !i_io_we && o_io_hit && off == 3'd0 && !dlab && rbr_valid) begin
                rbr_valid <= 1'b0;
            end
        end
    end

    wire [7:0] lsr = { 1'b0, 1'b0, 1'b1, 1'b1, 4'b0000, rbr_valid };

    always_comb begin
        o_io_rdata = 8'hFF;
        if (i_io_valid && !i_io_we && o_io_hit) begin
            unique case (off)
                3'd0: o_io_rdata = dlab ? dll : rbr;
                3'd1: o_io_rdata = dlab ? dlm : ier;
                3'd2: o_io_rdata = 8'hC1;
                3'd3: o_io_rdata = lcr;
                3'd4: o_io_rdata = mcr;
                3'd5: o_io_rdata = lsr;
                3'd6: o_io_rdata = 8'hB0;
                3'd7: o_io_rdata = scr;
            endcase
        end
    end

endmodule
