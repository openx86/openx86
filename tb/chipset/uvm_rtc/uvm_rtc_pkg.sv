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
//  File        : uvm_rtc_pkg.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : UVM package for chip_mc146818_rtc
// ============================================================================

package uvm_rtc_pkg;

    import uvm_pkg::*;
    import uvm_chipset_pkg::*;
    `include "uvm_macros.svh"

    `include "rtc_scoreboard.sv"
    `include "rtc_coverage.sv"
    `include "rtc_env.sv"
    `include "rtc_test_base.sv"
    `include "rtc_test_smoke.sv"

endpackage
