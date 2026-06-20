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
//  File        : eeprom_env.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : UVM environment for chip_at24lc32_eeprom
// ============================================================================

class eeprom_env extends uvm_env;

    i2c_agent      agt;
    eeprom_scoreboard sb;

    `uvm_component_utils(eeprom_env)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = i2c_agent::type_id::create("agt", this);
        sb  = eeprom_scoreboard::type_id::create("sb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.mon.mon_ap.connect(sb.mon_export);
    endfunction

    function void reset();
        sb.reset();
    endfunction

endclass
