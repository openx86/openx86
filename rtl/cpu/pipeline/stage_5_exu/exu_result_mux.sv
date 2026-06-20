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
//  File        : exu_result_mux.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Priority mux for exu_dispatch_out_t from parallel EXU units
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_result_mux #(
    parameter int LP_ENTRIES = 48
) (
    input  exu_dispatch_out_t i_entries [0: LP_ENTRIES - 1],
    input  logic [ 5: 0]      i_select,
    output exu_dispatch_out_t o_selected
);

    localparam int LP_IDX_WIDTH = $clog2(LP_ENTRIES);

    always_comb begin
        if (i_select < 6'(LP_ENTRIES)) begin
            o_selected = i_entries[i_select];
        end else begin
            o_selected = '0;
        end
    end

endmodule
