// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the conditions:
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : i2c_driver.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : I2C master driver (bit-banged)
// ============================================================================

class i2c_driver extends uvm_driver #(i2c_transaction);

    virtual i2c_if vif;
    int clk_period = 40;  // ns, I2C SCL half-period

    `uvm_component_utils(i2c_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "i2c_if not set")
    endfunction

    task reset_signals();
        vif.scl = 1'b1;
        vif.sda_master_drv = 1'b1;
    endtask

    task run_phase(uvm_phase phase);
        reset_signals();
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_transaction(i2c_transaction tr);
        i2c_start();
        i2c_write_byte({tr.dev_addr, ~tr.rw});  // addr + R/W
        i2c_write_byte(tr.word_addr[15:8]);      // word addr high
        i2c_write_byte(tr.word_addr[7:0]);       // word addr low

        if (tr.rw == i2c_transaction::I2C_WRITE) begin
            for (int i = 0; i < tr.num_bytes; i++) begin
                i2c_write_byte(tr.data_q[i]);
            end
        end else begin
            i2c_start();  // repeated start for read
            i2c_write_byte({tr.dev_addr, 1'b1});  // addr + R
            for (int i = 0; i < tr.num_bytes; i++) begin
                bit [7:0] d;
                i2c_read_byte(d, (i == tr.num_bytes - 1));
                tr.data_q.push_back(d);
            end
        end

        i2c_stop();
    endtask

    task i2c_start();
        vif.sda_master_drv = 1'b1;
        #(clk_period);
        vif.scl = 1'b1;
        #(clk_period);
        vif.sda_master_drv = 1'b0;
        #(clk_period);
        vif.scl = 1'b0;
        #(clk_period);
    endtask

    task i2c_stop();
        vif.sda_master_drv = 1'b0;
        vif.scl = 1'b1;
        #(clk_period);
        vif.sda_master_drv = 1'b1;
        #(clk_period);
    endtask

    task i2c_write_byte(bit [7:0] data);
        for (int i = 7; i >= 0; i--) begin
            vif.sda_master_drv = data[i];
            #(clk_period);
            vif.scl = 1'b1;
            #(clk_period);
            vif.scl = 1'b0;
            #(clk_period);
        end
        // ACK
        vif.sda_master_drv = 1'b1;
        #(clk_period);
        vif.scl = 1'b1;
        #(clk_period);
        if (vif.sda_in !== 1'b0)
            `uvm_warning("I2C_NACK", "Slave did not ACK")
        vif.scl = 1'b0;
        #(clk_period);
    endtask

    task i2c_read_byte(output bit [7:0] data, bit send_nack);
        vif.sda_master_drv = 1'b1;
        data = 8'h00;
        for (int i = 7; i >= 0; i--) begin
            #(clk_period);
            vif.scl = 1'b1;
            #(clk_period);
            data[i] = vif.sda_in;
            vif.scl = 1'b0;
            #(clk_period);
        end
        // ACK/NACK
        vif.sda_master_drv = send_nack ? 1'b1 : 1'b0;
        #(clk_period);
        vif.scl = 1'b1;
        #(clk_period);
        vif.scl = 1'b0;
        #(clk_period);
        vif.sda_master_drv = 1'b1;
    endtask

endclass
