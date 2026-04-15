// ============================================================================
// Minimal SoC: x86_core_top + bus + sys_ram + BIOS ROMs + VGA Graphics Adapter
// ============================================================================

module soc_top (
    input  logic        clock,
    input  logic        reset,
    output logic        o_vga_hsync,
    output logic        o_vga_vsync,
    output logic [3:0]  o_vga_r,
    output logic [3:0]  o_vga_g,
    output logic [3:0]  o_vga_b
);

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

    logic        ram_we;
    logic [19:0] ram_addr;
    logic [31:0] ram_wdata;
    logic [31:0] ram_rdata;

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

    logic        o_halted;

    x86_core_top u_cpu (
        .o_bus_valid        ( bus_valid ),
        .i_bus_ready        ( bus_ready ),
        .i_bus_busy         ( bus_busy ),
        .o_bus_write_enable ( bus_we ),
        .o_bus_io_access    ( bus_io ),
        .o_bus_address      ( bus_addr ),
        .i_bus_data_read    ( bus_rdata ),
        .o_bus_data_write   ( bus_wdata ),
        .i_cr0_we           ( 1'b0 ),
        .i_cr0_wdata        ( 32'h0 ),
        .o_halted           ( o_halted ),
        .i_clock            ( clock ),
        .i_reset            ( reset )
    );

    // PS/2 回读：仿真无外部设备时置 1（上拉空闲）
    wire ps2_kbd_clk_in = 1'b1;
    wire ps2_kbd_dat_in = 1'b1;
    wire ps2_aux_clk_in = 1'b1;
    wire ps2_aux_dat_in = 1'b1;

    bus u_bus (
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
        .o_ram_we           ( ram_we ),
        .o_ram_addr         ( ram_addr ),
        .o_ram_wdata        ( ram_wdata ),
        .i_ram_rdata        ( ram_rdata ),
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
        .o_ps2_kbd_clk_out ( ),
        .o_ps2_kbd_clk_oe  ( ),
        .i_ps2_kbd_clk_in  ( ps2_kbd_clk_in ),
        .o_ps2_kbd_dat_out ( ),
        .o_ps2_kbd_dat_oe  ( ),
        .i_ps2_kbd_dat_in  ( ps2_kbd_dat_in ),
        .o_ps2_aux_clk_out ( ),
        .o_ps2_aux_clk_oe  ( ),
        .i_ps2_aux_clk_in  ( ps2_aux_clk_in ),
        .o_ps2_aux_dat_out ( ),
        .o_ps2_aux_dat_oe  ( ),
        .i_ps2_aux_dat_in  ( ps2_aux_dat_in ),
        .i_clock            ( clock ),
        .i_reset            ( reset )
    );

    sdram_controller #(
        .MEM_WORDS_LG2 ( 18 ),
        .LATENCY       ( 5 )
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
        .o_sdram_dq_oe  ( sdr_phy_dq_oe )
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

    sys_ram u_main_ram (
        .clock     ( clock ),
        .reset     ( reset ),
        .we        ( ram_we ),
        .byte_addr ( ram_addr ),
        .wdata     ( ram_wdata ),
        .rdata     ( ram_rdata )
    );

    // 系统 BIOS 0xF0000–0xFFFFF + 扩展 ROM 0xC0000–0xDFFFF → 后端 EEPROM（镜像：128KB 扩展 + 64KB 系统）
    // 使用 24LC32（4KiB）做后端：地址在 192KiB 线性镜像上取模映射到 4KiB
    pc_bios_24lc32 #(
        .INSTALL_DEFAULT_BOOTSTUB ( 1'b1 ),
        .ENABLE_PLUSARGS          ( 1'b0 ),
        .INIT_FILE                ( "" )
    ) u_bios_24lc32 (
        .clock               ( clock ),
        .reset               ( reset ),
        .i_sys_bios_byte_off ( bios_addr ),
        .i_ext_bios_byte_off ( ext_bios_addr ),
        .o_sys_bios_rdata    ( bios_rdata ),
        .o_ext_bios_rdata    ( ext_bios_rdata )
    );

endmodule
