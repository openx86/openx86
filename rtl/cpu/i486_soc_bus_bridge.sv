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
//  File        : i486_soc_bus_bridge.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Bridge 80486 burst bus to openx86 SoC valid/ready bus
// ============================================================================

module i486_soc_bus_bridge (
    // =========================
    // 80486 CPU bus (master)
    // =========================
    input  logic         i_ads_n,
    input  logic [31: 0] i_address,
    input  logic [31: 0] i_data_out,
    input  logic         i_data_oe,
    output logic [31: 0] o_data_in,
    input  logic [ 3: 0] i_be_n,
    input  logic         i_wr_n,
    input  logic         i_mio_n,
    input  logic         i_blast_n,
    output logic         o_bready_n,

    // =========================
    // SoC simplified bus
    // =========================
    output logic         o_bus_valid,
    input  logic         i_bus_ready,
    input  logic         i_bus_busy,
    output logic         o_bus_write_enable,
    output logic         o_bus_io_access,
    output logic [31: 0] o_bus_address,
    input  logic [31: 0] i_bus_read_data,
    output logic [31: 0] o_bus_write_data,
    output logic [ 3: 0] o_bus_be_n,

    input  logic         clk,
    input  logic         rst_n
);

    typedef enum logic [ 1: 0] {
        S_IDLE,
        S_WAIT_SOC,
        S_DONE
    } bridge_state_e;

    bridge_state_e state;
    logic          latched_write;
    logic          latched_io;
    logic [31: 0]  latched_addr;
    logic [31: 0]  latched_wdata;
    // BRDY is registered one cycle after i_bus_ready, when o_bus_valid is already
    // low. Chipset IO then drives idle 0xFF — latch the beat while valid is high.
    logic [31: 0]  latched_rdata;

    assign o_data_in = latched_rdata;

    always_ff @(posedge clk or negedge rst_n) begin : ff_bridge
        if (~rst_n) begin
            state             <= S_IDLE;
            o_bready_n        <= 1'b1;
            o_bus_valid       <= 1'b0;
            o_bus_write_enable <= 1'b0;
            o_bus_io_access   <= 1'b0;
            o_bus_address     <= 32'h0;
            o_bus_write_data  <= 32'h0;
            o_bus_be_n        <= 4'h0;
            latched_write     <= 1'b0;
            latched_io        <= 1'b0;
            latched_addr      <= 32'h0;
            latched_wdata     <= 32'h0;
            latched_rdata     <= 32'h0;
        end else begin
            o_bready_n <= 1'b1;

            unique case (state)
                S_IDLE: begin
                    o_bus_valid <= 1'b0;
                    if (~i_ads_n) begin
                        latched_write    <= ~i_wr_n;
                        latched_io       <= i_mio_n;
                        latched_addr     <= i_address;
                        latched_wdata    <= i_data_out;
                        o_bus_valid      <= 1'b1;
                        o_bus_write_enable <= ~i_wr_n;
                        o_bus_io_access  <= i_mio_n;
                        o_bus_address    <= i_address;
                        o_bus_write_data <= i_data_out;
                        o_bus_be_n       <= i_be_n;
                        o_bready_n       <= 1'b1;
                        state            <= S_WAIT_SOC;
                    end
                end
                S_WAIT_SOC: begin
                    // Retire on ready alone. SDRAM asserts ready in ST_DONE while
                    // historically also busy; requiring ~busy dropped the pulse.
                    if (i_bus_ready) begin
                        latched_rdata <= i_bus_read_data;
                        o_bus_valid   <= 1'b0;
                        // Do NOT assert BRDY in this cycle. Burst samples
                        // i_data_in (= latched_rdata) when BRDY falls; a
                        // same-cycle latch+BRDY NBA race delivers the previous
                        // beat's data (often 0), so cache fills saw zeros while
                        // SDRAM already held the correct word (e.g. CALL return
                        // addr at 6ffc). Assert BRDY only in S_DONE.
                        state <= S_DONE;
                    end
                end
                S_DONE: begin
                    // BRDY with stable latched_rdata. Hold until BLAST# rises so
                    // the burst FSM cannot miss a 1-cycle pulse.
                    o_bready_n <= 1'b0;
                    if (i_blast_n) begin
                        o_bready_n <= 1'b1;
                        // Always return to IDLE. Do NOT accept back-to-back ADS#
                        // here: the burst controller holds ADS# for two cycles, so
                        // a same-pulse re-accept issued a second IDE data read and
                        // skipped every other ATA word (boot got 3ceb|4452).
                        state <= S_IDLE;
                    end
                end
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
