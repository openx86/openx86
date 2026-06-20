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
//  File        : eeprom_scoreboard.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Scoreboard for chip_at24lc32_eeprom
// ============================================================================

class eeprom_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(eeprom_scoreboard)

    uvm_analysis_imp #(i2c_transaction, eeprom_scoreboard) mon_export;

    bit [ 7:0] mem[0:4095];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_export = new("mon_export", this);
    endfunction

    function void reset();
        for (int i = 0; i < 4096; i++)
            mem[i] = 8'hFF;
    endfunction

    function void preload(bit [7:0] data[]);
        for (int i = 0; i < data.size() && i < 4096; i++)
            mem[i] = data[i];
    endfunction

    function void write(i2c_transaction tr);
        if (tr.rw == i2c_transaction::I2C_WRITE) begin
            bit [15:0] addr = tr.word_addr;
            bit [15:0] page_base = addr & ~(32-1);

            for (int i = 0; i < tr.data_q.size(); i++) begin
                bit [15:0] a = page_base + ((addr - page_base + i) % 32);
                if (a < 4096)
                    mem[a] = tr.data_q[i];
            end
            `uvm_info("EEPROM_SB", $sformatf("write %0d bytes @%04h", tr.data_q.size(), tr.word_addr), UVM_MEDIUM)
        end
    endfunction

    function bit [7:0] read_byte(bit [15:0] addr);
        if (addr < 4096)
            return mem[addr];
        else
            return 8'hFF;
    endfunction

endclass
