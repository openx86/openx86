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
//  File        : rtc_scoreboard.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Register-level scoreboard for chip_mc146818_rtc
// ============================================================================

class rtc_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(rtc_scoreboard)

    uvm_analysis_imp #(isa_transaction, rtc_scoreboard) mon_export;

    bit [ 7:0] index_reg;
    bit [ 7:0] cmos_ram[0:127];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_export = new("mon_export", this);
    endfunction

    function void reset();
        index_reg = 8'h00;
        for (int i = 0; i < 128; i++)
            cmos_ram[i] = 8'h00;
        cmos_ram[10] = 8'h26;  // reg A default
        cmos_ram[11] = 8'h02;  // reg B default
        cmos_ram[50] = 8'h19;  // century default
    endfunction

    function void write(isa_transaction tr);
        if (tr.read) begin
            if (tr.addr[0] == 1'b0) begin
                // read index register
                if (tr.data !== index_reg)
                    `uvm_error("RTC_MISMATCH",
                        $sformatf("read index: exp=%02h got=%02h", index_reg, tr.data))
            end else begin
                bit [6:0] idx = index_reg[6:0];
                bit [7:0] expected;

                unique case (idx)
                    7'h0C: expected = 8'h00;  // reg C — clears on read
                    7'h0D: expected = 8'h80;  // reg D — VRT=1
                    default: expected = cmos_ram[idx];
                endcase

                if (tr.data !== expected)
                    `uvm_error("RTC_MISMATCH",
                        $sformatf("read idx=%02h: exp=%02h got=%02h", idx, expected, tr.data))
            end
        end else begin
            if (tr.addr[0] == 1'b0) begin
                // write index register
                index_reg = tr.data;
            end else begin
                bit [6:0] idx = index_reg[6:0];
                if (idx == 7'h0A)
                    cmos_ram[10] = tr.data & 8'h7F;
                else if (idx == 7'h0B)
                    cmos_ram[11] = tr.data;
                else if (idx == 7'h32)
                    cmos_ram[50] = tr.data;
                else if (idx != 7'h0C && idx != 7'h0D)
                    cmos_ram[idx] = tr.data;
            end
        end
    endfunction

endclass
