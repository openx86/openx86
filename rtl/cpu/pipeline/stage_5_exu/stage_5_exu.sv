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
//  File        : stage_5_exu.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Execute unit — receives micro_op_t and operand data from
//                stage_4_reg, decodes uop to sub-unit control signals,
//                dispatches to ALU/branch/muldiv/FPU/AGU/LSU
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module stage_5_exu (
    // =========================
    // Pipeline handshake
    // =========================
    input  logic                i_uop_valid,
    input  micro_op_t           i_uop,
    output logic                o_stage_ready,
    output logic                o_stage_valid,
    input  logic                i_wrb_ready,

    // =========================
    // Operand data from stage_4_reg
    // =========================
    input  logic [31: 0]        i_src1_data,
    input  logic [31: 0]        i_src2_data,

    // =========================
    // Flag inputs from stage_4_reg
    // =========================
    input  logic                i_cf,
    input  logic                i_pf,
    input  logic                i_af,
    input  logic                i_zf,
    input  logic                i_sf,
    input  logic                i_of,

    // =========================
    // Write-back outputs to i486_cpu_core
    // =========================
    output logic                o_wrb_gpr_enable_EAX,
    output logic                o_wrb_gpr_enable_AX,
    output logic                o_wrb_gpr_enable_AL,
    output logic                o_wrb_gpr_enable_AH,
    output logic                o_wrb_gpr_enable_EBX,
    output logic                o_wrb_gpr_enable_BX,
    output logic                o_wrb_gpr_enable_BL,
    output logic                o_wrb_gpr_enable_BH,
    output logic                o_wrb_gpr_enable_ECX,
    output logic                o_wrb_gpr_enable_CX,
    output logic                o_wrb_gpr_enable_CL,
    output logic                o_wrb_gpr_enable_CH,
    output logic                o_wrb_gpr_enable_EDX,
    output logic                o_wrb_gpr_enable_DX,
    output logic                o_wrb_gpr_enable_DL,
    output logic                o_wrb_gpr_enable_DH,
    output logic                o_wrb_gpr_enable_ESP,
    output logic                o_wrb_gpr_enable_SP,
    output logic                o_wrb_gpr_enable_EBP,
    output logic                o_wrb_gpr_enable_BP,
    output logic                o_wrb_gpr_enable_ESI,
    output logic                o_wrb_gpr_enable_SI,
    output logic                o_wrb_gpr_enable_EDI,
    output logic                o_wrb_gpr_enable_DI,
    output logic [31: 0]        o_wrb_gpr_data_EAX,
    output logic [15: 0]        o_wrb_gpr_data_AX,
    output logic [ 7: 0]        o_wrb_gpr_data_AL,
    output logic [ 7: 0]        o_wrb_gpr_data_AH,
    output logic [31: 0]        o_wrb_gpr_data_EBX,
    output logic [15: 0]        o_wrb_gpr_data_BX,
    output logic [ 7: 0]        o_wrb_gpr_data_BL,
    output logic [ 7: 0]        o_wrb_gpr_data_BH,
    output logic [31: 0]        o_wrb_gpr_data_ECX,
    output logic [15: 0]        o_wrb_gpr_data_CX,
    output logic [ 7: 0]        o_wrb_gpr_data_CL,
    output logic [ 7: 0]        o_wrb_gpr_data_CH,
    output logic [31: 0]        o_wrb_gpr_data_EDX,
    output logic [15: 0]        o_wrb_gpr_data_DX,
    output logic [ 7: 0]        o_wrb_gpr_data_DL,
    output logic [ 7: 0]        o_wrb_gpr_data_DH,
    output logic [31: 0]        o_wrb_gpr_data_ESP,
    output logic [15: 0]        o_wrb_gpr_data_SP,
    output logic [31: 0]        o_wrb_gpr_data_EBP,
    output logic [15: 0]        o_wrb_gpr_data_BP,
    output logic [31: 0]        o_wrb_gpr_data_ESI,
    output logic [15: 0]        o_wrb_gpr_data_SI,
    output logic [31: 0]        o_wrb_gpr_data_EDI,
    output logic [15: 0]        o_wrb_gpr_data_DI,
    output logic                o_wrb_seg_enable_es,
    output logic                o_wrb_seg_enable_cs,
    output logic                o_wrb_seg_enable_ss,
    output logic                o_wrb_seg_enable_ds,
    output logic                o_wrb_seg_enable_fs,
    output logic                o_wrb_seg_enable_gs,
    output logic [15: 0]        o_wrb_seg_selector,
    output logic [63: 0]        o_wrb_seg_descriptor,
    output logic                o_wrb_flags_enable,
    output logic [31: 0]        o_wrb_flags_data,
    output logic                o_wrb_ip_enable,
    output logic [31: 0]        o_wrb_ip_data,
    output logic                o_mem_valid,
    output logic                o_mem_write_enable,
    output logic [31: 0]        o_mem_address,
    output logic [31: 0]        o_mem_write_data,

    // =========================
    // Clock and reset
    // =========================
    input  logic                clk,
    input  logic                rst_n
);

    logic [31: 0] src1_data;
    logic [31: 0] src2_data;
    logic [31: 0] immediate;
    logic [31: 0] displacement;
    logic [ 2: 0] dest_reg;
    logic [ 3: 0] tttn;
    logic         has_imm;
    logic         has_disp;
    logic         mem_access;
    logic         is_store;
    logic [ 5: 0] uop_opcode;

    logic [31: 0] result;
    logic         new_cf;
    logic         new_pf;
    logic         new_zf;
    logic         new_sf;
    logic         new_of;
    logic [31: 0] flags_data;
    logic         write_gpr;
    logic         write_flags;
    logic         write_ip;
    logic [31: 0] ip_data;
    logic         mem_valid;
    logic         mem_write_enable;
    logic [31: 0] mem_address;
    logic [31: 0] mem_write_data;

    // Temporary variables for case statements
    logic [15: 0] tmp_src_16;
    logic [31: 0] tmp_sum;
    logic [31: 0] tmp_diff;
    logic [31: 0] tmp_res;
    logic [31: 0] tmp_src;
    logic [31: 0] tmp_new_esp;
    logic [31: 0] tmp_target;
    logic [ 4: 0] tmp_shift_count;
    logic [31: 0] tmp_operand;
    logic [ 4: 0] tmp_bit_index;
    logic [32: 0] tmp_ext_src;
    logic [63: 0] tmp_combined;
    logic [63: 0] tmp_dividend;
    logic signed [63: 0] tmp_dividend_signed;
    logic [31: 0] tmp_tmp_divisor;
    logic signed [31: 0] tmp_tmp_divisor_signed;

    assign src1_data = i_src1_data;
    assign src2_data = i_src2_data;
    assign immediate = i_uop.uop_immediate;
    assign displacement = i_uop.uop_displacement;
    assign dest_reg = i_uop.uop_dest_reg;
    assign tttn = i_uop.uop_tttn;
    assign has_imm = i_uop.uop_has_imm;
    assign has_disp = i_uop.uop_has_disp;
    assign mem_access = i_uop.uop_mem_access;
    assign is_store = i_uop.uop_is_store;
    assign uop_opcode = i_uop.uop_opcode;

    // Function to compute condition based on tttn
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
            4'hC: compute_condition = sf_val ^ of_val;
            4'hD: compute_condition = ~(sf_val ^ of_val);
            4'hE: compute_condition = sf_val ^ of_val ^ cf_val;
            4'hF: compute_condition = 1'b1;
            default: compute_condition = 1'b0;
        endcase
    endfunction

    always_comb begin
        result = 32'd0;
        new_cf = i_cf;
        new_pf = i_pf;
        new_zf = i_zf;
        new_sf = i_sf;
        new_of = i_of;
        flags_data = {10'b0, i_of, 1'b0, 1'b0, 1'b0, i_sf, i_zf, 1'b0, i_pf, 1'b0, i_cf};
        write_gpr = 1'b0;
        write_flags = 1'b0;
        write_ip = 1'b0;
        ip_data = 32'd0;
        mem_valid = 1'b0;
        mem_write_enable = 1'b0;
        mem_address = 32'd0;
        mem_write_data = 32'd0;

        if (i_uop_valid) begin
            case (uop_opcode)
                `UOP_ADD: begin
                    tmp_sum = src1_data + src2_data;
                    result = tmp_sum;
                    new_cf = compute_cf_add(src1_data, src2_data);
                    new_pf = compute_pf(tmp_sum);
                    new_zf = compute_zf(tmp_sum);
                    new_sf = compute_sf(tmp_sum);
                    new_of = compute_of_add(src1_data, src2_data);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_SUB: begin
                    tmp_diff = src1_data - src2_data;
                    result = tmp_diff;
                    new_cf = compute_cf_sub(src1_data, src2_data);
                    new_pf = compute_pf(tmp_diff);
                    new_zf = compute_zf(tmp_diff);
                    new_sf = compute_sf(tmp_diff);
                    new_of = compute_of_sub(src1_data, src2_data);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_AND: begin
                    tmp_res = src1_data & src2_data;
                    result = tmp_res;
                    new_cf = 1'b0;
                    new_of = 1'b0;
                    new_pf = compute_pf(tmp_res);
                    new_zf = compute_zf(tmp_res);
                    new_sf = compute_sf(tmp_res);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_OR: begin
                    tmp_res = src1_data | src2_data;
                    result = tmp_res;
                    new_cf = 1'b0;
                    new_of = 1'b0;
                    new_pf = compute_pf(tmp_res);
                    new_zf = compute_zf(tmp_res);
                    new_sf = compute_sf(tmp_res);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_XOR: begin
                    tmp_res = src1_data ^ src2_data;
                    result = tmp_res;
                    new_cf = 1'b0;
                    new_of = 1'b0;
                    new_pf = compute_pf(tmp_res);
                    new_zf = compute_zf(tmp_res);
                    new_sf = compute_sf(tmp_res);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_MOV: begin
                    result = has_imm ? immediate : src2_data;
                    write_gpr = 1'b1;
                end
                `UOP_CMP: begin
                    tmp_diff = src1_data - src2_data;
                    new_cf = compute_cf_sub(src1_data, src2_data);
                    new_pf = compute_pf(tmp_diff);
                    new_zf = compute_zf(tmp_diff);
                    new_sf = compute_sf(tmp_diff);
                    new_of = compute_of_sub(src1_data, src2_data);
                    write_flags = 1'b1;
                end
                `UOP_ADC: begin
                    tmp_sum = src1_data + src2_data + i_cf;
                    result = tmp_sum;
                    new_cf = compute_cf_adc(src1_data, src2_data, i_cf);
                    new_pf = compute_pf(tmp_sum);
                    new_zf = compute_zf(tmp_sum);
                    new_sf = compute_sf(tmp_sum);
                    new_of = compute_of_adc(src1_data, src2_data, i_cf);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_SBB: begin
                    tmp_diff = src1_data - src2_data - i_cf;
                    result = tmp_diff;
                    new_cf = compute_cf_sbb(src1_data, src2_data, i_cf);
                    new_pf = compute_pf(tmp_diff);
                    new_zf = compute_zf(tmp_diff);
                    new_sf = compute_sf(tmp_diff);
                    new_of = compute_of_sbb(src1_data, src2_data, i_cf);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_INC: begin
                    tmp_res = src1_data + 32'd1;
                    result = tmp_res;
                    new_pf = compute_pf(tmp_res);
                    new_zf = compute_zf(tmp_res);
                    new_sf = compute_sf(tmp_res);
                    new_of = compute_of_inc(src1_data);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_DEC: begin
                    tmp_res = src1_data - 32'd1;
                    result = tmp_res;
                    new_pf = compute_pf(tmp_res);
                    new_zf = compute_zf(tmp_res);
                    new_sf = compute_sf(tmp_res);
                    new_of = compute_of_dec(src1_data);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_NEG: begin
                    tmp_res = ~src1_data + 32'd1;
                    result = tmp_res;
                    new_cf = (src1_data != 32'd0);
                    new_pf = compute_pf(tmp_res);
                    new_zf = compute_zf(tmp_res);
                    new_sf = compute_sf(tmp_res);
                    new_of = (src1_data == 32'h80000000);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_NOT: begin
                    result = ~src1_data;
                    write_gpr = 1'b1;
                end
                `UOP_TEST: begin
                    tmp_res = src1_data & src2_data;
                    new_cf = 1'b0;
                    new_of = 1'b0;
                    new_pf = compute_pf(tmp_res);
                    new_zf = compute_zf(tmp_res);
                    new_sf = compute_sf(tmp_res);
                    write_flags = 1'b1;
                end
                `UOP_SHL: begin
                    tmp_shift_count = src2_data[4: 0];
                    tmp_res = src1_data << tmp_shift_count;
                    result = tmp_res;
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = (shift_count > 5'd0) ? src1_data[32'd32 - shift_count] : src1_data[0];
                        new_of = (shift_count == 5'd1) ? (src1_data[31] ^ res[31]) : i_of;
                        new_pf = compute_pf(tmp_res);
                        new_zf = compute_zf(tmp_res);
                        new_sf = compute_sf(tmp_res);
                    end
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_SHR: begin
                    tmp_shift_count = src2_data[4: 0];
                    tmp_res = src1_data >> tmp_shift_count;
                    result = tmp_res;
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = (shift_count > 5'd0) ? src1_data[shift_count - 5'd1] : src1_data[31];
                        new_of = (shift_count == 5'd1) ? src1_data[31] : 1'b0;
                        new_pf = compute_pf(tmp_res);
                        new_zf = compute_zf(tmp_res);
                        new_sf = compute_sf(tmp_res);
                    end
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_SAR: begin
                    tmp_shift_count = src2_data[4: 0];
                    tmp_res = $signed(src1_data) >>> tmp_shift_count;
                    result = tmp_res;
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = (shift_count > 5'd0) ? src1_data[shift_count - 5'd1] : src1_data[31];
                        new_of = 1'b0;
                        new_pf = compute_pf(tmp_res);
                        new_zf = compute_zf(tmp_res);
                        new_sf = compute_sf(tmp_res);
                    end
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_ROL: begin
                    tmp_shift_count = src2_data[4: 0];
                    tmp_res = (src1_data << tmp_shift_count) | (src1_data >> (32'd32 - shift_count));
                    result = tmp_res;
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = (shift_count == 5'd0) ? i_cf : src1_data[32'd32 - shift_count];
                        new_of = (shift_count == 5'd1) ? (src1_data[31] ^ res[31]) : i_of;
                    end
                    write_gpr = 1'b1;
                end
                `UOP_ROR: begin
                    tmp_shift_count = src2_data[4: 0];
                    tmp_res = (src1_data >> tmp_shift_count) | (src1_data << (32'd32 - shift_count));
                    result = tmp_res;
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = (shift_count == 5'd0) ? i_cf : src1_data[shift_count - 5'd1];
                        new_of = (shift_count == 5'd1) ? (res[31] ^ src1_data[31]) : i_of;
                    end
                    write_gpr = 1'b1;
                end
                `UOP_RCL: begin
                    tmp_shift_count = src2_data[4: 0];
                    tmp_tmp_ext_src = {i_cf, src1_data};
                    tmp_res = (tmp_ext_src << tmp_shift_count) | (tmp_ext_src >> (33'd33 - shift_count));
                    result = tmp_res[31: 0];
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = res[32];
                        new_of = (shift_count == 5'd1) ? (res[31] ^ src1_data[31]) : i_of;
                    end
                    write_gpr = 1'b1;
                end
                `UOP_RCR: begin
                    tmp_shift_count = src2_data[4: 0];
                    tmp_tmp_ext_src = {src1_data, i_cf};
                    tmp_res = (tmp_ext_src >> tmp_shift_count) | (tmp_ext_src << (33'd33 - shift_count));
                    result = tmp_res[31: 0];
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = res[0];
                        new_of = (shift_count == 5'd1) ? (src1_data[31] ^ res[31]) : i_of;
                    end
                    write_gpr = 1'b1;
                end
                `UOP_SHLD: begin
                    tmp_shift_count = src2_data[4: 0];
                    tmp_tmp_combined = {src1_data, src2_data};
                    tmp_res = tmp_combined[31: 0] << tmp_shift_count;
                    result = tmp_res;
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = (shift_count > 5'd0) ? combined[32'd32 - shift_count] : combined[31];
                        new_of = (shift_count == 5'd1) ? (src1_data[31] ^ res[31]) : i_of;
                        new_pf = compute_pf(tmp_res);
                        new_zf = compute_zf(tmp_res);
                        new_sf = compute_sf(tmp_res);
                    end
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_SHRD: begin
                    tmp_shift_count = src2_data[4: 0];
                    tmp_tmp_combined = {src1_data, src2_data};
                    tmp_res = tmp_combined[63: 32] >> tmp_shift_count;
                    result = tmp_res;
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = (shift_count > 5'd0) ? combined[shift_count - 5'd1] : combined[32];
                        new_of = (shift_count == 5'd1) ? (src1_data[31] ^ res[31]) : i_of;
                        new_pf = compute_pf(tmp_res);
                        new_zf = compute_zf(tmp_res);
                        new_sf = compute_sf(tmp_res);
                    end
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_BT: begin
                    tmp_bit_index = src2_data[4: 0];
                    new_cf = src1_data[tmp_bit_index];
                    write_flags = 1'b1;
                end
                `UOP_BTS: begin
                    tmp_bit_index = src2_data[4: 0];
                    new_cf = src1_data[tmp_bit_index];
                    result = src1_data;
                    result[tmp_bit_index] = 1'b1;
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_BTR: begin
                    tmp_bit_index = src2_data[4: 0];
                    new_cf = src1_data[tmp_bit_index];
                    result = src1_data;
                    result[tmp_bit_index] = 1'b0;
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_BTC: begin
                    tmp_bit_index = src2_data[4: 0];
                    new_cf = src1_data[tmp_bit_index];
                    result = src1_data;
                    result[tmp_bit_index] = ~src1_data[tmp_bit_index];
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_BSF: begin
                    tmp_bit_index = 5'd0;
                    tmp_operand = src1_data;
                    if (tmp_operand != 32'd0) begin
                        case (1'b1)
                            operand[0]:  bit_index = 5'd0;
                            operand[1]:  bit_index = 5'd1;
                            operand[2]:  bit_index = 5'd2;
                            operand[3]:  bit_index = 5'd3;
                            operand[4]:  bit_index = 5'd4;
                            operand[5]:  bit_index = 5'd5;
                            operand[6]:  bit_index = 5'd6;
                            operand[7]:  bit_index = 5'd7;
                            operand[8]:  bit_index = 5'd8;
                            operand[9]:  bit_index = 5'd9;
                            operand[10]: bit_index = 5'd10;
                            operand[11]: bit_index = 5'd11;
                            operand[12]: bit_index = 5'd12;
                            operand[13]: bit_index = 5'd13;
                            operand[14]: bit_index = 5'd14;
                            operand[15]: bit_index = 5'd15;
                            operand[16]: bit_index = 5'd16;
                            operand[17]: bit_index = 5'd17;
                            operand[18]: bit_index = 5'd18;
                            operand[19]: bit_index = 5'd19;
                            operand[20]: bit_index = 5'd20;
                            operand[21]: bit_index = 5'd21;
                            operand[22]: bit_index = 5'd22;
                            operand[23]: bit_index = 5'd23;
                            operand[24]: bit_index = 5'd24;
                            operand[25]: bit_index = 5'd25;
                            operand[26]: bit_index = 5'd26;
                            operand[27]: bit_index = 5'd27;
                            operand[28]: bit_index = 5'd28;
                            operand[29]: bit_index = 5'd29;
                            operand[30]: bit_index = 5'd30;
                            operand[31]: bit_index = 5'd31;
                            default:  bit_index = 5'd0;
                        endcase
                        result = {27'd0, bit_index};
                        write_gpr = 1'b1;
                        write_flags = 1'b1;
                    end
                    new_zf = (operand == 32'd0);
                    write_flags = 1'b1;
                end
                `UOP_BSR: begin
                    tmp_bit_index = 5'd0;
                    tmp_operand = src1_data;
                    if (tmp_operand != 32'd0) begin
                        case (1'b1)
                            operand[31]: bit_index = 5'd31;
                            operand[30]: bit_index = 5'd30;
                            operand[29]: bit_index = 5'd29;
                            operand[28]: bit_index = 5'd28;
                            operand[27]: bit_index = 5'd27;
                            operand[26]: bit_index = 5'd26;
                            operand[25]: bit_index = 5'd25;
                            operand[24]: bit_index = 5'd24;
                            operand[23]: bit_index = 5'd23;
                            operand[22]: bit_index = 5'd22;
                            operand[21]: bit_index = 5'd21;
                            operand[20]: bit_index = 5'd20;
                            operand[19]: bit_index = 5'd19;
                            operand[18]: bit_index = 5'd18;
                            operand[17]: bit_index = 5'd17;
                            operand[16]: bit_index = 5'd16;
                            operand[15]: bit_index = 5'd15;
                            operand[14]: bit_index = 5'd14;
                            operand[13]: bit_index = 5'd13;
                            operand[12]: bit_index = 5'd12;
                            operand[11]: bit_index = 5'd11;
                            operand[10]: bit_index = 5'd10;
                            operand[9]:  bit_index = 5'd9;
                            operand[8]:  bit_index = 5'd8;
                            operand[7]:  bit_index = 5'd7;
                            operand[6]:  bit_index = 5'd6;
                            operand[5]:  bit_index = 5'd5;
                            operand[4]:  bit_index = 5'd4;
                            operand[3]:  bit_index = 5'd3;
                            operand[2]:  bit_index = 5'd2;
                            operand[1]:  bit_index = 5'd1;
                            operand[0]:  bit_index = 5'd0;
                            default:  bit_index = 5'd0;
                        endcase
                        result = {27'd0, bit_index};
                        write_gpr = 1'b1;
                        write_flags = 1'b1;
                    end
                    new_zf = (operand == 32'd0);
                    write_flags = 1'b1;
                end
                `UOP_MOVSX: begin
                    tmp_src_16 = has_imm ? immediate[15: 0] : src2_data[15: 0];
                    result = {{16{tmp_src_16[15]}}, tmp_src_16};
                    write_gpr = 1'b1;
                end
                `UOP_MOVZX: begin
                    tmp_src_16 = has_imm ? immediate[15: 0] : src2_data[15: 0];
                    result = {16'd0, tmp_src_16};
                    write_gpr = 1'b1;
                end
                `UOP_XCHG: begin
                    result = src2_data;
                    write_gpr = 1'b1;
                end
                `UOP_LEA: begin
                    result = src1_data + src2_data + displacement;
                    write_gpr = 1'b1;
                end
                `UOP_XADD: begin
                    tmp_sum = src1_data + src2_data;
                    result = tmp_sum;
                    new_cf = compute_cf_add(src1_data, src2_data);
                    new_pf = compute_pf(tmp_sum);
                    new_zf = compute_zf(tmp_sum);
                    new_sf = compute_sf(tmp_sum);
                    new_of = compute_of_add(src1_data, src2_data);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_CMPXCHG: begin
                    tmp_diff = src1_data - src2_data;
                    new_cf = compute_cf_sub(src1_data, src2_data);
                    new_pf = compute_pf(tmp_diff);
                    new_zf = compute_zf(tmp_diff);
                    new_sf = compute_sf(tmp_diff);
                    new_of = compute_of_sub(src1_data, src2_data);
                    if (src1_data == src2_data) begin
                        result = src2_data;
                    end else begin
                        result = src1_data;
                    end
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_PUSH: begin
                    tmp_src = has_imm ? immediate : src1_data;
                    tmp_new_esp = src2_data - 32'd4;
                    result = tmp_new_esp;
                    mem_address = new_esp;
                    mem_write_data = src;
                    mem_valid = 1'b1;
                    mem_write_enable = 1'b1;
                    write_gpr = 1'b1;
                end
                `UOP_POP: begin
                    tmp_new_esp = src1_data + 32'd4;
                    result = has_imm ? new_esp + immediate : src2_data;
                    mem_address = src1_data;
                    mem_valid = 1'b1;
                    mem_write_enable = 1'b0;
                    write_gpr = 1'b1;
                end
                `UOP_BRANCH: begin
                    tmp_target = has_disp ? displacement : immediate;
                    tmp_condition_met = compute_condition(tttn, i_of, i_cf, i_zf, i_sf, i_pf);
                    if (condition_met) begin
                        ip_data = target;
                        write_ip = 1'b1;
                    end
                end
                `UOP_CALL: begin
                    tmp_target = has_disp ? displacement : immediate;
                    tmp_new_esp = src2_data - 32'd4;
                    result = tmp_new_esp;
                    mem_address = new_esp;
                    mem_write_data = src1_data;
                    mem_valid = 1'b1;
                    mem_write_enable = 1'b1;
                    ip_data = target;
                    write_gpr = 1'b1;
                    write_ip = 1'b1;
                end
                `UOP_RET: begin
                    tmp_new_esp = has_imm ? (src1_data + immediate) : (src1_data + 32'd4);
                    result = tmp_new_esp;
                    mem_address = src1_data;
                    mem_valid = 1'b1;
                    mem_write_enable = 1'b0;
                    ip_data = src2_data;
                    write_gpr = 1'b1;
                    write_ip = 1'b1;
                end
                `UOP_SETCC: begin
                    tmp_condition_met = compute_condition(tttn, i_of, i_cf, i_zf, i_sf, i_pf);
                    result = condition_met ? 32'd1 : 32'd0;
                    write_gpr = 1'b1;
                end
                `UOP_STRING: begin
                    result = 32'd0;
                end
                `UOP_FLAG_CTRL: begin
                    result = 32'd0;
                end
                `UOP_MISC: begin
                    result = 32'd0;
                end
                `UOP_X87: begin
                    result = 32'd0;
                end
                `UOP_NOP: begin
                    result = 32'd0;
                end
                `UOP_MUL: begin
                    logic [63: 0] product = src1_data * src2_data;
                    result = product[31: 0];
                    new_cf = product[63: 32] != 32'd0;
                    new_of = product[63: 32] != 32'd0;
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_IMUL: begin
                    logic signed [63: 0] product = $signed(src1_data) * $signed(src2_data);
                    result = product[31: 0];
                    new_cf = (product[63: 32] != 32'sd0) && (product[63: 32] != 32'hFFFFFFFF);
                    new_of = (product[63: 32] != 32'sd0) && (product[63: 32] != 32'hFFFFFFFF);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_DIV: begin
                    tmp_dividend = {src1_data, src2_data};
                    tmp_divisor = src2_data;
                    if (tmp_divisor != 32'd0) begin
                        result = tmp_dividend[31: 0] / tmp_divisor;
                    end
                    write_gpr = 1'b1;
                end
                `UOP_IDIV: begin
                    tmp_dividend_signed = {src1_data, src2_data};
                    tmp_divisor_signed = src2_data;
                    if (tmp_divisor != 32'sd0) begin
                        result = tmp_dividend[31: 0] / tmp_divisor;
                    end
                    write_gpr = 1'b1;
                end
                default: begin
                    result = 32'd0;
                end
            endcase

            flags_data = {10'b0, new_of, 1'b0, 1'b0, 1'b0, new_sf, new_zf, 1'b0, new_pf, 1'b0, new_cf};
        end
    end

    assign o_stage_ready = i_wrb_ready;
    assign o_stage_valid = i_uop_valid;

    always_comb begin
        o_wrb_gpr_enable_EAX = 1'b0;
        o_wrb_gpr_enable_AX  = 1'b0;
        o_wrb_gpr_enable_AL  = 1'b0;
        o_wrb_gpr_enable_AH  = 1'b0;
        o_wrb_gpr_enable_EBX = 1'b0;
        o_wrb_gpr_enable_BX  = 1'b0;
        o_wrb_gpr_enable_BL  = 1'b0;
        o_wrb_gpr_enable_BH  = 1'b0;
        o_wrb_gpr_enable_ECX = 1'b0;
        o_wrb_gpr_enable_CX  = 1'b0;
        o_wrb_gpr_enable_CL  = 1'b0;
        o_wrb_gpr_enable_CH  = 1'b0;
        o_wrb_gpr_enable_EDX = 1'b0;
        o_wrb_gpr_enable_DX  = 1'b0;
        o_wrb_gpr_enable_DL  = 1'b0;
        o_wrb_gpr_enable_DH  = 1'b0;
        o_wrb_gpr_enable_ESP = 1'b0;
        o_wrb_gpr_enable_SP  = 1'b0;
        o_wrb_gpr_enable_EBP = 1'b0;
        o_wrb_gpr_enable_BP  = 1'b0;
        o_wrb_gpr_enable_ESI = 1'b0;
        o_wrb_gpr_enable_SI  = 1'b0;
        o_wrb_gpr_enable_EDI = 1'b0;
        o_wrb_gpr_enable_DI  = 1'b0;

        if (i_uop_valid && write_gpr) begin
            case (dest_reg)
                3'd0: begin
                    o_wrb_gpr_enable_EAX = 1'b1;
                    o_wrb_gpr_enable_AX  = 1'b1;
                    o_wrb_gpr_enable_AL  = 1'b1;
                    o_wrb_gpr_enable_AH  = 1'b1;
                end
                3'd1: begin
                    o_wrb_gpr_enable_ECX = 1'b1;
                    o_wrb_gpr_enable_CX  = 1'b1;
                    o_wrb_gpr_enable_CL  = 1'b1;
                    o_wrb_gpr_enable_CH  = 1'b1;
                end
                3'd2: begin
                    o_wrb_gpr_enable_EDX = 1'b1;
                    o_wrb_gpr_enable_DX  = 1'b1;
                    o_wrb_gpr_enable_DL  = 1'b1;
                    o_wrb_gpr_enable_DH  = 1'b1;
                end
                3'd3: begin
                    o_wrb_gpr_enable_EBX = 1'b1;
                    o_wrb_gpr_enable_BX  = 1'b1;
                    o_wrb_gpr_enable_BL  = 1'b1;
                    o_wrb_gpr_enable_BH  = 1'b1;
                end
                3'd4: begin
                    o_wrb_gpr_enable_ESP = 1'b1;
                    o_wrb_gpr_enable_SP  = 1'b1;
                end
                3'd5: begin
                    o_wrb_gpr_enable_EBP = 1'b1;
                    o_wrb_gpr_enable_BP  = 1'b1;
                end
                3'd6: begin
                    o_wrb_gpr_enable_ESI = 1'b1;
                    o_wrb_gpr_enable_SI  = 1'b1;
                end
                3'd7: begin
                    o_wrb_gpr_enable_EDI = 1'b1;
                    o_wrb_gpr_enable_DI  = 1'b1;
                end
            endcase
        end
    end

    assign o_wrb_gpr_data_EAX = result;
    assign o_wrb_gpr_data_AX  = result[15: 0];
    assign o_wrb_gpr_data_AL  = result[ 7: 0];
    assign o_wrb_gpr_data_AH  = result[15: 8];
    assign o_wrb_gpr_data_EBX = result;
    assign o_wrb_gpr_data_BX  = result[15: 0];
    assign o_wrb_gpr_data_BL  = result[ 7: 0];
    assign o_wrb_gpr_data_BH  = result[15: 8];
    assign o_wrb_gpr_data_ECX = result;
    assign o_wrb_gpr_data_CX  = result[15: 0];
    assign o_wrb_gpr_data_CL  = result[ 7: 0];
    assign o_wrb_gpr_data_CH  = result[15: 8];
    assign o_wrb_gpr_data_EDX = result;
    assign o_wrb_gpr_data_DX  = result[15: 0];
    assign o_wrb_gpr_data_DL  = result[ 7: 0];
    assign o_wrb_gpr_data_DH  = result[15: 8];
    assign o_wrb_gpr_data_ESP = result;
    assign o_wrb_gpr_data_SP  = result[15: 0];
    assign o_wrb_gpr_data_EBP = result;
    assign o_wrb_gpr_data_BP  = result[15: 0];
    assign o_wrb_gpr_data_ESI = result;
    assign o_wrb_gpr_data_SI  = result[15: 0];
    assign o_wrb_gpr_data_EDI = result;
    assign o_wrb_gpr_data_DI  = result[15: 0];

    assign o_wrb_seg_enable_es = 1'b0;
    assign o_wrb_seg_enable_cs = 1'b0;
    assign o_wrb_seg_enable_ss = 1'b0;
    assign o_wrb_seg_enable_ds = 1'b0;
    assign o_wrb_seg_enable_fs = 1'b0;
    assign o_wrb_seg_enable_gs = 1'b0;
    assign o_wrb_seg_selector   = 16'd0;
    assign o_wrb_seg_descriptor = 64'd0;

    assign o_wrb_flags_enable = i_uop_valid && write_flags;
    assign o_wrb_flags_data   = flags_data;

    assign o_wrb_ip_enable = i_uop_valid && write_ip;
    assign o_wrb_ip_data   = ip_data;

    assign o_mem_valid        = i_uop_valid && mem_valid;
    assign o_mem_write_enable = i_uop_valid && mem_write_enable;
    assign o_mem_address      = mem_address;
    assign o_mem_write_data   = mem_write_data;

endmodule
