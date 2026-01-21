`timescale 1ns/1ps

module x86_reg_instruction_point_tb;

    logic        write_enable;
    logic [31:0] write_data;
    logic [15:0] IP;
    logic [31:0] EIP;
    logic        clock;
    logic        reset;

    initial clock = 0;
    always #5 clock = ~clock;

    x86_reg_instruction_point dut (
        .write_enable(write_enable),
        .write_data  (write_data),
        .IP          (IP),
        .EIP         (EIP),
        .clock       (clock),
        .reset       (reset)
    );

    initial begin
        write_enable = 0;
        write_data   = '0;
        reset        = 1;
        repeat (2) @(posedge clock);
        reset = 0;

        // write new instruction pointer
        @(posedge clock);
        write_enable = 1;
        write_data   = 32'h0000_2000;

        @(posedge clock);
        write_enable = 0;

        @(posedge clock);
        $display("[x86_reg_instruction_point] IP=%h EIP=%h", IP, EIP);

        #20;
        $finish;
    end

endmodule

