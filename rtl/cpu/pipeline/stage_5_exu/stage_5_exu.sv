// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without tmp_restriction, including without limitation the rights
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
    output logic                o_multicycle_stall,
    input  logic                i_wrb_ready,

    input  logic                i_mem_done,
    input  logic [31: 0]        i_mem_rdata,
    input  logic [31: 0]        i_gdtr_base,
    input  logic [15: 0]        i_gdtr_limit,
    input  logic [31: 0]        i_idtr_base,
    input  logic [15: 0]        i_idtr_limit,

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

    output logic                o_gdtr_write_enable,
    output logic [15: 0]        o_gdtr_write_limit,
    output logic [31: 0]        o_gdtr_write_base,
    output logic                o_idtr_write_enable,
    output logic [15: 0]        o_idtr_write_limit,
    output logic [31: 0]        o_idtr_write_base,
    output logic                o_cr_write_enable,
    output logic [ 2: 0]        o_cr_write_index,
    output logic [31: 0]        o_cr_write_data,
    output logic                o_invalidate_cache,
    output logic                o_wbinvd,
    output logic                o_data_io_access,

    output logic                o_mem_valid,
    output logic                o_mem_write_enable,
    output logic [31: 0]        o_mem_address,
    output logic [31: 0]        o_mem_write_data,

    // =========================
    // Clock and tmp_reset
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

    logic [31: 0] tmp_result;
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

    logic         load_pending_r;
    logic [ 2: 0] load_dest_r;
    logic         load_complete_we;
    logic [31: 0] load_complete_data;
    logic         misc_load_pending_r;
    logic [ 7: 0] misc_subcode_r;
    logic         ret_pending_r;

    logic         gdtr_we;
    logic [15: 0] gdtr_limit;
    logic [31: 0] gdtr_base;
    logic         idtr_we;
    logic [15: 0] idtr_limit;
    logic [31: 0] idtr_base;
    logic         cr_we;
    logic [ 2: 0] cr_index;
    logic [31: 0] cr_data;
    logic         inv_cache;
    logic         wbinvd_cmd;
    logic         data_io_access;

    logic [31: 0] cpuid_eax;
    logic [31: 0] cpuid_ebx;
    logic [31: 0] cpuid_ecx;
    logic [31: 0] cpuid_edx;

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
    logic [31: 0] tmp_divisor;
    logic signed [31: 0] tmp_divisor_signed;
    logic [63: 0] tmp_product;
    logic signed [63: 0] tmp_product_signed;
    logic         tmp_condition_met;

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
        tmp_result = 32'd0;
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
        gdtr_we          = 1'b0;
        gdtr_limit       = 16'd0;
        gdtr_base        = 32'd0;
        idtr_we          = 1'b0;
        idtr_limit       = 16'd0;
        idtr_base        = 32'd0;
        cr_we            = 1'b0;
        cr_index         = 3'd0;
        cr_data          = 32'd0;
        inv_cache        = 1'b0;
        wbinvd_cmd       = 1'b0;
        data_io_access   = 1'b0;

        if (i_uop_valid && ~load_pending_r) begin
            case (uop_opcode)
                `UOP_ADD: begin
                    tmp_sum = src1_data + src2_data;
                    tmp_result = tmp_sum;
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
                    tmp_result = tmp_diff;
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
                    tmp_result = tmp_res;
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
                    tmp_result = tmp_res;
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
                    tmp_result = tmp_res;
                    new_cf = 1'b0;
                    new_of = 1'b0;
                    new_pf = compute_pf(tmp_res);
                    new_zf = compute_zf(tmp_res);
                    new_sf = compute_sf(tmp_res);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_MOV: begin
                    if (mem_access) begin
                        mem_address = src1_data + displacement;
                        mem_valid   = ~load_pending_r;
                        if (is_store) begin
                            mem_write_enable = 1'b1;
                            mem_write_data   = src2_data;
                        end else begin
                            mem_write_enable = 1'b0;
                        end
                    end else begin
                        tmp_result = has_imm ? immediate : src2_data;
                        write_gpr = 1'b1;
                    end
                end
                `UOP_LOAD: begin
                    mem_address      = src1_data + displacement;
                    mem_valid        = ~load_pending_r;
                    mem_write_enable = 1'b0;
                end
                `UOP_STORE: begin
                    mem_address      = src1_data + displacement;
                    mem_write_data   = src2_data;
                    mem_valid        = 1'b1;
                    mem_write_enable = 1'b1;
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
                    tmp_result = tmp_sum;
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
                    tmp_result = tmp_diff;
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
                    tmp_result = tmp_res;
                    new_pf = compute_pf(tmp_res);
                    new_zf = compute_zf(tmp_res);
                    new_sf = compute_sf(tmp_res);
                    new_of = compute_of_inc(src1_data);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_DEC: begin
                    tmp_res = src1_data - 32'd1;
                    tmp_result = tmp_res;
                    new_pf = compute_pf(tmp_res);
                    new_zf = compute_zf(tmp_res);
                    new_sf = compute_sf(tmp_res);
                    new_of = compute_of_dec(src1_data);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_NEG: begin
                    tmp_res = ~src1_data + 32'd1;
                    tmp_result = tmp_res;
                    new_cf = (src1_data != 32'd0);
                    new_pf = compute_pf(tmp_res);
                    new_zf = compute_zf(tmp_res);
                    new_sf = compute_sf(tmp_res);
                    new_of = (src1_data == 32'h80000000);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_NOT: begin
                    tmp_result = ~src1_data;
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
                    tmp_result = tmp_res;
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = (tmp_shift_count > 5'd0) ? src1_data[32'd32 - tmp_shift_count] : src1_data[0];
                        new_of = (tmp_shift_count == 5'd1) ? (src1_data[31] ^ tmp_res[31]) : i_of;
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
                    tmp_result = tmp_res;
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = (tmp_shift_count > 5'd0) ? src1_data[tmp_shift_count - 5'd1] : src1_data[31];
                        new_of = (tmp_shift_count == 5'd1) ? src1_data[31] : 1'b0;
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
                    tmp_result = tmp_res;
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = (tmp_shift_count > 5'd0) ? src1_data[tmp_shift_count - 5'd1] : src1_data[31];
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
                    tmp_res = (src1_data << tmp_shift_count) | (src1_data >> (32'd32 - tmp_shift_count));
                    tmp_result = tmp_res;
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = (tmp_shift_count == 5'd0) ? i_cf : src1_data[32'd32 - tmp_shift_count];
                        new_of = (tmp_shift_count == 5'd1) ? (src1_data[31] ^ tmp_res[31]) : i_of;
                    end
                    write_gpr = 1'b1;
                end
                `UOP_ROR: begin
                    tmp_shift_count = src2_data[4: 0];
                    tmp_res = (src1_data >> tmp_shift_count) | (src1_data << (32'd32 - tmp_shift_count));
                    tmp_result = tmp_res;
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = (tmp_shift_count == 5'd0) ? i_cf : src1_data[tmp_shift_count - 5'd1];
                        new_of = (tmp_shift_count == 5'd1) ? (tmp_res[31] ^ src1_data[31]) : i_of;
                    end
                    write_gpr = 1'b1;
                end
                `UOP_RCL: begin
                    tmp_shift_count = src2_data[4: 0];
                    tmp_ext_src = {i_cf, src1_data};
                    tmp_res = (tmp_ext_src << tmp_shift_count) | (tmp_ext_src >> (33'd33 - tmp_shift_count));
                    tmp_result = tmp_res[31: 0];
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = tmp_res[32];
                        new_of = (tmp_shift_count == 5'd1) ? (tmp_res[31] ^ src1_data[31]) : i_of;
                    end
                    write_gpr = 1'b1;
                end
                `UOP_RCR: begin
                    tmp_shift_count = src2_data[4: 0];
                    tmp_ext_src = {src1_data, i_cf};
                    tmp_res = (tmp_ext_src >> tmp_shift_count) | (tmp_ext_src << (33'd33 - tmp_shift_count));
                    tmp_result = tmp_res[31: 0];
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = tmp_res[0];
                        new_of = (tmp_shift_count == 5'd1) ? (src1_data[31] ^ tmp_res[31]) : i_of;
                    end
                    write_gpr = 1'b1;
                end
                `UOP_SHLD: begin
                    tmp_shift_count = src2_data[4: 0];
                    tmp_combined = {src1_data, src2_data};
                    tmp_res = tmp_combined[31: 0] << tmp_shift_count;
                    tmp_result = tmp_res;
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = (tmp_shift_count > 5'd0) ? tmp_combined[32'd32 - tmp_shift_count] : tmp_combined[31];
                        new_of = (tmp_shift_count == 5'd1) ? (src1_data[31] ^ tmp_res[31]) : i_of;
                        new_pf = compute_pf(tmp_res);
                        new_zf = compute_zf(tmp_res);
                        new_sf = compute_sf(tmp_res);
                    end
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_SHRD: begin
                    tmp_shift_count = src2_data[4: 0];
                    tmp_combined = {src1_data, src2_data};
                    tmp_res = tmp_combined[63: 32] >> tmp_shift_count;
                    tmp_result = tmp_res;
                    if (tmp_shift_count != 5'd0) begin
                        new_cf = (tmp_shift_count > 5'd0) ? tmp_combined[tmp_shift_count - 5'd1] : tmp_combined[32];
                        new_of = (tmp_shift_count == 5'd1) ? (src1_data[31] ^ tmp_res[31]) : i_of;
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
                    tmp_result = src1_data;
                    tmp_result[tmp_bit_index] = 1'b1;
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_BTR: begin
                    tmp_bit_index = src2_data[4: 0];
                    new_cf = src1_data[tmp_bit_index];
                    tmp_result = src1_data;
                    tmp_result[tmp_bit_index] = 1'b0;
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_BTC: begin
                    tmp_bit_index = src2_data[4: 0];
                    new_cf = src1_data[tmp_bit_index];
                    tmp_result = src1_data;
                    tmp_result[tmp_bit_index] = ~src1_data[tmp_bit_index];
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_BSF: begin
                    tmp_bit_index = 5'd0;
                    if (src1_data[ 0]) tmp_bit_index = 5'd0;
                    if (src1_data[ 1]) tmp_bit_index = 5'd1;
                    if (src1_data[ 2]) tmp_bit_index = 5'd2;
                    if (src1_data[ 3]) tmp_bit_index = 5'd3;
                    if (src1_data[ 4]) tmp_bit_index = 5'd4;
                    if (src1_data[ 5]) tmp_bit_index = 5'd5;
                    if (src1_data[ 6]) tmp_bit_index = 5'd6;
                    if (src1_data[ 7]) tmp_bit_index = 5'd7;
                    if (src1_data[ 8]) tmp_bit_index = 5'd8;
                    if (src1_data[ 9]) tmp_bit_index = 5'd9;
                    if (src1_data[10]) tmp_bit_index = 5'd10;
                    if (src1_data[11]) tmp_bit_index = 5'd11;
                    if (src1_data[12]) tmp_bit_index = 5'd12;
                    if (src1_data[13]) tmp_bit_index = 5'd13;
                    if (src1_data[14]) tmp_bit_index = 5'd14;
                    if (src1_data[15]) tmp_bit_index = 5'd15;
                    if (src1_data[16]) tmp_bit_index = 5'd16;
                    if (src1_data[17]) tmp_bit_index = 5'd17;
                    if (src1_data[18]) tmp_bit_index = 5'd18;
                    if (src1_data[19]) tmp_bit_index = 5'd19;
                    if (src1_data[20]) tmp_bit_index = 5'd20;
                    if (src1_data[21]) tmp_bit_index = 5'd21;
                    if (src1_data[22]) tmp_bit_index = 5'd22;
                    if (src1_data[23]) tmp_bit_index = 5'd23;
                    if (src1_data[24]) tmp_bit_index = 5'd24;
                    if (src1_data[25]) tmp_bit_index = 5'd25;
                    if (src1_data[26]) tmp_bit_index = 5'd26;
                    if (src1_data[27]) tmp_bit_index = 5'd27;
                    if (src1_data[28]) tmp_bit_index = 5'd28;
                    if (src1_data[29]) tmp_bit_index = 5'd29;
                    if (src1_data[30]) tmp_bit_index = 5'd30;
                    if (src1_data[31]) tmp_bit_index = 5'd31;
                    tmp_result = {27'd0, tmp_bit_index};
                    new_zf = (src1_data == 32'd0);
                    new_of = 1'b0;
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_BSR: begin
                    tmp_bit_index = 5'd0;
                    if (src1_data[31]) tmp_bit_index = 5'd31;
                    if (src1_data[30]) tmp_bit_index = 5'd30;
                    if (src1_data[29]) tmp_bit_index = 5'd29;
                    if (src1_data[28]) tmp_bit_index = 5'd28;
                    if (src1_data[27]) tmp_bit_index = 5'd27;
                    if (src1_data[26]) tmp_bit_index = 5'd26;
                    if (src1_data[25]) tmp_bit_index = 5'd25;
                    if (src1_data[24]) tmp_bit_index = 5'd24;
                    if (src1_data[23]) tmp_bit_index = 5'd23;
                    if (src1_data[22]) tmp_bit_index = 5'd22;
                    if (src1_data[21]) tmp_bit_index = 5'd21;
                    if (src1_data[20]) tmp_bit_index = 5'd20;
                    if (src1_data[19]) tmp_bit_index = 5'd19;
                    if (src1_data[18]) tmp_bit_index = 5'd18;
                    if (src1_data[17]) tmp_bit_index = 5'd17;
                    if (src1_data[16]) tmp_bit_index = 5'd16;
                    if (src1_data[15]) tmp_bit_index = 5'd15;
                    if (src1_data[14]) tmp_bit_index = 5'd14;
                    if (src1_data[13]) tmp_bit_index = 5'd13;
                    if (src1_data[12]) tmp_bit_index = 5'd12;
                    if (src1_data[11]) tmp_bit_index = 5'd11;
                    if (src1_data[10]) tmp_bit_index = 5'd10;
                    if (src1_data[ 9]) tmp_bit_index = 5'd9;
                    if (src1_data[ 8]) tmp_bit_index = 5'd8;
                    if (src1_data[ 7]) tmp_bit_index = 5'd7;
                    if (src1_data[ 6]) tmp_bit_index = 5'd6;
                    if (src1_data[ 5]) tmp_bit_index = 5'd5;
                    if (src1_data[ 4]) tmp_bit_index = 5'd4;
                    if (src1_data[ 3]) tmp_bit_index = 5'd3;
                    if (src1_data[ 2]) tmp_bit_index = 5'd2;
                    if (src1_data[ 1]) tmp_bit_index = 5'd1;
                    if (src1_data[ 0]) tmp_bit_index = 5'd0;
                    tmp_result = {27'd0, tmp_bit_index};
                    new_zf = (src1_data == 32'd0);
                    new_of = 1'b0;
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_MOVSX: begin
                    tmp_src_16 = has_imm ? immediate[15: 0] : src2_data[15: 0];
                    tmp_result = {{16{tmp_src_16[15]}}, tmp_src_16};
                    write_gpr = 1'b1;
                end
                `UOP_MOVZX: begin
                    tmp_src_16 = has_imm ? immediate[15: 0] : src2_data[15: 0];
                    tmp_result = {16'd0, tmp_src_16};
                    write_gpr = 1'b1;
                end
                `UOP_XCHG: begin
                    tmp_result = src2_data;
                    write_gpr = 1'b1;
                end
                `UOP_LEA: begin
                    tmp_result = src1_data + src2_data + displacement;
                    write_gpr = 1'b1;
                end
                `UOP_XADD: begin
                    tmp_sum = src1_data + src2_data;
                    tmp_result = tmp_sum;
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
                        tmp_result = src2_data;
                    end else begin
                        tmp_result = src1_data;
                    end
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_PUSH: begin
                    tmp_src = has_imm ? immediate : src1_data;
                    tmp_new_esp = src2_data - 32'd4;
                    tmp_result = tmp_new_esp;
                    mem_address = tmp_new_esp;
                    mem_write_data = tmp_src;
                    mem_valid = 1'b1;
                    mem_write_enable = 1'b1;
                    write_gpr = 1'b1;
                end
                `UOP_POP: begin
                    tmp_new_esp = src1_data + 32'd4;
                    tmp_result  = tmp_new_esp;
                    mem_address = src1_data;
                    mem_valid   = ~load_pending_r;
                    mem_write_enable = 1'b0;
                    write_gpr   = 1'b1;
                end
                `UOP_BRANCH: begin
                    tmp_target = has_disp ? displacement : immediate;
                    tmp_condition_met = compute_condition(tttn, i_of, i_cf, i_zf, i_sf, i_pf);
                    if (tmp_condition_met) begin
                        ip_data = tmp_target;
                        write_ip = 1'b1;
                    end
                end
                `UOP_CALL: begin
                    tmp_target = has_disp ? displacement : immediate;
                    tmp_new_esp = src2_data - 32'd4;
                    tmp_result = tmp_new_esp;
                    mem_address = tmp_new_esp;
                    mem_write_data = src1_data;
                    mem_valid = 1'b1;
                    mem_write_enable = 1'b1;
                    ip_data = tmp_target;
                    write_gpr = 1'b1;
                    write_ip = 1'b1;
                end
                `UOP_RET: begin
                    tmp_new_esp = has_imm ? (src1_data + immediate) : (src1_data + 32'd4);
                    tmp_result  = tmp_new_esp;
                    mem_address = src1_data;
                    mem_valid   = ~load_pending_r;
                    mem_write_enable = 1'b0;
                    write_gpr   = 1'b1;
                end
                `UOP_SETCC: begin
                    tmp_condition_met = compute_condition(tttn, i_of, i_cf, i_zf, i_sf, i_pf);
                    tmp_result = tmp_condition_met ? 32'd1 : 32'd0;
                    write_gpr = 1'b1;
                end
                `UOP_STRING: begin
                    mem_address      = src1_data;
                    mem_valid        = 1'b1;
                    mem_write_enable = is_store;
                    mem_write_data   = src2_data;
                    tmp_result       = src1_data + (i_zf ? 32'd0 : 32'd1);
                    write_gpr        = 1'b1;
                end
                `UOP_FLAG_CTRL: begin
                    flags_data  = {16'h0, i_of, 1'b0, 1'b0, 1'b0, 1'b1, i_sf, i_zf,
                                   1'b0, i_af, 1'b0, i_pf, 1'b1, i_cf};
                    write_flags = 1'b1;
                end
                `UOP_MISC: begin
                    unique case (immediate[7: 0])
                        `MISC_SUB_BSWAP: begin
                            tmp_result = {src1_data[ 7: 0], src1_data[15: 8],
                                          src1_data[23:16], src1_data[31:24]};
                            write_gpr = 1'b1;
                        end
                        `MISC_SUB_CPUID: begin
                            tmp_result = cpuid_eax;
                            write_gpr  = 1'b1;
                        end
                        `MISC_SUB_INVD: begin
                            inv_cache = 1'b1;
                        end
                        `MISC_SUB_WBINVD: begin
                            wbinvd_cmd = 1'b1;
                        end
                        `MISC_SUB_LGDT: begin
                            if (~misc_load_pending_r) begin
                                mem_address      = src1_data + displacement;
                                mem_valid        = 1'b1;
                                mem_write_enable = 1'b0;
                            end
                        end
                        `MISC_SUB_LIDT: begin
                            if (~misc_load_pending_r) begin
                                mem_address      = src1_data + displacement;
                                mem_valid        = 1'b1;
                                mem_write_enable = 1'b0;
                            end
                        end
                        `MISC_SUB_SGDT: begin
                            mem_address      = src1_data + displacement;
                            mem_valid        = 1'b1;
                            mem_write_enable = 1'b1;
                            mem_write_data   = {i_gdtr_base[15: 0], i_gdtr_limit};
                        end
                        `MISC_SUB_SIDT: begin
                            mem_address      = src1_data + displacement;
                            mem_valid        = 1'b1;
                            mem_write_enable = 1'b1;
                            mem_write_data   = {i_idtr_base[15: 0], i_idtr_limit};
                        end
                        `MISC_SUB_LMSW: begin
                            cr_we    = 1'b1;
                            cr_index = 3'd0;
                            cr_data  = {16'h0, src2_data[15: 0]};
                        end
                        `MISC_SUB_MOV_CR: begin
                            cr_we    = 1'b1;
                            cr_index = dest_reg;
                            cr_data  = src2_data;
                        end
                        `MISC_SUB_IN: begin
                            data_io_access   = 1'b1;
                            mem_address      = {16'h0, immediate[15: 0]};
                            mem_valid        = ~load_pending_r;
                            mem_write_enable = 1'b0;
                        end
                        `MISC_SUB_OUT: begin
                            data_io_access   = 1'b1;
                            mem_address      = {16'h0, immediate[15: 0]};
                            mem_valid        = 1'b1;
                            mem_write_enable = 1'b1;
                            mem_write_data   = src2_data;
                        end
                        default: ;
                    endcase
                end
                `UOP_X87: begin
                    tmp_result = 32'd0;
                end
                `UOP_MMX: begin
                    tmp_result = src1_data + src2_data;
                    write_gpr = 1'b1;
                end
                `UOP_SSE: begin
                    tmp_result = src1_data + src2_data;
                    write_gpr = 1'b1;
                end
                `UOP_EMMS: begin
                    tmp_result = 32'd0;
                end
                `UOP_NOP: begin
                    tmp_result = 32'd0;
                end
                `UOP_MUL: begin
                    tmp_product = src1_data * src2_data;
                    tmp_result = tmp_product[31: 0];
                    new_cf = tmp_product[63: 32] != 32'd0;
                    new_of = tmp_product[63: 32] != 32'd0;
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_IMUL: begin
                    tmp_product_signed = $signed(src1_data) * $signed(src2_data);
                    tmp_result = tmp_product_signed[31: 0];
                    new_cf = (tmp_product_signed[63: 32] != 32'sd0) && (tmp_product_signed[63: 32] != 32'hFFFFFFFF);
                    new_of = (tmp_product_signed[63: 32] != 32'sd0) && (tmp_product_signed[63: 32] != 32'hFFFFFFFF);
                    write_gpr = 1'b1;
                    write_flags = 1'b1;
                end
                `UOP_DIV: begin
                    tmp_dividend = {src1_data, src2_data};
                    tmp_divisor = src2_data;
                    if (tmp_divisor != 32'd0) begin
                        tmp_result = tmp_dividend[31: 0] / tmp_divisor;
                    end
                    write_gpr = 1'b1;
                end
                `UOP_IDIV: begin
                    tmp_dividend_signed = {src1_data, src2_data};
                    tmp_divisor_signed = src2_data;
                    if (tmp_divisor != 32'sd0) begin
                        tmp_result = tmp_dividend[31: 0] / tmp_divisor;
                    end
                    write_gpr = 1'b1;
                end
                default: begin
                    tmp_result = 32'd0;
                end
            endcase

            flags_data = {10'b0, new_of, 1'b0, 1'b0, 1'b0, new_sf, new_zf, 1'b0, new_pf, 1'b0, new_cf};
        end

        if (load_pending_r & i_mem_done) begin
            tmp_result = i_mem_rdata;
            write_gpr  = 1'b1;
            if (ret_pending_r) begin
                ip_data  = i_mem_rdata;
                write_ip = 1'b1;
            end
            if (misc_subcode_r == `MISC_SUB_LGDT) begin
                gdtr_we    = 1'b1;
                gdtr_limit = i_mem_rdata[15: 0];
                gdtr_base  = {16'h0, i_mem_rdata[31:16]};
            end else if (misc_subcode_r == `MISC_SUB_LIDT) begin
                idtr_we    = 1'b1;
                idtr_limit = i_mem_rdata[15: 0];
                idtr_base  = {16'h0, i_mem_rdata[31:16]};
            end
        end
    end

    i486_cpuid u_cpuid (
        .i_eax_in (src1_data),
        .i_ecx_in (src2_data),
        .o_eax    (cpuid_eax),
        .o_ebx    (cpuid_ebx),
        .o_ecx    (cpuid_ecx),
        .o_edx    (cpuid_edx)
    );

    always_ff @(posedge clk or negedge rst_n) begin : ff_load_pending
        if (~rst_n) begin
            load_pending_r       <= 1'b0;
            load_dest_r          <= 3'b0;
            misc_load_pending_r  <= 1'b0;
            misc_subcode_r       <= 8'h0;
            ret_pending_r        <= 1'b0;
        end else begin
            if (i_uop_valid & i_wrb_ready & ~load_pending_r & mem_valid & ~mem_write_enable) begin
                load_pending_r <= 1'b1;
                load_dest_r    <= dest_reg;
                if (uop_opcode == `UOP_RET) begin
                    ret_pending_r <= 1'b1;
                end
                if (uop_opcode == `UOP_MISC) begin
                    misc_load_pending_r <= 1'b1;
                    misc_subcode_r      <= immediate[7: 0];
                end
            end else if (load_pending_r & i_mem_done) begin
                load_pending_r      <= 1'b0;
                misc_load_pending_r <= 1'b0;
                ret_pending_r       <= 1'b0;
            end
        end
    end

    assign o_stage_ready       = i_wrb_ready & ~load_pending_r;
    assign o_multicycle_stall  = load_pending_r;
    assign o_stage_valid       = i_uop_valid | (load_pending_r & i_mem_done);

    always_comb begin
        logic [2:0] active_dest;
        active_dest = (load_pending_r & i_mem_done) ? load_dest_r : dest_reg;

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

        if (((i_uop_valid && ~load_pending_r) | (load_pending_r & i_mem_done)) && write_gpr) begin
            case (active_dest)
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

    assign o_wrb_gpr_data_EAX = tmp_result;
    assign o_wrb_gpr_data_AX  = tmp_result[15: 0];
    assign o_wrb_gpr_data_AL  = tmp_result[ 7: 0];
    assign o_wrb_gpr_data_AH  = tmp_result[15: 8];
    assign o_wrb_gpr_data_EBX = tmp_result;
    assign o_wrb_gpr_data_BX  = tmp_result[15: 0];
    assign o_wrb_gpr_data_BL  = tmp_result[ 7: 0];
    assign o_wrb_gpr_data_BH  = tmp_result[15: 8];
    assign o_wrb_gpr_data_ECX = tmp_result;
    assign o_wrb_gpr_data_CX  = tmp_result[15: 0];
    assign o_wrb_gpr_data_CL  = tmp_result[ 7: 0];
    assign o_wrb_gpr_data_CH  = tmp_result[15: 8];
    assign o_wrb_gpr_data_EDX = tmp_result;
    assign o_wrb_gpr_data_DX  = tmp_result[15: 0];
    assign o_wrb_gpr_data_DL  = tmp_result[ 7: 0];
    assign o_wrb_gpr_data_DH  = tmp_result[15: 8];
    assign o_wrb_gpr_data_ESP = tmp_result;
    assign o_wrb_gpr_data_SP  = tmp_result[15: 0];
    assign o_wrb_gpr_data_EBP = tmp_result;
    assign o_wrb_gpr_data_BP  = tmp_result[15: 0];
    assign o_wrb_gpr_data_ESI = tmp_result;
    assign o_wrb_gpr_data_SI  = tmp_result[15: 0];
    assign o_wrb_gpr_data_EDI = tmp_result;
    assign o_wrb_gpr_data_DI  = tmp_result[15: 0];

    assign o_wrb_seg_enable_es = 1'b0;
    assign o_wrb_seg_enable_cs = 1'b0;
    assign o_wrb_seg_enable_ss = 1'b0;
    assign o_wrb_seg_enable_ds = 1'b0;
    assign o_wrb_seg_enable_fs = 1'b0;
    assign o_wrb_seg_enable_gs = 1'b0;
    assign o_wrb_seg_selector   = 16'd0;
    assign o_wrb_seg_descriptor = 64'd0;

    assign o_wrb_flags_enable = ((i_uop_valid && ~load_pending_r) | (load_pending_r & i_mem_done)) && write_flags;
    assign o_wrb_flags_data   = flags_data;

    assign o_wrb_ip_enable = ((i_uop_valid && ~load_pending_r) | (load_pending_r & i_mem_done)) && write_ip;
    assign o_wrb_ip_data   = ip_data;

    assign o_mem_valid        = (i_uop_valid | load_pending_r) && mem_valid;
    assign o_mem_write_enable = i_uop_valid && mem_write_enable;
    assign o_mem_address      = mem_address;
    assign o_mem_write_data   = mem_write_data;

    assign o_gdtr_write_enable = gdtr_we;
    assign o_gdtr_write_limit  = gdtr_limit;
    assign o_gdtr_write_base   = gdtr_base;
    assign o_idtr_write_enable = idtr_we;
    assign o_idtr_write_limit  = idtr_limit;
    assign o_idtr_write_base   = idtr_base;
    assign o_cr_write_enable   = cr_we;
    assign o_cr_write_index    = cr_index;
    assign o_cr_write_data     = cr_data;
    assign o_invalidate_cache  = inv_cache;
    assign o_wbinvd            = wbinvd_cmd;
    assign o_data_io_access    = data_io_access;

endmodule
