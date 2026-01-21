// ============================================================================
// x86 core shared types (minimal)
// - Keep modules small and testable
// - No absolute-path includes
// - Compatible with iverilog (wrapped in module for compatibility)
// ============================================================================

// Note: iverilog has limited support for file-level typedef.
// Types are defined here but may need to be redeclared in modules that use them.
// For full SystemVerilog simulators, these can be used directly.

// Instruction bytes buffer (max 16 bytes, enough for legacy longest = 15)
// typedef logic [7:0] x86_instr_bytes_t [0:15];

// Macro operation kinds
// typedef enum logic [2:0] {
//   X86_MACRO_NOP   = 3'd0,
//   X86_MACRO_MOVI  = 3'd1,
//   X86_MACRO_ADDI  = 3'd2,
//   X86_MACRO_HLT   = 3'd3,
//   X86_MACRO_UNK   = 3'd7
// } x86_macro_kind_t;

// For iverilog compatibility, we use localparam and manual encoding
`define X86_MACRO_NOP   3'd0
`define X86_MACRO_MOVI  3'd1
`define X86_MACRO_ADDI  3'd2
`define X86_MACRO_HLT   3'd3
`define X86_MACRO_UNK   3'd7

`define X86_UOP_NONE       3'd0
`define X86_UOP_WRITE_GPR  3'd1
`define X86_UOP_ALU_ADD    3'd2
`define X86_UOP_HALT       3'd3

// Macro operation structure (packed, 42 bits total)
// [41:39] = kind (3 bits)
// [38:36] = reg_idx (3 bits)
// [35:4]  = imm (32 bits)
// [3:0]   = length (4 bits)
// Note: valid bit handled separately in modules

// UOP structure (packed, 39 bits total)
// [38:36] = kind (3 bits)
// [35:33] = dst_gpr (3 bits)
// [32:1]  = src_imm (32 bits)
// [0]     = last (1 bit)
// Note: valid bit handled separately in modules
