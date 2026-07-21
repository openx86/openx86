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
//  File        : i486_cache_unit.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : 80486-style 8KB unified write-through cache (4-way, 32B line)
// ============================================================================

module i486_cache_unit (
    // =========================
    // CPU-side CODE port
    // =========================
    input  logic         i_code_valid,
    output logic         o_code_ready,
    input  logic [31: 0] i_code_address,
    output logic [31: 0] o_code_data,
    // =========================
    // CPU-side DATA port
    // =========================
    input  logic         i_data_valid,
    output logic         o_data_ready,
    input  logic         i_data_write_enable,
    input  logic         i_data_io_access,
    input  logic [ 1: 0] i_data_size,
    input  logic [31: 0] i_data_address,
    input  logic [31: 0] i_data_wdata,
    output logic [31: 0] o_data_rdata,
    // =========================
    // Downstream BIU (single beat)
    // =========================
    output logic         o_mem_valid,
    input  logic         i_mem_ready,
    output logic         o_mem_write,
    output logic         o_mem_io,
    output logic         o_mem_code,
    output logic [ 1: 0] o_mem_size,
    output logic [31: 0] o_mem_address,
    output logic [31: 0] o_mem_wdata,
    input  logic [31: 0] i_mem_rdata,
    // =========================
    // Cache maintenance
    // =========================
    input  logic         i_invalidate_all,
    input  logic         i_wbinvd,
    input  logic         clk,
    input  logic         rst_n
);

    localparam int LP_LINE_BYTES  = 32;
    localparam int LP_NUM_SETS    = 64;
    localparam int LP_NUM_WAYS    = 4;
    localparam int LP_INDEX_BITS  = 6;
    localparam int LP_OFFSET_BITS = 5;
    localparam int LP_TAG_BITS    = 32 - LP_INDEX_BITS - LP_OFFSET_BITS;

    logic [LP_NUM_SETS - 1: 0][LP_NUM_WAYS - 1: 0][LP_TAG_BITS - 1: 0] tag_mem;
    logic [LP_NUM_SETS - 1: 0][LP_NUM_WAYS - 1: 0]                      valid_mem;
    logic [LP_NUM_SETS - 1: 0][LP_NUM_WAYS - 1: 0][LP_LINE_BYTES * 8 - 1: 0] data_mem;
    logic [1: 0] lru_ptr [LP_NUM_SETS - 1: 0];

    logic                           code_hit;
    logic [ 1: 0]                   code_hit_way;
    logic [31: 0]                   code_hit_data;
    logic                           data_hit;
    logic [ 1: 0]                   data_hit_way;
    logic [31: 0]                   data_hit_data;
    logic [LP_INDEX_BITS - 1: 0]    code_index;
    logic [LP_OFFSET_BITS - 1: 0]   code_offset;
    logic [LP_TAG_BITS - 1: 0]      code_tag;
    logic [LP_INDEX_BITS - 1: 0]    data_index;
    logic [LP_OFFSET_BITS - 1: 0]   data_offset;
    logic [LP_TAG_BITS - 1: 0]      data_tag;

    typedef enum logic [ 2: 0] {
        S_IDLE,
        S_FILL_WAIT,
        S_FILL_GAP,
        S_RESP,
        S_WR_SPAN2
    } cache_state_e;

    cache_state_e state;
    logic [ 1: 0] fill_way;
    logic [ 4: 0] fill_beat;
    logic [31: 0] fill_base_addr;
    logic [LP_INDEX_BITS - 1: 0] fill_index;
    logic [LP_TAG_BITS - 1: 0]   fill_tag;
    logic         pending_code;
    logic         pending_data;
    logic         pending_write;
    logic [31: 0] pending_addr;
    logic [ 1: 0] pending_size;
    logic [31: 0] pending_wdata;
    logic [31: 0] span2_pend_addr;
    logic [31: 0] span2_pend_wdata;
    logic         code_hit_accept_r;
    logic [ 1: 0] fill_gap_r;
    logic [31: 0] fill_resp_data;
    logic         fill_resp_active;
    logic [31: 0] io_rdata_r;
    logic         io_rdata_valid_r;
    logic         io_req_accept_r;
    logic         mem_ready_q;
    logic         mem_ready_rise;

    function automatic logic [31: 0] f_extract_word (
        input logic [LP_LINE_BYTES * 8 - 1: 0] line_data,
        input logic [LP_OFFSET_BITS - 1: 0]    byte_off
    );
        logic [ 4: 0] word_idx;
        word_idx = byte_off[LP_OFFSET_BITS - 1: 2];
        return line_data[word_idx * 32 +: 32];
    endfunction

    // Size-aware extract into low bits (handles odd halfword / unaligned dword
    // within a cache line — e.g. FreeDOS BPB bytes/sector at 7C0B).
    function automatic logic [31: 0] f_extract_sized (
        input logic [LP_LINE_BYTES * 8 - 1: 0] line_data,
        input logic [LP_OFFSET_BITS - 1: 0]    byte_off,
        input logic [ 1: 0]                   size
    );
        logic [LP_LINE_BYTES * 8 - 1: 0] shifted;
        shifted = line_data >> (byte_off * 8);
        unique case (size)
            2'b00:   return {24'h0, shifted[ 7: 0]};
            2'b01:   return {16'h0, shifted[15: 0]};
            default: return shifted[31: 0];
        endcase
    endfunction

    function automatic logic [31: 0] f_be_mask (
        input logic [ 1: 0] size,
        input logic [ 1: 0] byte_lane
    );
        logic [ 3: 0] be_n;
        unique case (size)
            2'b00: unique case (byte_lane)
                2'b00:   be_n = 4'b1110;
                2'b01:   be_n = 4'b1101;
                2'b10:   be_n = 4'b1011;
                default: be_n = 4'b0111;
            endcase
            2'b01: unique case (byte_lane)
                2'b00:   be_n = 4'b1100;
                2'b01:   be_n = 4'b1001;
                2'b10:   be_n = 4'b0011;
                default: be_n = 4'b0111;
            endcase
            // Dword: aligned = all bytes; half-aligned (&2) = high half only
            // (low half of the store lands in the next dword — see span2_*).
            default: unique case (byte_lane)
                2'b00:   be_n = 4'b0000;
                2'b10:   be_n = 4'b0011;
                default: be_n = 4'b0000;
            endcase
        endcase
        return {{8{~be_n[3]}}, {8{~be_n[2]}}, {8{~be_n[1]}}, {8{~be_n[0]}}};
    endfunction

    function automatic logic [31: 0] f_lane_wdata (
        input logic [31: 0] data,
        input logic [ 1: 0] size,
        input logic [ 1: 0] byte_lane
    );
        unique case (size)
            2'b00:   return {24'h0, data[7: 0]} << (byte_lane * 8);
            2'b01:   return {16'h0, data[15: 0]} << (byte_lane * 8);
            // Half-aligned dword: low 16 bits go into lanes [31:16] of this word.
            default: begin
                if (byte_lane == 2'b10)
                    return {data[15: 0], 16'h0};
                else
                    return data;
            end
        endcase
    endfunction

    // SeaBIOS irqentry: pushl after a 6-byte INT frame leaves ESP[1:0]==2.
    // A dword store then spans two aligned words — merge both in-cache and
    // write-through as two halfword BIU beats (BE already correct for &2 / &0).
    logic         span2_dword;
    logic [31: 0] span2_addr;
    logic [31: 0] span2_mask;
    logic [31: 0] span2_wdata;
    logic [31: 0] span2_old_word;
    logic [ 4: 0] span2_word_idx;
    assign span2_dword = (i_data_size == 2'b10) && (i_data_address[1: 0] == 2'b10);
    assign span2_addr  = {i_data_address[31: 2], 2'b00} + 32'd4;
    assign span2_mask  = 32'h0000_FFFF;
    assign span2_wdata = {16'h0, i_data_wdata[31: 16]};
    assign span2_word_idx = span2_addr[LP_OFFSET_BITS - 1: 2];
    assign span2_old_word = data_hit ?
                            data_mem[data_index][data_hit_way][span2_word_idx * 32 +: 32] :
                            32'h0;

    logic [31: 0] hit_write_mask;
    logic [31: 0] hit_write_data;
    logic [31: 0] hit_old_word;
    assign hit_write_mask = f_be_mask(i_data_size, i_data_address[1: 0]);
    assign hit_write_data = f_lane_wdata(i_data_wdata, i_data_size, i_data_address[1: 0]);
    assign hit_old_word   = data_hit ?
                            f_extract_word(data_mem[data_index][data_hit_way], data_offset) :
                            32'h0;
    always_comb begin
        code_index  = i_code_address[LP_INDEX_BITS + LP_OFFSET_BITS - 1: LP_OFFSET_BITS];
        code_offset = i_code_address[LP_OFFSET_BITS - 1: 0];
        code_tag    = i_code_address[31: LP_INDEX_BITS + LP_OFFSET_BITS];
        data_index  = i_data_address[LP_INDEX_BITS + LP_OFFSET_BITS - 1: LP_OFFSET_BITS];
        data_offset = i_data_address[LP_OFFSET_BITS - 1: 0];
        data_tag    = i_data_address[31: LP_INDEX_BITS + LP_OFFSET_BITS];
        code_hit      = 1'b0;
        code_hit_way  = 2'b00;
        code_hit_data = 32'h0;
        for (int w = 0; w < LP_NUM_WAYS; w++) begin
            if (valid_mem[code_index][w] & (tag_mem[code_index][w] == code_tag)) begin
                code_hit      = 1'b1;
                code_hit_way  = w[1: 0];
                code_hit_data = f_extract_word(data_mem[code_index][w], code_offset);
            end
        end
        data_hit      = 1'b0;
        data_hit_way  = 2'b00;
        data_hit_data = 32'h0;
        for (int w = 0; w < LP_NUM_WAYS; w++) begin
            if (valid_mem[data_index][w] & (tag_mem[data_index][w] == data_tag)) begin
                data_hit      = 1'b1;
                data_hit_way  = w[1: 0];
                // Size-aware extract only when the operand is not dword-aligned
                // in a way f_extract_word + EXU lane-select cannot recover:
                //  - halfword with EA[1:0]==11 (spans two dwords)
                //  - dword with EA[1:0]!=00 (e.g. LES far ptr at BP+0x5A)
                // Aligned hits keep returning the containing dword for EXU lanes.
                if (~i_data_write_enable &&
                    (((i_data_size == 2'b01) && (i_data_address[1: 0] == 2'b11)) ||
                     ((i_data_size == 2'b10) && (i_data_address[1: 0] != 2'b00))))
                    data_hit_data = f_extract_sized(
                        data_mem[data_index][w], data_offset, i_data_size);
                else
                    data_hit_data = f_extract_word(data_mem[data_index][w], data_offset);
            end
        end
    end

    // Post-fill response must use pending_addr — live IFU/EXU addresses can change.
    // IO responses forward BIU rdata (never the hit mux, which would be 0).
    assign fill_resp_active = (state == S_RESP) & ~o_mem_valid;
    assign fill_resp_data   =
        ((!pending_code) &&
         (((pending_size == 2'b01) && (pending_addr[1: 0] == 2'b11)) ||
          ((pending_size == 2'b10) && (pending_addr[1: 0] != 2'b00)))) ?
        f_extract_sized(
            data_mem[fill_index][fill_way],
            pending_addr[LP_OFFSET_BITS - 1: 0],
            pending_size
        ) :
        f_extract_word(
            data_mem[fill_index][fill_way],
            pending_addr[LP_OFFSET_BITS - 1: 0]
        );
    assign o_code_data  = (fill_resp_active & pending_code) ? fill_resp_data : code_hit_data;
    assign o_data_rdata = (state == S_RESP && o_mem_valid) ? i_mem_rdata :
                          io_rdata_valid_r ? io_rdata_r :
                          (fill_resp_active & pending_data) ? fill_resp_data : data_hit_data;
    // BIU ready is a 1-cycle pulse; sample on rise so a leftover level from the
    // previous beat cannot corrupt fill beat0.
    assign mem_ready_rise = i_mem_ready & ~mem_ready_q;

    always_ff @(posedge clk or negedge rst_n) begin : ff_cache_ctrl
        integer s, w;
        if (~rst_n) begin
            state             <= S_IDLE;
            o_code_ready      <= 1'b0;
            o_data_ready      <= 1'b0;
            o_mem_valid       <= 1'b0;
            o_mem_write       <= 1'b0;
            o_mem_io          <= 1'b0;
            o_mem_code        <= 1'b0;
            o_mem_address     <= 32'h0;
            o_mem_wdata       <= 32'h0;
            o_mem_size        <= 2'b10;
            fill_beat         <= 5'd0;
            fill_way          <= 2'b00;
            fill_base_addr    <= 32'h0;
            fill_index        <= {LP_INDEX_BITS{1'b0}};
            fill_tag          <= {LP_TAG_BITS{1'b0}};
            pending_code      <= 1'b0;
            pending_data      <= 1'b0;
            pending_write     <= 1'b0;
            pending_addr      <= 32'h0;
            pending_size      <= 2'b10;
            pending_wdata     <= 32'h0;
            span2_pend_addr   <= 32'h0;
            span2_pend_wdata  <= 32'h0;
            code_hit_accept_r <= 1'b0;
            fill_gap_r        <= 2'd0;
            io_rdata_r        <= 32'h0;
            io_rdata_valid_r  <= 1'b0;
            io_req_accept_r   <= 1'b0;
            mem_ready_q       <= 1'b0;
            for (s = 0; s < LP_NUM_SETS; s = s + 1) begin
                lru_ptr[s] <= 2'b00;
                for (w = 0; w < LP_NUM_WAYS; w = w + 1) begin
                    valid_mem[s][w] <= 1'b0;
                    tag_mem[s][w]   <= {LP_TAG_BITS{1'b0}};
                end
            end
        end else begin
            o_code_ready <= 1'b0;
            o_data_ready <= 1'b0;
            mem_ready_q  <= i_mem_ready;
            if (i_invalidate_all | i_wbinvd) begin
                for (s = 0; s < LP_NUM_SETS; s = s + 1) begin
                    for (w = 0; w < LP_NUM_WAYS; w = w + 1) begin
                        valid_mem[s][w] <= 1'b0;
                    end
                end
            end
            if (~i_code_valid)
                code_hit_accept_r <= 1'b0;
            // New IO request only after master drops valid (level-held start).
            if (~i_data_valid)
                io_req_accept_r <= 1'b0;
            if (io_rdata_valid_r & o_data_ready)
                io_rdata_valid_r <= 1'b0;
            unique case (state)
                S_IDLE: begin
                    o_mem_valid <= 1'b0;
                    // Independent code/data hit checks: after code_hit_accept_r,
                    // fall through must NOT reuse code hit_data for a data load.
                    if (i_code_valid & code_hit & ~code_hit_accept_r) begin
                        o_code_ready        <= 1'b1;
                        code_hit_accept_r   <= 1'b1;
                        lru_ptr[code_index] <= code_hit_way;
                    end else if (i_data_valid & ~i_data_io_access & data_hit) begin
                        lru_ptr[data_index] <= data_hit_way;
                        if (i_data_write_enable) begin
                            // Write-through: merge into cache line and push to memory
                            data_mem[data_index][data_hit_way][data_offset[4: 2] * 32 +: 32] <=
                                (hit_old_word & ~hit_write_mask) |
                                (hit_write_data & hit_write_mask);
                            if (span2_dword) begin
                                data_mem[data_index][data_hit_way][span2_word_idx * 32 +: 32] <=
                                    (span2_old_word & ~span2_mask) |
                                    (span2_wdata & span2_mask);
                                // Beat0: low halfword at EA (addr[1:0]==2).
                                o_mem_valid     <= 1'b1;
                                o_mem_write     <= 1'b1;
                                o_mem_io        <= 1'b0;
                                o_mem_code      <= 1'b0;
                                o_mem_size      <= 2'b01;
                                o_mem_address   <= i_data_address;
                                o_mem_wdata     <= {16'h0, i_data_wdata[15: 0]};
                                span2_pend_addr <= span2_addr;
                                span2_pend_wdata<= {16'h0, i_data_wdata[31: 16]};
                                mem_ready_q     <= 1'b1;
                                state           <= S_WR_SPAN2;
                            end else begin
                                o_mem_valid     <= 1'b1;
                                o_mem_write     <= 1'b1;
                                o_mem_io        <= 1'b0;
                                o_mem_code      <= 1'b0;
                                o_mem_size      <= i_data_size;
                                o_mem_address   <= i_data_address;
                                o_mem_wdata     <= i_data_wdata;
                                mem_ready_q     <= 1'b1;
                                state           <= S_RESP;
                            end
                        end else begin
                            o_data_ready <= 1'b1;
                        end
                    end else if (i_data_valid & i_data_io_access & ~io_req_accept_r) begin
                        o_mem_valid     <= 1'b1;
                        o_mem_write     <= i_data_write_enable;
                        o_mem_io        <= 1'b1;
                        o_mem_code      <= 1'b0;
                        o_mem_size      <= i_data_size;
                        o_mem_address   <= i_data_address;
                        // IO devices sample low bytes of wdata; do not lane-shift.
                        o_mem_wdata     <= i_data_wdata;
                        io_req_accept_r <= 1'b1;
                        mem_ready_q     <= 1'b1;
                        state           <= S_RESP;
                    end else if (i_code_valid & ~code_hit) begin
                        fill_way       <= lru_ptr[code_index];
                        fill_beat      <= 5'd0;
                        fill_base_addr <= {i_code_address[31: LP_OFFSET_BITS], {LP_OFFSET_BITS{1'b0}}};
                        fill_index     <= code_index;
                        fill_tag       <= code_tag;
                        pending_code   <= 1'b1;
                        pending_data   <= 1'b0;
                        pending_write  <= 1'b0;
                        pending_addr   <= i_code_address;
                        pending_size   <= 2'b10;
                        pending_wdata  <= 32'h0;
                        o_mem_valid    <= 1'b1;
                        o_mem_write    <= 1'b0;
                        o_mem_io       <= 1'b0;
                        o_mem_code     <= 1'b1;
                        o_mem_size     <= 2'b10;
                        o_mem_address  <= {i_code_address[31: LP_OFFSET_BITS], {LP_OFFSET_BITS{1'b0}}};
                        // Suppress leftover ready-rise from the prior BIU beat.
                        mem_ready_q    <= 1'b1;
                        state          <= S_FILL_WAIT;
                    end else if (i_data_valid & ~i_data_io_access & i_data_write_enable) begin
                        // Write miss: write-through only (no allocate). Allocating a
                        // single dword and marking the line valid left sibling
                        // dwords stale (e.g. IVT[0x4C] after a store to 0x40).
                        if (span2_dword) begin
                            o_mem_valid      <= 1'b1;
                            o_mem_write      <= 1'b1;
                            o_mem_io         <= 1'b0;
                            o_mem_code       <= 1'b0;
                            o_mem_size       <= 2'b01;
                            o_mem_address    <= i_data_address;
                            o_mem_wdata      <= {16'h0, i_data_wdata[15: 0]};
                            span2_pend_addr  <= span2_addr;
                            span2_pend_wdata <= {16'h0, i_data_wdata[31: 16]};
                            mem_ready_q      <= 1'b1;
                            state            <= S_WR_SPAN2;
                        end else begin
                            o_mem_valid   <= 1'b1;
                            o_mem_write   <= 1'b1;
                            o_mem_io      <= 1'b0;
                            o_mem_code    <= 1'b0;
                            o_mem_size    <= i_data_size;
                            o_mem_address <= i_data_address;
                            o_mem_wdata   <= i_data_wdata;
                            mem_ready_q   <= 1'b1;
                            state         <= S_RESP;
                        end
                    end else if (i_data_valid & ~i_data_io_access & ~data_hit) begin
                        fill_way       <= lru_ptr[data_index];
                        fill_beat      <= 5'd0;
                        fill_base_addr <= {i_data_address[31: LP_OFFSET_BITS], {LP_OFFSET_BITS{1'b0}}};
                        fill_index     <= data_index;
                        fill_tag       <= data_tag;
                        pending_code   <= 1'b0;
                        pending_data   <= 1'b1;
                        pending_write  <= 1'b0;
                        pending_addr   <= i_data_address;
                        pending_size   <= i_data_size;
                        pending_wdata  <= 32'h0;
                        o_mem_valid    <= 1'b1;
                        o_mem_write    <= 1'b0;
                        o_mem_io       <= 1'b0;
                        o_mem_code     <= 1'b0;
                        o_mem_size     <= 2'b10;
                        o_mem_address  <= {i_data_address[31: LP_OFFSET_BITS], {LP_OFFSET_BITS{1'b0}}};
                        mem_ready_q    <= 1'b1;
                        state          <= S_FILL_WAIT;
                    end
                end
                // Hold mem_valid until a rising ready for THIS request (ignores
                // leftover ready level from the previous BIU beat / hold cycle).
                S_FILL_WAIT: begin
                    o_mem_valid <= 1'b1;
                    if (mem_ready_rise) begin
                        data_mem[fill_index][fill_way][fill_beat * 32 +: 32] <= i_mem_rdata;
                        o_mem_valid <= 1'b0;
                        if (fill_beat == 5'd7) begin
                            valid_mem[fill_index][fill_way] <= 1'b1;
                            tag_mem[fill_index][fill_way]   <= fill_tag;
                            lru_ptr[fill_index]             <= fill_way;
                            state                           <= S_RESP;
                        end else begin
                            fill_beat     <= fill_beat + 5'd1;
                            o_mem_address <= fill_base_addr + ((fill_beat + 5'd1) << 2);
                            fill_gap_r    <= 2'd0;
                            state         <= S_FILL_GAP;
                        end
                    end
                end
                S_FILL_GAP: begin
                    o_mem_valid <= 1'b0;
                    fill_gap_r  <= fill_gap_r + 2'd1;
                    if (fill_gap_r == 2'd2) begin
                        o_mem_valid <= 1'b1;
                        mem_ready_q <= 1'b1;
                        state       <= S_FILL_WAIT;
                    end
                end
                S_WR_SPAN2: begin
                    // Beat0 complete → brief gap → beat1 in S_RESP.
                    if (fill_gap_r != 2'd0) begin
                        o_mem_valid <= 1'b0;
                        fill_gap_r  <= fill_gap_r + 2'd1;
                        if (fill_gap_r == 2'd2) begin
                            o_mem_valid   <= 1'b1;
                            o_mem_write   <= 1'b1;
                            o_mem_io      <= 1'b0;
                            o_mem_code    <= 1'b0;
                            o_mem_size    <= 2'b01;
                            o_mem_address <= span2_pend_addr;
                            o_mem_wdata   <= span2_pend_wdata;
                            mem_ready_q   <= 1'b1;
                            fill_gap_r    <= 2'd0;
                            state         <= S_RESP;
                        end
                    end else if (mem_ready_rise) begin
                        o_mem_valid <= 1'b0;
                        fill_gap_r  <= 2'd1;
                    end else begin
                        o_mem_valid <= 1'b1;
                    end
                end
                S_RESP: begin
                    // Same rise-only handshake as fill: a leftover ready level
                    // from the previous BIU beat must not complete this request.
                    if (o_mem_valid) begin
                        if (mem_ready_rise) begin
                            // Only latch rdata for reads. Store completion used to
                            // set io_rdata_valid with BIU write rdata (often 0), and
                            // that sticky value poisoned the next load (RET popped 0
                            // while stack[6ffc] still held the CALL return address).
                            if (~o_mem_write) begin
                                io_rdata_r       <= i_mem_rdata;
                                io_rdata_valid_r <= 1'b1;
                            end
                            o_data_ready     <= 1'b1;
                            o_mem_valid      <= 1'b0;
                            state            <= S_IDLE;
                        end
                    end else begin
                        // Latch fill word so data ready is still valid after
                        // leaving S_RESP (fill_resp_active drops in IDLE).
                        if (pending_data) begin
                            io_rdata_r       <= fill_resp_data;
                            io_rdata_valid_r <= 1'b1;
                        end
                        if (pending_code) begin
                            o_code_ready      <= 1'b1;
                            code_hit_accept_r <= 1'b1;
                        end else begin
                            o_data_ready <= 1'b1;
                        end
                        state <= S_IDLE;
                    end
                end
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
