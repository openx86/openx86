// CPUID
// TODO: use real cpuid_max_EAX
`define cpuid_max_EAX (32'hFFFF_FFFF)
// 3*32/8=12 bytes { EBX, ECX, EDX }, 12 ascii
`define cpuid_manufacturer "OpenX86-Free"
`define cpuid_stepping_id 4'b0
`define cpuid_model_id 4'b0
`define cpuid_family_id 4'b0
`define cpuid_processor_type 2'b0
`define cpuid_extended_model_id 4'b0
`define cpuid_extended_family_id 8'b0
// `define cpuid_revision 1

`define cpuid_brand_index 8'b0
`define cpuid_CLFLUSH_line_size 16'b0
`define cpuid_logical_processors_count 8'b0
`define cpuid_local_APIC_id 8'b0

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
`define cpuid_feature_peg            1'b0
`define cpuid_feature_mca            1'b0
`define cpuid_feature_cmov           1'b0
`define cpuid_feature_pat            1'b0
`define cpuid_feature_pse            1'b0
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
`define bit_width_gpr__0 (2'b00)
`define bit_width_gpr__8 (2'b01)
`define bit_width_gpr_16 (2'b10)
`define bit_width_gpr_32 (2'b11)

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
`define index_reg_gpr__BX (3'b001)
`define index_reg_gpr__CX (3'b010)
`define index_reg_gpr__DX (3'b011)
`define index_reg_gpr__SI (3'b100)
`define index_reg_gpr__DI (3'b101)
`define index_reg_gpr__BP (3'b110)
`define index_reg_gpr__SP (3'b111)

`define index_reg_gpr_EAX (3'b000)
`define index_reg_gpr_EBX (3'b001)
`define index_reg_gpr_ECX (3'b010)
`define index_reg_gpr_EDX (3'b011)
`define index_reg_gpr_ESI (3'b100)
`define index_reg_gpr_EDI (3'b101)
`define index_reg_gpr_EBP (3'b110)
`define index_reg_gpr_ESP (3'b111)

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
