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
//  File        : exu_flag_ctrl.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : FLAG_CTRL execution unit — EFLAGS subset updates
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_flag_ctrl (
    input  logic         i_cf,
    input  logic         i_pf,
    input  logic         i_af,
    input  logic         i_zf,
    input  logic         i_sf,
    input  logic         i_of,
    input  logic [31: 0] i_immediate,
    output exu_result_t  o_result
);

    // result[10]=DF shadow, result[9]=IF shadow for parent merge (CLD/STD/CLI/STI)
    always_comb begin
        o_result.result           = 32'd0;
        o_result.cf               = i_cf;
        o_result.pf               = i_pf;
        o_result.af               = i_af;
        o_result.zf               = i_zf;
        o_result.sf               = i_sf;
        o_result.of               = i_of;
        o_result.mem_valid        = 1'b0;
        o_result.mem_write_enable = 1'b0;
        o_result.mem_address      = 32'd0;
        o_result.mem_write_data   = 32'd0;

        unique case (i_immediate[7: 0])
            8'h01: o_result.cf = 1'b0;           // CLC
            8'h02: o_result.cf = 1'b1;           // STC
            8'h03: o_result.cf = ~i_cf;          // CMC
            8'h04: o_result.result[10] = 1'b0;   // CLD → DF=0
            8'h05: o_result.result[10] = 1'b1;   // STD → DF=1
            8'h06: o_result.result[9]  = 1'b0;   // CLI → IF=0
            8'h07: o_result.result[9]  = 1'b1;   // STI → IF=1
            default: ;
        endcase
    end

endmodule
