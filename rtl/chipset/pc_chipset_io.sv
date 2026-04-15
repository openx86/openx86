// ============================================================================
// IBM PC/AT 主板 I/O 聚合 — 单入口 valid/ready 字节访问
// 优先级（同址冲突时，序号小者优先）：DMA > PIC主 > PIC从 > PIT > 8042 > RTC > IDE
// PIT CH0 out -> PIC 主片 IR0；PIC 从片 o_intr -> PIC 主片 IR2
// IDE 使用 disk_ram_8 作为盘映像（与 SD 卡模型共享，见 rtl/peripheral/sdcard）
// COM1（0x3F8–0x3FF）、LPT1（0x378–0x37F）
// 优先级：… > RTC > COM > LPT > IDE
// ============================================================================

module pc_chipset_io (
    input  logic        i_clock,
    input  logic        i_reset,
    input  logic        i_io_valid,
    input  logic        i_io_we,
    input  logic [15:0] i_io_addr,
    input  logic [7:0]  i_io_wdata,
    output logic [7:0]  o_io_rdata,
    output logic        o_io_hit,
    output logic        o_io_ready,
    input  logic        i_ps2_kbd_push,
    input  logic [7:0]  i_ps2_kbd_data,
    input  logic        i_ps2_aux_push,
    input  logic [7:0]  i_ps2_aux_data,
    input  logic [7:0]  i_pic_slave_ir,
    output logic        o_pic_master_intr,
    output logic        o_pic_slave_intr,
    output logic        o_pit_out0
);

    localparam int DISK_IMAGE_BYTES = 512 * 2048;
    localparam int DISK_SECTOR_CNT  = DISK_IMAGE_BYTES / 512;

    assign o_io_ready = 1'b1;

    logic [31:0] ide_disk_raddr;
    logic [7:0]  ide_disk_rdata;
    logic [7:0]  disk_rdata_b_unused;

    disk_ram_8 #(
        .BYTE_DEPTH ( DISK_IMAGE_BYTES )
    ) u_disk_image (
        .i_clock   ( i_clock ),
        .i_reset   ( i_reset ),
        .i_we      ( 1'b0 ),
        .i_waddr   ( 32'h0 ),
        .i_wdata   ( 8'h0 ),
        .i_raddr_a ( ide_disk_raddr ),
        .i_raddr_b ( 32'h0 ),
        .o_rdata_a ( ide_disk_rdata ),
        .o_rdata_b ( disk_rdata_b_unused )
    );

    logic [7:0] r_dma, r_pic_m, r_pic_s, r_pit, r_ps2, r_rtc, r_com, r_lpt, r_ide;
    logic       h_dma, h_pic_m, h_pic_s, h_pit, h_ps2, h_rtc, h_com, h_lpt, h_ide;

    logic       pit_out0;
    logic       intr_m, intr_s;

    logic [7:0] ir_m;
    assign ir_m[0]    = pit_out0;
    assign ir_m[1]    = 1'b0;
    assign ir_m[2]    = intr_s;
    assign ir_m[7:3]  = 5'b0;

    assign o_pit_out0   = pit_out0;
    assign o_pic_master_intr = intr_m;
    assign o_pic_slave_intr  = intr_s;

    i8237_dma u_dma (
        .i_clock    ( i_clock ),
        .i_reset    ( i_reset ),
        .i_io_valid ( i_io_valid ),
        .i_io_we    ( i_io_we ),
        .i_io_addr  ( i_io_addr ),
        .i_io_wdata ( i_io_wdata ),
        .o_io_rdata ( r_dma ),
        .o_io_hit   ( h_dma )
    );

    i8259_pic #(
        .PORT_BASE ( 16'h0020 )
    ) u_pic_m (
        .i_clock    ( i_clock ),
        .i_reset    ( i_reset ),
        .i_io_valid ( i_io_valid ),
        .i_io_we    ( i_io_we ),
        .i_io_addr  ( i_io_addr ),
        .i_io_wdata ( i_io_wdata ),
        .o_io_rdata ( r_pic_m ),
        .o_io_hit   ( h_pic_m ),
        .i_ir       ( ir_m ),
        .o_intr     ( intr_m )
    );

    i8259_pic #(
        .PORT_BASE ( 16'h00A0 )
    ) u_pic_s (
        .i_clock    ( i_clock ),
        .i_reset    ( i_reset ),
        .i_io_valid ( i_io_valid ),
        .i_io_we    ( i_io_we ),
        .i_io_addr  ( i_io_addr ),
        .i_io_wdata ( i_io_wdata ),
        .o_io_rdata ( r_pic_s ),
        .o_io_hit   ( h_pic_s ),
        .i_ir       ( i_pic_slave_ir ),
        .o_intr     ( intr_s )
    );

    logic pit_out1, pit_out2;
    i8254_pit u_pit (
        .i_clock    ( i_clock ),
        .i_reset    ( i_reset ),
        .i_io_valid ( i_io_valid ),
        .i_io_we    ( i_io_we ),
        .i_io_addr  ( i_io_addr ),
        .i_io_wdata ( i_io_wdata ),
        .o_io_rdata ( r_pit ),
        .o_io_hit   ( h_pit ),
        .o_out0     ( pit_out0 ),
        .o_out1     ( pit_out1 ),
        .o_out2     ( pit_out2 )
    );

    ps2_i8042 u_ps2 (
        .i_clock     ( i_clock ),
        .i_reset     ( i_reset ),
        .i_io_valid  ( i_io_valid ),
        .i_io_we     ( i_io_we ),
        .i_io_addr   ( i_io_addr ),
        .i_io_wdata  ( i_io_wdata ),
        .o_io_rdata  ( r_ps2 ),
        .o_io_hit    ( h_ps2 ),
        .i_kbd_push  ( i_ps2_kbd_push ),
        .i_kbd_data  ( i_ps2_kbd_data ),
        .i_aux_push  ( i_ps2_aux_push ),
        .i_aux_data  ( i_ps2_aux_data )
    );

    rtc_mc146818 u_rtc (
        .i_clock    ( i_clock ),
        .i_reset    ( i_reset ),
        .i_io_valid ( i_io_valid ),
        .i_io_we    ( i_io_we ),
        .i_io_addr  ( i_io_addr ),
        .i_io_wdata ( i_io_wdata ),
        .o_io_rdata ( r_rtc ),
        .o_io_hit   ( h_rtc )
    );

    com_ns16550 u_com1 (
        .i_clock    ( i_clock ),
        .i_reset    ( i_reset ),
        .i_io_valid ( i_io_valid ),
        .i_io_we    ( i_io_we ),
        .i_io_addr  ( i_io_addr ),
        .i_io_wdata ( i_io_wdata ),
        .o_io_rdata ( r_com ),
        .o_io_hit   ( h_com ),
        .i_rx_push  ( 1'b0 ),
        .i_rx_data  ( 8'h0 )
    );

    lpt_centronics u_lpt1 (
        .i_clock    ( i_clock ),
        .i_reset    ( i_reset ),
        .i_io_valid ( i_io_valid ),
        .i_io_we    ( i_io_we ),
        .i_io_addr  ( i_io_addr ),
        .i_io_wdata ( i_io_wdata ),
        .o_io_rdata ( r_lpt ),
        .o_io_hit   ( h_lpt )
    );

    ide_ata_pio #(
        .SECTOR_BYTES        ( 512 ),
        .SECTOR_COUNT        ( DISK_SECTOR_CNT ),
        .USE_INTERNAL_DISK_MEM ( 1'b0 )
    ) u_ide (
        .i_clock       ( i_clock ),
        .i_reset       ( i_reset ),
        .i_io_valid    ( i_io_valid ),
        .i_io_we       ( i_io_we ),
        .i_io_addr     ( i_io_addr ),
        .i_io_wdata    ( i_io_wdata ),
        .o_io_rdata    ( r_ide ),
        .o_io_hit      ( h_ide ),
        .o_disk_raddr  ( ide_disk_raddr ),
        .i_disk_rdata  ( ide_disk_rdata )
    );

    always_comb begin
        o_io_hit   = 1'b0;
        o_io_rdata = 8'hFF;
        if (h_dma) begin
            o_io_hit   = 1'b1;
            o_io_rdata = r_dma;
        end else if (h_pic_m) begin
            o_io_hit   = 1'b1;
            o_io_rdata = r_pic_m;
        end else if (h_pic_s) begin
            o_io_hit   = 1'b1;
            o_io_rdata = r_pic_s;
        end else if (h_pit) begin
            o_io_hit   = 1'b1;
            o_io_rdata = r_pit;
        end else if (h_ps2) begin
            o_io_hit   = 1'b1;
            o_io_rdata = r_ps2;
        end else if (h_rtc) begin
            o_io_hit   = 1'b1;
            o_io_rdata = r_rtc;
        end else if (h_com) begin
            o_io_hit   = 1'b1;
            o_io_rdata = r_com;
        end else if (h_lpt) begin
            o_io_hit   = 1'b1;
            o_io_rdata = r_lpt;
        end else if (h_ide) begin
            o_io_hit   = 1'b1;
            o_io_rdata = r_ide;
        end
    end

endmodule
