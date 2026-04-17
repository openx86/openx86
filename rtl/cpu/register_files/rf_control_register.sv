/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Control register file.
*/

module rf_control_register (
    input  logic         write_enable,
    input  logic [ 2: 0] write_index,
    input  logic [31: 0] write_data,
    output logic [31: 0] CR [ 0:  7],
    output logic         PE,
    output logic         MP,
    output logic         EM,
    output logic         TS,
    output logic         R,
    output logic         PG,
    output logic [19: 0] page_directory_base,
    input  logic         clock,
    input  logic         reset_n
);

always_ff @(posedge clock or negedge reset_n) begin : ff_control_register
    if (~reset_n) begin
        CR[0] <= 32'b0;
        CR[1] <= 32'b0;
        CR[2] <= 32'b0;
        CR[3] <= 32'b0;
        CR[4] <= 32'b0;
        CR[5] <= 32'b0;
        CR[6] <= 32'b0;
        CR[7] <= 32'b0;
    end else if (write_enable) begin
        CR[write_index] <= write_data;
    end
end

assign PE = CR[0][0];
assign MP = CR[0][1];
assign EM = CR[0][2];
assign TS = CR[0][3];
assign R  = CR[0][4];
assign PG = CR[0][31];

assign page_directory_base = CR[3][31: 12];

endmodule