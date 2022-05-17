// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: fetch_tb
// create at: 2021-12-28 15:31:24
// description: instruction fetch module

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module instruction_fetch (
    // signal from bus_interface_unit
    output logic        o_code_vaild,
    input  logic        i_code_ready,
    output logic [31:0] o_code_address,
    input  logic [31:0] i_code_data_read,
    // signal from execute unit
    input  logic        i_IP_vaild,
    // instruction fetch
    output logic [ 7:0] o_instruction [0:15],
    output logic        o_instruction_ready,
    // unused
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

assign o_code_address = physical_address;

// reg [3:0] buffer [0:7];
// reg [3:0] buffer_index, instruction_index;

// localparam
// state_set_bus_valid = 1,
// state_wait_bus_ready = 2,
// state_fetch_finish = 3,
// state_idle = 0;

enum logic [1:0] {
    STATE_WAIT_FOR_CODE_DATA_READY = 1,
    STATE_WAIT_FOR_IP_VALID = 0
} state;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= STATE_WAIT_FOR_IP_VALID;
    end else begin
        unique case (state)
            STATE_WAIT_FOR_IP_VALID: begin
                if (i_IP_vaild) begin
                    state <= STATE_WAIT_FOR_CODE_DATA_READY;
                end else begin
                    state <= STATE_WAIT_FOR_IP_VALID;
                end
            end
            STATE_WAIT_FOR_CODE_DATA_READY: begin
                if (i_code_ready) begin
                    state <= STATE_WAIT_FOR_IP_VALID;
                end else begin
                    state <= STATE_WAIT_FOR_CODE_DATA_READY;
                end
            end
            default: begin
                state <= STATE_WAIT_FOR_IP_VALID;
            end
        endcase
    end
end

logic [ 1:0] bytes_index;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        o_code_vaild <= 0;
        bytes_index <= 0;
    end else begin
        unique case (state)
            STATE_WAIT_FOR_IP_VALID: begin
                bytes_index <= 0;
                if (i_IP_vaild) begin
                    o_code_vaild <= 1;
                end else begin
                    o_code_vaild <= 0;
                end
            end
            STATE_WAIT_FOR_CODE_DATA_READY: begin
                if (code_data_ready) begin
                    bytes_index <= bytes_index + 1;
                    if (bytes_index < 2'h3) begin
                        instruction[bytes_index*4:bytes_index*4+3] <= '{
                            i_code_data_read[31:24],
                            i_code_data_read[23:16],
                            i_code_data_read[15: 8],
                            i_code_data_read[ 7: 0]
                        };
                        instruction_ready <= 0;
                        state <= STATE_WAIT_FOR_CODE_DATA_READY;
                    end else begin
                        instruction_ready <= 1;
                        state <= STATE_WAIT_FOR_IP_VALID;
                    end
                end else begin
                    instruction_ready <= 0;
                    state <= STATE_WAIT_FOR_CODE_DATA_READY;
                end
            end
            default: begin
                state <= STATE_WAIT_FOR_IP_VALID;
            end
        endcase
    end
end

// always_ff @(posedge clock or posedge reset) begin
    // if (reset) begin
    //     state <= STATE_WAIT_FOR_IP_VALID;
    //     bus_read_vaild <= 0;
    //     bus_read_address <= 0;
    //     instruction_ready <= 0;
    //     buffer_index <= 0;
    //     instruction_index <= 0;
    //     for (int i=0; i<16; ++i) begin
    //         instruction[i] <= 8'b0;
    //     end
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
//     end else begin
//         unique case (state)
//             state_idle: begin
//                 bus_read_vaild <= 0;
//                 bus_read_address <= 0;
//                 instruction_ready <= 0;
//                 instruction_index <= 0;
//                 for (int i=0; i<16; ++i) begin
//                     instruction[i] <= 8'b0;
//                 end
//                 if (program_counter_valid & ~bus_busy) begin
//                     bus_read_address <= program_counter;
//                     state <= state_set_bus_valid;
//                 end else begin
//                     state <= state_idle;
//                 end
//             end
//             state_set_bus_valid: begin
//                 bus_read_vaild <= 1;
//                 state <= state_wait_bus_ready;
//             end
//             state_wait_bus_ready: begin
//                 if (bus_read_ready) begin
//                     bus_read_vaild <= 0;
//                     instruction[instruction_index + 0] <= bus_read_data[ 7: 0];
//                     instruction[instruction_index + 1] <= bus_read_data[15: 8];
//                     instruction[instruction_index + 2] <= bus_read_data[23:16];
//                     instruction[instruction_index + 3] <= bus_read_data[31:24];
//                     instruction_index <= instruction_index + 4'h4;
//                     bus_read_address <= bus_read_address + 32'h4;
//                     if (instruction_index >= 15) begin
//                         state <= state_fetch_finish;
//                         instruction_ready <= 1;
//                     end else begin
//                         state <= state_set_bus_valid;
//                     end
//                 end else begin

//                 end
//             end
//             state_fetch_finish: begin
//                 instruction_ready <= 0;
//                 state <= state_idle;
//             end
//             default: begin
//                 state <= state_idle;
//             end
//         endcase
//     end
// end

endmodule
