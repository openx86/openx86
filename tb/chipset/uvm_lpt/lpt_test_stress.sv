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
//  File        : lpt_test_stress.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Stress test for chip_centronics_lpt
// ============================================================================

class lpt_stress_test extends lpt_test_base;

    `uvm_component_utils(lpt_stress_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        random_stress_seq sseq;
        write_read_check_seq wrc;
        int err_count;

        phase.raise_objection(this);
        env.reset();
        @(negedge vif.rst_n);
        @(posedge vif.rst_n);
        repeat (10) @(posedge vif.clk);

        // 200 random bus cycles
        `uvm_info("STRESS", "Starting 200 random bus cycles", UVM_LOW)
        sseq = random_stress_seq::type_id::create("sseq");
        sseq.num_cycles = 200;
        sseq.addr_range = 8;
        sseq.start(env.agt.sqr);

        // bounded random write-read-check
        `uvm_info("STRESS", "Starting 50 write-read-check cycles", UVM_LOW)
        repeat (50) begin
            wrc = write_read_check_seq::type_id::create("wrc");
            if (!wrc.randomize()) begin
                `uvm_error("STRESS", "write_read_check_seq randomization failed")
            end
            wrc.start(env.agt.sqr);
        end

        phase.drop_objection(this);
    endtask

endclass
