// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : stage_2_dec_x86_operand_mod_rm.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_2_dec_x86_operand_mod_rm module
// ============================================================================

/* ref:
Intel486(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
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
3-bit field, allowing the Intel486 DX FS and GS segment
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

`include "openx86_defs.h.sv"

module stage_2_dec_x86_operand_mod_rm (
    // ModR/M 输入：mod/rm + W + address/operand size → 寻址分量与位移宽度
    input  logic [ 1: 0] i_mod,
    input  logic [ 2: 0] i_rm,
    input  logic         i_w_present,
    input  logic         i_w,
    // Address size (CS.D XOR 0x67) — SIB / base / disp form
    input  logic         i_address_size_32,
    // Operand size (CS.D XOR 0x66) — mod=11 GPR width
    input  logic         i_operand_size_32,
    output logic [ 2: 0] o_seg_reg_index,
    output logic         o_base_reg_valid,
    output logic [ 2: 0] o_base_reg_index,
    output logic         o_index_reg_valid,
    output logic [ 2: 0] o_index_reg_index,
    output logic         o_gpr_reg_valid,
    output logic [ 2: 0] o_gpr_reg_index,
    output logic [ 2: 0] o_gpr_reg_bit_width,
    output logic         o_disp_present,
    output logic         o_disp_size_8b,
    output logic         o_disp_size_16b,
    output logic         o_disp_size_32b,
    output logic         o_sib_present
);

// o_sib_present=1：32 位寻址且 rm=100 时需再读 SIB，本模块输出的 base/index/seg 仅部分有效
logic mod_00;
logic mod_01;
logic mod_10;
logic mod_11;

logic rm_000;
logic rm_001;
logic rm_010;
logic rm_011;
logic rm_100;
logic rm_101;
logic rm_110;
logic rm_111;

logic default_operation_size_16;
logic default_operation_size_32;
logic operand_size_16;
logic operand_size_32;

assign mod_00 = (i_mod == 2'b00);
assign mod_01 = (i_mod == 2'b01);
assign mod_10 = (i_mod == 2'b10);
assign mod_11 = (i_mod == 2'b11);
assign rm_000 = (i_rm == 3'b000);
assign rm_001 = (i_rm == 3'b001);
assign rm_010 = (i_rm == 3'b010);
assign rm_011 = (i_rm == 3'b011);
assign rm_100 = (i_rm == 3'b100);
assign rm_101 = (i_rm == 3'b101);
assign rm_110 = (i_rm == 3'b110);
assign rm_111 = (i_rm == 3'b111);
assign default_operation_size_16 = ~i_address_size_32;
assign default_operation_size_32 =  i_address_size_32;
assign operand_size_16           = ~i_operand_size_32;
assign operand_size_32           =  i_operand_size_32;

// segment register

logic mod_00_DS_16_bit;
logic mod_01_DS_16_bit;
logic mod_10_DS_16_bit;

logic mod_00_SS_16_bit;
logic mod_01_SS_16_bit;
logic mod_10_SS_16_bit;

logic mod_00_DS_32_bit;
logic mod_01_DS_32_bit;
logic mod_10_DS_32_bit;

logic mod_00_SS_32_bit;
logic mod_01_SS_32_bit;
logic mod_10_SS_32_bit;

logic DS_16_bit;
logic SS_16_bit;
logic DS_32_bit;
logic SS_32_bit;

logic segment_reg_index_DS;
logic segment_reg_index_SS;

assign mod_00_DS_16_bit = mod_00 & (rm_000 | rm_001 | rm_100 | rm_101 | rm_110 | rm_111);
assign mod_01_DS_16_bit = mod_01 & (rm_000 | rm_001 | rm_100 | rm_101 | rm_111);
assign mod_10_DS_16_bit = mod_10 & (rm_000 | rm_001 | rm_100 | rm_101 | rm_111);
assign mod_00_SS_16_bit = mod_00 & (rm_010 | rm_011);
assign mod_01_SS_16_bit = mod_01 & (rm_010 | rm_011 | rm_110);
assign mod_10_SS_16_bit = mod_10 & (rm_010 | rm_011 | rm_110);
assign mod_00_DS_32_bit = mod_00;
assign mod_01_DS_32_bit = mod_01 & ~rm_101;
assign mod_10_DS_32_bit = mod_10 & ~rm_101;
assign mod_00_SS_32_bit = 1'b0;
assign mod_01_SS_32_bit = mod_01 & rm_101;
assign mod_10_SS_32_bit = mod_10 & rm_101;
assign DS_16_bit = mod_00_DS_16_bit | mod_01_DS_16_bit | mod_10_DS_16_bit;
assign SS_16_bit = mod_00_SS_16_bit | mod_01_SS_16_bit | mod_10_SS_16_bit;
assign DS_32_bit = mod_00_DS_32_bit | mod_01_DS_32_bit | mod_10_DS_32_bit;
assign SS_32_bit = mod_00_SS_32_bit | mod_01_SS_32_bit | mod_10_SS_32_bit;
assign segment_reg_index_DS = (default_operation_size_16 & DS_16_bit) | (default_operation_size_32 & DS_32_bit);
assign segment_reg_index_SS = (default_operation_size_16 & SS_16_bit) | (default_operation_size_32 & SS_32_bit);

// 默认段：多数寻址用 DS；BP 基址栈帧用 SS
always_comb begin
    unique case (1'b1)
        segment_reg_index_DS: o_seg_reg_index = `index_reg_seg__DS;
        segment_reg_index_SS: o_seg_reg_index = `index_reg_seg__SS;
        default             : o_seg_reg_index = 3'b0;
    endcase
end

// scale-index-base is present
assign o_sib_present = default_operation_size_32 & ~mod_11 & rm_100;

// base register
logic base_mod_xx_BX;
logic base_mod_00_BP;
logic base_mod_01_BP;
logic base_mod_10_BP;

logic base_16_BX;
logic base_16_BP;

logic base_32_EAX;
logic base_32_ECX;
logic base_32_EDX;
logic base_32_EBX;
logic base_32_ESP;
logic base_32_EBP;
logic base_32_ESI;
logic base_32_EDI;

assign base_mod_xx_BX = ~mod_11 & (rm_000 | rm_001 | rm_111);
assign base_mod_00_BP = mod_00 & (rm_010 | rm_011);
assign base_mod_01_BP = mod_01 & (rm_010 | rm_011 | rm_110);
assign base_mod_10_BP = mod_10 & (rm_010 | rm_011 | rm_110);
assign base_16_BX = default_operation_size_16 & base_mod_xx_BX;
assign base_16_BP = default_operation_size_16 & (base_mod_00_BP | base_mod_01_BP | base_mod_10_BP);

// 32-bit non-SIB: r/m is the base (rm=100 → SIB; mod=00 rm=101 → disp32 only)
assign base_32_EAX = default_operation_size_32 & ~mod_11 & rm_000;
assign base_32_ECX = default_operation_size_32 & ~mod_11 & rm_001;
assign base_32_EDX = default_operation_size_32 & ~mod_11 & rm_010;
assign base_32_EBX = default_operation_size_32 & ~mod_11 & rm_011;
assign base_32_ESP = 1'b0; // ESP only via SIB
assign base_32_EBP = default_operation_size_32 & (mod_01 | mod_10) & rm_101;
assign base_32_ESI = default_operation_size_32 & ~mod_11 & rm_110;
assign base_32_EDI = default_operation_size_32 & ~mod_11 & rm_111;

// 16 位：BX/BP；32 位：EAX..EDI（非 SIB）
always_comb begin
    unique case (1'b1)
        base_16_BX:  o_base_reg_index = `index_reg_gpr__BX;
        base_16_BP:  o_base_reg_index = `index_reg_gpr__BP;
        base_32_EAX: o_base_reg_index = `index_reg_gpr_EAX;
        base_32_ECX: o_base_reg_index = `index_reg_gpr_ECX;
        base_32_EDX: o_base_reg_index = `index_reg_gpr_EDX;
        base_32_EBX: o_base_reg_index = `index_reg_gpr_EBX;
        base_32_ESP: o_base_reg_index = `index_reg_gpr_ESP;
        base_32_EBP: o_base_reg_index = `index_reg_gpr_EBP;
        base_32_ESI: o_base_reg_index = `index_reg_gpr_ESI;
        base_32_EDI: o_base_reg_index = `index_reg_gpr_EDI;
        default    : o_base_reg_index = 3'b0;
    endcase
end

logic base_reg_size_16;
logic base_reg_size_32;

assign base_reg_size_16 = default_operation_size_16 & (base_16_BX | base_16_BP);
assign base_reg_size_32 = default_operation_size_32 & (
    base_32_EAX | base_32_ECX | base_32_EDX | base_32_EBX |
    base_32_ESP | base_32_EBP | base_32_ESI | base_32_EDI);
assign o_base_reg_valid = base_reg_size_16 | base_reg_size_32;

// index register — 16-bit SI/DI only here; 32-bit scaled index comes from SIB
logic index_mod_xx__SI;
logic index_mod_xx__DI;

assign index_mod_xx__SI = default_operation_size_16 & ~mod_11 & (rm_000 | rm_010 | rm_100);
assign index_mod_xx__DI = default_operation_size_16 & ~mod_11 & (rm_001 | rm_011 | rm_101);

// 16 位寻址：索引分量 SI/DI（32 位非 SIB 无独立 index）
always_comb begin
    unique case (1'b1)
        index_mod_xx__SI: o_index_reg_index = `index_reg_gpr__SI;
        index_mod_xx__DI: o_index_reg_index = `index_reg_gpr__DI;
        default         : o_index_reg_index = 3'b0;
    endcase
end

logic index_reg_size_16;
logic index_reg_size_32;

assign index_reg_size_16 = default_operation_size_16 & (index_mod_xx__SI | index_mod_xx__DI);
assign index_reg_size_32 = 1'b0;
assign o_index_reg_valid = index_reg_size_16 | index_reg_size_32;

// displacement_length
assign o_disp_size_8b  = mod_01;
assign o_disp_size_16b = default_operation_size_16 & ((mod_00 & rm_110) | mod_10);
assign o_disp_size_32b = default_operation_size_32 & ((mod_00 & rm_101) | mod_10);
assign o_disp_present = o_disp_size_8b | o_disp_size_16b | o_disp_size_32b;

//     unique case (1'b1)
//         displacement_length__8: displacement_length = `length_displacement__8;
//         displacement_length_16: displacement_length = `length_displacement_16;
//         displacement_length_32: displacement_length = `length_displacement_32;
//     endcase

// general purpose register
assign o_gpr_reg_valid = mod_11;
assign o_gpr_reg_index = i_rm;

// refer to 6.2.3.2 ENCODING OF THE GENERAL REGISTER (reg) FIELD
// The general register is specified by the reg field,
// which may appear in the primary opcode bytes, or as
// the reg field of the ``mod r/m'' byte, or as the r/m
// field of the ``mod r/m'' byte.
logic gpr_reg_bit_width__8;
logic gpr_reg_bit_width_16;
logic gpr_reg_bit_width_32;

assign gpr_reg_bit_width__8 = i_w_present ? (~i_w) : 1'b0;
assign gpr_reg_bit_width_16 = i_w_present ? (i_w & operand_size_16) : operand_size_16;
assign gpr_reg_bit_width_32 = i_w_present ? (i_w & operand_size_32) : operand_size_32;
// mod=11：r/m 字段直接编码通用寄存器及其位宽
always_comb begin
    unique case (1'b1)
        gpr_reg_bit_width__8: o_gpr_reg_bit_width = `bit_width_gpr__8;
        gpr_reg_bit_width_16: o_gpr_reg_bit_width = `bit_width_gpr_16;
        gpr_reg_bit_width_32: o_gpr_reg_bit_width = `bit_width_gpr_32;
        default             : o_gpr_reg_bit_width = `bit_width_gpr__0;
    endcase
end

endmodule
