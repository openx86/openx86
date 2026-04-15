// ============================================================================
// SDRAM Controller — 主机侧 32bit 字对齐访问 + 多周期握手
// 内部集成存储阵列（仿真/综合用 block RAM）；对外保留简化 SDRAM 命令引脚
// 典型时序：请求后 LATENCY 个周期完成，o_ready 脉冲 1 拍，o_rdata 与 o_ready 同拍有效
// ============================================================================

module sdram_controller #(
    parameter int MEM_WORDS_LG2 = 18,
    parameter int LATENCY       = 5
) (
    input  logic        clk,
    input  logic        rst,

    // 主机（与总线桥接：i_en = 译码命中 && bus_valid）
    input  logic        i_en,
    input  logic        i_we,
    input  logic [23:0] i_addr_off,
    input  logic [31:0] i_wdata,
    output logic [31:0] o_rdata,
    output logic        o_ready,
    output logic        o_busy,

    // 简化 SDRAM 物理侧（空闲时为 NOP：CS# 无效）
    output logic        o_sdram_clk,
    output logic        o_sdram_cke,
    output logic        o_sdram_cs_n,
    output logic        o_sdram_ras_n,
    output logic        o_sdram_cas_n,
    output logic        o_sdram_we_n,
    output logic [1:0]  o_sdram_ba,
    output logic [12:0] o_sdram_a,
    output logic [1:0]  o_sdram_dqm,
    output logic [15:0] o_sdram_dq_out,
    output logic        o_sdram_dq_oe
);

    localparam int MEM_WORDS = 1 << MEM_WORDS_LG2;
    localparam int WCW       = (LATENCY <= 1) ? 1 : $clog2(LATENCY);

    (* ram_style = "block" *)
    logic [31:0] mem[0:MEM_WORDS-1];

    typedef enum logic [1:0] {
        ST_IDLE,
        ST_WAIT,
        ST_ACK
    } state_t;

    state_t state;
    logic [WCW-1:0] wait_ctr;
    logic [23:0] latched_addr;
    logic        latched_we;
    logic [31:0] latched_wdata;

    logic [21:0] word_idx;
    assign word_idx = latched_addr[23:2];

    logic [MEM_WORDS_LG2-1:0] word_phys;
    assign word_phys = word_idx[MEM_WORDS_LG2-1:0];

    // 空闲 PHY：CS#=1 为器件未选中（等价 NOP）
    assign o_sdram_clk   = clk;
    assign o_sdram_cke   = 1'b1;
    assign o_sdram_cs_n  = 1'b1;
    assign o_sdram_ras_n = 1'b1;
    assign o_sdram_cas_n = 1'b1;
    assign o_sdram_we_n  = 1'b1;
    assign o_sdram_ba    = 2'b0;
    assign o_sdram_a     = 13'b0;
    assign o_sdram_dqm   = 2'b0;
    assign o_sdram_dq_out = 16'b0;
    assign o_sdram_dq_oe  = 1'b0;

    assign o_busy = (state != ST_IDLE);

    always_ff @(posedge clk) begin
        o_ready <= 1'b0;
        if (rst) begin
            state        <= ST_IDLE;
            wait_ctr     <= '0;
            o_rdata      <= 32'h0;
            latched_addr <= '0;
            latched_we   <= 1'b0;
            latched_wdata<= 32'h0;
        end else begin
            unique case (state)
                ST_IDLE: begin
                    if (i_en) begin
                        latched_addr  <= i_addr_off;
                        latched_we    <= i_we;
                        latched_wdata <= i_wdata;
                        wait_ctr      <= '0;
                        state         <= ST_WAIT;
                    end
                end
                ST_WAIT: begin
                    if (wait_ctr == (LATENCY - 1)) begin
                        state <= ST_ACK;
                    end else begin
                        wait_ctr <= wait_ctr + 1'b1;
                    end
                end
                ST_ACK: begin
                    if (latched_we) begin
                        mem[word_phys] <= latched_wdata;
                    end else begin
                        o_rdata <= mem[word_phys];
                    end
                    o_ready <= 1'b1;
                    state <= ST_IDLE;
                end
                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule
