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
//  File        : bios_scoreboard.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Scoreboard for chip_pc_bios_eeprom
// ============================================================================

class bios_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(bios_scoreboard)

    bit [ 7:0] ref_mem[0:4095];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void reset();
        for (int i = 0; i < 4096; i++)
            ref_mem[i] = 8'hFF;
    endfunction

    function void preload(int addr, bit [7:0] data);
        if (addr >= 0 && addr < 4096)
            ref_mem[addr] = data;
    endfunction

    function void preload_range(int base, bit [7:0] data[]);
        for (int i = 0; i < data.size() && (base + i) < 4096; i++)
            ref_mem[base + i] = data[i];
    endfunction

    function bit [31:0] expected_sys_read(bit [15:0] off);
        bit [11:0] a0 = off[11:0];
        bit [11:0] a1 = off[11:0] + 1;
        bit [11:0] a2 = off[11:0] + 2;
        bit [11:0] a3 = off[11:0] + 3;
        return {ref_mem[a3], ref_mem[a2], ref_mem[a1], ref_mem[a0]};
    endfunction

    function bit [31:0] expected_ext_read(bit [16:0] off);
        bit [11:0] a0 = off[11:0];
        bit [11:0] a1 = off[11:0] + 1;
        bit [11:0] a2 = off[11:0] + 2;
        bit [11:0] a3 = off[11:0] + 3;
        return {ref_mem[a3], ref_mem[a2], ref_mem[a1], ref_mem[a0]};
    endfunction

endclass
