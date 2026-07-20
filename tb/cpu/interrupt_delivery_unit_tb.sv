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
//  File        : interrupt_delivery_unit_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : INT delivery test with mock IDT gate in memory
// ============================================================================

`timescale 1ns/1ns

`include "openx86_defs.h.sv"

module interrupt_delivery_unit_tb;

    localparam logic [31: 0] LP_IDTR_BASE    = 32'h0000_1000;
    localparam logic [15: 0] LP_IDTR_LIMIT   = 16'h0FFF;
    localparam logic [ 7: 0] LP_VECTOR       = 8'h21;
    localparam logic [31: 0] LP_GATE_ADDR    = LP_IDTR_BASE + {24'd0, LP_VECTOR, 3'b000};
    localparam logic [31: 0] LP_HANDLER_EIP  = 32'h0000_5000;
    localparam logic [15: 0] LP_HANDLER_CS   = 16'h0010;
    localparam logic [31: 0] LP_SAVED_EIP    = 32'h0000_0100;
    localparam logic [15: 0] LP_SAVED_CS     = 16'h0008;
    localparam logic [31: 0] LP_SAVED_ESP    = 32'h0000_9000;
    localparam logic [31: 0] LP_SAVED_EFLAGS = 32'h0000_0202;
    localparam logic [31: 0] LP_NEW_ESP      = 32'h0000_A000;

    logic         clk;
    logic         rst_n;
    logic         start;
    logic         is_iret;
    logic         is_external;
    logic [ 7: 0] vector;
    logic         has_error_code;
    logic [31: 0] error_code;
    logic [31: 0] saved_eip;
    logic [15: 0] saved_cs_selector;
    logic [31: 0] saved_eflags;
    logic [31: 0] saved_esp;
    logic [31: 0] idtr_base;
    logic [15: 0] idtr_limit;
    logic         inta_vector_valid;
    logic [ 7: 0] inta_vector;
    logic [ 1: 0] cpl;
    logic [ 1: 0] gate_dpl;
    logic         need_stack_switch;
    logic [15: 0] new_ss;
    logic [31: 0] new_esp;
    logic [15: 0] current_ss;
    logic         busy;
    logic         inta_req;
    logic         done;
    logic         flush_pipeline;
    logic         clear_if;
    logic         new_eip_valid;
    logic [31: 0] new_eip;
    logic         new_cs_valid;
    logic [15: 0] new_cs_selector;
    logic         esp_write_enable;
    logic [31: 0] esp_write_data;
    logic         eflags_write_enable;
    logic [31: 0] eflags_write_data;
    logic         mem_valid;
    logic         mem_ready;
    logic         mem_write_enable;
    logic [31: 0] mem_address;
    logic [31: 0] mem_write_data;
    logic [31: 0] mem_rdata;

    logic [31: 0] mem [0: 16383];
    logic         mem_ready_r;
    int           pass_count;
    int           wait_timeout;

    always #1 clk = ~clk;

    assign mem_rdata         = mem[mem_address >> 2];
    assign mem_ready         = mem_ready_r;
    assign inta_vector       = 8'h21;
    assign inta_vector_valid = inta_req;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            mem_ready_r <= 1'b0;
        end else begin
            // One-cycle delayed ready; deassert after accept so master can issue next beat
            mem_ready_r <= mem_valid & ~mem_ready_r;
            if (mem_valid & mem_ready_r & mem_write_enable) begin
                mem[mem_address >> 2] <= mem_write_data;
            end
        end
    end

    interrupt_delivery_unit dut (
        .i_start                (start),
        .i_is_iret              (is_iret),
        .i_is_external          (is_external),
        .i_vector               (vector),
        .i_has_error_code       (has_error_code),
        .i_error_code           (error_code),
        .i_saved_eip            (saved_eip),
        .i_saved_cs_selector    (saved_cs_selector),
        .i_saved_eflags         (saved_eflags),
        .i_saved_esp            (saved_esp),
        .i_idtr_base            (idtr_base),
        .i_idtr_limit           (idtr_limit),
        .i_inta_vector_valid    (inta_vector_valid),
        .i_inta_vector          (inta_vector),
        .i_cpl                  (cpl),
        .i_gate_dpl             (gate_dpl),
        .i_need_stack_switch    (need_stack_switch),
        .i_new_ss               (new_ss),
        .i_new_esp              (new_esp),
        .i_current_ss           (current_ss),
        .o_busy                 (busy),
        .o_inta_req             (inta_req),
        .o_done                 (done),
        .o_flush_pipeline       (flush_pipeline),
        .o_clear_if             (clear_if),
        .o_new_eip_valid        (new_eip_valid),
        .o_new_eip              (new_eip),
        .o_new_cs_valid         (new_cs_valid),
        .o_new_cs_selector      (new_cs_selector),
        .o_esp_write_enable     (esp_write_enable),
        .o_esp_write_data       (esp_write_data),
        .o_eflags_write_enable  (eflags_write_enable),
        .o_eflags_write_data    (eflags_write_data),
        .o_mem_valid            (mem_valid),
        .i_mem_ready            (mem_ready),
        .o_mem_write_enable     (mem_write_enable),
        .o_mem_address          (mem_address),
        .o_mem_write_data       (mem_write_data),
        .i_mem_rdata            (mem_rdata),
        .clk                    (clk),
        .rst_n                  (rst_n)
    );

    task automatic wait_done();
        begin
            wait_timeout = 0;
            while (~done) begin
                @(posedge clk);
                wait_timeout++;
                if (wait_timeout > 10000) begin
                    $display("FAIL timeout waiting for done busy=%b mem_valid=%b mem_ready=%b state=%0d",
                             busy, mem_valid, mem_ready, dut.state);
                    $finish(1);
                end
            end
            // Sample pulse outputs on the done cycle (do not wait an extra clock first)
        end
    endtask

    initial begin
        clk               = 1'b0;
        rst_n             = 1'b0;
        start             = 1'b0;
        is_iret           = 1'b0;
        is_external       = 1'b0;
        vector            = LP_VECTOR;
        has_error_code    = 1'b0;
        error_code        = 32'h0;
        saved_eip         = LP_SAVED_EIP;
        saved_cs_selector = LP_SAVED_CS;
        saved_eflags      = LP_SAVED_EFLAGS;
        saved_esp         = LP_SAVED_ESP;
        idtr_base         = LP_IDTR_BASE;
        idtr_limit        = LP_IDTR_LIMIT;
        cpl               = 2'b00;
        gate_dpl          = 2'b00;
        need_stack_switch = 1'b0;
        new_ss            = 16'h0;
        new_esp           = 32'h0;
        current_ss        = 16'h0018;
        pass_count        = 0;

        // Interrupt gate: lo={sel,off15:0}, hi={off31:16, attr=0x8E, reserved=0}
        mem[LP_GATE_ADDR >> 2]           = {LP_HANDLER_CS, LP_HANDLER_EIP[15: 0]};
        mem[(LP_GATE_ADDR + 32'd4) >> 2] = {LP_HANDLER_EIP[31: 16], 8'h8E, 8'h00};

        repeat (4) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
        wait_done();

        if (new_eip !== LP_HANDLER_EIP) begin
            $display("FAIL handler EIP got %h expected %h", new_eip, LP_HANDLER_EIP);
            $finish(1);
        end
        if (new_cs_selector !== LP_HANDLER_CS) begin
            $display("FAIL handler CS got %h expected %h", new_cs_selector, LP_HANDLER_CS);
            $finish(1);
        end
        if (~clear_if) begin
            $display("FAIL interrupt gate did not clear IF clear_if_r=%b gate_type=%h gate_hi=%h",
                     dut.clear_if_r, dut.gate_type, dut.gate_hi_r);
            $finish(1);
        end
        if (mem[(LP_SAVED_ESP - 32'd4) >> 2] !== LP_SAVED_EFLAGS) begin
            $display("FAIL stack EFLAGS got %h", mem[(LP_SAVED_ESP - 32'd4) >> 2]);
            $finish(1);
        end
        if (mem[(LP_SAVED_ESP - 32'd8) >> 2] !== {16'h0, LP_SAVED_CS}) begin
            $display("FAIL stack CS got %h", mem[(LP_SAVED_ESP - 32'd8) >> 2]);
            $finish(1);
        end
        if (mem[(LP_SAVED_ESP - 32'd12) >> 2] !== LP_SAVED_EIP) begin
            $display("FAIL stack EIP got %h", mem[(LP_SAVED_ESP - 32'd12) >> 2]);
            $finish(1);
        end
        pass_count++;
        @(posedge clk);

        mem[(LP_SAVED_ESP - 32'd12) >> 2] = LP_HANDLER_EIP;
        mem[(LP_SAVED_ESP - 32'd8) >> 2]  = {16'h0, LP_HANDLER_CS};
        mem[(LP_SAVED_ESP - 32'd4) >> 2]  = LP_SAVED_EFLAGS;
        saved_esp = LP_SAVED_ESP - 32'd12;
        is_iret   = 1'b1;
        start     = 1'b1;
        @(posedge clk);
        start = 1'b0;
        wait_done();

        if (new_eip !== LP_HANDLER_EIP) begin
            $display("FAIL IRET EIP got %h", new_eip);
            $finish(1);
        end
        if (new_cs_selector !== LP_HANDLER_CS) begin
            $display("FAIL IRET CS got %h", new_cs_selector);
            $finish(1);
        end
        if (esp_write_data !== LP_SAVED_ESP) begin
            $display("FAIL IRET ESP got %h expected %h", esp_write_data, LP_SAVED_ESP);
            $finish(1);
        end
        pass_count++;

        // Privilege stack switch: push old SS:ESP onto new stack before frame
        need_stack_switch = 1'b1;
        new_ss            = 16'h0020;
        new_esp           = LP_NEW_ESP;
        current_ss        = 16'h0018;
        saved_esp         = LP_SAVED_ESP;
        is_iret           = 1'b0;
        start             = 1'b1;
        @(posedge clk);
        start = 1'b0;
        wait_done();

        if (mem[(LP_NEW_ESP - 32'd4) >> 2] !== {16'h0, 16'h0018}) begin
            $display("FAIL stack-switch old SS got %h", mem[(LP_NEW_ESP - 32'd4) >> 2]);
            $finish(1);
        end
        if (mem[(LP_NEW_ESP - 32'd8) >> 2] !== LP_SAVED_ESP) begin
            $display("FAIL stack-switch old ESP got %h", mem[(LP_NEW_ESP - 32'd8) >> 2]);
            $finish(1);
        end
        if (esp_write_data !== (LP_NEW_ESP - 32'd20)) begin
            // SS+ESP+EFLAGS+CS+EIP = 5 dwords
            $display("FAIL stack-switch new ESP got %h", esp_write_data);
            $finish(1);
        end
        pass_count++;

        $display("PASS interrupt_delivery_unit_tb pass_count=%0d", pass_count);
        $finish;
    end

endmodule
