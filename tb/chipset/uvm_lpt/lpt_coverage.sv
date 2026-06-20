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
//  File        : lpt_coverage.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Functional coverage for chip_centronics_lpt
// ============================================================================

class lpt_coverage extends uvm_subscriber #(isa_transaction);

    `uvm_component_utils(lpt_coverage)

    covergroup cg_lpt_access;
        ADDR: coverpoint item.addr[2:0] {
            bins data   = {3'h0};
            bins status = {3'h1};
            bins ctrl   = {3'h2};
            bins other  = {3'h3, 3'h4, 3'h5, 3'h6, 3'h7};
        }
        RW: coverpoint item.read {
            bins read  = {1};
            bins write = {0};
        }
        DATA_BYTE: coverpoint item.data {
            bins zero  = {8'h00};
            bins ones  = {8'hFF};
            bins other = default;
        }
        ADDR_X_RW: cross ADDR, RW;
    endgroup

    isa_transaction item;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_lpt_access = new();
    endfunction

    function void write(isa_transaction t);
        item = t;
        cg_lpt_access.sample();
    endfunction

endclass
