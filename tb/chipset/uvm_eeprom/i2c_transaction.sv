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
//  File        : i2c_transaction.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : I2C bus transaction
// ============================================================================

class i2c_transaction extends uvm_sequence_item;

    typedef enum { I2C_READ, I2C_WRITE } rw_e;

    rand rw_e        rw;
    rand bit [ 6: 0] dev_addr;
    rand bit [15: 0] word_addr;
    rand bit [ 7: 0] data_q[$];
    rand int         num_bytes;

    constraint c_dev_addr { dev_addr inside {7'b1010_xxx}; }
    constraint c_num_bytes { num_bytes inside {[1: 32]}; }

    `uvm_object_utils_begin(i2c_transaction)
        `uvm_field_enum(rw_e, rw, UVM_DEFAULT)
        `uvm_field_int(dev_addr, UVM_DEFAULT)
        `uvm_field_int(word_addr, UVM_DEFAULT)
        `uvm_field_queue_int(data_q, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "i2c_transaction");
        super.new(name);
    endfunction

endclass
