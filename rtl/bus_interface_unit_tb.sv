`timescale 1ns/1ns
module bus_interface_unit_tb #(
    // parameters
    clock_period = 2
) (
    // ports
);
logic clock, reset;
always #(clock_period/2) clock = ~clock;

logic        i_code_vaild;
logic        o_code_ready;
logic [31:0] i_code_address;
logic [31:0] o_code_data_read;
logic        i_data_vaild;
logic        o_data_ready;
logic        i_data_write_enable;
logic [31:0] i_data_address;
logic [31:0] o_data_data_read;
logic [31:0] i_data_data_write;
logic        o_bus_vaild;
logic        i_bus_ready;
logic        i_bus_busy;
logic        o_bus_write_enable;
logic [31:0] o_bus_address;
logic [31:0] i_bus_data_read;
logic [31:0] o_bus_data_write;

initial begin
    clock = 1;
    reset = 1;
    #(clock_period * 2);
    reset = 0;

    i_code_vaild = 0;
    i_code_address = 0;
    i_data_vaild = 0;
    i_data_write_enable = 0;
    i_data_address = 0;
    i_data_data_write = 0;
    i_bus_ready = 0;
    i_bus_busy = 0;
    i_bus_data_read = 0;

    #(clock_period * 2);

    // fetch code
    i_code_vaild = 1;
    i_code_address = 32'h1;

    #(clock_period * 2);
    i_bus_ready = 1;
    i_bus_data_read = 32'h1;
    #(clock_period);
    i_bus_ready = 0;
    i_code_vaild = 0;

    #(clock_period * 2);

    // fetch data
    i_data_vaild = 1;
    i_data_address = 32'h20;

    #(clock_period * 2);
    i_bus_ready = 1;
    i_bus_data_read = 32'h200;
    #(clock_period);
    i_bus_ready = 0;
    i_data_vaild = 0;

    #(clock_period * 2);

    // code and data are vaild in the same time,
    // code is ready after 2 cycles, except fetch data immediately.
    i_code_vaild = 1;
    i_code_address = 32'h1;

    i_data_vaild = 1;
    i_data_address = 32'h20;

    #(clock_period);
    i_bus_ready = 1;
    i_bus_data_read = 32'h1;
    #(clock_period);
    i_bus_ready = 0;
    i_code_vaild = 0;

    #(clock_period * 2);
    i_bus_ready = 1;
    i_bus_data_read = 32'h200;
    #(clock_period);
    i_bus_ready = 0;
    i_data_vaild = 0;

    #(clock_period * 4);

    // fetch code first, then data is valid after 1 cycle,
    // data is ready after 2 cycles, except fetch code immediately.
    i_code_vaild = 1;
    i_code_address = 32'h1;

    #(clock_period);

    i_data_vaild = 1;
    i_data_address = 32'h20;

    #(clock_period);
    i_bus_ready = 1;
    i_bus_data_read = 32'h1;
    #(clock_period);
    i_bus_ready = 0;
    i_code_vaild = 0;

    #(clock_period * 2);
    i_bus_ready = 1;
    i_bus_data_read = 32'h200;
    #(clock_period);
    i_bus_ready = 0;
    i_data_vaild = 0;

    #(clock_period * 4);

    $stop();
end

bus_interface_unit tb_bus_interface_unit (
    .i_code_vaild        ( i_code_vaild ),
    .o_code_ready        ( o_code_ready ),
    .i_code_address      ( i_code_address ),
    .o_code_data_read    ( o_code_data_read ),
    .i_data_vaild        ( i_data_vaild ),
    .o_data_ready        ( o_data_ready ),
    .i_data_write_enable ( i_data_write_enable ),
    .i_data_address      ( i_data_address ),
    .o_data_data_read    ( o_data_data_read ),
    .i_data_data_write   ( i_data_data_write ),
    .o_bus_vaild         ( o_bus_vaild ),
    .i_bus_ready         ( i_bus_ready ),
    .i_bus_busy          ( i_bus_busy ),
    .o_bus_write_enable  ( o_bus_write_enable ),
    .o_bus_address       ( o_bus_address ),
    .i_bus_data_read     ( i_bus_data_read ),
    .o_bus_data_write    ( o_bus_data_write ),
    .i_clock             ( clock ),
    .i_reset             ( reset )
);

endmodule
