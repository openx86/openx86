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
//  File        : uart_test_smoke.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Smoke test for chip_ns16550_com
// ============================================================================

class uart_smoke_test extends uart_test_base;

    `uvm_component_utils(uart_smoke_test)

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

        // T1: LCR write (no DLAB)
        `uvm_info("TEST", "T1: LCR = 0x03 (8N1)", UVM_LOW)
        wseq = write_byte_seq::type_id::create("wseq");
        wseq.waddr = 16'h0003;
        wseq.wdata = 8'h03;  // 8N1, DLAB=0
        wseq.start(env.agt.sqr);

        rseq = read_byte_seq::type_id::create("rseq");
        rseq.raddr = 16'h0003;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'h03)
            `uvm_error("SMOKE", $sformatf("LCR exp=03 got=%02h", rseq.rdata))
        else
            `uvm_info("SMOKE", "LCR write/read: PASS", UVM_LOW)

        // T2: DLAB=1, write DLL/DLM
        `uvm_info("TEST", "T2: DLAB=1, write DLL/DLM", UVM_LOW)
        wseq.waddr = 16'h0003;
        wseq.wdata = 8'h83;  // DLAB=1
        wseq.start(env.agt.sqr);

        wseq.waddr = 16'h0000;
        wseq.wdata = 8'h01;  // DLL = 1
        wseq.start(env.agt.sqr);

        wseq.waddr = 16'h0001;
        wseq.wdata = 8'h00;  // DLM = 0
        wseq.start(env.agt.sqr);

        // T3: back to DLAB=0, read RBR (should be 0)
        `uvm_info("TEST", "T3: DLAB=0, read RBR", UVM_LOW)
        wseq.waddr = 16'h0003;
        wseq.wdata = 8'h03;
        wseq.start(env.agt.sqr);

        rseq.raddr = 16'h0000;
        rseq.start(env.agt.sqr);
        `uvm_info("SMOKE", $sformatf("RBR = %02h", rseq.rdata), UVM_LOW)

        // T4: write SCR, read back
        `uvm_info("TEST", "T4: SCR write/read", UVM_LOW)
        wseq.waddr = 16'h0007;
        wseq.wdata = 8'hA5;
        wseq.start(env.agt.sqr);

        rseq.raddr = 16'h0007;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'hA5)
            `uvm_error("SMOKE", $sformatf("SCR exp=A5 got=%02h", rseq.rdata))
        else
            `uvm_info("SMOKE", "SCR write/read: PASS", UVM_LOW)

        `uvm_info("SMOKE", "UART smoke test done", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
