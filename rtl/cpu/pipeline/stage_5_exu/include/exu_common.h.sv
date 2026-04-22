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

// ============================================================
// Flag computation helper functions
// ============================================================

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
