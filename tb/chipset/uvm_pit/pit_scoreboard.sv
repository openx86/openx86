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
//  File        : pit_scoreboard.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Register-level scoreboard for chip_8254_pit
// ============================================================================

class pit_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(pit_scoreboard)

    uvm_analysis_imp #(isa_transaction, pit_scoreboard) mon_export;

    // per-counter state
    typedef struct {
        bit [15:0] reload;
        bit [15:0] count;
        bit [15:0] latched;
        bit [ 2:0] mode;
        bit [ 1:0] rw_fmt;
        bit        bcd_en;
        bit        write_wait_msb;
        bit        load_pending;
        bit        run_en;
        bit        out_r;
        bit        latch_valid;
        bit        read_msb_phase;
    } counter_state_t;

    counter_state_t cnt[0:2];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_export = new("mon_export", this);
    endfunction

    function void reset();
        for (int i = 0; i < 3; i++) begin
            cnt[i].reload          = 16'd65536;
            cnt[i].count           = 16'd65536;
            cnt[i].latched         = 16'd0;
            cnt[i].mode            = 3'd3;
            cnt[i].rw_fmt          = 2'b11;
            cnt[i].bcd_en          = 1'b0;
            cnt[i].write_wait_msb  = 1'b1;
            cnt[i].load_pending    = 1'b0;
            cnt[i].run_en          = 1'b0;
            cnt[i].out_r           = 1'b1;
            cnt[i].latch_valid     = 1'b0;
            cnt[i].read_msb_phase  = 1'b0;
        end
    endfunction

    function void write(isa_transaction tr);
        if (tr.read) begin
            if (tr.addr[1:0] != 2'b11) begin
                int ch = tr.addr[1:0];
                bit [15:0] rval;
                bit [ 7:0] expected;

                if (cnt[ch].latch_valid)
                    rval = cnt[ch].latched;
                else
                    rval = cnt[ch].count;

                unique case (cnt[ch].rw_fmt)
                    2'b01: expected = rval[7:0];
                    2'b10: expected = rval[15:8];
                    2'b11: expected = cnt[ch].read_msb_phase ? rval[15:8] : rval[7:0];
                    default: expected = rval[7:0];
                endcase

                if (tr.data !== expected)
                    `uvm_error("PIT_MISMATCH",
                        $sformatf("read cnt%0d addr=%04h exp=%02h got=%02h (count=%04h latched=%04h fmt=%b msb=%b)",
                            ch, tr.addr, expected, tr.data, rval, cnt[ch].latched,
                            cnt[ch].rw_fmt, cnt[ch].read_msb_phase))
            end
        end else begin
            if (tr.addr[1:0] == 2'b11) begin
                // control word
                if (tr.data[7:6] != 2'b11) begin
                    int ch = tr.data[7:6];
                    if (tr.data[5:4] == 2'b00) begin
                        // latch command
                        cnt[ch].latch_valid    = 1'b1;
                        cnt[ch].latched        = cnt[ch].count;
                        cnt[ch].read_msb_phase = 1'b0;
                    end else begin
                        cnt[ch].mode           = {1'b0, tr.data[3:1]};
                        cnt[ch].rw_fmt         = tr.data[5:4];
                        cnt[ch].bcd_en         = tr.data[0];
                        cnt[ch].write_wait_msb = (tr.data[5:4] == 2'b11);
                        cnt[ch].load_pending   = 1'b0;
                        cnt[ch].run_en         = 1'b0;
                        cnt[ch].latch_valid    = 1'b0;
                        cnt[ch].read_msb_phase = 1'b0;
                        cnt[ch].out_r          = (tr.data[3:1] == 3'b000) ? 1'b0 : 1'b1;
                    end
                end
            end else begin
                int ch = tr.addr[1:0];
                unique case (cnt[ch].rw_fmt)
                    2'b01: begin
                        cnt[ch].reload     = {8'h00, tr.data};
                        cnt[ch].load_pending = 1'b1;
                        cnt[ch].run_en     = 1'b1;
                        cnt[ch].write_wait_msb = 1'b1;
                        cnt[ch].latch_valid = 1'b0;
                        cnt[ch].read_msb_phase = 1'b0;
                    end
                    2'b10: begin
                        cnt[ch].reload     = {tr.data, 8'h00};
                        cnt[ch].load_pending = 1'b1;
                        cnt[ch].run_en     = 1'b1;
                        cnt[ch].write_wait_msb = 1'b1;
                        cnt[ch].latch_valid = 1'b0;
                        cnt[ch].read_msb_phase = 1'b0;
                    end
                    2'b11: begin
                        if (cnt[ch].write_wait_msb) begin
                            cnt[ch].write_wait_msb = 1'b0;
                            cnt[ch].latch_valid    = 1'b0;
                            cnt[ch].read_msb_phase = 1'b0;
                        end else begin
                            cnt[ch].reload         = {tr.data, cnt[ch].reload[15:8]};
                            cnt[ch].load_pending   = 1'b1;
                            cnt[ch].run_en         = 1'b1;
                            cnt[ch].write_wait_msb = 1'b1;
                            cnt[ch].latch_valid    = 1'b0;
                            cnt[ch].read_msb_phase = 1'b0;
                        end
                    end
                endcase
            end
        end
    endfunction

endclass
