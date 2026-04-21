/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements openx86_soc_top.
*/
// ============================================================================
// 最小 SoC：i486_cpu 仅接 bus_controller；SDRAM/ROM/VGA/chipset 由总线控制器译码驱动
// ============================================================================

module openx86_soc_top #(
    parameter bit P_USE_SDIO_DISK = 1'b0  // 1：IDE 走 SDIO 盘体；0：空闲/占位
) (

    // ------------------------------------------------------------------------
    // VGA：RGB444 + 同步
    // ------------------------------------------------------------------------
    output logic         o_vga_hsync, // 行同步
    output logic         o_vga_vsync, // 场同步
    output logic [ 3: 0] o_vga_r,    // 红基色
    output logic [ 3: 0] o_vga_g,    // 输出信号
    output logic [ 3: 0] o_vga_b,    // 输出信号

    // ------------------------------------------------------------------------
    // PS/2：开漏；每线为（输出数据、输出使能、总线回读）
    // ------------------------------------------------------------------------
    output logic         o_ps2_kbd_clk_out, // 时钟信号
    output logic         o_ps2_kbd_clk_oe,  // 时钟信号
    input  logic          i_ps2_kbd_clk_in,  // 时钟信号
    output logic         o_ps2_kbd_dat_out, // 输出信号
    output logic         o_ps2_kbd_dat_oe,  // 输出信号
    input  logic          i_ps2_kbd_dat_in,  // 输入信号
    output logic         o_ps2_aux_clk_out, // 时钟信号
    output logic         o_ps2_aux_clk_oe,  // 时钟信号
    input  logic          i_ps2_aux_clk_in,  // 时钟信号
    output logic         o_ps2_aux_dat_out, // 输出信号
    output logic         o_ps2_aux_dat_oe,  // 输出信号
    input  logic          i_ps2_aux_dat_in,  // 输入信号

    // ------------------------------------------------------------------------
    // SDIO / SD 4-bit（IDE 通道；PHY 在片内）
    // ------------------------------------------------------------------------
    output logic         o_sdio_clk,    // SD 时钟至卡
    inout  logic         io_sdio_cmd,   // CMD 双向
    inout  logic [ 3: 0] io_sdio_dat,  // DAT[3: 0] 双向

    // ------------------------------------------------------------------------
    // SDRAM 物理接口（x16 器件）
    // ------------------------------------------------------------------------
    output logic         o_sdram_clk,  // SDRAM 时钟输出
    output logic         o_sdram_cke,  // 时钟使能
    output logic         o_sdram_cs_n, // 片选
    output logic         o_sdram_ras_n, // 行地址选通
    output logic         o_sdram_cas_n, // 列地址选通
    output logic         o_sdram_we_n, // 写使能
    output logic [ 1: 0] o_sdram_ba,   // Bank 地址
    output logic [12: 0] o_sdram_a,    // 地址/命令复用
    output logic [ 1: 0] o_sdram_dqm,  // 字节掩码
    inout  logic [15: 0] io_sdram_dq,  // 数据总线

    // ------------------------------------------------------------------------
    // 板级时钟与复位
    // ------------------------------------------------------------------------
    // clk：外部 50MHz 振荡器
    // rst_n：低有效复位（按键/POR）
    input  logic          clk,          // 系统时钟
    input  logic          rst_n         // 异步低有效复位
);

    logic        bus_valid;      // CPU 总线事务有效
    logic        bus_ready;      // 从设备就绪
    logic        bus_busy;       // 多周期外设忙
    logic        bus_we;         // 写使能
    logic        bus_io;         // I/O 访问
    logic [31: 0] bus_addr;      // 地址
    logic [31: 0] bus_rdata;     // 读数据
    logic [31: 0] bus_wdata;     // 写数据

    logic        vga_mem_en_w;   // VGA VRAM 写字节使能
    logic [19: 0] vga_mem_addr;  // VRAM 字节地址
    logic [ 7: 0]  vga_mem_data_w;
    logic        vga_io_en_w;    // VGA I/O 写使能
    logic        vga_io_en_r;    // VGA I/O 读使能
    logic [15: 0] vga_io_addr;   // VGA I/O 地址
    logic [ 7: 0]  vga_io_data_w;
    logic [ 7: 0]  vga_io_data_r;

    logic [15: 0] bios_addr;     // 系统 BIOS 窗口内字偏移→字节
    logic [31: 0] bios_rdata;
    logic [16: 0] ext_bios_addr; // 扩展 ROM 窗口地址
    logic [31: 0] ext_bios_rdata;

    logic        o_sdram_en;     // SDRAM 控制器访问请求
    logic        o_sdram_we;
    logic [23: 0] o_sdram_addr_off;
    logic [31: 0] o_sdram_wdata;
    logic [31: 0] i_sdram_rdata;
    logic        i_sdram_ready;
    logic        i_sdram_busy;

    logic        sdram_phy_cs_n, sdram_phy_ras_n, sdram_phy_cas_n, sdram_phy_we_n;
    logic [ 1: 0]  sdram_phy_ba;
    logic [12: 0] sdram_phy_a;
    logic [ 1: 0]  sdram_phy_dqm;
    logic [15: 0] sdram_phy_dq_out;  // DQ 输出数据
    logic        sdram_phy_dq_oe;    // DQ 输出使能
    logic        sdram_phy_clk, sdram_phy_cke;

    /* verilator lint_off UNUSEDSIGNAL */
    logic        pic_intr;       // 主 PIC INTR → CPU（待接 CPU 中断输入）
    /* verilator lint_on UNUSEDSIGNAL */

    logic        b_sd_nat_clk;   // ide→native 主机时钟
    logic        b_sd_cmd_o;
    logic        b_sd_cmd_oe;
    logic        b_nat_cmd_i;
    logic [ 3: 0]  b_sd_dat_o;
    logic        b_sd_dat_oe;
    logic [ 3: 0]  b_nat_dat_i;
    logic        sdio_cmd_out;  // PHY 侧 CMD 驱动
    logic        sdio_cmd_oe;
    logic        sdio_cmd_in;
    logic [ 3: 0]  sdio_dat_out;
    logic        sdio_dat_oe;
    logic [ 3: 0]  sdio_dat_in;

    // W686 CPU 与总线控制器之间的主事务通道
    i486_cpu u_cpu (
        .bus_vaild        ( bus_valid ),
        .bus_ready        ( bus_ready ),
        .bus_busy         ( bus_busy ),
        .bus_write_enable ( bus_we ),
        .bus_io_access    ( bus_io ),
        .bus_address      ( bus_addr ),
        .bus_read_data    ( bus_rdata ),
        .bus_write_data   ( bus_wdata ),
        .clk            ( clk ),
        .rst_n            ( rst_n )
    );

    // SDRAM DQ：仅当控制器 OE 时驱动，否则高阻。
    assign io_sdram_dq = sdram_phy_dq_oe ? sdram_phy_dq_out : 16'hZZZZ;

    // SDRAM 命令/地址引脚直连板级封装
    assign o_sdram_clk   = sdram_phy_clk;
    assign o_sdram_cke   = sdram_phy_cke;
    assign o_sdram_cs_n  = sdram_phy_cs_n;
    assign o_sdram_ras_n = sdram_phy_ras_n;
    assign o_sdram_cas_n = sdram_phy_cas_n;
    assign o_sdram_we_n  = sdram_phy_we_n;
    assign o_sdram_ba    = sdram_phy_ba;
    assign o_sdram_a     = sdram_phy_a;
    assign o_sdram_dqm   = sdram_phy_dqm;

    // SDIO CMD/DAT：顶层三态以满足综合对 inout 的结构要求
    assign io_sdio_cmd = sdio_cmd_oe ? sdio_cmd_out : 1'bz;
    assign sdio_cmd_in = io_sdio_cmd;
    assign io_sdio_dat = sdio_dat_oe ? sdio_dat_out : 4'bzzzz;
    assign sdio_dat_in = io_sdio_dat;

    bus_controller #(
        .P_USE_SDIO_DISK ( P_USE_SDIO_DISK )
    ) u_bus_controller (
        .i_bus_valid        ( bus_valid ),
        .o_bus_ready        ( bus_ready ),
        .o_bus_busy         ( bus_busy ),
        .i_bus_write_enable ( bus_we ),
        .i_bus_io_access    ( bus_io ),
        .i_bus_address      ( bus_addr ),
        .o_bus_data_read    ( bus_rdata ),
        .i_bus_data_write   ( bus_wdata ),
        .o_vga_mem_en_w     ( vga_mem_en_w ),
        .o_vga_mem_addr     ( vga_mem_addr ),
        .o_vga_mem_data_w   ( vga_mem_data_w ),
        .o_vga_io_en_w      ( vga_io_en_w ),
        .o_vga_io_en_r      ( vga_io_en_r ),
        .o_vga_io_addr      ( vga_io_addr ),
        .o_vga_io_data_w    ( vga_io_data_w ),
        .i_vga_io_data_r    ( vga_io_data_r ),
        .o_bios_addr        ( bios_addr ),
        .i_bios_rdata       ( bios_rdata ),
        .o_ext_bios_addr    ( ext_bios_addr ),
        .i_ext_bios_rdata   ( ext_bios_rdata ),
        .o_sdram_en         ( o_sdram_en ),
        .o_sdram_we         ( o_sdram_we ),
        .o_sdram_addr_off   ( o_sdram_addr_off ),
        .o_sdram_wdata      ( o_sdram_wdata ),
        .i_sdram_rdata      ( i_sdram_rdata ),
        .i_sdram_ready      ( i_sdram_ready ),
        .i_sdram_busy       ( i_sdram_busy ),
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
        .i_ps2_aux_dat_in  ( i_ps2_aux_dat_in ),
        .o_sdio_clk    ( b_sd_nat_clk ),
        .o_sdio_cmd_o  ( b_sd_cmd_o ),
        .o_sdio_cmd_oe ( b_sd_cmd_oe ),
        .i_sdio_cmd_i  ( b_nat_cmd_i ),
        .o_sdio_dat_o  ( b_sd_dat_o ),
        .o_sdio_dat_oe ( b_sd_dat_oe ),
        .i_sdio_dat_i  ( b_nat_dat_i ),
        .o_pic_intr         ( pic_intr ),
        .clk            ( clk ),
        .rst_n            ( rst_n )
    );

    sdcard_4bit_phy u_sdio_phy (
        .i_sd_clk       ( b_sd_nat_clk ),
        .i_host_cmd_out ( b_sd_cmd_o ),
        .i_host_cmd_oe  ( b_sd_cmd_oe ),
        .o_host_cmd_in  ( b_nat_cmd_i ),
        .i_host_dat_out ( b_sd_dat_o ),
        .i_host_dat_oe  ( b_sd_dat_oe ),
        .o_host_dat_in  ( b_nat_dat_i ),
        .o_sd_clk_pin   ( o_sdio_clk ),
        .o_sd_cmd_out   ( sdio_cmd_out ),
        .o_sd_cmd_oe    ( sdio_cmd_oe ),
        .i_sd_cmd_in    ( sdio_cmd_in ),
        .o_sd_dat_out   ( sdio_dat_out ),
        .o_sd_dat_oe    ( sdio_dat_oe ),
        .i_sd_dat_in    ( sdio_dat_in )
    );

    sdram_controller #(
        .CLK_HZ          ( 50_000_000 ),
        .T_RP            ( 2 ),
        .T_RCD           ( 2 ),
        .T_RFC           ( 7 ),
        .T_MRD           ( 2 ),
        .T_WR            ( 2 ),
        .CAS             ( 2 ),
        .REFRESH_CYCLES  ( 390 )
    ) u_sdram (
        .clk            ( clk ),
        .rst_n          ( rst_n ),
        .i_en           ( o_sdram_en ),
        .i_we           ( o_sdram_we ),
        .i_addr_off     ( o_sdram_addr_off ),
        .i_wdata        ( o_sdram_wdata ),
        .o_rdata        ( i_sdram_rdata ),
        .o_ready        ( i_sdram_ready ),
        .o_busy         ( i_sdram_busy ),
        .o_sdram_clk    ( sdram_phy_clk ),
        .o_sdram_cke    ( sdram_phy_cke ),
        .o_sdram_cs_n   ( sdram_phy_cs_n ),
        .o_sdram_ras_n  ( sdram_phy_ras_n ),
        .o_sdram_cas_n  ( sdram_phy_cas_n ),
        .o_sdram_we_n   ( sdram_phy_we_n ),
        .o_sdram_ba     ( sdram_phy_ba ),
        .o_sdram_a      ( sdram_phy_a ),
        .o_sdram_dqm    ( sdram_phy_dqm ),
        .o_sdram_dq_out ( sdram_phy_dq_out ),
        .o_sdram_dq_oe  ( sdram_phy_dq_oe ),
        .i_sdram_dq_in  ( io_sdram_dq )
    );

    // VGA Graphics Adapter: bus VRAM writes + VGA I/O decode (see rtl/bus_controller.sv)
    vga_graphics_adapter u_vga (
        .io_en_w      ( vga_io_en_w      ),
        .io_en_r      ( vga_io_en_r      ),
        .io_addr      ( vga_io_addr      ),
        .io_data_w    ( vga_io_data_w    ),
        .io_data_r    ( vga_io_data_r    ),
        .mem_en_w     ( vga_mem_en_w     ),
        .mem_addr     ( vga_mem_addr     ),
        .mem_data_w   ( vga_mem_data_w   ),
        .vga_hsync    ( o_vga_hsync      ),
        .vga_vsync    ( o_vga_vsync      ),
        .vga_r        ( o_vga_r          ),
        .vga_g        ( o_vga_g          ),
        .vga_b        ( o_vga_b          ),
        .clk        ( clk            ),
        .rst_n      ( rst_n          )
    );

    // 系统 BIOS 0xF0000–0xFFFFF + 扩展 ROM 0xC0000–0xDFFFF → 后端 EEPROM（镜像：128KB 扩展 + 64KB 系统）
    // 使用 24LC32（4KiB）做后端：地址在 192KiB 线性镜像上取模映射到 4KiB
    chip_pc_bios_eeprom u_bios_24lc32 (
        .clk               ( clk ),
        .rst_n               ( rst_n ),
        .i_sys_bios_byte_off ( bios_addr ),
        .i_ext_bios_byte_off ( ext_bios_addr ),
        .o_sys_bios_rdata    ( bios_rdata ),
        .o_ext_bios_rdata    ( ext_bios_rdata )
    );

endmodule
