/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_field
create at: 2022-02-25 02:54:27
description: decode fileds include w, s, reg, mod_r/m, imm, disp
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"

module decode_field (
    input  logic [ 7:0] i_instruction [0:3],
    input  logic        i_x86_ADC_reg_1_to_reg_2,
    input  logic        i_x86_ADC_reg_2_to_reg_1,
    input  logic        i_x86_ADC_mem_to_reg,
    input  logic        i_x86_ADC_reg_to_mem,
    input  logic        i_x86_ADC_imm_to_reg,
    input  logic        i_x86_ADC_imm_to_acc,
    input  logic        i_x86_ADC_imm_to_mem,
    output logic [ 2:0] o_index_reg_gen [0:2],
    output logic        o_index_reg_gen_is_present,
    output logic [ 2:0] o_index_reg_seg,
    output logic        o_index_reg_seg_is_present,
    output logic        o_w_is_present,
    output logic        o_w,
    output logic        o_s_is_present,
    output logic        o_s,
    output logic        o_mod_rm_is_present,
    output logic [ 1:0] o_mod,
    output logic [ 2:0] o_rm,
    output logic        o_immediate_size_full,
    output logic        o_consume_bytes_opcode_1,
    output logic        o_consume_bytes_opcode_2,
    output logic        o_consume_bytes_opcode_3,
    output logic        o_error
);

wire reg_1_at_1_5_3 =
i_x86_ADC_reg_1_to_reg_2 |
i_x86_ADC_reg_2_to_reg_1 |
i_x86_ADC_mem_to_reg |
i_x86_ADC_reg_to_mem |
i_x86_ADC_imm_to_reg |
0;

wire reg_1_at_1_2_0 =
i_x86_ADC_reg_1_to_reg_2 |
i_x86_ADC_reg_2_to_reg_1 |
0;

always_comb begin
    unique case (1'b1)
        reg_1_at_1_5_3 : o_index_reg_gen[0] <= i_instruction[1][5:3];
        reg_1_at_1_2_0 : o_index_reg_gen[0] <= i_instruction[1][2:0];
        default        : o_index_reg_gen[0] <= 3'bzzz;
    endcase
end
assign o_index_reg_gen_is_present =
reg_1_at_1_5_3 |
reg_1_at_1_2_0 |
0;

assign o_index_reg_seg = 0;
assign o_index_reg_seg_is_present = 0;

assign o_w_is_present =
i_x86_ADC_reg_1_to_reg_2 |
i_x86_ADC_reg_2_to_reg_1 |
i_x86_ADC_mem_to_reg |
i_x86_ADC_reg_to_mem |
i_x86_ADC_imm_to_reg |
i_x86_ADC_imm_to_acc |
i_x86_ADC_imm_to_mem |
0;

wire   w_at_0_0 =
o_w_is_present |
0;
always_comb begin
    case (1'b1)
        w_at_0_0: o_w <= i_instruction[0][0];
        default : o_w <= 1'bz;
    endcase
end

wire   s_at_0_1 = i_x86_ADC_imm_to_acc;
assign o_s_is_present =
w_at_0_0 |
s_at_0_1 |
0;
always_comb begin
    case (1'b1)
        s_at_0_1: o_s <= i_instruction[0][1];
        default : o_s <= 1'bz;
    endcase
end

wire   mod_rm_at_1 =
i_x86_ADC_mem_to_reg |
i_x86_ADC_reg_to_mem |
i_x86_ADC_imm_to_mem |
0;
assign o_mod_rm_is_present =
mod_rm_at_1 |
0;
always_comb begin
    case (1'b1)
        mod_rm_at_1: { o_mod, o_rm } <= { i_instruction[1][7:6], i_instruction[1][2:0] };
        default    : { o_mod, o_rm } <= { 2'bzz, 3'bzzz };
    endcase
end

assign o_immediate_size_full =
i_x86_ADC_imm_to_reg |
i_x86_ADC_imm_to_acc |
i_x86_ADC_imm_to_mem |
0;

assign o_consume_bytes_opcode_1 =
i_x86_ADC_reg_1_to_reg_2 |
i_x86_ADC_reg_2_to_reg_1 |
i_x86_ADC_mem_to_reg |
i_x86_ADC_reg_to_mem |
i_x86_ADC_imm_to_reg |
i_x86_ADC_imm_to_acc |
i_x86_ADC_imm_to_mem |
0;
assign o_consume_bytes_opcode_2 =
0;
assign o_consume_bytes_opcode_3 =
0;

endmodule
