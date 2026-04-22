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
//  File        : sdcard_4bit_phy.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : sdcard_4bit_phy module
// ============================================================================

module sdcard_4bit_phy (
    input  logic         i_sd_clk, // 内部生成的 SD 时钟至焊盘方向
    input  logic         i_host_cmd_out, // 控制器侧 CMD 驱动电平
    input  logic         i_host_cmd_oe, // 控制器侧 CMD 输出使能
    output logic         o_host_cmd_in, // 回读焊盘 CMD（含外部设备驱动）
    input  logic [ 3: 0] i_host_dat_out, // 控制器侧 DAT 驱动
    input  logic         i_host_dat_oe, // 控制器侧 DAT OE
    output logic [ 3: 0] o_host_dat_in, // 回读焊盘 DAT
    output logic         o_sd_clk_pin, // 输出至板级 SD_CLK
    output logic         o_sd_cmd_out, // 至 IOBUF/PAD 的 CMD 出
    output logic         o_sd_cmd_oe, // CMD 三态使能
    input  logic         i_sd_cmd_in, // 自板级 CMD _pad 的回读
    output logic [ 3: 0] o_sd_dat_out, // DAT 至 PAD
    output logic         o_sd_dat_oe, // DAT 三态使能
    input  logic [ 3: 0] i_sd_dat_in // 自板级 DAT_pad 的回读
);

    // 时钟直通板级
    assign o_sd_clk_pin = i_sd_clk;

    // CMD 数据线转发（PAD 侧与控制器侧直连模型）
    assign o_sd_cmd_out = i_host_cmd_out;
    assign o_sd_cmd_oe = i_host_cmd_oe;
    assign o_host_cmd_in = i_sd_cmd_in;

    // DAT[3: 0] 转发
    assign o_sd_dat_out = i_host_dat_out;
    assign o_sd_dat_oe = i_host_dat_oe;
    assign o_host_dat_in = i_sd_dat_in;

endmodule
