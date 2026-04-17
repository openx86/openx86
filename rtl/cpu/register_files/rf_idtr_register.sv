/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: IDTR register file.
*/

module rf_idtr_register (
    input  logic         idtr_write_enable,
    input  logic [15: 0] idtr_write_data_limit,
    input  logic [31: 0] idtr_write_data_base,
    output logic [15: 0] idtr_limit,
    output logic [31: 0] idtr_base,
    input  logic         clock,
    input  logic         reset_n
);

always_ff @(posedge clock or negedge reset_n) begin
    if (~reset_n) begin
        idtr_limit <= 16'b0;
        idtr_base <= 32'b0;
    end else if (idtr_write_enable) begin
        idtr_limit <= idtr_write_data_limit;
        idtr_base <= idtr_write_data_base;
    end
end

endmodule