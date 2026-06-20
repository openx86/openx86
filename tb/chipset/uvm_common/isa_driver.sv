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
//  File        : isa_driver.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ISA bus driver (drives CPU bus cycles)
// ============================================================================

class isa_driver extends uvm_driver #(isa_transaction);

    virtual isa_if vif;

    `uvm_component_utils(isa_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual isa_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "isa_if not set via uvm_config_db")
    endfunction

    task reset_signals();
        vif.drv_cb.cs_n <= 1;
        vif.drv_cb.rd_n <= 1;
        vif.drv_cb.wr_n <= 1;
        vif.drv_cb.addr <= '0;
        vif.drv_cb.d_in <= '0;
    endtask

    task run_phase(uvm_phase phase);
        reset_signals();
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_transaction(isa_transaction tr);
        repeat (tr.delay) @(vif.drv_cb);
        if (tr.read)
            read_cycle(tr.addr, tr.data);
        else
            write_cycle(tr.addr, tr.data);
    endtask

    task write_cycle(bit [15: 0] addr, bit [7: 0] data);
        @(vif.drv_cb);
        vif.drv_cb.addr <= addr;
        vif.drv_cb.d_in <= data;
        vif.drv_cb.cs_n <= 1'b0;
        vif.drv_cb.wr_n <= 1'b0;
        @(vif.drv_cb);
        vif.drv_cb.cs_n <= 1'b1;
        vif.drv_cb.wr_n <= 1'b1;
    endtask

    task read_cycle(bit [15: 0] addr, output bit [7: 0] data);
        @(vif.drv_cb);
        vif.drv_cb.addr <= addr;
        vif.drv_cb.cs_n <= 1'b0;
        vif.drv_cb.rd_n <= 1'b0;
        @(vif.drv_cb);
        data = vif.drv_cb.d_out;
        vif.drv_cb.cs_n <= 1'b1;
        vif.drv_cb.rd_n <= 1'b1;
    endtask

endclass
