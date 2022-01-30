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
    // ports
    input  logic [ 7:0] instruction,
    input  logic [ 1:0] mod,
    output logic [`info_reg_seg_len-1:0] info_segment_reg,
    output logic [`info_scale_len-1:0] info_scale,
    output logic [`info_reg_gpr_len-1:0] info_base_reg,
    output logic [`info_reg_gpr_len-1:0] info_index_reg,
    output logic [`info_displacement_len-1:0] info_displacement
);

wire [1:0] scale = instruction[7:6];
wire [2:0] index = instruction[5:3];
wire [2:0] base  = instruction[2:0];

always_comb begin
    unique case (scale)
        2'b00: info_scale <= `info_scale_x1;
        2'b01: info_scale <= `info_scale_x2;
        2'b10: info_scale <= `info_scale_x4;
        2'b11: info_scale <= `info_scale_x8;
    endcase
    unique case (index)
        3'b000: info_index_reg <= `info_reg_gpr_EAX;
        3'b001: info_index_reg <= `info_reg_gpr_ECX;
        3'b010: info_index_reg <= `info_reg_gpr_EDX;
        3'b011: info_index_reg <= `info_reg_gpr_EBX;
        3'b100: info_index_reg <= `info_reg_gpr_NUL;
        3'b101: info_index_reg <= `info_reg_gpr_EBP;
        3'b110: info_index_reg <= `info_reg_gpr_ESI;
        3'b111: info_index_reg <= `info_reg_gpr_EDI;
    endcase
    unique case (mod)
        2'b00 : begin
            unique case (base)
                3'b000 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EAX; info_displacement <= `info_displacement__0; end
                3'b001 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ECX; info_displacement <= `info_displacement__0; end
                3'b010 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDX; info_displacement <= `info_displacement__0; end
                3'b011 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EBX; info_displacement <= `info_displacement__0; end
                3'b100 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr_ESP; info_displacement <= `info_displacement__0; end
                3'b101 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; end
                3'b110 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ESI; info_displacement <= `info_displacement__0; end
                3'b111 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDI; info_displacement <= `info_displacement__0; end
            endcase
        end
        2'b01 : begin
            unique case (base)
                3'b000 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EAX; info_displacement <= `info_displacement__8; end
                3'b001 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ECX; info_displacement <= `info_displacement__8; end
                3'b010 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDX; info_displacement <= `info_displacement__8; end
                3'b011 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EBX; info_displacement <= `info_displacement__8; end
                3'b100 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr_ESP; info_displacement <= `info_displacement__8; end
                3'b101 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr_EBP; info_displacement <= `info_displacement__8; end
                3'b110 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ESI; info_displacement <= `info_displacement__8; end
                3'b111 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDI; info_displacement <= `info_displacement__8; end
            endcase
        end
        2'b10 : begin
            unique case (base)
                3'b000 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EAX; info_displacement <= `info_displacement_32; end
                3'b001 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ECX; info_displacement <= `info_displacement_32; end
                3'b010 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDX; info_displacement <= `info_displacement_32; end
                3'b011 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EBX; info_displacement <= `info_displacement_32; end
                3'b100 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr_ESP; info_displacement <= `info_displacement_32; end
                3'b101 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr_EBP; info_displacement <= `info_displacement_32; end
                3'b110 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ESI; info_displacement <= `info_displacement_32; end
                3'b111 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDI; info_displacement <= `info_displacement_32; end
            endcase
        end
        2'b11 : begin
            info_segment_reg <= `info_reg_seg_NUL; info_base_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0;;
        end
    endcase
end

endmodule
