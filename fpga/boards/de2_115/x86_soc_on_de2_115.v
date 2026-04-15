module x86_soc_on_de2_115 (
	//////// CLOCK //////////
	input          CLOCK_50,
	input          CLOCK2_50,
	input          CLOCK3_50,
	input          ENETCLK_25,

	//////// Sma //////////
	input          SMA_CLKIN,
	output         SMA_CLKOUT,

	//////// LED //////////
	output [ 8:0]  LEDG,
	output [17:0]  LEDR,

	//////// KEY //////////
	input  [3:0]   KEY,

	//////// SW //////////
	input  [17:0]  SW,

	//////// SEG7 //////////
	output [6:0]   HEX0,
	output [6:0]   HEX1,
	output [6:0]   HEX2,
	output [6:0]   HEX3,
	output [6:0]   HEX4,
	output [6:0]   HEX5,
	output [6:0]   HEX6,
	output [6:0]   HEX7,

	//////// LCD //////////
	output         LCD_BLON,
	inout  [7:0]   LCD_DATA,
	output         LCD_EN,
	output         LCD_ON,
	output         LCD_RS,
	output         LCD_RW,

	//////// RS232 //////////
	output         UART_CTS,
	input          UART_RTS,
	input          UART_RXD,
	output         UART_TXD,

	//////// PS2 //////////
	inout          PS2_CLK,
	inout          PS2_DAT,
	inout          PS2_CLK2,
	inout          PS2_DAT2,

	//////// SDCARD //////////
	output         SD_CLK,
	inout          SD_CMD,
	inout  [3:0]   SD_DAT,
	input          SD_WP_N,

	//////// VGA //////////
	output [7:0]   VGA_B,
	output         VGA_BLANK_N,
	output         VGA_CLK,
	output [7:0]   VGA_G,
	output         VGA_HS,
	output [7:0]   VGA_R,
	output         VGA_SYNC_N,
	output         VGA_VS,

	//////// Audio //////////
	input          AUD_ADCDAT,
	inout          AUD_ADCLRCK,
	inout          AUD_BCLK,
	output         AUD_DACDAT,
	inout          AUD_DACLRCK,
	output         AUD_XCK,

	//////// I2C for EEPROM //////////
	output         EEP_I2C_SCLK,
	inout          EEP_I2C_SDAT,

	//////// I2C for Audio and Tv-Decode //////////
	output         I2C_SCLK,
	inout          I2C_SDAT,

	//////// Ethernet 0 //////////
	output         ENET0_GTX_CLK,
	input          ENET0_INT_N,
	output         ENET0_MDC,
	input          ENET0_MDIO,
	output         ENET0_RST_N,
	input          ENET0_RX_CLK,
	input          ENET0_RX_COL,
	input          ENET0_RX_CRS,
	input  [3:0]   ENET0_RX_DATA,
	input          ENET0_RX_DV,
	input          ENET0_RX_ER,
	input          ENET0_TX_CLK,
	output [3:0]   ENET0_TX_DATA,
	output         ENET0_TX_EN,
	output         ENET0_TX_ER,
	input          ENET0_LINK100,

	//////// Ethernet 1 //////////
	output         ENET1_GTX_CLK,
	input          ENET1_INT_N,
	output         ENET1_MDC,
	input          ENET1_MDIO,
	output         ENET1_RST_N,
	input          ENET1_RX_CLK,
	input          ENET1_RX_COL,
	input          ENET1_RX_CRS,
	input [3:0]    ENET1_RX_DATA,
	input          ENET1_RX_DV,
	input          ENET1_RX_ER,
	input          ENET1_TX_CLK,
	output [3:0]   ENET1_TX_DATA,
	output         ENET1_TX_EN,
	output         ENET1_TX_ER,
	input          ENET1_LINK100,

	//////// TV Decoder //////////
	input          TD_CLK27,
	input [7:0]    TD_DATA,
	input          TD_HS,
	output         TD_RESET_N,
	input          TD_VS,

	//////// USB OTG controller //////////
	inout [15:0]  OTG_DATA,
	output [1:0]   OTG_ADDR,
	output         OTG_CS_N,
	output         OTG_WR_N,
	output         OTG_RD_N,
	input          OTG_INT,
	output         OTG_RST_N,

	//////// IR Receiver //////////
	input          IRDA_RXD,

	//////// SDRAM //////////
	output [12:0] DRAM_ADDR,
	output [1:0]   DRAM_BA,
	output         DRAM_CAS_N,
	output         DRAM_CKE,
	output         DRAM_CLK,
	output         DRAM_CS_N,
	inout [31:0]  DRAM_DQ,
	output [3:0]   DRAM_DQM,
	output         DRAM_RAS_N,
	output         DRAM_WE_N,

	//////// SRAM //////////
	output [19:0] SRAM_ADDR,
	output         SRAM_CE_N,
	inout [15:0]  SRAM_DQ,
	output         SRAM_LB_N,
	output         SRAM_OE_N,
	output         SRAM_UB_N,
	output         SRAM_WE_N,

	//////// Flash //////////
	output [22:0] FL_ADDR,
	output         FL_CE_N,
	inout [7:0]    FL_DQ,
	output         FL_OE_N,
	output         FL_RST_N,
	input          FL_RY,
	output         FL_WE_N,
	output         FL_WP_N,

	//////// GPIO //////////
	inout [35:0]  GPIO,

	//////// HSMC (LVDS) //////////
	//	input         HSMC_CLKIN_N1,
	//	input         HSMC_CLKIN_N2,
	input          HSMC_CLKIN_P1,
	input          HSMC_CLKIN_P2,
	input          HSMC_CLKIN0,
	//	output        HSMC_CLKOUT_N1,
	//	output        HSMC_CLKOUT_N2,
	output         HSMC_CLKOUT_P1,
	output         HSMC_CLKOUT_P2,
	output         HSMC_CLKOUT0,
	inout [3:0]    HSMC_D,
	//	input [16:0]  HSMC_RX_D_N,
	input [16:0]  HSMC_RX_D_P,
	//	output [16:0] HSMC_TX_D_N,
	output [16:0] HSMC_TX_D_P,

	//////// EXTEND IO //////////
	inout [6:0]    EX_IO
);

//=======================================================
//  PARAMETER declarations
//=======================================================

//=======================================================
//  openx86 SoC (see src/rtl/openx86_soc_top.sv)
//=======================================================

wire        soc_vga_hs;
wire        soc_vga_vs;
wire [3:0]  soc_vga_r;
wire [3:0]  soc_vga_g;
wire [3:0]  soc_vga_b;

wire        ps2_kbd_clk_out, ps2_kbd_clk_oe;
wire        ps2_kbd_dat_out, ps2_kbd_dat_oe;
wire        ps2_aux_clk_out, ps2_aux_clk_oe;
wire        ps2_aux_dat_out, ps2_aux_dat_oe;

wire        sd_spi_mosi_w;
wire        sd_spi_cs_n_w;

// Approx. 25MHz pixel clock for VGA DAC (640x480 class timing uses ~25MHz)
reg vga_pix_clk_div;
always @(posedge CLOCK_50)
    vga_pix_clk_div <= ~vga_pix_clk_div;

openx86_soc_top u_openx86_soc (
    .i_clk_50m          ( CLOCK_50 ),
    .i_reset_n          ( KEY[0] ),

    .o_vga_hsync        ( soc_vga_hs ),
    .o_vga_vsync        ( soc_vga_vs ),
    .o_vga_r            ( soc_vga_r ),
    .o_vga_g            ( soc_vga_g ),
    .o_vga_b            ( soc_vga_b ),

    .o_ps2_kbd_clk_out  ( ps2_kbd_clk_out ),
    .o_ps2_kbd_clk_oe   ( ps2_kbd_clk_oe ),
    .i_ps2_kbd_clk_in   ( PS2_CLK ),
    .o_ps2_kbd_dat_out  ( ps2_kbd_dat_out ),
    .o_ps2_kbd_dat_oe   ( ps2_kbd_dat_oe ),
    .i_ps2_kbd_dat_in   ( PS2_DAT ),
    .o_ps2_aux_clk_out  ( ps2_aux_clk_out ),
    .o_ps2_aux_clk_oe   ( ps2_aux_clk_oe ),
    .i_ps2_aux_clk_in   ( PS2_CLK2 ),
    .o_ps2_aux_dat_out  ( ps2_aux_dat_out ),
    .o_ps2_aux_dat_oe   ( ps2_aux_dat_oe ),
    .i_ps2_aux_dat_in   ( PS2_DAT2 ),

    .o_sd_spi_sck       ( SD_CLK ),
    .o_sd_spi_mosi      ( sd_spi_mosi_w ),
    .i_sd_spi_miso      ( SD_DAT[0] ),
    .o_sd_spi_cs_n      ( sd_spi_cs_n_w ),

    .o_sdram_clk        ( DRAM_CLK ),
    .o_sdram_cke        ( DRAM_CKE ),
    .o_sdram_cs_n       ( DRAM_CS_N ),
    .o_sdram_ras_n      ( DRAM_RAS_N ),
    .o_sdram_cas_n      ( DRAM_CAS_N ),
    .o_sdram_we_n       ( DRAM_WE_N ),
    .o_sdram_ba         ( DRAM_BA ),
    .o_sdram_a          ( DRAM_ADDR ),
    .o_sdram_dqm        ( DRAM_DQM[1:0] ),
    .io_sdram_dq        ( DRAM_DQ[15:0] )
);

// PS/2: open-drain — drive low only when oe && !out; otherwise Hi-Z
assign PS2_CLK  = (ps2_kbd_clk_oe && !ps2_kbd_clk_out) ? 1'b0 : 1'bz;
assign PS2_DAT  = (ps2_kbd_dat_oe && !ps2_kbd_dat_out) ? 1'b0 : 1'bz;
assign PS2_CLK2 = (ps2_aux_clk_oe && !ps2_aux_clk_out) ? 1'b0 : 1'bz;
assign PS2_DAT2 = (ps2_aux_dat_oe && !ps2_aux_dat_out) ? 1'b0 : 1'bz;

// SD SPI: CMD = MOSI; DAT0 = MISO; DAT3 = CS# (active low)
assign SD_CMD    = sd_spi_mosi_w;
assign SD_DAT[0] = 1'bz;
assign SD_DAT[1] = 1'bz;
assign SD_DAT[2] = 1'bz;
assign SD_DAT[3] = sd_spi_cs_n_w ? 1'bz : 1'b0;

// 32-bit SDRAM: use lower 16 data bits; mask upper 16-bit lane
assign DRAM_DQM[3:2]  = 2'b11;
assign DRAM_DQ[31:16] = {16{1'bz}};

// VGA: RGB444 replicated to 8-bit DAC
assign VGA_HS      = soc_vga_hs;
assign VGA_VS      = soc_vga_vs;
assign VGA_R       = { soc_vga_r, soc_vga_r };
assign VGA_G       = { soc_vga_g, soc_vga_g };
assign VGA_B       = { soc_vga_b, soc_vga_b };
assign VGA_BLANK_N = 1'b1;
assign VGA_SYNC_N  = 1'b1;
assign VGA_CLK     = vga_pix_clk_div;

//=======================================================
//  Unused I/O: safe defaults (SoC does not drive these)
//=======================================================

assign SMA_CLKOUT   = 1'b0;
assign LEDG         = 9'd0;
assign LEDR         = 18'd0;
assign HEX0         = 7'h7f;
assign HEX1         = 7'h7f;
assign HEX2         = 7'h7f;
assign HEX3         = 7'h7f;
assign HEX4         = 7'h7f;
assign HEX5         = 7'h7f;
assign HEX6         = 7'h7f;
assign HEX7         = 7'h7f;

assign LCD_BLON     = 1'b0;
assign LCD_EN       = 1'b0;
assign LCD_ON       = 1'b0;
assign LCD_RS       = 1'b0;
assign LCD_RW       = 1'b0;
assign LCD_DATA     = {8{1'bz}};

assign UART_CTS     = 1'b0;
assign UART_TXD     = 1'b0;

assign AUD_DACDAT   = 1'b0;
assign AUD_XCK      = 1'b0;
assign AUD_ADCLRCK  = 1'bz;
assign AUD_BCLK     = 1'bz;
assign AUD_DACLRCK  = 1'bz;

assign EEP_I2C_SCLK = 1'b0;
assign EEP_I2C_SDAT = 1'bz;
assign I2C_SCLK     = 1'b0;
assign I2C_SDAT     = 1'bz;

assign ENET0_GTX_CLK = 1'b0;
assign ENET0_MDC     = 1'b0;
assign ENET0_RST_N   = 1'b0;
assign ENET0_TX_DATA = 4'd0;
assign ENET0_TX_EN   = 1'b0;
assign ENET0_TX_ER   = 1'b0;

assign ENET1_GTX_CLK = 1'b0;
assign ENET1_MDC     = 1'b0;
assign ENET1_RST_N   = 1'b0;
assign ENET1_TX_DATA = 4'd0;
assign ENET1_TX_EN   = 1'b0;
assign ENET1_TX_ER   = 1'b0;

assign TD_RESET_N   = 1'b0;

assign OTG_ADDR     = 2'd0;
assign OTG_CS_N     = 1'b1;
assign OTG_WR_N     = 1'b1;
assign OTG_RD_N     = 1'b1;
assign OTG_RST_N    = 1'b0;
assign OTG_DATA     = {16{1'bz}};

assign SRAM_ADDR    = 20'd0;
assign SRAM_CE_N    = 1'b1;
assign SRAM_DQ      = {16{1'bz}};
assign SRAM_LB_N    = 1'b1;
assign SRAM_OE_N    = 1'b1;
assign SRAM_UB_N    = 1'b1;
assign SRAM_WE_N    = 1'b1;

assign FL_ADDR      = 23'd0;
assign FL_CE_N      = 1'b1;
assign FL_DQ        = {8{1'bz}};
assign FL_OE_N      = 1'b1;
assign FL_RST_N     = 1'b0;
assign FL_WE_N      = 1'b1;
assign FL_WP_N      = 1'b0;

assign GPIO           = {36{1'bz}};
assign HSMC_CLKOUT_P1 = 1'b0;
assign HSMC_CLKOUT_P2 = 1'b0;
assign HSMC_CLKOUT0   = 1'b0;
assign HSMC_D         = {4{1'bz}};
assign HSMC_TX_D_P    = 17'd0;
assign EX_IO          = {7{1'bz}};

endmodule
