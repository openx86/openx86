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
//  File        : pic_coverage.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Functional coverage for chip_8259_pic
// ============================================================================

class pic_coverage extends uvm_subscriber #(isa_transaction);

    `uvm_component_utils(pic_coverage)

    covergroup cg_pic_access;
        A0: coverpoint item.addr[0];
        RW: coverpoint item.read {
            bins read  = {1};
            bins write = {0};
        }
        DATA: coverpoint item.data {
            bins icw1     = {8'b00010001};  // ICW1 with ICW4
            bins ocw2_eoi = {8'b00100000};  // non-specific EOI
            bins ocw3_irr = {8'b00001010};  // read IRR
            bins ocw3_isr = {8'b00001011};  // read ISR
            bins other    = default;
        }
        A0_X_RW: cross A0, RW;
    endgroup

    isa_transaction item;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_pic_access = new();
    endfunction

    function void write(isa_transaction t);
        item = t;
        cg_pic_access.sample();
    endfunction

endclass
