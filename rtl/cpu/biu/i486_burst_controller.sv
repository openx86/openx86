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
//  File        : i486_burst_controller.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : 80486 external burst bus protocol (address/data phases)
// ============================================================================

module i486_burst_controller (
    // =========================
    // Internal BIU handshake (single beat)
    // =========================
    input  logic         i_req_valid,
    output logic         o_req_ready,
    input  logic         i_req_write,
    input  logic         i_req_io,
    input  logic         i_req_code,
    input  logic [31: 0] i_req_address,
    input  logic [31: 0] i_req_wdata,
    output logic [31: 0] o_req_rdata,

    // =========================
    // 80486 pin-level bus
    // =========================
    output logic         o_ads_n,
    output logic [31: 0] o_address,
    output logic [31: 0] o_data_out,
    output logic         o_data_oe,
    input  logic [31: 0] i_data_in,
    output logic [ 3: 0] o_be_n,
    output logic         o_wr_n,
    output logic         o_dc_n,
    output logic         o_mio_n,
    output logic         o_blast_n,
    input  logic         i_bready_n,

    // =========================
    // HOLD acknowledge
    // =========================
    input  logic         i_hold,
    output logic         o_hlda,

    input  logic         clk,
    input  logic         rst_n
);

    typedef enum logic [ 1: 0] {
        S_IDLE,
        S_ADDR,
        S_DATA
    } burst_state_e;

    burst_state_e state;
    logic [31: 0] latched_addr;
    logic         latched_write;
    logic         latched_io;
    logic         latched_code;
    logic [31: 0] latched_wdata;

    assign o_hlda = i_hold;

    always_ff @(posedge clk or negedge rst_n) begin : ff_burst_fsm
        if (~rst_n) begin
            state         <= S_IDLE;
            o_ads_n       <= 1'b1;
            o_address     <= 32'h0;
            o_data_out    <= 32'h0;
            o_data_oe     <= 1'b0;
            o_be_n        <= 4'hF;
            o_wr_n        <= 1'b1;
            o_dc_n        <= 1'b1;
            o_mio_n       <= 1'b1;
            o_blast_n     <= 1'b1;
            o_req_ready   <= 1'b0;
            o_req_rdata   <= 32'h0;
            latched_addr  <= 32'h0;
            latched_write <= 1'b0;
            latched_io    <= 1'b0;
            latched_code  <= 1'b0;
            latched_wdata <= 32'h0;
        end else begin
            o_req_ready <= 1'b0;

            unique case (state)
                S_IDLE: begin
                    o_ads_n   <= 1'b1;
                    o_data_oe <= 1'b0;
                    o_blast_n <= 1'b1;
                    if (i_req_valid & ~i_hold) begin
                        latched_addr  <= i_req_address;
                        latched_write <= i_req_write;
                        latched_io    <= i_req_io;
                        latched_code  <= i_req_code;
                        latched_wdata <= i_req_wdata;
                        o_address     <= i_req_address;
                        o_be_n        <= 4'h0;
                        o_wr_n        <= ~i_req_write;
                        o_dc_n        <= i_req_code ? 1'b1 : 1'b0;
                        o_mio_n       <= i_req_io ? 1'b1 : 1'b0;
                        o_ads_n       <= 1'b0;
                        state         <= S_ADDR;
                    end
                end
                S_ADDR: begin
                    o_ads_n <= 1'b1;
                    state   <= S_DATA;
                    if (latched_write) begin
                        o_data_out <= latched_wdata;
                        o_data_oe  <= 1'b1;
                    end else begin
                        o_data_oe <= 1'b0;
                    end
                    o_blast_n <= 1'b0;
                end
                S_DATA: begin
                    if (~i_bready_n) begin
                        if (~latched_write) begin
                            o_req_rdata <= i_data_in;
                        end
                        o_data_oe   <= 1'b0;
                        o_blast_n   <= 1'b1;
                        o_req_ready <= 1'b1;
                        state       <= S_IDLE;
                    end
                end
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
