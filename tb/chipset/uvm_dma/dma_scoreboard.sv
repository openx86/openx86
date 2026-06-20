// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : dma_scoreboard.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Scoreboard for chip_8237_dma
// ============================================================================

class dma_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(dma_scoreboard)

    uvm_analysis_imp #(isa_transaction, dma_scoreboard) mon_export;

    // channel regs
    bit [15: 0] ch_addr [0: 3];
    bit [15: 0] ch_count[0: 3];

    // control regs
    bit [ 7: 0] reg_command;
    bit [ 3: 0] reg_request;
    bit [ 3: 0] reg_mask;
    bit [ 7: 0] reg_mode_last;
    bit [ 3: 0] reg_tc;
    bit         first_last;

    // page registers (0x80-0x8F)
    bit [ 7: 0] page_reg[0: 15];

    // DMA16 stub (0xC0-0xDF)
    bit [ 7: 0] dma16_stub[0: 31];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_export = new("mon_export", this);
    endfunction

    function void reset();
        for (int i = 0; i < 4; i++) begin
            ch_addr[i]  = 16'h0000;
            ch_count[i] = 16'h0000;
        end
        reg_command  = 8'h00;
        reg_request  = 4'h0;
        reg_mask     = 4'hF;
        reg_mode_last = 8'h00;
        reg_tc       = 4'h0;
        first_last   = 1'b0;
        for (int j = 0; j < 16; j++) page_reg[j] = 8'h00;
        for (int k = 0; k < 32; k++) dma16_stub[k] = 8'h00;
    endfunction

    function void write(isa_transaction tr);
        bit [15:0] a = tr.addr;

        if (tr.read) begin
            if (a <= 16'h000F) begin
                if (a[3:0] <= 4'h7) begin
                    // channel addr/count read
                end else begin
                    unique case (a[3:0])
                        4'h8: check_read(tr, {reg_request, reg_tc}, "STATUS");
                        4'hA: check_read(tr, {4'h0, reg_mask}, "MASK");
                        4'hB: check_read(tr, reg_mode_last, "MODE");
                        4'hF: check_read(tr, {4'h0, reg_mask}, "ALL_MASK");
                        default: check_read(tr, 8'hFF, "INVALID_LO");
                    endcase
                end
            end else if (a >= 16'h0080 && a <= 16'h008F) begin
                check_read(tr, page_reg[a[3:0]], "PAGE_REG");
            end else if (a >= 16'h00C0 && a <= 16'h00DF) begin
                check_read(tr, dma16_stub[a[4:0]], "DMA16");
            end else
                check_read(tr, 8'hFF, "NO_HIT");
        end else begin
            if (a <= 16'h000F) begin
                if (a[3:0] <= 4'h7) begin
                    int ch = a[2:1];
                    int is_count = a[0];
                    if (!first_last) begin
                        if (!is_count) ch_addr[ch][7:0]  = tr.data;
                        else           ch_count[ch][7:0] = tr.data;
                    end else begin
                        if (!is_count) ch_addr[ch][15:8] = tr.data;
                        else           ch_count[ch][15:8]= tr.data;
                    end
                    first_last = ~first_last;
                end else begin
                    unique case (a[3:0])
                        4'h8: reg_command = tr.data;
                        4'h9: reg_request[tr.data[1:0]] = tr.data[2];
                        4'hA: reg_mask[tr.data[1:0]] = tr.data[2];
                        4'hB: reg_mode_last = tr.data;
                        4'hC: first_last = 1'b0;
                        4'hD: begin
                            for (int i = 0; i < 4; i++) begin
                                ch_addr[i] = 16'h0000;
                                ch_count[i] = 16'h0000;
                            end
                            reg_command = 8'h00;
                            reg_request = 4'h0;
                            reg_mask = 4'hF;
                            reg_tc = 4'h0;
                            first_last = 1'b0;
                        end
                        4'hE: reg_mask = 4'h0;
                        4'hF: reg_mask = tr.data[3:0];
                    endcase
                end
            end else if (a >= 16'h0080 && a <= 16'h008F) begin
                page_reg[a[3:0]] = tr.data;
            end else if (a >= 16'h00C0 && a <= 16'h00DF) begin
                dma16_stub[a[4:0]] = tr.data;
            end
        end
    endfunction

    function void check_read(isa_transaction tr, bit [7:0] expected, string rgn);
        if (tr.data !== expected)
            `uvm_error("DMA_MISMATCH",
                $sformatf("read %s addr=%04h: exp=%02h got=%02h", rgn, tr.addr, expected, tr.data))
    endfunction

endclass
