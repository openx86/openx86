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
//  File        : rtc_test_smoke.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Smoke test for chip_mc146818_rtc
// ============================================================================

class rtc_smoke_test extends rtc_test_base;

    `uvm_component_utils(rtc_smoke_test)

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

        // T1: write index 0x0A (reg A), read back
        `uvm_info("TEST", "T1: reg A index write/read", UVM_LOW)
        wseq = write_byte_seq::type_id::create("wseq");
        wseq.waddr = 16'h0000;  // index port (A0=0)
        wseq.wdata = 8'h0A;     // reg A index
        wseq.start(env.agt.sqr);

        rseq = read_byte_seq::type_id::create("rseq");
        rseq.raddr = 16'h0001;  // data port (A0=1)
        rseq.start(env.agt.sqr);
        `uvm_info("SMOKE", $sformatf("Reg A = %02h", rseq.rdata), UVM_LOW)

        // T2: write reg B with SET bit
        `uvm_info("TEST", "T2: write reg B (SET=1)", UVM_LOW)
        wseq.waddr = 16'h0000;
        wseq.wdata = 8'h0B;
        wseq.start(env.agt.sqr);

        wseq.waddr = 16'h0001;
        wseq.wdata = 8'h82;  // SET=1, DM=0, 24h
        wseq.start(env.agt.sqr);

        rseq.raddr = 16'h0001;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'h82)
            `uvm_error("SMOKE", $sformatf("Reg B exp=82 got=%02h", rseq.rdata))
        else
            `uvm_info("SMOKE", "Reg B write/read: PASS", UVM_LOW)

        // T3: read reg D (VRT bit)
        `uvm_info("TEST", "T3: reg D (VRT)", UVM_LOW)
        wseq.waddr = 16'h0000;
        wseq.wdata = 8'h0D;
        wseq.start(env.agt.sqr);

        rseq.raddr = 16'h0001;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'h80)
            `uvm_error("SMOKE", $sformatf("Reg D exp=80 got=%02h", rseq.rdata))
        else
            `uvm_info("SMOKE", "Reg D VRT: PASS", UVM_LOW)

        // T4: write century register (0x32)
        `uvm_info("TEST", "T4: century register (0x32)", UVM_LOW)
        wseq.waddr = 16'h0000;
        wseq.wdata = 8'h32;
        wseq.start(env.agt.sqr);

        wseq.waddr = 16'h0001;
        wseq.wdata = 8'h20;
        wseq.start(env.agt.sqr);

        rseq.raddr = 16'h0001;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'h20)
            `uvm_error("SMOKE", $sformatf("Century exp=20 got=%02h", rseq.rdata))

        // T5: read reg C (should clear)
        `uvm_info("TEST", "T5: reg C (read-clear)", UVM_LOW)
        wseq.waddr = 16'h0000;
        wseq.wdata = 8'h0C;
        wseq.start(env.agt.sqr);

        rseq.raddr = 16'h0001;
        rseq.start(env.agt.sqr);
        `uvm_info("SMOKE", $sformatf("Reg C = %02h", rseq.rdata), UVM_LOW)

        // Read again — should be 0
        rseq.raddr = 16'h0001;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'h00)
            `uvm_error("SMOKE", $sformatf("Reg C second read exp=00 got=%02h", rseq.rdata))
        else
            `uvm_info("SMOKE", "Reg C read-clear: PASS", UVM_LOW)

        `uvm_info("SMOKE", "RTC smoke test done", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
