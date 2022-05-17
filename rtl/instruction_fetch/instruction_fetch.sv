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
    // signal from outside
    input  logic        i_protected_mode,
    input  logic        i_segment_selector [6],
    input  logic        i_current_privilege_level,
    // signal from execute unit
    input  logic        i_IP_vaild,
    // instruction fetch
    output logic [ 7:0] o_instruction [0:15],
    output logic        o_instruction_ready,
    // instruction pointer register file
    input  logic [31:0] EIP,
    // common
    input  logic        clock, reset
);

logic i_vaild;
logic o_ready;

memory_management_unit #(
    .read_from_fetch ( 1 )
) instruction_fetch_memory_management_unit (
    .i_vaild ( i_vaild ),
    .o_ready ( o_ready ),
    .i_protected_mode ( i_protected_mode ),
    .i_segment_selector ( i_segment_selector ),
    .i_current_privilege_level ( i_current_privilege_level ),
    .i_segment_index ( `sreg_index_CS ),
    .i_effective_address ( EIP ),
    .i_write_enable ( 0 ),
    .i_paging_enable ( i_paging_enable ),
    .i_page_directory_base ( i_page_directory_base ),
    .o_physical_address ( o_code_address ),
    .clock ( clock ),
    .reset ( reset )
);

enum logic {
    STATE_WAIT_FOR_CODE_DATA_READY = 1'h1,
    STATE_WAIT_FOR_IP_VALID = 1'h0
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
                if (i_code_ready) begin
                    bytes_index <= bytes_index + 1;
                    if (bytes_index < 2'h3) begin
                        unique case (bytes_index)
                            2'h0: begin
                                o_instruction[0*4:0*4+3] <= '{
                                    i_code_data_read[31:24],
                                    i_code_data_read[23:16],
                                    i_code_data_read[15: 8],
                                    i_code_data_read[ 7: 0]
                                };
                            end
                            2'h1: begin
                                o_instruction[1*4:1*4+3] <= '{
                                    i_code_data_read[31:24],
                                    i_code_data_read[23:16],
                                    i_code_data_read[15: 8],
                                    i_code_data_read[ 7: 0]
                                };
                            end
                            2'h2: begin
                                o_instruction[2*4:2*4+3] <= '{
                                    i_code_data_read[31:24],
                                    i_code_data_read[23:16],
                                    i_code_data_read[15: 8],
                                    i_code_data_read[ 7: 0]
                                };
                            end
                            2'h3: begin
                                o_instruction[3*4:3*4+3] <= '{
                                    i_code_data_read[31:24],
                                    i_code_data_read[23:16],
                                    i_code_data_read[15: 8],
                                    i_code_data_read[ 7: 0]
                                };
                            end
                        endcase
                        // o_instruction[bytes_index*4:bytes_index*4+3] <= '{
                        //     i_code_data_read[31:24],
                        //     i_code_data_read[23:16],
                        //     i_code_data_read[15: 8],
                        //     i_code_data_read[ 7: 0]
                        // };
                        o_instruction_ready <= 0;
                        // state <= STATE_WAIT_FOR_CODE_DATA_READY;
                    end else begin
                        o_instruction_ready <= 1;
                        // state <= STATE_WAIT_FOR_IP_VALID;
                    end
                end else begin
                    o_instruction_ready <= 0;
                    // state <= STATE_WAIT_FOR_CODE_DATA_READY;
                end
            end
            default: begin
                // state <= STATE_WAIT_FOR_IP_VALID;
            end
        endcase
    end
end

endmodule
