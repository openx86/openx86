/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements ps2_host_phy.
*/
// ============================================================================
// PS/2 主机侧物理层（单端口）
// 路径: rtl/periph — 由 rtl/chipset/chip_i8042_ps2 例化
//
// 电气模型：开漏 + 片外上拉。每根线用 (out, oe) 表示：oe=1 且 out=0 为拉低；
//           oe=0 为高阻，由上拉维持高电平（回读用 i_ps2_*_in，通常接同一 PAD）。
//
// 帧格式：起始 0，8 数据位 LSB 先，奇校验位，停止 1。
// ============================================================================

module ps2_host_phy #(
    parameter int CLK_HZ = 50_000_000
) (
    input  logic          i_ps2_clk_in,  // 来自焊盘的 PS/2 时钟（异步输入，经双拍）
    input  logic          i_ps2_dat_in,  // 来自焊盘的 PS/2 数据
    output logic         o_ps2_clk_out, // 主机驱动时钟线电平（开漏模型）
    output logic         o_ps2_clk_oe,  // 时钟线输出使能（拉低抑制期）
    output logic         o_ps2_dat_out, // 主机数据线驱动
    output logic         o_ps2_dat_oe,  // 数据线输出使能
    input  logic          i_tx_req,     // 单周期：请求发送一字节到设备
    input  logic [ 7: 0] i_tx_byte,     // 待发送数据
    // 主机 → 设备（单周期 i_tx_req 脉冲即可，o_tx_busy 期间勿重复请求）
    output logic         o_tx_busy,     // 发送进行中
    output logic         o_tx_done,     // 发送成功完成脉冲
    output logic         o_tx_err,      // 发送超时/无 ACK
    output logic         o_rx_strobe,   // 收到一字节脉冲
    output logic [ 7: 0] o_rx_byte,     // 接收数据
    // 设备 → 主机
    output logic         o_rx_err,      // 接收帧校验失败
    input  logic          clk,        // 主机逻辑时钟
    input  logic          rst_n       // 异步低有效复位
);

    // --- 时间常量（与 CLK_HZ 成比例）-----------------------------------------
    // 抑制时钟阶段：≥100µs，取 150µs
    localparam int CYCLES_INHIBIT_150US =
        (CLK_HZ / 1_000) * 150 / 1000 > 0 ? (CLK_HZ / 1_000) * 150 / 1000 : 64;
    // 等待设备 ACK 拉低 DATA 的超时
    localparam int CYCLES_ACK_TIMEOUT_MS2 =
        (CLK_HZ / 1000) * 2 > 0 ? (CLK_HZ / 1000) * 2 : 100_000;

    // --- 输入同步（双拍 + 边沿）---------------------------------------------
    logic clk_s1, clk_s2, dat_s1, dat_s2; // CLK/DAT 双拍同步器输出
    logic clk_prev;                        // 上一拍同步后的 CLK，用于下降沿检测

    // 双拍同步 PS/2 时钟与数据，降低亚稳
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            clk_s1 <= 1'b1;
            clk_s2 <= 1'b1;
            dat_s1 <= 1'b1;
            dat_s2 <= 1'b1;
        end else begin
            clk_s1 <= i_ps2_clk_in;
            clk_s2 <= clk_s1;
            dat_s1 <= i_ps2_dat_in;
            dat_s2 <= dat_s1;
        end
    end

    // 延迟一拍同步 CLK，供边沿检测
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            clk_prev <= 1'b1;
        else
            clk_prev <= clk_s2;
    end

    // PS/2 时钟下降沿（同步域内）
    logic ps2_clk_falling;

    // 组合：检测同步后 CLK 的 1→0
    always_comb begin
        ps2_clk_falling = clk_prev & ~clk_s2;
    end

    // --- 主状态机 -----------------------------------------------------------
    typedef enum logic [ 3: 0] {
        S_IDLE,             // 空闲：可发或监听设备起始位
        S_TX_INHIBIT_CLK,   // 拉低 CLK 禁止设备发送
        S_TX_ASSERT_REQ,    // 拉低 DATA 请求发送，等 CLK 释放变高
        S_TX_SHIFT,         // 在设备 CLK 边沿移位输出 11 位帧
        S_TX_WAIT_ACK,      // 等待设备在第 12 拍拉低 DATA（ACK）
        S_TX_RELEASE_BUS,   // 释放总线，等 CLK/DAT 回到空闲
        S_RX_SAMPLE         // 采样设备到主机的 11 位帧
    } state_t;

    // PS/2 主机收发状态
    state_t state;
    logic [15: 0] cnt_inhibit;   // 抑制 CLK 持续时间计数
    logic [ 3: 0]  bit_index;    // 位序号（发/收）
    logic [10: 0] shift_tx;      // 发送移位寄存（起停奇偶）
    logic [10: 0] shift_rx;      // 接收移位寄存
    logic [31: 0] cnt_ack_timeout; // ACK 等待超时递减计数

    assign o_tx_busy = (state != S_IDLE);

    // 主 FSM：主机发送与设备接收帧处理
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state           <= S_IDLE;
            cnt_inhibit     <= '0;
            bit_index       <= '0;
            shift_tx        <= '0;
            shift_rx        <= '0;
            cnt_ack_timeout <= '0;
            o_ps2_clk_oe    <= 1'b0;
            o_ps2_clk_out   <= 1'b1;
            o_ps2_dat_oe    <= 1'b0;
            o_ps2_dat_out   <= 1'b1;
            o_rx_strobe     <= 1'b0;
            o_rx_byte       <= '0;
            o_rx_err        <= 1'b0;
            o_tx_done       <= 1'b0;
            o_tx_err        <= 1'b0;
        end else begin
            o_rx_strobe <= 1'b0;
            o_tx_done   <= 1'b0;
            o_tx_err    <= 1'b0;
            o_rx_err    <= 1'b0;

            unique case (state)
                // 空闲：可发起发送，或检测设备起始位（CLK↓ 且 DATA=0）
                S_IDLE: begin
                    o_ps2_clk_oe  <= 1'b0;
                    o_ps2_clk_out <= 1'b1;
                    o_ps2_dat_oe  <= 1'b0;
                    o_ps2_dat_out <= 1'b1;
                    cnt_inhibit     <= '0;
                    bit_index       <= '0;
                    cnt_ack_timeout <= CYCLES_ACK_TIMEOUT_MS2[31: 0];
                    shift_rx        <= '0;

                    if (i_tx_req) begin
                        state    <= S_TX_INHIBIT_CLK;
                        shift_tx <= { 1'b1, ~(^i_tx_byte), i_tx_byte, 1'b0 };
                    end else if (ps2_clk_falling && !dat_s2) begin
                        state     <= S_RX_SAMPLE;
                        bit_index <= '0;
                    end
                end

                // 拉低 CLK ≥100µs，禁止设备发送
                S_TX_INHIBIT_CLK: begin
                    o_ps2_clk_oe  <= 1'b1;
                    o_ps2_clk_out <= 1'b0;
                    o_ps2_dat_oe  <= 1'b0;
                    o_ps2_dat_out <= 1'b1;
                    if (cnt_inhibit < CYCLES_INHIBIT_150US[15: 0])
                        cnt_inhibit <= cnt_inhibit + 16'd1;
                    else
                        state <= S_TX_ASSERT_REQ;
                end

                // 拉低 DATA，释放 CLK，等待 CLK 被上拉变高
                S_TX_ASSERT_REQ: begin
                    o_ps2_clk_oe  <= 1'b0;
                    o_ps2_clk_out <= 1'b1;
                    o_ps2_dat_oe  <= 1'b1;
                    o_ps2_dat_out <= 1'b0;
                    bit_index <= '0;
                    if (clk_s2)
                        state <= S_TX_SHIFT;
                end

                // 在设备产生的每个 CLK↓ 上移位输出
                S_TX_SHIFT: begin
                    o_ps2_dat_oe  <= 1'b1;
                    o_ps2_dat_out <= shift_tx[bit_index];
                    if (ps2_clk_falling) begin
                        if (bit_index < 4'd10)
                            bit_index <= bit_index + 4'd1;
                        else begin
                            o_ps2_dat_oe <= 1'b0;
                            state        <= S_TX_WAIT_ACK;
                            cnt_ack_timeout <= CYCLES_ACK_TIMEOUT_MS2[31: 0];
                        end
                    end
                end

                // 第 12 拍设备应拉低 DATA（ACK）
                S_TX_WAIT_ACK: begin
                    o_ps2_dat_oe <= 1'b0;
                    if (!dat_s2) begin
                        state     <= S_TX_RELEASE_BUS;
                        o_tx_done <= 1'b1;
                    end else if (cnt_ack_timeout != 32'd0)
                        cnt_ack_timeout <= cnt_ack_timeout - 32'd1;
                    else begin
                        state    <= S_IDLE;
                        o_tx_err <= 1'b1;
                    end
                end

                S_TX_RELEASE_BUS: begin
                    o_ps2_dat_oe <= 1'b0;
                    if (clk_s2 && dat_s2)
                        state <= S_IDLE;
                end

                // 接收：前 10 拍存 shift_rx[ 0:  9]，第 11 拍采样停止位并校验
                S_RX_SAMPLE: begin
                    if (ps2_clk_falling) begin
                        if (bit_index < 4'd10) begin
                            shift_rx[bit_index] <= dat_s2;
                            bit_index           <= bit_index + 4'd1;
                        end else if (bit_index == 4'd10) begin
                            if (shift_rx[0] == 1'b0 && dat_s2 == 1'b1
                                && (^{ shift_rx[ 9:  1] })) begin
                                o_rx_byte   <= shift_rx[ 8:  1];
                                o_rx_strobe <= 1'b1;
                            end else
                                o_rx_err <= 1'b1;
                            state     <= S_IDLE;
                            bit_index <= '0;
                        end
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
