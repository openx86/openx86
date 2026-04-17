/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: GDTR register file.
*/

module rf_gdtr_register (
    input  logic         gdtr_write_enable,
    input  logic [15: 0] gdtr_write_data_limit,
    input  logic [31: 0] gdtr_write_data_base,
    output logic [15: 0] gdtr_limit,
    output logic [31: 0] gdtr_base,
    input  logic         clock,
    input  logic         reset_n
);

always_ff @(posedge clock or negedge reset_n) begin
    if (~reset_n) begin
        gdtr_limit <= 16'b0;
        gdtr_base <= 32'b0;
    end else if (gdtr_write_enable) begin
        gdtr_limit <= gdtr_write_data_limit;
        gdtr_base <= gdtr_write_data_base;
    end
end

endmodule