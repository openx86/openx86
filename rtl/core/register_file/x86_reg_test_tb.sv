`timescale 1ns/1ps

module x86_reg_test_tb;

    logic         write_enable;
    logic [2:0]   write_index;
    logic [31:0]  write_data;
    logic [31:0]  TR [0:7];
    logic         clock;
    logic         reset;

    initial clock = 0;
    always #5 clock = ~clock;

    x86_reg_test dut (
        .write_enable(write_enable),
        .write_index (write_index),
        .write_data  (write_data),
        .TR          (TR),
        .clock       (clock),
        .reset       (reset)
    );

    integer i;

    initial begin
        write_enable = 0;
        write_index  = '0;
        write_data   = '0;
        reset        = 1;
        repeat (2) @(posedge clock);
        reset = 0;

        for (i = 0; i < 4; i = i + 1) begin
            @(posedge clock);
            write_enable = 1;
            write_index  = i[2:0];
            write_data   = 32'hDEAD_0000 + i;
        end

        @(posedge clock);
        write_enable = 0;

        @(posedge clock);
        $display("[x86_reg_test] TR0=%h TR1=%h TR2=%h TR3=%h",
                 TR[0], TR[1], TR[2], TR[3]);

        #20;
        $finish;
    end

endmodule

