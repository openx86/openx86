/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_2_dec_decode_sib.
*/
/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: stage_2_dec_decode_sib
create at: 2022-02-25 04:26:25
description: decode the s-i-b means scale-index-base
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
6.2.3.4 ENCODING OF ADDRESS MODE
*/

`include "openx86_defs.h.sv"

module stage_2_dec_decode_sib (
    input  logic [ 7:0] i_sib,
    input  logic [ 1:0] i_mod,
    output logic [ 1:0] o_scale_factor,
    output logic [ 2:0] o_segment_reg_index,
    output logic        o_index_reg_is_present,
    output logic [ 2:0] o_index_reg_index,
    output logic        o_base_reg_is_present,
    output logic [ 2:0] o_base_reg_index,
    output logic        o_displacement_size_1,
    output logic        o_displacement_size_4,
    output logic        o_effecitve_address_undefined
);

logic [ 1: 0] sib_7_6 = i_sib[ 7:  6];
logic [ 2: 0] sib_5_3 = i_sib[ 5:  3];
logic [ 2: 0] sib_2_0 = i_sib[ 2: 0];

logic mod_00 = (i_mod == 2'b00);
logic mod_01 = (i_mod == 2'b01);
logic mod_10 = (i_mod == 2'b10);
logic mod_11 = (i_mod == 2'b11);

logic base_000 = (sib_2_0 == 3'b000);
logic base_001 = (sib_2_0 == 3'b001);
logic base_010 = (sib_2_0 == 3'b010);
logic base_011 = (sib_2_0 == 3'b011);
logic base_100 = (sib_2_0 == 3'b100);
logic base_101 = (sib_2_0 == 3'b101);
logic base_110 = (sib_2_0 == 3'b110);
logic base_111 = (sib_2_0 == 3'b111);

logic seg_SS_mod_00 = mod_00 & base_100;
logic seg_SS_mod_01 = mod_01 & (base_100 | base_101);
logic seg_SS_mod_10 = mod_10 & (base_100 | base_101);
logic seg_SS_mod_xx = seg_SS_mod_00 | seg_SS_mod_01 | seg_SS_mod_10;

assign o_segment_reg_index = seg_SS_mod_xx ? `index_reg_seg__SS : `index_reg_seg__DS;

assign o_scale_factor    = sib_7_6;
assign o_index_reg_index = sib_5_3;
assign o_base_reg_index  = sib_2_0;

assign o_index_reg_is_present  = (o_index_reg_index != 3'b100);
assign o_base_reg_is_present   = ~(mod_00 & base_101);

// displacement
assign o_displacement_size_1 = mod_01;
assign o_displacement_size_4 = mod_10 | (mod_00 & base_101);

/*
**IMPORTANT NOTE:
When index field is 100, indicating ``no index register,'' then
ss field MUST equal 00. If index is 100 and ss does not
equal 00, the effective address is undefined.
*/
assign o_effecitve_address_undefined = (o_index_reg_index == 3'b100) & (o_scale_factor != 2'b00);

endmodule
