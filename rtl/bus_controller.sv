// ============================================================================
// Bus Controller Module
// 根据 IBM PC 兼容机标准和 Intel 标准实现总线控制器
// 负责地址解码和外设路由
// ============================================================================

// ----------------------------------------------------------------------------
// bus_devices
// ----------------------------------------------------------------------------
// Pure address decode + device integration. This module contains no CPU-side
// sequencing beyond combinational ready/data selection.
//
// It is wrapped by `bus_controller` to keep a stable top-level bus port
// interface while allowing the device-side to evolve.
// ----------------------------------------------------------------------------
module bus_devices #(
    parameter bit  USE_REAL_PS2 = 1'b0,
    parameter int PS2_CLK_HZ   = 50_000_000,
    parameter bit  USE_SDIO_DISK = 1'b0
) (
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

    // BIOS ROM 接口（系统 BIOS 64KB）
    // 使用简单的ROM接口：addr, rdata
    output logic [15:0] o_bios_addr,
    input  logic [31:0] i_bios_rdata,

    // 扩展 BIOS ROM 接口（128KB）
    output logic [16:0] o_ext_bios_addr,
    input  logic [31:0] i_ext_bios_rdata,

    // SDRAM：640KB 常规内存 + 16MB 窗口（0x0100_0000）共用 sdram_controller
    output logic        o_sdram_en,
    output logic        o_sdram_we,
    output logic [23:0] o_sdram_addr_off,
    output logic [31:0] o_sdram_wdata,
    input  logic [31:0] i_sdram_rdata,
    input  logic        i_sdram_ready,
    input  logic        i_sdram_busy,

    // PS/2 键盘与鼠标（8042）：开漏驱动 + 总线回读；未用 PHY 时可上拉输入为 1
    output logic        o_ps2_kbd_clk_out,
    output logic        o_ps2_kbd_clk_oe,
    input  logic        i_ps2_kbd_clk_in,
    output logic        o_ps2_kbd_dat_out,
    output logic        o_ps2_kbd_dat_oe,
    input  logic        i_ps2_kbd_dat_in,
    output logic        o_ps2_aux_clk_out,
    output logic        o_ps2_aux_clk_oe,
    input  logic        i_ps2_aux_clk_in,
    output logic        o_ps2_aux_dat_out,
    output logic        o_ps2_aux_dat_oe,
    input  logic        i_ps2_aux_dat_in,

    // SDIO / SD 4-bit（IDE 盘体由 bus_devices 内 SD 主机驱动；USE_SDIO_DISK=0 时引脚空闲）
    output logic        o_sdio_clk,
    output logic        o_sdio_cmd_o,
    output logic        o_sdio_cmd_oe,
    input  logic        i_sdio_cmd_i,
    output logic [3:0]  o_sdio_dat_o,
    output logic        o_sdio_dat_oe,
    input  logic [3:0]  i_sdio_dat_i,

    // PIC 主片中断输出（接 CPU INTR）
    output logic        o_pic_intr,

    // Chipset（IBM PC/AT I/O：各 chip_* 模块由 bus_devices 直连例化；未命中时读回 0xFF）

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
localparam logic [31:0] MEM_BASE_SDRAM      = 32'h0100_0000;  // SDRAM 窗口起始（16MB）
localparam logic [31:0] MEM_END_SDRAM       = 32'h01FF_FFFF;  // SDRAM 窗口结束

// I/O 端口地址范围定义（16位地址空间）
localparam logic [15:0] IO_BASE_MOTHERBOARD = 16'h0000;  // 主板 I/O 起始
localparam logic [15:0] IO_END_MOTHERBOARD  = 16'h00FF;  // 主板 I/O 结束
localparam logic [15:0] IO_BASE_EXTENDED    = 16'h0100;  // 扩展 I/O 起始
localparam logic [15:0] IO_END_EXTENDED     = 16'h03FF;  // 扩展 I/O 结束
localparam logic [15:0] IO_BASE_VGA         = 16'h03C0;  // VGA I/O 起始
localparam logic [15:0] IO_END_VGA          = 16'h03DF;  // VGA I/O 结束
localparam logic [15:0] IO_BASE_COM1        = 16'h03F8;  // COM1 串口起始
localparam logic [15:0] IO_END_COM1         = 16'h03FF;  // COM1 串口结束

// 地址解码信号
logic is_memory_access;
logic is_io_access;
logic is_ram_access;
logic is_vram_access;
logic is_ext_bios_access;
logic is_sys_bios_access;
logic is_sdram_access;
logic is_vga_io_access;
logic is_other_io_access;
logic is_chipset_io;
logic [7:0] chipset_io_rdata;
logic       chipset_io_hit;

// 数据选择信号
logic [31:0] vram_data_selected;
logic [31:0] bios_data_selected;
logic [31:0] ext_bios_data_selected;
logic [31:0] io_data_selected;

// 就绪信号
logic vram_ready_internal;
logic bios_ready_internal;
logic ext_bios_ready_internal;
logic sdram_ready_internal;
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

assign is_sdram_access    = is_memory_access &&
                             (i_bus_address >= MEM_BASE_SDRAM) &&
                             (i_bus_address <= MEM_END_SDRAM);

// I/O 地址解码
assign is_vga_io_access   = is_io_access &&
                             (i_bus_address[15:0] >= IO_BASE_VGA) &&
                             (i_bus_address[15:0] <= IO_END_VGA);

assign is_other_io_access = is_io_access && !is_vga_io_access;

// Chipset 端口并集（与各 chip_* 模块地址一致）
assign is_chipset_io = is_other_io_access && (
    ((i_bus_address[15:0] >= 16'h0000) && (i_bus_address[15:0] <= 16'h000F)) ||
    ((i_bus_address[15:0] >= 16'h0080) && (i_bus_address[15:0] <= 16'h008F)) ||
    ((i_bus_address[15:0] >= 16'h00C0) && (i_bus_address[15:0] <= 16'h00DF)) ||
    ((i_bus_address[15:0] >= 16'h0020) && (i_bus_address[15:0] <= 16'h0021)) ||
    ((i_bus_address[15:0] >= 16'h00A0) && (i_bus_address[15:0] <= 16'h00A1)) ||
    ((i_bus_address[15:0] >= 16'h0040) && (i_bus_address[15:0] <= 16'h0043)) ||
    (i_bus_address[15:0] == 16'h0060) ||
    (i_bus_address[15:0] == 16'h0064) ||
    ((i_bus_address[15:0] >= 16'h0070) && (i_bus_address[15:0] <= 16'h0071)) ||
    ((i_bus_address[15:0] >= 16'h01F0) && (i_bus_address[15:0] <= 16'h01F7)) ||
    (i_bus_address[15:0] == 16'h03F6) ||
    ((i_bus_address[15:0] >= 16'h0378) && (i_bus_address[15:0] <= 16'h037F)) ||
    ((i_bus_address[15:0] >= 16'h03F8) && (i_bus_address[15:0] <= 16'h03FF))
);

// -------------------------------------------------------------------------
// IBM PC/AT：各 chip_* 在 bus_devices 内直连例化
// -------------------------------------------------------------------------
localparam int CHIP_DISK_IMAGE_BYTES = 512 * 2048;
localparam int CHIP_DISK_SECTOR_CNT  = CHIP_DISK_IMAGE_BYTES / 512;

wire [15:0] chip_io_addr = i_bus_address[15:0];
wire        chip_io_vld  = is_chipset_io && i_bus_valid;
wire        chip_io_we   = i_bus_write_enable;

logic [31:0] chip_ide_disk_raddr;
logic [7:0]  chip_ide_disk_rdata_ram;
logic [7:0]  chip_disk_rdata_b_unused;
logic [7:0]  chip_ide_disk_rdata_eff;
logic        chip_ide_sector_ready_eff;
logic        chip_ide_sector_req_w;

generate
    if (!USE_SDIO_DISK) begin : g_disk_ram
        disk_ram_8 #(
            .BYTE_DEPTH ( CHIP_DISK_IMAGE_BYTES )
        ) u_disk_image (
            .i_clock   ( i_clock ),
            .i_reset   ( i_reset ),
            .i_we      ( 1'b0 ),
            .i_waddr   ( 32'h0 ),
            .i_wdata   ( 8'h0 ),
            .i_raddr_a ( chip_ide_disk_raddr ),
            .i_raddr_b ( 32'h0 ),
            .o_rdata_a ( chip_ide_disk_rdata_ram ),
            .o_rdata_b ( chip_disk_rdata_b_unused )
        );
        assign chip_ide_disk_rdata_eff   = chip_ide_disk_rdata_ram;
        assign chip_ide_sector_ready_eff = 1'b0;
        assign o_sdio_clk      = 1'b0;
        assign o_sdio_cmd_o    = 1'b1;
        assign o_sdio_cmd_oe   = 1'b0;
        assign o_sdio_dat_o    = 4'hF;
        assign o_sdio_dat_oe   = 1'b0;
    end else begin : g_sdio_host
        logic        sd_start;
        logic [31:0] sd_lba;
        logic        sd_busy;
        logic        sd_done;
        logic        sd_err;
        logic        sd_payload_we;
        logic [8:0]  sd_payload_addr;
        logic [7:0]  sd_payload_data;

        ide_sd_sector_bridge u_ide_sd_br (
            .i_clock             ( i_clock ),
            .i_reset             ( i_reset ),
            .i_ide_disk_raddr    ( chip_ide_disk_raddr ),
            .o_ide_disk_rdata    ( chip_ide_disk_rdata_eff ),
            .i_ide_sector_req    ( chip_ide_sector_req_w ),
            .o_ide_sector_ready  ( chip_ide_sector_ready_eff ),
            .o_sd_start          ( sd_start ),
            .o_sd_lba            ( sd_lba ),
            .i_sd_busy           ( sd_busy ),
            .i_sd_done           ( sd_done ),
            .i_sd_err            ( sd_err ),
            .i_sd_payload_we     ( sd_payload_we ),
            .i_sd_payload_addr   ( sd_payload_addr ),
            .i_sd_payload_data   ( sd_payload_data )
        );

        sd_native_host_4bit u_sdio_host (
            .i_clock        ( i_clock ),
            .i_reset        ( i_reset ),
            .o_sd_clk       ( o_sdio_clk ),
            .o_phy_cmd_out  ( o_sdio_cmd_o ),
            .o_phy_cmd_oe   ( o_sdio_cmd_oe ),
            .i_phy_cmd_in   ( i_sdio_cmd_i ),
            .o_phy_dat_out  ( o_sdio_dat_o ),
            .o_phy_dat_oe   ( o_sdio_dat_oe ),
            .i_phy_dat_in   ( i_sdio_dat_i ),
            .i_start        ( sd_start ),
            .i_lba          ( sd_lba ),
            .o_busy         ( sd_busy ),
            .o_done         ( sd_done ),
            .o_err          ( sd_err ),
            .o_payload_we   ( sd_payload_we ),
            .o_payload_addr ( sd_payload_addr ),
            .o_payload_data ( sd_payload_data )
        );
    end
endgenerate

logic [7:0] r_dma, r_pic_m, r_pic_s, r_pit, r_ps2, r_rtc, r_com, r_lpt, r_ide;

wire hit_dma   = (chip_io_addr <= 16'h000F)
               | ((chip_io_addr >= 16'h0080) & (chip_io_addr <= 16'h008F))
               | ((chip_io_addr >= 16'h00C0) & (chip_io_addr <= 16'h00DF));
wire hit_pic_m = (chip_io_addr >= 16'h0020) & (chip_io_addr <= 16'h0021);
wire hit_pic_s = (chip_io_addr >= 16'h00A0) & (chip_io_addr <= 16'h00A1);
wire hit_pit   = (chip_io_addr >= 16'h0040) & (chip_io_addr <= 16'h0043);
wire hit_ps2   = (chip_io_addr == 16'h0060) | (chip_io_addr == 16'h0064);
wire hit_rtc   = (chip_io_addr == 16'h0070) | (chip_io_addr == 16'h0071);
wire hit_com   = (chip_io_addr >= 16'h03F8) & (chip_io_addr <= 16'h03FF);
wire hit_lpt   = (chip_io_addr >= 16'h0378) & (chip_io_addr <= 16'h037F);
wire hit_ide   = ((chip_io_addr >= 16'h01F0) & (chip_io_addr <= 16'h01F7)) | (chip_io_addr == 16'h03F6);

wire vld = chip_io_vld;

wire cs_dma_n   = !(vld & hit_dma);
wire rd_dma_n   = !(vld & !chip_io_we & hit_dma);
wire wr_dma_n   = !(vld &  chip_io_we & hit_dma);

wire cs_pic_m_n = !(vld & hit_pic_m);
wire rd_pic_m_n = !(vld & !chip_io_we & hit_pic_m);
wire wr_pic_m_n = !(vld &  chip_io_we & hit_pic_m);

wire cs_pic_s_n = !(vld & hit_pic_s);
wire rd_pic_s_n = !(vld & !chip_io_we & hit_pic_s);
wire wr_pic_s_n = !(vld &  chip_io_we & hit_pic_s);

wire cs_pit_n   = !(vld & hit_pit);
wire rd_pit_n   = !(vld & !chip_io_we & hit_pit);
wire wr_pit_n   = !(vld &  chip_io_we & hit_pit);

wire cs_ps2_n   = !(vld & hit_ps2);
wire rd_ps2_n   = !(vld & !chip_io_we & hit_ps2);
wire wr_ps2_n   = !(vld &  chip_io_we & hit_ps2);

wire cs_rtc_n   = !(vld & hit_rtc);
wire rd_rtc_n   = !(vld & !chip_io_we & hit_rtc);
wire wr_rtc_n   = !(vld &  chip_io_we & hit_rtc);

wire cs_com_n   = !(vld & hit_com);
wire rd_com_n   = !(vld & !chip_io_we & hit_com);
wire wr_com_n   = !(vld &  chip_io_we & hit_com);

wire cs_lpt_n   = !(vld & hit_lpt);
wire rd_lpt_n   = !(vld & !chip_io_we & hit_lpt);
wire wr_lpt_n   = !(vld &  chip_io_we & hit_lpt);

wire cs_ide_n   = !(vld & hit_ide);
wire rd_ide_n   = !(vld & !chip_io_we & hit_ide);
wire wr_ide_n   = !(vld &  chip_io_we & hit_ide);

logic       pit_out0;
logic       intr_m, intr_s;

logic [7:0] ir_m;
logic       rtc_irq;
logic       ps2_kbd_irq;
logic       ps2_aux_irq;
wire [7:0] pic_slave_ir_merged = { 3'b0, ps2_aux_irq, 3'b0, rtc_irq };

assign ir_m[0]    = pit_out0;
assign ir_m[1]    = ps2_kbd_irq;
assign ir_m[2]    = intr_s;
assign ir_m[7:3]  = 5'b0;

assign chipset_io_hit = chip_io_vld & (hit_dma | hit_pic_m | hit_pic_s | hit_pit | hit_ps2 | hit_rtc | hit_com | hit_lpt | hit_ide);

chip_8237_dma u_chip_dma (
    .i_clock    ( i_clock ),
    .i_reset    ( i_reset ),
    .i_cs_n     ( cs_dma_n ),
    .i_rd_n     ( rd_dma_n ),
    .i_wr_n     ( wr_dma_n ),
    .i_addr     ( chip_io_addr ),
    .i_d        ( i_bus_data_write[7:0] ),
    .o_d        ( r_dma )
);

chip_8259_pic u_chip_pic_m (
    .i_clock    ( i_clock ),
    .i_reset    ( i_reset ),
    .i_cs_n     ( cs_pic_m_n ),
    .i_rd_n     ( rd_pic_m_n ),
    .i_wr_n     ( wr_pic_m_n ),
    .i_a0       ( chip_io_addr[0] ),
    .i_d        ( i_bus_data_write[7:0] ),
    .o_d        ( r_pic_m ),
    .i_ir       ( ir_m ),
    .o_intr     ( intr_m )
);

chip_8259_pic u_chip_pic_s (
    .i_clock    ( i_clock ),
    .i_reset    ( i_reset ),
    .i_cs_n     ( cs_pic_s_n ),
    .i_rd_n     ( rd_pic_s_n ),
    .i_wr_n     ( wr_pic_s_n ),
    .i_a0       ( chip_io_addr[0] ),
    .i_d        ( i_bus_data_write[7:0] ),
    .o_d        ( r_pic_s ),
    .i_ir       ( pic_slave_ir_merged ),
    .o_intr     ( intr_s )
);

logic pit_out1_unused, pit_out2_unused;
chip_8254_pit u_chip_pit (
    .i_clock    ( i_clock ),
    .i_reset    ( i_reset ),
    .i_cs_n     ( cs_pit_n ),
    .i_rd_n     ( rd_pit_n ),
    .i_wr_n     ( wr_pit_n ),
    .i_a        ( chip_io_addr[1:0] ),
    .i_d        ( i_bus_data_write[7:0] ),
    .o_d        ( r_pit ),
    .o_out0     ( pit_out0 ),
    .o_out1     ( pit_out1_unused ),
    .o_out2     ( pit_out2_unused )
);

chip_i8042_ps2 #(
    .USE_REAL_PS2 ( USE_REAL_PS2 ),
    .CLK_HZ       ( PS2_CLK_HZ )
) u_chip_ps2 (
    .i_clock           ( i_clock ),
    .i_reset           ( i_reset ),
    .i_cs_n            ( cs_ps2_n ),
    .i_rd_n            ( rd_ps2_n ),
    .i_wr_n            ( wr_ps2_n ),
    .i_a0              ( chip_io_addr[2] ),
    .i_d               ( i_bus_data_write[7:0] ),
    .o_d               ( r_ps2 ),
    .i_kbd_push        ( 1'b0 ),
    .i_kbd_data        ( 8'h0 ),
    .i_aux_push        ( 1'b0 ),
    .i_aux_data        ( 8'h0 ),
    .o_kbd_irq         ( ps2_kbd_irq ),
    .o_aux_irq         ( ps2_aux_irq ),
    .o_ps2_kbd_clk_out ( o_ps2_kbd_clk_out ),
    .o_ps2_kbd_clk_oe  ( o_ps2_kbd_clk_oe ),
    .i_ps2_kbd_clk_in  ( i_ps2_kbd_clk_in ),
    .o_ps2_kbd_dat_out ( o_ps2_kbd_dat_out ),
    .o_ps2_kbd_dat_oe  ( o_ps2_kbd_dat_oe ),
    .i_ps2_kbd_dat_in  ( i_ps2_kbd_dat_in ),
    .o_ps2_aux_clk_out ( o_ps2_aux_clk_out ),
    .o_ps2_aux_clk_oe  ( o_ps2_aux_clk_oe ),
    .i_ps2_aux_clk_in  ( i_ps2_aux_clk_in ),
    .o_ps2_aux_dat_out ( o_ps2_aux_dat_out ),
    .o_ps2_aux_dat_oe  ( o_ps2_aux_dat_oe ),
    .i_ps2_aux_dat_in  ( i_ps2_aux_dat_in )
);

chip_mc146818_rtc u_chip_rtc (
    .i_clock    ( i_clock ),
    .i_reset    ( i_reset ),
    .i_cs_n     ( cs_rtc_n ),
    .i_rd_n     ( rd_rtc_n ),
    .i_wr_n     ( wr_rtc_n ),
    .i_a0       ( chip_io_addr[0] ),
    .i_d        ( i_bus_data_write[7:0] ),
    .o_d        ( r_rtc ),
    .o_rtc_irq  ( rtc_irq )
);

chip_ns16550_com u_chip_com1 (
    .i_clock    ( i_clock ),
    .i_reset    ( i_reset ),
    .i_cs_n     ( cs_com_n ),
    .i_rd_n     ( rd_com_n ),
    .i_wr_n     ( wr_com_n ),
    .i_a        ( chip_io_addr[2:0] ),
    .i_d        ( i_bus_data_write[7:0] ),
    .o_d        ( r_com ),
    .i_rx_push  ( 1'b0 ),
    .i_rx_data  ( 8'h0 )
);

chip_centronics_lpt u_chip_lpt1 (
    .i_clock    ( i_clock ),
    .i_reset    ( i_reset ),
    .i_cs_n     ( cs_lpt_n ),
    .i_rd_n     ( rd_lpt_n ),
    .i_wr_n     ( wr_lpt_n ),
    .i_a        ( chip_io_addr[2:0] ),
    .i_d        ( i_bus_data_write[7:0] ),
    .o_d        ( r_lpt )
);

chip_ata_ide #(
    .SECTOR_BYTES          ( 512 ),
    .SECTOR_COUNT          ( CHIP_DISK_SECTOR_CNT ),
    .USE_INTERNAL_DISK_MEM ( 1'b0 ),
    .USE_ASYNC_DISK        ( USE_SDIO_DISK )
) u_chip_ide (
    .i_clock             ( i_clock ),
    .i_reset             ( i_reset ),
    .i_cs_n              ( cs_ide_n ),
    .i_rd_n              ( rd_ide_n ),
    .i_wr_n              ( wr_ide_n ),
    .i_addr              ( chip_io_addr ),
    .i_d                 ( i_bus_data_write[7:0] ),
    .o_d                 ( r_ide ),
    .o_disk_raddr        ( chip_ide_disk_raddr ),
    .i_disk_rdata        ( chip_ide_disk_rdata_eff ),
    .i_disk_sector_ready ( chip_ide_sector_ready_eff ),
    .o_disk_sector_req   ( chip_ide_sector_req_w )
);

always_comb begin
    chipset_io_rdata = 8'hFF;
    if (chip_io_vld) begin
        if (hit_dma)
            chipset_io_rdata = r_dma;
        else if (hit_pic_m)
            chipset_io_rdata = r_pic_m;
        else if (hit_pic_s)
            chipset_io_rdata = r_pic_s;
        else if (hit_pit)
            chipset_io_rdata = r_pit;
        else if (hit_ps2)
            chipset_io_rdata = r_ps2;
        else if (hit_rtc)
            chipset_io_rdata = r_rtc;
        else if (hit_com)
            chipset_io_rdata = r_com;
        else if (hit_lpt)
            chipset_io_rdata = r_lpt;
        else if (hit_ide)
            chipset_io_rdata = r_ide;
    end
end

assign o_pic_intr = intr_m;

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

// VRAM 访问控制（VGA 只支持字节写）
assign o_vga_mem_en_w = is_vram_access && i_bus_valid && i_bus_write_enable;
assign o_vga_mem_data_w = i_bus_data_write[7:0];  // 只使用低 8 位

// BIOS ROM 访问控制（只读）
assign o_bios_addr = i_bus_address[15:0] - MEM_BASE_SYS_BIOS[15:0];
assign o_ext_bios_addr = i_bus_address[16:0] - MEM_BASE_EXT_BIOS[16:0];

// SDRAM（32 位字访问；常规 RAM 与高位窗口映射到同一物理地址空间，见 soc_top）
assign o_sdram_en       = (is_ram_access || is_sdram_access) && i_bus_valid;
assign o_sdram_we       = i_bus_write_enable;
assign o_sdram_addr_off = is_ram_access ? i_bus_address[23:0]
                                        : (i_bus_address[23:0] - MEM_BASE_SDRAM[23:0]);
assign o_sdram_wdata    = i_bus_data_write;

// VGA I/O 端口访问控制
assign o_vga_io_en_w = is_vga_io_access && i_bus_valid && i_bus_write_enable;
assign o_vga_io_en_r = is_vga_io_access && i_bus_valid && !i_bus_write_enable;
assign o_vga_io_addr = i_bus_address[15:0];
assign o_vga_io_data_w = i_bus_data_write[7:0];  // I/O 端口通常是 8 位或 16 位

// ============================================================================
// 数据读取路径选择
// ============================================================================

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
                      (chipset_io_hit ? chipset_io_rdata : 8'hFF);
assign io_data_selected = is_io_access ? {24'h0, io_byte_data} : 32'h0;

// 最终数据输出
always_comb begin
    if (is_ram_access || is_sdram_access) begin
        o_bus_data_read = i_sdram_ready ? i_sdram_rdata : 32'h0;
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
assign vram_ready_internal = o_vga_mem_en_w ? 1'b1 : 1'b0;  // VGA 写操作假设立即完成

// BIOS ROM是同步的，假设立即完成
assign bios_ready_internal = is_sys_bios_access ? 1'b1 : 1'b0;
assign ext_bios_ready_internal = is_ext_bios_access ? 1'b1 : 1'b0;

assign sdram_ready_internal = (is_ram_access || is_sdram_access) ? i_sdram_ready : 1'b0;

assign io_ready_internal = (o_vga_io_en_w || o_vga_io_en_r || is_other_io_access) ? 1'b1 : 1'b0;  // I/O 操作假设立即完成

// 总线就绪信号
always_comb begin
    if (is_ram_access || is_sdram_access) begin
        o_bus_ready = sdram_ready_internal;
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

// SDRAM 忙：多周期事务期间由控制器拉高
assign o_bus_busy = (is_ram_access || is_sdram_access) && i_sdram_busy;

endmodule

// ----------------------------------------------------------------------------
// bus_controller
// ----------------------------------------------------------------------------
// Stable CPU-facing bus wrapper. Right now it is a thin wrapper around
// bus_devices, but it is intentionally separated so that future work (e.g.
// registered responses, wait-state insertion, arbitration) does not bloat the
// decode/device file.
// ----------------------------------------------------------------------------
module bus_controller #(
    parameter bit  USE_REAL_PS2 = 1'b0,
    parameter int PS2_CLK_HZ   = 50_000_000,
    parameter bit  USE_SDIO_DISK = 1'b0
) (
    input  logic        i_bus_valid,
    output logic        o_bus_ready,
    output logic        o_bus_busy,
    input  logic        i_bus_write_enable,
    input  logic        i_bus_io_access,
    input  logic [31:0] i_bus_address,
    output logic [31:0] o_bus_data_read,
    input  logic [31:0] i_bus_data_write,

    output logic        o_vga_mem_en_w,
    output logic [19:0] o_vga_mem_addr,
    output logic [7:0]  o_vga_mem_data_w,

    output logic        o_vga_io_en_w,
    output logic        o_vga_io_en_r,
    output logic [15:0] o_vga_io_addr,
    output logic [7:0]  o_vga_io_data_w,
    input  logic [7:0]  i_vga_io_data_r,

    output logic [15:0] o_bios_addr,
    input  logic [31:0] i_bios_rdata,

    output logic [16:0] o_ext_bios_addr,
    input  logic [31:0] i_ext_bios_rdata,

    output logic        o_sdram_en,
    output logic        o_sdram_we,
    output logic [23:0] o_sdram_addr_off,
    output logic [31:0] o_sdram_wdata,
    input  logic [31:0] i_sdram_rdata,
    input  logic        i_sdram_ready,
    input  logic        i_sdram_busy,

    output logic        o_ps2_kbd_clk_out,
    output logic        o_ps2_kbd_clk_oe,
    input  logic        i_ps2_kbd_clk_in,
    output logic        o_ps2_kbd_dat_out,
    output logic        o_ps2_kbd_dat_oe,
    input  logic        i_ps2_kbd_dat_in,
    output logic        o_ps2_aux_clk_out,
    output logic        o_ps2_aux_clk_oe,
    input  logic        i_ps2_aux_clk_in,
    output logic        o_ps2_aux_dat_out,
    output logic        o_ps2_aux_dat_oe,
    input  logic        i_ps2_aux_dat_in,

    output logic        o_sdio_clk,
    output logic        o_sdio_cmd_o,
    output logic        o_sdio_cmd_oe,
    input  logic        i_sdio_cmd_i,
    output logic [3:0]  o_sdio_dat_o,
    output logic        o_sdio_dat_oe,
    input  logic [3:0]  i_sdio_dat_i,

    output logic        o_pic_intr,

    input  logic        i_clock,
    input  logic        i_reset
);
    bus_devices #(
        .USE_REAL_PS2 ( USE_REAL_PS2 ),
        .PS2_CLK_HZ   ( PS2_CLK_HZ ),
        .USE_SDIO_DISK ( USE_SDIO_DISK )
    ) u_devices (
        .i_bus_valid        ( i_bus_valid ),
        .o_bus_ready        ( o_bus_ready ),
        .o_bus_busy         ( o_bus_busy ),
        .i_bus_write_enable ( i_bus_write_enable ),
        .i_bus_io_access    ( i_bus_io_access ),
        .i_bus_address      ( i_bus_address ),
        .o_bus_data_read    ( o_bus_data_read ),
        .i_bus_data_write   ( i_bus_data_write ),
        .o_vga_mem_en_w     ( o_vga_mem_en_w ),
        .o_vga_mem_addr     ( o_vga_mem_addr ),
        .o_vga_mem_data_w   ( o_vga_mem_data_w ),
        .o_vga_io_en_w      ( o_vga_io_en_w ),
        .o_vga_io_en_r      ( o_vga_io_en_r ),
        .o_vga_io_addr      ( o_vga_io_addr ),
        .o_vga_io_data_w    ( o_vga_io_data_w ),
        .i_vga_io_data_r    ( i_vga_io_data_r ),
        .o_bios_addr        ( o_bios_addr ),
        .i_bios_rdata       ( i_bios_rdata ),
        .o_ext_bios_addr    ( o_ext_bios_addr ),
        .i_ext_bios_rdata   ( i_ext_bios_rdata ),
        .o_sdram_en         ( o_sdram_en ),
        .o_sdram_we         ( o_sdram_we ),
        .o_sdram_addr_off   ( o_sdram_addr_off ),
        .o_sdram_wdata      ( o_sdram_wdata ),
        .i_sdram_rdata      ( i_sdram_rdata ),
        .i_sdram_ready      ( i_sdram_ready ),
        .i_sdram_busy       ( i_sdram_busy ),
        .o_ps2_kbd_clk_out  ( o_ps2_kbd_clk_out ),
        .o_ps2_kbd_clk_oe   ( o_ps2_kbd_clk_oe ),
        .i_ps2_kbd_clk_in   ( i_ps2_kbd_clk_in ),
        .o_ps2_kbd_dat_out  ( o_ps2_kbd_dat_out ),
        .o_ps2_kbd_dat_oe   ( o_ps2_kbd_dat_oe ),
        .i_ps2_kbd_dat_in   ( i_ps2_kbd_dat_in ),
        .o_ps2_aux_clk_out  ( o_ps2_aux_clk_out ),
        .o_ps2_aux_clk_oe   ( o_ps2_aux_clk_oe ),
        .i_ps2_aux_clk_in   ( i_ps2_aux_clk_in ),
        .o_ps2_aux_dat_out  ( o_ps2_aux_dat_out ),
        .o_ps2_aux_dat_oe   ( o_ps2_aux_dat_oe ),
        .i_ps2_aux_dat_in   ( i_ps2_aux_dat_in ),
        .o_sdio_clk    ( o_sdio_clk ),
        .o_sdio_cmd_o  ( o_sdio_cmd_o ),
        .o_sdio_cmd_oe ( o_sdio_cmd_oe ),
        .i_sdio_cmd_i  ( i_sdio_cmd_i ),
        .o_sdio_dat_o  ( o_sdio_dat_o ),
        .o_sdio_dat_oe ( o_sdio_dat_oe ),
        .i_sdio_dat_i  ( i_sdio_dat_i ),
        .o_pic_intr         ( o_pic_intr ),
        .i_clock            ( i_clock ),
        .i_reset            ( i_reset )
    );
endmodule
