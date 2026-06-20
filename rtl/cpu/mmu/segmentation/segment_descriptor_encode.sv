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
//  File        : segment_descriptor_encode.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : segment_descriptor_encode module
// ============================================================================

/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: segment_descriptor_encode
create at: 2022-01-27 13:23:55
description: encode the segment information to segment descriptor
*/

/* ref:
Intel486(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
4.3.4 Descriptors
4.3.4.1 DESCRIPTOR ATTRIBUTE BITS
The object to which the segment selector points to
is called a descriptor. Descriptors are eight byte
quantities which contain attributes about a given region of linear address space (i.e. a segment). These
attributes include the 32-bit base linear address of
the segment, the 20-bit length and granularity of the
segment, the protection level, read, write or execute
privileges, the default size of the operands (16-bit or
32-bit), and the type of segment. All of the attribute
information about a segment is contained in 12 bits
in the segment descriptor. Figure 4-5 shows the general format of a descriptor. All segments on the Intel486 DX have three attribute fields in common: the
P bit, the DPL bit, and the S bit. The Present P bit is
1 if the segment is loaded in physical memory, if
Pe0 then any attempt to access this segment causes a not present exception (exception 11). The Descriptor Privilege Level DPL is a two-bit field which
specifies the protection level 0–3 associated with a
segment
*/

module segment_descriptor_encode (
    // =========================
    // structured attributes to pack into 64-bit descriptor
    // =========================
    input  logic [31: 0] i_base,
    input  logic [19: 0] i_limit,
    input  logic          i_present,
    input  logic [ 1: 0] i_privilege_level,
    input  logic          i_available_field,
    input  logic          i_descriptor_type,
    input  logic          i_date_or_code_granularity,
    input  logic          i_date_or_code_default_operation_size,
    input  logic          i_date_or_code_executable,
    input  logic          i_data_expansion_direction_code_conforming,
    input  logic          i_data_writeable_code_readable,
    input  logic          i_date_or_code_accessed,

    // =========================
    // output
    // =========================
    output logic [63: 0] o_descriptor
);

    // ============================================================
    // pack according to manual bit order (including AVL/G/D/B attribute bits)
    // ============================================================
    assign o_descriptor = {
    i_base[15: 0],
    i_limit[15: 0],
    i_base[31: 24],
    i_date_or_code_granularity,
    i_date_or_code_default_operation_size,
    1'b0,
    i_available_field,
    i_limit[19: 16],
    i_present,
    i_privilege_level,
    i_descriptor_type,
    i_date_or_code_executable,
    i_data_expansion_direction_code_conforming,
    i_data_writeable_code_readable,
    i_date_or_code_accessed,
    i_base[23: 16]
};

endmodule
