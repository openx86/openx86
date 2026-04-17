/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements sd_native_host_4bit.
*/
// ============================================================================
// SD/MMC 原生 4-bit 单块读主机（与 sd_mmc_card_model_native 配对仿真）
// sd_clk = clock 二分频；CMD 在下降沿改变、上升沿采样；DAT 上升沿采样 4-bit
// ============================================================================

module sd_native_host_4bit (
    output logic        o_sd_clk,
    output logic        o_phy_cmd_out,
    output logic        o_phy_cmd_oe,
    input  logic        i_phy_cmd_in,
    output logic [ 3:  0]  o_phy_dat_out,
    output logic        o_phy_dat_oe,
    input  logic [ 3:  0]  i_phy_dat_in,
    input  logic        i_start,
    input  logic [31:  0] i_lba,
    output logic        o_busy,
    output logic        o_done,
    output logic        o_err,
    output logic        o_payload_we,
    output logic [ 8:  0]  o_payload_addr,
    output logic [ 7:  0]  o_payload_data,
    input  logic        reset_n,
    input  logic        clock);

    function automatic logic [ 6:  0] crc7_40(input logic [39:  0] d);
        logic [ 6:  0] c;
        c = 7'd0;
        for (int k = 39; k >= 0; k--) begin
            logic x;
            x = d[k] ^ c[6];
            c = {c[ 5:  0], 1'b0};
            if (x)
                c = c ^ 7'h09;
        end
        return c;
    endfunction

    function automatic logic [47:  0] mk_cmd(input logic [ 5:  0] idx, input logic [31:  0] arg);
        logic [39:  0] h;
        logic [ 6:  0] cr;
        h  = {1'b0, 1'b1, idx, arg};
        cr = crc7_40(h);
        return {h, cr, 1'b1};
    endfunction

    typedef enum logic [ 3:  0] {
        H_IDLE,
        H_CMD_TX,
        H_CMD_NCR,
        H_RESP_RX,
        H_GAP_DAT,
        H_DATA_TOKEN,
        H_DATA_BODY,
        H_DATA_CRC,
        H_FINISH
    } hst_t;

    hst_t st;

    logic        sd_clk_r, sd_clk_d;
    logic [ 5:  0]  cmd_bit_cnt;
    logic [47:  0] cmd_word;
    logic [ 3:  0]  ncr_cnt;
    logic [ 5:  0]  resp_bit_cnt;
    logic [47:  0] resp_shift;
    logic [ 3:  0]  dat_gap_cnt;
    logic [ 1:  0]  tok_cnt;
    logic [ 3:  0]  nibble_lo;
    logic        nibble_pair;
    logic [ 8:  0]  byte_wr_addr;
    logic [ 1:  0]  crc_nib;

    wire fall_sd = sd_clk_d & ~sd_clk_r;
    wire rise_sd = ~sd_clk_d & sd_clk_r;

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n)
            sd_clk_r <= 1'b0;
        else
            sd_clk_r <= ~sd_clk_r;
    end

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n)
            sd_clk_d <= 1'b0;
        else
            sd_clk_d <= sd_clk_r;
    end

    assign o_sd_clk = sd_clk_r;

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            st              <= H_IDLE;
            o_busy          <= 1'b0;
            o_done          <= 1'b0;
            o_err           <= 1'b0;
            o_phy_cmd_out   <= 1'b1;
            o_phy_cmd_oe    <= 1'b0;
            o_phy_dat_out   <= 4'hF;
            o_phy_dat_oe    <= 1'b0;
            o_payload_we    <= 1'b0;
            o_payload_addr  <= '0;
            o_payload_data  <= '0;
            cmd_bit_cnt     <= '0;
            cmd_word        <= '0;
            ncr_cnt         <= '0;
            resp_bit_cnt    <= '0;
            resp_shift      <= '0;
            dat_gap_cnt     <= '0;
            tok_cnt         <= '0;
            nibble_lo       <= '0;
            nibble_pair     <= 1'b0;
            byte_wr_addr    <= '0;
            crc_nib         <= '0;
        end else begin
            o_done       <= 1'b0;
            o_payload_we <= 1'b0;

            unique case (st)
                H_IDLE: begin
                    o_err         <= 1'b0;
                    o_phy_cmd_oe  <= 1'b0;
                    o_phy_dat_oe  <= 1'b0;
                    o_phy_dat_out <= 4'hF;
                    if (i_start && !o_busy) begin
                        o_busy      <= 1'b1;
                        cmd_word    <= mk_cmd(6'd17, i_lba);
                        cmd_bit_cnt <= '0;
                        st          <= H_CMD_TX;
                        o_phy_cmd_oe <= 1'b1;
                    end
                end

                H_CMD_TX: begin
                    if (fall_sd) begin
                        o_phy_cmd_out <= cmd_word[47];
                        cmd_word      <= {cmd_word[46:  0], 1'b1};
                        if (cmd_bit_cnt == 6'd47) begin
                            st      <= H_CMD_NCR;
                            ncr_cnt <= '0;
                        end else
                            cmd_bit_cnt <= cmd_bit_cnt + 6'd1;
                    end
                end

                H_CMD_NCR: begin
                    o_phy_cmd_oe <= 1'b0;
                    if (rise_sd) begin
                        if (ncr_cnt == 4'd2) begin
                            st           <= H_RESP_RX;
                            resp_bit_cnt <= '0;
                            resp_shift   <= '0;
                        end else
                            ncr_cnt <= ncr_cnt + 4'd1;
                    end
                end

                H_RESP_RX: begin
                    if (rise_sd) begin
                        resp_shift <= {resp_shift[46:  0], i_phy_cmd_in};
                        if (resp_bit_cnt == 6'd47) begin
                            st          <= H_GAP_DAT;
                            dat_gap_cnt <= '0;
                        end else
                            resp_bit_cnt <= resp_bit_cnt + 6'd1;
                    end
                end

                H_GAP_DAT: begin
                    if (rise_sd) begin
                        if (dat_gap_cnt == 4'd3) begin
                            st      <= H_DATA_TOKEN;
                            tok_cnt <= '0;
                        end else
                            dat_gap_cnt <= dat_gap_cnt + 4'd1;
                    end
                end

                H_DATA_TOKEN: begin
                    if (rise_sd) begin
                        if (tok_cnt == 2'd0) begin
                            if (i_phy_dat_in != 4'hF)
                                o_err <= 1'b1;
                            tok_cnt <= 2'd1;
                        end else begin
                            if (i_phy_dat_in != 4'hE)
                                o_err <= 1'b1;
                            st           <= H_DATA_BODY;
                            nibble_pair  <= 1'b0;
                            byte_wr_addr <= '0;
                        end
                    end
                end

                H_DATA_BODY: begin
                    if (rise_sd) begin
                        if (!nibble_pair) begin
                            nibble_lo   <= i_phy_dat_in;
                            nibble_pair <= 1'b1;
                        end else begin
                            o_payload_we   <= 1'b1;
                            o_payload_addr <= byte_wr_addr;
                            o_payload_data <= {i_phy_dat_in, nibble_lo};
                            nibble_pair    <= 1'b0;
                            if (byte_wr_addr == 9'd511) begin
                                st      <= H_DATA_CRC;
                                crc_nib <= '0;
                            end else
                                byte_wr_addr <= byte_wr_addr + 9'd1;
                        end
                    end
                end

                H_DATA_CRC: begin
                    if (rise_sd) begin
                        if (crc_nib == 2'd3) begin
                            st     <= H_FINISH;
                            o_done <= 1'b1;
                            o_busy <= 1'b0;
                        end else
                            crc_nib <= crc_nib + 2'd1;
                    end
                end

                H_FINISH: begin
                    st <= H_IDLE;
                end

                default: st <= H_IDLE;
            endcase
        end
    end

endmodule
