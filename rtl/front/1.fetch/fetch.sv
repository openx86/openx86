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
    input  logic [ 3:0] program_counter_offset,
    output logic [31:0] instruction,
    output logic        instruction_ready,
    input  logic        clock, reset
);
wire [31:0] real_address = {4'b0000, program_counter[31:5]}; // 32 bit == 2^5
// wire [31:0] real_address = program_counter >>> 5; // some bits become to 1'bx when simulate

// logic bus_read_ready_pos_edge;
// edge_detect edge_detect_inst (
//     .signal ( bus_read_ready ),
//     .pos_edge ( bus_read_ready_pos_edge ),
//     .clock ( clock ),
//     .reset ( reset )
// );

localparam
state_wait_result = 1 << 1,
state_idle = 1 << 0;

logic [1:0] state;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= state_idle;
        bus_read_vaild <= 0;
        bus_read_address <= 0;
        instruction <= 0;
        instruction_ready <= 0;
    end else begin
        unique case (state)
            state_idle: begin
                bus_read_vaild <= 0;
                bus_read_address <= 0;
                instruction <= 0;
                instruction_ready <= 0;
                if (program_counter_valid) begin
                    bus_read_vaild <= 1;
                    bus_read_address <= real_address;
                    state <= state_wait_result;
                end else begin
                    state <= state_idle;
                end
            end
            state_wait_result: begin
                // if (bus_read_ready_pos_edge) begin
                if (bus_read_ready) begin
                    unique case (program_counter_offset)
                        4'b???1: begin
                            instruction <= {instruction[23: 0], bus_read_data[31:24]};
                        end
                        4'b??1?: begin
                            instruction <= {instruction[15: 0], bus_read_data[31:16]};
                        end
                        4'b?1??: begin
                            instruction <= {instruction[ 7: 0], bus_read_data[31: 8]};
                        end
                        4'b1???: begin
                            instruction <= {                    bus_read_data[31: 8]};
                        end
                    endcase
                    instruction_ready <= 1;
                    bus_read_vaild <= 0;
                    bus_read_address <= 0;
                    state <= state_idle;
                end else begin
                    state <= state_wait_result;
                end
            end
            default: begin
                state <= state_idle;
            end
        endcase
    end
end

endmodule
