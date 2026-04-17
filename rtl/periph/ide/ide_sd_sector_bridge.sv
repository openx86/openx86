/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements ide_sd_sector_bridge.
*/
// ============================================================================
// IDE 异步扇区缓冲 ↔ SD 原生主机
// ============================================================================

module ide_sd_sector_bridge (
    input  logic [31: 0] i_ide_disk_raddr,
    output logic [ 7: 0]  o_ide_disk_rdata,
    input  logic        i_ide_sector_req,
    output logic        o_ide_sector_ready,
    output logic        o_sd_start,
    output logic [31: 0] o_sd_lba,
    input  logic        i_sd_busy,
    input  logic        i_sd_done,
    input  logic        i_sd_err,
    input  logic        i_sd_payload_we,
    input  logic [ 8: 0]  i_sd_payload_addr,
    input  logic [ 7: 0]  i_sd_payload_data,
    input  logic        reset_n,
    input  logic        clock
);

    logic [ 7: 0] sector_ram[ 0: 511];
    logic       sd_run;
    logic       req_d;
    logic       ready_latched;
    logic       pending_start;

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n)
            req_d <= 1'b0;
        else
            req_d <= i_ide_sector_req;
    end

    wire req_on = i_ide_sector_req && !req_d;

    wire start_pulse = pending_start && !sd_run && !i_sd_busy;

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n)
            pending_start <= 1'b0;
        else begin
            if (req_on)
                pending_start <= 1'b1;
            else if (start_pulse)
                pending_start <= 1'b0;
        end
    end

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n)
            sd_run <= 1'b0;
        else begin
            if (start_pulse)
                sd_run <= 1'b1;
            else if (i_sd_done || i_sd_err)
                sd_run <= 1'b0;
        end
    end

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n)
            o_sd_start <= 1'b0;
        else
            o_sd_start <= start_pulse;
    end

    assign o_sd_lba = i_ide_disk_raddr[31:  9];

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n)
            ready_latched <= 1'b0;
        else begin
            if (req_on)
                ready_latched <= 1'b0;
            else if (sd_run && i_sd_done)
                ready_latched <= 1'b1;
        end
    end

    assign o_ide_sector_ready = ready_latched;

    integer bi;
    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            for (bi = 0; bi < 512; bi = bi + 1)
                sector_ram[bi] <= 8'h00;
        end else if (i_sd_payload_we && i_sd_payload_addr <= 9'd511)
            sector_ram[i_sd_payload_addr] <= i_sd_payload_data;
    end

    always_comb begin
        if (i_ide_disk_raddr[ 8: 0] <= 9'd511)
            o_ide_disk_rdata = sector_ram[i_ide_disk_raddr[ 8: 0]];
        else
            o_ide_disk_rdata = 8'h00;
    end

endmodule
