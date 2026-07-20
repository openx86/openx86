// ============================================================================
// Copyright (c) 2026 Chang Wei
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
// File : v86_sensitive_check.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : V86 sensitive opcode vs IOPL #GP trap check (combinational)
// ============================================================================

module v86_sensitive_check (
    input  logic        i_vm,
    input  logic [ 1: 0] i_iopl,
    input  logic        i_op_cli,
    input  logic        i_op_sti,
    input  logic        i_op_pushf,
    input  logic        i_op_popf,
    input  logic        i_op_int,
    input  logic        i_op_iret,
    input  logic        i_op_in,
    input  logic        i_op_out,
    output logic        o_trap_gp
);

    logic sensitive;
    logic iopl_lt_3;

    assign sensitive  = i_op_cli | i_op_sti | i_op_pushf | i_op_popf |
                        i_op_int | i_op_iret | i_op_in | i_op_out;
    assign iopl_lt_3  = (i_iopl < 2'd3);
    // V86: IOPL < 3 makes listed ops trap to #GP (monitor)
    assign o_trap_gp  = i_vm & sensitive & iopl_lt_3;

endmodule
