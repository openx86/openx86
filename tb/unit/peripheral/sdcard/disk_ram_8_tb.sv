// ============================================================================
// disk_ram_8 + chip_ata_ide（外部盘）读 LBA0
// 文件名匹配 test_all_modules.sh 自动加入 disk_ram_8.sv
// ============================================================================
`timescale 1ns/1ps

module disk_ram_8_tb;

    logic        clock = 0;
    logic        reset;
    logic        io_valid, io_we;
    logic [15:0] io_addr;
    logic [7:0]  io_wdata, io_rdata;

    wire ide_hit = ((io_addr >= 16'h01F0) && (io_addr <= 16'h01F7)) | (io_addr == 16'h03F6);
    wire ide_cs_n = !(io_valid && ide_hit);
    wire ide_wr_n = !(io_valid && io_we && ide_hit);
    wire ide_rd_n = !(io_valid && !io_we && ide_hit);

    logic [31:0] ide_raddr;
    logic [7:0]  disk_a, disk_b;

    always #5 clock = ~clock;

    disk_ram_8 #(.BYTE_DEPTH(512 * 16)) u_disk (
        .i_clock   ( clock ),
        .i_reset   ( reset ),
        .i_we      ( 1'b0 ),
        .i_waddr   ( 32'h0 ),
        .i_wdata   ( 8'h0 ),
        .i_raddr_a ( ide_raddr ),
        .i_raddr_b ( 32'h0 ),
        .o_rdata_a ( disk_a ),
        .o_rdata_b ( disk_b )
    );

    initial begin
        u_disk.mem[0] = 8'hA5;
        u_disk.mem[1] = 8'h5A;
    end

    wire ide_sector_req;
    chip_ata_ide #(
        .SECTOR_BYTES(512),
        .SECTOR_COUNT(16),
        .USE_INTERNAL_DISK_MEM(1'b0),
        .USE_ASYNC_DISK(1'b0)
    ) u_ide (
        .i_clock             ( clock ),
        .i_reset             ( reset ),
        .i_cs_n              ( ide_cs_n ),
        .i_rd_n              ( ide_rd_n ),
        .i_wr_n              ( ide_wr_n ),
        .i_addr              ( io_addr ),
        .i_d                 ( io_wdata ),
        .o_d                 ( io_rdata ),
        .o_disk_raddr        ( ide_raddr ),
        .i_disk_rdata        ( disk_a ),
        .i_disk_sector_ready ( 1'b0 ),
        .o_disk_sector_req   ( ide_sector_req )
    );

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
        reset = 1;
        io_valid = 0;
        repeat (4) @(posedge clock);
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
            $display("FAIL disk_ram+ide expect A5 got %h", rb);
        else
            $display("PASS disk_ram_8_tb");
        $finish;
    end

endmodule
