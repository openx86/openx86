// ============================================================================
// sys_ram testbench
// ============================================================================

module ram_tb;

    logic        clock;
    logic        reset;
    logic        we;
    logic [19:0] byte_addr;
    logic [31:0] wdata;
    logic [31:0] rdata;

    sys_ram dut (
        .clock     ( clock ),
        .reset     ( reset ),
        .we        ( we ),
        .byte_addr ( byte_addr ),
        .wdata     ( wdata ),
        .rdata     ( rdata )
    );

    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    initial begin
        reset = 1'b1;
        we = 1'b0;
        byte_addr = 20'h0;
        wdata = 32'h0;
        @(posedge clock);
        @(posedge clock);
        reset = 1'b0;

        // write word at byte 0 -> index 0
        @(posedge clock);
        we = 1'b1;
        byte_addr = 20'h00;
        wdata = 32'hDEAD_BEEF;
        @(posedge clock);
        we        = 1'b0;
        byte_addr = 20'h00;

        // read pipeline: one cycle after WE deassert / addr stable
        @(posedge clock);
        if (rdata !== 32'hDEAD_BEEF) begin
            $display("ram_tb FAIL expect 0xdeadbeef got %h", rdata);
            $finish;
        end

        $display("ram_tb PASS");
        $finish;
    end

endmodule
