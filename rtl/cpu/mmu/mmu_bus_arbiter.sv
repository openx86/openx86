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
//  File        : mmu_bus_arbiter.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Arbitrate IFU and LSU MMU page-walk bus requests (IFU priority)
// ============================================================================

module mmu_bus_arbiter (
    input  logic         i_ifu_valid,
    output logic         o_ifu_ready,
    input  logic [31: 0] i_ifu_address,

    input  logic         i_lsu_valid,
    output logic         o_lsu_ready,
    input  logic [31: 0] i_lsu_address,

    output logic         o_mmu_valid,
    input  logic         i_mmu_ready,
    output logic [31: 0] o_mmu_address,

    input  logic         clk,
    input  logic         rst_n
);

    assign o_mmu_valid   = i_ifu_valid | i_lsu_valid;
    assign o_mmu_address = i_ifu_valid ? i_ifu_address : i_lsu_address;
    assign o_ifu_ready   = i_ifu_valid & i_mmu_ready;
    assign o_lsu_ready   = i_lsu_valid & ~i_ifu_valid & i_mmu_ready;

endmodule
