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
//  File        : ide_controller.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ide_controller module
// ============================================================================

module ide_controller #(
    parameter int P_SECTOR_BYTES   = 512,
    parameter int P_SECTOR_COUNT   = 2048,
    parameter bit P_USE_SDIO_DISK  = 1'b0
) (
    // =========================
    // ISA-style interface
    // =========================
    input  logic         i_cs_n,
    input  logic         i_rd_n,
    input  logic         i_wr_n,
    input  logic [15: 0] i_addr,
    input  logic [ 7: 0] i_wdata,
    output logic [ 7: 0] o_rdata,

    // =========================
    // SDIO PHY interface
    // =========================
    output logic         o_sdio_clk,
    output logic         o_sdio_cmd_out,
    output logic         o_sdio_cmd_oe,
    input  logic         i_sdio_cmd_in,
    output logic [ 3: 0] o_sdio_dat_out,
    output logic         o_sdio_dat_oe,
    input  logic [ 3: 0] i_sdio_dat_in,

    // =========================
    // clock and reset
    // =========================
    input  logic         clk,
    input  logic         rst_n
);

    // ============================================================
    // ATA PIO read transaction state machine
    // ============================================================
    typedef enum logic [ 2: 0] {
        ST_IDLE,
        ST_WAIT_SECTOR,
        ST_DRQ,
        ST_WRITE_DRQ
    } ide_state_t;

    ide_state_t state;

    // ============================================================
    // ATA register mirrors
    // ============================================================
    logic [ 7: 0] sector_cnt;
    logic [ 7: 0] lba_lo, lba_mid, lba_hi;
    logic [ 7: 0] drv_head;
    logic [ 7: 0] status_r;

    // ============================================================
    // data path signals
    // ============================================================
    logic [ 8: 0] buf_ptr;
    logic [31: 0] mem_off;
    logic [31: 0] disk_waddr;
    logic [ 7: 0] disk_wdata;
    logic         disk_we;
    logic         wr_data_d;
    logic [ 7: 0] sectors_left;

    // ============================================================
    // disk backend interface
    // ============================================================
    logic [31: 0] disk_raddr;
    logic [ 7: 0] disk_rdata;
    logic         disk_sector_ready;
    logic         disk_sector_req;

    // ============================================================
    // localparams and address calculation
    // ============================================================
    localparam logic [ 7: 0] LP_ST_RDY = 8'h40;
    localparam logic [ 7: 0] LP_ST_DRQ  = 8'h08;
    localparam logic [ 7: 0] LP_ST_BSY  = 8'h80;

    localparam int LP_DISK_BYTES = P_SECTOR_BYTES * P_SECTOR_COUNT;

    logic         async_on;
    logic [31: 0] mem_bytes;
    logic [31: 0] byte_addr;

    assign async_on = P_USE_SDIO_DISK;
    assign mem_bytes = P_SECTOR_BYTES * P_SECTOR_COUNT;
    assign byte_addr = mem_off * 32'(P_SECTOR_BYTES) + { 23'h0, buf_ptr };
    assign disk_raddr = byte_addr;
    assign disk_waddr = byte_addr;
    assign disk_we    = wr && (i_addr == 16'h01F0) && (state == ST_WRITE_DRQ);
    assign disk_wdata = i_wdata;
    assign disk_sector_req = async_on && (state == ST_WAIT_SECTOR);

    logic wr;
    logic rd;

    assign wr = !i_cs_n && !i_wr_n;
    assign rd = !i_cs_n && !i_rd_n;

    // ============================================================
    // disk backend: BRAM image or SDIO sector buffer
    // ============================================================
    sdcard_controller #(
        .P_BYTE_DEPTH    ( LP_DISK_BYTES ),
        .P_USE_SDIO_DISK ( P_USE_SDIO_DISK )
    ) u_disk (
        .i_disk_raddr         ( disk_raddr ),
        .o_disk_rdata         ( disk_rdata ),
        .i_disk_waddr         ( disk_waddr ),
        .i_disk_wdata         ( disk_wdata ),
        .i_disk_we            ( disk_we ),
        .i_disk_sector_req    ( disk_sector_req ),
        .o_disk_sector_ready  ( disk_sector_ready ),
        .o_sdcard_controller_phy_clk     ( o_sdio_clk ),
        .o_sdcard_controller_phy_cmd_out   ( o_sdio_cmd_out ),
        .o_sdcard_controller_phy_cmd_oe    ( o_sdio_cmd_oe ),
        .i_sdcard_controller_phy_cmd_in    ( i_sdio_cmd_in ),
        .o_sdcard_controller_phy_dat_out   ( o_sdio_dat_out ),
        .o_sdcard_controller_phy_dat_oe    ( o_sdio_dat_oe ),
        .i_sdcard_controller_phy_dat_in    ( i_sdio_dat_in ),
        .clk                ( clk ),
        .rst_n              ( rst_n )
    );

    // 寄存器与 ATA 状态：写口更新 LBA/命令；读数据口时推进缓冲指针；SDIO 等待扇区就绪
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state      <= ST_IDLE;
            sector_cnt <= 8'h01;
            lba_lo     <= '0;
            lba_mid    <= '0;
            lba_hi     <= '0;
            drv_head   <= 8'hE0;
            status_r   <= LP_ST_RDY;
            buf_ptr    <= '0;
            mem_off    <= '0;
            rd_data_d  <= 1'b0;
            wr_data_d  <= 1'b0;
            sectors_left <= 8'h0;
        end else begin
            if (async_on && (state == ST_WAIT_SECTOR) && disk_sector_ready) begin
                state    <= ST_DRQ;
                buf_ptr  <= '0;
                status_r <= LP_ST_DRQ | LP_ST_RDY;
            end else if (wr) begin
                unique case (i_addr)
                    16'h01F2: sector_cnt <= i_wdata;
                    16'h01F3: lba_lo  <= i_wdata;
                    16'h01F4: lba_mid <= i_wdata;
                    16'h01F5: lba_hi  <= i_wdata;
                    16'h01F6: drv_head <= i_wdata;
                    16'h01F7: begin
                        if (i_wdata == 8'h20) begin
                            mem_off      <= {8'b0, lba_hi, lba_mid, lba_lo};
                            buf_ptr      <= '0;
                            sectors_left <= sector_cnt;
                            if (async_on) begin
                                state    <= ST_WAIT_SECTOR;
                                status_r <= LP_ST_BSY;
                            end else begin
                                state    <= ST_DRQ;
                                status_r <= LP_ST_DRQ | LP_ST_RDY;
                            end
                        end else if (i_wdata == 8'h30) begin
                            mem_off      <= {8'b0, lba_hi, lba_mid, lba_lo};
                            buf_ptr      <= '0;
                            sectors_left <= sector_cnt;
                            state        <= ST_WRITE_DRQ;
                            status_r     <= LP_ST_DRQ | LP_ST_RDY;
                        end
                    end
                    16'h03F6: ;
                    default: ;
                endcase
            end

            if (rd_data_d && !(rd && (i_addr == 16'h01F0) && (state == ST_DRQ))) begin
                if (buf_ptr == (9'(P_SECTOR_BYTES) - 9'd1)) begin
                    if (sectors_left <= 8'd1) begin
                        state    <= ST_IDLE;
                        status_r <= LP_ST_RDY;
                        buf_ptr  <= '0;
                    end else begin
                        sectors_left <= sectors_left - 8'd1;
                        mem_off      <= mem_off + 32'd1;
                        buf_ptr      <= '0;
                        if (async_on) begin
                            state    <= ST_WAIT_SECTOR;
                            status_r <= LP_ST_BSY;
                        end else begin
                            state    <= ST_DRQ;
                            status_r <= LP_ST_DRQ | LP_ST_RDY;
                        end
                    end
                end else
                    buf_ptr <= buf_ptr + 9'h1;
            end

            if (wr_data_d && !(wr && (i_addr == 16'h01F0) && (state == ST_WRITE_DRQ))) begin
                if (buf_ptr == (9'(P_SECTOR_BYTES) - 9'd1)) begin
                    if (sectors_left <= 8'd1) begin
                        state    <= ST_IDLE;
                        status_r <= LP_ST_RDY;
                        buf_ptr  <= '0;
                    end else begin
                        sectors_left <= sectors_left - 8'd1;
                        mem_off      <= mem_off + 32'd1;
                        buf_ptr      <= '0;
                        state        <= ST_WRITE_DRQ;
                        status_r     <= LP_ST_DRQ | LP_ST_RDY;
                    end
                end else
                    buf_ptr <= buf_ptr + 9'h1;
            end

            rd_data_d <= (rd && (i_addr == 16'h01F0) && (state == ST_DRQ));
            wr_data_d <= (wr && (i_addr == 16'h01F0) && (state == ST_WRITE_DRQ));
        end
    end

    // 读路径组合：默认 FF；译码各寄存器口与数据口
    always_comb begin
        o_rdata = 8'hFF;
        if (rd) begin
            unique case (i_addr)
                16'h01F0: begin
                    if (state == ST_DRQ) begin
                        if (byte_addr < mem_bytes)
                            o_rdata = disk_rdata;
                        else
                            o_rdata = 8'h00;
                    end else if (state == ST_WRITE_DRQ) begin
                        o_rdata = 8'h00;
                    end else
                        o_rdata = 8'h00;
                end
                16'h01F1: o_rdata = 8'h00; // 错误（当前模型恒 0）
                16'h01F2: o_rdata = sector_cnt;
                16'h01F3: o_rdata = lba_lo;
                16'h01F4: o_rdata = lba_mid;
                16'h01F5: o_rdata = lba_hi;
                16'h01F6: o_rdata = drv_head;
                16'h01F7: o_rdata = status_r; // 主状态
                16'h03F6: o_rdata = status_r; // 辅助状态
                default: o_rdata = 8'hFF; // 未实现口
            endcase
        end
    end

endmodule
