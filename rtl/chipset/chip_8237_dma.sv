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
//  File        : chip_8237_dma.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : chip_8237_dma module
// ============================================================================

// ============================================================================
// Intel 8237 DMA register model + CH2 bus-master transfer engine (disk/floppy)
//
// Host-visible windows:
//   0x00-0x0F : primary 8237 register set
//   0x80-0x8F : DMA page register latch window
//   0xC0-0xDF : 16-bit DMA window stub (AT compatibility placeholder)
//
// Implemented semantics in this model:
//   - CH0-CH3 address/count register access through first/last byte flip-flop
//   - command, request, mask, mode register write behavior
//   - clear first/last flip-flop, master clear, clear mask, write-all-mask
//   - status register read returns {request[3: 0], tc[3: 0]} and clears tc on read
//   - CH2 single-byte transfer FSM (DMA_IDLE/READ/WRITE) with page:addr → mem/IO
//     (IDE data port 0x01F0); TC and request clear on final count
//
// Not implemented in this phase:
//   - full DREQ/DACK/HRQ/HLDA external handshake pins
//   - CH0/CH1/CH3 hardware request paths (software request bit only for CH2)
// ============================================================================

module chip_8237_dma (
    // =========================
    // CPU bus interface
    // =========================
    input  logic         i_cs_n,
    input  logic         i_rd_n,
    input  logic         i_wr_n,
    input  logic [15: 0] i_addr,
    input  logic [ 7: 0] i_d,
    output logic [ 7: 0] o_d,

    // =========================
    // Channel 2 bus-master (disk/floppy 8-bit)
    // =========================
    output logic         o_master_valid,
    input  logic         i_master_ready,
    output logic         o_master_we,
    output logic         o_master_io,
    output logic [31: 0] o_master_addr,
    output logic [ 7: 0] o_master_wdata,
    input  logic [ 7: 0] i_master_rdata,

    // =========================
    // clock and reset
    // =========================
    input  logic         clk,
    input  logic         rst_n
);

    localparam logic [ 3: 0] LP_REG_COMMAND   = 4'h8;
    localparam logic [ 3: 0] LP_REG_REQUEST   = 4'h9;
    localparam logic [ 3: 0] LP_REG_MASK      = 4'hA;
    localparam logic [ 3: 0] LP_REG_MODE      = 4'hB;
    localparam logic [ 3: 0] LP_REG_CLEAR_FF  = 4'hC;
    localparam logic [ 3: 0] LP_REG_MCLR      = 4'hD;
    localparam logic [ 3: 0] LP_REG_CLR_MASK  = 4'hE;
    localparam logic [ 3: 0] LP_REG_ALL_MASK  = 4'hF;
    localparam logic [15: 0] LP_IDE_DATA_PORT = 16'h01F0;
    localparam int LP_CH_DISK      = 2;
    localparam int LP_CH2_PAGE_IDX = 0;

    typedef enum logic [ 1: 0] {
        DMA_IDLE,
        DMA_READ,
        DMA_WRITE
    } dma_state_t;

    dma_state_t dma_state;
    logic         dma_active;
    logic         dma_mem_to_io;
    logic [ 7: 0] dma_hold_byte;
    logic         dma_set_tc;
    logic         dma_clear_req;
    logic         dma_dec_count;
    logic         dma_inc_addr;

    // ============================================================
    // channel registers
    // ============================================================
    logic [15: 0] ch_curr_addr  [ 0: 3];
    logic [15: 0] ch_curr_count [ 0: 3];

    // ============================================================
    // control registers
    // ============================================================
    logic [ 7: 0] reg_temp;
    logic [ 7: 0] reg_mode_last;
    logic [ 3: 0] reg_request;
    logic [ 3: 0] reg_mask;
    logic [ 3: 0] reg_tc;
    logic         first_last_ff;

    // ============================================================
    // page registers and DMA16 stub
    // ============================================================
    logic [ 7: 0] page_reg   [ 0: 15];
    logic [ 7: 0] dma16_stub [ 0: 31];

    // ============================================================
    // address decode and control signals
    // ============================================================
    logic         hit_lo;
    logic         hit_page;
    logic         hit_hi;
    logic         wr;
    logic         rd;
    logic [ 3: 0] lo_idx;
    logic [ 1: 0] ch_sel;
    logic         is_count_reg;
    logic [ 3: 0] page_idx;
    logic [ 4: 0] hi_idx;
    logic         rd_status;
    logic         wr_addr_count;
    logic         wr_master_clear;
    logic         wr_clear_ff;

    // ============================================================
    // address window and CS/RD/WR decode
    // ============================================================
    always_comb begin : comb_address_decode
        hit_lo          = (i_addr <= 16'h000F);
        hit_page        = (i_addr >= 16'h0080) && (i_addr <= 16'h008F);
        hit_hi          = (i_addr >= 16'h00C0) && (i_addr <= 16'h00DF);
        wr              = !i_cs_n && !i_wr_n;
        rd              = !i_cs_n && !i_rd_n;
        lo_idx          = i_addr[ 3: 0];
        ch_sel          = i_addr[ 2: 1];
        is_count_reg    = i_addr[0];
        page_idx        = i_addr[ 3: 0];
        hi_idx          = i_addr[ 4: 0];
        rd_status       = rd && hit_lo && (lo_idx == LP_REG_COMMAND);
        wr_addr_count   = wr && hit_lo && (lo_idx <= 4'h7);
        wr_master_clear = wr && hit_lo && (lo_idx == LP_REG_MCLR);
        wr_clear_ff     = wr && hit_lo && (lo_idx == LP_REG_CLEAR_FF);
    end

    // 寄存器与通道数组：写路径、主清除、先/后字节翻转。
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            for (int i = 0; i < 4; i++) begin
                ch_curr_addr[i]  <= 16'h0000;
                ch_curr_count[i] <= 16'h0000;
            end
            reg_temp      <= 8'h00;
            reg_mode_last <= 8'h00;
            reg_request   <= 4'h0;
            reg_mask      <= 4'hF;
            reg_tc        <= 4'h0;
            first_last_ff <= 1'b0;
            for (int j = 0; j < 16; j++)
                page_reg[j] <= 8'h00;
            for (int k = 0; k < 32; k++)
                dma16_stub[k] <= 8'h00;
        end else begin
            if (wr_master_clear) begin
                for (int i = 0; i < 4; i++) begin
                    ch_curr_addr[i]  <= 16'h0000;
                    ch_curr_count[i] <= 16'h0000;
                end
                reg_temp      <= 8'h00;
                reg_mode_last <= 8'h00;
                reg_request   <= 4'h0;
                reg_mask      <= 4'hF;
                reg_tc        <= 4'h0;
                first_last_ff <= 1'b0;
            end else begin
                if (wr) begin
                    if (wr_addr_count) begin
                        if (!is_count_reg) begin
                            if (!first_last_ff) begin
                                ch_curr_addr[ch_sel][ 7: 0] <= i_d;
                            end else begin
                                ch_curr_addr[ch_sel][15: 8] <= i_d;
                            end
                        end else begin
                            if (!first_last_ff) begin
                                ch_curr_count[ch_sel][ 7: 0] <= i_d;
                            end else begin
                                ch_curr_count[ch_sel][15: 8] <= i_d;
                            end
                        end
                        first_last_ff <= ~first_last_ff;
                    end else if (hit_lo) begin
                        unique case (lo_idx)
                            LP_REG_REQUEST: begin
                                reg_request[i_d[ 1: 0]] <= i_d[2];
                            end
                            LP_REG_MASK: begin
                                reg_mask[i_d[ 1: 0]] <= i_d[2];
                            end
                            LP_REG_MODE: begin
                                reg_mode_last <= i_d;
                            end
                            LP_REG_CLEAR_FF: begin
                                first_last_ff <= 1'b0;
                            end
                            LP_REG_CLR_MASK: begin
                                reg_mask <= 4'h0;
                            end
                            LP_REG_ALL_MASK: begin
                                reg_mask <= i_d[ 3: 0];
                            end
                            default: ;
                        endcase
                    end else if (hit_page) begin
                        page_reg[page_idx] <= i_d;
                    end else if (hit_hi) begin
                        dma16_stub[hi_idx] <= i_d;
                    end
                end

                if (rd && hit_lo && (lo_idx <= 4'h7)) begin
                    first_last_ff <= ~first_last_ff;
                end

                if (rd_status) begin
                    reg_tc <= 4'h0;
                end

                if (wr_clear_ff) begin
                    first_last_ff <= 1'b0;
                end

                if (dma_set_tc) begin
                    reg_tc[LP_CH_DISK] <= 1'b1;
                end
                if (dma_clear_req) begin
                    reg_request[LP_CH_DISK] <= 1'b0;
                end
                if (dma_dec_count) begin
                    ch_curr_count[LP_CH_DISK] <= ch_curr_count[LP_CH_DISK] - 16'h0001;
                end
                if (dma_inc_addr) begin
                    ch_curr_addr[LP_CH_DISK] <= ch_curr_addr[LP_CH_DISK] + 16'h0001;
                end
            end
        end
    end

    assign dma_mem_to_io = reg_mode_last[5];
    assign dma_active    = reg_request[LP_CH_DISK] & ~reg_mask[LP_CH_DISK] &
                           (ch_curr_count[LP_CH_DISK] != 16'h0);

    always_ff @(posedge clk or negedge rst_n) begin : ff_dma_engine
        if (~rst_n) begin
            dma_state     <= DMA_IDLE;
            dma_hold_byte <= 8'h0;
        end else if (wr_master_clear) begin
            dma_state <= DMA_IDLE;
        end else begin
            case (dma_state)
                DMA_IDLE: begin
                    if (dma_active) begin
                        dma_state <= DMA_READ;
                    end
                end
                DMA_READ: begin
                    if (i_master_ready) begin
                        dma_hold_byte <= i_master_rdata;
                        dma_state     <= DMA_WRITE;
                    end
                end
                DMA_WRITE: begin
                    if (i_master_ready) begin
                        if (ch_curr_count[LP_CH_DISK] <= 16'h0001) begin
                            dma_state <= DMA_IDLE;
                        end else begin
                            dma_state <= DMA_READ;
                        end
                    end
                end
                default: dma_state <= DMA_IDLE;
            endcase
        end
    end

    assign dma_set_tc    = (dma_state == DMA_WRITE) & i_master_ready &
                           (ch_curr_count[LP_CH_DISK] <= 16'h0001);
    assign dma_clear_req = dma_set_tc;
    assign dma_dec_count = (dma_state == DMA_WRITE) & i_master_ready &
                            (ch_curr_count[LP_CH_DISK] > 16'h0001);
    assign dma_inc_addr  = dma_dec_count;

    logic [31: 0] dma_mem_addr;

    assign dma_mem_addr = {page_reg[LP_CH2_PAGE_IDX], ch_curr_addr[LP_CH_DISK], 8'h00};

    always_comb begin
        o_master_valid = 1'b0;
        o_master_we    = 1'b0;
        o_master_io    = 1'b0;
        o_master_addr  = 32'h0;
        o_master_wdata = 8'h0;

        if (dma_state == DMA_READ) begin
            o_master_valid = 1'b1;
            o_master_we    = 1'b0;
            if (dma_mem_to_io) begin
                o_master_io   = 1'b0;
                o_master_addr = dma_mem_addr;
            end else begin
                o_master_io   = 1'b1;
                o_master_addr = {16'h0, LP_IDE_DATA_PORT};
            end
        end else if (dma_state == DMA_WRITE) begin
            o_master_valid = 1'b1;
            o_master_we    = 1'b1;
            o_master_wdata = dma_hold_byte;
            if (dma_mem_to_io) begin
                o_master_io   = 1'b1;
                o_master_addr = {16'h0, LP_IDE_DATA_PORT};
            end else begin
                o_master_io   = 1'b0;
                o_master_addr = dma_mem_addr;
            end
        end
    end

    // 读：地址/计数字节、状态/模式/屏蔽、页寄存器与 16 位窗口占位。
    always_comb begin
        o_d = 8'hFF;
        if (rd) begin
            if (hit_lo) begin
                if (lo_idx <= 4'h7) begin
                    if (!is_count_reg)
                        o_d = first_last_ff ? ch_curr_addr[ch_sel][15: 8] : ch_curr_addr[ch_sel][ 7: 0];
                    else
                        o_d = first_last_ff ? ch_curr_count[ch_sel][15: 8] : ch_curr_count[ch_sel][ 7: 0];
                end else begin
                    unique case (lo_idx)
                        LP_REG_COMMAND:  o_d = { reg_request, reg_tc };
                        LP_REG_REQUEST:  o_d = reg_temp;
                        LP_REG_MASK:     o_d = { 4'h0, reg_mask };
                        LP_REG_MODE:     o_d = reg_mode_last;
                        LP_REG_ALL_MASK: o_d = { 4'h0, reg_mask };
                        default:         o_d = 8'hFF;
                    endcase
                end
            end else if (hit_page) begin
                o_d = page_reg[page_idx];
            end else if (hit_hi) begin
                o_d = dma16_stub[hi_idx];
            end
        end
    end

endmodule
