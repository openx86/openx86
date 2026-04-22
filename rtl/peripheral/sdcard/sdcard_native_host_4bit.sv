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
//  File        : sdcard_native_host_4bit.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : sdcard_native_host_4bit module
// ============================================================================

module sdcard_native_host_4bit (
    input  logic         i_start, // 启动一次 CMD17 单块读（脉冲/单拍均可，经沿检测）
    input  logic [31: 0] i_lba, // 逻辑块地址（512B 块号）
    output logic         o_busy, // 忙：传输进行中
    output logic         o_done, // 完成脉冲：整块读入 payload RAM
    output logic         o_err, // 错误脉冲（本最小实现较少触发）
    output logic         o_payload_we, // 写入扇区缓冲写使能
    output logic [ 8: 0] o_payload_addr, // 扇区缓冲字节地址 0..511
    output logic [ 7: 0] o_payload_data, // 扇区缓冲写入数据
    output logic         o_sdcard_native_host_4bit_phy_clk, // SD 时钟输出（直连本模块 clk）
    output logic         o_sdcard_native_host_4bit_phy_cmd_out, // CMD 线驱动数据（配合 oe）
    output logic         o_sdcard_native_host_4bit_phy_cmd_oe, // CMD 输出使能（开漏主机模型）
    input  logic         i_sdcard_native_host_4bit_phy_cmd_in, // CMD 总线回读
    output logic [ 3: 0] o_sdcard_native_host_4bit_phy_dat_out, // DAT[3: 0] 驱动
    output logic         o_sdcard_native_host_4bit_phy_dat_oe, // DAT 输出使能
    input  logic [ 3: 0] i_sdcard_native_host_4bit_phy_dat_in, // DAT 总线回读
    input  logic         clk, // 主机逻辑时钟
    input  logic         rst_n // 异步低有效复位
);

    typedef enum logic [ 3: 0] {
        ST_IDLE,          // 空闲等待启动
        ST_LATCH_LBA,     // 锁存 LBA 并准备命令帧
        ST_SEND_CMD,      // 串行移出 48 位命令帧
        ST_GAP_HOST,      // 释放 CMD 总线，进入响应前间隔
        ST_PRE_RESP,      // 固定节拍等待卡侧开始驱动响应
        ST_RECV_RESP,     // 移位采样 R1 类 48 位响应（本模型简化）
        ST_WAIT_TOKEN_E, // 等待 DAT 上数据起始令牌 0xE
        ST_READ_LO,       // 读半字节低半（4bit）
        ST_READ_HI,      // 拼字节并写入 payload
        ST_FINISH,        // 置完成并回空闲
        ST_ERR            // 错误出口（预留）
    } sd_host_state_t;

    // SDIO 主机事务状态
    sd_host_state_t state;

    logic [ 5: 0]  send_bit_ix;   // 命令位移位索引 0..47
    logic [ 5: 0]  resp_bit_ix;   // 响应位移位索引
    logic [ 2: 0]  gap_cnt;       // 主机释放总线后的间隔计数
    logic [ 8: 0]  byte_ix;       // 扇区内字节序号
    logic [ 3: 0]  lo_nib;        // 当前字节低 4 位（先采 DAT 低半）
    logic [31: 0]  latched_lba;   // 已锁存的 LBA
    logic [47: 0]  cmd_frame;     // 48 位命令帧（组合拼装）
    logic          start_d;       // i_start 打一拍，用于边沿检测
    logic          start_pulse;   // 单周期启动脉冲

    // 组合：检测 start 上升沿并拼装 CMD17 帧（CRC 域为占位）
    always_comb begin
        start_pulse = i_start & ~start_d;
        cmd_frame   = { 1'b0, 1'b1, 6'd17, latched_lba, 7'h7F, 1'b1 };
    end

    // 对 i_start 打一拍，供组合逻辑产生单周期脉冲
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            start_d <= 1'b0;
        else
            start_d <= i_start;
    end


    assign o_sdcard_native_host_4bit_phy_clk = clk;

    // 主状态机：CMD17 单块读 → payload 顺序写入
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state      <= ST_IDLE;
            send_bit_ix <= '0;
            resp_bit_ix <= '0;
            gap_cnt    <= '0;
            byte_ix    <= '0;
            lo_nib     <= '0;
            latched_lba <= '0;
            o_busy     <= 1'b0;
            o_done     <= 1'b0;
            o_err      <= 1'b0;
            o_payload_we   <= 1'b0;
            o_payload_addr <= '0;
            o_payload_data <= '0;
            o_sdcard_native_host_4bit_phy_cmd_out <= 1'b1;
            o_sdcard_native_host_4bit_phy_cmd_oe  <= 1'b0;
            o_sdcard_native_host_4bit_phy_dat_out <= 4'hF;
            o_sdcard_native_host_4bit_phy_dat_oe  <= 1'b0;
        end else begin
            o_done   <= 1'b0;
            o_err    <= 1'b0;
            o_payload_we <= 1'b0;

            unique case (state)
                ST_IDLE: begin // 等待 start_pulse
                    o_busy <= 1'b0;
                    o_sdcard_native_host_4bit_phy_cmd_oe  <= 1'b0;
                    o_sdcard_native_host_4bit_phy_cmd_out <= 1'b1;
                    o_sdcard_native_host_4bit_phy_dat_oe  <= 1'b0;
                    o_sdcard_native_host_4bit_phy_dat_out <= 4'hF;
                    if (start_pulse) begin
                        state         <= ST_LATCH_LBA;
                        o_busy        <= 1'b1;
                    end
                end

                ST_LATCH_LBA: begin // 锁存块地址并开 CMD 输出
                    latched_lba <= i_lba;
                    send_bit_ix <= '0;
                    state       <= ST_SEND_CMD;
                    o_sdcard_native_host_4bit_phy_cmd_oe <= 1'b1;
                end

                ST_SEND_CMD: begin // MSB 先发：逐位推 cmd_frame
                    o_sdcard_native_host_4bit_phy_cmd_out <= cmd_frame[47 - send_bit_ix];
                    o_sdcard_native_host_4bit_phy_cmd_oe  <= 1'b1;
                    if (send_bit_ix == 6'd47)
                        state <= ST_GAP_HOST;
                    else
                        send_bit_ix <= send_bit_ix + 6'd1;
                end

                ST_GAP_HOST: begin // 主机高阻 CMD，给卡响应让出总线
                    o_sdcard_native_host_4bit_phy_cmd_oe  <= 1'b0;
                    o_sdcard_native_host_4bit_phy_cmd_out <= 1'b1;
                    gap_cnt    <= '0;
                    resp_bit_ix <= '0;
                    state      <= ST_PRE_RESP;
                end

                ST_PRE_RESP: begin // 固定 8 拍间隔后进入响应采样
                    if (gap_cnt == 3'd7)
                        state <= ST_RECV_RESP;
                    else
                        gap_cnt <= gap_cnt + 3'd1;
                end

                ST_RECV_RESP: begin // 简化：仅推进比特计数（回读未参与译码）
                    if (resp_bit_ix == 6'd47)
                        state <= ST_WAIT_TOKEN_E;
                    else
                        resp_bit_ix <= resp_bit_ix + 6'd1;
                end

                ST_WAIT_TOKEN_E: begin // 等数据令牌 0xE（4bit 总线）
                    if (i_sdcard_native_host_4bit_phy_dat_in == 4'hE) begin
                        state   <= ST_READ_LO;
                        byte_ix <= '0;
                    end
                end

                ST_READ_LO: begin // 先采低半字节
                    lo_nib <= i_sdcard_native_host_4bit_phy_dat_in;
                    state  <= ST_READ_HI;
                end

                ST_READ_HI: begin // 再高半字节拼成 8 位写入缓冲
                    o_payload_we   <= 1'b1;
                    o_payload_addr <= byte_ix;
                    o_payload_data <= { i_sdcard_native_host_4bit_phy_dat_in, lo_nib };
                    if (byte_ix == 9'd511)
                        state <= ST_FINISH;
                    else begin
                        byte_ix <= byte_ix + 9'd1;
                        state   <= ST_READ_LO;
                    end
                end

                ST_FINISH: begin
                    o_done <= 1'b1;
                    o_busy <= 1'b0;
                    state  <= ST_IDLE;
                end

                ST_ERR: begin
                    o_err  <= 1'b1;
                    o_busy <= 1'b0;
                    state  <= ST_IDLE;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule
