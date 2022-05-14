module bus_controller (
    // bus
    input  logic        i_bus_vaild,
    output logic        o_bus_ready,
    output logic        o_bus_busy,
    input  logic        i_bus_write_enable,
    input  logic [31:0] i_bus_address,
    output logic [31:0] o_bus_data_read,
    input  logic [31:0] i_bus_data_write,
    // common
    input  logic        i_clock, i_reset
);

// TODO: use BIOS ROM data
assign o_bus_ready = 1;
assign o_bus_data_read = 32'hABCD_EF01;
assign o_bus_busy = 0;
assign o_bus_ready = i_bus_vaild;
// rom u_rom (
//     // .data    (_connected_to_data_),    //   input,  width = 32,    data.datain
//     .q       (bus_read_data),       //  input,  width = 32,       q.dataout
//     .address (bus_read_address[7:0]), //   input,  width = 8, address.address
//     // .wren    (_connected_to_wren_),    //   input,   width = 1,    wren.wren
//     .clock   (clock)    //   input,   width = 1,   clock.clk
// );

// logic bus_read_vaild_pos_edge;
// edge_detect edge_detect_inst (
//     .signal ( bus_read_vaild ),
//     .pos_edge ( bus_read_vaild_pos_edge ),
//     .clock ( clock ),
//     .reset ( reset )
// );

// localparam
// state_transmit = 1 << 1,
// state_idle = 1 << 0;

// logic [1:0] state;

// always_ff @(posedge clock or posedge reset) begin
//     if (reset) begin
//         state <= state_idle;
//         bus_read_data <= 0;
//         bus_read_ready <= 0;
//         memory_read_address <= 0;
//     end else begin
//         unique case (state)
//             state_idle: begin
//                 if (bus_read_vaild_pos_edge) begin
//                     state <= state_transmit;
//                     memory_read_address <= bus_read_address;
//                 end
//             end
//             state_transmit: begin
//                 state <= state_idle;
//                 bus_read_ready <= 1;
//                 bus_read_data <= memory_read_data;
//             end
//             default: begin
//                 state <= state_idle;
//             end
//         endcase
//     end
// end

endmodule
