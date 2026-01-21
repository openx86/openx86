`timescale 1ns/1ps

module x86_reg_debug_tb;

    logic         write_enable;
    logic [2:0]   write_index;
    logic [31:0]  write_data;
    logic [31:0]  DR [0:7];
    logic         clock;
    logic         reset;

    initial clock = 0;
    always #5 clock = ~clock;

    x86_reg_debug dut (
        .write_enable(write_enable),
        .write_index (write_index),
        .write_data  (write_data),
        .DR          (DR),
        .clock       (clock),
        .reset       (reset)
    );

    initial begin
        write_enable = 0;
        write_index  = '0;
        write_data   = '0;
        reset        = 1;
        repeat (2) @(posedge clock);
        reset = 0;

        // write DR0..DR3
        repeat (4) begin : wr_loop
            @(posedge clock);
            write_enable = 1;
            write_index  = wr_loop.iteration[2:0];
            write_data   = 32'hA5A5_0000 + wr_loop.iteration;
        end

        @(posedge clock);
        write_enable = 0;

        @(posedge clock);
        $display("[x86_reg_debug] DR0=%h DR1=%h DR2=%h DR3=%h",
                 DR[0], DR[1], DR[2], DR[3]);

        #20;
        $finish;
    end

endmodule

