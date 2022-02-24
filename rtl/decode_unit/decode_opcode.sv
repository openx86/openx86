/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_opcode
create at: 2022-02-25 04:05:06
description: decode opcode selection signal from instruction
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"

module decode_opcode (
    input  logic [ 7:0] i_instruction [0:15],
    output logic        o_x86_ADC_reg_1_to_reg_2,
    output logic        o_x86_ADC_reg_2_to_reg_1,
    output logic        o_x86_ADC_mem_to_reg,
    output logic        o_x86_ADC_reg_to_mem,
    output logic        o_x86_ADC_imm_to_reg,
    output logic        o_x86_ADC_imm_to_acc,
    output logic        o_x86_ADC_imm_to_mem,
    output logic        o_error
);

assign o_x86_ADC_reg_1_to_reg_2 = i_instruction[0][7:1] == 7'b0001_000 & i_instruction[1][7:6] == 2'b11;
assign o_x86_ADC_reg_2_to_reg_1 = i_instruction[0][7:1] == 7'b0001_001 & i_instruction[1][7:6] == 2'b11;
assign o_x86_ADC_mem_to_reg     = i_instruction[0][7:1] == 7'b0001_001 & i_instruction[1][7:6] != 2'b11;
assign o_x86_ADC_reg_to_mem     = i_instruction[0][7:1] == 7'b0001_000 & i_instruction[1][7:6] != 2'b11;
assign o_x86_ADC_imm_to_reg     = i_instruction[0][7:1] == 6'b1000_00  & i_instruction[1][7:6] == 2'b11;
assign o_x86_ADC_imm_to_acc     = i_instruction[0][7:1] == 7'b0001_010;
assign o_x86_ADC_imm_to_mem     = i_instruction[0][7:1] == 6'b1000_00  & i_instruction[1][7:6] != 2'b11;

endmodule
