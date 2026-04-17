/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements sd_4bit_phy.
*/
// ============================================================================
// SD 原生总线焊盘 — 主机侧驱动/采样（卡端接外部上拉与 SD 器件）
// ============================================================================

module sd_4bit_phy (
    input  logic         i_sd_clk,
    input  logic         i_host_cmd_out,
    input  logic         i_host_cmd_oe,
    output logic         o_host_cmd_in,
    input  logic [ 3: 0] i_host_dat_out,
    input  logic         i_host_dat_oe,
    output logic [ 3: 0] o_host_dat_in,
    output logic         o_sd_clk_pin,
    inout  logic         io_sd_cmd,
    inout  logic [ 3: 0] io_sd_dat
);

    assign o_sd_clk_pin = i_sd_clk;

    assign io_sd_cmd = i_host_cmd_oe ? i_host_cmd_out : 1'bz;
    assign o_host_cmd_in = io_sd_cmd;

    assign io_sd_dat = i_host_dat_oe ? i_host_dat_out : 4'bz;
    assign o_host_dat_in = io_sd_dat;

endmodule
