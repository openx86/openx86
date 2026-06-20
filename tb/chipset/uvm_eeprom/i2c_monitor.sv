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
//  File        : i2c_monitor.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : I2C bus monitor
// ============================================================================

class i2c_monitor extends uvm_monitor;

    virtual i2c_if vif;
    uvm_analysis_port #(i2c_transaction) mon_ap;

    `uvm_component_utils(i2c_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "i2c_if not set")
    endfunction

    task run_phase(uvm_phase phase);
        i2c_transaction tr;
        bit [ 7:0] byte_val;
        bit        rw;
        int        bit_cnt;

        forever begin
            @(posedge vif.scl);

            // START detection
            if (vif.scl && !vif.sda_in) begin
                tr = i2c_transaction::type_id::create("tr");
                // receive device addr + RW
                byte_val = 0;
                repeat (8) begin
                    @(posedge vif.scl);
                    byte_val = {byte_val[6:0], vif.sda_in};
                end
                tr.dev_addr = byte_val[7:1];
                rw = byte_val[0];
                // ACK
                @(negedge vif.scl);
                @(posedge vif.scl);

                if (rw == 0) begin
                    // write: word addr high, word addr low, then data
                    repeat (2) begin
                        byte_val = 0;
                        repeat (8) begin
                            @(posedge vif.scl);
                            byte_val = {byte_val[6:0], vif.sda_in};
                        end
                        if (tr.word_addr == 16'h0000)
                            tr.word_addr = {tr.word_addr[7:0], byte_val};
                        else
                            tr.word_addr = {tr.word_addr[15:8], byte_val};
                        @(negedge vif.scl);
                        @(posedge vif.scl);
                    end
                    tr.rw = i2c_transaction::I2C_WRITE;
                    // data bytes until STOP
                    while (1) begin
                        byte_val = 0;
                        repeat (8) begin
                            @(posedge vif.scl);
                            byte_val = {byte_val[6:0], vif.sda_in};
                        end
                        tr.data_q.push_back(byte_val);
                        @(negedge vif.scl);
                        @(posedge vif.scl);
                        // check for STOP condition
                        fork
                            begin
                                @(posedge vif.scl);
                                if (vif.scl && vif.sda_in) break;
                            end
                            begin
                                @(negedge vif.scl);
                            end
                        join_any;
                        disable fork;
                    end
                    mon_ap.write(tr);
                end
            end
        end
    endtask

endclass
