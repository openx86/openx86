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
//  File        : dma_coverage.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Functional coverage for chip_8237_dma
// ============================================================================

class dma_coverage extends uvm_subscriber #(isa_transaction);

    `uvm_component_utils(dma_coverage)

    covergroup cg_dma_window;
        WIN: coverpoint get_window(item.addr) {
            bins ch_addr_count = {0};
            bins ctrl          = {1};
            bins page          = {2};
            bins dma16         = {3};
        }
        RW: coverpoint item.read {
            bins read  = {1};
            bins write = {0};
        }
        DATA: coverpoint item.data {
            bins zero  = {8'h00};
            bins ones  = {8'hFF};
            bins pattern = {8'h55, 8'hAA};
            bins other = default;
        }
        WIN_X_RW: cross WIN, RW;
    endgroup

    isa_transaction item;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_dma_window = new();
    endfunction

    function int get_window(bit [15:0] a);
        if (a <= 16'h000F) return (a[3:0] <= 4'h7) ? 0 : 1;
        else if (a >= 16'h0080 && a <= 16'h008F) return 2;
        else if (a >= 16'h00C0 && a <= 16'h00DF) return 3;
        else return -1;
    endfunction

    function void write(isa_transaction t);
        item = t;
        cg_dma_window.sample();
    endfunction

endclass
