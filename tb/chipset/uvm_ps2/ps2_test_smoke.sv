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
//  File        : ps2_test_smoke.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Smoke test for chip_i8042_ps2
// ============================================================================

class ps2_smoke_test extends ps2_test_base;

    `uvm_component_utils(ps2_smoke_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        write_byte_seq wseq;
        read_byte_seq  rseq;

        phase.raise_objection(this);
        env.reset();
        @(negedge vif.rst_n);
        @(posedge vif.rst_n);
        repeat (10) @(posedge vif.clk);

        // T1: read status port
        `uvm_info("TEST", "T1: read status", UVM_LOW)
        rseq = read_byte_seq::type_id::create("rseq");
        rseq.raddr = 16'h0001;  // 0x64 (A0=1)
        rseq.start(env.agt.sqr);
        `uvm_info("SMOKE", $sformatf("Status = %02h", rseq.rdata), UVM_LOW)

        // T2: disable kbd interface (command AD)
        `uvm_info("TEST", "T2: disable kbd interface", UVM_LOW)
        wseq = write_byte_seq::type_id::create("wseq");
        wseq.waddr = 16'h0001;  // command port
        wseq.wdata = 8'hAD;     // disable kbd
        wseq.start(env.agt.sqr);

        // T3: re-enable kbd interface (command AE)
        `uvm_info("TEST", "T3: enable kbd interface", UVM_LOW)
        wseq.waddr = 16'h0001;
        wseq.wdata = 8'hAE;
        wseq.start(env.agt.sqr);

        // T4: read data port (should be 0 — FIFO empty)
        `uvm_info("TEST", "T4: read data port (empty FIFO)", UVM_LOW)
        rseq.raddr = 16'h0000;  // data port
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'h00)
            `uvm_error("SMOKE", $sformatf("Data port (empty) exp=00 got=%02h", rseq.rdata))
        else
            `uvm_info("SMOKE", "Empty readback: PASS", UVM_LOW)

        // T5: write data port (simulate keyboard output)
        `uvm_info("TEST", "T5: write keyboard data via D2 cmd", UVM_LOW)
        wseq.waddr = 16'h0001;
        wseq.wdata = 8'hD2;  // write output buffer to keyboard
        wseq.start(env.agt.sqr);

        wseq.waddr = 16'h0000;
        wseq.wdata = 8'hAA;  // BAT completion code
        wseq.start(env.agt.sqr);

        // Read back
        rseq.raddr = 16'h0000;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'hAA)
            `uvm_error("SMOKE", $sformatf("KBD data exp=AA got=%02h", rseq.rdata))
        else
            `uvm_info("SMOKE", "KBD write/read data: PASS", UVM_LOW)

        `uvm_info("SMOKE", "PS2 smoke test done", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
