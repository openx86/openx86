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
//  File        : exu_common.h.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Common definitions for execution units
// ============================================================================

`ifndef EXU_COMMON_SVH
`define EXU_COMMON_SVH

// ============================================================
// Execution unit result structure
// ============================================================
typedef struct packed {
    logic [31: 0] result;
    logic         cf;
    logic         pf;
    logic         af;
    logic         zf;
    logic         sf;
    logic         of;
    logic         mem_valid;
    logic         mem_write_enable;
    logic [31: 0] mem_address;
    logic [31: 0] mem_write_data;
} exu_result_t;

// Dispatcher control metadata bundled with datapath result
typedef struct packed {
    exu_result_t  data;
    logic         write_gpr;
    logic         write_flags;
    logic         write_ip;
    logic [31: 0] ip_data;
} exu_dispatch_out_t;

function automatic logic exu_opcode_is_alu(input logic [ 5: 0] opcode);
    return (opcode == `UOP_ADD)  | (opcode == `UOP_SUB)  | (opcode == `UOP_AND) |
           (opcode == `UOP_OR)   | (opcode == `UOP_XOR)  | (opcode == `UOP_ADC) |
           (opcode == `UOP_SBB)   | (opcode == `UOP_INC)  | (opcode == `UOP_DEC) |
           (opcode == `UOP_NEG)   | (opcode == `UOP_NOT)  | (opcode == `UOP_CMP) |
           (opcode == `UOP_TEST);
endfunction

function automatic logic exu_opcode_is_shift(input logic [ 5: 0] opcode);
    return (opcode == `UOP_SHL)  | (opcode == `UOP_SHR)  | (opcode == `UOP_SAR) |
           (opcode == `UOP_ROL)  | (opcode == `UOP_ROR)  | (opcode == `UOP_RCL) |
           (opcode == `UOP_RCR)  | (opcode == `UOP_SHLD) | (opcode == `UOP_SHRD);
endfunction

function automatic logic exu_opcode_is_data_xfer(input logic [ 5: 0] opcode);
    return (opcode == `UOP_MOV)    | (opcode == `UOP_MOVSX) | (opcode == `UOP_MOVZX) |
           (opcode == `UOP_LEA)    | (opcode == `UOP_XCHG);
endfunction

function automatic logic exu_opcode_is_control(input logic [ 5: 0] opcode);
    return (opcode == `UOP_BRANCH) | (opcode == `UOP_CALL) | (opcode == `UOP_RET) |
           (opcode == `UOP_PUSH)   | (opcode == `UOP_POP);
endfunction

function automatic logic exu_opcode_is_muldiv(input logic [ 5: 0] opcode);
    return (opcode == `UOP_MUL) | (opcode == `UOP_IMUL) |
           (opcode == `UOP_DIV) | (opcode == `UOP_IDIV);
endfunction

function automatic logic exu_opcode_is_bitmanip(input logic [ 5: 0] opcode);
    return (opcode == `UOP_BT)  | (opcode == `UOP_BTS) | (opcode == `UOP_BTR) |
           (opcode == `UOP_BTC) | (opcode == `UOP_BSF) | (opcode == `UOP_BSR) |
           (opcode == `UOP_XADD) | (opcode == `UOP_CMPXCHG);
endfunction

function automatic logic exu_opcode_is_misc_simple(input logic [ 7: 0] subcode);
    return (subcode == `MISC_SUB_BSWAP) | (subcode == `MISC_SUB_CPUID) |
           (subcode == `MISC_SUB_CBW)   | (subcode == `MISC_SUB_CWDE) |
           (subcode == `MISC_SUB_CDQ)   | (subcode == `MISC_SUB_AAA) |
           (subcode == `MISC_SUB_AAS)   | (subcode == `MISC_SUB_DAA) |
           (subcode == `MISC_SUB_DAS)   | (subcode == `MISC_SUB_AAD) |
           (subcode == `MISC_SUB_AAM);
endfunction

function automatic logic exu_opcode_dispatched(input logic [ 5: 0] opcode);
    return exu_opcode_is_alu(opcode)       | exu_opcode_is_shift(opcode) |
           exu_opcode_is_data_xfer(opcode) | exu_opcode_is_control(opcode) |
           exu_opcode_is_muldiv(opcode)   | exu_opcode_is_bitmanip(opcode) |
           (opcode == `UOP_SETCC)         | (opcode == `UOP_STRING) |
           (opcode == `UOP_FLAG_CTRL);
endfunction

function automatic logic compute_condition (
    input logic [ 3: 0] tttn_val,
    input logic         of_val,
    input logic         cf_val,
    input logic         zf_val,
    input logic         sf_val,
    input logic         pf_val
);
    case (tttn_val)
        4'h0: compute_condition = of_val;
        4'h1: compute_condition = ~of_val;
        4'h2: compute_condition = cf_val;
        4'h3: compute_condition = ~cf_val;
        4'h4: compute_condition = zf_val;
        4'h5: compute_condition = ~zf_val;
        4'h6: compute_condition = cf_val | zf_val;
        4'h7: compute_condition = ~(cf_val | zf_val);
        4'h8: compute_condition = sf_val;
        4'h9: compute_condition = ~sf_val;
        4'hA: compute_condition = pf_val;
        4'hB: compute_condition = ~pf_val;
        4'hC: compute_condition = sf_val ^ of_val;                 // JL/JNGE
        4'hD: compute_condition = ~(sf_val ^ of_val);              // JNL/JGE
        4'hE: compute_condition = (sf_val ^ of_val) | zf_val;      // JLE/JNG
        4'hF: compute_condition = ~((sf_val ^ of_val) | zf_val);   // JG/JNLE
        default: compute_condition = 1'b0;
    endcase
endfunction

// ============================================================
// Flag computation helper functions
// ============================================================

// Pack arith/logic status flags into architected EFLAGS bit positions.
// Preserves TF/IF/DF/IOPL/NT/RF/VM from base (ALU ops must not clear IF).
function automatic logic [31: 0] pack_eflags_status (
    input logic [31: 0] base,
    input logic         cf_val,
    input logic         pf_val,
    input logic         af_val,
    input logic         zf_val,
    input logic         sf_val,
    input logic         of_val
);
    logic [31: 0] r;
    r        = base;
    r[0]     = cf_val;
    r[1]     = 1'b1; // reserved, always 1
    r[2]     = pf_val;
    r[4]     = af_val;
    r[6]     = zf_val;
    r[7]     = sf_val;
    r[11]    = of_val;
    return r;
endfunction

// Parity flag: even parity of low 8 bits
function automatic logic compute_pf (input logic [31: 0] data);
    logic [ 7: 0] byte_val;
    logic [ 3: 0] nibble0;
    logic [ 3: 0] nibble1;
    logic         parity;
    byte_val = data[ 7: 0];
    nibble0 = ^byte_val[ 3: 0];
    nibble1 = ^byte_val[ 7: 4];
    parity = ~(nibble0 ^ nibble1);
    return parity;
endfunction

// Zero flag
function automatic logic compute_zf (input logic [31: 0] data);
    return (data == 32'd0);
endfunction

// Sign flag
function automatic logic compute_sf (input logic [31: 0] data);
    return data[31];
endfunction

// Auxiliary carry flag (for BCD arithmetic)
function automatic logic compute_af (input logic [31: 0] src1,
                                     input logic [31: 0] src2,
                                     input logic         is_sub);
    logic [ 3: 0] low_src1;
    logic [ 3: 0] low_src2;
    logic [ 4: 0] low_result;
    low_src1 = src1[ 3: 0];
    low_src2 = src2[ 3: 0];
    if (is_sub) begin
        low_result = low_src1 - low_src2;
    end else begin
        low_result = low_src1 + low_src2;
    end
    return low_result[4];
endfunction

// Carry flag for addition
function automatic logic compute_cf_add (input logic [31: 0] src1,
                                         input logic [31: 0] src2);
    logic [32: 0] result;
    result = src1 + src2;
    return result[32];
endfunction

// Carry flag for subtraction (borrow)
function automatic logic compute_cf_sub (input logic [31: 0] src1,
                                         input logic [31: 0] src2);
    return (src1 < src2);
endfunction

// Overflow flag for addition
function automatic logic compute_of_add (input logic [31: 0] src1,
                                         input logic [31: 0] src2);
    logic         src1_sign;
    logic         src2_sign;
    logic [31: 0] result;
    logic         result_sign;
    src1_sign = src1[31];
    src2_sign = src2[31];
    result = src1 + src2;
    result_sign = result[31];
    return (~src1_sign & ~src2_sign & result_sign) | (src1_sign & src2_sign & ~result_sign);
endfunction

// Overflow flag for subtraction
function automatic logic compute_of_sub (input logic [31: 0] src1,
                                         input logic [31: 0] src2);
    logic         src1_sign;
    logic         src2_sign;
    logic [31: 0] result;
    logic         result_sign;
    src1_sign = src1[31];
    src2_sign = src2[31];
    result = src1 - src2;
    result_sign = result[31];
    return (~src1_sign & src2_sign & result_sign) | (src1_sign & ~src2_sign & ~result_sign);
endfunction

// Carry flag for addition with carry
function automatic logic compute_cf_adc (input logic [31: 0] src1,
                                         input logic [31: 0] src2,
                                         input logic         cf_in);
    logic [32: 0] result;
    result = src1 + src2 + cf_in;
    return result[32];
endfunction

// Overflow flag for addition with carry
function automatic logic compute_of_adc (input logic [31: 0] src1,
                                         input logic [31: 0] src2,
                                         input logic         cf_in);
    logic         src1_sign;
    logic         src2_sign;
    logic [31: 0] result;
    logic         result_sign;
    src1_sign = src1[31];
    src2_sign = src2[31];
    result = src1 + src2 + cf_in;
    result_sign = result[31];
    return (~src1_sign & ~src2_sign & result_sign) | (src1_sign & src2_sign & ~result_sign);
endfunction

// Carry flag for subtraction with borrow
function automatic logic compute_cf_sbb (input logic [31: 0] src1,
                                         input logic [31: 0] src2,
                                         input logic         cf_in);
    logic [32: 0] result;
    result = src1 - src2 - cf_in;
    return result[32];
endfunction

// Overflow flag for subtraction with borrow
function automatic logic compute_of_sbb (input logic [31: 0] src1,
                                         input logic [31: 0] src2,
                                         input logic         cf_in);
    logic         src1_sign;
    logic         src2_sign;
    logic [31: 0] result;
    logic         result_sign;
    src1_sign = src1[31];
    src2_sign = src2[31];
    result = src1 - src2 - cf_in;
    result_sign = result[31];
    return (~src1_sign & src2_sign & result_sign) | (src1_sign & ~src2_sign & ~result_sign);
endfunction

// Overflow flag for increment
function automatic logic compute_of_inc (input logic [31: 0] src1);
    logic         src1_sign;
    logic [31: 0] result;
    logic         result_sign;
    src1_sign = src1[31];
    result = src1 + 32'd1;
    result_sign = result[31];
    return src1_sign & ~result_sign;
endfunction

// Overflow flag for decrement
function automatic logic compute_of_dec (input logic [31: 0] src1);
    logic         src1_sign;
    logic [31: 0] result;
    logic         result_sign;
    src1_sign = src1[31];
    result = src1 - 32'd1;
    result_sign = result[31];
    return ~src1_sign & result_sign;
endfunction

// ============================================================
// Register index to write enable mapping
// ============================================================

// GPR index mapping (32-bit registers)
// 0: EAX, 1: ECX, 2: EDX, 3: EBX, 4: ESP, 5: EBP, 6: ESI, 7: EDI

// Segment register index mapping
// 0: ES, 1: CS, 2: SS, 3: DS, 4: FS, 5: GS

`endif
