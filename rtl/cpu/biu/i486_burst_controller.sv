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
    input  logic [ 1: 0] i_req_size,
    input  logic [31: 0] i_req_address,
    input  logic [31: 0] i_req_wdata,
    output logic [31: 0] o_req_rdata,
    // Address of the in-flight / completing beat (stable from accept through ready)
    output logic [31: 0] o_req_beat_addr,

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
    logic [ 1: 0] latched_size;
    logic [31: 0] latched_wdata;
    logic [ 3: 0] be_n_calc;
    logic [31: 0] wdata_lanes;
    // Ignore leftover BRDY from the previous beat (bridge may still hold it
    // when we enter S_DATA); only sample after BRDY has gone inactive first.
    logic         brdy_armed;

    // Active-low BE from size + addr[1:0].
    // x86 IO (IN/OUT) places AL/AX/EAX on D[7:0]/D[15:0]/D[31:0] regardless of
    // port address LSBs — unlike memory stores which are lane-steered. Our chipset
    // (IDE 1F7, PIC, …) also samples low bytes only; shifting by port[1:0] made
    // OUT to odd ports write 0 and IN read the wrong lane (status always 0).
    always_comb begin
        if (i_req_io) begin
            unique case (i_req_size)
                2'b00:   be_n_calc = 4'b1110;
                2'b01:   be_n_calc = 4'b1100;
                default: be_n_calc = 4'b0000;
            endcase
        end else begin
            unique case (i_req_size)
                2'b00: begin
                    unique case (i_req_address[1: 0])
                        2'b00:   be_n_calc = 4'b1110;
                        2'b01:   be_n_calc = 4'b1101;
                        2'b10:   be_n_calc = 4'b1011;
                        default: be_n_calc = 4'b0111;
                    endcase
                end
                2'b01: begin
                    unique case (i_req_address[1: 0])
                        2'b00:   be_n_calc = 4'b1100;
                        2'b01:   be_n_calc = 4'b1001;
                        2'b10:   be_n_calc = 4'b0011;
                        default: be_n_calc = 4'b0111;
                    endcase
                end
                default: be_n_calc = 4'b0000;
            endcase
        end
    end

    always_comb begin
        if (i_req_io) begin
            unique case (i_req_size)
                2'b00:   wdata_lanes = {24'h0, i_req_wdata[7: 0]};
                2'b01:   wdata_lanes = {16'h0, i_req_wdata[15: 0]};
                default: wdata_lanes = i_req_wdata;
            endcase
        end else begin
            unique case (i_req_size)
                2'b00:   wdata_lanes = {24'h0, i_req_wdata[7: 0]} << (i_req_address[1: 0] * 8);
                2'b01:   wdata_lanes = {16'h0, i_req_wdata[15: 0]} << (i_req_address[1: 0] * 8);
                default: wdata_lanes = i_req_wdata;
            endcase
        end
    end

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
            latched_size  <= 2'b10;
            latched_wdata <= 32'h0;
            brdy_armed    <= 1'b0;
        end else begin
            o_req_ready <= 1'b0;

            unique case (state)
                S_IDLE: begin
                    o_ads_n   <= 1'b1;
                    o_data_oe <= 1'b0;
                    o_blast_n <= 1'b1;
                    brdy_armed <= 1'b0;
                    if (i_req_valid & ~i_hold) begin
                        latched_addr  <= i_req_address;
                        latched_write <= i_req_write;
                        latched_io    <= i_req_io;
                        latched_code  <= i_req_code;
                        latched_size  <= i_req_size;
                        latched_wdata <= wdata_lanes;
                        o_address     <= i_req_address;
                        o_be_n        <= be_n_calc;
                        o_wr_n        <= ~i_req_write;
                        o_dc_n        <= i_req_code ? 1'b1 : 1'b0;
                        o_mio_n       <= i_req_io ? 1'b1 : 1'b0;
                        // Drive write data with the first ADS# beat. The SoC
                        // bridge samples i_data_out on the first observed ADS#
                        // edge (one cycle after we assert it); if data only
                        // appeared in S_ADDR, the bridge latched the previous
                        // beat's data (e.g. CALL push stored UART 'A'=0x41).
                        if (i_req_write) begin
                            o_data_out <= wdata_lanes;
                            o_data_oe  <= 1'b1;
                        end else begin
                            o_data_oe <= 1'b0;
                        end
                        // Hold ADS# low for two cycles so the SoC bridge (which
                        // samples one edge later) cannot miss a 1-cycle pulse.
                        o_ads_n       <= 1'b0;
                        state         <= S_ADDR;
                    end
                end
                S_ADDR: begin
                    // Second ADS# cycle; still not sampling data.
                    o_ads_n    <= 1'b0;
                    brdy_armed <= 1'b0;
                    state      <= S_DATA;
                    if (latched_write) begin
                        o_data_out <= latched_wdata;
                        o_data_oe  <= 1'b1;
                    end else begin
                        o_data_oe <= 1'b0;
                    end
                    o_blast_n <= 1'b0;
                end
                S_DATA: begin
                    o_ads_n <= 1'b1;
                    if (i_bready_n)
                        brdy_armed <= 1'b1;
                    if (~i_bready_n & brdy_armed) begin
                        if (~latched_write) begin
                            // Memory: extract lane(s) into low bits for the CPU.
                            // IO: chipset returns payload in D[7:0]/D[15:0] already.
                            if (latched_io) begin
                                unique case (latched_size)
                                    2'b00:   o_req_rdata <= {24'h0, i_data_in[ 7: 0]};
                                    2'b01:   o_req_rdata <= {16'h0, i_data_in[15: 0]};
                                    default: o_req_rdata <= i_data_in;
                                endcase
                            end else begin
                                unique case (latched_size)
                                    2'b00: begin
                                        unique case (latched_addr[1: 0])
                                            2'b00:   o_req_rdata <= {24'h0, i_data_in[ 7: 0]};
                                            2'b01:   o_req_rdata <= {24'h0, i_data_in[15: 8]};
                                            2'b10:   o_req_rdata <= {24'h0, i_data_in[23:16]};
                                            default: o_req_rdata <= {24'h0, i_data_in[31:24]};
                                        endcase
                                    end
                                    2'b01: begin
                                        unique case (latched_addr[1: 0])
                                            2'b00:   o_req_rdata <= {16'h0, i_data_in[15: 0]};
                                            2'b01:   o_req_rdata <= {16'h0, i_data_in[23: 8]};
                                            2'b10:   o_req_rdata <= {16'h0, i_data_in[31:16]};
                                            default: o_req_rdata <= {24'h0, i_data_in[31:24]};
                                        endcase
                                    end
                                    default: o_req_rdata <= i_data_in;
                                endcase
                            end
                        end
                        o_data_oe   <= 1'b0;
                        o_blast_n   <= 1'b1;
                        o_req_ready <= 1'b1;
                        brdy_armed  <= 1'b0;
                        state       <= S_IDLE;
                    end
                end
                default: state <= S_IDLE;
            endcase
        end
    end

    assign o_req_beat_addr = latched_addr;

endmodule
