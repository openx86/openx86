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
//  File        : exu_string.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : STRING execution — pointer update + REP/ECX restart hints
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_string (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [31: 0] i_ecx,
    input  logic [ 1: 0] i_mem_size,
    input  logic         i_is_store,
    input  logic         i_df,
    input  logic         i_rep,
    input  logic         i_repne,
    input  logic         i_zf,
    output exu_result_t  o_result,
    output logic         o_rep_restart,
    output logic [31: 0] o_ecx_next
);

    logic [31: 0] elem_bytes;
    logic [31: 0] step;
    logic         cond_ok;

    always_comb begin
        unique case (i_mem_size)
            2'b00:   elem_bytes = 32'd1;
            2'b01:   elem_bytes = 32'd2;
            default: elem_bytes = 32'd4;
        endcase
    end
    assign step = i_df ? (~elem_bytes + 32'd1) : elem_bytes;
    // REPE continues while ZF=1; REPNE while ZF=0; plain REP ignores ZF
    assign cond_ok  = i_repne ? ~i_zf : 1'b1;
    assign o_ecx_next = (i_ecx == 32'd0) ? 32'd0 : (i_ecx - 32'd1);
    assign o_rep_restart = (i_rep | i_repne) & (i_ecx > 32'd1) & cond_ok;

    always_comb begin
        o_result.result           = i_src1_data + step;
        o_result.cf               = 1'b0;
        o_result.pf               = 1'b0;
        o_result.af               = 1'b0;
        o_result.zf               = 1'b0;
        o_result.sf               = 1'b0;
        o_result.of               = 1'b0;
        o_result.mem_valid        = 1'b1;
        o_result.mem_write_enable = i_is_store;
        o_result.mem_address      = i_src1_data;
        o_result.mem_write_data   = i_src2_data;
    end

endmodule
