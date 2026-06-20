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
//  File        : bios_env.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : UVM environment for chip_pc_bios_eeprom
// ============================================================================

class bios_env extends uvm_env;

    bios_scoreboard sb;

    `uvm_component_utils(bios_env)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb = bios_scoreboard::type_id::create("sb", this);
    endfunction

    function void reset();
        sb.reset();
    endfunction

endclass
