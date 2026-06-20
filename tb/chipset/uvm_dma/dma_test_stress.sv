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
//  File        : dma_test_stress.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Stress test for chip_8237_dma
// ============================================================================

class dma_stress_test extends dma_test_base;

    `uvm_component_utils(dma_stress_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        random_stress_seq sseq;

        phase.raise_objection(this);
        env.reset();
        @(negedge vif.rst_n);
        @(posedge vif.rst_n);
        repeat (10) @(posedge vif.clk);

        `uvm_info("STRESS", "Starting 300 random DMA cycles", UVM_LOW)
        sseq = random_stress_seq::type_id::create("sseq");
        sseq.num_cycles = 300;
        sseq.addr_range = 256;
        sseq.start(env.agt.sqr);

        phase.drop_objection(this);
    endtask

endclass
