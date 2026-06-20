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
//  File        : pit_test_base.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Base test for chip_8254_pit
// ============================================================================

class pit_test_base extends uvm_test;

    pit_env env;
    virtual isa_if vif;

    `uvm_component_utils(pit_test_base)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = pit_env::type_id::create("env", this);
        if (!uvm_config_db#(virtual isa_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "isa_if not set via uvm_config_db")
        uvm_config_db#(virtual isa_if)::set(this, "env.agt.*", "vif", vif);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        env.reset();
        @(negedge vif.rst_n);
        @(posedge vif.rst_n);
        repeat (10) @(posedge vif.clk);
        phase.drop_objection(this);
    endtask

    function void report_phase(uvm_phase phase);
        uvm_report_server svr;
        svr = uvm_report_server::get_server();
        if (svr.get_severity_count(UVM_ERROR) == 0)
            `uvm_info("RESULT", "*** TEST PASSED ***", UVM_LOW)
        else
            `uvm_info("RESULT", "*** TEST FAILED ***", UVM_LOW)
    endfunction

endclass
