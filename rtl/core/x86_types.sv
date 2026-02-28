// ============================================================================
// x86 core shared types (minimal)
// - Keep modules small and testable
// - No absolute-path includes
// - Compatible with iverilog (wrapped in module for compatibility)
// ============================================================================

`ifndef X86_TYPES_SV
`define X86_TYPES_SV

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

// Aliases without prefix for testbench compatibility
`define UOP_NONE       3'd0
`define UOP_WRITE_GPR  3'd1
`define UOP_ALU_ADD    3'd2
`define UOP_HALT       3'd3

// Macro operation structure (packed, 43 bits total)
// [42]    = valid
// [41:39] = kind (3 bits)
// [38:36] = reg_idx (3 bits)
// [35:4]  = imm (32 bits)
// [3:0]   = length (4 bits)
typedef struct packed {
    logic        valid;
    logic [2:0]  kind;
    logic [2:0]  reg_idx;
    logic [31:0] imm;
    logic [3:0]  length;
} x86_macro_op_t;

// UOP structure (packed, 41 bits total)
// [40]    = valid
// [39]    = last
// [38:36] = kind (3 bits)
// [35:33] = dst_gpr (3 bits)
// [32:1]  = src_imm (32 bits) -- note: src_imm uses [31:0] in the struct
// [0]     = (padding)
typedef struct packed {
    logic        valid;
    logic        last;
    logic [2:0]  kind;
    logic [2:0]  dst_gpr;
    logic [31:0] src_imm;
} x86_uop_t;

`endif // X86_TYPES_SV
