// ============================================================================
// MC146818 兼容 RTC/CMOS — 简化模型
// 0x70: 索引（低 7 位）；bit7 常作 NMI 屏蔽（本模型仅存储）
// 0x71: 读写 CMOS[index]
// 时间寄存器：固定为二进制（非 BCD），与 PC BIOS 可能不完全一致
// ============================================================================

module rtc_mc146818 (
    input  logic        i_clock,
    input  logic        i_reset,
    input  logic        i_io_valid,
    input  logic        i_io_we,
    input  logic [15:0] i_io_addr,
    input  logic [7:0]  i_io_wdata,
    output logic [7:0]  o_io_rdata,
    output logic        o_io_hit
);

    assign o_io_hit = (i_io_addr == 16'h0070) || (i_io_addr == 16'h0071);

    logic [7:0] index_reg;
    logic [7:0] cmos [0:127];

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            index_reg <= '0;
            for (int i = 0; i < 128; i++)
                cmos[i] <= 8'h00;
            // 初值：1997-10-06 00:00:00（二进制寄存器，非 BCD）
            cmos[0] <= 8'h00; // 秒
            cmos[2] <= 8'h00; // 分
            cmos[4] <= 8'h00; // 时
            cmos[6] <= 8'h02; // 星期（1=日 … 7=六；1997-10-06 为周一）
            cmos[7] <= 8'h06; // 日
            cmos[8] <= 8'h0A; // 月
            cmos[9] <= 8'h61; // 年低（十进制 97 → 1997）
        end else if (i_io_valid && i_io_we && o_io_hit) begin
            if (i_io_addr == 16'h0070)
                index_reg <= i_io_wdata;
            else
                cmos[index_reg[6:0]] <= i_io_wdata;
        end
    end

    always_comb begin
        o_io_rdata = 8'hFF;
        if (i_io_valid && !i_io_we && o_io_hit) begin
            if (i_io_addr == 16'h0070)
                o_io_rdata = index_reg;
            else
                o_io_rdata = cmos[index_reg[6:0]];
        end
    end

endmodule
