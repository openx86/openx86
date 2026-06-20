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
//  File        : exu_dispatcher.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Execution unit dispatcher - routes uops to appropriate units
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_dispatcher (
    input  logic         i_valid,
    input  logic [ 5: 0] i_uop_opcode,
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [31: 0] i_immediate,
    input  logic [31: 0] i_displacement,
    input  logic         i_cf,
    input  logic         i_pf,
    input  logic         i_af,
    input  logic         i_zf,
    input  logic         i_sf,
    input  logic         i_of,
    input  logic [ 2: 0] i_dest_reg,
    input  logic [ 3: 0] i_tttn,
    input  logic         i_has_imm,
    input  logic         i_has_disp,
    input  logic         i_mem_access,
    input  logic         i_is_store,
    output logic         o_wrb_gpr_enable_EAX,
    output logic         o_wrb_gpr_enable_AX,
    output logic         o_wrb_gpr_enable_AL,
    output logic         o_wrb_gpr_enable_AH,
    output logic         o_wrb_gpr_enable_EBX,
    output logic         o_wrb_gpr_enable_BX,
    output logic         o_wrb_gpr_enable_BL,
    output logic         o_wrb_gpr_enable_BH,
    output logic         o_wrb_gpr_enable_ECX,
    output logic         o_wrb_gpr_enable_CX,
    output logic         o_wrb_gpr_enable_CL,
    output logic         o_wrb_gpr_enable_CH,
    output logic         o_wrb_gpr_enable_EDX,
    output logic         o_wrb_gpr_enable_DX,
    output logic         o_wrb_gpr_enable_DL,
    output logic         o_wrb_gpr_enable_DH,
    output logic         o_wrb_gpr_enable_ESP,
    output logic         o_wrb_gpr_enable_SP,
    output logic         o_wrb_gpr_enable_EBP,
    output logic         o_wrb_gpr_enable_BP,
    output logic         o_wrb_gpr_enable_ESI,
    output logic         o_wrb_gpr_enable_SI,
    output logic         o_wrb_gpr_enable_EDI,
    output logic         o_wrb_gpr_enable_DI,
    output logic         o_wrb_seg_enable_es,
    output logic         o_wrb_seg_enable_cs,
    output logic         o_wrb_seg_enable_ss,
    output logic         o_wrb_seg_enable_ds,
    output logic         o_wrb_seg_enable_fs,
    output logic         o_wrb_seg_enable_gs,
    output logic         o_wrb_flags_enable,
    output logic         o_wrb_ip_enable,
    output logic [31: 0] o_wrb_ip_data,
    output logic [31: 0] o_wrb_gpr_data_EAX,
    output logic [15: 0] o_wrb_gpr_data_AX,
    output logic [ 7: 0] o_wrb_gpr_data_AL,
    output logic [ 7: 0] o_wrb_gpr_data_AH,
    output logic [31: 0] o_wrb_gpr_data_EBX,
    output logic [15: 0] o_wrb_gpr_data_BX,
    output logic [ 7: 0] o_wrb_gpr_data_BL,
    output logic [ 7: 0] o_wrb_gpr_data_BH,
    output logic [31: 0] o_wrb_gpr_data_ECX,
    output logic [15: 0] o_wrb_gpr_data_CX,
    output logic [ 7: 0] o_wrb_gpr_data_CL,
    output logic [ 7: 0] o_wrb_gpr_data_CH,
    output logic [31: 0] o_wrb_gpr_data_EDX,
    output logic [15: 0] o_wrb_gpr_data_DX,
    output logic [ 7: 0] o_wrb_gpr_data_DL,
    output logic [ 7: 0] o_wrb_gpr_data_DH,
    output logic [31: 0] o_wrb_gpr_data_ESP,
    output logic [15: 0] o_wrb_gpr_data_SP,
    output logic [31: 0] o_wrb_gpr_data_EBP,
    output logic [15: 0] o_wrb_gpr_data_BP,
    output logic [31: 0] o_wrb_gpr_data_ESI,
    output logic [15: 0] o_wrb_gpr_data_SI,
    output logic [31: 0] o_wrb_gpr_data_EDI,
    output logic [15: 0] o_wrb_gpr_data_DI,
    output logic [15: 0] o_wrb_seg_selector,
    output logic [63: 0] o_wrb_seg_descriptor,
    output logic [31: 0] o_wrb_flags_data,
    output logic         o_cf,
    output logic         o_pf,
    output logic         o_af,
    output logic         o_zf,
    output logic         o_sf,
    output logic         o_of,
    output logic         o_mem_valid,
    output logic         o_mem_write_enable,
    output logic [31: 0] o_mem_address,
    output logic [31: 0] o_mem_write_data,
    input  logic         clk,
    input  logic         rst_n
);

    logic         unit_valid;
    logic [ 5: 0] unit_opcode;
    logic [31: 0] unit_src1_data;
    logic [31: 0] unit_src2_data;
    logic [31: 0] unit_immediate;
    logic [31: 0] unit_displacement;
    logic         unit_cf;
    logic         unit_pf;
    logic         unit_af;
    logic         unit_zf;
    logic         unit_sf;
    logic         unit_of;
    logic [ 2: 0] unit_dest_reg;
    logic [ 3: 0] unit_tttn;
    logic         unit_has_imm;
    logic         unit_has_disp;

    logic         add_wrb_gpr_enable_EAX;
    logic         add_wrb_gpr_enable_AX;
    logic         add_wrb_gpr_enable_AL;
    logic         add_wrb_gpr_enable_AH;
    logic         add_wrb_gpr_enable_EBX;
    logic         add_wrb_gpr_enable_BX;
    logic         add_wrb_gpr_enable_BL;
    logic         add_wrb_gpr_enable_BH;
    logic         add_wrb_gpr_enable_ECX;
    logic         add_wrb_gpr_enable_CX;
    logic         add_wrb_gpr_enable_CL;
    logic         add_wrb_gpr_enable_CH;
    logic         add_wrb_gpr_enable_EDX;
    logic         add_wrb_gpr_enable_DX;
    logic         add_wrb_gpr_enable_DL;
    logic         add_wrb_gpr_enable_DH;
    logic         add_wrb_gpr_enable_ESP;
    logic         add_wrb_gpr_enable_SP;
    logic         add_wrb_gpr_enable_EBP;
    logic         add_wrb_gpr_enable_BP;
    logic         add_wrb_gpr_enable_ESI;
    logic         add_wrb_gpr_enable_SI;
    logic         add_wrb_gpr_enable_EDI;
    logic         add_wrb_gpr_enable_DI;
    logic         add_wrb_seg_enable_es;
    logic         add_wrb_seg_enable_cs;
    logic         add_wrb_seg_enable_ss;
    logic         add_wrb_seg_enable_ds;
    logic         add_wrb_seg_enable_fs;
    logic         add_wrb_seg_enable_gs;
    logic         add_wrb_flags_enable;
    logic         add_wrb_ip_enable;
    logic [31: 0] add_wrb_ip_data;
    logic [31: 0] add_wrb_gpr_data_EAX;
    logic [15: 0] add_wrb_gpr_data_AX;
    logic [ 7: 0] add_wrb_gpr_data_AL;
    logic [ 7: 0] add_wrb_gpr_data_AH;
    logic [31: 0] add_wrb_gpr_data_EBX;
    logic [15: 0] add_wrb_gpr_data_BX;
    logic [ 7: 0] add_wrb_gpr_data_BL;
    logic [ 7: 0] add_wrb_gpr_data_BH;
    logic [31: 0] add_wrb_gpr_data_ECX;
    logic [15: 0] add_wrb_gpr_data_CX;
    logic [ 7: 0] add_wrb_gpr_data_CL;
    logic [ 7: 0] add_wrb_gpr_data_CH;
    logic [31: 0] add_wrb_gpr_data_EDX;
    logic [15: 0] add_wrb_gpr_data_DX;
    logic [ 7: 0] add_wrb_gpr_data_DL;
    logic [ 7: 0] add_wrb_gpr_data_DH;
    logic [31: 0] add_wrb_gpr_data_ESP;
    logic [15: 0] add_wrb_gpr_data_SP;
    logic [31: 0] add_wrb_gpr_data_EBP;
    logic [15: 0] add_wrb_gpr_data_BP;
    logic [31: 0] add_wrb_gpr_data_ESI;
    logic [15: 0] add_wrb_gpr_data_SI;
    logic [31: 0] add_wrb_gpr_data_EDI;
    logic [15: 0] add_wrb_gpr_data_DI;
    logic [15: 0] add_wrb_seg_selector;
    logic [63: 0] add_wrb_seg_descriptor;
    logic [31: 0] add_wrb_flags_data;
    logic         add_cf;
    logic         add_pf;
    logic         add_af;
    logic         add_zf;
    logic         add_sf;
    logic         add_of;
    logic         add_mem_valid;
    logic         add_mem_write_enable;
    logic [31: 0] add_mem_address;
    logic [31: 0] add_mem_write_data;

    assign unit_valid = i_valid;
    assign unit_opcode = i_uop_opcode;
    assign unit_src1_data = i_src1_data;
    assign unit_src2_data = i_src2_data;
    assign unit_immediate = i_immediate;
    assign unit_displacement = i_displacement;
    assign unit_cf = i_cf;
    assign unit_pf = i_pf;
    assign unit_af = i_af;
    assign unit_zf = i_zf;
    assign unit_sf = i_sf;
    assign unit_of = i_of;
    assign unit_dest_reg = i_dest_reg;
    assign unit_tttn = i_tttn;
    assign unit_has_imm = i_has_imm;
    assign unit_has_disp = i_has_disp;

    exu_add u_add (
        .i_valid          (unit_valid && (unit_opcode == `UOP_ADD)),
        .i_src1_data     (unit_src1_data),
        .i_src2_data     (unit_src2_data),
        .i_immediate     (unit_immediate),
        .i_displacement  (unit_displacement),
        .i_cf            (unit_cf),
        .i_pf            (unit_pf),
        .i_af            (unit_af),
        .i_zf            (unit_zf),
        .i_sf            (unit_sf),
        .i_of            (unit_of),
        .i_dest_reg      (unit_dest_reg),
        .i_has_imm       (unit_has_imm),
        .i_has_disp      (unit_has_disp),
        .o_wrb_gpr_enable_EAX (add_wrb_gpr_enable_EAX),
        .o_wrb_gpr_enable_AX  (add_wrb_gpr_enable_AX),
        .o_wrb_gpr_enable_AL  (add_wrb_gpr_enable_AL),
        .o_wrb_gpr_enable_AH  (add_wrb_gpr_enable_AH),
        .o_wrb_gpr_enable_EBX (add_wrb_gpr_enable_EBX),
        .o_wrb_gpr_enable_BX  (add_wrb_gpr_enable_BX),
        .o_wrb_gpr_enable_BL  (add_wrb_gpr_enable_BL),
        .o_wrb_gpr_enable_BH  (add_wrb_gpr_enable_BH),
        .o_wrb_gpr_enable_ECX (add_wrb_gpr_enable_ECX),
        .o_wrb_gpr_enable_CX  (add_wrb_gpr_enable_CX),
        .o_wrb_gpr_enable_CL  (add_wrb_gpr_enable_CL),
        .o_wrb_gpr_enable_CH  (add_wrb_gpr_enable_CH),
        .o_wrb_gpr_enable_EDX (add_wrb_gpr_enable_EDX),
        .o_wrb_gpr_enable_DX  (add_wrb_gpr_enable_DX),
        .o_wrb_gpr_enable_DL  (add_wrb_gpr_enable_DL),
        .o_wrb_gpr_enable_DH  (add_wrb_gpr_enable_DH),
        .o_wrb_gpr_enable_ESP (add_wrb_gpr_enable_ESP),
        .o_wrb_gpr_enable_SP  (add_wrb_gpr_enable_SP),
        .o_wrb_gpr_enable_EBP (add_wrb_gpr_enable_EBP),
        .o_wrb_gpr_enable_BP  (add_wrb_gpr_enable_BP),
        .o_wrb_gpr_enable_ESI (add_wrb_gpr_enable_ESI),
        .o_wrb_gpr_enable_SI  (add_wrb_gpr_enable_SI),
        .o_wrb_gpr_enable_EDI (add_wrb_gpr_enable_EDI),
        .o_wrb_gpr_enable_DI  (add_wrb_gpr_enable_DI),
        .o_wrb_seg_enable_es (add_wrb_seg_enable_es),
        .o_wrb_seg_enable_cs (add_wrb_seg_enable_cs),
        .o_wrb_seg_enable_ss (add_wrb_seg_enable_ss),
        .o_wrb_seg_enable_ds (add_wrb_seg_enable_ds),
        .o_wrb_seg_enable_fs (add_wrb_seg_enable_fs),
        .o_wrb_seg_enable_gs (add_wrb_seg_enable_gs),
        .o_wrb_flags_enable (add_wrb_flags_enable),
        .o_wrb_ip_enable   (add_wrb_ip_enable),
        .o_wrb_ip_data     (add_wrb_ip_data),
        .o_wrb_gpr_data_EAX (add_wrb_gpr_data_EAX),
        .o_wrb_gpr_data_AX  (add_wrb_gpr_data_AX),
        .o_wrb_gpr_data_AL  (add_wrb_gpr_data_AL),
        .o_wrb_gpr_data_AH  (add_wrb_gpr_data_AH),
        .o_wrb_gpr_data_EBX (add_wrb_gpr_data_EBX),
        .o_wrb_gpr_data_BX  (add_wrb_gpr_data_BX),
        .o_wrb_gpr_data_BL  (add_wrb_gpr_data_BL),
        .o_wrb_gpr_data_BH  (add_wrb_gpr_data_BH),
        .o_wrb_gpr_data_ECX (add_wrb_gpr_data_ECX),
        .o_wrb_gpr_data_CX  (add_wrb_gpr_data_CX),
        .o_wrb_gpr_data_CL  (add_wrb_gpr_data_CL),
        .o_wrb_gpr_data_CH  (add_wrb_gpr_data_CH),
        .o_wrb_gpr_data_EDX (add_wrb_gpr_data_EDX),
        .o_wrb_gpr_data_DX  (add_wrb_gpr_data_DX),
        .o_wrb_gpr_data_DL  (add_wrb_gpr_data_DL),
        .o_wrb_gpr_data_DH  (add_wrb_gpr_data_DH),
        .o_wrb_gpr_data_ESP (add_wrb_gpr_data_ESP),
        .o_wrb_gpr_data_SP  (add_wrb_gpr_data_SP),
        .o_wrb_gpr_data_EBP (add_wrb_gpr_data_EBP),
        .o_wrb_gpr_data_BP  (add_wrb_gpr_data_BP),
        .o_wrb_gpr_data_ESI (add_wrb_gpr_data_ESI),
        .o_wrb_gpr_data_SI  (add_wrb_gpr_data_SI),
        .o_wrb_gpr_data_EDI (add_wrb_gpr_data_EDI),
        .o_wrb_gpr_data_DI  (add_wrb_gpr_data_DI),
        .o_wrb_seg_selector   (add_wrb_seg_selector),
        .o_wrb_seg_descriptor (add_wrb_seg_descriptor),
        .o_wrb_flags_data     (add_wrb_flags_data),
        .o_cf            (add_cf),
        .o_pf            (add_pf),
        .o_af            (add_af),
        .o_zf            (add_zf),
        .o_sf            (add_sf),
        .o_of            (add_of),
        .o_mem_valid        (add_mem_valid),
        .o_mem_write_enable (add_mem_write_enable),
        .o_mem_address      (add_mem_address),
        .o_mem_write_data   (add_mem_write_data),
        .clk             (clk),
        .rst_n           (rst_n)
    );

    exu_result_t sub_result;
    logic        sub_active;

    assign sub_active = unit_valid && (unit_opcode == `UOP_SUB);

    exu_sub u_sub (
        .i_src1_data (unit_src1_data),
        .i_src2_data (unit_src2_data),
        .i_immediate (unit_immediate),
        .i_has_imm   (unit_has_imm),
        .o_result    (sub_result)
    );

    assign o_wrb_gpr_enable_EAX = add_wrb_gpr_enable_EAX | (sub_active && (unit_dest_reg == 3'd0));
    assign o_wrb_gpr_enable_AX  = add_wrb_gpr_enable_AX  | (sub_active && (unit_dest_reg == 3'd0));
    assign o_wrb_gpr_enable_AL  = add_wrb_gpr_enable_AL  | (sub_active && (unit_dest_reg == 3'd0));
    assign o_wrb_gpr_enable_AH  = add_wrb_gpr_enable_AH  | (sub_active && (unit_dest_reg == 3'd0));
    assign o_wrb_gpr_enable_EBX = add_wrb_gpr_enable_EBX | (sub_active && (unit_dest_reg == 3'd3));
    assign o_wrb_gpr_enable_BX  = add_wrb_gpr_enable_BX  | (sub_active && (unit_dest_reg == 3'd3));
    assign o_wrb_gpr_enable_BL  = add_wrb_gpr_enable_BL  | (sub_active && (unit_dest_reg == 3'd3));
    assign o_wrb_gpr_enable_BH  = add_wrb_gpr_enable_BH  | (sub_active && (unit_dest_reg == 3'd3));
    assign o_wrb_gpr_enable_ECX = add_wrb_gpr_enable_ECX | (sub_active && (unit_dest_reg == 3'd1));
    assign o_wrb_gpr_enable_CX  = add_wrb_gpr_enable_CX  | (sub_active && (unit_dest_reg == 3'd1));
    assign o_wrb_gpr_enable_CL  = add_wrb_gpr_enable_CL  | (sub_active && (unit_dest_reg == 3'd1));
    assign o_wrb_gpr_enable_CH  = add_wrb_gpr_enable_CH  | (sub_active && (unit_dest_reg == 3'd1));
    assign o_wrb_gpr_enable_EDX = add_wrb_gpr_enable_EDX | (sub_active && (unit_dest_reg == 3'd2));
    assign o_wrb_gpr_enable_DX  = add_wrb_gpr_enable_DX  | (sub_active && (unit_dest_reg == 3'd2));
    assign o_wrb_gpr_enable_DL  = add_wrb_gpr_enable_DL  | (sub_active && (unit_dest_reg == 3'd2));
    assign o_wrb_gpr_enable_DH  = add_wrb_gpr_enable_DH  | (sub_active && (unit_dest_reg == 3'd2));
    assign o_wrb_gpr_enable_ESP = add_wrb_gpr_enable_ESP | (sub_active && (unit_dest_reg == 3'd4));
    assign o_wrb_gpr_enable_SP  = add_wrb_gpr_enable_SP  | (sub_active && (unit_dest_reg == 3'd4));
    assign o_wrb_gpr_enable_EBP = add_wrb_gpr_enable_EBP | (sub_active && (unit_dest_reg == 3'd5));
    assign o_wrb_gpr_enable_BP  = add_wrb_gpr_enable_BP  | (sub_active && (unit_dest_reg == 3'd5));
    assign o_wrb_gpr_enable_ESI = add_wrb_gpr_enable_ESI | (sub_active && (unit_dest_reg == 3'd6));
    assign o_wrb_gpr_enable_SI  = add_wrb_gpr_enable_SI  | (sub_active && (unit_dest_reg == 3'd6));
    assign o_wrb_gpr_enable_EDI = add_wrb_gpr_enable_EDI | (sub_active && (unit_dest_reg == 3'd7));
    assign o_wrb_gpr_enable_DI  = add_wrb_gpr_enable_DI  | (sub_active && (unit_dest_reg == 3'd7));

    assign o_wrb_gpr_data_EAX = sub_active ? sub_result.result : add_wrb_gpr_data_EAX;
    assign o_wrb_gpr_data_AX  = sub_active ? sub_result.result[15: 0] : add_wrb_gpr_data_AX;
    assign o_wrb_gpr_data_AL  = sub_active ? sub_result.result[ 7: 0] : add_wrb_gpr_data_AL;
    assign o_wrb_gpr_data_AH  = sub_active ? sub_result.result[15: 8] : add_wrb_gpr_data_AH;
    assign o_wrb_gpr_data_EBX = sub_active ? sub_result.result : add_wrb_gpr_data_EBX;
    assign o_wrb_gpr_data_BX  = sub_active ? sub_result.result[15: 0] : add_wrb_gpr_data_BX;
    assign o_wrb_gpr_data_BL  = sub_active ? sub_result.result[ 7: 0] : add_wrb_gpr_data_BL;
    assign o_wrb_gpr_data_BH  = sub_active ? sub_result.result[15: 8] : add_wrb_gpr_data_BH;
    assign o_wrb_gpr_data_ECX = sub_active ? sub_result.result : add_wrb_gpr_data_ECX;
    assign o_wrb_gpr_data_CX  = sub_active ? sub_result.result[15: 0] : add_wrb_gpr_data_CX;
    assign o_wrb_gpr_data_CL  = sub_active ? sub_result.result[ 7: 0] : add_wrb_gpr_data_CL;
    assign o_wrb_gpr_data_CH  = sub_active ? sub_result.result[15: 8] : add_wrb_gpr_data_CH;
    assign o_wrb_gpr_data_EDX = sub_active ? sub_result.result : add_wrb_gpr_data_EDX;
    assign o_wrb_gpr_data_DX  = sub_active ? sub_result.result[15: 0] : add_wrb_gpr_data_DX;
    assign o_wrb_gpr_data_DL  = sub_active ? sub_result.result[ 7: 0] : add_wrb_gpr_data_DL;
    assign o_wrb_gpr_data_DH  = sub_active ? sub_result.result[15: 8] : add_wrb_gpr_data_DH;
    assign o_wrb_gpr_data_ESP = sub_active ? sub_result.result : add_wrb_gpr_data_ESP;
    assign o_wrb_gpr_data_SP  = sub_active ? sub_result.result[15: 0] : add_wrb_gpr_data_SP;
    assign o_wrb_gpr_data_EBP = sub_active ? sub_result.result : add_wrb_gpr_data_EBP;
    assign o_wrb_gpr_data_BP  = sub_active ? sub_result.result[15: 0] : add_wrb_gpr_data_BP;
    assign o_wrb_gpr_data_ESI = sub_active ? sub_result.result : add_wrb_gpr_data_ESI;
    assign o_wrb_gpr_data_SI  = sub_active ? sub_result.result[15: 0] : add_wrb_gpr_data_SI;
    assign o_wrb_gpr_data_EDI = sub_active ? sub_result.result : add_wrb_gpr_data_EDI;
    assign o_wrb_gpr_data_DI  = sub_active ? sub_result.result[15: 0] : add_wrb_gpr_data_DI;
    assign o_wrb_seg_enable_es = add_wrb_seg_enable_es;
    assign o_wrb_seg_enable_cs = add_wrb_seg_enable_cs;
    assign o_wrb_seg_enable_ss = add_wrb_seg_enable_ss;
    assign o_wrb_seg_enable_ds = add_wrb_seg_enable_ds;
    assign o_wrb_seg_enable_fs = add_wrb_seg_enable_fs;
    assign o_wrb_seg_enable_gs = add_wrb_seg_enable_gs;
    assign o_wrb_flags_enable = add_wrb_flags_enable | sub_active;
    assign o_wrb_ip_enable   = add_wrb_ip_enable;
    assign o_wrb_ip_data     = add_wrb_ip_data;
    assign o_wrb_seg_selector   = add_wrb_seg_selector;
    assign o_wrb_seg_descriptor = add_wrb_seg_descriptor;
    assign o_wrb_flags_data     = add_wrb_flags_data;
    assign o_cf = sub_active ? sub_result.cf : add_cf;
    assign o_pf = sub_active ? sub_result.pf : add_pf;
    assign o_af = sub_active ? sub_result.af : add_af;
    assign o_zf = sub_active ? sub_result.zf : add_zf;
    assign o_sf = sub_active ? sub_result.sf : add_sf;
    assign o_of = sub_active ? sub_result.of : add_of;
    assign o_mem_valid        = add_mem_valid;
    assign o_mem_write_enable = add_mem_write_enable;
    assign o_mem_address      = add_mem_address;
    assign o_mem_write_data   = add_mem_write_data;

endmodule
