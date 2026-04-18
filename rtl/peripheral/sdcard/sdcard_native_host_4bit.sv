/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Minimal SD native 4-bit host — CMD17 single-block read for RTL + sd_mmc_card_model_native.
*/
// ============================================================================
// sdcard_native_host_4bit
// ----------------------------------------------------------------------------
// i_start: one-shot or pulse to read one 512B block at i_lba (argument field).
// Card model does not validate CRC; bit count and data token path matter.
// ============================================================================

module sdcard_native_host_4bit (
    input  logic         i_start,
    input  logic [31: 0] i_lba,
    output logic         o_busy,
    output logic         o_done,
    output logic         o_err,
    output logic         o_payload_we,
    output logic [ 8: 0] o_payload_addr,
    output logic [ 7: 0] o_payload_data,
    output logic         o_sdcard_native_host_4bit_phy_clk,
    output logic         o_sdcard_native_host_4bit_phy_cmd_out,
    output logic         o_sdcard_native_host_4bit_phy_cmd_oe,
    input  logic         i_sdcard_native_host_4bit_phy_cmd_in,
    output logic [ 3: 0] o_sdcard_native_host_4bit_phy_dat_out,
    output logic         o_sdcard_native_host_4bit_phy_dat_oe,
    input  logic [ 3: 0] i_sdcard_native_host_4bit_phy_dat_in,
    input  logic         clock,
    input  logic         reset_n
);

    typedef enum logic [ 3: 0] {
        ST_IDLE,
        ST_LATCH_LBA,
        ST_SEND_CMD,
        ST_GAP_HOST,
        ST_PRE_RESP,
        ST_RECV_RESP,
        ST_WAIT_TOKEN_E,
        ST_READ_LO,
        ST_READ_HI,
        ST_FINISH,
        ST_ERR
    } sd_host_state_t;

    sd_host_state_t state;

    logic [ 5: 0]  send_bit_ix;
    logic [ 5: 0]  resp_bit_ix;
    logic [ 2: 0]  gap_cnt;
    logic [ 8: 0]  byte_ix;
    logic [ 3: 0]  lo_nib;
    logic [31: 0]  latched_lba;
    logic [47: 0]  cmd_frame;
    logic          start_d;
    logic          start_pulse;

    always_comb begin
        start_pulse = i_start & ~start_d;
        cmd_frame   = { 1'b0, 1'b1, 6'd17, latched_lba, 7'h7F, 1'b1 };
    end

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n)
            start_d <= 1'b0;
        else
            start_d <= i_start;
    end


    assign o_sdcard_native_host_4bit_phy_clk = clock;

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
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
                ST_IDLE: begin
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

                ST_LATCH_LBA: begin
                    latched_lba <= i_lba;
                    send_bit_ix <= '0;
                    state       <= ST_SEND_CMD;
                    o_sdcard_native_host_4bit_phy_cmd_oe <= 1'b1;
                end

                ST_SEND_CMD: begin
                    o_sdcard_native_host_4bit_phy_cmd_out <= cmd_frame[47 - send_bit_ix];
                    o_sdcard_native_host_4bit_phy_cmd_oe  <= 1'b1;
                    if (send_bit_ix == 6'd47)
                        state <= ST_GAP_HOST;
                    else
                        send_bit_ix <= send_bit_ix + 6'd1;
                end

                ST_GAP_HOST: begin
                    o_sdcard_native_host_4bit_phy_cmd_oe  <= 1'b0;
                    o_sdcard_native_host_4bit_phy_cmd_out <= 1'b1;
                    gap_cnt    <= '0;
                    resp_bit_ix <= '0;
                    state      <= ST_PRE_RESP;
                end

                ST_PRE_RESP: begin
                    if (gap_cnt == 3'd7)
                        state <= ST_RECV_RESP;
                    else
                        gap_cnt <= gap_cnt + 3'd1;
                end

                ST_RECV_RESP: begin
                    if (resp_bit_ix == 6'd47)
                        state <= ST_WAIT_TOKEN_E;
                    else
                        resp_bit_ix <= resp_bit_ix + 6'd1;
                end

                ST_WAIT_TOKEN_E: begin
                    if (i_sdcard_native_host_4bit_phy_dat_in == 4'hE) begin
                        state   <= ST_READ_LO;
                        byte_ix <= '0;
                    end
                end

                ST_READ_LO: begin
                    lo_nib <= i_sdcard_native_host_4bit_phy_dat_in;
                    state  <= ST_READ_HI;
                end

                ST_READ_HI: begin
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
