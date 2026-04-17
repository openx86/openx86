/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements sd_mmc_card_model_native.
*/
// ============================================================================
// SD 卡极简原生模型（仿真）：CMD17 + 4-bit 单块数据（令牌 0xFE + 512B + CRC 占位）
// ============================================================================

module sd_mmc_card_model_native (
    input  logic       i_sd_clk,
    input  logic       i_reset,
    input  logic       i_host_cmd_oe,
    input  logic       i_host_cmd_o,
    input  logic       i_sd_cmd_bus,
    output logic       o_card_cmd_oe,
    output logic       o_card_cmd_o,
    input  logic [3:0] i_host_dat_oe,
    input  logic [3:0] i_host_dat_o,
    output logic       o_card_dat_oe,
    output logic [3:0] o_card_dat_o
);

    logic [47:0] cmd_sr;
    logic [6:0]  cmd_bc;
    logic        host_oe_d;

    typedef enum logic [2:0] {
        C_IDLE,
        C_CMD_IN,
        C_RESP_OUT,
        C_GAP,
        C_TOK_HI,
        C_TOK_LO,
        C_PAYLOAD,
        C_CRC
    } cst_t;

    cst_t cst;

    logic [5:0]  resp_bc;
    logic [47:0] r1_sh;
    logic [3:0]  gap_c;
    logic        pay_low_nibble;
    logic [8:0]  byte_ix;
    logic [2:0]  crc_c;

    logic [7:0] sector [0:511];

    integer si;
    initial begin
        for (si = 0; si < 512; si = si + 1)
            sector[si] = 8'h00;
        sector[0] = 8'hA5;
        sector[1] = 8'h5A;
    end

    always_ff @(posedge i_sd_clk or posedge i_reset) begin
        if (i_reset)
            host_oe_d <= 1'b0;
        else
            host_oe_d <= i_host_cmd_oe;
    end

    wire host_cmd_fall = host_oe_d & ~i_host_cmd_oe;

    always_ff @(posedge i_sd_clk or posedge i_reset) begin
        if (i_reset) begin
            cst            <= C_IDLE;
            cmd_sr         <= '0;
            cmd_bc         <= '0;
            o_card_cmd_oe  <= 1'b0;
            o_card_cmd_o   <= 1'b1;
            o_card_dat_oe  <= 1'b0;
            o_card_dat_o   <= 4'hF;
            resp_bc        <= '0;
            r1_sh          <= '0;
            gap_c          <= '0;
            pay_low_nibble <= 1'b1;
            byte_ix        <= '0;
            crc_c          <= '0;
        end else begin
            unique case (cst)
                C_IDLE: begin
                    o_card_cmd_oe <= 1'b0;
                    o_card_dat_oe <= 1'b0;
                    o_card_dat_o  <= 4'hF;
                    pay_low_nibble <= 1'b1;
                    if (i_host_cmd_oe) begin
                        cst    <= C_CMD_IN;
                        cmd_sr <= '0;
                        cmd_bc <= '0;
                    end
                end

                C_CMD_IN: begin
                    if (i_host_cmd_oe) begin
                        cmd_sr <= {cmd_sr[46:0], i_sd_cmd_bus};
                        cmd_bc <= cmd_bc + 7'd1;
                    end else if (host_cmd_fall) begin
                        // Accept command with a tolerant bit count so minor
                        // host/model phase differences do not block data flow.
                        if (cmd_bc >= 7'd47) begin
                            cst           <= C_RESP_OUT;
                            resp_bc       <= '0;
                            r1_sh         <= 48'h000000000018;
                            o_card_cmd_oe <= 1'b1;
                            o_card_cmd_o  <= 1'b1;
                        end else begin
                            cst    <= C_IDLE;
                            cmd_bc <= '0;
                        end
                    end
                end

                C_RESP_OUT: begin
                    if (resp_bc == 6'd47) begin
                        o_card_cmd_o  <= r1_sh[47];
                        cst           <= C_GAP;
                        gap_c         <= '0;
                        o_card_cmd_oe <= 1'b0;
                    end else begin
                        o_card_cmd_o <= r1_sh[47];
                        r1_sh        <= {r1_sh[46:0], 1'b0};
                        resp_bc      <= resp_bc + 6'd1;
                    end
                end

                C_GAP: begin
                    if (gap_c == 4'd4) begin
                        cst           <= C_TOK_HI;
                        o_card_dat_oe <= 1'b1;
                        o_card_dat_o  <= 4'hF;
                    end else
                        gap_c <= gap_c + 4'd1;
                end

                C_TOK_HI: begin
                    o_card_dat_o <= 4'hF;
                    cst          <= C_TOK_LO;
                end

                C_TOK_LO: begin
                    o_card_dat_o <= 4'hE;
                    cst            <= C_PAYLOAD;
                    pay_low_nibble <= 1'b1;
                    byte_ix        <= '0;
                end

                C_PAYLOAD: begin
                    if (pay_low_nibble) begin
                        o_card_dat_o   <= sector[byte_ix][3:0];
                        pay_low_nibble <= 1'b0;
                    end else begin
                        o_card_dat_o   <= sector[byte_ix][7:4];
                        pay_low_nibble <= 1'b1;
                        if (byte_ix == 9'd511) begin
                            cst   <= C_CRC;
                            crc_c <= '0;
                        end else
                            byte_ix <= byte_ix + 9'd1;
                    end
                end

                C_CRC: begin
                    o_card_dat_o <= 4'h0;
                    if (crc_c == 3'd3) begin
                        cst           <= C_IDLE;
                        o_card_dat_oe <= 1'b0;
                        o_card_dat_o  <= 4'hF;
                    end else
                        crc_c <= crc_c + 3'd1;
                end

                default: cst <= C_IDLE;
            endcase
        end
    end

endmodule
