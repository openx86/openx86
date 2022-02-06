/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_sib
create at: 2021-12-27 00:51:10
description: decode the s-i-b means scale-index-base
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
6.2.3.4 ENCODING OF ADDRESS MODE
*/
`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_sib (
    input  logic [ 7:0] instruction,
    input  logic [ 1:0] mod,
    output logic [ 1:0] scale_factor,
    output logic        index_reg_used,
    output logic [ 2:0] index_reg_index,
    output logic        base_reg_used,
    output logic [ 2:0] base_reg_index,
    output logic [ 2:0] displacement_length,
    output logic        effecitve_address_undefined
);

wire mod_00 = (mod == 2'b00);
wire mod_01 = (mod == 2'b01);
wire mod_10 = (mod == 2'b10);
wire mod_11 = (mod == 2'b11);

wire base_000 = (base_reg_index == 3'b000);
wire base_001 = (base_reg_index == 3'b001);
wire base_010 = (base_reg_index == 3'b010);
wire base_011 = (base_reg_index == 3'b011);
wire base_100 = (base_reg_index == 3'b100);
wire base_101 = (base_reg_index == 3'b101);
wire base_110 = (base_reg_index == 3'b110);
wire base_111 = (base_reg_index == 3'b111);

assign scale_factor    = instruction[7:6];
assign index_reg_index = instruction[5:3];
assign base_reg_index  = instruction[2:0];

assign index_reg_used  = (index_reg_index != 3'b100);
assign base_reg_used   = ~(mod_00 & base_101);

// displacement
wire displacement_length__0 = mod_00 & ~base_101;
wire displacement_length__8 = mod_01;
wire displacement_length_32 = mod_10 | (mod_00 & base_101);
always_comb begin
    unique case (1'b1)
        displacement_length__0: displacement_length <= `length_displacement__0;
        displacement_length__8: displacement_length <= `length_displacement__8;
        displacement_length_32: displacement_length <= `length_displacement_32;
        default               : displacement_length <= `length_displacement__0;
    endcase
end

/*
**IMPORTANT NOTE:
When index field is 100, indicating ``no index register,'' then
ss field MUST equal 00. If index is 100 and ss does not
equal 00, the effective address is undefined.
*/
assign effecitve_address_undefined = (index_reg_index == 3'b100) & (scale_factor != 2'b00);

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
//     unique case (mod)
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
