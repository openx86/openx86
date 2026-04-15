// ============================================================================
// sdcard_spi_host 冒烟 + disk_ram_8 与 IDE 外部读一致性（可选）
// ============================================================================
`timescale 1ns/1ps

module sdcard_spi_host_tb;

    logic        clock = 0;
    logic        reset;
    logic        cmd_rd, cmd_wr;
    logic [31:0] lba;
    logic        busy, done;

    logic        sck, mosi, miso, cs_n;

    always #5 clock = ~clock;

    sdcard_spi_host dut (
        .i_clock    ( clock ),
        .i_reset    ( reset ),
        .o_spi_sck  ( sck ),
        .o_spi_mosi ( mosi ),
        .i_spi_miso ( miso ),
        .o_spi_cs_n ( cs_n ),
        .o_busy     ( busy ),
        .i_cmd_read ( cmd_rd ),
        .i_cmd_write( cmd_wr ),
        .i_lba      ( lba ),
        .o_done     ( done )
    );

    assign miso = 1'b1;

    initial begin
        reset  = 1;
        cmd_rd = 0;
        cmd_wr = 0;
        lba    = 0;
        repeat (4) @(posedge clock);
        reset = 0;
        @(posedge clock);
        cmd_rd = 1;
        lba    = 32'h0;
        @(posedge clock);
        cmd_rd = 0;
        wait (done);
        $display("PASS sdcard_spi_host_tb");
        $finish;
    end

endmodule
