/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Aggregated register files for w686_core.
*/

module w686_register_files (
    input  logic         wb_write_enable,
    input  logic [ 2: 0] wb_write_index,
    input  logic [31: 0] wb_write_data,

    input  logic         wb_SREG_write_enable,
    input  logic [ 2: 0] wb_SREG_write_index,
    input  logic [15: 0] wb_SREG_write_selector,
    input  logic [63: 0] wb_SREG_write_descriptor,

    input  logic         wb_FLAGS_write_enable,
    input  logic [31: 0] wb_FLAGS_write_data,

    input  logic         wb_IP_write_enable,
    input  logic [31: 0] wb_IP_write_data,

    input  logic         wb_CR_write_enable,
    input  logic [ 2: 0] wb_CR_write_index,
    input  logic [31: 0] wb_CR_write_data,

    input  logic         wb_DR_write_enable,
    input  logic [ 2: 0] wb_DR_write_index,
    input  logic [31: 0] wb_DR_write_data,

    input  logic         wb_TR_write_enable,
    input  logic [ 2: 0] wb_TR_write_index,
    input  logic [31: 0] wb_TR_write_data,

    output logic [31: 0] GPR_read__8 [ 0:  7],
    output logic [31: 0] GPR_read_16 [ 0:  7],
    output logic [31: 0] GPR_read_32 [ 0:  7],

    output logic [15: 0] segment_selector [ 0:  5],
    output logic [63: 0] descriptor_cache [ 0:  5],

    output logic         CF,
    output logic         PF,
    output logic         AF,
    output logic         ZF,
    output logic         SF,
    output logic         TF,
    output logic         IF,
    output logic         DF,
    output logic         OF,
    output logic [ 1: 0] IOPL,
    output logic         NT,
    output logic         RF,
    output logic         VM,
    output logic [31: 0] EFLAGS,
    output logic [15: 0] FLAGS,

    output logic [15: 0] IP,
    output logic [31: 0] EIP,

    output logic [31: 0] CR [ 0:  7],
    output logic         PE,
    output logic         MP,
    output logic         EM,
    output logic         TS,
    output logic         R,
    output logic         PG,
    output logic [19: 0] page_directory_base,

    output logic [31: 0] DR [ 0:  7],
    output logic [31: 0] TR [ 0:  7],

    output logic [15: 0] GDTR_limit,
    output logic [31: 0] GDTR_base,
    output logic [15: 0] IDTR_limit,
    output logic [31: 0] IDTR_base,

    input  logic          clock,
    input  logic          reset_n
);

    logic gdtr_write_enable = 1'b0;
    logic idtr_write_enable = 1'b0;

    rf_general_purpose_register general_purpose_register (
        .write_enable ( wb_write_enable ),
        .write_index ( wb_write_index ),
        .write_data ( wb_write_data ),
        .read__8 ( GPR_read__8 ),
        .read_16 ( GPR_read_16 ),
        .read_32 ( GPR_read_32 ),
        .clock ( clock ),
        .reset_n ( reset_n )
    );

    rf_segment_register core_segment_register (
        .write_enable ( wb_SREG_write_enable ),
        .write_index ( wb_SREG_write_index ),
        .write_selector ( wb_SREG_write_selector ),
        .write_descriptor ( wb_SREG_write_descriptor ),
        .segment_selector ( segment_selector ),
        .descriptor_cache ( descriptor_cache ),
        .clock ( clock ),
        .reset_n ( reset_n )
    );

    rf_flags_register core_flags_register (
        .write_enable ( wb_FLAGS_write_enable ),
        .write_data ( wb_FLAGS_write_data ),
        .CF ( CF ),
        .PF ( PF ),
        .AF ( AF ),
        .ZF ( ZF ),
        .SF ( SF ),
        .TF ( TF ),
        .IF ( IF ),
        .DF ( DF ),
        .OF ( OF ),
        .IOPL ( IOPL ),
        .NT ( NT ),
        .RF ( RF ),
        .VM ( VM ),
        .EFLAGS ( EFLAGS ),
        .FLAGS ( FLAGS ),
        .clock ( clock ),
        .reset_n ( reset_n )
    );

    rf_instruction_pointer_register core_instruction_pointer_register (
        .write_enable ( wb_IP_write_enable ),
        .write_data ( wb_IP_write_data ),
        .IP ( IP ),
        .EIP ( EIP ),
        .clock ( clock ),
        .reset_n ( reset_n )
    );

    rf_control_register core_control_register (
        .write_enable ( wb_CR_write_enable ),
        .write_index ( wb_CR_write_index ),
        .write_data ( wb_CR_write_data ),
        .CR ( CR ),
        .PE ( PE ),
        .MP ( MP ),
        .EM ( EM ),
        .TS ( TS ),
        .R ( R ),
        .PG ( PG ),
        .page_directory_base ( page_directory_base ),
        .clock ( clock ),
        .reset_n ( reset_n )
    );

    rf_debug_register core_debug_register (
        .write_enable ( wb_DR_write_enable ),
        .write_index ( wb_DR_write_index ),
        .write_data ( wb_DR_write_data ),
        .DR ( DR ),
        .clock ( clock ),
        .reset_n ( reset_n )
    );

    rf_test_register core_test_register (
        .write_enable ( wb_TR_write_enable ),
        .write_index ( wb_TR_write_index ),
        .write_data ( wb_TR_write_data ),
        .TR ( TR ),
        .clock ( clock ),
        .reset_n ( reset_n )
    );

    rf_gdtr_register core_gdtr_register (
        .gdtr_write_enable ( gdtr_write_enable ),
        .gdtr_write_data_limit ( 16'd0 ),
        .gdtr_write_data_base ( 32'd0 ),
        .gdtr_limit ( GDTR_limit ),
        .gdtr_base ( GDTR_base ),
        .clock ( clock ),
        .reset_n ( reset_n )
    );

    rf_idtr_register core_idtr_register (
        .idtr_write_enable ( idtr_write_enable ),
        .idtr_write_data_limit ( 16'd0 ),
        .idtr_write_data_base ( 32'd0 ),
        .idtr_limit ( IDTR_limit ),
        .idtr_base ( IDTR_base ),
        .clock ( clock ),
        .reset_n ( reset_n )
    );


endmodule