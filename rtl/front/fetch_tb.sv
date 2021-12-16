// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: fetch_tb
// create at: 2021-12-17 01:23:49
// description: test fetch module

`timescale 1ns/1ns
module fetch_tb #(
    // parameters
) (
    // ports
);

logic        bus_read_vaild;
logic        bus_read_ready;
logic [31:0] bus_read_address;
logic [31:0] bus_read_data;
logic [31:0] program_counter;
logic        program_counter_valid;
logic [31:0] instruction;
logic        instruction_ready;
logic        clock, reset;

fetch fetch_inst (
    .bus_read_vaild ( bus_read_vaild ),
    .bus_read_ready ( bus_read_ready ),
    .bus_read_address ( bus_read_address ),
    .bus_read_data ( bus_read_data ),
    .program_counter ( program_counter ),
    .program_counter_valid ( program_counter_valid ),
    .instruction ( instruction ),
    .instruction_ready ( instruction_ready ),
    .clock ( clock ),
    .reset ( reset )
);

always #1 clock = ~clock;

initial begin
    bus_read_ready = 0;
    bus_read_data = 0;
    program_counter = 0;
    program_counter_valid = 0;
    clock = 0;
    reset = 1;
    #2;
    reset = 0;

    program_counter = 32'h0000_0020;
    program_counter_valid = 1;
    $display("%t: test fetch instruction: program_counter=%h", $time, program_counter);
    #4
    program_counter_valid = 0;

    $monitor("%t: instruction=%h, instruction_ready=%h", $time, instruction, instruction_ready);
    $monitor("%t: bus_read_vaild=%h, bus_read_address=%h", $time, bus_read_vaild, bus_read_address);

    #8;
    bus_read_ready = 1;
    bus_read_data = 32'h0001_1011;

    #64;

    $stop();
end

endmodule
