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
//  File        : dec_to_uop.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : dec_to_uop module
// ============================================================================

module dec_to_uop (
    // =========================
    // decode to uop handshake
    // =========================
    input  logic i_dec_ready,
    input  logic i_uop_ready,
    input  logic i_flush,
    output logic o_stage2_valid,
    output logic o_insn_fire
);

    assign o_stage2_valid = i_dec_ready;
    assign o_insn_fire   = i_dec_ready & i_uop_ready & ~i_flush;

endmodule
