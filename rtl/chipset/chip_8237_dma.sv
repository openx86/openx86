/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Intel 8237 DMA register-level model (PC/XT oriented).
*/
// ============================================================================
// Intel 8237 DMA register model (no real DMA bus-master transfer engine)
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
//   - status register read returns {request[3:0], tc[3:0]} and clears tc on read
//
// Not implemented in this phase:
//   - real DMA transfer execution, DREQ/DACK/HRQ/HLDA handshakes
//   - terminal count generation from transfer engine (tc bits stay software model)
// ============================================================================

module chip_8237_dma (
    input  logic         i_cs_n,      // 低有效片选（命中 DMA/页寄存器/16 位窗口之一）
    input  logic         i_rd_n,      // 低有效读
    input  logic         i_wr_n,      // 低有效写
    input  logic [15: 0] i_addr,      // I/O 地址（16 位）
    input  logic [ 7: 0] i_d,         // 写数据
    output logic [ 7: 0] o_d,         // 读数据
    input  logic         clk,       // 系统时钟
    input  logic         rst_n      // 异步低有效复位
);

    localparam logic [ 3: 0] LP_REG_COMMAND   = 4'h8;
    localparam logic [ 3: 0] LP_REG_REQUEST   = 4'h9;
    localparam logic [ 3: 0] LP_REG_MASK      = 4'hA;
    localparam logic [ 3: 0] LP_REG_MODE      = 4'hB;
    localparam logic [ 3: 0] LP_REG_CLEAR_FF  = 4'hC;
    localparam logic [ 3: 0] LP_REG_MCLR      = 4'hD;
    localparam logic [ 3: 0] LP_REG_CLR_MASK  = 4'hE;
    localparam logic [ 3: 0] LP_REG_ALL_MASK  = 4'hF;

    logic [15: 0] ch_curr_addr  [ 0: 3];  // 通道当前地址
    logic [15: 0] ch_curr_count [ 0: 3];  // 通道当前计数

    logic [ 7: 0] reg_temp;        // 占位/保留读
    logic [ 7: 0] reg_mode_last;   // 最近一次写入的模式字节
    logic [ 3: 0] reg_request;     // 软件请求位（每通道）
    logic [ 3: 0] reg_mask;        // 通道屏蔽
    logic [ 3: 0] reg_tc;          // 终端计数位（读状态清）
    logic         first_last_ff;   // 先/后字节触发器

    logic [ 7: 0] page_reg   [ 0: 15];  // 0x80–0x8F 页寄存器
    logic [ 7: 0] dma16_stub [ 0: 31];  // 0xC0–0xDF 占位

    logic         hit_lo;           // 命中 0x00–0x0F
    logic         hit_page;         // 命中页寄存器窗口
    logic         hit_hi;           // 命中 16 位 DMA 占位窗口
    logic         wr;               // 写事务有效
    logic         rd;               // 读事务有效
    logic [ 3: 0] lo_idx;           // 低窗口寄存器索引
    logic [ 1: 0] ch_sel;           // 当前地址对应的通道号
    logic         is_count_reg;     // 1=计数寄存器，0=地址寄存器
    logic [ 3: 0] page_idx;         // 页寄存器索引
    logic [ 4: 0] hi_idx;           // 高位窗口线性索引
    logic         rd_status;        // 读状态寄存器（同时清 TC）
    logic         wr_addr_count;    // 写地址/计数字节
    logic         wr_master_clear;  // 主清除
    logic         wr_clear_ff;      // 清除先/后触发器

    // 地址窗口与片选/读写微操作译码。
    always_comb begin
        hit_lo        = (i_addr <= 16'h000F);
        hit_page      = (i_addr >= 16'h0080) && (i_addr <= 16'h008F);
        hit_hi        = (i_addr >= 16'h00C0) && (i_addr <= 16'h00DF);
        wr            = !i_cs_n && !i_wr_n;
        rd            = !i_cs_n && !i_rd_n;
        lo_idx        = i_addr[ 3: 0];
        ch_sel        = i_addr[ 2: 1];
        is_count_reg  = i_addr[0];
        page_idx      = i_addr[ 3: 0];
        hi_idx        = i_addr[ 4: 0];
        rd_status     = rd && hit_lo && (lo_idx == LP_REG_COMMAND);
        wr_addr_count = wr && hit_lo && (lo_idx <= 4'h7);
        wr_master_clear = wr && hit_lo && (lo_idx == LP_REG_MCLR);
        wr_clear_ff   = wr && hit_lo && (lo_idx == LP_REG_CLEAR_FF);
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
