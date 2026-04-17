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
// P_USE_SDIO_DISK=1: sd_native_host_4bit fills sector_buf; sector_ready pulses
//   when load completes; data valid for i_disk_raddr in loaded LBA until next load.
// ============================================================================

module sdcard_controller #(
    parameter int P_BYTE_DEPTH    = 512 * 2048,
    parameter bit P_USE_SDIO_DISK = 1'b0
) (
    input  logic [31: 0] i_disk_raddr,
    output logic [ 7: 0] o_disk_rdata,
    input  logic         i_disk_sector_req,
    output logic         o_disk_sector_ready,
    output logic         o_sdcard_controller_phy_clk,
    output logic         o_sdcard_controller_phy_cmd_out,
    output logic         o_sdcard_controller_phy_cmd_oe,
    input  logic         i_sdcard_controller_phy_cmd_in,
    output logic [ 3: 0] o_sdcard_controller_phy_dat_out,
    output logic         o_sdcard_controller_phy_dat_oe,
    input  logic [ 3: 0] i_sdcard_controller_phy_dat_in,
    input  logic         clock,
    input  logic         reset_n
);

    localparam int LP_AW = $clog2(P_BYTE_DEPTH);

    logic [ 7: 0] image [0:P_BYTE_DEPTH-1];

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            image[0] <= 8'hA5;
            image[1] <= 8'h5A;
        end
    end

    generate
        if (!P_USE_SDIO_DISK) begin : g_bram_only
            always_comb begin
                if (i_disk_raddr < P_BYTE_DEPTH)
                    o_disk_rdata = image[i_disk_raddr[LP_AW-1: 0]];
                else
                    o_disk_rdata = 8'h00;
            end
            assign o_disk_sector_ready = 1'b0;
            assign o_sdcard_controller_phy_clk     = 1'b0;
            assign o_sdcard_controller_phy_cmd_out = 1'b1;
            assign o_sdcard_controller_phy_cmd_oe  = 1'b0;
            assign o_sdcard_controller_phy_dat_out = 4'hF;
            assign o_sdcard_controller_phy_dat_oe  = 1'b0;
        end else begin : g_sdio
            logic [ 8: 0]  sector_buf [0:511];
            logic          sector_loaded;
            logic [31: 0]  hold_lba;
            logic          sd_start;
            logic [31: 0]  sd_lba;
            logic          sd_busy;
            logic          sd_done;
            logic          sd_err;
            logic          sd_payload_we;
            logic [ 8: 0]  sd_payload_addr;
            logic [ 7: 0]  sd_payload_data;
            logic          sd_active;
            logic          sector_ready_hold;

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

                    if (!i_disk_sector_req)
                        sector_ready_hold <= 1'b0;
                    else if (sd_err && sd_active) begin
                        sd_active <= 1'b0;
                    end else if (sd_done && sd_active) begin
                        sd_active         <= 1'b0;
                        hold_lba          <= sd_lba;
                        sector_loaded     <= 1'b1;
                        sector_ready_hold <= 1'b1;
                    end else if (i_disk_sector_req && !sd_busy && !sd_active) begin
                        if (sector_loaded && ((i_disk_raddr >> 9) == hold_lba))
                            sector_ready_hold <= 1'b1;
                        else begin
                            sd_lba    <= i_disk_raddr >> 9;
                            sd_start  <= 1'b1;
                            sd_active <= 1'b1;
                        end
                    end
                end
            end

            always_comb begin
                if (sector_loaded && ((i_disk_raddr >> 9) == hold_lba))
                    o_disk_rdata = sector_buf[i_disk_raddr[8: 0]];
                else
                    o_disk_rdata = 8'h00;
            end

            assign o_disk_sector_ready = sector_ready_hold;

            sd_native_host_4bit u_sd_host (
                .i_start        ( sd_start ),
                .i_lba          ( sd_lba ),
                .o_busy         ( sd_busy ),
                .o_done         ( sd_done ),
                .o_err          ( sd_err ),
                .o_payload_we   ( sd_payload_we ),
                .o_payload_addr ( sd_payload_addr ),
                .o_payload_data ( sd_payload_data ),
                .o_sd_native_host_4bit_phy_clk     ( o_sdcard_controller_phy_clk ),
                .o_sd_native_host_4bit_phy_cmd_out   ( o_sdcard_controller_phy_cmd_out ),
                .o_sd_native_host_4bit_phy_cmd_oe    ( o_sdcard_controller_phy_cmd_oe ),
                .i_sd_native_host_4bit_phy_cmd_in    ( i_sdcard_controller_phy_cmd_in ),
                .o_sd_native_host_4bit_phy_dat_out   ( o_sdcard_controller_phy_dat_out ),
                .o_sd_native_host_4bit_phy_dat_oe    ( o_sdcard_controller_phy_dat_oe ),
                .i_sd_native_host_4bit_phy_dat_in    ( i_sdcard_controller_phy_dat_in ),
                .clock          ( clock ),
                .reset_n        ( reset_n )
            );
        end
    endgenerate

endmodule
