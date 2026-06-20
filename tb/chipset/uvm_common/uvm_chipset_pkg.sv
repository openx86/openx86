// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : uvm_chipset_pkg.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Common UVM package for chipset verification
// ============================================================================

package uvm_chipset_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "isa_transaction.sv"
    `include "isa_sequencer.sv"
    `include "isa_driver.sv"
    `include "isa_monitor.sv"
    `include "isa_agent.sv"
    `include "isa_seq_lib.sv"

endpackage
