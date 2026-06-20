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
//  File        : pic_scoreboard.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Reference model and scoreboard for chip_8259_pic
// ============================================================================

class pic_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(pic_scoreboard)

    uvm_analysis_imp #(isa_transaction, pic_scoreboard) mon_export;

    // PIC state
    typedef enum logic [2:0] {
        ST_RESET, ST_ICW2, ST_ICW3, ST_ICW4, ST_READY
    } pic_state_e;

    pic_state_e state;
    bit         need_icw3;
    bit         need_icw4;
    bit         ltim;
    bit         aeoi;
    bit         read_isr;
    bit [ 7:0] icw2_vec;
    bit [ 7:0] imr;
    bit [ 7:0] irr;
    bit [ 7:0] isr;
    bit [ 7:0] ir_prev;

    // external inputs
    bit [ 7:0] ir_driven;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_export = new("mon_export", this);
    endfunction

    function void reset();
        state     = ST_RESET;
        need_icw3 = 1'b0;
        need_icw4 = 1'b0;
        ltim      = 1'b0;
        aeoi      = 1'b0;
        read_isr  = 1'b0;
        icw2_vec  = 8'h00;
        imr       = 8'hFF;
        irr       = 8'h00;
        isr       = 8'h00;
        ir_prev   = 8'h00;
        ir_driven = 8'h00;
    endfunction

    // highest priority index finder
    function logic [2:0] highest_prio(logic [7:0] vec);
        for (int i = 0; i < 8; i++)
            if (vec[i]) return i[2:0];
        return 3'd0;
    endfunction

    function void write(isa_transaction tr);
        if (tr.read) begin
            bit [7:0] expected;
            if (tr.addr[0] == 1'b0)
                expected = read_isr ? isr : irr;
            else
                expected = imr;
            if (tr.data !== expected)
                `uvm_error("PIC_MISMATCH",
                    $sformatf("read addr=%04h exp=%02h got=%02h (state=%s isr=%02h irr=%02h imr=%02h)",
                        tr.addr, expected, tr.data, state.name(), isr, irr, imr))
        end else begin
            if (tr.addr[0] == 1'b0) begin
                // command port
                if (tr.data[4]) begin
                    // ICW1
                    need_icw3 = ~tr.data[1];
                    need_icw4 = tr.data[0];
                    ltim      = tr.data[3];
                    aeoi      = 1'b0;
                    read_isr  = 1'b0;
                    icw2_vec  = 8'h00;
                    imr       = 8'h00;
                    irr       = 8'h00;
                    isr       = 8'h00;
                    ir_prev   = ir_driven;
                    state     = ST_ICW2;
                end else if (state == ST_READY) begin
                    if (tr.data[3]) begin
                        // OCW3
                        if (tr.data[1]) read_isr = tr.data[0];
                    end else begin
                        // OCW2 - EOI
                        if (tr.data[5]) begin
                            if (tr.data[6])
                                isr[tr.data[2:0]] = 1'b0;
                            else if (|isr)
                                isr[highest_prio(isr)] = 1'b0;
                        end
                    end
                end
            end else begin
                // data port
                case (state)
                    ST_RESET: ;
                    ST_ICW2: begin
                        icw2_vec = tr.data;
                        state = need_icw3 ? ST_ICW3 : (need_icw4 ? ST_ICW4 : ST_READY);
                    end
                    ST_ICW3: begin
                        state = need_icw4 ? ST_ICW4 : ST_READY;
                    end
                    ST_ICW4: begin
                        aeoi  = tr.data[1];
                        state = ST_READY;
                    end
                    ST_READY: begin
                        imr = tr.data;
                    end
                endcase
            end
        end
    endfunction

    // update IR lines and check intr output
    function void update_ir(logic [7:0] ir, logic intr_actual);
        logic [7:0] masked;
        logic       pending_valid;
        logic [2:0] pending_idx;
        logic       isr_valid;
        logic [2:0] isr_idx;
        logic       intr_expected;

        if (ltim)
            irr = ir;
        else
            irr = irr | ((~ir_prev) & ir);
        ir_prev = ir;
        ir_driven = ir;

        masked        = irr & ~imr;
        pending_valid = |masked;
        pending_idx   = highest_prio(masked);
        isr_valid     = |isr;
        isr_idx       = highest_prio(isr);

        intr_expected = (state == ST_READY) && pending_valid && (!isr_valid || (pending_idx < isr_idx));

        if (intr_expected) begin
            irr[pending_idx] = 1'b0;
            if (!aeoi) isr[pending_idx] = 1'b1;
        end

        if (intr_actual !== intr_expected)
            `uvm_error("PIC_INTR",
                $sformatf("o_intr mismatch: exp=%b got=%b (irr=%02h isr=%02h imr=%02h)",
                    intr_expected, intr_actual, irr, isr, imr))
    endfunction

endclass
