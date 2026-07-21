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
//  File        : openx86_defs.h.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Module
// ============================================================================

`ifndef OPENX86_DEFS_SVH
`define OPENX86_DEFS_SVH

// Common definitions (merged from definition.h.sv)
`define BIT_WIDTH 32
// segment
`define GRANULARITY_BYTE 0
`define GRANULARITY_4K 1
`define DESCRIPTOR_TYPE_SYSTEM 0
`define DESCRIPTOR_TYPE_CODE_OR_DATA 1

// CPUID — 80486DX identity (family 4). VME enabled at M4 roadmap stage.
`define cpuid_max_EAX (32'd1)
// 3*32/8=12 bytes { EBX, EDX, ECX }, 12 ascii
`define cpuid_manufacturer "OpenX86-Free"
`define cpuid_stepping_id 4'd0
`define cpuid_model_id 4'd0
`define cpuid_family_id 4'd4
`define cpuid_processor_type 2'b0
`define cpuid_extended_model_id 4'b0
`define cpuid_extended_family_id 8'b0

`define cpuid_brand_index 8'b0
`define cpuid_CLFLUSH_line_size 16'b0
`define cpuid_logical_processors_count 8'b0
`define cpuid_local_APIC_id 8'b0

// Feature EDX bits for leaf 1 (Intel layout). Only FPU is advertised for 486DX.
`define cpuid_feature_fpu           1'b1
`define cpuid_feature_vme            1'b0
`define cpuid_feature_de             1'b0
`define cpuid_feature_pse            1'b0
`define cpuid_feature_tsc            1'b0
`define cpuid_feature_msr            1'b0
`define cpuid_feature_pae            1'b0
`define cpuid_feature_mce            1'b0
`define cpuid_feature_cx8            1'b0
`define cpuid_feature_apic           1'b0
`define cpuid_feature_sep            1'b0
`define cpuid_feature_mtrr           1'b0
`define cpuid_feature_pge            1'b0
`define cpuid_feature_mca            1'b0
`define cpuid_feature_cmov           1'b0
`define cpuid_feature_pat            1'b0
`define cpuid_feature_pse36          1'b0
`define cpuid_feature_psn            1'b0
`define cpuid_feature_clfsh          1'b0
`define cpuid_feature_ds             1'b0
`define cpuid_feature_acpi           1'b0
`define cpuid_feature_mmx            1'b0
`define cpuid_feature_fxsr           1'b0
`define cpuid_feature_sse            1'b0
`define cpuid_feature_sse2           1'b0
`define cpuid_feature_ss             1'b0
`define cpuid_feature_htt            1'b0
`define cpuid_feature_tm             1'b0
`define cpuid_feature_ia64           1'b0
`define cpuid_feature_pbe            1'b0
`define cpuid_feature_sse3           1'b0
`define cpuid_feature_pclmulqdq      1'b0
`define cpuid_feature_dtes64         1'b0
`define cpuid_feature_monitor        1'b0
`define cpuid_feature_ds_cpl         1'b0
`define cpuid_feature_vmx            1'b0
`define cpuid_feature_smx            1'b0
`define cpuid_feature_est            1'b0
`define cpuid_feature_tm2            1'b0
`define cpuid_feature_ssse3          1'b0
`define cpuid_feature_cnxt_id        1'b0
`define cpuid_feature_sdbg           1'b0
`define cpuid_feature_fma            1'b0
`define cpuid_feature_cx16           1'b0
`define cpuid_feature_xtpr           1'b0
`define cpuid_feature_pdcm           1'b0
`define cpuid_feature_pcid           1'b0
`define cpuid_feature_pdca           1'b0
`define cpuid_feature_sse41          1'b0
`define cpuid_feature_sse42          1'b0
`define cpuid_feature_x2apic         1'b0
`define cpuid_feature_movbe          1'b0
`define cpuid_feature_popcnt         1'b0
`define cpuid_feature_tsc_deadline   1'b0
`define cpuid_feature_aes            1'b0
`define cpuid_feature_xsave          1'b0
`define cpuid_feature_osxsave        1'b0
`define cpuid_feature_avx            1'b0
`define cpuid_feature_f16c           1'b0
`define cpuid_feature_rdrnd          1'b0
`define cpuid_feature_hypervisor     1'b0

// segment register
`define sreg_index_ES 3'b000
`define sreg_index_CS 3'b001
`define sreg_index_SS 3'b010
`define sreg_index_DS 3'b011
`define sreg_index_FS 3'b100
`define sreg_index_GS 3'b101

// granularity
`define granularity_byte 1'b0
`define granularity_page 1'b1

// data_expansion_direction
`define data_expansion_direction_up   1'b0
`define data_expansion_direction_down 1'b1

// default_operation_size
`define default_operation_size_16 1'b0
`define default_operation_size_32 1'b1

// decode_register_general
`define info_reg_gpr_len (24)
`define info_reg_gpr_NUL (24'b0 <<  0)
`define info_reg_gpr__AL (24'b1 <<  0)
`define info_reg_gpr__BL (24'b1 <<  1)
`define info_reg_gpr__CL (24'b1 <<  2)
`define info_reg_gpr__DL (24'b1 <<  3)
`define info_reg_gpr__AH (24'b1 <<  4)
`define info_reg_gpr__BH (24'b1 <<  5)
`define info_reg_gpr__CH (24'b1 <<  6)
`define info_reg_gpr__DH (24'b1 <<  7)
`define info_reg_gpr__AX (24'b1 <<  8)
`define info_reg_gpr__BX (24'b1 <<  9)
`define info_reg_gpr__CX (24'b1 << 10)
`define info_reg_gpr__DX (24'b1 << 11)
`define info_reg_gpr__SI (24'b1 << 12)
`define info_reg_gpr__DI (24'b1 << 13)
`define info_reg_gpr__BP (24'b1 << 14)
`define info_reg_gpr__SP (24'b1 << 15)
`define info_reg_gpr_EAX (24'b1 << 16)
`define info_reg_gpr_EBX (24'b1 << 17)
`define info_reg_gpr_ECX (24'b1 << 18)
`define info_reg_gpr_EDX (24'b1 << 19)
`define info_reg_gpr_ESI (24'b1 << 20)
`define info_reg_gpr_EDI (24'b1 << 21)
`define info_reg_gpr_EBP (24'b1 << 22)
`define info_reg_gpr_ESP (24'b1 << 23)

// decode_register_segment
`define info_reg_seg_len (6)
`define info_reg_seg_NUL (6'b0 << 0)
`define info_reg_seg__ES (6'b1 << 0)
`define info_reg_seg__CS (6'b1 << 1)
`define info_reg_seg__SS (6'b1 << 2)
`define info_reg_seg__DS (6'b1 << 3)
`define info_reg_seg__FS (6'b1 << 4)
`define info_reg_seg__GS (6'b1 << 5)

// bit width of general propose register
`define bit_width_gpr__0 (3'b000)
`define bit_width_gpr__8 (3'b001)
`define bit_width_gpr_16 (3'b010)
`define bit_width_gpr_32 (3'b011)

// index of general propose register
`define index_reg_gpr__AL (3'b000)
`define index_reg_gpr__BL (3'b001)
`define index_reg_gpr__CL (3'b010)
`define index_reg_gpr__DL (3'b011)
`define index_reg_gpr__AH (3'b100)
`define index_reg_gpr__BH (3'b101)
`define index_reg_gpr__CH (3'b110)
`define index_reg_gpr__DH (3'b111)

`define index_reg_gpr__AX (3'b000)
`define index_reg_gpr__CX (3'b001)
`define index_reg_gpr__DX (3'b010)
`define index_reg_gpr__BX (3'b011)
`define index_reg_gpr__SP (3'b100)
`define index_reg_gpr__BP (3'b101)
`define index_reg_gpr__SI (3'b110)
`define index_reg_gpr__DI (3'b111)

`define index_reg_gpr_EAX (3'b000)
`define index_reg_gpr_ECX (3'b001)
`define index_reg_gpr_EDX (3'b010)
`define index_reg_gpr_EBX (3'b011)
`define index_reg_gpr_ESP (3'b100)
`define index_reg_gpr_EBP (3'b101)
`define index_reg_gpr_ESI (3'b110)
`define index_reg_gpr_EDI (3'b111)

`define index_reg__mm___0 (3'b000)
`define index_reg__mm___1 (3'b001)
`define index_reg__mm___2 (3'b010)
`define index_reg__mm___3 (3'b011)
`define index_reg__mm___4 (3'b100)
`define index_reg__mm___5 (3'b101)
`define index_reg__mm___6 (3'b110)
`define index_reg__mm___7 (3'b111)

`define index_reg_xmm___0 (3'b000)
`define index_reg_xmm___1 (3'b001)
`define index_reg_xmm___2 (3'b010)
`define index_reg_xmm___3 (3'b011)
`define index_reg_xmm___4 (3'b100)
`define index_reg_xmm___5 (3'b101)
`define index_reg_xmm___6 (3'b110)
`define index_reg_xmm___7 (3'b111)

// index of segment register
`define index_reg_seg__ES (3'b000)
`define index_reg_seg__CS (3'b001)
`define index_reg_seg__SS (3'b010)
`define index_reg_seg__DS (3'b011)
`define index_reg_seg__FS (3'b100)
`define index_reg_seg__GS (3'b101)

// length of displacement
`define length_displacement__0 (2'b00)
`define length_displacement__8 (2'b01)
`define length_displacement_16 (2'b10)
`define length_displacement_32 (2'b11)

// scale
`define scale_x1 (2'b00)
`define scale_x2 (2'b01)
`define scale_x4 (2'b10)
`define scale_x8 (2'b11)

// displacement
`define info_displacement_len (3)
`define info_displacement__0  (3'b0 << 0)
`define info_displacement__8  (3'b1 << 0)
`define info_displacement_16  (3'b1 << 1)
`define info_displacement_32  (3'b1 << 2)

// bit_width
`define info_bit_width_len (2)
`define info_bit_width_16  (2'b1 << 0)
`define info_bit_width_32  (2'b1 << 1)

// decode opcode
`define info_opcode_len                     (32)
`define info_opcode_invalid                 (0)
`define info_opcode_mov_reg_to_reg_mem      ((32'b1 << 31) >> 00)
`define info_opcode_mov_reg_mem_to_reg      ((32'b1 << 31) >> 01)
`define info_opcode_mov_imm_to_reg_mem      ((32'b1 << 31) >> 02)
`define info_opcode_mov_imm_to_reg_short    ((32'b1 << 31) >> 03)
`define info_opcode_mov_mem_to_acc          ((32'b1 << 31) >> 04)
`define info_opcode_mov_acc_to_mem          ((32'b1 << 31) >> 05)
`define info_opcode_mov_reg_mem_to_sreg     ((32'b1 << 31) >> 06)
`define info_opcode_mov_sreg_to_reg_mem     ((32'b1 << 31) >> 07)
`define info_opcode_movsx                   ((32'b1 << 31) >> 08)
`define info_opcode_movzx                   ((32'b1 << 31) >> 09)
`define info_opcode_push_reg_mem            ((32'b1 << 31) >> 10)
`define info_opcode_push_reg_short          ((32'b1 << 31) >> 11)
`define info_opcode_push_sreg_2             ((32'b1 << 31) >> 12)
`define info_opcode_push_sreg_3             ((32'b1 << 31) >> 13)
`define info_opcode_push_imm                ((32'b1 << 31) >> 14)
`define info_opcode_push_all                ((32'b1 << 31) >> 15)
`define info_opcode_pop_reg_mem             ((32'b1 << 31) >> 16)
`define info_opcode_pop_reg_short           ((32'b1 << 31) >> 17)
`define info_opcode_pop_sreg_2              ((32'b1 << 31) >> 18)
`define info_opcode_pop_sreg_3              ((32'b1 << 31) >> 19)
`define info_opcode_pop_all                 ((32'b1 << 31) >> 20)
`define info_opcode_xchg_reg_mem_with_reg   ((32'b1 << 31) >> 21)
`define info_opcode_xchg_reg_with_acc_short ((32'b1 << 31) >> 22)
`define info_opcode_xchg_in_fix             ((32'b1 << 31) >> 23)
`define info_opcode_xchg_in_var             ((32'b1 << 31) >> 24)
`define info_opcode_xchg_out_fix            ((32'b1 << 31) >> 25)
`define info_opcode_xchg_out_var            ((32'b1 << 31) >> 26)

// `define DECODE_OPCODE_INFO_LEN 128
// `define DECODE_OPCODE_LOAD `DECODE_OPCODE_INFO_LEN'b << 0
// `define DECODE_OPCODE_STOR `DECODE_OPCODE_INFO_LEN'b << 1
// `define DECODE_OPCODE_MOVE `DECODE_OPCODE_INFO_LEN'b << 1
// `define DECODE_OPCODE___OR `DECODE_OPCODE_INFO_LEN'b << 1
// `define DECODE_OPCODE__AND `DECODE_OPCODE_INFO_LEN'b << 1
// `define DECODE_OPCODE__XOR `DECODE_OPCODE_INFO_LEN'b << 1
// `define DECODE_OPCODE__ADD `DECODE_OPCODE_INFO_LEN'b << 1
// `define DECODE_OPCODE__SUB `DECODE_OPCODE_INFO_LEN'b << 1
// `define DECODE_OPCODE__MUL `DECODE_OPCODE_INFO_LEN'b << 1
// `define DECODE_OPCODE__DIV `DECODE_OPCODE_INFO_LEN'b << 1
// `define DECODE_OPCODE_XCHG `DECODE_OPCODE_INFO_LEN'b << 1

// execute
// `define OPERAND_BIT_WIDTH 32

// x87 decode opmask indexes (replacement for `X87_MASK_M_*)
`define X87_MASK_M_FADD_ST0_STI   5'd0
`define X87_MASK_M_FMUL_ST0_STI   5'd1
`define X87_MASK_M_FCOM_STI       5'd2
`define X87_MASK_M_FCOMP_STI      5'd3
`define X87_MASK_M_FSUB_ST0_STI   5'd4
`define X87_MASK_M_FSUBR_ST0_STI  5'd5
`define X87_MASK_M_FDIV_ST0_STI   5'd6
`define X87_MASK_M_FDIVR_ST0_STI  5'd7
`define X87_MASK_M_FLD_STI        5'd8
`define X87_MASK_M_FXCH_STI       5'd9
`define X87_MASK_M_FNOP           5'd10
`define X87_MASK_M_FCHS           5'd11
`define X87_MASK_M_FABS           5'd12
`define X87_MASK_M_FTST           5'd13
`define X87_MASK_M_FLD1           5'd14
`define X87_MASK_M_FLDZ           5'd15
`define X87_MASK_M_FST_STI        5'd16
`define X87_MASK_M_FSTP_STI       5'd17
`define X87_MASK_M_FFREE_STI      5'd18
`define X87_MASK_M_FADDP_STI_ST0  5'd19
`define X87_MASK_M_FMULP_STI_ST0  5'd20
`define X87_MASK_M_FSUBRP_STI_ST0 5'd21
`define X87_MASK_M_FSUBP_STI_ST0  5'd22
`define X87_MASK_M_FDIVRP_STI_ST0 5'd23
`define X87_MASK_M_FDIVP_STI_ST0  5'd24
`define X87_MASK_M_FCOMIP_STI     5'd25
`define X87_MASK_M_FUCOMIP_STI    5'd26
`define X87_MASK_M_FILD_M32       5'd27
`define X87_MASK_M_FISTP_M32      5'd28
`define X87_MASK_M_FLD_M32        5'd29
`define X87_MASK_M_FSTP_M32       5'd30
`define X87_MASK_M_RESERVED       5'd31

// execute-unit operation constants (macro form)
`define EXE_MD_OP_W  3
`define EXE_X87_OP_W 6
`define EXE_INT_OP_W 6

`define EXE_MD_NOP    3'd0
`define EXE_MD_MULU32 3'd1
`define EXE_MD_IMUL32 3'd2
`define EXE_MD_DIVU32 3'd3
`define EXE_MD_IDIV32 3'd4

`define EXE_X87_NOP     6'd0
`define EXE_X87_FLD     6'd1
`define EXE_X87_FSTP    6'd2
`define EXE_X87_FADD    6'd3
`define EXE_X87_FSUB    6'd4
`define EXE_X87_FMUL    6'd5
`define EXE_X87_FDIV    6'd6
`define EXE_X87_FCHS    6'd7
`define EXE_X87_FABS    6'd8
`define EXE_X87_FXCH    6'd9
`define EXE_X87_FCOMI   6'd10
`define EXE_X87_FLD_STI 6'd11
`define EXE_X87_FST     6'd12
`define EXE_X87_FFREE   6'd13
`define EXE_X87_FCOM    6'd14
`define EXE_X87_FCOMP   6'd15
`define EXE_X87_FTST    6'd16
`define EXE_X87_FLD1    6'd17
`define EXE_X87_FLDZ    6'd18
`define EXE_X87_FNOP    6'd19
`define EXE_X87_FADDP   6'd20
`define EXE_X87_FMULP   6'd21
`define EXE_X87_FSUBP   6'd22
`define EXE_X87_FSUBRP  6'd23
`define EXE_X87_FDIVP   6'd24
`define EXE_X87_FDIVRP  6'd25
`define EXE_X87_FCOMIP  6'd26
`define EXE_X87_FUCOMIP 6'd27
`define EXE_X87_FSUBR   6'd28
`define EXE_X87_FDIVR   6'd29
`define EXE_X87_FLDCW   6'd30
`define EXE_X87_FSTCW   6'd31
`define EXE_X87_FSTSW   6'd32
`define EXE_X87_FINIT   6'd33

// Page table entry bit positions (i486 two-level paging)
`define PTE_BIT_P   0
`define PTE_BIT_RW  1
`define PTE_BIT_US  2

`define EXE_INT_NOP         6'd0
`define EXE_INT_ADD         6'd1
`define EXE_INT_ADC         6'd2
`define EXE_INT_SUB         6'd3
`define EXE_INT_SBB         6'd4
`define EXE_INT_AND         6'd5
`define EXE_INT_OR          6'd6
`define EXE_INT_XOR         6'd7
`define EXE_INT_NOT         6'd8
`define EXE_INT_NEG         6'd9
`define EXE_INT_INC         6'd10
`define EXE_INT_DEC         6'd11
`define EXE_INT_SHL         6'd12
`define EXE_INT_SHR         6'd13
`define EXE_INT_SAR         6'd14
`define EXE_INT_ROL         6'd15
`define EXE_INT_ROR         6'd16
`define EXE_INT_SHLD        6'd17
`define EXE_INT_SHRD        6'd18
`define EXE_INT_RCL         6'd19
`define EXE_INT_RCR         6'd20
`define EXE_INT_BSF         6'd21
`define EXE_INT_BSR         6'd22
`define EXE_INT_BT          6'd23
`define EXE_INT_BTS         6'd24
`define EXE_INT_BTR         6'd25
`define EXE_INT_BTC         6'd26
`define EXE_INT_BSWAP       6'd27
`define EXE_INT_AAA         6'd28
`define EXE_INT_AAS         6'd29
`define EXE_INT_DAA         6'd30
`define EXE_INT_DAS         6'd31
`define EXE_INT_AAD         6'd32
`define EXE_INT_AAM         6'd33
`define EXE_INT_CBW         6'd34
`define EXE_INT_CDQ         6'd35
`define EXE_INT_MOVSX       6'd36
`define EXE_INT_MOVZX       6'd37
`define EXE_INT_CLC         6'd38
`define EXE_INT_STC         6'd39
`define EXE_INT_CMC         6'd40
`define EXE_INT_CLD         6'd41
`define EXE_INT_STD         6'd42
`define EXE_INT_CLI         6'd43
`define EXE_INT_STI         6'd44
`define EXE_INT_LAHF        6'd45
`define EXE_INT_SAHF        6'd46
`define EXE_INT_XCHG        6'd47
`define EXE_INT_XADD        6'd48
`define EXE_INT_CMPXCHG     6'd49
`define EXE_INT_SETCC       6'd50
`define EXE_INT_ARPL        6'd51
`define EXE_INT_LAR         6'd52
`define EXE_INT_LSL         6'd53
`define EXE_INT_VERR        6'd54
`define EXE_INT_STRIDX_STEP 6'd55
`define EXE_INT_IMUL_IMM    6'd56
`define EXE_INT_CLTS        6'd57
`define EXE_INT_LMSW        6'd58
`define EXE_INT_SMSW        6'd59
`define EXE_INT_LOOP_CTRL   6'd60

// Micro-op structure definition for stage_3_uop
// Micro-op format: simplified internal instruction representation
typedef struct packed {
    logic [ 5: 0] uop_opcode;        // Micro-op operation code
    logic [ 2: 0] uop_dest_reg;      // Destination register index
    logic [ 2: 0] uop_src1_reg;      // Source register 1 index
    logic [ 2: 0] uop_src2_reg;      // Source register 2 index
    logic [31: 0] uop_immediate;     // Immediate value
    logic [31: 0] uop_displacement;  // Displacement value
    logic [ 3: 0] uop_tttn;          // Condition code for Jcc/SETcc
    logic [ 5: 0] uop_eee;           // X87 sub-opcode index (EXE_X87_*)
    logic [ 2: 0] uop_seg_index;     // Segment register index for mem ops
    logic [ 1: 0] uop_sib_scale;     // SIB scale factor (index <<= scale)
    logic        uop_has_imm;        // Has immediate operand
    logic        uop_has_disp;       // Has displacement operand
    logic        uop_agu_base;       // src1 is AGU base (else no base term)
    logic        uop_agu_index;      // src2 is AGU index (scaled by uop_sib_scale)
    logic        uop_mem_access;     // Memory access operation
    logic        uop_is_store;       // Store operation (1) vs load (0)
    logic        uop_rep;            // REP/REPE prefix present
    logic        uop_repne;          // REPNE prefix present
    logic        uop_valid;          // Micro-op valid flag
} micro_op_t;

// Micro-op opcodes (extended for full instruction set)
`define UOP_NOP        6'd0
`define UOP_ADD        6'd1
`define UOP_ADC        6'd2
`define UOP_SUB        6'd3
`define UOP_SBB        6'd4
`define UOP_AND        6'd5
`define UOP_OR         6'd6
`define UOP_XOR        6'd7
`define UOP_MOV        6'd8
`define UOP_MOVSX      6'd9
`define UOP_MOVZX      6'd10
`define UOP_LOAD       6'd11
`define UOP_STORE      6'd12
`define UOP_BRANCH     6'd13
`define UOP_CALL       6'd14
`define UOP_RET        6'd15
`define UOP_PUSH       6'd16
`define UOP_POP        6'd17
`define UOP_MUL        6'd18
`define UOP_IMUL       6'd19
`define UOP_DIV        6'd20
`define UOP_IDIV       6'd21
`define UOP_INC        6'd22
`define UOP_DEC        6'd23
`define UOP_NEG        6'd24
`define UOP_NOT        6'd25
`define UOP_CMP        6'd26
`define UOP_TEST       6'd27
`define UOP_SHL        6'd28
`define UOP_SHR        6'd29
`define UOP_SAR        6'd30
`define UOP_ROL        6'd31
`define UOP_ROR        6'd32
`define UOP_RCL        6'd33
`define UOP_RCR        6'd34
`define UOP_SHLD       6'd35
`define UOP_SHRD       6'd36
`define UOP_BT         6'd37
`define UOP_BTS        6'd38
`define UOP_BTR        6'd39
`define UOP_BTC        6'd40
`define UOP_BSF        6'd41
`define UOP_BSR        6'd42
`define UOP_XCHG       6'd43
`define UOP_LEA        6'd44
`define UOP_XADD       6'd45
`define UOP_CMPXCHG    6'd46
`define UOP_SETCC      6'd47
`define UOP_X87        6'd48
`define UOP_STRING     6'd49
`define UOP_FLAG_CTRL  6'd50
`define UOP_MISC       6'd51
`define UOP_MMX        6'd52
`define UOP_SSE        6'd53
`define UOP_EMMS       6'd54

// MISC micro-op subcodes (carried in uop_immediate[7: 0])
`define MISC_SUB_BSWAP    8'h01
`define MISC_SUB_CPUID    8'h02
`define MISC_SUB_HLT      8'h03
`define MISC_SUB_INVD     8'h04
`define MISC_SUB_WBINVD   8'h05
`define MISC_SUB_INVLPG   8'h06
`define MISC_SUB_LGDT     8'h10
`define MISC_SUB_LIDT     8'h11
`define MISC_SUB_SGDT     8'h12
`define MISC_SUB_SIDT     8'h13
`define MISC_SUB_LMSW     8'h14
`define MISC_SUB_MOV_CR   8'h15
`define MISC_SUB_MOV_FROM_CR 8'h16
`define MISC_SUB_IN       8'h20
`define MISC_SUB_OUT      8'h21
`define MISC_SUB_INT      8'h30
`define MISC_SUB_IRET     8'h31
`define MISC_SUB_MOV_SEG  8'h40
`define MISC_SUB_FAR_JMP  8'h41
`define MISC_SUB_FAR_CALL 8'h42
`define MISC_SUB_FAR_RET  8'h43
`define MISC_SUB_UD       8'h44
`define MISC_SUB_CLTS     8'h50
`define MISC_SUB_SMSW     8'h51
`define MISC_SUB_LLDT     8'h52
`define MISC_SUB_LTR      8'h53
`define MISC_SUB_LAR      8'h54
`define MISC_SUB_LSL      8'h55
`define MISC_SUB_VERR     8'h56
`define MISC_SUB_VERW     8'h57
`define MISC_SUB_LEAVE    8'h58
`define MISC_SUB_ENTER    8'h59
`define MISC_SUB_PUSH_SEG 8'h5A
`define MISC_SUB_POP_SEG  8'h5B
`define MISC_SUB_CBW      8'h5C
`define MISC_SUB_CWDE     8'h5D
`define MISC_SUB_CDQ      8'h5E
`define MISC_SUB_XLAT     8'h5F
`define MISC_SUB_AAA      8'h60
`define MISC_SUB_AAS      8'h61
`define MISC_SUB_DAA      8'h62
`define MISC_SUB_DAS      8'h63
`define MISC_SUB_AAD      8'h64
`define MISC_SUB_AAM      8'h65
`define MISC_SUB_BOUND    8'h66
`define MISC_SUB_ARPL     8'h67
`define MISC_SUB_LDS      8'h68
`define MISC_SUB_LES      8'h69
`define MISC_SUB_LFS      8'h6A
`define MISC_SUB_LGS      8'h6B
`define MISC_SUB_LSS      8'h6C
// Stack / flag tags carried in uop_immediate[7:0] for PUSH/POP variants
`define UOP_TAG_PUSHF     8'hFA
`define UOP_TAG_POPF      8'hFB

`endif
