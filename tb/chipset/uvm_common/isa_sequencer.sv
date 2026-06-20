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
//  File        : isa_sequencer.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ISA bus sequencer
// ============================================================================

class isa_sequencer extends uvm_sequencer #(isa_transaction);

    `uvm_component_utils(isa_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
