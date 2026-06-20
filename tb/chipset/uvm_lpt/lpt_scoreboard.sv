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
//  File        : lpt_scoreboard.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Scoreboard for chip_centronics_lpt
// ============================================================================

class lpt_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(lpt_scoreboard)

    uvm_analysis_imp #(isa_transaction, lpt_scoreboard) mon_export;

    bit [ 7: 0] data_reg;
    bit [ 7: 0] ctrl_reg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_export = new("mon_export", this);
    endfunction

    function void reset();
        data_reg = 8'h00;
        ctrl_reg = 8'h0C;
    endfunction

    function void write(isa_transaction tr);
        if (tr.read) begin
            case (tr.addr[2:0])
                3'h0: check_read(tr, data_reg, "DATA");
                3'h1: check_read(tr, 8'hB7, "STATUS");
                3'h2: check_read(tr, ctrl_reg, "CTRL");
                default: check_read(tr, 8'hFF, "INVALID");
            endcase
        end else begin
            case (tr.addr[2:0])
                3'h0: data_reg = tr.data;
                3'h2: ctrl_reg = tr.data;
                default: ;
            endcase
        end
    endfunction

    function void check_read(isa_transaction tr, bit [7:0] expected, string regname);
        if (tr.data !== expected)
            `uvm_error("LPT_MISMATCH",
                $sformatf("read %s addr=%04h: exp=%02h got=%02h",
                    regname, tr.addr, expected, tr.data))
    endfunction

endclass
