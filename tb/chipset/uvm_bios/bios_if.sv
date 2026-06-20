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
//  File        : bios_if.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Interface for chip_pc_bios_eeprom read ports
// ============================================================================

interface bios_if ();

    logic [15: 0] sys_bios_off;
    logic [31: 0] sys_bios_data;
    logic [16: 0] ext_bios_off;
    logic [31: 0] ext_bios_data;

endinterface
