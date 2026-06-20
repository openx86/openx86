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
//  File        : uvm_eeprom_pkg.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : UVM package for chip_at24lc32_eeprom
// ============================================================================

package uvm_eeprom_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "i2c_if.sv"
    `include "i2c_transaction.sv"
    `include "i2c_driver.sv"
    `include "i2c_monitor.sv"
    `include "i2c_agent.sv"
    `include "eeprom_scoreboard.sv"
    `include "eeprom_env.sv"
    `include "eeprom_test_base.sv"
    `include "eeprom_test_smoke.sv"

endpackage
