/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: SDIO 4-bit pad transceiver — host digital side to board inout CMD/DAT.
*/
// ============================================================================
// sdcard_4bit_phy
// ----------------------------------------------------------------------------
// Maps internal out/oe signals to external SD CMD / DAT[3:0] bidirectional pins.
// ============================================================================

module sdcard_4bit_phy (
    input  logic         i_sd_clk,
    input  logic         i_host_cmd_out,
    input  logic         i_host_cmd_oe,
    output logic         o_host_cmd_in,
    input  logic [ 3: 0] i_host_dat_out,
    input  logic         i_host_dat_oe,
    output logic [ 3: 0] o_host_dat_in,
    output logic         o_sd_clk_pin,
    output logic         o_sd_cmd_out,
    output logic         o_sd_cmd_oe,
    input  logic         i_sd_cmd_in,
    output logic [ 3: 0] o_sd_dat_out,
    output logic         o_sd_dat_oe,
    input  logic [ 3: 0] i_sd_dat_in
);

    assign o_sd_clk_pin = i_sd_clk;

    assign o_sd_cmd_out = i_host_cmd_out;
    assign o_sd_cmd_oe = i_host_cmd_oe;
    assign o_host_cmd_in = i_sd_cmd_in;

    assign o_sd_dat_out = i_host_dat_out;
    assign o_sd_dat_oe = i_host_dat_oe;
    assign o_host_dat_in = i_sd_dat_in;

endmodule
