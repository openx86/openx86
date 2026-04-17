/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Test register file.
*/

module rf_test_register (
    input  logic         write_enable,
    input  logic [ 2: 0] write_index,
    input  logic [31: 0] write_data,
    output logic [31: 0] TR [ 0:  7],
    input  logic         clock,
    input  logic         reset_n
);

always_ff @(posedge clock or negedge reset_n) begin
    if (~reset_n) begin
        TR[0] <= 32'b0;
        TR[1] <= 32'b0;
        TR[2] <= 32'b0;
        TR[3] <= 32'b0;
        TR[4] <= 32'b0;
        TR[5] <= 32'b0;
        TR[6] <= 32'b0;
        TR[7] <= 32'b0;
    end else if (write_enable) begin
        TR[write_index] <= write_data;
    end
end

endmodule