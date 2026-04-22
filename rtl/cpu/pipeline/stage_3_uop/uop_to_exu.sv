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
//  File        : uop_to_exu.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : uop_to_exu module
// ============================================================================

module uop_to_exu (
    // =========================
    // uop to exu handshake
    // =========================
    input  logic i_uop_valid,
    input  logic i_exu_ready,
    input  logic i_flush,
    output logic o_stage3_valid,
    output logic o_uop_fire
);

    assign o_stage3_valid = i_uop_valid & ~i_flush;
    assign o_uop_fire     = i_uop_valid & i_exu_ready & ~i_flush;

endmodule
