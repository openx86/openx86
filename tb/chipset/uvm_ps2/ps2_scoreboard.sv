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
//  File        : ps2_scoreboard.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Scoreboard for chip_i8042_ps2
// ============================================================================

class ps2_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(ps2_scoreboard)

    uvm_analysis_imp #(isa_transaction, ps2_scoreboard) mon_export;

    // FIFO state
    bit [ 7:0] kbd_fifo[0:15];
    bit [ 3:0] kbd_wptr, kbd_rptr;
    bit [ 4:0] kbd_count;
    bit [ 7:0] aux_fifo[0:15];
    bit [ 3:0] aux_wptr, aux_rptr;
    bit [ 4:0] aux_count;

    // control state
    bit        use_aux_out;
    bit        kbd_if_en;
    bit        aux_if_en;
    bit        kbd_irq_en;
    bit        aux_irq_en;
    bit        last_wr_cmd;
    bit        next_wr_to_aux;
    bit        cmd_d2_pending;
    bit        cmd_d3_pending;
    bit        kbd_parity_err;
    bit        aux_parity_err;

    // TX pending
    bit        kbd_tx_pending;
    bit [ 7:0] kbd_tx_hold;
    bit        aux_tx_pending;
    bit [ 7:0] aux_tx_hold;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_export = new("mon_export", this);
    endfunction

    function void reset();
        kbd_wptr      = '0;
        kbd_rptr      = '0;
        kbd_count     = '0;
        aux_wptr      = '0;
        aux_rptr      = '0;
        aux_count     = '0;
        use_aux_out   = 1'b0;
        kbd_if_en     = 1'b1;
        aux_if_en     = 1'b1;
        kbd_irq_en    = 1'b1;
        aux_irq_en    = 1'b1;
        last_wr_cmd   = 1'b0;
        next_wr_to_aux = 1'b0;
        cmd_d2_pending = 1'b0;
        cmd_d3_pending = 1'b0;
        kbd_parity_err = 1'b0;
        aux_parity_err = 1'b0;
        kbd_tx_pending = 1'b0;
        kbd_tx_hold    = '0;
        aux_tx_pending = 1'b0;
        aux_tx_hold    = '0;
    endfunction

    function bit kbd_obf(); return (kbd_count != 5'h0); endfunction
    function bit aux_obf(); return (aux_count != 5'h0); endfunction
    function bit obf_stat(); return kbd_obf() | aux_obf(); endfunction
    function bit obf_from_aux(); return aux_obf() && (use_aux_out || !kbd_obf()); endfunction
    function bit ibf_stat(); return kbd_tx_pending | aux_tx_pending | next_wr_to_aux | cmd_d2_pending | cmd_d3_pending; endfunction

    function bit [7:0] kbd_head(); return kbd_fifo[kbd_rptr]; endfunction
    function bit [7:0] aux_head(); return aux_fifo[aux_rptr]; endfunction

    function bit [7:0] expected_status();
        return {
            kbd_parity_err | aux_parity_err,
            1'b0,
            obf_from_aux(),
            1'b0,
            last_wr_cmd,
            1'b0,
            ibf_stat(),
            obf_stat()
        };
    endfunction

    function bit [7:0] expected_data();
        if (obf_from_aux() && aux_obf())
            return aux_head();
        else if (kbd_obf())
            return kbd_head();
        else
            return 8'h00;
    endfunction

    function void push_kbd(bit [7:0] data);
        if (kbd_count < 5'd16) begin
            kbd_fifo[kbd_wptr] = data;
            kbd_wptr = kbd_wptr + 4'h1;
            kbd_count = kbd_count + 5'h1;
            if ((kbd_count == 5'h0) && (aux_count == 5'h0))
                use_aux_out = 1'b0;
        end
    endfunction

    function void push_aux(bit [7:0] data);
        if (aux_count < 5'd16) begin
            aux_fifo[aux_wptr] = data;
            aux_wptr = aux_wptr + 4'h1;
            aux_count = aux_count + 5'h1;
            if ((kbd_count == 5'h0) && (aux_count == 5'h0))
                use_aux_out = 1'b1;
        end
    endfunction

    function void write(isa_transaction tr);
        if (tr.read) begin
            if (tr.addr[0] == 1'b0) begin
                // data port
                if (tr.data !== expected_data())
                    `uvm_error("PS2_MISMATCH",
                        $sformatf("read data: exp=%02h got=%02h", expected_data(), tr.data))
                // pop FIFO on read
                if (obf_from_aux() && aux_obf()) begin
                    aux_rptr = aux_rptr + 4'h1;
                    aux_count = aux_count - 5'h1;
                    if ((aux_count == 5'h1) && kbd_obf())
                        use_aux_out = 1'b0;
                end else if (kbd_obf()) begin
                    kbd_rptr = kbd_rptr + 4'h1;
                    kbd_count = kbd_count - 5'h1;
                    if ((kbd_count == 5'h1) && aux_obf())
                        use_aux_out = 1'b1;
                end
            end else begin
                // status port
                if (tr.data !== expected_status())
                    `uvm_error("PS2_MISMATCH",
                        $sformatf("read status: exp=%02h got=%02h", expected_status(), tr.data))
            end
        end else begin
            if (tr.addr[0] == 1'b1) begin
                // command port write
                last_wr_cmd = 1'b1;
                unique case (tr.data)
                    8'hD4: begin
                        next_wr_to_aux = 1'b1;
                        cmd_d2_pending = 1'b0;
                        cmd_d3_pending = 1'b0;
                    end
                    8'hD2: begin
                        cmd_d2_pending = 1'b1;
                        cmd_d3_pending = 1'b0;
                        next_wr_to_aux = 1'b0;
                    end
                    8'hD3: begin
                        cmd_d2_pending = 1'b0;
                        cmd_d3_pending = 1'b1;
                        next_wr_to_aux = 1'b0;
                    end
                    8'hAE: kbd_if_en = 1'b1;
                    8'hAD: kbd_if_en = 1'b0;
                    8'hA7: aux_if_en = 1'b0;
                    8'hA8: aux_if_en = 1'b1;
                endcase
            end else begin
                // data port write
                last_wr_cmd = 1'b0;
                if (cmd_d2_pending) begin
                    if (kbd_count < 5'd16) begin
                        kbd_fifo[kbd_wptr] = tr.data;
                        kbd_wptr = kbd_wptr + 4'h1;
                        kbd_count = kbd_count + 5'h1;
                        use_aux_out = 1'b0;
                    end
                    cmd_d2_pending = 1'b0;
                end else if (cmd_d3_pending) begin
                    if (aux_count < 5'd16) begin
                        aux_fifo[aux_wptr] = tr.data;
                        aux_wptr = aux_wptr + 4'h1;
                        aux_count = aux_count + 5'h1;
                        use_aux_out = 1'b1;
                    end
                    cmd_d3_pending = 1'b0;
                end else if (next_wr_to_aux) begin
                    if (aux_if_en) begin
                        if (!aux_tx_pending) begin
                            aux_tx_pending = 1'b1;
                            aux_tx_hold = tr.data;
                        end
                    end
                end else if (kbd_if_en) begin
                    if (!kbd_tx_pending) begin
                        kbd_tx_pending = 1'b1;
                        kbd_tx_hold = tr.data;
                    end
                end
                next_wr_to_aux = 1'b0;
            end
        end
    endfunction

endclass
