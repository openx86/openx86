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
//  File        : uvm_lpt_pkg.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : UVM package for chip_centronics_lpt
// ============================================================================

package uvm_lpt_pkg;

    import uvm_pkg::*;
    import uvm_chipset_pkg::*;
    `include "uvm_macros.svh"

    `include "lpt_scoreboard.sv"
    `include "lpt_coverage.sv"
    `include "lpt_env.sv"
    `include "lpt_test_base.sv"
    `include "lpt_test_smoke.sv"
    `include "lpt_test_stress.sv"

endpackage
