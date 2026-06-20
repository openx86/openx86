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
//  File        : isa_seq_lib.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Common ISA bus sequences
// ============================================================================

// ------------------------------------------------
// write_byte_seq — write single byte to addr
// ------------------------------------------------
class write_byte_seq extends uvm_sequence #(isa_transaction);

    rand bit [15: 0] waddr;
    rand bit [ 7: 0] wdata;

    `uvm_object_utils(write_byte_seq)
    `uvm_declare_p_sequencer(isa_sequencer)

    function new(string name = "write_byte_seq");
        super.new(name);
    endfunction

    task body();
        isa_transaction tr;
        tr = isa_transaction::type_id::create("tr");
        tr.addr = waddr;
        tr.data = wdata;
        tr.read = 1'b0;
        tr.delay = 0;
        start_item(tr);
        finish_item(tr);
    endtask

endclass

// ------------------------------------------------
// read_byte_seq — read single byte from addr
// ------------------------------------------------
class read_byte_seq extends uvm_sequence #(isa_transaction);

    rand bit [15: 0] raddr;
    bit    [ 7: 0]   rdata;

    `uvm_object_utils(read_byte_seq)
    `uvm_declare_p_sequencer(isa_sequencer)

    function new(string name = "read_byte_seq");
        super.new(name);
    endfunction

    task body();
        isa_transaction tr;
        tr = isa_transaction::type_id::create("tr");
        tr.addr = raddr;
        tr.read = 1'b1;
        tr.delay = 0;
        start_item(tr);
        finish_item(tr);
        rdata = tr.data;
    endtask

endclass

// ------------------------------------------------
// write_read_check_seq — write then read back & compare
// ------------------------------------------------
class write_read_check_seq extends uvm_sequence #(isa_transaction);

    rand bit [15: 0] waddr;
    rand bit [ 7: 0] wdata;
    bit              match;

    `uvm_object_utils(write_read_check_seq)
    `uvm_declare_p_sequencer(isa_sequencer)

    function new(string name = "write_read_check_seq");
        super.new(name);
    endfunction

    task body();
        isa_transaction tr_w, tr_r;
        // write
        tr_w = isa_transaction::type_id::create("tr_w");
        tr_w.addr = waddr;
        tr_w.data = wdata;
        tr_w.read = 1'b0;
        tr_w.delay = 0;
        start_item(tr_w);
        finish_item(tr_w);
        // read
        tr_r = isa_transaction::type_id::create("tr_r");
        tr_r.addr = waddr;
        tr_r.read = 1'b1;
        tr_r.delay = 0;
        start_item(tr_r);
        finish_item(tr_r);
        match = (tr_r.data == wdata);
        if (!match)
            `uvm_error("MISMATCH", $sformatf("addr=%04h wrote=%02h read=%02h", waddr, wdata, tr_r.data))
    endtask

endclass

// ------------------------------------------------
// burst_write_seq — sequential writes to addr range
// ------------------------------------------------
class burst_write_seq extends uvm_sequence #(isa_transaction);

    rand bit [15: 0] base_addr;
    rand int         num_bytes;
    rand bit [ 7: 0] data_q[$];

    constraint c_num_bytes {
        num_bytes inside {[1: 64]};
    }

    `uvm_object_utils(burst_write_seq)
    `uvm_declare_p_sequencer(isa_sequencer)

    function new(string name = "burst_write_seq");
        super.new(name);
    endfunction

    task body();
        isa_transaction tr;
        data_q = {};
        for (int i = 0; i < num_bytes; i++) begin
            tr = isa_transaction::type_id::create($sformatf("tr_%0d", i));
            tr.addr = base_addr + i;
            tr.data = $urandom_range(8'h00, 8'hFF);
            tr.read = 1'b0;
            tr.delay = 0;
            data_q.push_back(tr.data);
            start_item(tr);
            finish_item(tr);
        end
    endtask

endclass

// ------------------------------------------------
// burst_read_check_seq — read back & compare to expected
// ------------------------------------------------
class burst_read_check_seq extends uvm_sequence #(isa_transaction);

    rand bit [15: 0] base_addr;
    rand int         num_bytes;
    rand bit [ 7: 0] expected_q[$];

    constraint c_num_bytes {
        num_bytes == expected_q.size();
        num_bytes inside {[1: 64]};
    }

    `uvm_object_utils(burst_read_check_seq)
    `uvm_declare_p_sequencer(isa_sequencer)

    function new(string name = "burst_read_check_seq");
        super.new(name);
    endfunction

    task body();
        isa_transaction tr;
        for (int i = 0; i < num_bytes; i++) begin
            tr = isa_transaction::type_id::create($sformatf("tr_%0d", i));
            tr.addr = base_addr + i;
            tr.read = 1'b1;
            tr.delay = 0;
            start_item(tr);
            finish_item(tr);
            if (tr.data !== expected_q[i])
                `uvm_error("BURST_MISMATCH", $sformatf("addr=%04h exp=%02h got=%02h",
                    base_addr + i, expected_q[i], tr.data))
        end
    endtask

endclass

// ------------------------------------------------
// random_stress_seq — random mix of read/write cycles
// ------------------------------------------------
class random_stress_seq extends uvm_sequence #(isa_transaction);

    rand int         num_cycles;
    rand bit [15: 0] addr_range;

    constraint c_num_cycles {
        num_cycles inside {[50: 200]};
    }
    constraint c_addr_range {
        addr_range inside {[4: 64]};
    }

    `uvm_object_utils(random_stress_seq)
    `uvm_declare_p_sequencer(isa_sequencer)

    function new(string name = "random_stress_seq");
        super.new(name);
    endfunction

    task body();
        isa_transaction tr;
        repeat (num_cycles) begin
            tr = isa_transaction::type_id::create("tr");
            tr.addr = $urandom_range(0, addr_range - 1);
            tr.data = $urandom_range(8'h00, 8'hFF);
            tr.read = $urandom;
            tr.delay = $urandom_range(0, 5);
            start_item(tr);
            finish_item(tr);
        end
    endtask

endclass
