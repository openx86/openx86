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
//  File        : mmx_load_store.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : MMX MOVQ/MOVD load and store helpers
// ============================================================================

module mmx_load_store (
    input  logic         i_load_qword,
    input  logic         i_store_qword,
    input  logic [31: 0] i_mem_data,
    input  logic [63: 0] i_reg_data,
    output logic [63: 0] o_reg_data,
    output logic [31: 0] o_mem_data,
    output logic         o_mem_write_enable
);

    assign o_reg_data         = i_load_qword ? {32'd0, i_mem_data} : i_reg_data;
    assign o_mem_data         = i_store_qword ? i_reg_data[31: 0] : 32'd0;
    assign o_mem_write_enable = i_store_qword;

endmodule
