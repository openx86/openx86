module i8237_dma_tb;

    logic        clock = 0;
    logic        reset;
    logic        io_valid;
    logic        io_we;
    logic [15:0] io_addr;
    logic [7:0]  io_wdata;
    logic [7:0]  io_rdata;
    logic        io_hit;

    i8237_dma dut (
        .i_clock    ( clock ),
        .i_reset    ( reset ),
        .i_io_valid ( io_valid ),
        .i_io_we    ( io_we ),
        .i_io_addr  ( io_addr ),
        .i_io_wdata ( io_wdata ),
        .o_io_rdata ( io_rdata ),
        .o_io_hit   ( io_hit )
    );

    always #5 clock = ~clock;

    initial begin
        reset    = 1;
        io_valid = 0;
        io_we    = 0;
        repeat (3) @(posedge clock);
        reset = 0;
        @(posedge clock);

        io_valid = 1;
        io_we    = 1;
        io_addr  = 16'h0005;
        io_wdata = 8'hAB;
        @(posedge clock);
        io_valid = 0;
        @(posedge clock);

        io_valid = 1;
        io_we    = 0;
        io_addr  = 16'h0005;
        @(posedge clock);
        if (io_rdata !== 8'hAB)
            $display("FAIL dma read");
        else
            $display("PASS dma read");

        $finish;
    end

endmodule
