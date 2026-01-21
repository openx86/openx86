`timescale 1ns/1ps

module x86_reg_segment_tb;

    logic        write_enable;
    logic [2:0]  write_index;
    logic [15:0] write_selector;
    logic [63:0] write_descriptor;
    logic [15:0] segment_selector [0:5];
    logic [63:0] descriptor_cache [0:5];
    logic        clock;
    logic        reset;

    initial clock = 0;
    always #5 clock = ~clock;

    x86_reg_segment dut (
        .write_enable    (write_enable),
        .write_index     (write_index),
        .write_selector  (write_selector),
        .write_descriptor(write_descriptor),
        .segment_selector(segment_selector),
        .descriptor_cache(descriptor_cache),
        .clock           (clock),
        .reset           (reset)
    );

    integer i;

    initial begin
        write_enable     = 0;
        write_index      = '0;
        write_selector   = '0;
        write_descriptor = '0;
        reset            = 1;
        repeat (2) @(posedge clock);
        reset = 0;

        // write few segment entries
        for (i = 0; i < 3; i = i + 1) begin
            @(posedge clock);
            write_enable     = 1;
            write_index      = i[2:0];
            write_selector   = 16'h1000 + i;
            write_descriptor = 64'h00FF_0000_0000_0000 + i;
        end

        @(posedge clock);
        write_enable = 0;

        @(posedge clock);
        $display("[x86_reg_segment] selector0=%h selector1=%h selector2=%h",
                 segment_selector[0], segment_selector[1], segment_selector[2]);

        #20;
        $finish;
    end

endmodule

