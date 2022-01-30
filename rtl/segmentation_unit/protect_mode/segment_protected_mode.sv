/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: segment_protected_mode
create at: 2022-01-26 19:55:43
description: segment_protected_mode
*/

module segment_protected_mode #(
    // parameters
) (
    // ports
    input  logic [15: 0] segment_selector,
    input  logic [15: 0] GDT_limit,
    input  logic [31: 0] GDT_base_linear_address,
    output logic [31: 0] bus_read_address,
    input  logic [31: 0] bus_read_data,
    output logic         bus_vaild,
    input  logic         bus_ready,
    output logic [31: 0] linear_base_address,
    input  logic         valid,
    output logic         ready,
    input  logic         clock,
    input  logic         reset
);

wire [12:0] segment_descriptor_index  = segment_selector[15:3];
wire        table_indicator           = segment_selector[2]; // 0 indicate GDT, 1 indicate LDT
wire [ 1:0] requestor_privilege_level = segment_selector[1:0];

wire is_legal_segment = ~segment_selector & ~segment_descriptor_index;
wire is_not_out_of_GDTs_bound = segment_descriptor_index >= (GDT_limit >> 3);
wire is_legal_privilege_level = 1; //  requestor_privilege_level RPL >= CPL;

wire is_legal = is_legal_segment & is_not_out_of_GDTs_bound & is_legal_privilege_level;

wire descriptor_offset_address_31__0 = GDT_base_linear_address + segment_descriptor_index * 8 + 0;
wire descriptor_offset_address_63_32 = descriptor_offset_address_31__0 + 4;

reg [63:0] descriptor;

typedef enum bit [7:0] {
    STATE_IDLE,
    STATE_GET_GDT_DESCRIPTOR,
} state;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        ready <= 0;
        linear_base_address <= 0;
        bus_read_write_n <= 0;
        bus_vaild <= 0;
        descriptor <= 0;
        state <= STATE_IDLE;
    end else begin
        unique case (state)
            STATE_IDLE: begin
                ready <= 0;
                linear_base_address <= 0;
                bus_read_write_n <= 0;
                bus_vaild <= 0;
                // check if segment descriptor index is out of GDT's bound by GDT_limit
                if (valid & is_legal) begin
                    state <= STATE_REQUEST_GDT_DESCRIPTOR_31__0;
                end else begin
                    state <= STATE_IDLE;
                end
            end
            STATE_REQUEST_GDT_DESCRIPTOR_31__0: begin
                bus_vaild <= 1;
                bus_read_address <= descriptor_offset_address_31__0;
                state <= STATE_WAIT_FOR_DESCRIPTOR_31__0;
            end
            STATE_WAIT_FOR_DESCRIPTOR_31__0: begin
                bus_vaild <= 0;
                if (bus_ready) begin
                    descriptor[31: 0] <= bus_read_data;
                    state <= STATE_WAIT_FOR_DESCRIPTOR_63_32;
                end else begin
                    state <= STATE_WAIT_FOR_DESCRIPTOR_31__0;
                end
            end
            STATE_REQUEST_GDT_DESCRIPTOR_63_32: begin
                bus_vaild <= 1;
                bus_read_address <= descriptor_offset_address_63_32;
                state <= STATE_WAIT_FOR_DESCRIPTOR_63_32;
            end
            STATE_WAIT_FOR_DESCRIPTOR_63_32: begin
                bus_vaild <= 0;
                if (bus_ready) begin
                    descriptor[63:32] <= bus_read_data;
                    state <= STATE_WAIT_FOR_DESCRIPTOR_63_32;
                end else begin
                    state <= STATE_WAIT_FOR_DESCRIPTOR_63_32;
                end
            end
            RETURN_RESULT: begin
                ready <= 1;
                linear_base_address <= ;
            end
            default: begin
                state <= STATE_IDLE;
            end
        endcase
    end
end

assign linear_base_address = segment_value << 4;

endmodule
