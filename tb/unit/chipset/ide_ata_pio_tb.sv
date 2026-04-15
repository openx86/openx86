// ============================================================================
// TB: ide_ata_pio
// ----------------------------------------------------------------------------
// 目标：验证 IDE ATA PIO 控制器的寄存器访问与数据通路的基础行为。
//
// 该 DUT 通常会通过 `o_disk_raddr/i_disk_rdata` 与磁盘映像 RAM 交互；
// 在系统级仿真中，还可通过 plusargs 指定磁盘镜像（见 pc_chipset_io 的 DISK_*）。
// ============================================================================

module ide_ata_pio_tb;

    logic        clock = 0;
    logic        reset;
    logic        io_valid;
    logic        io_we;
    logic [15:0] io_addr;
    logic [7:0]  io_wdata;
    logic [7:0]  io_rdata;
    logic        io_hit;

    wire [31:0] disk_ra;
    wire disk_sector_req;
    ide_ata_pio dut (
        .i_clock             ( clock ),
        .i_reset             ( reset ),
        .i_io_valid          ( io_valid ),
        .i_io_we             ( io_we ),
        .i_io_addr           ( io_addr ),
        .i_io_wdata          ( io_wdata ),
        .o_io_rdata          ( io_rdata ),
        .o_io_hit            ( io_hit ),
        .o_disk_raddr        ( disk_ra ),
        .i_disk_rdata        ( 8'h0 ),
        .i_disk_sector_ready ( 1'b0 ),
        .o_disk_sector_req   ( disk_sector_req )
    );

    always #5 clock = ~clock;

    task automatic wr(input logic [15:0] a, input logic [7:0] d);
        @(posedge clock);
        io_valid = 1;
        io_we    = 1;
        io_addr  = a;
        io_wdata = d;
        @(posedge clock);
        io_valid = 0;
    endtask

    task automatic rd(input logic [15:0] a, output logic [7:0] d);
        @(posedge clock);
        io_valid = 1;
        io_we    = 0;
        io_addr  = a;
        @(posedge clock);
        d = io_rdata;
        io_valid = 0;
    endtask

    logic [7:0] rb;
    initial begin
        reset    = 1;
        io_valid = 0;
        repeat (3) @(posedge clock);
        reset = 0;
        repeat (2) @(posedge clock);

        wr(16'h01F2, 8'h01);
        wr(16'h01F3, 8'h00);
        wr(16'h01F4, 8'h00);
        wr(16'h01F5, 8'h00);
        wr(16'h01F6, 8'hE0);
        wr(16'h01F7, 8'h20);
        repeat (2) @(posedge clock);
        rd(16'h01F0, rb);
        if (rb !== 8'hA5)
            $display("FAIL ide first byte %h", rb);
        else
            $display("PASS ide pio read");

        $finish;
    end

endmodule
