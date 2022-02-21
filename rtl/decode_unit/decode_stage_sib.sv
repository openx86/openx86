/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_stage_sib
create at: 2021-12-27 00:51:10
description: decode the s-i-b means scale-index-base
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
6.2.3.4 ENCODING OF ADDRESS MODE
*/
`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_stage_sib (
    input  logic [ 7:0] i_sib,
    input  logic [ 1:0] i_mod,
    output logic [ 1:0] o_scale_factor,
    output logic        o_index_reg_is_present,
    output logic [ 2:0] o_index_reg_index,
    output logic        o_base_reg_is_present,
    output logic [ 2:0] o_base_reg_index,
    output logic        o_displacement_is_present,
    output logic [ 3:0] o_displacement_length,
    output logic        o_effecitve_address_undefined
);

wire [1:0] sib_7_6 = i_sib[7:6];
wire [2:0] sib_5_3 = i_sib[5:3];
wire [2:0] sib_2_0 = i_sib[2:0];

wire mod_00 = (i_mod == 2'b00);
wire mod_01 = (i_mod == 2'b01);
wire mod_10 = (i_mod == 2'b10);
wire mod_11 = (i_mod == 2'b11);

wire base_000 = (sib_2_0 == 3'b000);
wire base_001 = (sib_2_0 == 3'b001);
wire base_010 = (sib_2_0 == 3'b010);
wire base_011 = (sib_2_0 == 3'b011);
wire base_100 = (sib_2_0 == 3'b100);
wire base_101 = (sib_2_0 == 3'b101);
wire base_110 = (sib_2_0 == 3'b110);
wire base_111 = (sib_2_0 == 3'b111);

assign o_scale_factor    = sib_7_6;
assign o_index_reg_index = sib_5_3;
assign o_base_reg_index  = sib_2_0;

assign o_index_reg_is_present  = (o_index_reg_index != 3'b100);
assign o_base_reg_is_present   = ~(mod_00 & base_101);

// displacement
wire displacement_length__0 = mod_00 & ~base_101;
wire displacement_length__8 = mod_01;
wire displacement_length_32 = mod_10 | (mod_00 & base_101);
assign o_displacement_is_present = displacement_length__0;
assign o_displacement_length = {displacement_length__8, 1'b0, displacement_length_32, 1'b0};
// always_comb begin
//     unique case (1'b1)
//         displacement_length__0: o_displacement_length <= `length_displacement__0;
//         displacement_length__8: o_displacement_length <= `length_displacement__8;
//         displacement_length_32: o_displacement_length <= `length_displacement_32;
//         default               : o_displacement_length <= `length_displacement__0;
//     endcase
// end

/*
**IMPORTANT NOTE:
When index field is 100, indicating ``no index register,'' then
ss field MUST equal 00. If index is 100 and ss does not
equal 00, the effective address is undefined.
*/
assign o_effecitve_address_undefined = (o_index_reg_index == 3'b100) & (o_scale_factor != 2'b00);

// always_comb begin
//     unique case (scale)
//         2'b00: info_scale <= `info_scale_x1;
//         2'b01: info_scale <= `info_scale_x2;
//         2'b10: info_scale <= `info_scale_x4;
//         2'b11: info_scale <= `info_scale_x8;
//     endcase
//     unique case (index)
//         3'b000: info_index_reg <= `info_reg_gpr_EAX;
//         3'b001: info_index_reg <= `info_reg_gpr_ECX;
//         3'b010: info_index_reg <= `info_reg_gpr_EDX;
//         3'b011: info_index_reg <= `info_reg_gpr_EBX;
//         3'b100: info_index_reg <= `info_reg_gpr_NUL;
//         3'b101: info_index_reg <= `info_reg_gpr_EBP;
//         3'b110: info_index_reg <= `info_reg_gpr_ESI;
//         3'b111: info_index_reg <= `info_reg_gpr_EDI;
//     endcase
//     unique case (i_mod)
//         2'b00 : begin
//             unique case (base)
//                 3'b000 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EAX; info_displacement <= `info_displacement__0; end
//                 3'b001 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ECX; info_displacement <= `info_displacement__0; end
//                 3'b010 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDX; info_displacement <= `info_displacement__0; end
//                 3'b011 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EBX; info_displacement <= `info_displacement__0; end
//                 3'b100 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr_ESP; info_displacement <= `info_displacement__0; end
//                 3'b101 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; end
//                 3'b110 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ESI; info_displacement <= `info_displacement__0; end
//                 3'b111 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDI; info_displacement <= `info_displacement__0; end
//             endcase
//         end
//         2'b01 : begin
//             unique case (base)
//                 3'b000 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EAX; info_displacement <= `info_displacement__8; end
//                 3'b001 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ECX; info_displacement <= `info_displacement__8; end
//                 3'b010 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDX; info_displacement <= `info_displacement__8; end
//                 3'b011 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EBX; info_displacement <= `info_displacement__8; end
//                 3'b100 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr_ESP; info_displacement <= `info_displacement__8; end
//                 3'b101 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr_EBP; info_displacement <= `info_displacement__8; end
//                 3'b110 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ESI; info_displacement <= `info_displacement__8; end
//                 3'b111 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDI; info_displacement <= `info_displacement__8; end
//             endcase
//         end
//         2'b10 : begin
//             unique case (base)
//                 3'b000 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EAX; info_displacement <= `info_displacement_32; end
//                 3'b001 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ECX; info_displacement <= `info_displacement_32; end
//                 3'b010 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDX; info_displacement <= `info_displacement_32; end
//                 3'b011 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EBX; info_displacement <= `info_displacement_32; end
//                 3'b100 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr_ESP; info_displacement <= `info_displacement_32; end
//                 3'b101 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr_EBP; info_displacement <= `info_displacement_32; end
//                 3'b110 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ESI; info_displacement <= `info_displacement_32; end
//                 3'b111 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDI; info_displacement <= `info_displacement_32; end
//             endcase
//         end
//         2'b11 : begin
//             info_segment_reg <= `info_reg_seg_NUL; info_base_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0;;
//         end
//     endcase
// end

endmodule
