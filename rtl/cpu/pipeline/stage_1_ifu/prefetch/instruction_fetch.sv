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
//  File        : instruction_fetch.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : instruction_fetch module
// ============================================================================

`include "openx86_defs.h.sv"
module instruction_fetch (
    // =========================
    // instruction fetch bus (to BIU/memory subsystem)
    // =========================
    output logic         o_code_valid,
    input  logic          i_code_ready,
    output logic [31: 0] o_code_address,
    input  logic [31: 0] i_code_data_read,

    // =========================
    // MMU page table walk bus (higher priority than normal code/data)
    // =========================
    output logic         o_mmu_bus_valid,
    input  logic          i_mmu_bus_ready,
    output logic [31: 0] o_mmu_bus_addr,
    input  logic [31: 0] i_mmu_bus_rdata,

    // =========================
    // segment/paging context (from CPU register side)
    // =========================
    input  logic          i_protected_mode,
    input  logic [ 5: 0][15: 0] i_segment_selector,
    input  logic [ 5: 0][63: 0] i_segment_descriptor,
    input  logic [ 1: 0]        i_current_privilege_level,
    input  logic                 i_paging_enable,
    input  logic [31: 0]        i_page_directory_base,

    // =========================
    // execution unit: fetch next batch after IP update completes
    // =========================
    input  logic                 i_IP_valid,

    // =========================
    // output to decode: 16B instruction buffer
    // =========================
    output logic [15: 0][ 7: 0] o_instruction,
    output logic                 o_instruction_ready,
    output logic                 o_segment_fault,

    // =========================
    // instruction pointer
    // =========================
    input  logic [31: 0]        i_eip,

    // =========================
    // clock and reset
    // =========================
    input  logic                 clk,
    input  logic                 rst_n
);

    // ============================================================
    // MMU request gating and signals
    // ============================================================
    logic        mmu_valid;
    logic        mmu_ready;
    logic        mmu_bus_we;
    logic [31: 0] mmu_bus_wdata;
    logic        seg_fault;

    assign mmu_valid = i_IP_valid;

    // ============================================================
    // segment translation: compute physical fetch address when IP valid
    // ============================================================

memory_management_unit #(
    .read_from_fetch (1'b1)
) instruction_fetch_memory_management_unit (
    .i_valid             (mmu_valid),
    .o_ready             (mmu_ready),
    .i_protected_mode    (i_protected_mode),
    .i_segment_selector  (i_segment_selector),
    .i_segment_descriptor(i_segment_descriptor),
    .i_current_privilege_level (i_current_privilege_level),
    .i_segment_index     (`sreg_index_CS),
    .i_effective_address (i_eip),
    .i_write_enable      (1'b0),
    .i_paging_enable     (i_paging_enable),
    .i_page_directory_base (i_page_directory_base),
    .o_physical_address  (o_code_address),
    .o_segment_fault     (seg_fault),
    .o_bus_valid         (o_mmu_bus_valid),
    .i_bus_ready         (i_mmu_bus_ready),
    .o_bus_write_enable  (mmu_bus_we),
    .o_bus_address       (o_mmu_bus_addr),
    .i_bus_data_read     (i_mmu_bus_rdata),
    .o_bus_data_write    (mmu_bus_wdata),
    .clk                 (clk),
    .rst_n               (rst_n)
);

    assign o_segment_fault = seg_fault;

    // ============================================================
    // fetch small state machine: wait for EIP valid → fetch 4×32b and assemble 16B → wait for IP again
    // ============================================================
    enum logic {
        STATE_WAIT_FOR_CODE_DATA_READY = 1'h1,
        STATE_WAIT_FOR_IP_VALID = 1'h0
    } state;

    // ============================================================
    // state transition: complete 4×32b reads with bytes_index
    // ============================================================
    always_ff @(posedge clk or negedge rst_n) begin : ff_fetch_state
    if (~rst_n) begin
        state <= STATE_WAIT_FOR_IP_VALID;
    end else begin
        unique case (state)
            STATE_WAIT_FOR_IP_VALID: begin
                if (i_IP_valid) begin
                    state <= STATE_WAIT_FOR_CODE_DATA_READY;
                end else begin
                    state <= STATE_WAIT_FOR_IP_VALID;
                end
            end
            STATE_WAIT_FOR_CODE_DATA_READY: begin
                if (i_code_ready && (bytes_index == 2'h3)) begin
                    state <= STATE_WAIT_FOR_IP_VALID;
                end else begin
                    state <= STATE_WAIT_FOR_CODE_DATA_READY;
                end
            end
            default: begin
                state <= STATE_WAIT_FOR_IP_VALID;
            end
        endcase
    end
end

logic [ 1: 0] bytes_index; // 当前正在接收第几个 32b 槽（0..3）

// 输出握手与缓冲装载：按槽把 big-endian 32b 拆入 o_instruction
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        o_code_valid <= 1'b0;
        bytes_index <= 2'b00;
    end else begin
        unique case (state)
            STATE_WAIT_FOR_IP_VALID: begin
                bytes_index  <= 2'b00;
                if (i_IP_valid) begin
                    o_code_valid <= 1;
                end else begin
                    o_code_valid <= 1'b0;
                end
            end
            STATE_WAIT_FOR_CODE_DATA_READY: begin
                if (i_code_ready) begin
                    bytes_index <= bytes_index + 2'd1;
                    if (bytes_index < 2'h3) begin
                        // 每个 i_code_ready 周期写入一个 32b 小端槽到 16B 缓冲
                        unique case (bytes_index)
                            2'h0: begin
                                o_instruction[0] <= i_code_data_read[31: 24];
                                o_instruction[1] <= i_code_data_read[23: 16];
                                o_instruction[2] <= i_code_data_read[15: 8];
                                o_instruction[3] <= i_code_data_read[ 7: 0];
                            end
                            2'h1: begin
                                o_instruction[4] <= i_code_data_read[31: 24];
                                o_instruction[5] <= i_code_data_read[23: 16];
                                o_instruction[6] <= i_code_data_read[15: 8];
                                o_instruction[7] <= i_code_data_read[ 7: 0];
                            end
                            2'h2: begin
                                o_instruction[ 8] <= i_code_data_read[31: 24];
                                o_instruction[ 9] <= i_code_data_read[23: 16];
                                o_instruction[10] <= i_code_data_read[15: 8];
                                o_instruction[11] <= i_code_data_read[ 7: 0];
                            end
                            2'h3: begin
                                o_instruction[12] <= i_code_data_read[31: 24];
                                o_instruction[13] <= i_code_data_read[23: 16];
                                o_instruction[14] <= i_code_data_read[15: 8];
                                o_instruction[15] <= i_code_data_read[ 7: 0];
                            end
                        endcase
                        // o_instruction[bytes_index*4:bytes_index*4+3] <= '{
                        //     i_code_data_read[31: 24],
                        //     i_code_data_read[23: 16],
                        //     i_code_data_read[15: 8],
                        //     i_code_data_read[ 7: 0]
                        // };
                        o_instruction_ready <= 1'b0;
                    end else begin
                        o_instruction_ready <= 1;
                    end
                end else begin
                    o_instruction_ready <= 1'b0;
                end
            end
            default: begin
            end
        endcase
    end
end

endmodule
