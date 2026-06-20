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
//  File        : uvm_dma_pkg.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : UVM package for chip_8237_dma
// ============================================================================

package uvm_dma_pkg;

    import uvm_pkg::*;
    import uvm_chipset_pkg::*;
    `include "uvm_macros.svh"

    `include "dma_scoreboard.sv"
    `include "dma_coverage.sv"
    `include "dma_env.sv"
    `include "dma_test_base.sv"
    `include "dma_test_smoke.sv"
    `include "dma_test_stress.sv"

endpackage
