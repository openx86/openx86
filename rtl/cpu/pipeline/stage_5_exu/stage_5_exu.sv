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
                    logic [31: 0] sum = src1_data + src2_data;
                    result = sum;
                    new_cf = compute_cf_add(src1_data, src2_data);
                    new_pf = compute_pf(sum);
                    new_zf = compute_zf(sum);
                    new_sf = compute_sf(sum);
                    new_of = compute_of_add(src1_data, src2_data);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_SUB: begin
                    logic [31: 0] diff = src1_data - src2_data;
                    result = diff;
                    new_cf = compute_cf_sub(src1_data, src2_data);
                    new_pf = compute_pf(diff);
                    new_zf = compute_zf(diff);
                    new_sf = compute_sf(diff);
                    new_of = compute_of_sub(src1_data, src2_data);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_AND: begin
                    logic [31: 0] res = src1_data & src2_data;
                    result = res;
                    new_cf = 1'b0;
                    new_of = 1'b0;
                    new_pf = compute_pf(res);
                    new_zf = compute_zf(res);
                    new_sf = compute_sf(res);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_OR: begin
                    logic [31: 0] res = src1_data | src2_data;
                    result = res;
                    new_cf = 1'b0;
                    new_of = 1'b0;
                    new_pf = compute_pf(res);
                    new_zf = compute_zf(res);
                    new_sf = compute_sf(res);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_XOR: begin
                    logic [31: 0] res = src1_data ^ src2_data;
                    result = res;
                    new_cf = 1'b0;
                    new_of = 1'b0;
                    new_pf = compute_pf(res);
                    new_zf = compute_zf(res);
                    new_sf = compute_sf(res);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_MOV: begin
                    result = has_imm ? immediate : src2_data;
                    write_gpr = 1'b1;
                end
                `UOP_CMP: begin
                    logic [31: 0] diff = src1_data - src2_data;
                    new_cf = compute_cf_sub(src1_data, src2_data);
                    new_pf = compute_pf(diff);
                    new_zf = compute_zf(diff);
                    new_sf = compute_sf(diff);
                    new_of = compute_of_sub(src1_data, src2_data);
                    write_flags = 1'b1;
                end
                `UOP_ADC: begin
                    logic [31: 0] sum = src1_data + src2_data + i_cf;
                    result = sum;
                    new_cf = compute_cf_adc(src1_data, src2_data, i_cf);
                    new_pf = compute_pf(sum);
                    new_zf = compute_zf(sum);
                    new_sf = compute_sf(sum);
                    new_of = compute_of_adc(src1_data, src2_data, i_cf);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_SBB: begin
                    logic [31: 0] diff = src1_data - src2_data - i_cf;
                    result = diff;
                    new_cf = compute_cf_sbb(src1_data, src2_data, i_cf);
                    new_pf = compute_pf(diff);
                    new_zf = compute_zf(diff);
                    new_sf = compute_sf(diff);
                    new_of = compute_of_sbb(src1_data, src2_data, i_cf);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_INC: begin
                    logic [31: 0] res = src1_data + 32'd1;
                    result = res;
                    new_pf = compute_pf(res);
                    new_zf = compute_zf(res);
                    new_sf = compute_sf(res);
                    new_of = compute_of_inc(src1_data);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_DEC: begin
                    logic [31: 0] res = src1_data - 32'd1;
                    result = res;
                    new_pf = compute_pf(res);
                    new_zf = compute_zf(res);
                    new_sf = compute_sf(res);
                    new_of = compute_of_dec(src1_data);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_NEG: begin
                    logic [31: 0] res = ~src1_data + 32'd1;
                    result = res;
                    new_cf = (src1_data != 32'd0);
                    new_pf = compute_pf(res);
                    new_zf = compute_zf(res);
                    new_sf = compute_sf(res);
                    new_of = (src1_data == 32'h80000000);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_NOT: begin
                    result = ~src1_data;
                    write_gpr = 1'b1;
                end
                `UOP_TEST: begin
                    logic [31: 0] res = src1_data & src2_data;
                    new_cf = 1'b0;
                    new_of = 1'b0;
                    new_pf = compute_pf(res);
                    new_zf = compute_zf(res);
                    new_sf = compute_sf(res);
                    write_flags = 1'b1;
                end
                `UOP_SHL: begin
                    logic [ 4: 0] shift_count = src2_data[4: 0];
                    logic [31: 0] res = src1_data << shift_count;
                    result = res;
                    if (shift_count != 5'd0) begin
                        new_cf = (shift_count > 5'd0) ? src1_data[32'd32 - shift_count] : src1_data[0];
                        new_of = (shift_count == 5'd1) ? (src1_data[31] ^ res[31]) : i_of;
                        new_pf = compute_pf(res);
                        new_zf = compute_zf(res);
                        new_sf = compute_sf(res);
                    end
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_SHR: begin
                    logic [ 4: 0] shift_count = src2_data[4: 0];
                    logic [31: 0] res = src1_data >> shift_count;
                    result = res;
                    if (shift_count != 5'd0) begin
                        new_cf = (shift_count > 5'd0) ? src1_data[shift_count - 5'd1] : src1_data[31];
                        new_of = (shift_count == 5'd1) ? src1_data[31] : 1'b0;
                        new_pf = compute_pf(res);
                        new_zf = compute_zf(res);
                        new_sf = compute_sf(res);
                    end
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_SAR: begin
                    logic [ 4: 0] shift_count = src2_data[4: 0];
                    logic [31: 0] res = $signed(src1_data) >>> shift_count;
                    result = res;
                    if (shift_count != 5'd0) begin
                        new_cf = (shift_count > 5'd0) ? src1_data[shift_count - 5'd1] : src1_data[31];
                        new_of = 1'b0;
                        new_pf = compute_pf(res);
                        new_zf = compute_zf(res);
                        new_sf = compute_sf(res);
                    end
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_ROL: begin
                    logic [ 4: 0] shift_count = src2_data[4: 0];
                    logic [31: 0] res = (src1_data << shift_count) | (src1_data >> (32'd32 - shift_count));
                    result = res;
                    if (shift_count != 5'd0) begin
                        new_cf = (shift_count == 5'd0) ? i_cf : src1_data[32'd32 - shift_count];
                        new_of = (shift_count == 5'd1) ? (src1_data[31] ^ res[31]) : i_of;
                    end
                    write_gpr = 1'b1;
                end
                `UOP_ROR: begin
                    logic [ 4: 0] shift_count = src2_data[4: 0];
                    logic [31: 0] res = (src1_data >> shift_count) | (src1_data << (32'd32 - shift_count));
                    result = res;
                    if (shift_count != 5'd0) begin
                        new_cf = (shift_count == 5'd0) ? i_cf : src1_data[shift_count - 5'd1];
                        new_of = (shift_count == 5'd1) ? (res[31] ^ src1_data[31]) : i_of;
                    end
                    write_gpr = 1'b1;
                end
                `UOP_RCL: begin
                    logic [ 4: 0] shift_count = src2_data[4: 0];
                    logic [32: 0] ext_src = {i_cf, src1_data};
                    logic [32: 0] res = (ext_src << shift_count) | (ext_src >> (33'd33 - shift_count));
                    result = res[31: 0];
                    if (shift_count != 5'd0) begin
                        new_cf = res[32];
                        new_of = (shift_count == 5'd1) ? (res[31] ^ src1_data[31]) : i_of;
                    end
                    write_gpr = 1'b1;
                end
                `UOP_RCR: begin
                    logic [ 4: 0] shift_count = src2_data[4: 0];
                    logic [32: 0] ext_src = {src1_data, i_cf};
                    logic [32: 0] res = (ext_src >> shift_count) | (ext_src << (33'd33 - shift_count));
                    result = res[31: 0];
                    if (shift_count != 5'd0) begin
                        new_cf = res[0];
                        new_of = (shift_count == 5'd1) ? (src1_data[31] ^ res[31]) : i_of;
                    end
                    write_gpr = 1'b1;
                end
                `UOP_SHLD: begin
                    logic [ 4: 0] shift_count = src2_data[4: 0];
                    logic [63: 0] combined = {src1_data, src2_data};
                    logic [31: 0] res = combined[31: 0] << shift_count;
                    result = res;
                    if (shift_count != 5'd0) begin
                        new_cf = (shift_count > 5'd0) ? combined[32'd32 - shift_count] : combined[31];
                        new_of = (shift_count == 5'd1) ? (src1_data[31] ^ res[31]) : i_of;
                        new_pf = compute_pf(res);
                        new_zf = compute_zf(res);
                        new_sf = compute_sf(res);
                    end
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_SHRD: begin
                    logic [ 4: 0] shift_count = src2_data[4: 0];
                    logic [63: 0] combined = {src1_data, src2_data};
                    logic [31: 0] res = combined[63: 32] >> shift_count;
                    result = res;
                    if (shift_count != 5'd0) begin
                        new_cf = (shift_count > 5'd0) ? combined[shift_count - 5'd1] : combined[32];
                        new_of = (shift_count == 5'd1) ? (src1_data[31] ^ res[31]) : i_of;
                        new_pf = compute_pf(res);
                        new_zf = compute_zf(res);
                        new_sf = compute_sf(res);
                    end
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_BT: begin
                    logic [ 4: 0] bit_index = src2_data[4: 0];
                    new_cf = src1_data[bit_index];
                    write_flags = 1'b1;
                end
                `UOP_BTS: begin
                    logic [ 4: 0] bit_index = src2_data[4: 0];
                    new_cf = src1_data[bit_index];
                    result = src1_data;
                    result[bit_index] = 1'b1;
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_BTR: begin
                    logic [ 4: 0] bit_index = src2_data[4: 0];
                    new_cf = src1_data[bit_index];
                    result = src1_data;
                    result[bit_index] = 1'b0;
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_BTC: begin
                    logic [ 4: 0] bit_index = src2_data[4: 0];
                    new_cf = src1_data[bit_index];
                    result = src1_data;
                    result[bit_index] = ~src1_data[bit_index];
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_BSF: begin
                    logic [ 4: 0] bit_index = 5'd0;
                    logic [31: 0] operand = src1_data;
                    if (operand != 32'd0) begin
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
                    logic [ 4: 0] bit_index = 5'd0;
                    logic [31: 0] operand = src1_data;
                    if (operand != 32'd0) begin
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
                `UOP_BSWAP: begin
                    result = {src1_data[ 7: 0], src1_data[15: 8], src1_data[23:16], src1_data[31:24]};
                    write_gpr = 1'b1;
                end
                `UOP_MOVSX: begin
                    logic [15: 0] src = has_imm ? immediate[15: 0] : src2_data[15: 0];
                    result = {{16{src[15]}}, src};
                    write_gpr = 1'b1;
                end
                `UOP_MOVZX: begin
                    logic [15: 0] src = has_imm ? immediate[15: 0] : src2_data[15: 0];
                    result = {16'd0, src};
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
                    logic [31: 0] sum = src1_data + src2_data;
                    result = sum;
                    new_cf = compute_cf_add(src1_data, src2_data);
                    new_pf = compute_pf(sum);
                    new_zf = compute_zf(sum);
                    new_sf = compute_sf(sum);
                    new_of = compute_of_add(src1_data, src2_data);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_CMPXCHG: begin
                    logic [31: 0] diff = src1_data - src2_data;
                    new_cf = compute_cf_sub(src1_data, src2_data);
                    new_pf = compute_pf(diff);
                    new_zf = compute_zf(diff);
                    new_sf = compute_sf(diff);
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
                    logic [31: 0] src = has_imm ? immediate : src1_data;
                    logic [31: 0] new_esp = src2_data - 32'd4;
                    result = new_esp;
                    mem_address = new_esp;
                    mem_write_data = src;
                    mem_valid = 1'b1;
                    mem_write_enable = 1'b1;
                    write_gpr = 1'b1;
                end
                `UOP_POP: begin
                    logic [31: 0] new_esp = src1_data + 32'd4;
                    result = has_imm ? new_esp + immediate : src2_data;
                    mem_address = src1_data;
                    mem_valid = 1'b1;
                    mem_write_enable = 1'b0;
                    write_gpr = 1'b1;
                end
                `UOP_BRANCH: begin
                    logic [31: 0] target = has_disp ? displacement : immediate;
                    logic         condition_met;
                    case (tttn)
                        4'h0: condition_met = i_of;
                        4'h1: condition_met = ~i_of;
                        4'h2: condition_met = i_cf;
                        4'h3: condition_met = ~i_cf;
                        4'h4: condition_met = i_zf;
                        4'h5: condition_met = ~i_zf;
                        4'h6: condition_met = i_cf | i_zf;
                        4'h7: condition_met = ~(i_cf | i_zf);
                        4'h8: condition_met = i_sf;
                        4'h9: condition_met = ~i_sf;
                        4'hA: condition_met = i_pf;
                        4'hB: condition_met = ~i_pf;
                        4'hC: condition_met = i_sf ^ i_of;
                        4'hD: condition_met = ~(i_sf ^ i_of);
                        4'hE: condition_met = i_sf ^ i_of ^ i_cf;
                        4'hF: condition_met = 1'b1;
                        default: condition_met = 1'b0;
                    endcase
                    if (condition_met) begin
                        ip_data = target;
                        write_ip = 1'b1;
                    end
                end
                `UOP_CALL: begin
                    logic [31: 0] target = has_disp ? displacement : immediate;
                    logic [31: 0] new_esp = src2_data - 32'd4;
                    result = new_esp;
                    mem_address = new_esp;
                    mem_write_data = src1_data;
                    mem_valid = 1'b1;
                    mem_write_enable = 1'b1;
                    ip_data = target;
                    write_gpr = 1'b1;
                    write_ip = 1'b1;
                end
                `UOP_RET: begin
                    logic [31: 0] new_esp = has_imm ? (src1_data + immediate) : (src1_data + 32'd4);
                    result = new_esp;
                    mem_address = src1_data;
                    mem_valid = 1'b1;
                    mem_write_enable = 1'b0;
                    ip_data = src2_data;
                    write_gpr = 1'b1;
                    write_ip = 1'b1;
                end
                `UOP_SETCC: begin
                    logic         condition_met;
                    case (tttn)
                        4'h0: condition_met = i_of;
                        4'h1: condition_met = ~i_of;
                        4'h2: condition_met = i_cf;
                        4'h3: condition_met = ~i_cf;
                        4'h4: condition_met = i_zf;
                        4'h5: condition_met = ~i_zf;
                        4'h6: condition_met = i_cf | i_zf;
                        4'h7: condition_met = ~(i_cf | i_zf);
                        4'h8: condition_met = i_sf;
                        4'h9: condition_met = ~i_sf;
                        4'hA: condition_met = i_pf;
                        4'hB: condition_met = ~i_pf;
                        4'hC: condition_met = i_sf ^ i_of;
                        4'hD: condition_met = ~(i_sf ^ i_of);
                        4'hE: condition_met = i_sf ^ i_of ^ i_cf;
                        4'hF: condition_met = 1'b1;
                        default: condition_met = 1'b0;
                    endcase
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
                    logic [63: 0] dividend = {src1_data, src2_data};
                    logic [31: 0] divisor = src2_data;
                    if (divisor != 32'd0) begin
                        result = dividend[31: 0] / divisor;
                    end
                    write_gpr = 1'b1;
                end
                `UOP_IDIV: begin
                    logic signed [63: 0] dividend = {src1_data, src2_data};
                    logic signed [31: 0] divisor = src2_data;
                    if (divisor != 32'sd0) begin
                        result = dividend[31: 0] / divisor;
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
