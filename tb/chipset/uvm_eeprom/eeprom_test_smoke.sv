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
//  File        : eeprom_test_smoke.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Smoke test for chip_at24lc32_eeprom
// ============================================================================

class eeprom_smoke_test extends eeprom_test_base;

    `uvm_component_utils(eeprom_smoke_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        i2c_transaction tr;

        phase.raise_objection(this);
        env.reset();

        // T1: page write 8 bytes to 0x0000
        `uvm_info("TEST", "T1: page write 8 bytes @0x0000", UVM_LOW)
        tr = i2c_transaction::type_id::create("tr1");
        tr.dev_addr  = 7'b1010000;
        tr.rw        = i2c_transaction::I2C_WRITE;
        tr.word_addr = 16'h0000;
        tr.num_bytes = 8;
        for (int i = 0; i < 8; i++)
            tr.data_q.push_back(8'(i + 1));
        tr.start(env.agt.sqr);

        // T2: random read from 0x0000
        `uvm_info("TEST", "T2: random read @0x0000", UVM_LOW)
        tr = i2c_transaction::type_id::create("tr2");
        tr.dev_addr  = 7'b1010000;
        tr.rw        = i2c_transaction::I2C_READ;
        tr.word_addr = 16'h0000;
        tr.num_bytes = 8;
        tr.start(env.agt.sqr);

        for (int i = 0; i < tr.data_q.size(); i++) begin
            if (tr.data_q[i] !== 8'(i + 1))
                `uvm_error("SMOKE", $sformatf("Read byte %0d exp=%02h got=%02h",
                    i, 8'(i+1), tr.data_q[i]))
        end
        `uvm_info("SMOKE", "Page write/read: PASS", UVM_LOW)

        // T3: page write across boundary (test page wrap)
        `uvm_info("TEST", "T3: page write across page boundary", UVM_LOW)
        tr = i2c_transaction::type_id::create("tr3");
        tr.dev_addr  = 7'b1010000;
        tr.rw        = i2c_transaction::I2C_WRITE;
        tr.word_addr = 16'h001E;  // near page end (32-byte page = 0x00-0x1F)
        tr.num_bytes = 8;
        tr.data_q   = {8'hAA, 8'hBB, 8'hCC, 8'hDD, 8'hEE, 8'hFF, 8'h11, 8'h22};
        tr.start(env.agt.sqr);

        `uvm_info("SMOKE", "EEPROM smoke test done", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
