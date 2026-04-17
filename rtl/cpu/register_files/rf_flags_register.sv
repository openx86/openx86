/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: EFLAGS/FLAGS register file.
*/

module rf_flags_register (
    input  logic         write_enable,
    input  logic [31: 0] write_data,
    output logic         CF,
    output logic         PF,
    output logic         AF,
    output logic         ZF,
    output logic         SF,
    output logic         TF,
    output logic         IF,
    output logic         DF,
    output logic         OF,
    output logic [ 1: 0] IOPL,
    output logic         NT,
    output logic         RF,
    output logic         VM,
    output logic [31: 0] EFLAGS,
    output logic [15: 0] FLAGS,
    input  logic         clock,
    input  logic         reset_n
);

logic [31: 0] flags_reg;

always_ff @(posedge clock or negedge reset_n) begin
    if (~reset_n) begin
        flags_reg <= 32'b0;
    end else if (write_enable) begin
        flags_reg <= write_data;
    end
end

assign EFLAGS = flags_reg[31: 0];
assign FLAGS  = flags_reg[15: 0];

assign CF   = flags_reg[    0];
assign PF   = flags_reg[    2];
assign AF   = flags_reg[    4];
assign ZF   = flags_reg[    6];
assign SF   = flags_reg[    7];
assign TF   = flags_reg[    8];
assign IF   = flags_reg[    9];
assign DF   = flags_reg[   10];
assign OF   = flags_reg[   11];
assign IOPL = flags_reg[13: 12];
assign NT   = flags_reg[   14];
assign RF   = flags_reg[   16];
assign VM   = flags_reg[   17];

endmodule