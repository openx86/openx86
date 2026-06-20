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
//  File        : dma_test_smoke.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Smoke test for chip_8237_dma
// ============================================================================

class dma_smoke_test extends dma_test_base;

    `uvm_component_utils(dma_smoke_test)

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

        // T1: channel 0 addr low then high (first/last FF toggling)
        `uvm_info("TEST", "T1: CH0 addr LOW then HIGH", UVM_LOW)
        wseq = write_byte_seq::type_id::create("wseq");
        wseq.waddr = 16'h0000; wseq.wdata = 8'h34;
        wseq.start(env.agt.sqr);
        wseq.waddr = 16'h0000; wseq.wdata = 8'h12;
        wseq.start(env.agt.sqr);

        rseq = read_byte_seq::type_id::create("rseq");
        rseq.raddr = 16'h0000;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'h34)
            `uvm_error("SMOKE", $sformatf("CH0 addr low exp=34 got=%02h", rseq.rdata))

        rseq.raddr = 16'h0000;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'h12)
            `uvm_error("SMOKE", $sformatf("CH0 addr high exp=12 got=%02h", rseq.rdata))

        // T2: channel 1 count
        `uvm_info("TEST", "T2: CH1 count LOW then HIGH", UVM_LOW)
        wseq.waddr = 16'h0003; wseq.wdata = 8'h00;
        wseq.start(env.agt.sqr);
        wseq.waddr = 16'h0003; wseq.wdata = 8'h01;
        wseq.start(env.agt.sqr);

        // T3: mask register
        `uvm_info("TEST", "T3: mask channel 2", UVM_LOW)
        wseq.waddr = 16'h000A; wseq.wdata = 8'b00000110;
        wseq.start(env.agt.sqr);

        rseq.raddr = 16'h000A;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'h04)
            `uvm_error("SMOKE", $sformatf("MASK exp=04 got=%02h", rseq.rdata))

        // T4: master clear
        `uvm_info("TEST", "T4: master clear", UVM_LOW)
        wseq.waddr = 16'h000D; wseq.wdata = 8'h00;
        wseq.start(env.agt.sqr);

        rseq.raddr = 16'h000A;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'h0F)
            `uvm_error("SMOKE", $sformatf("MASK after mclr exp=0F got=%02h", rseq.rdata))

        // T5: page register
        `uvm_info("TEST", "T5: page register 0x80", UVM_LOW)
        wseq.waddr = 16'h0080; wseq.wdata = 8'h5A;
        wseq.start(env.agt.sqr);

        rseq.raddr = 16'h0080;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'h5A)
            `uvm_error("SMOKE", $sformatf("PAGE_REG exp=5A got=%02h", rseq.rdata))

        // T6: clear first/last FF
        `uvm_info("TEST", "T6: clear FF then write CH0 addr", UVM_LOW)
        wseq.waddr = 16'h000C; wseq.wdata = 8'h00;
        wseq.start(env.agt.sqr);
        wseq.waddr = 16'h0000; wseq.wdata = 8'h78;
        wseq.start(env.agt.sqr);

        rseq.raddr = 16'h0000;
        rseq.start(env.agt.sqr);
        if (rseq.rdata !== 8'h78)
            `uvm_error("SMOKE", $sformatf("CH0 addr low after FF clear exp=78 got=%02h", rseq.rdata))

        `uvm_info("SMOKE", "DMA smoke test done", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
