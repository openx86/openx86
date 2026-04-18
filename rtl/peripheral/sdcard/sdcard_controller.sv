/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: SD / BRAM disk backend for IDE — byte read + async sector load handshake.
*/
// ============================================================================
// sdcard_controller
// ----------------------------------------------------------------------------
// P_USE_SDIO_DISK=0: async byte read from internal image[].
// P_USE_SDIO_DISK=1: sdcard_native_host_4bit fills sector_buf; sector_ready pulses
//   when load completes; data valid for i_disk_raddr in loaded LBA until next load.
// ============================================================================

module sdcard_controller #(
    parameter int P_BYTE_DEPTH    = 512 * 2048,
    parameter bit P_USE_SDIO_DISK = 1'b0
) (
    input  logic [31: 0] i_disk_raddr,       // 磁盘线性字节读地址
    output logic [ 7: 0] o_disk_rdata,      // 当前地址读出的字节
    input  logic         i_disk_sector_req,   // SDIO 模式：请求确保当前 LBA 扇区已载入缓冲
    output logic         o_disk_sector_ready, // 当前读地址所在扇区已在 sector_buf 就绪（脉冲/保持见逻辑）
    output logic         o_sdcard_controller_phy_clk,     // 下至 PHY/卡的 SD 时钟
    output logic         o_sdcard_controller_phy_cmd_out, // CMD 线驱动数据
    output logic         o_sdcard_controller_phy_cmd_oe,  // CMD 输出使能
    input  logic         i_sdcard_controller_phy_cmd_in,  // CMD 总线回读
    output logic [ 3: 0] o_sdcard_controller_phy_dat_out, // DAT[3:0] 驱动
    output logic         o_sdcard_controller_phy_dat_oe,   // DAT 输出使能
    input  logic [ 3: 0] i_sdcard_controller_phy_dat_in,   // DAT 总线回读
    input  logic         clock,             // 控制器时钟
    input  logic         reset_n            // 异步低有效复位
);

    localparam int LP_AW = $clog2(P_BYTE_DEPTH);

    // BRAM/映像盘体（P_USE_SDIO_DISK=0 时直接字节读）
    logic [ 7: 0] image [0:P_BYTE_DEPTH-1];

    // 上电写魔术数到映像首字节（便于仿真可见）
    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            image[0] <= 8'hA5;
            image[1] <= 8'h5A;
        end
    end

    generate
        if (!P_USE_SDIO_DISK) begin : g_bram_only
            // 纯 BRAM：组合读 image，越界返回 0
            always_comb begin
                if (i_disk_raddr < P_BYTE_DEPTH) // 地址在映像范围内
                    o_disk_rdata = image[i_disk_raddr[LP_AW-1: 0]];
                else
                    o_disk_rdata = 8'h00; // 越界读保护
            end
            assign o_disk_sector_ready = 1'b0;
            assign o_sdcard_controller_phy_clk     = 1'b0;
            assign o_sdcard_controller_phy_cmd_out = 1'b1;
            assign o_sdcard_controller_phy_cmd_oe  = 1'b0;
            assign o_sdcard_controller_phy_dat_out = 4'hF;
            assign o_sdcard_controller_phy_dat_oe  = 1'b0;
        end else begin : g_sdio
            logic [ 8: 0]  sector_buf [0:511]; // 当前扇区 512 字节缓存
            logic          sector_loaded;      // 已有一扇区有效数据
            logic [31: 0]  hold_lba;           // 已载入扇区对应的 LBA
            logic          sd_start;           // 脉冲启动 native host
            logic [31: 0]  sd_lba;             // 传给 host 的块地址
            logic          sd_busy;            // host 忙
            logic          sd_done;          // host 完成一块
            logic          sd_err;           // host 报错
            logic          sd_payload_we;    // host 写扇区缓冲
            logic [ 8: 0]  sd_payload_addr;
            logic [ 7: 0]  sd_payload_data;
            logic          sd_active;        // 已发出 load 且等待完成
            logic          sector_ready_hold; // 与上层 req 握手的 ready 锁存

            // SDIO 路径：调度 CMD17 填 sector_buf，并维护与 IDE 的扇区握手
            always_ff @(posedge clock or negedge reset_n) begin
                if (~reset_n) begin
                    sector_loaded        <= 1'b0;
                    hold_lba             <= '0;
                    sd_start             <= 1'b0;
                    sd_lba               <= '0;
                    sd_active            <= 1'b0;
                    sector_ready_hold    <= 1'b0;
                end else begin
                    sd_start <= 1'b0;

                    if (sd_payload_we)
                        sector_buf[sd_payload_addr] <= sd_payload_data;

                    if (sd_start)
                        sector_loaded <= 1'b0;

                    if (!i_disk_sector_req) // 上层撤请求：清除 ready 锁存
                        sector_ready_hold <= 1'b0;
                    else if (sd_err && sd_active) begin // 传输失败：结束活动态
                        sd_active <= 1'b0;
                    end else if (sd_done && sd_active) begin // 成功：记录 LBA 并置缓冲有效
                        sd_active         <= 1'b0;
                        hold_lba          <= sd_lba;
                        sector_loaded     <= 1'b1;
                        sector_ready_hold <= 1'b1;
                    end else if (i_disk_sector_req && !sd_busy && !sd_active) begin
                        if (sector_loaded && ((i_disk_raddr >> 9) == hold_lba)) // 命中已缓存扇区
                            sector_ready_hold <= 1'b1;
                        else begin // 需换扇区：发起一次 SDIO 读
                            sd_lba    <= i_disk_raddr >> 9;
                            sd_start  <= 1'b1;
                            sd_active <= 1'b1;
                        end
                    end
                end
            end

            // 仅当读地址落在已载入 LBA 的扇区内时返回缓冲字节，否则 0（防陈旧数据）
            always_comb begin
                if (sector_loaded && ((i_disk_raddr >> 9) == hold_lba))
                    o_disk_rdata = sector_buf[i_disk_raddr[8: 0]];
                else
                    o_disk_rdata = 8'h00;
            end

            assign o_disk_sector_ready = sector_ready_hold;

            sdcard_native_host_4bit u_sd_host (
                .i_start        ( sd_start ),
                .i_lba          ( sd_lba ),
                .o_busy         ( sd_busy ),
                .o_done         ( sd_done ),
                .o_err          ( sd_err ),
                .o_payload_we   ( sd_payload_we ),
                .o_payload_addr ( sd_payload_addr ),
                .o_payload_data ( sd_payload_data ),
                .o_sdcard_native_host_4bit_phy_clk     ( o_sdcard_controller_phy_clk ),
                .o_sdcard_native_host_4bit_phy_cmd_out   ( o_sdcard_controller_phy_cmd_out ),
                .o_sdcard_native_host_4bit_phy_cmd_oe    ( o_sdcard_controller_phy_cmd_oe ),
                .i_sdcard_native_host_4bit_phy_cmd_in    ( i_sdcard_controller_phy_cmd_in ),
                .o_sdcard_native_host_4bit_phy_dat_out   ( o_sdcard_controller_phy_dat_out ),
                .o_sdcard_native_host_4bit_phy_dat_oe    ( o_sdcard_controller_phy_dat_oe ),
                .i_sdcard_native_host_4bit_phy_dat_in    ( i_sdcard_controller_phy_dat_in ),
                .clock          ( clock ),
                .reset_n        ( reset_n )
            );
        end
    endgenerate

endmodule
