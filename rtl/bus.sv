// ============================================================================
// Bus Controller Module
// 根据 IBM PC 兼容机标准和 Intel 标准实现总线控制器
// 负责地址解码和外设路由
// ============================================================================

module bus (
    // CPU 总线接口
    input  logic        i_bus_valid,
    output logic        o_bus_ready,
    output logic        o_bus_busy,
    input  logic        i_bus_write_enable,
    input  logic        i_bus_io_access,  // 1=I/O访问, 0=内存访问 (类似x86的M/IO#信号)
    input  logic [31:0] i_bus_address,
    output logic [31:0] o_bus_data_read,
    input  logic [31:0] i_bus_data_write,
    
    // VGA 内存访问接口（VRAM窗口 0xA0000-0xBFFFF）
    // 注意：VGA VRAM 通常是只写的（从CPU角度），VGA控制器自己读取显示
    output logic        o_vga_mem_en_w,
    output logic [19:0] o_vga_mem_addr,
    output logic [7:0]  o_vga_mem_data_w,
    
    // VGA I/O 端口接口（0x03C0-0x03DF）
    output logic        o_vga_io_en_w,
    output logic        o_vga_io_en_r,
    output logic [15:0] o_vga_io_addr,
    output logic [7:0]  o_vga_io_data_w,
    input  logic [7:0]  i_vga_io_data_r,
    
    // 系统 RAM 接口（640KB 常规内存）
    // 使用简单的RAM接口：we, addr, wdata, rdata
    output logic        o_ram_we,
    output logic [19:0] o_ram_addr,
    output logic [31:0] o_ram_wdata,
    input  logic [31:0] i_ram_rdata,
    
    // BIOS ROM 接口（系统 BIOS 64KB）
    // 使用简单的ROM接口：addr, rdata
    output logic [15:0] o_bios_addr,
    input  logic [31:0] i_bios_rdata,
    
    // 扩展 BIOS ROM 接口（128KB）
    output logic [16:0] o_ext_bios_addr,
    input  logic [31:0] i_ext_bios_rdata,
    
    // 公共信号
    input  logic        i_clock,
    input  logic        i_reset
);

// ============================================================================
// IBM PC 兼容机标准地址映射定义
// ============================================================================

// 内存地址范围定义（32位地址空间）
localparam logic [31:0] MEM_BASE_RAM        = 32'h0000_0000;  // 常规内存起始
localparam logic [31:0] MEM_END_RAM         = 32'h0009_FFFF;  // 常规内存结束 (640KB)
localparam logic [31:0] MEM_BASE_VRAM       = 32'h000A_0000;  // VGA VRAM 起始
localparam logic [31:0] MEM_END_VRAM        = 32'h000B_FFFF;  // VGA VRAM 结束 (128KB)
localparam logic [31:0] MEM_BASE_EXT_BIOS   = 32'h000C_0000;  // 扩展 BIOS 起始
localparam logic [31:0] MEM_END_EXT_BIOS    = 32'h000D_FFFF;  // 扩展 BIOS 结束 (128KB)
localparam logic [31:0] MEM_BASE_RESERVED   = 32'h000E_0000;  // 保留区域起始
localparam logic [31:0] MEM_END_RESERVED    = 32'h000E_FFFF;  // 保留区域结束 (64KB)
localparam logic [31:0] MEM_BASE_SYS_BIOS   = 32'h000F_0000;  // 系统 BIOS 起始
localparam logic [31:0] MEM_END_SYS_BIOS    = 32'h000F_FFFF;  // 系统 BIOS 结束 (64KB)

// I/O 端口地址范围定义（16位地址空间）
localparam logic [15:0] IO_BASE_MOTHERBOARD = 16'h0000;  // 主板 I/O 起始
localparam logic [15:0] IO_END_MOTHERBOARD  = 16'h00FF;  // 主板 I/O 结束
localparam logic [15:0] IO_BASE_EXTENDED    = 16'h0100;  // 扩展 I/O 起始
localparam logic [15:0] IO_END_EXTENDED     = 16'h03FF;  // 扩展 I/O 结束
localparam logic [15:0] IO_BASE_VGA         = 16'h03C0;  // VGA I/O 起始
localparam logic [15:0] IO_END_VGA          = 16'h03DF;  // VGA I/O 结束
localparam logic [15:0] IO_BASE_FDC         = 16'h03F0;  // 软盘控制器起始
localparam logic [15:0] IO_END_FDC          = 16'h03F7;  // 软盘控制器结束
localparam logic [15:0] IO_BASE_COM1        = 16'h03F8;  // COM1 串口起始
localparam logic [15:0] IO_END_COM1         = 16'h03FF;  // COM1 串口结束

// 地址解码信号
logic is_memory_access;
logic is_io_access;
logic is_ram_access;
logic is_vram_access;
logic is_ext_bios_access;
logic is_sys_bios_access;
logic is_vga_io_access;
logic is_other_io_access;

// 数据选择信号
logic [31:0] ram_data_selected;
logic [31:0] vram_data_selected;
logic [31:0] bios_data_selected;
logic [31:0] ext_bios_data_selected;
logic [31:0] io_data_selected;

// 就绪信号
logic ram_ready_internal;
logic vram_ready_internal;
logic bios_ready_internal;
logic ext_bios_ready_internal;
logic io_ready_internal;

// ============================================================================
// 地址解码逻辑
// ============================================================================

// 判断是内存访问还是 I/O 访问
// 在 x86 架构中，I/O 访问通过 IN/OUT 指令，使用专门的 I/O 地址空间
// CPU 通过 i_bus_io_access 信号来区分：
// - i_bus_io_access = 0: 内存访问
// - i_bus_io_access = 1: I/O 端口访问（地址的低16位是I/O端口地址）

assign is_memory_access = !i_bus_io_access;
assign is_io_access     = i_bus_io_access;

// 内存地址解码
assign is_ram_access      = is_memory_access && 
                             (i_bus_address >= MEM_BASE_RAM) && 
                             (i_bus_address <= MEM_END_RAM);
                             
assign is_vram_access     = is_memory_access && 
                             (i_bus_address >= MEM_BASE_VRAM) && 
                             (i_bus_address <= MEM_END_VRAM);
                             
assign is_ext_bios_access = is_memory_access && 
                             (i_bus_address >= MEM_BASE_EXT_BIOS) && 
                             (i_bus_address <= MEM_END_EXT_BIOS);
                             
assign is_sys_bios_access = is_memory_access && 
                             (i_bus_address >= MEM_BASE_SYS_BIOS) && 
                             (i_bus_address <= MEM_END_SYS_BIOS);

// I/O 地址解码
assign is_vga_io_access   = is_io_access && 
                             (i_bus_address[15:0] >= IO_BASE_VGA) && 
                             (i_bus_address[15:0] <= IO_END_VGA);
                             
assign is_other_io_access = is_io_access && !is_vga_io_access;

// 注意：VGA VRAM 是只写的（从CPU角度），不支持读操作
// 如果需要读VRAM，需要从VGA模块内部读取，这里暂时不支持

// ============================================================================
// 地址转换（将物理地址转换为外设内部地址）
// ============================================================================

// VRAM 地址：减去基地址，使用低 20 位（128KB = 2^17，但为了对齐使用 20 位）
assign o_vga_mem_addr = i_bus_address[19:0] - MEM_BASE_VRAM[19:0];

// ============================================================================
// 外设使能信号生成
// ============================================================================

// RAM 访问控制
assign o_ram_we = is_ram_access && i_bus_valid && i_bus_write_enable;
assign o_ram_addr = i_bus_address[19:0];
assign o_ram_wdata = i_bus_data_write;

// VRAM 访问控制（VGA 只支持字节写）
assign o_vga_mem_en_w = is_vram_access && i_bus_valid && i_bus_write_enable;
assign o_vga_mem_data_w = i_bus_data_write[7:0];  // 只使用低 8 位

// BIOS ROM 访问控制（只读）
assign o_bios_addr = i_bus_address[15:0] - MEM_BASE_SYS_BIOS[15:0];
assign o_ext_bios_addr = i_bus_address[16:0] - MEM_BASE_EXT_BIOS[16:0];

// VGA I/O 端口访问控制
assign o_vga_io_en_w = is_vga_io_access && i_bus_valid && i_bus_write_enable;
assign o_vga_io_en_r = is_vga_io_access && i_bus_valid && !i_bus_write_enable;
assign o_vga_io_addr = i_bus_address[15:0];
assign o_vga_io_data_w = i_bus_data_write[7:0];  // I/O 端口通常是 8 位或 16 位

// ============================================================================
// 数据读取路径选择
// ============================================================================

// RAM 数据（32 位）
assign ram_data_selected = is_ram_access ? i_ram_rdata : 32'h0;

// VRAM 数据（8 位扩展到 32 位）
// 注意：VGA VRAM 是只写的，不支持CPU读操作
// 如果CPU尝试读VRAM，返回0（或者可以返回未定义值）
assign vram_data_selected = 32'h0;  // VRAM不支持读操作

// BIOS 数据
assign bios_data_selected = is_sys_bios_access ? i_bios_rdata : 32'h0;
assign ext_bios_data_selected = is_ext_bios_access ? i_ext_bios_rdata : 32'h0;

// I/O 数据（8 位扩展到 32 位）
logic [7:0] io_byte_data;
assign io_byte_data = is_vga_io_access ? i_vga_io_data_r : 
                      8'hFF;  // 未实现的外设返回 0xFF
assign io_data_selected = is_io_access ? {24'h0, io_byte_data} : 32'h0;

// 最终数据输出
always_comb begin
    if (is_ram_access) begin
        o_bus_data_read = ram_data_selected;
    end else if (is_vram_access) begin
        // VRAM不支持读操作，返回0
        o_bus_data_read = 32'h0;
    end else if (is_ext_bios_access) begin
        o_bus_data_read = ext_bios_data_selected;
    end else if (is_sys_bios_access) begin
        o_bus_data_read = bios_data_selected;
    end else if (is_io_access) begin
        o_bus_data_read = io_data_selected;
    end else begin
        // 未映射的地址返回 0xFFFFFFFF
        o_bus_data_read = 32'hFFFF_FFFF;
    end
end

// ============================================================================
// 就绪信号生成
// ============================================================================

// 各外设的就绪信号
// RAM和ROM是同步的，假设立即完成（实际可能需要1个时钟周期）
assign ram_ready_internal = is_ram_access ? 1'b1 : 1'b0;

assign vram_ready_internal = o_vga_mem_en_w ? 1'b1 : 1'b0;  // VGA 写操作假设立即完成

// BIOS ROM是同步的，假设立即完成
assign bios_ready_internal = is_sys_bios_access ? 1'b1 : 1'b0;
assign ext_bios_ready_internal = is_ext_bios_access ? 1'b1 : 1'b0;

assign io_ready_internal = (o_vga_io_en_w || o_vga_io_en_r || is_other_io_access) ? 1'b1 : 1'b0;  // I/O 操作假设立即完成

// 总线就绪信号
always_comb begin
    if (is_ram_access) begin
        o_bus_ready = ram_ready_internal;
    end else if (is_vram_access) begin
        o_bus_ready = vram_ready_internal;
    end else if (is_ext_bios_access) begin
        o_bus_ready = ext_bios_ready_internal;
    end else if (is_sys_bios_access) begin
        o_bus_ready = bios_ready_internal;
    end else if (is_io_access) begin
        o_bus_ready = io_ready_internal;
    end else begin
        // 未映射的地址立即返回就绪（但数据是 0xFFFFFFFF）
        o_bus_ready = i_bus_valid;
    end
end

// 总线忙信号（暂时设为 0，表示总线总是可用）
assign o_bus_busy = 1'b0;

endmodule
