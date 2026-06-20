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
//  File        : stage_1_ifu.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_1_ifu module
// ============================================================================

`include "openx86_defs.h.sv"

module stage_1_ifu (
    // =========================
    // instruction fetch bus interface
    // =========================
    output logic                 o_code_valid,
    input  logic                 i_code_ready,
    output logic [31: 0]        o_code_address,
    input  logic [31: 0]        i_code_data_read,

    // =========================
    // MMU backend bus interface
    // =========================
    output logic                 o_mmu_bus_valid,
    input  logic                 i_mmu_bus_ready,
    output logic [31: 0]        o_mmu_bus_addr,
    input  logic [31: 0]        i_mmu_bus_rdata,

    // =========================
    // CPU execution context
    // =========================
    input  logic                 i_protected_mode,
    input  logic [ 5: 0][15: 0] i_segment_selector,
    input  logic [ 5: 0][63: 0] i_segment_descriptor,
    input  logic [ 1: 0]        i_current_privilege_level,
    input  logic                 i_paging_enable,
    input  logic [31: 0]        i_page_directory_base,

    // =========================
    // IFU control
    // =========================
    input  logic                 i_start,
    input  logic [31: 0]        i_initial_eip,
    input  logic                 i_reload_eip,
    input  logic [31: 0]        i_reload_eip_value,

    // =========================
    // IFU to DEC handshake
    // =========================
    output logic [15: 0][ 7: 0] o_instruction,
    output logic                 o_instruction_valid,
    output logic                 o_segment_fault,
    output logic                 o_page_fault,
    output logic [31: 0]        o_fault_linear_address,
    output logic [ 4: 0]        o_fifo_count,
    output logic [31: 0]        o_eip,
    input  logic                 i_dec_ready,
    input  logic                 i_dec_fire,
    input  logic [ 3: 0]        i_dec_consume_bytes,
    input  logic                 i_dec_error,

    // =========================
    // clock and reset
    // =========================
    input  logic                 clk,
    input  logic                 rst_n
);

    // ============================================================
    // IFU state registers
    // ============================================================
    logic [31: 0] eip_r;
    logic         started_r;
    logic         fetch_active_r;
    logic         fetch_code_phase;
    logic [ 1: 0] fetch_word_idx_r;
    logic         fetch_instruction_ready_r;
    logic         segment_fault_r;
    logic         page_fault_r;
    logic [31: 0] fault_linear_r;

    // ============================================================
    // fetch control signals
    // ============================================================
    logic         fetch_request;

    logic [15: 0][ 7: 0] fetch_instruction;
    logic                fetch_instruction_ready;
    logic                fetch_segment_fault;

    // ============================================================
    // FIFO signals
    // ============================================================
    logic [15: 0][ 7: 0] fifo_window;
    logic [ 4: 0]        fifo_count;
    logic                fifo_push_ready;
    logic                fifo_pop_ready;
    logic                fifo_full;
    logic                fifo_empty;

    // ============================================================
    // decode interface signals
    // ============================================================
    logic                ifu_valid;
    logic [ 4: 0]        dec_consume_bytes_ext;

    // ============================================================
    // MMU request gating and signals
    // ============================================================
    logic         mmu_req_valid;
    logic         mmu_req_ready;
    logic         mmu_bus_we;
    logic [31: 0] mmu_bus_wdata;
    logic         mmu_seg_fault;
    logic         mmu_page_fault;
    logic         mmu_fault_present;
    logic [31: 0] mmu_fault_linear;
    logic [31: 0] mmu_phys_addr;
    logic         fetch_need_mmu;
    logic [31: 0] fetch_linear_addr;

    assign fetch_linear_addr = eip_r + {28'h0, fetch_word_idx_r, 2'b00};
    assign fetch_need_mmu    = fetch_active_r & ~fetch_code_phase;
    assign mmu_req_valid     = fetch_need_mmu;

    memory_management_unit #(
        .read_from_fetch (1'b1)
    ) u_ifu_mmu (
        .i_valid                 (mmu_req_valid),
        .o_ready                 (mmu_req_ready),
        .i_protected_mode        (i_protected_mode),
        .i_segment_selector      (i_segment_selector),
        .i_segment_descriptor    (i_segment_descriptor),
        .i_current_privilege_level (i_current_privilege_level),
        .i_segment_index         (`sreg_index_CS),
        .i_effective_address     (fetch_linear_addr),
        .i_write_enable          (1'b0),
        .i_paging_enable         (i_paging_enable),
        .i_page_directory_base   (i_page_directory_base),
        .o_physical_address      (mmu_phys_addr),
        .o_segment_fault         (mmu_seg_fault),
        .o_page_fault            (mmu_page_fault),
        .o_fault_present         (mmu_fault_present),
        .o_fault_linear_address  (mmu_fault_linear),
        .o_bus_valid             (o_mmu_bus_valid),
        .i_bus_ready             (i_mmu_bus_ready),
        .o_bus_write_enable      (mmu_bus_we),
        .o_bus_address           (o_mmu_bus_addr),
        .i_bus_data_read         (i_mmu_bus_rdata),
        .o_bus_data_write        (mmu_bus_wdata),
        .clk                     (clk),
        .rst_n                   (rst_n)
    );

    // ============================================================
    // fetch control assignments
    // ============================================================
    assign fetch_request           = started_r & i_start & ~fetch_active_r & fifo_empty;
    assign fetch_instruction_ready = fetch_instruction_ready_r;
    assign fetch_segment_fault     = mmu_seg_fault;

    assign o_code_valid            = fetch_active_r & fetch_code_phase;
    assign o_code_address          = mmu_phys_addr;

    // ============================================================
    // decode interface assignments
    // ============================================================
    assign dec_consume_bytes_ext = {1'b0, i_dec_consume_bytes};
    assign ifu_valid             =
        ~fifo_empty &
        (dec_consume_bytes_ext != 5'd0) &
        (dec_consume_bytes_ext <= fifo_count);

    assign o_instruction       = fifo_window;
    assign o_instruction_valid = ifu_valid;
    assign o_segment_fault         = segment_fault_r;
    assign o_page_fault            = page_fault_r;
    assign o_fault_linear_address  = fault_linear_r;
    assign o_fifo_count        = fifo_count;
    assign o_eip               = eip_r;

    // 时序逻辑块：维护 EIP、取指拼包状态、16B 窗口有效脉冲。
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            eip_r                    <= 32'h0000_0000;
            started_r                <= 1'b0;
            fetch_active_r           <= 1'b0;
            fetch_code_phase         <= 1'b0;
            fetch_word_idx_r         <= 2'b00;
            fetch_instruction_ready_r <= 1'b0;
            fetch_instruction        <= '0;
            segment_fault_r          <= 1'b0;
            page_fault_r             <= 1'b0;
            fault_linear_r           <= 32'h0;
        end else if (i_reload_eip) begin
            eip_r                    <= i_reload_eip_value;
            started_r                <= 1'b1;
            fetch_active_r           <= 1'b0;
            fetch_code_phase         <= 1'b0;
            fetch_word_idx_r         <= 2'b00;
            fetch_instruction_ready_r <= 1'b0;
            segment_fault_r          <= 1'b0;
            page_fault_r             <= 1'b0;
            fault_linear_r           <= 32'h0;
        end else begin
            fetch_instruction_ready_r <= 1'b0;

            if (~started_r && i_start) begin
                eip_r     <= i_initial_eip;
                started_r <= 1'b1;
            end else if (i_dec_fire) begin
                eip_r <= eip_r + {28'h0, i_dec_consume_bytes};
            end

            if (fetch_request) begin
                fetch_active_r   <= 1'b1;
                fetch_code_phase <= 1'b0;
                fetch_word_idx_r <= 2'b00;
            end

            if (fetch_active_r) begin
                if (~fetch_code_phase) begin
                    if (mmu_req_ready) begin
                        if (mmu_seg_fault) begin
                            fetch_active_r            <= 1'b0;
                            fetch_instruction_ready_r <= 1'b0;
                            segment_fault_r           <= 1'b1;
                            fault_linear_r            <= mmu_fault_linear;
                        end else if (mmu_page_fault) begin
                            fetch_active_r            <= 1'b0;
                            fetch_instruction_ready_r <= 1'b0;
                            page_fault_r              <= 1'b1;
                            fault_linear_r            <= mmu_fault_linear;
                        end else begin
                            fetch_code_phase <= 1'b1;
                        end
                    end
                end else if (i_code_ready) begin
                    fetch_code_phase <= 1'b0;
                    unique case (fetch_word_idx_r)
                    2'd0: begin
                        fetch_instruction[0] <= i_code_data_read[31: 24];
                        fetch_instruction[1] <= i_code_data_read[23: 16];
                        fetch_instruction[2] <= i_code_data_read[15: 8];
                        fetch_instruction[3] <= i_code_data_read[ 7: 0];
                    end
                    2'd1: begin
                        fetch_instruction[4] <= i_code_data_read[31: 24];
                        fetch_instruction[5] <= i_code_data_read[23: 16];
                        fetch_instruction[6] <= i_code_data_read[15: 8];
                        fetch_instruction[7] <= i_code_data_read[ 7: 0];
                    end
                    2'd2: begin
                        fetch_instruction[8]  <= i_code_data_read[31: 24];
                        fetch_instruction[9]  <= i_code_data_read[23: 16];
                        fetch_instruction[10] <= i_code_data_read[15: 8];
                        fetch_instruction[11] <= i_code_data_read[ 7: 0];
                    end
                    default: begin
                        fetch_instruction[12] <= i_code_data_read[31: 24];
                        fetch_instruction[13] <= i_code_data_read[23: 16];
                        fetch_instruction[14] <= i_code_data_read[15: 8];
                        fetch_instruction[15] <= i_code_data_read[ 7: 0];
                    end
                endcase

                if (fetch_word_idx_r == 2'd3) begin
                    fetch_active_r            <= 1'b0;
                    fetch_instruction_ready_r <= 1'b1;
                    segment_fault_r           <= 1'b0;
                    page_fault_r              <= 1'b0;
                end else begin
                    fetch_word_idx_r <= fetch_word_idx_r + 2'd1;
                end
            end
            end
        end
    end

    stage_1_ifu_fifo #(
        .P_DEPTH      (16),
        .P_DATA_WIDTH (8)
    ) u_stage_1_ifu_fifo (
        .i_push_valid  (fetch_instruction_ready),
        .i_push_data   (fetch_instruction),
        .i_push_bytes  (5'd16),
        .o_push_ready  (fifo_push_ready),
        .i_pop_valid   (i_dec_fire),
        .i_pop_bytes   (dec_consume_bytes_ext),
        .o_pop_ready   (fifo_pop_ready),
        .o_window_data (fifo_window),
        .o_count       (fifo_count),
        .o_full        (fifo_full),
        .o_empty       (fifo_empty),
        .clk           (clk),
        .rst_n         (rst_n)
    );

    // Keep lint clean for currently unused status/context wires.
    /* verilator lint_off UNUSEDSIGNAL */
    logic unused_ifu;
    assign unused_ifu =
        fifo_push_ready ^ fifo_pop_ready ^ fifo_full ^ i_dec_ready ^ i_dec_error ^
        mmu_bus_we ^ mmu_bus_wdata[0] ^ mmu_fault_present;
    /* verilator lint_on UNUSEDSIGNAL */

endmodule

module stage_1_ifu_fifo #(
    parameter int P_DEPTH      = 16,
    parameter int P_DATA_WIDTH = 8
) (
    input  logic                                        i_push_valid,
    input  logic [P_DEPTH - 1: 0][P_DATA_WIDTH - 1: 0] i_push_data,
    input  logic [$clog2(P_DEPTH + 1) - 1: 0]          i_push_bytes,
    output logic                                        o_push_ready,

    input  logic                                        i_pop_valid,
    input  logic [$clog2(P_DEPTH + 1) - 1: 0]          i_pop_bytes,
    output logic                                        o_pop_ready,

    output logic [P_DEPTH - 1: 0][P_DATA_WIDTH - 1: 0] o_window_data,
    output logic [$clog2(P_DEPTH + 1) - 1: 0]          o_count,
    output logic                                        o_full,
    output logic                                        o_empty,

    input  logic                                        clk, // 时钟信号
    input  logic                                        rst_n // 复位信号
);

    localparam int LP_ADDR_WIDTH  = $clog2(P_DEPTH);
    localparam int LP_COUNT_WIDTH = $clog2(P_DEPTH + 1);

    localparam logic [LP_COUNT_WIDTH - 1: 0] LP_DEPTH_W = LP_COUNT_WIDTH'(P_DEPTH);

    logic [P_DATA_WIDTH - 1: 0] fifo_mem [0: P_DEPTH - 1];
    logic [LP_ADDR_WIDTH - 1: 0] head_ptr;
    logic [LP_ADDR_WIDTH - 1: 0] tail_ptr;
    logic [LP_COUNT_WIDTH - 1: 0] count;

    logic [LP_COUNT_WIDTH - 1: 0] free_count;
    logic                         do_push;
    logic                         do_pop;

    function automatic logic [LP_ADDR_WIDTH - 1: 0] f_wrap_index (
        input logic [LP_ADDR_WIDTH - 1: 0]  i_base,
        input logic [LP_COUNT_WIDTH - 1: 0] i_offset
    );
        logic [LP_COUNT_WIDTH: 0] sum;
        logic [LP_COUNT_WIDTH: 0] sum_sub;
        begin
            sum = {1'b0, i_base} + {1'b0, i_offset};
            if (sum >= {1'b0, LP_DEPTH_W}) begin
                sum_sub      = sum - {1'b0, LP_DEPTH_W};
                f_wrap_index = sum_sub[LP_ADDR_WIDTH - 1: 0];
            end else begin
                f_wrap_index = sum[LP_ADDR_WIDTH - 1: 0];
            end
        end
    endfunction

    assign free_count   = LP_DEPTH_W - count;
    assign o_push_ready = (i_push_bytes <= free_count);
    assign o_pop_ready  = (i_pop_bytes != LP_COUNT_WIDTH'(0)) & (i_pop_bytes <= count);

    assign do_push = i_push_valid & o_push_ready & (i_push_bytes != LP_COUNT_WIDTH'(0));
    assign do_pop  = i_pop_valid & o_pop_ready;

    assign o_count = count;
    assign o_empty = (count == LP_COUNT_WIDTH'(0));
    assign o_full  = (count == LP_DEPTH_W);

    // 组合逻辑块：输出从 head 开始的前视窗口。
    always_comb begin
        for (int i = 0; i < P_DEPTH; i++) begin
            if (LP_COUNT_WIDTH'(i) < count) begin
                o_window_data[i] = fifo_mem[f_wrap_index(head_ptr, LP_COUNT_WIDTH'(i))];
            end else begin
                o_window_data[i] = '0;
            end
        end
    end

    // 时序逻辑块：按 push/pop 握手更新环形指针与计数。
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            head_ptr <= '0;
            tail_ptr <= '0;
            count    <= '0;
        end else begin
            if (do_push) begin
                for (int i = 0; i < P_DEPTH; i++) begin
                    if (LP_COUNT_WIDTH'(i) < i_push_bytes) begin
                        fifo_mem[f_wrap_index(tail_ptr, LP_COUNT_WIDTH'(i))] <= i_push_data[i];
                    end
                end
                tail_ptr <= f_wrap_index(tail_ptr, i_push_bytes);
            end

            if (do_pop) begin
                head_ptr <= f_wrap_index(head_ptr, i_pop_bytes);
            end

            unique case ({do_push, do_pop})
                2'b10: count <= count + i_push_bytes;
                2'b01: count <= count - i_pop_bytes;
                2'b11: count <= count + i_push_bytes - i_pop_bytes;
                default: begin
                end
            endcase
        end
    end

endmodule
