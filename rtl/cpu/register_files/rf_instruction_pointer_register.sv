/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Instruction pointer register file.
*/

module rf_instruction_pointer_register (
    input  logic         write_enable,
    input  logic [31: 0] write_data,
    output logic [15: 0] IP,
    output logic [31: 0] EIP,
    input  logic         clock,
    input  logic         reset_n
);

logic [31: 0] instruction_pointer;

always_ff @(posedge clock or negedge reset_n) begin
    if (~reset_n) begin
        instruction_pointer <= 32'h0000_FFF0;
    end else if (write_enable) begin
        instruction_pointer <= write_data;
    end
end

assign IP  = instruction_pointer[15: 0];
assign EIP = instruction_pointer[31: 0];

endmodule