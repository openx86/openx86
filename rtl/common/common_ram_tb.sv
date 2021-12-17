// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: common_ram_tb
// create at: 2021-12-18 01:47:34
// description: test common_ram module

`timescale 1ns/1ns
module common_ram_tb #(
    // parameters
) (
    // ports
);

logic        bus_read_vaild;
logic        bus_read_ready;
logic [ 4:0] bus_read_address;
logic [31:0] bus_read_data;
logic        bus_write_vaild;
logic        bus_write_ready;
logic [ 4:0] bus_write_address;
logic [31:0] bus_write_data;
logic        clock, reset;

common_ram common_ram_inst (
    .bus_read_vaild ( bus_read_vaild ),
    .bus_read_ready ( bus_read_ready ),
    .bus_read_address ( bus_read_address ),
    .bus_read_data ( bus_read_data ),
    .bus_write_vaild ( bus_write_vaild ),
    .bus_write_ready ( bus_write_ready ),
    .bus_write_address ( bus_write_address ),
    .bus_write_data ( bus_write_data ),
    .clock ( clock ),
    .reset ( reset )
);

always #1 clock = ~clock;

initial begin
    bus_read_vaild = 0;
    bus_read_address = 0;
    bus_write_vaild = 0;
    bus_write_address = 0;
    bus_write_data = 0;
    clock = 0;
    reset = 1;
    #2;
    reset = 0;

    bus_read_vaild = 1;
    bus_read_address = 0;
    $display("%t: read: address=0x%h", $time, bus_read_address);
    $monitor("%t: bus_read_ready=0x%h, bus_read_data=0x%h", $time, bus_read_ready, bus_read_data);

    #8;

    bus_write_vaild = 1;
    bus_write_address = 0;
    bus_write_data = 1;
    $display("%t: write: address=0x%h", $time, bus_write_address);
    $monitor("%t: bus_write_ready=0x%h, bus_write_address=0x%h, bus_write_data=0x%h", $time, bus_write_ready, bus_write_address, bus_write_data);

    #8;

    bus_read_vaild = 1;
    bus_read_address = 0;
    $display("%t: read: address=0x%h", $time, bus_read_address);
    $monitor("%t: bus_read_ready=0x%h, bus_read_data=0x%h", $time, bus_read_ready, bus_read_data);

    #64;

    $stop();
end

endmodule
