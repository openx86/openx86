// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: fetch_tb
// create at: 2021-12-28 15:31:24
// description: instruction fetch module

module fetch #(
    // parameters
) (
    // ports
    output logic        bus_read_vaild,
    input  logic        bus_read_ready,
    output logic [31:0] bus_read_address,
    input  logic [31:0] bus_read_data,
    input  logic [31:0] program_counter,
    input  logic        program_counter_valid,
    // input  logic [ 3:0] program_counter_offset,
    output logic [ 7:0] instruction [0:9],
    output logic        instruction_ready,
    input  logic        clock, reset
);
// wire [31:0] real_address = program_counter // {4'b0_0000, program_counter[31:5]}; // 32 bit == 2^5
wire [1:0] program_counter_offset = program_counter % 4;
// wire [31:0] real_address = program_counter >>> 5; // some bits become to 1'bx when simulate

// logic bus_read_ready_pos_edge;
// edge_detect edge_detect_inst (
//     .signal ( bus_read_ready ),
//     .pos_edge ( bus_read_ready_pos_edge ),
//     .clock ( clock ),
//     .reset ( reset )
// );

reg [7:0] buffer [0:15];
reg [7:0] buffer_index, instruction_index;

localparam
state_set_bus_valid = 1,
state_wait_bus_ready = 2,
state_fetch_finish = 3,
state_idle = 0;

logic [3:0] state;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= state_idle;
        bus_read_vaild <= 0;
        bus_read_address <= 0;
        instruction_ready <= 0;
        buffer_index <= 0;
        instruction_index <= 0;
        instruction[0] <= 0;
        instruction[1] <= 0;
        instruction[2] <= 0;
        instruction[3] <= 0;
        instruction[4] <= 0;
        instruction[5] <= 0;
        instruction[6] <= 0;
        instruction[7] <= 0;
        instruction[8] <= 0;
        instruction[9] <= 0;
    end else begin
        unique case (state)
            state_idle: begin
                bus_read_vaild <= 0;
                bus_read_address <= 0;
                instruction_ready <= 0;
                buffer_index <= 0;
                instruction_index <= 0;
                instruction[0] <= 0;
                instruction[1] <= 0;
                instruction[2] <= 0;
                instruction[3] <= 0;
                instruction[4] <= 0;
                instruction[5] <= 0;
                instruction[6] <= 0;
                instruction[7] <= 0;
                instruction[8] <= 0;
                instruction[9] <= 0;
                if (program_counter_valid) begin
                    bus_read_address <= program_counter;
                    state <= state_set_bus_valid;
                end else begin
                    state <= state_idle;
                end
            end
            state_set_bus_valid: begin
                bus_read_vaild <= 1;
                state <= state_wait_bus_ready;
            end
            state_wait_bus_ready: begin
                if (bus_read_ready) begin
                    bus_read_vaild <= 0;
                    buffer[buffer_index+0] <= bus_read_data[ 7: 0];
                    buffer[buffer_index+1] <= bus_read_data[15: 8];
                    buffer[buffer_index+2] <= bus_read_data[23:16];
                    buffer[buffer_index+3] <= bus_read_data[31:24];
                    buffer_index <= buffer_index + 4;
                    instruction_index <= instruction_index + 1;
                    bus_read_address <= bus_read_address + 32'h4;
                    if (buffer_index >= 15) begin
                        state <= state_fetch_finish;
                        instruction_ready <= 1;
                        instruction[0] <= buffer[0+program_counter_offset];
                        instruction[1] <= buffer[1+program_counter_offset];
                        instruction[2] <= buffer[2+program_counter_offset];
                        instruction[3] <= buffer[3+program_counter_offset];
                        instruction[4] <= buffer[4+program_counter_offset];
                        instruction[5] <= buffer[5+program_counter_offset];
                        instruction[6] <= buffer[6+program_counter_offset];
                        instruction[7] <= buffer[7+program_counter_offset];
                        instruction[8] <= buffer[8+program_counter_offset];
                        instruction[9] <= buffer[9+program_counter_offset];
                    end else begin
                        state <= state_set_bus_valid;
                    end
                end else begin

                end
            end
            state_fetch_finish: begin
                instruction_ready <= 0;
                state <= state_idle;
            end
            default: begin
                state <= state_idle;
            end
        endcase
    end
end

endmodule
