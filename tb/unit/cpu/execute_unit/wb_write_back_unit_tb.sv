`timescale 1ns/1ns

module wb_write_back_unit_tb;
    logic        i_gpr_write_enable;
    logic [ 2:0] i_gpr_write_index;
    logic [31:0] i_gpr_write_data;
    logic        o_gpr_write_enable;
    logic [ 2:0] o_gpr_write_index;
    logic [31:0] o_gpr_write_data;

    logic        i_sreg_write_enable;
    logic [ 2:0] i_sreg_write_index;
    logic [15:0] i_sreg_write_selector;
    logic [63:0] i_sreg_write_descriptor;
    logic        o_sreg_write_enable;
    logic [ 2:0] o_sreg_write_index;
    logic [15:0] o_sreg_write_selector;
    logic [63:0] o_sreg_write_descriptor;

    logic        i_flags_write_enable;
    logic [31:0] i_flags_write_data;
    logic        o_flags_write_enable;
    logic [31:0] o_flags_write_data;

    logic        i_ip_write_enable;
    logic [31:0] i_ip_write_data;
    logic        o_ip_write_enable;
    logic [31:0] o_ip_write_data;

    logic        i_cr_write_enable;
    logic [ 2:0] i_cr_write_index;
    logic [31:0] i_cr_write_data;
    logic        o_cr_write_enable;
    logic [ 2:0] o_cr_write_index;
    logic [31:0] o_cr_write_data;

    logic        i_dr_write_enable;
    logic [ 2:0] i_dr_write_index;
    logic [31:0] i_dr_write_data;
    logic        o_dr_write_enable;
    logic [ 2:0] o_dr_write_index;
    logic [31:0] o_dr_write_data;

    logic        i_tr_write_enable;
    logic [ 2:0] i_tr_write_index;
    logic [31:0] i_tr_write_data;
    logic        o_tr_write_enable;
    logic [ 2:0] o_tr_write_index;
    logic [31:0] o_tr_write_data;

    logic        i_mem_valid;
    logic        i_mem_write_enable;
    logic [31:0] i_mem_address;
    logic [31:0] i_mem_write_data;
    logic        o_mem_valid;
    logic        o_mem_write_enable;
    logic [31:0] o_mem_address;
    logic [31:0] o_mem_write_data;

    stage_5_wrb_wb_write_back_unit u_dut (
        .i_gpr_write_enable(i_gpr_write_enable),
        .i_gpr_write_index(i_gpr_write_index),
        .i_gpr_write_data(i_gpr_write_data),
        .o_gpr_write_enable(o_gpr_write_enable),
        .o_gpr_write_index(o_gpr_write_index),
        .o_gpr_write_data(o_gpr_write_data),
        .i_sreg_write_enable(i_sreg_write_enable),
        .i_sreg_write_index(i_sreg_write_index),
        .i_sreg_write_selector(i_sreg_write_selector),
        .i_sreg_write_descriptor(i_sreg_write_descriptor),
        .o_sreg_write_enable(o_sreg_write_enable),
        .o_sreg_write_index(o_sreg_write_index),
        .o_sreg_write_selector(o_sreg_write_selector),
        .o_sreg_write_descriptor(o_sreg_write_descriptor),
        .i_flags_write_enable(i_flags_write_enable),
        .i_flags_write_data(i_flags_write_data),
        .o_flags_write_enable(o_flags_write_enable),
        .o_flags_write_data(o_flags_write_data),
        .i_ip_write_enable(i_ip_write_enable),
        .i_ip_write_data(i_ip_write_data),
        .o_ip_write_enable(o_ip_write_enable),
        .o_ip_write_data(o_ip_write_data),
        .i_cr_write_enable(i_cr_write_enable),
        .i_cr_write_index(i_cr_write_index),
        .i_cr_write_data(i_cr_write_data),
        .o_cr_write_enable(o_cr_write_enable),
        .o_cr_write_index(o_cr_write_index),
        .o_cr_write_data(o_cr_write_data),
        .i_dr_write_enable(i_dr_write_enable),
        .i_dr_write_index(i_dr_write_index),
        .i_dr_write_data(i_dr_write_data),
        .o_dr_write_enable(o_dr_write_enable),
        .o_dr_write_index(o_dr_write_index),
        .o_dr_write_data(o_dr_write_data),
        .i_tr_write_enable(i_tr_write_enable),
        .i_tr_write_index(i_tr_write_index),
        .i_tr_write_data(i_tr_write_data),
        .o_tr_write_enable(o_tr_write_enable),
        .o_tr_write_index(o_tr_write_index),
        .o_tr_write_data(o_tr_write_data),
        .i_mem_valid(i_mem_valid),
        .i_mem_write_enable(i_mem_write_enable),
        .i_mem_address(i_mem_address),
        .i_mem_write_data(i_mem_write_data),
        .o_mem_valid(o_mem_valid),
        .o_mem_write_enable(o_mem_write_enable),
        .o_mem_address(o_mem_address),
        .o_mem_write_data(o_mem_write_data)
    );

    initial begin
        i_gpr_write_enable = 1'b1;
        i_gpr_write_index = 3'd2;
        i_gpr_write_data = 32'hA5A5_5A5A;
        i_sreg_write_enable = 1'b1;
        i_sreg_write_index = 3'd3;
        i_sreg_write_selector = 16'h0010;
        i_sreg_write_descriptor = 64'h1122_3344_5566_7788;
        i_flags_write_enable = 1'b1;
        i_flags_write_data = 32'h0000_0246;
        i_ip_write_enable = 1'b1;
        i_ip_write_data = 32'h0000_1000;
        i_cr_write_enable = 1'b1;
        i_cr_write_index = 3'd0;
        i_cr_write_data = 32'h8000_0011;
        i_dr_write_enable = 1'b1;
        i_dr_write_index = 3'd1;
        i_dr_write_data = 32'hDEAD_BEEF;
        i_tr_write_enable = 1'b1;
        i_tr_write_index = 3'd6;
        i_tr_write_data = 32'hCAFE_BABE;
        i_mem_valid = 1'b1;
        i_mem_write_enable = 1'b1;
        i_mem_address = 32'h0000_2000;
        i_mem_write_data = 32'h1234_5678;

        #1;

        if (!o_gpr_write_enable || o_gpr_write_index != 3'd2 || o_gpr_write_data != 32'hA5A5_5A5A) begin
            $display("FAIL wb gpr");
            $finish(1);
        end

        if (!o_mem_valid || !o_mem_write_enable || o_mem_address != 32'h0000_2000 || o_mem_write_data != 32'h1234_5678) begin
            $display("FAIL wb mem");
            $finish(1);
        end

        $display("wb_write_back_unit_tb PASS");
        $finish;
    end

endmodule
