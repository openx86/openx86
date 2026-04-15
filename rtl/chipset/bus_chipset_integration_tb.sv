// ============================================================================
// bus + chipset 集成读冒烟（I/O 0x0080 DMA 页寄存器）
// ============================================================================
`timescale 1ns/1ps
module bus_chipset_integration_tb;

    logic        clock = 0;
    logic        reset;
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
        .i_clock            ( clock ),
        .i_reset            ( reset )
    );

    assign ram_rdata = 32'h0;
    assign bios_rdata = 32'h0;
    assign ext_bios_rdata = 32'h0;
    assign vga_io_data_r = 8'hFF;

    always #5 clock = ~clock;

    initial begin
        reset     = 1;
        bus_valid = 0;
        bus_we    = 0;
        bus_io    = 0;
        bus_addr  = 0;
        bus_wdata = 0;
        repeat (4) @(posedge clock);
        reset = 0;
        @(posedge clock);

        bus_valid = 1;
        bus_we    = 0;
        bus_io    = 1;
        bus_addr  = 32'h0000_0080;
        @(posedge clock);
        wait (bus_ready);
        if (bus_rdata[7:0] !== 8'h00)
            $display("FAIL bus chipset read %h", bus_rdata);
        else
            $display("PASS bus_chipset_integration");

        bus_valid = 0;
        $finish;
    end

endmodule
