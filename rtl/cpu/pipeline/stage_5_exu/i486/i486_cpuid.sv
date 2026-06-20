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
//  File        : i486_cpuid.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : CPUID leaf 0/1 feature reporting
// ============================================================================

`include "openx86_defs.h.sv"

module i486_cpuid (
    input  logic [31: 0] i_eax_in,
    input  logic [31: 0] i_ecx_in,
    output logic [31: 0] o_eax,
    output logic [31: 0] o_ebx,
    output logic [31: 0] o_ecx,
    output logic [31: 0] o_edx
);

    logic [31: 0] vendor_ebx;
    logic [31: 0] vendor_edx;
    logic [31: 0] vendor_ecx;
    logic [31: 0] feature_edx;

    assign vendor_ebx = 32'h6E65476F; // "Genu"
    assign vendor_edx = 32'h49656E69; // "ineI"
    assign vendor_ecx = 32'h6E65476F; // "ntel" placeholder

    assign feature_edx = {
        `cpuid_feature_pbe,            1'b0,
        `cpuid_feature_ia64,           1'b0,
        `cpuid_feature_tm,              1'b0,
        `cpuid_feature_htt,             1'b0,
        1'b0,                           1'b0,
        `cpuid_feature_sse2,            1'b0,
        `cpuid_feature_sse,            1'b0,
        `cpuid_feature_fxsr,           1'b0,
        `cpuid_feature_mmx,            1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        `cpuid_feature_fpu,            1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0,
        1'b0,                           1'b0
    };

    always_comb begin
        o_eax = 32'd0;
        o_ebx = 32'd0;
        o_ecx = 32'd0;
        o_edx = 32'd0;

        unique case (i_eax_in)
            32'd0: begin
                o_eax = 32'd1;
                o_ebx = vendor_ebx;
                o_ecx = vendor_ecx;
                o_edx = vendor_edx;
            end
            32'd1: begin
                o_eax = {4'd0, `cpuid_extended_family_id, 4'd0,
                         `cpuid_extended_model_id, 4'd0,
                         `cpuid_family_id, 4'd0, `cpuid_model_id, `cpuid_stepping_id};
                o_ebx = 32'd0;
                o_ecx = 32'd0;
                o_edx = feature_edx;
            end
            default: begin
                o_eax = 32'd0;
                o_ebx = 32'd0;
                o_ecx = 32'd0;
                o_edx = 32'd0;
            end
        endcase
    end

endmodule
