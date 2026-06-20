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
//  File        : i2c_if.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : I2C bus interface (open-drain model with pull-up)
// ============================================================================

interface i2c_if ();

    logic scl;
    logic sda_master_drv;  // driven by master (0 = pull low, 1 = release)
    logic sda_slave_drv;   // driven by slave via o_sda_oe
    logic sda_in;          // sampled value (pull-up when nobody drives low)

    // open-drain with pull-up
    assign scl = scl;
    assign sda_in = (sda_master_drv === 1'b0 || sda_slave_drv === 1'b0) ? 1'b0 : 1'b1;

endinterface
