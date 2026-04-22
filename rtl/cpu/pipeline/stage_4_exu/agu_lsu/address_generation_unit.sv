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

module address_generation_unit (    input  logic [31: 0] i_base,  // 基址
    input  logic [31: 0] i_index, // 变址
    input  logic [ 1: 0]   i_scale, // 比例因子编码
    input  logic [31: 0] i_disp, // 位移（符号扩展）
    output logic [31: 0] o_effective_address // 有效地址
);

    logic [63: 0] scaled;  // index×scale 的 64 位项
    logic [63: 0] sum;  // base + scaled + disp（截断前）

    // 组合逻辑：连续赋值
    assign sum = {32'h0, i_base} + scaled + {{32{i_disp[31]}}, i_disp};

    // 组合逻辑：推导输出
    always_comb begin
        // SIB.scale：0/1/2/3 → ×1/×2/×4/×8
        unique case (i_scale)
            2'd0: scaled = {32'h0, i_index} * 64'd1;
            2'd1: scaled = {32'h0, i_index} * 64'd2;
            2'd2: scaled = {32'h0, i_index} * 64'd4;
            default: scaled = {32'h0, i_index} * 64'd8;
        endcase
    end

    // 组合逻辑：连续赋值
    assign o_effective_address = sum[31: 0];

endmodule
