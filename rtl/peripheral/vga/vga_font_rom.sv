// VGA 字符生成器（Font ROM）
// 支持 8x16 字符点阵，256 个字符（ASCII + 扩展字符）
// 每个字符 16 字节（16 行 x 1 字节/行）

module vga_font_rom (
    input  logic [7:0]  char_code,      // 字符码（0-255）
    input  logic [3:0]  row_index,      // 字符行索引（0-15）
    output logic [7:0]  font_data,      // 字符点阵数据（8 位，每 bit 代表一个像素）
    
    input  logic        clock,
    input  logic        reset
);

    // 字符 ROM 地址：char_code * 16 + row_index
    // 256 个字符 x 16 行 = 4096 字节，需要 12 位地址
    logic [11:0] font_addr;
    assign font_addr = {char_code, row_index};

    // 使用单口 ROM 实例
    // 注意：字体数据初始化通过 vga_font_rom_init 模块完成
    single_port_rom #(
        .DATA_WIDTH ( 8      ),
        .ADDR_WIDTH ( 12     ),
        .DEPTH      ( 4096   ),
        .INIT_FILE  ( "rtl/peripheral/vga/vga_font_8x16.hex" )  // 字体数据文件
    ) font_rom_inst (
        .addr   ( font_addr  ),
        .rdata  ( font_data  ),
        .clock  ( clock      ),
        .reset  ( reset      )
    );

    // 字体数据初始化通过修改 single_port_rom 的 INIT_FILE 参数完成
    // 或者创建专门的初始化模块来加载字体数据

endmodule
