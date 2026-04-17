/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: General purpose register file.
*/

module rf_general_purpose_register (
    input  logic         write_enable,
    input  logic [ 2: 0] write_index,
    input  logic [31: 0] write_data,
    output logic [31: 0] read__8 [ 0:  7],
    output logic [31: 0] read_16 [ 0:  7],
    output logic [31: 0] read_32 [ 0:  7],
    input  logic         reset_n,
    input  logic         clock
);

logic [31: 0] general_register [ 0:  7];

always_ff @(posedge clock or negedge reset_n) begin : ff_basic_register
    if (~reset_n) begin
        for (int i = 0; i < 8; i++) begin
            general_register[i] <= 32'h0;
        end
    end else if (write_enable) begin
        general_register[write_index] <= write_data;
    end
end

always_comb begin
    for (int i = 0; i < 8; i++) begin
        read_32[i] = general_register[i];
        read_16[i] = {16'h0, general_register[i][15: 0]};
        read__8[i] = {24'h0, general_register[i][ 7: 0]};
    end
end

endmodule