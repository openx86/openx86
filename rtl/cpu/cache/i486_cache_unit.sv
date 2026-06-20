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

    localparam int LP_LINE_BYTES = 32;
    localparam int LP_NUM_SETS   = 64;
    localparam int LP_NUM_WAYS   = 4;
    localparam int LP_INDEX_BITS = 6;
    localparam int LP_OFFSET_BITS = 5;
    localparam int LP_TAG_BITS   = 32 - LP_INDEX_BITS - LP_OFFSET_BITS;

    logic [LP_NUM_SETS - 1: 0][LP_NUM_WAYS - 1: 0][LP_TAG_BITS - 1: 0] tag_mem;
    logic [LP_NUM_SETS - 1: 0][LP_NUM_WAYS - 1: 0]                      valid_mem;
    logic [LP_NUM_SETS - 1: 0][LP_NUM_WAYS - 1: 0][LP_LINE_BYTES * 8 - 1: 0] data_mem;
    logic [LP_INDEX_BITS - 1: 0] lru_ptr [LP_NUM_SETS - 1: 0];

    logic [31: 0] req_addr;
    logic         req_write;
    logic         req_code;
    logic         req_valid;
    logic [31: 0] req_wdata;
    logic [LP_INDEX_BITS - 1: 0]    req_index;
    logic [LP_OFFSET_BITS - 1: 0]   req_offset;
    logic [LP_TAG_BITS - 1: 0]      req_tag;
    logic [LP_NUM_WAYS - 1: 0]      hit_way_onehot;
    logic                           cache_hit;
    logic [ 1: 0]                   hit_way;
    logic [31: 0]                   hit_data;

    typedef enum logic [ 1: 0] {
        S_IDLE,
        S_FILL,
        S_RESP
    } cache_state_e;

    cache_state_e state;
    logic [ 1: 0] fill_way;
    logic [ 4: 0] fill_beat;
    logic [31: 0] fill_base_addr;
    logic         pending_code;
    logic         pending_data;
    logic         pending_write;
    logic [31: 0] pending_addr;
    logic [31: 0] pending_wdata;

    function automatic logic [31: 0] f_extract_word (
        input logic [LP_LINE_BYTES * 8 - 1: 0] line_data,
        input logic [LP_OFFSET_BITS - 1: 0]    byte_off
    );
        logic [ 4: 0] word_idx;
        word_idx = byte_off[LP_OFFSET_BITS - 1: 2];
        return line_data[word_idx * 32 +: 32];
    endfunction

    always_comb begin
        req_valid = i_code_valid | i_data_valid;
        req_code  = i_code_valid;
        req_write = i_data_valid & i_data_write_enable;
        req_addr  = i_code_valid ? i_code_address : i_data_address;
        req_wdata = i_data_wdata;
        req_index = req_addr[LP_INDEX_BITS + LP_OFFSET_BITS - 1: LP_OFFSET_BITS];
        req_offset = req_addr[LP_OFFSET_BITS - 1: 0];
        req_tag   = req_addr[31: LP_INDEX_BITS + LP_OFFSET_BITS];

        hit_way_onehot = 4'b0000;
        cache_hit      = 1'b0;
        hit_data       = 32'h0;
        hit_way        = 2'b00;
        for (int w = 0; w < LP_NUM_WAYS; w++) begin
            if (valid_mem[req_index][w] & (tag_mem[req_index][w] == req_tag)) begin
                hit_way_onehot[w] = 1'b1;
                cache_hit         = 1'b1;
                hit_way           = w[1: 0];
                hit_data          = f_extract_word(data_mem[req_index][w], req_offset);
            end
        end
    end

    assign o_code_data  = hit_data;
    assign o_data_rdata = hit_data;

    always_ff @(posedge clk or negedge rst_n) begin : ff_cache_ctrl
        integer s, w;
        if (~rst_n) begin
            state          <= S_IDLE;
            o_code_ready   <= 1'b0;
            o_data_ready   <= 1'b0;
            o_mem_valid    <= 1'b0;
            o_mem_write    <= 1'b0;
            o_mem_io       <= 1'b0;
            o_mem_code     <= 1'b0;
            o_mem_address  <= 32'h0;
            o_mem_wdata    <= 32'h0;
            fill_beat      <= 5'd0;
            fill_way       <= 2'b00;
            fill_base_addr <= 32'h0;
            pending_code   <= 1'b0;
            pending_data   <= 1'b0;
            pending_write  <= 1'b0;
            pending_addr   <= 32'h0;
            pending_wdata  <= 32'h0;
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

            unique case (state)
                S_IDLE: begin
                    o_mem_valid <= 1'b0;
                    if (i_code_valid & cache_hit) begin
                        o_code_ready <= 1'b1;
                        lru_ptr[req_index] <= hit_way;
                    end else if (i_data_valid & ~i_data_io_access & cache_hit) begin
                        o_data_ready <= 1'b1;
                        lru_ptr[req_index] <= hit_way;
                        if (i_data_write_enable) begin
                            data_mem[req_index][hit_way][req_offset[4: 2] * 32 +: 32] <= i_data_wdata;
                        end
                    end else if (req_valid & ~i_data_io_access & ~cache_hit) begin
                        fill_way       <= lru_ptr[req_index];
                        fill_beat      <= 5'd0;
                        fill_base_addr <= {req_addr[31: LP_OFFSET_BITS], {LP_OFFSET_BITS{1'b0}}};
                        pending_code   <= i_code_valid;
                        pending_data   <= i_data_valid;
                        pending_write  <= req_write;
                        pending_addr   <= req_addr;
                        pending_wdata  <= req_wdata;
                        o_mem_valid    <= 1'b1;
                        o_mem_write    <= 1'b0;
                        o_mem_io       <= 1'b0;
                        o_mem_code     <= i_code_valid;
                        o_mem_address  <= {req_addr[31: LP_OFFSET_BITS], {LP_OFFSET_BITS{1'b0}}};
                        state          <= S_FILL;
                    end else if (i_data_valid & i_data_io_access) begin
                        o_mem_valid   <= 1'b1;
                        o_mem_write   <= i_data_write_enable;
                        o_mem_io      <= 1'b1;
                        o_mem_code    <= 1'b0;
                        o_mem_address <= i_data_address;
                        o_mem_wdata   <= i_data_wdata;
                        state         <= S_RESP;
                    end
                end
                S_FILL: begin
                    if (i_mem_ready) begin
                        data_mem[req_index][fill_way][fill_beat * 32 +: 32] <= i_mem_rdata;
                        fill_beat <= fill_beat + 5'd1;
                        if (fill_beat == 5'd7) begin
                            valid_mem[req_index][fill_way] <= 1'b1;
                            tag_mem[req_index][fill_way]   <= req_tag;
                            lru_ptr[req_index]             <= fill_way;
                            o_mem_valid                    <= 1'b0;
                            state                          <= S_RESP;
                        end else begin
                            o_mem_address <= fill_base_addr + ((fill_beat + 5'd1) << 2);
                        end
                    end
                end
                S_RESP: begin
                    if (i_mem_ready) begin
                        if (pending_code) begin
                            o_code_ready <= 1'b1;
                        end else begin
                            o_data_ready <= 1'b1;
                            if (pending_write) begin
                                data_mem[req_index][fill_way][pending_addr[4: 2] * 32 +: 32] <= pending_wdata;
                            end
                        end
                        o_mem_valid <= 1'b0;
                        state       <= S_IDLE;
                    end
                end
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
