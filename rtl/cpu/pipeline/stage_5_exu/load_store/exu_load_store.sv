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
//  File        : exu_load_store.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Load/Store execution unit - memory access operations
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_load_store (
    input  logic         i_valid,
    input  logic         i_mem_access,
    input  logic         i_is_store,
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [31: 0] i_displacement,
    input  logic [ 2: 0] i_dest_reg,
    output logic         o_wrb_gpr_enable_EAX,
    output logic         o_wrb_gpr_enable_AX,
    output logic         o_wrb_gpr_enable_AL,
    output logic         o_wrb_gpr_enable_AH,
    output logic         o_wrb_gpr_enable_EBX,
    output logic         o_wrb_gpr_enable_BX,
    output logic         o_wrb_gpr_enable_BL,
    output logic         o_wrb_gpr_enable_BH,
    output logic         o_wrb_gpr_enable_ECX,
    output logic         o_wrb_gpr_enable_CX,
    output logic         o_wrb_gpr_enable_CL,
    output logic         o_wrb_gpr_enable_CH,
    output logic         o_wrb_gpr_enable_EDX,
    output logic         o_wrb_gpr_enable_DX,
    output logic         o_wrb_gpr_enable_DL,
    output logic         o_wrb_gpr_enable_DH,
    output logic         o_wrb_gpr_enable_ESP,
    output logic         o_wrb_gpr_enable_SP,
    output logic         o_wrb_gpr_enable_EBP,
    output logic         o_wrb_gpr_enable_BP,
    output logic         o_wrb_gpr_enable_ESI,
    output logic         o_wrb_gpr_enable_SI,
    output logic         o_wrb_gpr_enable_EDI,
    output logic         o_wrb_gpr_enable_DI,
    output logic [31: 0] o_wrb_gpr_data_EAX,
    output logic [15: 0] o_wrb_gpr_data_AX,
    output logic [ 7: 0] o_wrb_gpr_data_AL,
    output logic [ 7: 0] o_wrb_gpr_data_AH,
    output logic [31: 0] o_wrb_gpr_data_EBX,
    output logic [15: 0] o_wrb_gpr_data_BX,
    output logic [ 7: 0] o_wrb_gpr_data_BL,
    output logic [ 7: 0] o_wrb_gpr_data_BH,
    output logic [31: 0] o_wrb_gpr_data_ECX,
    output logic [15: 0] o_wrb_gpr_data_CX,
    output logic [ 7: 0] o_wrb_gpr_data_CL,
    output logic [ 7: 0] o_wrb_gpr_data_CH,
    output logic [31: 0] o_wrb_gpr_data_EDX,
    output logic [15: 0] o_wrb_gpr_data_DX,
    output logic [ 7: 0] o_wrb_gpr_data_DL,
    output logic [ 7: 0] o_wrb_gpr_data_DH,
    output logic [31: 0] o_wrb_gpr_data_ESP,
    output logic [15: 0] o_wrb_gpr_data_SP,
    output logic [31: 0] o_wrb_gpr_data_EBP,
    output logic [15: 0] o_wrb_gpr_data_BP,
    output logic [31: 0] o_wrb_gpr_data_ESI,
    output logic [15: 0] o_wrb_gpr_data_SI,
    output logic [31: 0] o_wrb_gpr_data_EDI,
    output logic [15: 0] o_wrb_gpr_data_DI,
    output logic         o_mem_valid,
    output logic         o_mem_write_enable,
    output logic [31: 0] o_mem_address,
    output logic [31: 0] o_mem_write_data,
    input  logic         clk,
    input  logic         rst_n
);

    logic [31: 0] mem_addr;
    logic [31: 0] mem_data;

    assign mem_addr = i_src1_data + i_displacement;
    assign mem_data = i_src2_data;

    always_comb begin
        o_wrb_gpr_enable_EAX = 1'b0;
        o_wrb_gpr_enable_AX  = 1'b0;
        o_wrb_gpr_enable_AL  = 1'b0;
        o_wrb_gpr_enable_AH  = 1'b0;
        o_wrb_gpr_enable_EBX = 1'b0;
        o_wrb_gpr_enable_BX  = 1'b0;
        o_wrb_gpr_enable_BL  = 1'b0;
        o_wrb_gpr_enable_BH  = 1'b0;
        o_wrb_gpr_enable_ECX = 1'b0;
        o_wrb_gpr_enable_CX  = 1'b0;
        o_wrb_gpr_enable_CL  = 1'b0;
        o_wrb_gpr_enable_CH  = 1'b0;
        o_wrb_gpr_enable_EDX = 1'b0;
        o_wrb_gpr_enable_DX  = 1'b0;
        o_wrb_gpr_enable_DL  = 1'b0;
        o_wrb_gpr_enable_DH  = 1'b0;
        o_wrb_gpr_enable_ESP = 1'b0;
        o_wrb_gpr_enable_SP  = 1'b0;
        o_wrb_gpr_enable_EBP = 1'b0;
        o_wrb_gpr_enable_BP  = 1'b0;
        o_wrb_gpr_enable_ESI = 1'b0;
        o_wrb_gpr_enable_SI  = 1'b0;
        o_wrb_gpr_enable_EDI = 1'b0;
        o_wrb_gpr_enable_DI  = 1'b0;

        if (i_valid && i_mem_access && !i_is_store) begin
            case (i_dest_reg)
                3'd0: begin o_wrb_gpr_enable_EAX = 1'b1; o_wrb_gpr_enable_AX = 1'b1;
                        o_wrb_gpr_enable_AL = 1'b1; o_wrb_gpr_enable_AH = 1'b1; end
                3'd1: begin o_wrb_gpr_enable_ECX = 1'b1; o_wrb_gpr_enable_CX = 1'b1;
                        o_wrb_gpr_enable_CL = 1'b1; o_wrb_gpr_enable_CH = 1'b1; end
                3'd2: begin o_wrb_gpr_enable_EDX = 1'b1; o_wrb_gpr_enable_DX = 1'b1;
                        o_wrb_gpr_enable_DL = 1'b1; o_wrb_gpr_enable_DH = 1'b1; end
                3'd3: begin o_wrb_gpr_enable_EBX = 1'b1; o_wrb_gpr_enable_BX = 1'b1;
                        o_wrb_gpr_enable_BL = 1'b1; o_wrb_gpr_enable_BH = 1'b1; end
                3'd4: begin o_wrb_gpr_enable_ESP = 1'b1; o_wrb_gpr_enable_SP = 1'b1; end
                3'd5: begin o_wrb_gpr_enable_EBP = 1'b1; o_wrb_gpr_enable_BP = 1'b1; end
                3'd6: begin o_wrb_gpr_enable_ESI = 1'b1; o_wrb_gpr_enable_SI = 1'b1; end
                3'd7: begin o_wrb_gpr_enable_EDI = 1'b1; o_wrb_gpr_enable_DI = 1'b1; end
            endcase
        end
    end

    assign o_wrb_gpr_data_EAX = mem_data;
    assign o_wrb_gpr_data_AX  = mem_data[15: 0];
    assign o_wrb_gpr_data_AL  = mem_data[ 7: 0];
    assign o_wrb_gpr_data_AH  = mem_data[15: 8];
    assign o_wrb_gpr_data_EBX = mem_data;
    assign o_wrb_gpr_data_BX  = mem_data[15: 0];
    assign o_wrb_gpr_data_BL  = mem_data[ 7: 0];
    assign o_wrb_gpr_data_BH  = mem_data[15: 8];
    assign o_wrb_gpr_data_ECX = mem_data;
    assign o_wrb_gpr_data_CX  = mem_data[15: 0];
    assign o_wrb_gpr_data_CL  = mem_data[ 7: 0];
    assign o_wrb_gpr_data_CH  = mem_data[15: 8];
    assign o_wrb_gpr_data_EDX = mem_data;
    assign o_wrb_gpr_data_DX  = mem_data[15: 0];
    assign o_wrb_gpr_data_DL  = mem_data[ 7: 0];
    assign o_wrb_gpr_data_DH  = mem_data[15: 8];
    assign o_wrb_gpr_data_ESP = mem_data;
    assign o_wrb_gpr_data_SP  = mem_data[15: 0];
    assign o_wrb_gpr_data_EBP = mem_data;
    assign o_wrb_gpr_data_BP  = mem_data[15: 0];
    assign o_wrb_gpr_data_ESI = mem_data;
    assign o_wrb_gpr_data_SI  = mem_data[15: 0];
    assign o_wrb_gpr_data_EDI = mem_data;
    assign o_wrb_gpr_data_DI  = mem_data[15: 0];

    assign o_mem_valid        = i_valid && i_mem_access;
    assign o_mem_write_enable = i_valid && i_mem_access && i_is_store;
    assign o_mem_address      = mem_addr;
    assign o_mem_write_data   = mem_data;

endmodule
