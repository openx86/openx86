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
//  File        : lpt_test_smoke.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Smoke test for chip_centronics_lpt
// ============================================================================

class lpt_smoke_test extends lpt_test_base;

    `uvm_component_utils(lpt_smoke_test)

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

        // T1: write data reg (offset 0), read back
        `uvm_info("TEST", "T1: write/read DATA register", UVM_LOW)
        wseq = write_byte_seq::type_id::create("wseq");
        wseq.waddr = 16'h0000;
        wseq.wdata = 8'hA5;
        wseq.start(env.agt.sqr);

        rseq = read_byte_seq::type_id::create("rseq");
        rseq.raddr = 16'h0000;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'hA5)
            `uvm_error("SMOKE", $sformatf("DATA readback exp=A5 got=%02h", rseq.rdata))
        else
            `uvm_info("SMOKE", "DATA register: PASS", UVM_LOW)

        // T2: write ctrl reg (offset 2), read back
        `uvm_info("TEST", "T2: write/read CTRL register", UVM_LOW)
        wseq = write_byte_seq::type_id::create("wseq2");
        wseq.waddr = 16'h0002;
        wseq.wdata = 8'h0F;
        wseq.start(env.agt.sqr);

        rseq = read_byte_seq::type_id::create("rseq2");
        rseq.raddr = 16'h0002;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'h0F)
            `uvm_error("SMOKE", $sformatf("CTRL readback exp=0F got=%02h", rseq.rdata))
        else
            `uvm_info("SMOKE", "CTRL register: PASS", UVM_LOW)

        // T3: read status (offset 1) — hardcoded to 0xB7
        `uvm_info("TEST", "T3: read STATUS register", UVM_LOW)
        rseq = read_byte_seq::type_id::create("rseq3");
        rseq.raddr = 16'h0001;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'hB7)
            `uvm_error("SMOKE", $sformatf("STATUS readback exp=B7 got=%02h", rseq.rdata))
        else
            `uvm_info("SMOKE", "STATUS register: PASS", UVM_LOW)

        // T4: read invalid offset — expect FF
        `uvm_info("TEST", "T4: read invalid offset 0x3", UVM_LOW)
        rseq = read_byte_seq::type_id::create("rseq4");
        rseq.raddr = 16'h0003;
        rseq.start(env.agt.sqr);

        // T5: reset check
        `uvm_info("TEST", "T5: reset check", UVM_LOW)
        vif.rst_n <= 1'b0;
        repeat (5) @(posedge vif.clk);
        vif.rst_n <= 1'b1;
        repeat (5) @(posedge vif.clk);

        rseq = read_byte_seq::type_id::create("rseq5a");
        rseq.raddr = 16'h0000;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'h00)
            `uvm_error("SMOKE", $sformatf("DATA after reset exp=00 got=%02h", rseq.rdata))
        else
            `uvm_info("SMOKE", "DATA reset: PASS", UVM_LOW)

        rseq = read_byte_seq::type_id::create("rseq5b");
        rseq.raddr = 16'h0002;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'h0C)
            `uvm_error("SMOKE", $sformatf("CTRL after reset exp=0C got=%02h", rseq.rdata))
        else
            `uvm_info("SMOKE", "CTRL reset: PASS", UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass
