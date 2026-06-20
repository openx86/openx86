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
//  File        : paging_unit.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Two-level paging with PTE/PDE attribute checks and #PF
// ============================================================================

`include "openx86_defs.h.sv"

module paging_unit (
    input  logic         i_valid,
    output logic         o_ready,
    input  logic [31: 0] i_linear_address,
    input  logic [31: 0] i_page_directory_base,
    input  logic [ 1: 0] i_cpl,
    input  logic         i_is_write,
    output logic [31: 0] o_physical_address,
    output logic         o_page_fault,
    output logic         o_fault_present,
    output logic [31: 0] o_fault_linear_address,
    output logic         o_bus_valid,
    input  logic         i_bus_ready,
    output logic         o_bus_write_enable,
    output logic [31: 0] o_bus_address,
    input  logic [31: 0] i_bus_data_read,
    output logic [31: 0] o_bus_data_write,
    input  logic          clk,
    input  logic          rst_n
);
    logic  [ 9: 0] page_directory_index;
    logic  [ 9: 0] page_table_index;
    logic  [11: 0] page_frame_offset;
    logic  [31: 0] page_directory_offset;
    logic  [31: 0] latched_linear_address;
    assign page_directory_index  = latched_linear_address[31: 22];
    assign page_table_index      = latched_linear_address[21: 12];
    assign page_frame_offset     = latched_linear_address[11: 0];
    assign page_directory_offset = i_page_directory_base + (32'(page_directory_index) << 2);
    function automatic logic [31: 0] frame_base(input logic [31: 0] entry);
        return {entry[31: 12], 12'h0};
    endfunction
    function automatic logic pte_protection_fault(
        input logic [31: 0] entry,
        input logic         is_write,
        input logic [ 1: 0] cpl
    );
        if (is_write && ~entry[`PTE_BIT_RW]) begin
            return 1'b1;
        end
        if ((cpl == 2'b11) && ~entry[`PTE_BIT_US]) begin
            return 1'b1;
        end
        return 1'b0;
    endfunction
    typedef enum logic [ 1: 0] {
        STATE_IDLE,
        STATE_READ_PDE,
        STATE_READ_PTE
    } paging_state_e;
    paging_state_e state;
    logic [31: 0] pte_entry_r;
    logic [31: 0] pte_read_addr_r;
    logic         pte_addr_armed_r;
    logic         fault_r;
    logic         fault_present_r;
    logic         i_valid_r;
    logic         i_valid_rise;
    logic [ 1: 0] latched_cpl;
    logic         latched_is_write;
    assign i_valid_rise = i_valid & ~i_valid_r;
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            i_valid_r <= 1'b0;
        end else begin
            i_valid_r <= i_valid;
        end
    end
    always_comb begin
        o_physical_address     = frame_base(pte_entry_r) + 32'(page_frame_offset);
        o_fault_linear_address = latched_linear_address;
        o_page_fault           = fault_r;
        o_fault_present        = fault_present_r;
        o_bus_write_enable     = 1'b0;
        o_bus_data_write       = '0;
        unique case (state)
            STATE_READ_PDE: begin
                o_bus_valid   = 1'b1;
                o_bus_address = page_directory_offset;
            end
            STATE_READ_PTE: begin
                o_bus_valid   = pte_addr_armed_r;
                o_bus_address = pte_read_addr_r;
            end
            default: begin
                o_bus_valid   = 1'b0;
                o_bus_address = 32'h0;
            end
        endcase
    end
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state                  <= STATE_IDLE;
            o_ready                <= 1'b0;
            pte_entry_r            <= 32'h0;
            pte_read_addr_r        <= 32'h0;
            pte_addr_armed_r       <= 1'b0;
            latched_linear_address <= 32'h0;
            latched_cpl            <= 2'b00;
            latched_is_write       <= 1'b0;
            fault_r                <= 1'b0;
            fault_present_r        <= 1'b0;
        end else begin
            o_ready <= 1'b0;
            unique case (state)
                STATE_IDLE: begin
                    if (i_valid_rise) begin
                        fault_r                <= 1'b0;
                        fault_present_r        <= 1'b0;
                        latched_linear_address <= i_linear_address;
                        latched_cpl            <= i_cpl;
                        latched_is_write       <= i_is_write;
                        pte_addr_armed_r       <= 1'b0;
                        state                  <= STATE_READ_PDE;
                    end
                end
                STATE_READ_PDE: begin
                    if (i_bus_ready) begin
                        if (~i_bus_data_read[`PTE_BIT_P]) begin
                            state           <= STATE_IDLE;
                            o_ready         <= 1'b1;
                            fault_r         <= 1'b1;
                            fault_present_r <= 1'b0;
                        end else begin
                            pte_read_addr_r <= frame_base(i_bus_data_read) +
                                (32'(latched_linear_address[21: 12]) << 2);
                            pte_addr_armed_r <= 1'b0;
                            state            <= STATE_READ_PTE;
                        end
                    end
                end
                STATE_READ_PTE: begin
                    if (~pte_addr_armed_r) begin
                        pte_addr_armed_r <= 1'b1;
                    end else if (i_bus_ready) begin
                        state       <= STATE_IDLE;
                        o_ready     <= 1'b1;
                        pte_entry_r <= i_bus_data_read;
                        if (~i_bus_data_read[`PTE_BIT_P]) begin
                            fault_r         <= 1'b1;
                            fault_present_r <= 1'b0;
                        end else if (pte_protection_fault(
                            i_bus_data_read, latched_is_write, latched_cpl
                        )) begin
                            fault_r         <= 1'b1;
                            fault_present_r <= 1'b1;
                        end else begin
                            fault_r         <= 1'b0;
                            fault_present_r <= 1'b0;
                        end
                    end
                end
                default: state <= STATE_IDLE;
            endcase
        end
    end
endmodule
