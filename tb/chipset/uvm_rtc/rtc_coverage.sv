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
//  File        : rtc_coverage.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Functional coverage for chip_mc146818_rtc
// ============================================================================

class rtc_coverage extends uvm_subscriber #(isa_transaction);

    `uvm_component_utils(rtc_coverage)

    covergroup cg_rtc_access;
        A0: coverpoint item.addr[0] {
            bins index = {0};
            bins data  = {1};
        }
        RW: coverpoint item.read {
            bins read  = {1};
            bins write = {0};
        }
    endgroup

    isa_transaction item;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_rtc_access = new();
    endfunction

    function void write(isa_transaction t);
        item = t;
        cg_rtc_access.sample();
    endfunction

endclass
