// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : isa_monitor.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ISA bus monitor (captures read/write transactions)
// ============================================================================

class isa_monitor extends uvm_monitor;

    virtual isa_if vif;
    uvm_analysis_port #(isa_transaction) mon_ap;

    `uvm_component_utils(isa_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual isa_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "isa_if not set via uvm_config_db")
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            @(vif.mon_cb);
            if (!vif.mon_cb.cs_n && !vif.mon_cb.wr_n)
                capture_write();
            if (!vif.mon_cb.cs_n && !vif.mon_cb.rd_n)
                capture_read();
        end
    endtask

    task capture_write();
        isa_transaction tr;
        tr = isa_transaction::type_id::create("tr_write");
        tr.addr = vif.mon_cb.addr;
        tr.data = vif.mon_cb.d_in;
        tr.read = 1'b0;
        @(vif.mon_cb);
        mon_ap.write(tr);
    endtask

    task capture_read();
        isa_transaction tr;
        tr = isa_transaction::type_id::create("tr_read");
        tr.addr = vif.mon_cb.addr;
        tr.read = 1'b1;
        @(vif.mon_cb);
        tr.data = vif.mon_cb.d_out;
        mon_ap.write(tr);
    endtask

endclass
