/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Debug register file.
*/

module rf_debug_register (
    input  logic         write_enable,
    input  logic [ 2: 0] write_index,
    input  logic [31: 0] write_data,
    output logic [31: 0] DR [ 0:  7],
    input  logic         clock,
    input  logic         reset_n
);

always_ff @(posedge clock or negedge reset_n) begin
    if (~reset_n) begin
        DR[0] <= 32'b0;
        DR[1] <= 32'b0;
        DR[2] <= 32'b0;
        DR[3] <= 32'b0;
        DR[4] <= 32'b0;
        DR[5] <= 32'b0;
        DR[6] <= 32'b0;
        DR[7] <= 32'b0;
    end else if (write_enable) begin
        DR[write_index] <= write_data;
    end
end

endmodule