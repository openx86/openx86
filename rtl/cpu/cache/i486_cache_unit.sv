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
        S_FILL_ISSUE,
        S_FILL_WAIT,
        S_FILL_GAP,
        S_RESP
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
    logic [31: 0] pending_wdata;
    logic         code_hit_accept_r;
    logic [ 1: 0] fill_gap_r;
    logic [31: 0] fill_resp_data;
    logic         fill_resp_active;
    logic [31: 0] io_rdata_r;
    logic         io_rdata_valid_r;
    logic         io_req_accept_r;

    function automatic logic [31: 0] f_extract_word (
        input logic [LP_LINE_BYTES * 8 - 1: 0] line_data,
        input logic [LP_OFFSET_BITS - 1: 0]    byte_off
    );
        logic [ 4: 0] word_idx;
        word_idx = byte_off[LP_OFFSET_BITS - 1: 2];
        return line_data[word_idx * 32 +: 32];
    endfunction

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
                data_hit_data = f_extract_word(data_mem[data_index][w], data_offset);
            end
        end
    end

    // Post-fill response must use pending_addr — live IFU/EXU addresses can change.
    // IO responses forward BIU rdata (never the hit mux, which would be 0).
    assign fill_resp_active = (state == S_RESP) & ~o_mem_valid;
    assign fill_resp_data   = f_extract_word(
        data_mem[fill_index][fill_way],
        pending_addr[LP_OFFSET_BITS - 1: 0]
    );
    assign o_code_data  = (fill_resp_active & pending_code) ? fill_resp_data : code_hit_data;
    assign o_data_rdata = (state == S_RESP && o_mem_valid) ? i_mem_rdata :
                          io_rdata_valid_r ? io_rdata_r :
                          (fill_resp_active & pending_data) ? fill_resp_data : data_hit_data;

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
            fill_beat         <= 5'd0;
            fill_way          <= 2'b00;
            fill_base_addr    <= 32'h0;
            fill_index        <= {LP_INDEX_BITS{1'b0}};
            fill_tag          <= {LP_TAG_BITS{1'b0}};
            pending_code      <= 1'b0;
            pending_data      <= 1'b0;
            pending_write     <= 1'b0;
            pending_addr      <= 32'h0;
            pending_wdata     <= 32'h0;
            code_hit_accept_r <= 1'b0;
            fill_gap_r        <= 2'd0;
            io_rdata_r        <= 32'h0;
            io_rdata_valid_r  <= 1'b0;
            io_req_accept_r   <= 1'b0;
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
                        o_data_ready        <= 1'b1;
                        lru_ptr[data_index] <= data_hit_way;
                        if (i_data_write_enable) begin
                            data_mem[data_index][data_hit_way][data_offset[4: 2] * 32 +: 32] <= i_data_wdata;
                        end
                    end else if (i_data_valid & i_data_io_access & ~io_req_accept_r) begin
                        o_mem_valid     <= 1'b1;
                        o_mem_write     <= i_data_write_enable;
                        o_mem_io        <= 1'b1;
                        o_mem_code      <= 1'b0;
                        o_mem_address   <= i_data_address;
                        o_mem_wdata     <= i_data_wdata;
                        io_req_accept_r <= 1'b1;
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
                        pending_wdata  <= 32'h0;
                        o_mem_valid    <= 1'b1;
                        o_mem_write    <= 1'b0;
                        o_mem_io       <= 1'b0;
                        o_mem_code     <= 1'b1;
                        o_mem_address  <= {i_code_address[31: LP_OFFSET_BITS], {LP_OFFSET_BITS{1'b0}}};
                        state          <= S_FILL_ISSUE;
                    end else if (i_data_valid & ~i_data_io_access & ~data_hit) begin
                        fill_way       <= lru_ptr[data_index];
                        fill_beat      <= 5'd0;
                        fill_base_addr <= {i_data_address[31: LP_OFFSET_BITS], {LP_OFFSET_BITS{1'b0}}};
                        fill_index     <= data_index;
                        fill_tag       <= data_tag;
                        pending_code   <= 1'b0;
                        pending_data   <= 1'b1;
                        pending_write  <= i_data_write_enable;
                        pending_addr   <= i_data_address;
                        pending_wdata  <= i_data_wdata;
                        o_mem_valid    <= 1'b1;
                        o_mem_write    <= 1'b0;
                        o_mem_io       <= 1'b0;
                        o_mem_code     <= 1'b0;
                        o_mem_address  <= {i_data_address[31: LP_OFFSET_BITS], {LP_OFFSET_BITS{1'b0}}};
                        state          <= S_FILL_ISSUE;
                    end
                end
                S_FILL_ISSUE: begin
                    // Pulse valid one cycle per beat, then wait with valid low.
                    o_mem_valid <= 1'b0;
                    state       <= S_FILL_WAIT;
                end
                S_FILL_WAIT: begin
                    if (i_mem_ready) begin
                        data_mem[fill_index][fill_way][fill_beat * 32 +: 32] <= i_mem_rdata;
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
                    fill_gap_r <= fill_gap_r + 2'd1;
                    if (fill_gap_r == 2'd2) begin
                        o_mem_valid <= 1'b1;
                        state       <= S_FILL_ISSUE;
                    end
                end
                S_RESP: begin
                    if (o_mem_valid) begin
                        if (i_mem_ready) begin
                            io_rdata_r       <= i_mem_rdata;
                            io_rdata_valid_r <= 1'b1;
                            o_data_ready     <= 1'b1;
                            o_mem_valid      <= 1'b0;
                            state            <= S_IDLE;
                        end
                    end else begin
                        if (pending_code) begin
                            o_code_ready      <= 1'b1;
                            code_hit_accept_r <= 1'b1;
                        end else begin
                            o_data_ready <= 1'b1;
                            if (pending_write) begin
                                data_mem[fill_index][fill_way][pending_addr[4: 2] * 32 +: 32] <= pending_wdata;
                            end
                        end
                        state <= S_IDLE;
                    end
                end
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
