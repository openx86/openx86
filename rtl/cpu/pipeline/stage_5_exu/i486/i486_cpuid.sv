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
//  Description : CPUID leaf 0/1 feature reporting (80486DX identity)
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
    logic [31: 0] version_eax;

    // Unused on 486DX leaf 1; keep port for future leaves
    // verilator lint_off UNUSEDSIGNAL
    logic unused_ecx;
    assign unused_ecx = |i_ecx_in;
    // verilator lint_on UNUSEDSIGNAL

    assign vendor_ebx = 32'h6E65704F; // "Open"
    assign vendor_edx = 32'h2D363858; // "X86-"
    assign vendor_ecx = 32'h65657246; // "Free"

    // Standard leaf-1 EAX: {ExtFamily, ExtModel, Type, Family, Model, Stepping}
    assign version_eax = {
        `cpuid_extended_family_id,
        `cpuid_extended_model_id,
        2'b00,
        `cpuid_processor_type,
        `cpuid_family_id,
        `cpuid_model_id,
        `cpuid_stepping_id
    };

    // Intel CPUID.1 EDX bit layout (bit0 = FPU)
    assign feature_edx = {
        `cpuid_feature_pbe,     // 31
        `cpuid_feature_ia64,    // 30
        `cpuid_feature_tm,      // 29
        `cpuid_feature_htt,     // 28
        `cpuid_feature_ss,      // 27
        `cpuid_feature_sse2,    // 26
        `cpuid_feature_sse,     // 25
        `cpuid_feature_fxsr,    // 24
        `cpuid_feature_mmx,     // 23
        `cpuid_feature_acpi,    // 22
        `cpuid_feature_ds,      // 21
        1'b0,                   // 20 reserved
        `cpuid_feature_clfsh,   // 19
        `cpuid_feature_psn,     // 18
        `cpuid_feature_pse36,   // 17
        `cpuid_feature_pat,     // 16
        `cpuid_feature_cmov,    // 15
        `cpuid_feature_mca,     // 14
        `cpuid_feature_pge,     // 13
        `cpuid_feature_mtrr,    // 12
        `cpuid_feature_sep,     // 11
        1'b0,                   // 10 reserved
        `cpuid_feature_apic,    // 9
        `cpuid_feature_cx8,     // 8
        `cpuid_feature_mce,     // 7
        `cpuid_feature_pae,     // 6
        `cpuid_feature_msr,     // 5
        `cpuid_feature_tsc,     // 4
        `cpuid_feature_pse,     // 3
        `cpuid_feature_de,      // 2
        `cpuid_feature_vme,     // 1
        `cpuid_feature_fpu      // 0
    };

    always_comb begin
        o_eax = 32'd0;
        o_ebx = 32'd0;
        o_ecx = 32'd0;
        o_edx = 32'd0;
        unique case (i_eax_in)
            32'd0: begin
                o_eax = `cpuid_max_EAX;
                o_ebx = vendor_ebx;
                o_ecx = vendor_ecx;
                o_edx = vendor_edx;
            end
            32'd1: begin
                o_eax = version_eax;
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
