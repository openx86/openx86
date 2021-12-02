module soc_top (
    // ports
    input  logic        clock,
    input  logic        reset
);

logic        bus_read_vaild;
logic        bus_read_ready;
logic [31:0] bus_read_address;
logic [31:0] bus_read_data;
logic [31:0] memory_read_address;
logic [31:0] memory_read_data;

memory_controller memory_controller_inst (
    .bus_read_vaild ( bus_read_vaild ),
    .bus_read_ready ( bus_read_ready ),
    .bus_read_address ( bus_read_address ),
    .bus_read_data ( bus_read_data ),
    .memory_read_address ( memory_read_address ),
    .memory_read_data ( memory_read_data ),
    .clock ( clock ),
    .reset ( reset )
);

memory memory_inst (
    .read_address ( memory_read_address ),
    .read_data ( memory_read_data ),
    .clock ( clock ),
    .reset ( reset )
);

endmodule