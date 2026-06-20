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
//  File        : pit_coverage.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Functional coverage for chip_8254_pit
// ============================================================================

class pit_coverage extends uvm_subscriber #(isa_transaction);

    `uvm_component_utils(pit_coverage)

    covergroup cg_pit_access;
        CH: coverpoint item.addr[1:0] {
            bins cnt0  = {2'h0};
            bins cnt1  = {2'h1};
            bins cnt2  = {2'h2};
            bins ctrl  = {2'h3};
        }
        RW: coverpoint item.read {
            bins read  = {1};
            bins write = {0};
        }
        CTRL_BYTE: coverpoint item.data;
    endgroup

    isa_transaction item;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_pit_access = new();
    endfunction

    function void write(isa_transaction t);
        item = t;
        cg_pit_access.sample();
    endfunction

endclass
