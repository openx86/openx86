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
//  File        : address_generation_unit.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : address_generation_unit module
// ============================================================================

// ============================================================================
// Address Generation Unit (AGU)
// 有效地址 = base + index * {1,2,4,8} + displacement（32 位有符号扩展）
// 用于 ModR/M、SIB 寻址；段基址/分页在 MMU 侧叠加
// ============================================================================

module address_generation_unit (
    // =========================
    // address generation inputs
    // =========================
    input  logic [31: 0] i_base,
    input  logic [31: 0] i_index,
    input  logic [ 1: 0]   i_scale,
    input  logic [31: 0] i_disp,

    // =========================
    // output
    // =========================
    output logic [31: 0] o_effective_address
);

    // ============================================================
    // intermediate signals
    // ============================================================
    logic [63: 0] scaled;
    logic [63: 0] sum;

    // ============================================================
    // combinational logic: continuous assignment
    // ============================================================
    assign sum = {32'h0, i_base} + scaled + {{32{i_disp[31]}}, i_disp};

    // ============================================================
    // combinational logic: derive output
    // ============================================================
    always_comb begin : comb_scale
        // SIB.scale：0/1/2/3 → ×1/×2/×4/×8
        unique case (i_scale)
            2'd0: scaled = {32'h0, i_index} * 64'd1;
            2'd1: scaled = {32'h0, i_index} * 64'd2;
            2'd2: scaled = {32'h0, i_index} * 64'd4;
            default: scaled = {32'h0, i_index} * 64'd8;
        endcase
    end

    // ============================================================
    // combinational logic: continuous assignment
    // ============================================================
    assign o_effective_address = sum[31: 0];

endmodule
