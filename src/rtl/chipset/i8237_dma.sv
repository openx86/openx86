// ============================================================================
// Intel 8237 DMA — 寄存器占位模型（无真实 ISA 总线主控周期）
// 端口 0x00-0x0F：通道地址/计数、命令、请求、屏蔽等（字节存储）
// 0x80-0x8F：页寄存器（本模型仅 8 个端口映射到内部数组）
// 0xC0-0xDF：16 位 DMA 扩展端口（占位读回写入值）
// ============================================================================

module i8237_dma (
    input  logic        i_clock,
    input  logic        i_reset,
    input  logic        i_io_valid,
    input  logic        i_io_we,
    input  logic [15:0] i_io_addr,
    input  logic [7:0]  i_io_wdata,
    output logic [7:0]  o_io_rdata,
    output logic        o_io_hit
);

    logic [7:0] regfile [0:15];
    logic [7:0] page_reg [0:7];
    logic [7:0] dma16_stub [0:31];

    wire hit_lo   = (i_io_addr <= 16'h000F);
    wire hit_page = (i_io_addr >= 16'h0080) && (i_io_addr <= 16'h008F);
    wire hit_hi   = (i_io_addr >= 16'h00C0) && (i_io_addr <= 16'h00DF);

    assign o_io_hit = hit_lo || hit_page || hit_hi;

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            for (int i = 0; i < 16; i++)
                regfile[i] <= 8'h00;
            for (int j = 0; j < 8; j++)
                page_reg[j] <= 8'h00;
            for (int k = 0; k < 32; k++)
                dma16_stub[k] <= 8'h00;
        end else if (i_io_valid && i_io_we && o_io_hit) begin
            if (hit_lo)
                regfile[i_io_addr[3:0]] <= i_io_wdata;
            else if (hit_page)
                page_reg[i_io_addr[2:0]] <= i_io_wdata;
            else if (hit_hi)
                dma16_stub[i_io_addr[4:0]] <= i_io_wdata;
        end
    end

    always_comb begin
        o_io_rdata = 8'hFF;
        if (i_io_valid && !i_io_we && o_io_hit) begin
            if (hit_lo)
                o_io_rdata = regfile[i_io_addr[3:0]];
            else if (hit_page)
                o_io_rdata = page_reg[i_io_addr[2:0]];
            else
                o_io_rdata = dma16_stub[i_io_addr[4:0]];
        end
    end

endmodule
