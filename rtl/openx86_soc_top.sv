// ============================================================================
// Minimal SoC: w686_cpu 仅接 bus；SDRAM/ROM/VGA/chipset 均由 bus 译码后驱动
// ============================================================================

module openx86_soc_top #(
    parameter bit USE_SDIO_DISK = 1'b0
) (
    // ------------------------------------------------------------------------
    // Board-level clock / reset
    // ------------------------------------------------------------------------
    // i_clk_50m: external 50MHz oscillator
    // i_reset_n: active-low reset input (board push-button / POR)
    input  logic        i_clk_50m,
    input  logic        i_reset_n,

    // ------------------------------------------------------------------------
    // VGA (RGB444 + sync)
    // ------------------------------------------------------------------------
    output logic        o_vga_hsync,
    output logic        o_vga_vsync,
    output logic [3:0]  o_vga_r,
    output logic [3:0]  o_vga_g,
    output logic [3:0]  o_vga_b,

    // ------------------------------------------------------------------------
    // PS/2 ports (open-drain). Each line is (out, oe, in).
    // oe=1 and out=0 means drive-low; oe=0 means Hi-Z (pulled-up externally).
    // ------------------------------------------------------------------------
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

    // ------------------------------------------------------------------------
    // SDIO / SD 4-bit（IDE 盘体经片内主机；PHY 在片内）
    // ------------------------------------------------------------------------
    output logic        o_sdio_clk,
    inout  wire         io_sdio_cmd,
    inout  wire [3:0]   io_sdio_dat,

    // ------------------------------------------------------------------------
    // SDRAM physical interface (16-bit device)
    // ------------------------------------------------------------------------
    output logic        o_sdram_clk,
    output logic        o_sdram_cke,
    output logic        o_sdram_cs_n,
    output logic        o_sdram_ras_n,
    output logic        o_sdram_cas_n,
    output logic        o_sdram_we_n,
    output logic [1:0]  o_sdram_ba,
    output logic [12:0] o_sdram_a,
    output logic [1:0]  o_sdram_dqm,
    inout  wire [15:0]  io_sdram_dq
);

    // Internal clock/reset (keep existing naming for now)
    logic clock;
    logic reset;
    assign clock = i_clk_50m;
    assign reset = ~i_reset_n;

    logic        bus_valid;
    logic        bus_ready;
    logic        bus_busy;
    logic        bus_we;
    logic        bus_io;
    logic [31:0] bus_addr;
    logic [31:0] bus_rdata;
    logic [31:0] bus_wdata;

    logic        vga_mem_en_w;
    logic [19:0] vga_mem_addr;
    logic [7:0]  vga_mem_data_w;
    logic        vga_io_en_w;
    logic        vga_io_en_r;
    logic [15:0] vga_io_addr;
    logic [7:0]  vga_io_data_w;
    logic [7:0]  vga_io_data_r;

    logic [15:0] bios_addr;
    logic [31:0] bios_rdata;
    logic [16:0] ext_bios_addr;
    logic [31:0] ext_bios_rdata;

    logic        o_sdram_en;
    logic        o_sdram_we;
    logic [23:0] o_sdram_addr_off;
    logic [31:0] o_sdram_wdata;
    logic [31:0] i_sdram_rdata;
    logic        i_sdram_ready;
    logic        i_sdram_busy;

    logic        sdr_phy_cs_n, sdr_phy_ras_n, sdr_phy_cas_n, sdr_phy_we_n;
    logic [1:0]  sdr_phy_ba;
    logic [12:0] sdr_phy_a;
    logic [1:0]  sdr_phy_dqm;
    logic [15:0] sdr_phy_dq_out;
    logic        sdr_phy_dq_oe;
    logic        sdr_phy_clk, sdr_phy_cke;
    logic [15:0] sdr_phy_dq_in;

    logic        pic_intr;

    logic        b_sd_nat_clk;
    logic        b_sd_cmd_o;
    logic        b_sd_cmd_oe;
    logic        b_nat_cmd_i;
    logic [3:0]  b_sd_dat_o;
    logic        b_sd_dat_oe;
    logic [3:0]  b_nat_dat_i;

    w686_cpu u_cpu (
        .bus_vaild        ( bus_valid ),
        .bus_ready        ( bus_ready ),
        .bus_busy         ( bus_busy ),
        .bus_write_enable ( bus_we ),
        .bus_io_access    ( bus_io ),
        .bus_address      ( bus_addr ),
        .bus_read_data    ( bus_rdata ),
        .bus_write_data   ( bus_wdata ),
        .clock            ( clock ),
        .reset            ( reset )
    );

    // SDRAM DQ bus (temporary: only driven by controller when sdr_phy_dq_oe=1)
    assign io_sdram_dq = sdr_phy_dq_oe ? sdr_phy_dq_out : 16'hZZZZ;
    assign sdr_phy_dq_in = io_sdram_dq;

    // Export SDRAM command/address pins to board
    assign o_sdram_clk   = sdr_phy_clk;
    assign o_sdram_cke   = sdr_phy_cke;
    assign o_sdram_cs_n  = sdr_phy_cs_n;
    assign o_sdram_ras_n = sdr_phy_ras_n;
    assign o_sdram_cas_n = sdr_phy_cas_n;
    assign o_sdram_we_n  = sdr_phy_we_n;
    assign o_sdram_ba    = sdr_phy_ba;
    assign o_sdram_a     = sdr_phy_a;
    assign o_sdram_dqm   = sdr_phy_dqm;

    bus #(
        .USE_SDIO_DISK ( USE_SDIO_DISK )
    ) u_bus (
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
        .i_clock            ( clock ),
        .i_reset            ( reset )
    );

    sd_4bit_phy u_sdio_phy (
        .i_sd_clk       ( b_sd_nat_clk ),
        .i_host_cmd_out ( b_sd_cmd_o ),
        .i_host_cmd_oe  ( b_sd_cmd_oe ),
        .o_host_cmd_in  ( b_nat_cmd_i ),
        .i_host_dat_out ( b_sd_dat_o ),
        .i_host_dat_oe  ( b_sd_dat_oe ),
        .o_host_dat_in  ( b_nat_dat_i ),
        .o_sd_clk_pin   ( o_sdio_clk ),
        .io_sd_cmd      ( io_sdio_cmd ),
        .io_sd_dat      ( io_sdio_dat )
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
        .clk            ( clock ),
        .rst            ( reset ),
        .i_en           ( o_sdram_en ),
        .i_we           ( o_sdram_we ),
        .i_addr_off     ( o_sdram_addr_off ),
        .i_wdata        ( o_sdram_wdata ),
        .o_rdata        ( i_sdram_rdata ),
        .o_ready        ( i_sdram_ready ),
        .o_busy         ( i_sdram_busy ),
        .o_sdram_clk    ( sdr_phy_clk ),
        .o_sdram_cke    ( sdr_phy_cke ),
        .o_sdram_cs_n   ( sdr_phy_cs_n ),
        .o_sdram_ras_n  ( sdr_phy_ras_n ),
        .o_sdram_cas_n  ( sdr_phy_cas_n ),
        .o_sdram_we_n   ( sdr_phy_we_n ),
        .o_sdram_ba     ( sdr_phy_ba ),
        .o_sdram_a      ( sdr_phy_a ),
        .o_sdram_dqm    ( sdr_phy_dqm ),
        .o_sdram_dq_out ( sdr_phy_dq_out ),
        .o_sdram_dq_oe  ( sdr_phy_dq_oe ),
        .i_sdram_dq_in  ( sdr_phy_dq_in )
    );

    // VGA Graphics Adapter: bus VRAM writes + VGA I/O decode (see rtl/bus.sv)
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
        .clock        ( clock            ),
        .reset        ( reset            )
    );

    // 系统 BIOS 0xF0000–0xFFFFF + 扩展 ROM 0xC0000–0xDFFFF → 后端 EEPROM（镜像：128KB 扩展 + 64KB 系统）
    // 使用 24LC32（4KiB）做后端：地址在 192KiB 线性镜像上取模映射到 4KiB
    chip_pc_bios_eeprom u_bios_24lc32 (
        .clock               ( clock ),
        .reset               ( reset ),
        .i_sys_bios_byte_off ( bios_addr ),
        .i_ext_bios_byte_off ( ext_bios_addr ),
        .o_sys_bios_rdata    ( bios_rdata ),
        .o_ext_bios_rdata    ( ext_bios_rdata )
    );

endmodule
