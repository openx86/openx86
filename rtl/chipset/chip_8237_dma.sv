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
    input  logic         i_cs_n,
    input  logic         i_rd_n,
    input  logic         i_wr_n,
    input  logic [15: 0] i_addr,
    input  logic [ 7: 0] i_d,
    output logic [ 7: 0] o_d,
    input  logic         clock,
    input  logic         reset_n
);

    localparam logic [ 3: 0] LP_REG_COMMAND   = 4'h8;
    localparam logic [ 3: 0] LP_REG_REQUEST   = 4'h9;
    localparam logic [ 3: 0] LP_REG_MASK      = 4'hA;
    localparam logic [ 3: 0] LP_REG_MODE      = 4'hB;
    localparam logic [ 3: 0] LP_REG_CLEAR_FF  = 4'hC;
    localparam logic [ 3: 0] LP_REG_MCLR      = 4'hD;
    localparam logic [ 3: 0] LP_REG_CLR_MASK  = 4'hE;
    localparam logic [ 3: 0] LP_REG_ALL_MASK  = 4'hF;

    logic [15: 0] ch_base_addr  [ 0: 3];
    logic [15: 0] ch_curr_addr  [ 0: 3];
    logic [15: 0] ch_base_count [ 0: 3];
    logic [15: 0] ch_curr_count [ 0: 3];
    logic [ 7: 0] ch_mode       [ 0: 3];

    logic [ 7: 0] reg_command;
    logic [ 7: 0] reg_temp;
    logic [ 7: 0] reg_mode_last;
    logic [ 3: 0] reg_request;
    logic [ 3: 0] reg_mask;
    logic [ 3: 0] reg_tc;
    logic         first_last_ff;

    logic [ 7: 0] page_reg   [ 0: 15];
    logic [ 7: 0] dma16_stub [ 0: 31];

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

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            for (int i = 0; i < 4; i++) begin
                ch_base_addr[i]  <= 16'h0000;
                ch_curr_addr[i]  <= 16'h0000;
                ch_base_count[i] <= 16'h0000;
                ch_curr_count[i] <= 16'h0000;
                ch_mode[i]       <= 8'h00;
            end
            reg_command   <= 8'h00;
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
                    ch_base_addr[i]  <= 16'h0000;
                    ch_curr_addr[i]  <= 16'h0000;
                    ch_base_count[i] <= 16'h0000;
                    ch_curr_count[i] <= 16'h0000;
                    ch_mode[i]       <= 8'h00;
                end
                reg_command   <= 8'h00;
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
                                ch_base_addr[ch_sel][ 7: 0] <= i_d;
                                ch_curr_addr[ch_sel][ 7: 0] <= i_d;
                            end else begin
                                ch_base_addr[ch_sel][15: 8] <= i_d;
                                ch_curr_addr[ch_sel][15: 8] <= i_d;
                            end
                        end else begin
                            if (!first_last_ff) begin
                                ch_base_count[ch_sel][ 7: 0] <= i_d;
                                ch_curr_count[ch_sel][ 7: 0] <= i_d;
                            end else begin
                                ch_base_count[ch_sel][15: 8] <= i_d;
                                ch_curr_count[ch_sel][15: 8] <= i_d;
                            end
                        end
                        first_last_ff <= ~first_last_ff;
                    end else if (hit_lo) begin
                        unique case (lo_idx)
                            LP_REG_COMMAND: begin
                                reg_command <= i_d;
                            end
                            LP_REG_REQUEST: begin
                                reg_request[i_d[ 1: 0]] <= i_d[2];
                            end
                            LP_REG_MASK: begin
                                reg_mask[i_d[ 1: 0]] <= i_d[2];
                            end
                            LP_REG_MODE: begin
                                ch_mode[i_d[ 1: 0]] <= i_d;
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
