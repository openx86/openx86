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
//  File        : segment_load_unit.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : FSM to load segment descriptors from GDT/LDT via memory bus
// ============================================================================

`include "openx86_defs.h.sv"

module segment_load_unit (
    // =========================
    // load request
    // =========================
    input  logic         i_valid,
    output logic         o_ready,
    input  logic [ 1: 0] i_op_type,
    input  logic         i_protected_mode,
    input  logic [ 1: 0] i_cpl,
    input  logic [15: 0] i_selector,
    input  logic [ 2: 0] i_target_seg_index,
    input  logic [31: 0] i_gdtr_base,
    input  logic [15: 0] i_gdtr_limit,
    input  logic [15: 0] i_ldtr_selector,
    input  logic [63: 0] i_ldtr_descriptor,
    input  logic [31: 0] i_far_offset,
    input  logic [15: 0] i_far_selector,

    // =========================
    // segment register writeback
    // =========================
    output logic         o_seg_write_enable,
    output logic [ 2: 0] o_seg_write_index,
    output logic [15: 0] o_seg_write_selector,
    output logic [63: 0] o_seg_write_descriptor,
    output logic         o_ip_write_enable,
    output logic [31: 0] o_ip_write_data,

    // =========================
    // fault outputs
    // =========================
    output logic         o_segment_not_present,
    output logic         o_stack_segment_fault,
    output logic         o_segment_fault,

    // =========================
    // memory bus for descriptor reads
    // =========================
    output logic         o_bus_valid,
    input  logic         i_bus_ready,
    output logic         o_bus_write_enable,
    output logic [31: 0] o_bus_address,
    input  logic [31: 0] i_bus_data_read,
    output logic [31: 0] o_bus_data_write,

    // =========================
    // clock and reset
    // =========================
    input  logic         clk,
    input  logic         rst_n
);

    localparam logic [ 1: 0] LP_OP_MOV_SEG   = 2'b00;
    localparam logic [ 1: 0] LP_OP_FAR_JMP  = 2'b01;
    localparam logic [ 1: 0] LP_OP_FAR_CALL = 2'b10;
    localparam logic [ 1: 0] LP_OP_FAR_RET  = 2'b11;

    typedef enum logic [ 2: 0] {
        STATE_IDLE,
        STATE_READ_DESC_LO,
        STATE_READ_DESC_HI,
        STATE_READ_RET_LO,
        STATE_READ_RET_HI,
        STATE_DONE
    } seg_load_state_e;

    seg_load_state_e state;

    logic         i_valid_r;
    logic         i_valid_rise;
    logic [ 1: 0] latched_op_type;
    logic [ 1: 0] latched_cpl;
    logic [15: 0] latched_selector;
    logic [ 2: 0] latched_target_seg_index;
    logic [31: 0] latched_gdtr_base;
    logic [15: 0] latched_gdtr_limit;
    logic [63: 0] latched_ldtr_descriptor;
    logic [31: 0] latched_far_offset;

    logic [31: 0] ldtr_base;
    logic [19: 0] ldtr_limit;
    logic [31: 0] table_base;
    logic [15: 0] table_limit;
    logic [12: 0] selector_index;
    logic         selector_ti;
    logic [ 1: 0] selector_rpl;
    logic [31: 0] descriptor_addr;
    logic [31: 0] desc_lo_r;
    logic [31: 0] desc_hi_r;
    logic [31: 0] desc_hi_next;
    logic [31: 0] ret_offset_r;
    logic [63: 0] assembled_descriptor;
    logic [63: 0] assembled_descriptor_next;

    logic         fault_np_r;
    logic         fault_ss_r;
    logic         fault_gp_r;
    logic         seg_write_enable_r;
    logic [ 2: 0] seg_write_index_r;
    logic [15: 0] seg_write_selector_r;
    logic [63: 0] seg_write_descriptor_r;
    logic         ip_write_enable_r;
    logic [31: 0] ip_write_data_r;

    logic [31: 0] dec_base;
    logic [19: 0] dec_limit;
    logic         dec_present;
    logic [ 1: 0] dec_dpl;
    logic         dec_segment_type;
    logic         dec_executable;
    logic         dec_writeable;
    logic         dec_readable;
    logic         dec_conforming;

    logic [ 1: 0] effective_privilege;
    logic         is_target_cs;
    logic         is_target_ss;
    logic         is_far_control;
    logic         load_cs;
    logic         entry_selector_fault_ss;
    logic         entry_selector_fault_gp;
    logic [15: 0] entry_selector;
    logic [ 2: 0] entry_target;
    logic         descriptor_valid;
    logic         descriptor_fault_np;
    logic         descriptor_fault_ss;
    logic         descriptor_fault_gp;

    logic         dec_unused_b;
    logic [ 1: 0] dec_unused_dpl;
    logic [31: 0] cache_base_unused;
    logic [31: 0] cache_limit_unused;
    logic [ 1: 0] cache_present_unused;
    logic         cache_bit_unused;

    assign i_valid_rise = i_valid & ~i_valid_r;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            i_valid_r <= 1'b0;
        end else begin
            i_valid_r <= i_valid;
        end
    end

    assign selector_index = latched_selector[15: 3];
    assign selector_ti    = latched_selector[2];
    assign selector_rpl   = latched_selector[1: 0];

    segment_descriptor_decode u_ldtr_descriptor_decode (
        .o_base                                (ldtr_base),
        .o_limit                               (ldtr_limit),
        .o_date_or_code_present                (dec_unused_b),
        .o_date_or_code_privilege_level        (dec_unused_dpl),
        .o_available_field                     (dec_unused_b),
        .o_segment_type                        (dec_unused_b),
        .o_date_or_code_granularity            (dec_unused_b),
        .o_date_or_code_default_operation_size (dec_unused_b),
        .o_date_or_code_executable             (dec_unused_b),
        .o_data_expansion_direction            (dec_unused_b),
        .o_data_writeable                      (dec_unused_b),
        .o_code_conforming                     (dec_unused_b),
        .o_code_readable                       (dec_unused_b),
        .o_date_or_code_accessed               (dec_unused_b),
        .i_descriptor                          (latched_ldtr_descriptor)
    );

    assign table_base  = selector_ti ? ldtr_base : latched_gdtr_base;
    assign table_limit = selector_ti ? ldtr_limit[15: 0] : latched_gdtr_limit;
    assign descriptor_addr = table_base + (32'(selector_index) << 3);

    assign assembled_descriptor = {
        desc_lo_r[31: 16],
        desc_lo_r[15:  0],
        desc_hi_r[31: 24],
        desc_hi_r[23: 16],
        desc_hi_r[15:  8],
        desc_hi_r[ 7:  0]
    };

    assign desc_hi_next = i_bus_data_read;
    assign assembled_descriptor_next = {
        desc_lo_r[31: 16],
        desc_lo_r[15:  0],
        desc_hi_next[31: 24],
        desc_hi_next[23: 16],
        desc_hi_next[15:  8],
        desc_hi_next[ 7:  0]
    };

    assign is_target_cs   = (latched_target_seg_index == `sreg_index_CS);
    assign is_target_ss   = (latched_target_seg_index == `sreg_index_SS);
    assign is_far_control = (latched_op_type == LP_OP_FAR_JMP) |
                            (latched_op_type == LP_OP_FAR_CALL) |
                            (latched_op_type == LP_OP_FAR_RET);
    assign load_cs        = is_far_control | is_target_cs;

    assign effective_privilege = (latched_cpl > selector_rpl) ? latched_cpl : selector_rpl;

    segment_descriptor_decode u_segment_descriptor_decode (
        .o_base                                (dec_base),
        .o_limit                               (dec_limit),
        .o_date_or_code_present                (dec_present),
        .o_date_or_code_privilege_level        (dec_dpl),
        .o_available_field                     (dec_unused_b),
        .o_segment_type                        (dec_segment_type),
        .o_date_or_code_granularity            (dec_unused_b),
        .o_date_or_code_default_operation_size (dec_unused_b),
        .o_date_or_code_executable             (dec_executable),
        .o_data_expansion_direction            (dec_unused_b),
        .o_data_writeable                      (dec_writeable),
        .o_code_conforming                     (dec_conforming),
        .o_code_readable                       (dec_readable),
        .o_date_or_code_accessed               (dec_unused_b),
        .i_descriptor                          (assembled_descriptor_next)
    );

    segment_descriptor_cache u_segment_descriptor_cache (
        .i_protect_enable      (i_protected_mode),
        .i_segment_selector    (latched_selector),
        .i_segment_descriptor  (assembled_descriptor_next),
        .i_is_code_segment     (load_cs),
        .i_write_data          (16'h0),
        .i_write_enable        (1'b0),
        .o_read_data           (cache_bit_unused),
        .o_base                (cache_base_unused),
        .o_limit               (cache_limit_unused),
        .o_present             (cache_present_unused),
        .o_privilege_level     (cache_bit_unused),
        .o_accessed            (cache_bit_unused),
        .o_granularity         (cache_bit_unused),
        .o_expansion_direction (cache_bit_unused),
        .o_readable            (cache_bit_unused),
        .o_writeable           (cache_bit_unused),
        .o_executable          (cache_bit_unused),
        .o_stack_size          (cache_bit_unused),
        .o_conforming_privilege(cache_bit_unused)
    );

    function automatic void check_selector_faults(
        input  logic [15: 0] sel,
        input  logic [ 2: 0] target,
        input  logic [ 1: 0] op,
        input  logic [31: 0] tbl_base_in,
        input  logic [15: 0] tbl_limit_in,
        output logic         ss_fault,
        output logic         gp_fault
    );
        logic [12: 0] idx;
        logic         sel_null;
        logic         out_of_bounds;
        begin
            ss_fault = 1'b0;
            gp_fault = 1'b0;
            if (~i_protected_mode) begin
                return;
            end
            idx            = sel[15: 3];
            sel_null       = (sel[15: 3] == 13'b0);
            out_of_bounds  = ({3'b0, idx, 3'b0} > {1'b0, tbl_limit_in});
            if ((op == LP_OP_MOV_SEG) && (target == `sreg_index_CS)) begin
                gp_fault = 1'b1;
            end else if ((target == `sreg_index_SS) && sel_null) begin
                ss_fault = 1'b1;
            end else if (((op != LP_OP_MOV_SEG) || (target == `sreg_index_CS)) && sel_null &&
                         ((op == LP_OP_FAR_JMP) || (op == LP_OP_FAR_CALL) || (op == LP_OP_FAR_RET) ||
                          (target == `sreg_index_CS))) begin
                gp_fault = 1'b1;
            end else if (out_of_bounds) begin
                if (target == `sreg_index_SS) begin
                    ss_fault = 1'b1;
                end else begin
                    gp_fault = 1'b1;
                end
            end
        end
    endfunction

    logic [31: 0] entry_tbl_base;
    logic [15: 0] entry_tbl_limit;
    logic [31: 0] entry_ldtr_base;
    logic [19: 0] entry_ldtr_limit;
    logic         entry_ldtr_unused_b;
    logic [ 1: 0] entry_ldtr_unused_dpl;

    segment_descriptor_decode u_entry_ldtr_decode (
        .o_base                                (entry_ldtr_base),
        .o_limit                               (entry_ldtr_limit),
        .o_date_or_code_present                (entry_ldtr_unused_b),
        .o_date_or_code_privilege_level        (entry_ldtr_unused_dpl),
        .o_available_field                     (entry_ldtr_unused_b),
        .o_segment_type                        (entry_ldtr_unused_b),
        .o_date_or_code_granularity            (entry_ldtr_unused_b),
        .o_date_or_code_default_operation_size (entry_ldtr_unused_b),
        .o_date_or_code_executable             (entry_ldtr_unused_b),
        .o_data_expansion_direction            (entry_ldtr_unused_b),
        .o_data_writeable                      (entry_ldtr_unused_b),
        .o_code_conforming                     (entry_ldtr_unused_b),
        .o_code_readable                       (entry_ldtr_unused_b),
        .o_date_or_code_accessed               (entry_ldtr_unused_b),
        .i_descriptor                          (i_ldtr_descriptor)
    );

    always_comb begin
        entry_selector = (i_op_type == LP_OP_MOV_SEG) ? i_selector : i_far_selector;
        entry_target   = ((i_op_type == LP_OP_FAR_JMP) || (i_op_type == LP_OP_FAR_CALL) ||
                            (i_op_type == LP_OP_FAR_RET)) ? `sreg_index_CS : i_target_seg_index;
        // Use current (not latched) GDTR/LDTR so the rise-edge check sees this request
        entry_tbl_base  = entry_selector[2] ? entry_ldtr_base : i_gdtr_base;
        entry_tbl_limit = entry_selector[2] ? entry_ldtr_limit[15: 0] : i_gdtr_limit;
        check_selector_faults(entry_selector, entry_target, i_op_type,
                              entry_tbl_base, entry_tbl_limit,
                              entry_selector_fault_ss, entry_selector_fault_gp);
    end

    always_comb begin
        descriptor_fault_np = 1'b0;
        descriptor_fault_ss = 1'b0;
        descriptor_fault_gp = 1'b0;
        descriptor_valid    = 1'b0;
        if (~i_protected_mode) begin
            descriptor_valid = 1'b1;
        end else if (~dec_present) begin
            descriptor_fault_np = 1'b1;
        end else if (~dec_segment_type) begin
            descriptor_fault_gp = 1'b1;
        end else if (load_cs) begin
            if (~dec_executable) begin
                descriptor_fault_gp = 1'b1;
            end else if (~dec_conforming && (dec_dpl > latched_cpl)) begin
                descriptor_fault_gp = 1'b1;
            end
        end else if (is_target_ss) begin
            if (dec_executable || ~dec_writeable) begin
                descriptor_fault_ss = 1'b1;
            end else if ((latched_cpl != dec_dpl) || (selector_rpl != latched_cpl)) begin
                descriptor_fault_ss = 1'b1;
            end
        end else begin
            if (dec_executable) begin
                if (~dec_readable) begin
                    descriptor_fault_gp = 1'b1;
                end
            end else if (effective_privilege > dec_dpl) begin
                descriptor_fault_gp = 1'b1;
            end
        end
        if (~(descriptor_fault_np | descriptor_fault_ss | descriptor_fault_gp)) begin
            descriptor_valid = 1'b1;
        end
    end

    always_comb begin
        o_bus_write_enable = 1'b0;
        o_bus_data_write   = 32'h0;
        o_bus_valid        = 1'b0;
        o_bus_address      = 32'h0;
        unique case (state)
            STATE_READ_DESC_LO: begin
                o_bus_valid   = 1'b1;
                o_bus_address = descriptor_addr;
            end
            STATE_READ_DESC_HI: begin
                o_bus_valid   = 1'b1;
                o_bus_address = descriptor_addr + 32'd4;
            end
            STATE_READ_RET_LO: begin
                o_bus_valid   = 1'b1;
                o_bus_address = latched_far_offset;
            end
            STATE_READ_RET_HI: begin
                o_bus_valid   = 1'b1;
                o_bus_address = latched_far_offset + 32'd4;
            end
            default: begin
                o_bus_valid   = 1'b0;
                o_bus_address = 32'h0;
            end
        endcase
    end

    assign o_seg_write_enable     = seg_write_enable_r;
    assign o_seg_write_index      = seg_write_index_r;
    assign o_seg_write_selector   = seg_write_selector_r;
    assign o_seg_write_descriptor = seg_write_descriptor_r;
    assign o_ip_write_enable      = ip_write_enable_r;
    assign o_ip_write_data        = ip_write_data_r;
    assign o_segment_not_present  = fault_np_r;
    assign o_stack_segment_fault  = fault_ss_r;
    assign o_segment_fault        = fault_gp_r;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state                    <= STATE_IDLE;
            o_ready                  <= 1'b0;
            latched_op_type          <= LP_OP_MOV_SEG;
            latched_cpl              <= 2'b00;
            latched_selector         <= 16'h0;
            latched_target_seg_index <= 3'b0;
            latched_gdtr_base        <= 32'h0;
            latched_gdtr_limit       <= 16'h0;
            latched_ldtr_descriptor  <= 64'h0;
            latched_far_offset       <= 32'h0;
            desc_lo_r                <= 32'h0;
            desc_hi_r                <= 32'h0;
            ret_offset_r             <= 32'h0;
            fault_np_r               <= 1'b0;
            fault_ss_r               <= 1'b0;
            fault_gp_r               <= 1'b0;
            seg_write_enable_r       <= 1'b0;
            seg_write_index_r        <= 3'b0;
            seg_write_selector_r     <= 16'h0;
            seg_write_descriptor_r   <= 64'h0;
            ip_write_enable_r        <= 1'b0;
            ip_write_data_r          <= 32'h0;
        end else begin
            o_ready <= 1'b0;
            unique case (state)
                STATE_IDLE: begin
                    if (i_valid_rise) begin
                        // Drop previous completion strobes when a new request starts
                        seg_write_enable_r       <= 1'b0;
                        ip_write_enable_r        <= 1'b0;
                        fault_np_r               <= 1'b0;
                        fault_ss_r               <= 1'b0;
                        fault_gp_r               <= 1'b0;
                        latched_op_type          <= i_op_type;
                        latched_cpl              <= i_cpl;
                        latched_target_seg_index <= i_target_seg_index;
                        latched_gdtr_base        <= i_gdtr_base;
                        latched_gdtr_limit       <= i_gdtr_limit;
                        latched_ldtr_descriptor  <= i_ldtr_descriptor;
                        latched_far_offset       <= i_far_offset;
                        if (i_op_type == LP_OP_FAR_RET) begin
                            latched_selector         <= i_far_selector;
                            latched_target_seg_index <= `sreg_index_CS;
                            state                    <= STATE_READ_RET_LO;
                        end else if ((i_op_type == LP_OP_FAR_JMP) || (i_op_type == LP_OP_FAR_CALL)) begin
                            latched_selector         <= i_far_selector;
                            latched_target_seg_index <= `sreg_index_CS;
                            if (entry_selector_fault_gp || entry_selector_fault_ss) begin
                                fault_gp_r <= entry_selector_fault_gp;
                                fault_ss_r <= entry_selector_fault_ss;
                                state      <= STATE_DONE;
                            end else if (~i_protected_mode) begin
                                seg_write_selector_r   <= i_far_selector;
                                seg_write_descriptor_r <= 64'h0;
                                seg_write_index_r      <= `sreg_index_CS;
                                seg_write_enable_r     <= 1'b1;
                                ip_write_data_r        <= i_far_offset;
                                ip_write_enable_r      <= 1'b1;
                                state                  <= STATE_DONE;
                            end else begin
                                state <= STATE_READ_DESC_LO;
                            end
                        end else begin
                            latched_selector         <= i_selector;
                            latched_target_seg_index <= i_target_seg_index;
                            if (entry_selector_fault_gp || entry_selector_fault_ss) begin
                                fault_gp_r <= entry_selector_fault_gp;
                                fault_ss_r <= entry_selector_fault_ss;
                                state      <= STATE_DONE;
                            end else if (~i_protected_mode) begin
                                seg_write_selector_r   <= i_selector;
                                seg_write_descriptor_r <= 64'h0;
                                seg_write_index_r      <= i_target_seg_index;
                                seg_write_enable_r     <= 1'b1;
                                state                  <= STATE_DONE;
                            end else if ((i_selector[15: 3] == 13'b0) && (i_target_seg_index != `sreg_index_SS)) begin
                                seg_write_selector_r   <= 16'h0;
                                seg_write_descriptor_r <= 64'h0;
                                seg_write_index_r      <= i_target_seg_index;
                                seg_write_enable_r     <= 1'b1;
                                state                  <= STATE_DONE;
                            end else begin
                                state <= STATE_READ_DESC_LO;
                            end
                        end
                    end
                end
                STATE_READ_DESC_LO: begin
                    if (i_bus_ready) begin
                        desc_lo_r <= i_bus_data_read;
                        state     <= STATE_READ_DESC_HI;
                    end
                end
                STATE_READ_DESC_HI: begin
                    if (i_bus_ready) begin
                        desc_hi_r <= i_bus_data_read;
                        if (descriptor_valid) begin
                            seg_write_selector_r   <= latched_selector;
                            seg_write_descriptor_r <= assembled_descriptor_next;
                            seg_write_index_r      <= latched_target_seg_index;
                            seg_write_enable_r     <= 1'b1;
                            if (is_far_control) begin
                                ip_write_data_r   <= latched_far_offset;
                                ip_write_enable_r <= 1'b1;
                            end
                        end else begin
                            fault_np_r <= descriptor_fault_np;
                            fault_ss_r <= descriptor_fault_ss;
                            fault_gp_r <= descriptor_fault_gp;
                        end
                        state <= STATE_DONE;
                    end
                end
                STATE_READ_RET_LO: begin
                    if (i_bus_ready) begin
                        ret_offset_r <= i_bus_data_read;
                        state        <= STATE_READ_RET_HI;
                    end
                end
                STATE_READ_RET_HI: begin
                    if (i_bus_ready) begin
                        logic ret_ss_fault;
                        logic ret_gp_fault;
                        logic [31: 0] ret_tbl_base;
                        logic [15: 0] ret_tbl_limit;
                        latched_selector         <= i_bus_data_read[15: 0];
                        latched_target_seg_index <= `sreg_index_CS;
                        latched_far_offset       <= ret_offset_r;
                        ret_tbl_base  = i_bus_data_read[2] ? ldtr_base : latched_gdtr_base;
                        ret_tbl_limit = i_bus_data_read[2] ? ldtr_limit[15: 0] : latched_gdtr_limit;
                        check_selector_faults(i_bus_data_read[15: 0], `sreg_index_CS, LP_OP_FAR_RET,
                                              ret_tbl_base, ret_tbl_limit,
                                              ret_ss_fault, ret_gp_fault);
                        if (ret_gp_fault || ret_ss_fault) begin
                            fault_gp_r <= ret_gp_fault;
                            fault_ss_r <= ret_ss_fault;
                            state      <= STATE_DONE;
                        end else if (~i_protected_mode) begin
                            seg_write_selector_r   <= i_bus_data_read[15: 0];
                            seg_write_descriptor_r <= 64'h0;
                            seg_write_index_r      <= `sreg_index_CS;
                            seg_write_enable_r     <= 1'b1;
                            ip_write_data_r        <= ret_offset_r;
                            ip_write_enable_r      <= 1'b1;
                            state                  <= STATE_DONE;
                        end else begin
                            state <= STATE_READ_DESC_LO;
                        end
                    end
                end
                STATE_DONE: begin
                    o_ready <= 1'b1;
                    state   <= STATE_IDLE;
                end
                default: state <= STATE_IDLE;
            endcase
        end
    end

endmodule
