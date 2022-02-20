/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_prefix
create at: 2021-12-28 16:56:15
description: decode prefix from instruction
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_prefix (
    input  logic [ 7:0] instruction[0:2],
    output logic        address_size,
    output logic        bus_lock,
    output logic        operand_size,
    output logic        segment_override,
    output logic [ 2:0] segment_override_index
);

assign address_size        = (instruction[0][7:0] == 8'b0110_0111);
assign bus_lock            = (instruction[0][7:0] == 8'b1111_0000);
assign operand_size        = (instruction[0][7:0] == 8'b0110_0110);

wire   segment_override_CS = (instruction[0][7:0] == 8'b0010_1110);
wire   segment_override_DS = (instruction[0][7:0] == 8'b0011_1110);
wire   segment_override_ES = (instruction[0][7:0] == 8'b0010_0110);
wire   segment_override_FS = (instruction[0][7:0] == 8'b0110_0100);
wire   segment_override_GS = (instruction[0][7:0] == 8'b0110_0101);
wire   segment_override_SS = (instruction[0][7:0] == 8'b0011_0110);

assign segment_override    =
segment_override_CS |
segment_override_DS |
segment_override_ES |
segment_override_FS |
segment_override_GS |
segment_override_SS |
0;

always_comb begin
    unique case (1'b1)
        segment_override_CS: segment_override_index <= `index_reg_seg__CS;
        segment_override_DS: segment_override_index <= `index_reg_seg__DS;
        segment_override_ES: segment_override_index <= `index_reg_seg__ES;
        segment_override_FS: segment_override_index <= `index_reg_seg__FS;
        segment_override_GS: segment_override_index <= `index_reg_seg__GS;
        segment_override_SS: segment_override_index <= `index_reg_seg__SS;
        default            : segment_override_index <= 3'b0;
    endcase
end

endmodule
