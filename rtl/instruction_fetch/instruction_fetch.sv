// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: fetch_tb
// create at: 2021-12-28 15:31:24
// description: instruction fetch module

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module instruction_fetch (
    input  logic [15:0] IP,
    input  logic [31:0] EIP,
    // input  logic [15:0] CS_segment_selector,
    // input  logic [63:0] CS_descriptor_cache,
    input  logic [31:0] code_segment_base,
    input  logic [31:0] code_segment_limit,
    input  logic        code_default_operation_size,
    input  logic        program_counter_valid,
    output logic        bus_vaild,
    input  logic        bus_ready,
    input  logic        bus_busy,
    output logic        bus_write_enable,
    output logic [31:0] bus_address,
    input  logic [31:0] bus_data_read,
    output logic [31:0] bus_data_write,
    output logic [ 7:0] instruction [0:15],
    output logic        instruction_ready,
    input  logic        clock, reset
);

logic [31:0] physical_address;
memory_management_unit memory_management_unit_instance_in_instruction_fetch (
    .segment_index ( index_reg_seg__CS ),
    .offset ( EIP ),
    .physical_address ( physical_address )
);

reg [3:0] buffer [0:7];
reg [3:0] buffer_index, instruction_index;

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
        for (int i=0; i<16; ++i) begin
            instruction[i] <= 8'b0;
        end
        // instruction[0] <= 0;
        // instruction[1] <= 0;
        // instruction[2] <= 0;
        // instruction[3] <= 0;
        // instruction[4] <= 0;
        // instruction[5] <= 0;
        // instruction[6] <= 0;
        // instruction[7] <= 0;
        // instruction[8] <= 0;
        // instruction[9] <= 0;
    end else begin
        unique case (state)
            state_idle: begin
                bus_read_vaild <= 0;
                bus_read_address <= 0;
                instruction_ready <= 0;
                instruction_index <= 0;
                for (int i=0; i<16; ++i) begin
                    instruction[i] <= 8'b0;
                end
                if (program_counter_valid & ~bus_busy) begin
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
                    instruction[instruction_index + 0] <= bus_read_data[ 7: 0];
                    instruction[instruction_index + 1] <= bus_read_data[15: 8];
                    instruction[instruction_index + 2] <= bus_read_data[23:16];
                    instruction[instruction_index + 3] <= bus_read_data[31:24];
                    instruction_index <= instruction_index + 4'h4;
                    bus_read_address <= bus_read_address + 32'h4;
                    if (instruction_index >= 15) begin
                        state <= state_fetch_finish;
                        instruction_ready <= 1;
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
