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
//  File        : pit_test_smoke.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Smoke test for chip_8254_pit
// ============================================================================

class pit_smoke_test extends pit_test_base;

    `uvm_component_utils(pit_smoke_test)

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

        // T1: control word — counter 0, LSB/MSB, mode 3, binary
        `uvm_info("TEST", "T1: CW ch0 mode3 LSB/MSB", UVM_LOW)
        wseq = write_byte_seq::type_id::create("wseq");
        wseq.waddr = 16'h0003;
        wseq.wdata = 8'b00110110;  // ch0, LSB+MSB, mode3, binary
        wseq.start(env.agt.sqr);

        // T2: write count LOW then HIGH to ch0
        `uvm_info("TEST", "T2: write count 1000 to ch0", UVM_LOW)
        wseq.waddr = 16'h0000;
        wseq.wdata = 8'hE8;  // low byte of 1000
        wseq.start(env.agt.sqr);
        wseq.wdata = 8'h03;  // high byte of 1000
        wseq.start(env.agt.sqr);

        // T3: latch counter 0 and read
        `uvm_info("TEST", "T3: latch+read ch0", UVM_LOW)
        wseq.waddr = 16'h0003;
        wseq.wdata = 8'b00000000;  // latch ch0
        wseq.start(env.agt.sqr);

        rseq = read_byte_seq::type_id::create("rseq");
        rseq.raddr = 16'h0000;
        rseq.start(env.agt.sqr);
        `uvm_info("SMOKE", $sformatf("ch0 latched low  = %02h", rseq.rdata), UVM_LOW)

        rseq.raddr = 16'h0000;
        rseq.start(env.agt.sqr);
        `uvm_info("SMOKE", $sformatf("ch0 latched high = %02h", rseq.rdata), UVM_LOW)

        // T4: counter 1, mode 2, LSB only
        `uvm_info("TEST", "T4: CW ch1 mode2 LSB-only", UVM_LOW)
        wseq.waddr = 16'h0003;
        wseq.wdata = 8'b01010100;  // ch1, LSB, mode2, binary
        wseq.start(env.agt.sqr);

        wseq.waddr = 16'h0001;
        wseq.wdata = 8'h20;  // count = 32
        wseq.start(env.agt.sqr);

        `uvm_info("SMOKE", "PIT smoke test done", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
