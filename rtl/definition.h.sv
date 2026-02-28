/*
project: w80386dx
description: global macro definitions for the x86 CPU softcore
*/

`ifndef DEFINITION_H_SV
`define DEFINITION_H_SV

// Segment register indices (CS, DS, ES, SS, FS, GS = 0..5)
`define sreg_index_CS 3'h0
`define sreg_index_DS 3'h1
`define sreg_index_ES 3'h2
`define sreg_index_SS 3'h3
`define sreg_index_FS 3'h4
`define sreg_index_GS 3'h5

// Segment register address indices (used in decode logic)
`define index_reg_seg__CS 3'h0
`define index_reg_seg__DS 3'h1
`define index_reg_seg__ES 3'h2
`define index_reg_seg__SS 3'h3
`define index_reg_seg__FS 3'h4
`define index_reg_seg__GS 3'h5

// General purpose register indices (EAX=0, ECX=1, EDX=2, EBX=3, ESP=4, EBP=5, ESI=6, EDI=7)
`define index_reg_gpr_EAX 3'd0
`define index_reg_gpr_ECX 3'd1
`define index_reg_gpr_EDX 3'd2
`define index_reg_gpr_EBX 3'd3
`define index_reg_gpr_ESP 3'd4
`define index_reg_gpr_EBP 3'd5
`define index_reg_gpr_ESI 3'd6
`define index_reg_gpr_EDI 3'd7
// 16-bit legacy register indices (same encoding as 32-bit counterparts)
`define index_reg_gpr__AX 3'd0
`define index_reg_gpr__CX 3'd1
`define index_reg_gpr__DX 3'd2
`define index_reg_gpr__BX 3'd3
`define index_reg_gpr__SP 3'd4
`define index_reg_gpr__BP 3'd5
`define index_reg_gpr__SI 3'd6
`define index_reg_gpr__DI 3'd7

// GPR bit widths (for decode field output)
`define bit_width_gpr__0 2'd0
`define bit_width_gpr__8 2'd1
`define bit_width_gpr_16 2'd2
`define bit_width_gpr_32 2'd3

// Displacement lengths (for decode)
`define length_displacement__0 2'd0
`define length_displacement__8 2'd1
`define length_displacement_16 2'd2
`define length_displacement_32 2'd3

// Default operation size (used in decode modules)
`define default_operation_size_16 1'b0
`define default_operation_size_32 1'b1

// Granularity (segment descriptor G bit)
`define granularity_byte 1'b0
`define granularity_4K   1'b1

// Data segment expansion direction
`define data_expansion_direction_up   1'b0
`define data_expansion_direction_down 1'b1

// Descriptor type
`define descriptor_type_system        1'b0
`define descriptor_type_code_or_data  1'b1

// Operand bit width for shift/rotate operations
`define OPERAND_BIT_WIDTH 32

// General bit width
`define BIT_WIDTH 32

// info_bit_width_len (legacy, kept for compatibility)
`define info_bit_width_len 2

`endif // DEFINITION_H_SV
