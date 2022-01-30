/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_immediate
create at: 2022-01-28 03:28:46
description: decode immediate
*/
*/
`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_immediate #(
    // parameters
) (
    // ports
    input  logic [`info_displacement_len-1:0] info_displacement,
    input  logic [ 7:0] instruction[16],
    input  logic        PE,
    input  logic        has_w,
    input  logic        w,
    output logic [31:0] immediate
);

wire length__8 = ~PE &

always_comb begin
    case (info_bit_width)
        `info_bit_width_16: begin
            unique case (mod)
                2'b00 : begin
                    unique case (rm)
                        3'b000 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr__BX; info_index_reg <= `info_reg_gpr__SI; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
                        3'b001 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr__BX; info_index_reg <= `info_reg_gpr__DI; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
                        3'b010 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr__BP; info_index_reg <= `info_reg_gpr__SI; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
                        3'b011 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr__BP; info_index_reg <= `info_reg_gpr__DI; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
                        3'b100 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr__SI; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
                        3'b101 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr__DI; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
                        3'b110 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
                        3'b111 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr__BX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
                    endcase
                end
                2'b01 : begin
                    unique case (rm)
                        3'b000 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr__BX; info_index_reg <= `info_reg_gpr__SI; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
                        3'b001 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr__BX; info_index_reg <= `info_reg_gpr__DI; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
                        3'b010 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr__BP; info_index_reg <= `info_reg_gpr__SI; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
                        3'b011 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr__BP; info_index_reg <= `info_reg_gpr__DI; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
                        3'b100 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr__SI; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
                        3'b101 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr__DI; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
                        3'b110 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr__BP; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
                        3'b111 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr__BX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
                    endcase
                end
                2'b10 : begin
                    unique case (rm)
                        3'b000 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr__BX; info_index_reg <= `info_reg_gpr__SI; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
                        3'b001 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr__BX; info_index_reg <= `info_reg_gpr__DI; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
                        3'b010 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr__BP; info_index_reg <= `info_reg_gpr__SI; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
                        3'b011 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr__BP; info_index_reg <= `info_reg_gpr__DI; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
                        3'b100 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr__SI; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
                        3'b101 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr__DI; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
                        3'b110 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr__BP; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
                        3'b111 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr__BX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
                    endcase
                end
                2'b11 : begin
                    info_segment_reg <= `info_reg_seg_NUL; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 1;
                end
            endcase
        end
        `info_bit_width_32: begin
            unique case (mod)
                2'b00 : begin
                    unique case (rm)
                        3'b000 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EAX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
                        3'b001 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ECX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
                        3'b010 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
                        3'b011 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EBX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
                        3'b100 : begin info_segment_reg <= `info_reg_seg_NUL; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 1; use_register <= 0; end
                        3'b101 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
                        3'b110 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ESI; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
                        3'b111 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDI; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
                    endcase
                end
                2'b01 : begin
                    unique case (rm)
                        3'b000 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EAX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
                        3'b001 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ECX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
                        3'b010 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
                        3'b011 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EBX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
                        3'b100 : begin info_segment_reg <= `info_reg_seg_NUL; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 1; use_register <= 0; end
                        3'b101 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr_EBP; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
                        3'b110 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ESI; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
                        3'b111 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDI; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
                    endcase
                end
                2'b10 : begin
                    unique case (rm)
                        3'b000 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EAX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
                        3'b001 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ECX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
                        3'b010 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
                        3'b011 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EBX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
                        3'b100 : begin info_segment_reg <= `info_reg_seg_NUL; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 1; use_register <= 0; end
                        3'b101 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr_EBP; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
                        3'b110 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ESI; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
                        3'b111 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDI; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
                    endcase
                end
                2'b11 : begin info_segment_reg <= `info_reg_seg_NUL; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 1; end
            endcase
        end
    endcase
end

// assign use_register = mod_11;

// assign sib_is_present = (info_bit_width == `info_bit_width_32) & rm_100 & (~use_register);

// wire sreg_DS =
// ((info_bit_width == `info_bit_width_16) & (
// (mod_00 & (rm_000 | rm_001 | rm_100 | rm_101 | rm_110 | rm_111)) |
// (mod_01 & (rm_000 | rm_001 | rm_100 | rm_101 | rm_111)) |
// 0)) |
// 0;
// wire sreg_SS =
// (mod_00 & (rm_010 | rm_011)) |
// 0;

// wire mod_00 = (mod == 2'b00);
// wire mod_01 = (mod == 2'b01);
// wire mod_10 = (mod == 2'b10);
// wire mod_11 = (mod == 2'b11);

// wire rm_000 = (rm == 3'b000);
// wire rm_001 = (rm == 3'b001);
// wire rm_010 = (rm == 3'b010);
// wire rm_011 = (rm == 3'b011);
// wire rm_100 = (rm == 3'b100);
// wire rm_101 = (rm == 3'b101);
// wire rm_110 = (rm == 3'b110);
// wire rm_111 = (rm == 3'b111);

// assign segment_DS =
// (bit_width_16 &
//     (
//         (mod_00 & (rm_000 | rm_001 | rm_100 | rm_101 | rm_110 | rm_111)) |
//         (mod_01 & (rm_000 | rm_001 | rm_100 | rm_101 | rm_111)) |
//         (mod_10 & (rm_000 | rm_001 | rm_100 | rm_101 | rm_111))
//     )
// );
// assign segment_SS =
// (bit_width_16 &
//     (
//         (mod_00 & (rm_010 | rm_011)) |
//         (mod_01 & (rm_010 | rm_011 | rm_110)) |
//         (mod_10 & (rm_010 | rm_011 | rm_110))
//     )
// );

// // TODO: remove the logic: (bit_width_16 | bit_width_32) for saving the area, level it at here because of 64-bit compatible
// assign reg_AL   = mod_11 & rm_000 & ~w & (bit_width_16 | bit_width_32);
// assign reg_CL   = mod_11 & rm_001 & ~w & (bit_width_16 | bit_width_32);
// assign reg_DL   = mod_11 & rm_010 & ~w & (bit_width_16 | bit_width_32);
// assign reg_BL   = mod_11 & rm_011 & ~w & (bit_width_16 | bit_width_32);
// assign reg_AH   = mod_11 & rm_100 & ~w & (bit_width_16 | bit_width_32);
// assign reg_CH   = mod_11 & rm_101 & ~w & (bit_width_16 | bit_width_32);
// assign reg_DH   = mod_11 & rm_110 & ~w & (bit_width_16 | bit_width_32);
// assign reg_BH   = mod_11 & rm_111 & ~w & (bit_width_16 | bit_width_32);
// assign reg_AX   = mod_11 & rm_000 &  w & (bit_width_16);
// assign reg_CX   = mod_11 & rm_001 &  w & (bit_width_16);
// assign reg_DX   = mod_11 & rm_010 &  w & (bit_width_16);
// assign reg_BX   = mod_11 & rm_011 &  w & (bit_width_16);
// assign reg_SP   = mod_11 & rm_100 &  w & (bit_width_16);
// assign reg_BP   = mod_11 & rm_101 &  w & (bit_width_16);
// assign reg_SI   = mod_11 & rm_110 &  w & (bit_width_16);
// assign reg_DI   = mod_11 & rm_111 &  w & (bit_width_16);
// assign reg_EAX  = mod_11 & rm_000 &  w & (bit_width_32);
// assign reg_ECX  = mod_11 & rm_001 &  w & (bit_width_32);
// assign reg_EDX  = mod_11 & rm_010 &  w & (bit_width_32);
// assign reg_EBX  = mod_11 & rm_011 &  w & (bit_width_32);
// assign reg_ESP  = mod_11 & rm_100 &  w & (bit_width_32);
// assign reg_EBP  = mod_11 & rm_101 &  w & (bit_width_32);
// assign reg_ESI  = mod_11 & rm_110 &  w & (bit_width_32);
// assign reg_EDI  = mod_11 & rm_111 &  w & (bit_width_32);

// // TODO: remove the signal because we need to get the follow displacement info from other instruction
// assign d__0 = mod_00;
// // TODO: remove the logic: (bit_width_16 | bit_width_32) for saving the area
// assign d__8 = mod_01 & (bit_width_16 | bit_width_32);
// assign d_16 = mod_10 & (bit_width_16);
// assign d_32 = mod_10 & (bit_width_32);

// assign base_BX = bit_width_16 & (
//     rm_000 | rm_001 | rm_111
// );
// assign base_BP = bit_width_16 & (
//     (mod_00 & (rm_010 | rm_011)) | (mod_01 & (rm_010 | rm_011 | rm_110)) | (mod_10 & (rm_010 | rm_011 | rm_110))
// );

// assign base_EAX = bit_width_32 & ((mod_00 & rm_000) | (mod_10 & rm_000) | (mod_10 & rm_000));
// assign base_ECX = bit_width_32 & ((mod_00 & rm_001) | (mod_10 & rm_001) | (mod_10 & rm_001));
// assign base_EDX = bit_width_32 & ((mod_00 & rm_010) | (mod_10 & rm_010) | (mod_10 & rm_010));
// assign base_EBX = bit_width_32 & ((mod_00 & rm_011) | (mod_10 & rm_011) | (mod_10 & rm_011));
// // assign base_ESP = bit_width_32 & ((mod_00 & rm_100) | (mod_10 & rm_100) | (mod_10 & rm_100));
// assign base_EBP = bit_width_32 & ((mod_10 & rm_101) | (mod_10 & rm_101));
// assign base_ESI = bit_width_32 & ((mod_00 & rm_110) | (mod_10 & rm_110) | (mod_10 & rm_110));
// assign base_EDI = bit_width_32 & ((mod_00 & rm_111) | (mod_10 & rm_111) | (mod_10 & rm_111));

// logic [2:0] general_register_sequence_code;
// logic [`reg_sel_info_len-1:0] reg_sel_info;
// decode_general_register decode_general_register_inst (
//     .bit_width ( bit_width ),
//     .register_sequence_code ( general_register_sequence_code ),
//     .w_in_instruction ( w_in_instruction ),
//     .w ( w ),
//     .reg_sel_info ( reg_sel_info ),
// );

endmodule
