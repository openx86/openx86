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
//  File        : vga_font_rom.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : vga_font_rom module
// ============================================================================

// VGA 字符生成器（Font ROM）
// 支持 8x16 字符点阵，256 个字符（ASCII + 扩展字符）
// 每个字符 16 字节（16 行 x 1 字节/行）
//
// 字体数据：仿真时在 testbench 中对 font_rom_inst.rom 做 $readmemh 等初始化。

module vga_font_rom (
    // ------------------------------------------------------------------------
    // Font lookup interface
    // ------------------------------------------------------------------------
    input  logic [ 7: 0]  char_code, // 字符码（0-255）
    input  logic [ 3: 0]  row_index, // 字符内行索引（0-15，对应字体 ROM 行）
    output logic [ 7: 0] font_data, // 当前行 8 点宽点阵（MSB 通常对应左像素）

    // ------------------------------------------------------------------------
    // Clock / reset
    // ------------------------------------------------------------------------
    input  logic          rst_n, // 异步低有效复位（送子 ROM）
    input  logic          clk // 字体读同步时钟
);

    // 字体线性地址：{字符, 行}
    logic [11: 0] font_addr;

    assign font_addr = {char_code, row_index};

    single_port_rom #(
        .DATA_WIDTH ( 8      ),
        .ADDR_WIDTH ( 12     ),
        .DEPTH      ( 4096   )
    ) font_rom_inst (
        .addr   ( font_addr  ),
        .rdata  ( font_data  ),
        .clk  ( clk      ),
        .rst_n  ( rst_n    )
    );

endmodule
