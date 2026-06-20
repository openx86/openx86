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
//  File        : pic_test_smoke.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Smoke test for chip_8259_pic
// ============================================================================

class pic_smoke_test extends pic_test_base;

    `uvm_component_utils(pic_smoke_test)

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

        // T1: ICW1 (command port) -> ICW2 -> ICW4 -> READY
        `uvm_info("TEST", "T1: ICW init sequence (single, ICW4)", UVM_LOW)
        wseq = write_byte_seq::type_id::create("wseq");
        wseq.waddr = 16'h0000;  // command port
        wseq.wdata = 8'b00010001;  // ICW1: ICW4=1, SNGL=1, edge
        wseq.start(env.agt.sqr);

        wseq.waddr = 16'h0001;  // data port (now ICW2)
        wseq.wdata = 8'b00001000;  // vector base = 08h
        wseq.start(env.agt.sqr);

        wseq.waddr = 16'h0001;  // data port (now ICW4)
        wseq.wdata = 8'b00000011;  // 8086 mode, AEOI=0
        wseq.start(env.agt.sqr);

        // Now in ST_READY

        // T2: write IMR
        `uvm_info("TEST", "T2: write IMR, read back", UVM_LOW)
        wseq.waddr = 16'h0001;
        wseq.wdata = 8'hF0;
        wseq.start(env.agt.sqr);

        rseq = read_byte_seq::type_id::create("rseq");
        rseq.raddr = 16'h0001;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'hF0)
            `uvm_error("SMOKE", $sformatf("IMR readback exp=F0 got=%02h", rseq.rdata))
        else
            `uvm_info("SMOKE", "IMR write/read: PASS", UVM_LOW)

        // T3: OCW3 select IRR, read
        `uvm_info("TEST", "T3: OCW3 select IRR, read IRR", UVM_LOW)
        wseq.waddr = 16'h0000;
        wseq.wdata = 8'b00001010;  // OCW3: read IRR
        wseq.start(env.agt.sqr);

        rseq.raddr = 16'h0000;
        rseq.start(env.agt.sqr);
        `uvm_info("SMOKE", $sformatf("IRR = %02h", rseq.rdata), UVM_LOW)

        // T4: OCW3 select ISR, read
        `uvm_info("TEST", "T4: OCW3 select ISR, read ISR", UVM_LOW)
        wseq.waddr = 16'h0000;
        wseq.wdata = 8'b00001011;  // OCW3: read ISR
        wseq.start(env.agt.sqr);

        rseq.raddr = 16'h0000;
        rseq.start(env.agt.sqr);
        `uvm_info("SMOKE", $sformatf("ISR = %02h", rseq.rdata), UVM_LOW)

        `uvm_info("SMOKE", "PIC smoke test done", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
