module w80386dx_top (
    // ports
    // input  logic        next_address_n,
    // input  logic        bus_ready_n,
    // input  logic        bus_size_16_n,
    // input  logic        bus_hold_request,
    // output logic        bus_hold_acknowledge,
    // input  logic        busy_n,
    // input  logic        error_n,
    // input  logic        precessor_extension_request,
    // input  logic        interrupt_request,
    // input  logic        non_maskable_interrupt_request,
    // inout  logic [31:0] data,
    // output logic [31:2] address,
    // output logic [ 3:0] byte_enables_n,
    // output logic        write_read_n,
    // output logic        data_control_n,
    // output logic        memory_io_n,
    // output logic        bus_lock_n,
    // output logic        address_status_n,
    input  logic        clock,
    input  logic        reset
);

logic        bus_read_vaild;
logic        bus_read_ready;
logic [31:0] bus_read_address;
logic [31:0] bus_read_data;

w80386_core u_w80386_core (
    .bus_read_vaild ( bus_read_vaild ),
    .bus_read_ready ( bus_read_ready ),
    .bus_read_address ( bus_read_address ),
    .bus_read_data ( bus_read_data ),
    .clock ( clock ),
    .reset ( reset )
);

bus_controller u_bus_controller (
    .bus_read_vaild ( bus_read_vaild ),
    .bus_read_ready ( bus_read_ready ),
    .bus_read_address ( bus_read_address ),
    .bus_read_data ( bus_read_data ),
    .clock ( clock ),
    .reset ( reset )
);

endmodule
