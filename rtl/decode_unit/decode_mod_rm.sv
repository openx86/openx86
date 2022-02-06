/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_mod_rm
create at: 2021-10-23 15:54:39
description: decode mod and r/m field in instruction
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
6.2.3.2 ENCODING OF THE GENERAL
REGISTER (reg) FIELD
The general register is specified by the reg field,
which may appear in the primary opcode bytes, or as
the reg field of the ``mod r/m'' byte, or as the r/m
field of the ``mod r/m'' byte.

6.2.3.3 ENCODING OF THE SEGMENT
REGISTER (sreg) FIELD
The sreg field in certain instructions is a 2-bit field
allowing one of the four 80286 segment registers to
be specified. The sreg field in other instructions is a
3-bit field, allowing the Intel386 DX FS and GS segment
registers to be specified.
2-Bit sreg2 Field

6.2.3.4 ENCODING OF ADDRESS MODE
Except for special instructions, such as PUSH or
POP, where the addressing mode is pre-determined,
the addressing mode for the current instruction is
specified by addressing bytes following the primary
opcode. The primary addressing byte is the ``mod
r/m'' byte, and a second byte of addressing information,
the ``s-i-b'' (scale-index-basecan beyte) is specified
when using 32-bit addressing ``mod1 or 10.
When the sib byte is present, the 32-bit addressing
mode is a function of the mod, ss, index, fields.
also contains three bits (shown as TTT in Figure 6-1)
sometimes used as an extension of the primary opcode.
The three bits, however, may also be used as
a register field (reg).
When calculating an effective address, either 16-bit
addressing or 32-bit addressing is used. 16-bit addressing
uses 16-bit address components to calculate
the effective address while 32-bit addressing
uses 32-bit address components to calculate the effective
address. When 16-bit addressing is used, the
``mod r/m'' byte is interpreted as a 16-bit addressing
mode specifier. When 32-bit addressing is used, the
``mod r/m'' byte is interpreted as a 32-bit addressing
mode specifier.
Tables on the following three pages define all encodings
of all 16-bit addressing modes and 32-bit
addressing modes.
*/
`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_mod_rm (
    // ports
    input  logic [ 1:0] mod,
    input  logic [ 2:0] rm,
    input  logic        has_w,
    input  logic        w,
    input  logic        bit_width_in_code_descriptor,
    output logic        segment_reg_used,
    output logic [ 2:0] segment_reg_index,
    output logic        base_reg_used,
    output logic [ 2:0] base_reg_index,
    output logic        index_reg_used,
    output logic [ 2:0] index_reg_index,
    output logic [ 2:0] base_index_reg_bit_width,
    output logic        gpr_reg_used,
    output logic [ 2:0] gpr_reg_index,
    output logic [ 2:0] gpr_reg_bit_width,
    output logic [ 1:0] displacement_length,
    output logic        sib_is_present
);

// sib_is_present is 1'b1 means this module's signal is invalid
// neet to check s-i-b byte for correct segment & base & index & displacement signal

wire mod_00 = (mod == 2'b00);
wire mod_01 = (mod == 2'b01);
wire mod_10 = (mod == 2'b10);
wire mod_11 = (mod == 2'b11);

wire rm_000 = (rm == 3'b000);
wire rm_001 = (rm == 3'b001);
wire rm_010 = (rm == 3'b010);
wire rm_011 = (rm == 3'b011);
wire rm_100 = (rm == 3'b100);
wire rm_101 = (rm == 3'b101);
wire rm_110 = (rm == 3'b110);
wire rm_111 = (rm == 3'b111);

wire CS_bit_width_16 = (bit_width_in_code_descriptor == `default_operation_size_16);
wire CS_bit_width_32 = (bit_width_in_code_descriptor == `default_operation_size_32);


// segment register
assign segment_reg_used = mod_00 | mod_01 | mod_10;

wire mod_00_DS_16_bit = mod_00 & (rm_000 | rm_001 | rm_100 | rm_101 | rm_110 | rm_111);
wire mod_01_DS_16_bit = mod_01 & (rm_000 | rm_001 | rm_100 | rm_101 | rm_111);
wire mod_10_DS_16_bit = mod_10 & (rm_000 | rm_001 | rm_100 | rm_101 | rm_111);

wire mod_00_SS_16_bit = mod_00 & (rm_010 | rm_011);
wire mod_01_SS_16_bit = mod_01 & (rm_010 | rm_011 | rm_110);
wire mod_10_SS_16_bit = mod_10 & (rm_010 | rm_011 | rm_110);

wire mod_00_DS_32_bit = mod_00;
wire mod_01_DS_32_bit = mod_01 & ~rm_101;
wire mod_10_DS_32_bit = mod_01 & ~rm_101;

wire mod_00_SS_32_bit = mod_00;
wire mod_01_SS_32_bit = mod_01 & rm_101;
wire mod_10_SS_32_bit = mod_01 & rm_101;

wire DS_16_bit = mod_00_DS_16_bit | mod_01_DS_16_bit | mod_10_DS_16_bit;
wire SS_16_bit = mod_00_SS_16_bit | mod_01_SS_16_bit | mod_10_SS_16_bit;
wire DS_32_bit = mod_00_DS_32_bit | mod_01_DS_32_bit | mod_10_DS_32_bit;
wire SS_32_bit = mod_00_SS_32_bit | mod_01_SS_32_bit | mod_10_SS_32_bit;

wire segment_reg_index_DS = (CS_bit_width_16 & DS_16_bit) | (CS_bit_width_32 & DS_32_bit);
wire segment_reg_index_SS = (CS_bit_width_16 & SS_16_bit) | (CS_bit_width_32 & SS_32_bit);

assign segment_reg_index = segment_reg_index_DS ? `index_reg_seg__DS : `index_reg_seg__SS;

// scale-index-base is present
assign sib_is_present = CS_bit_width_32 & ~mod_11 & rm_100;

// base and index register index
assign base_index_reg_bit_width = bit_width_in_code_descriptor;

wire base_mod_xx_BX = ~mod_11 & (rm_000 | rm_001 | rm_111);
wire base_mod_00_BP =  mod_00 & (rm_010 | rm_011);
wire base_mod_01_BP =  mod_01 & (rm_010 | rm_011 | rm_110);
wire base_mod_10_BP =  mod_10 & (rm_010 | rm_011 | rm_110);
wire base_mod_xx_32_bit = rm;

wire base_reg_used_16_bit = CS_bit_width_16 & (base_mod_xx_BX | base_mod_00_BP | base_mod_01_BP | base_mod_10_BP);
wire base_reg_used_32_bit = CS_bit_width_32 & (base_mod_xx_32_bit);

assign base_reg_used = base_reg_used_16_bit | base_reg_used_32_bit;

wire index_mod_xx_SI = ~mod_11 & (rm_000 | rm_010 | rm_100);
wire index_mod_xx_DI = ~mod_11 & (rm_001 | rm_011 | rm_101);

assign index_reg_used = CS_bit_width_16 & (index_mod_xx_SI | index_mod_xx_DI);


// displacement_length
wire displacement_length__8 = mod_01;
wire displacement_length_16 = CS_bit_width_16 & ((mod_00 & rm_110) | mod_10);
wire displacement_length_32 = CS_bit_width_32 & ((mod_00 & rm_110) | mod_10);
always_comb begin
    unique case (1'b1)
        displacement_length__8: displacement_length <= `length_displacement__8;
        displacement_length_16: displacement_length <= `length_displacement_16;
        displacement_length_32: displacement_length <= `length_displacement_32;
        default               : displacement_length <= `length_displacement__0;
    endcase
end

// general propose register
assign gpr_reg_used = mod_11;
assign gpr_reg_index = rm;

// refer to 6.2.3.2 ENCODING OF THE GENERAL REGISTER (reg) FIELD
// The general register is specified by the reg field,
// which may appear in the primary opcode bytes, or as
// the reg field of the ``mod r/m'' byte, or as the r/m
// field of the ``mod r/m'' byte.
wire gpr_reg_bit_width__8 = has_w ? (~w) : 1'b0;
wire gpr_reg_bit_width_16 = has_w ? (w & CS_bit_width_16) : CS_bit_width_16;
wire gpr_reg_bit_width_32 = has_w ? (w & CS_bit_width_32) : CS_bit_width_32;
always_comb begin
    unique case (1'b1)
        gpr_reg_bit_width__8: gpr_reg_bit_width <= `bit_width_gpr__8;
        gpr_reg_bit_width_16: gpr_reg_bit_width <= `bit_width_gpr_16;
        gpr_reg_bit_width_32: gpr_reg_bit_width <= `bit_width_gpr_32;
        default             : gpr_reg_bit_width <= `bit_width_gpr__0;
    endcase
end


// always_comb begin
//     case (info_bit_width)
//         `info_bit_width_16: begin
//             unique case (mod)
//                 2'b00 : begin
//                     unique case (rm)
//                         3'b000 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr__BX; index_index_reg <= `index_reg_gpr__SI; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
//                         3'b001 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr__BX; index_index_reg <= `index_reg_gpr__DI; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
//                         3'b010 : begin index_segment_reg <= `index_reg_seg__SS; index_base_reg <= `index_reg_gpr__BP; index_index_reg <= `index_reg_gpr__SI; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
//                         3'b011 : begin index_segment_reg <= `index_reg_seg__SS; index_base_reg <= `index_reg_gpr__BP; index_index_reg <= `index_reg_gpr__DI; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
//                         3'b100 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr_NUL; index_index_reg <= `index_reg_gpr__SI; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
//                         3'b101 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr_NUL; index_index_reg <= `index_reg_gpr__DI; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
//                         3'b110 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr_NUL; index_index_reg <= `index_reg_gpr_NUL; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
//                         3'b111 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr__BX; index_index_reg <= `index_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
//                     endcase
//                 end
//                 2'b01 : begin
//                     unique case (rm)
//                         3'b000 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr__BX; index_index_reg <= `index_reg_gpr__SI; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
//                         3'b001 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr__BX; index_index_reg <= `index_reg_gpr__DI; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
//                         3'b010 : begin index_segment_reg <= `index_reg_seg__SS; index_base_reg <= `index_reg_gpr__BP; index_index_reg <= `index_reg_gpr__SI; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
//                         3'b011 : begin index_segment_reg <= `index_reg_seg__SS; index_base_reg <= `index_reg_gpr__BP; index_index_reg <= `index_reg_gpr__DI; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
//                         3'b100 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr_NUL; index_index_reg <= `index_reg_gpr__SI; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
//                         3'b101 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr_NUL; index_index_reg <= `index_reg_gpr__DI; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
//                         3'b110 : begin index_segment_reg <= `index_reg_seg__SS; index_base_reg <= `index_reg_gpr__BP; index_index_reg <= `index_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
//                         3'b111 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr__BX; index_index_reg <= `index_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
//                     endcase
//                 end
//                 2'b10 : begin
//                     unique case (rm)
//                         3'b000 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr__BX; index_index_reg <= `index_reg_gpr__SI; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
//                         3'b001 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr__BX; index_index_reg <= `index_reg_gpr__DI; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
//                         3'b010 : begin index_segment_reg <= `index_reg_seg__SS; index_base_reg <= `index_reg_gpr__BP; index_index_reg <= `index_reg_gpr__SI; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
//                         3'b011 : begin index_segment_reg <= `index_reg_seg__SS; index_base_reg <= `index_reg_gpr__BP; index_index_reg <= `index_reg_gpr__DI; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
//                         3'b100 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr_NUL; index_index_reg <= `index_reg_gpr__SI; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
//                         3'b101 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr_NUL; index_index_reg <= `index_reg_gpr__DI; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
//                         3'b110 : begin index_segment_reg <= `index_reg_seg__SS; index_base_reg <= `index_reg_gpr__BP; index_index_reg <= `index_reg_gpr_NUL; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
//                         3'b111 : begin index_segment_reg <= `index_reg_seg__DS; index_base_reg <= `index_reg_gpr__BX; index_index_reg <= `index_reg_gpr_NUL; info_displacement <= `info_displacement_16; sib_is_present <= 0; use_register <= 0; end
//                     endcase
//                 end
//                 2'b11 : begin
//                     info_segment_reg <= `info_reg_seg_NUL; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 1;
//                 end
//             endcase
//         end
//         `info_bit_width_32: begin
//             unique case (mod)
//                 2'b00 : begin
//                     unique case (rm)
//                         3'b000 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EAX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
//                         3'b001 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ECX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
//                         3'b010 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
//                         3'b011 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EBX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
//                         3'b100 : begin info_segment_reg <= `info_reg_seg_NUL; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 1; use_register <= 0; end
//                         3'b101 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
//                         3'b110 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ESI; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
//                         3'b111 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDI; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 0; end
//                     endcase
//                 end
//                 2'b01 : begin
//                     unique case (rm)
//                         3'b000 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EAX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
//                         3'b001 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ECX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
//                         3'b010 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
//                         3'b011 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EBX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
//                         3'b100 : begin info_segment_reg <= `info_reg_seg_NUL; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 1; use_register <= 0; end
//                         3'b101 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr_EBP; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
//                         3'b110 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ESI; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
//                         3'b111 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDI; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__8; sib_is_present <= 0; use_register <= 0; end
//                     endcase
//                 end
//                 2'b10 : begin
//                     unique case (rm)
//                         3'b000 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EAX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
//                         3'b001 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ECX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
//                         3'b010 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
//                         3'b011 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EBX; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
//                         3'b100 : begin info_segment_reg <= `info_reg_seg_NUL; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 1; use_register <= 0; end
//                         3'b101 : begin info_segment_reg <= `info_reg_seg__SS; info_base_reg <= `info_reg_gpr_EBP; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
//                         3'b110 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_ESI; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
//                         3'b111 : begin info_segment_reg <= `info_reg_seg__DS; info_base_reg <= `info_reg_gpr_EDI; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement_32; sib_is_present <= 0; use_register <= 0; end
//                     endcase
//                 end
//                 2'b11 : begin info_segment_reg <= `info_reg_seg_NUL; info_base_reg <= `info_reg_gpr_NUL; info_index_reg <= `info_reg_gpr_NUL; info_displacement <= `info_displacement__0; sib_is_present <= 0; use_register <= 1; end
//             endcase
//         end
//     endcase
// end

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
