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
//  File        : x87_fpu_load_store.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : x87 memory load/store helpers
// ============================================================================

module x87_fpu_load_store (
    input  logic         i_load,
    input  logic         i_store,
    input  logic         i_real64,
    input  logic [31: 0] i_mem_data,
    input  logic [63: 0] i_st_mant,
    output logic [63: 0] o_st_mant,
    output logic [31: 0] o_mem_data,
    output logic         o_mem_write_enable
);

    assign o_st_mant          = i_load ? {32'd0, i_mem_data} : i_st_mant;
    assign o_mem_data         = i_store ? i_st_mant[31: 0] : 32'd0;
    assign o_mem_write_enable = i_store;

endmodule
