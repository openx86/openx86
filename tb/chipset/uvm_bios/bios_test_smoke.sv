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
//  File        : bios_test_smoke.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Smoke test for chip_pc_bios_eeprom
// ============================================================================

class bios_smoke_test extends bios_test_base;

    `uvm_component_utils(bios_smoke_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        env.reset();

        // Preload reference model and DUT via backdoor
        env.sb.preload(0, 8'h11);
        env.sb.preload(1, 8'h22);
        env.sb.preload(2, 8'h33);
        env.sb.preload(3, 8'h44);
        env.sb.preload(4092, 8'hAA);
        env.sb.preload(4093, 8'hBB);
        env.sb.preload(4094, 8'hCC);
        env.sb.preload(4095, 8'hDD);

        // Backdoor write to DUT memory
        tb_bios_top.u_dut.mem[0] = 8'h11;
        tb_bios_top.u_dut.mem[1] = 8'h22;
        tb_bios_top.u_dut.mem[2] = 8'h33;
        tb_bios_top.u_dut.mem[3] = 8'h44;
        tb_bios_top.u_dut.mem[4092] = 8'hAA;
        tb_bios_top.u_dut.mem[4093] = 8'hBB;
        tb_bios_top.u_dut.mem[4094] = 8'hCC;
        tb_bios_top.u_dut.mem[4095] = 8'hDD;

        #1;

        // T1: sys window read @0
        `uvm_info("TEST", "T1: sys window @0", UVM_LOW)
        vif.sys_bios_off = 16'h0000;
        #1;
        if (vif.sys_bios_data !== 32'h44332211)
            `uvm_error("SMOKE", $sformatf("sys @0 exp=44332211 got=%08h", vif.sys_bios_data))
        else
            `uvm_info("SMOKE", "sys @0: PASS", UVM_LOW)

        // T2: sys window @4092 (near wrap)
        `uvm_info("TEST", "T2: sys window @4092", UVM_LOW)
        vif.sys_bios_off = 16'h0FFC;
        #1;
        if (vif.sys_bios_data !== 32'hDDCCBBAA)
            `uvm_error("SMOKE", $sformatf("sys @4092 exp=DDCCBBAA got=%08h", vif.sys_bios_data))
        else
            `uvm_info("SMOKE", "sys @4092: PASS", UVM_LOW)

        // T3: ext window @0
        `uvm_info("TEST", "T3: ext window @0", UVM_LOW)
        vif.ext_bios_off = 17'h00000;
        #1;
        if (vif.ext_bios_data !== 32'h44332211)
            `uvm_error("SMOKE", $sformatf("ext @0 exp=44332211 got=%08h", vif.ext_bios_data))
        else
            `uvm_info("SMOKE", "ext @0: PASS", UVM_LOW)

        // T4: ext window @4092 (near wrap)
        `uvm_info("TEST", "T4: ext window @4092", UVM_LOW)
        vif.ext_bios_off = 17'h00FFC;
        #1;
        if (vif.ext_bios_data !== 32'hDDCCBBAA)
            `uvm_error("SMOKE", $sformatf("ext @4092 exp=DDCCBBAA got=%08h", vif.ext_bios_data))
        else
            `uvm_info("SMOKE", "ext @4092: PASS", UVM_LOW)

        // T5: sys window wrap test (address > 4095 wraps)
        `uvm_info("TEST", "T5: sys window wrapping", UVM_LOW)
        vif.sys_bios_off = 16'h1000;  // same as @0 due to 4KiB wrap
        #1;
        if (vif.sys_bios_data !== 32'h44332211)
            `uvm_error("SMOKE", $sformatf("sys @wrap exp=44332211 got=%08h", vif.sys_bios_data))
        else
            `uvm_info("SMOKE", "sys @wrap: PASS", UVM_LOW)

        `uvm_info("SMOKE", "BIOS smoke test done", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
