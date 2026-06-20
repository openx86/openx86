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
//  File        : uart_scoreboard.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Scoreboard for chip_ns16550_com
// ============================================================================

class uart_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(uart_scoreboard)

    uvm_analysis_imp #(isa_transaction, uart_scoreboard) mon_export;

    // UART registers
    bit [ 7:0] rbr;
    bit        rbr_valid;
    bit [ 7:0] ier;
    bit [ 7:0] fcr;
    bit [ 7:0] lcr;
    bit [ 7:0] mcr;
    bit [ 7:0] scr;
    bit [ 7:0] dll;
    bit [ 7:0] dlm;

    // derived
    bit        dlab;
    bit        thr_empty;
    bit        tx_empty;
    bit        thre_irq_pending;

    // MSR
    bit [ 3:0] msr_status;
    bit [ 3:0] msr_delta;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_export = new("mon_export", this);
    endfunction

    function void reset();
        rbr       = 8'h00;
        rbr_valid = 1'b0;
        ier       = 8'h00;
        fcr       = 8'h00;
        lcr       = 8'h00;
        mcr       = 8'h00;
        scr       = 8'h00;
        dll       = 8'h01;
        dlm       = 8'h00;
        thr_empty        = 1'b1;
        tx_empty         = 1'b1;
        thre_irq_pending = 1'b1;
        msr_status       = 4'b0000;
        msr_delta        = 4'b0000;
    endfunction

    function bit get_dlab();
        return lcr[7];
    endfunction

    function void write(isa_transaction tr);
        bit [2:0] off = tr.addr[2:0];

        if (tr.read) begin
            bit [7:0] expected;
            if (off == 3'd0)
                expected = get_dlab() ? dll : rbr;
            else if (off == 3'd1)
                expected = get_dlab() ? dlm : ier;
            else if (off == 3'd2) begin
                bit [3:0] iir_code;
                bit       irq_rda   = ier[0] && rbr_valid;
                bit       irq_thre  = ier[1] && thre_irq_pending;
                bit       irq_ms    = ier[3] && (|msr_delta);
                if (irq_rda)       iir_code = 4'b0100;
                else if (irq_thre) iir_code = 4'b0010;
                else if (irq_ms)   iir_code = 4'b0000;
                else               iir_code = 4'b0001;
                expected = {fcr[0] ? 2'b11 : 2'b00, 2'b00, iir_code[3:1], iir_code[0]};
            end else if (off == 3'd3)
                expected = lcr;
            else if (off == 3'd4)
                expected = mcr;
            else if (off == 3'd5)
                expected = {1'b0, tx_empty, thr_empty, 1'b0, 1'b0, 1'b0, 1'b0, rbr_valid};
            else if (off == 3'd6)
                expected = {msr_status, msr_delta};
            else if (off == 3'd7)
                expected = scr;
            else
                expected = 8'hFF;

            if (tr.data !== expected)
                `uvm_error("UART_MISMATCH",
                    $sformatf("read off=%01x exp=%02h got=%02h", off, expected, tr.data))
        end else begin
            if (off == 3'd0) begin
                if (get_dlab()) dll = tr.data;
                else begin
                    thr_empty        = 1'b0;
                    tx_empty         = 1'b0;
                    thre_irq_pending = 1'b0;
                    if (mcr[4]) begin
                        rbr       = tr.data;
                        rbr_valid = 1'b1;
                    end
                end
            end else if (off == 3'd1) begin
                if (get_dlab()) dlm = tr.data;
                else begin
                    ier = {tr.data[7:6], 2'b00, tr.data[3:0]};
                    if (!ier[1] && tr.data[1] && thr_empty)
                        thre_irq_pending = 1'b1;
                end
            end else if (off == 3'd2) begin
                fcr = {(tr.data[0] ? tr.data[7:6] : 2'b00),
                        1'b0, tr.data[4],
                        (tr.data[0] ? tr.data[3] : 1'b0),
                        2'b00, tr.data[0]};
                if (tr.data[0] && tr.data[1]) rbr_valid = 1'b0;
                if (tr.data[0] && tr.data[2]) begin
                    thr_empty        = 1'b1;
                    tx_empty         = 1'b1;
                    thre_irq_pending = 1'b1;
                end
            end else if (off == 3'd3)
                lcr = tr.data;
            else if (off == 3'd4)
                mcr = {3'b000, tr.data[4:0]};
            else if (off == 3'd7)
                scr = tr.data;
        end
    endfunction

    // simulate RX byte injection
    function void inject_rx(bit [7:0] data);
        rbr       = data;
        rbr_valid = 1'b1;
    endfunction

endclass
