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
//  File        : uvm_bios_pkg.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : UVM package for chip_pc_bios_eeprom
// ============================================================================

package uvm_bios_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "bios_if.sv"
    `include "bios_scoreboard.sv"
    `include "bios_env.sv"
    `include "bios_test_base.sv"
    `include "bios_test_smoke.sv"

endpackage
