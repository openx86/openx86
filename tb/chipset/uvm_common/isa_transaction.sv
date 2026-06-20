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
//  File        : isa_transaction.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ISA bus transaction (read/write sequence item)
// ============================================================================

class isa_transaction extends uvm_sequence_item;

    rand bit [15: 0] addr;
    rand bit [ 7: 0] data;
    rand bit         read;
    rand int         delay;

    constraint c_delay {
        delay inside {[0: 10]};
    }

    `uvm_object_utils_begin(isa_transaction)
        `uvm_field_int(addr,  UVM_DEFAULT)
        `uvm_field_int(data,  UVM_DEFAULT)
        `uvm_field_int(read,  UVM_DEFAULT)
        `uvm_field_int(delay, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "isa_transaction");
        super.new(name);
    endfunction

endclass
