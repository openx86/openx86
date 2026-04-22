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
//  File        : rf_x87_fpu.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : rf_x87_fpu module
// ============================================================================

module rf_x87_fpu (

    // =========================
    // write interface
    // =========================
    input  logic         write_enable,
    input  logic [2:0]   write_sti,     // logical ST(i)
    input  logic [79:0]  write_data,    // x87 = 80-bit

    // push / pop control
    input  logic         push,
    input  logic         pop,

    // =========================
    // read interface
    // =========================
    input  logic [2:0]   read_sti,

    output logic [79:0]  read_st0,
    output logic [79:0]  read_sti_data,

    // full logical view (like GPR style)
    output logic [7:0][79:0] read_stack,

    // =========================
    // status
    // =========================
    output logic [2:0]   top_ptr,

    input  logic         rst_n,
    input  logic         clk
);

    // ============================================================
    // physical storage (ring buffer)
    // ============================================================
    logic [79:0] phys_reg [0:7];

    logic [2:0] top;

    assign top_ptr = top;

    // ============================================================
    // index mapping
    // ============================================================
    function automatic [2:0] map_idx(input [2:0] sti);
        map_idx = top + sti; // 自然溢出就是 mod 8
    endfunction

    logic [2:0] phys_write_idx = map_idx(write_sti);
    logic [2:0] phys_read_idx  = map_idx(read_sti);

    // ============================================================
    // sequential logic
    // ============================================================
    always_ff @(posedge clk or negedge rst_n) begin : ff_x87_stack
        if (~rst_n) begin
            top <= 3'd0;
            for (int i = 0; i < 8; i++) begin
                phys_reg[i] <= 80'h0;
            end
        end else begin

            // push: pre-decrement
            if (push)
                top <= top - 3'd1;

            // pop: post-increment
            else if (pop)
                top <= top + 3'd1;

            // write
            if (write_enable)
                phys_reg[phys_write_idx] <= write_data;
        end
    end

    // ============================================================
    // read logic
    // ============================================================
    always_comb begin
        read_st0      = phys_reg[top];
        read_sti_data = phys_reg[phys_read_idx];

        for (int i = 0; i < 8; i++) begin
            read_stack[i] = phys_reg[map_idx(i)];
        end
    end

endmodule
