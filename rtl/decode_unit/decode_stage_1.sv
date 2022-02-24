/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_stage_1
create at: 2022-02-25 05:00:20
description: decode_stage_1
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"

module decode_stage_1 (
    input  logic [ 7:0] i_instruction [0:15],
    input  logic        i_default_operand_size,
    output logic        o_group_1_lock_bus,
    output logic        o_group_1_repeat_not_equal,
    output logic        o_group_1_repeat_equal,
    output logic        o_group_1_bound,
    output logic        o_group_2_segment_override,
    output logic        o_group_2_hint_branch_not_taken,
    output logic        o_group_2_hint_branch_taken,
    output logic        o_group_3_operand_size,
    output logic        o_group_4_address_size,
    output logic [ 2:0] o_segment_override_index,
    output logic        o_consume_bytes_prefix_1,
    output logic        o_consume_bytes_prefix_2,
    output logic        o_consume_bytes_prefix_3,
    output logic        o_consume_bytes_prefix_4,
    output logic        o_error_stage_1
);

wire [ 7:0] instruction_for_decode_prefix_all [0:3] = i_instruction [0:3];

decode_prefix_all decode_decode_prefix_all (
    .i_instruction ( instruction_for_decode_prefix_all ),
    .o_group_1_lock_bus ( o_group_1_lock_bus ),
    .o_group_1_repeat_not_equal ( o_group_1_repeat_not_equal ),
    .o_group_1_repeat_equal ( o_group_1_repeat_equal ),
    .o_group_1_bound ( o_group_1_bound ),
    .o_group_2_segment_override ( o_group_2_segment_override ),
    .o_group_2_hint_branch_not_taken ( o_group_2_hint_branch_not_taken ),
    .o_group_2_hint_branch_taken ( o_group_2_hint_branch_taken ),
    .o_group_3_operand_size ( o_group_3_operand_size ),
    .o_group_4_address_size ( o_group_4_address_size ),
    .o_segment_override_index ( o_segment_override_index ),
    .o_consume_bytes_prefix_1 ( o_consume_bytes_prefix_1 ),
    .o_consume_bytes_prefix_2 ( o_consume_bytes_prefix_2 ),
    .o_consume_bytes_prefix_3 ( o_consume_bytes_prefix_3 ),
    .o_consume_bytes_prefix_4 ( o_consume_bytes_prefix_4 ),
    .o_error ( o_error_stage_1 ),
);

endmodule
