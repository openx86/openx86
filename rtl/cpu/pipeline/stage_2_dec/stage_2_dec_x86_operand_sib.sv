/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements sib.
*/
/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: stage_2_dec_x86_operand_sib
create at: 2022-02-25 04:26:25
description: decode the s-i-b means scale-index-base
*/

/* ref:
Intel486(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
6.2.3.4 ENCODING OF ADDRESS MODE
*/

`include "openx86_defs.h.sv"

module stage_2_dec_x86_operand_sib (
    input  logic [ 7: 0] i_sib_byte,
    input  logic [ 1: 0] i_mod_from_modrm,
    output logic [ 1: 0] o_scale,
    output logic [ 2: 0] o_seg_reg_index,
    output logic        o_index_reg_valid,
    output logic [ 2: 0] o_index_reg_index,
    output logic        o_base_reg_valid,
    output logic [ 2: 0] o_base_reg_index,
    output logic        o_disp_size_1b,
    output logic        o_disp_size_4b,
    output logic        o_ea_undefined
);

logic [ 1: 0] sib_7_6;
logic [ 2: 0] sib_5_3;
logic [ 2: 0] sib_2_0;

logic mod_00;
logic mod_01;
logic mod_10;
logic base_100;
logic base_101;

logic seg_SS_mod_00;
logic seg_SS_mod_01;
logic seg_SS_mod_10;
logic seg_SS_mod_xx;

assign sib_7_6 = i_sib_byte[ 7:  6];
assign sib_5_3 = i_sib_byte[ 5:  3];
assign sib_2_0 = i_sib_byte[ 2: 0];
assign mod_00 = (i_mod_from_modrm == 2'b00);
assign mod_01 = (i_mod_from_modrm == 2'b01);
assign mod_10 = (i_mod_from_modrm == 2'b10);
assign base_100 = (sib_2_0 == 3'b100);
assign base_101 = (sib_2_0 == 3'b101);
assign seg_SS_mod_00 = mod_00 & base_100;
assign seg_SS_mod_01 = mod_01 & (base_100 | base_101);
assign seg_SS_mod_10 = mod_10 & (base_100 | base_101);
assign seg_SS_mod_xx = seg_SS_mod_00 | seg_SS_mod_01 | seg_SS_mod_10;

assign o_seg_reg_index = seg_SS_mod_xx ? `index_reg_seg__SS : `index_reg_seg__DS;

assign o_scale           = sib_7_6;
assign o_index_reg_index = sib_5_3;
assign o_base_reg_index  = sib_2_0;

assign o_index_reg_valid = (o_index_reg_index != 3'b100);
assign o_base_reg_valid  = ~(mod_00 & base_101);

// displacement
assign o_disp_size_1b    = mod_01;
assign o_disp_size_4b    = mod_10 | (mod_00 & base_101);

/*
**IMPORTANT NOTE:
When index field is 100, indicating ``no index register,'' then
ss field MUST equal 00. If index is 100 and ss does not
equal 00, the effective address is undefined.
*/
assign o_ea_undefined = (o_index_reg_index == 3'b100) & (o_scale != 2'b00);

endmodule
