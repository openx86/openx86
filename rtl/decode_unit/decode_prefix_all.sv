/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_prefix
create at: 2021-12-28 16:56:15
description: decode prefix from instruction

refer to 64-ia-32-architectures-software-developer-vol-2a-manual.pdf

2.1.1 Instruction Prefixes

Instruction prefixes are divided into four groups, each with a set of allowable prefix codes. For each instruction, it
is only useful to include up to one prefix code from each of the four groups (Groups 1, 2, 3, 4). Groups 1 through 4
may be placed in any order relative to each other.

 Group 1
— Lock and repeat prefixes:
• LOCK prefix is encoded using F0H.
• REPNE/REPNZ prefix is encoded using F2H. Repeat-Not-Zero prefix applies only to string and
input/output instructions. (F2H is also used as a mandatory prefix for some instructions.)
• REP or REPE/REPZ is encoded using F3H. The repeat prefix applies only to string and input/output
instructions. F3H is also used as a mandatory prefix for POPCNT, LZCNT and ADOX instructions.
— Bound prefix is encoded using F2H if the following conditions are true:
• CPUID.(EAX=07H, ECX=0):EBX.MPX[bit 14] is set.
• BNDCFGU.EN and/or IA32_BNDCFGS.EN is set.
• When the F2 prefix precedes a near CALL, a near RET, a near JMP, or a near Jcc instruction (see Chapter
17, “Intel® MPX,” of the Intel® 64 and IA-32 Architectures Software Developer’s Manual, Volume 1).
Group 2
— Segment override prefixes:
• 2EH—CS segment override (use with any branch instruction is reserved).
• 36H—SS segment override prefix (use with any branch instruction is reserved).
• 3EH—DS segment override prefix (use with any branch instruction is reserved).
• 26H—ES segment override prefix (use with any branch instruction is reserved).
• 64H—FS segment override prefix (use with any branch instruction is reserved).
• 65H—GS segment override prefix (use with any branch instruction is reserved).
— Branch hints1:
• 2EH—Branch not taken (used only with Jcc instructions).
• 3EH—Branch taken (used only with Jcc instructions).
Group 3
• Operand-size override prefix is encoded using 66H (66H is also used as a mandatory prefix for some
instructions).
Group 4
• 67H—Address-size override prefix.

Register EXtension(REX) refer to
This 2002 Hot Chips presentation by AMD expands the acronym on slide 10: "REX (Register Extension)".
Kevin McGrath and Dave Christie, "The AMD x86-64 Architecture: Extending the x86 to 64 bits", Hot Chips 14, August 2002.
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_prefix_all (
    input  logic [ 7:0] i_instruction [0:3],
    output logic        o_group_1_lock_bus,
    output logic        o_group_1_repeat_not_equal,
    output logic        o_group_1_repeat_equal,
    output logic        o_group_1_bound,
    output logic        o_group_2_segment_override,
    output logic        o_group_2_hint_branch_not_taken,
    output logic        o_group_2_hint_branch_taken,
    output logic        o_group_3_operand_size,
    output logic        o_group_4_address_size,
    output logic        o_group_1_is_present,
    output logic        o_group_2_is_present,
    output logic        o_group_3_is_present,
    output logic        o_group_4_is_present,
    output logic [ 2:0] o_segment_override_index,
    output logic        o_consume_bytes_prefix_1,
    output logic        o_consume_bytes_prefix_2,
    output logic        o_consume_bytes_prefix_3,
    output logic        o_consume_bytes_prefix_4,
    output logic        o_error
);

logic        group_1_lock_bus [4];
logic        group_1_repeat_not_equal [4];
logic        group_1_repeat_equal [4];
logic        group_1_bound [4];
logic        group_2_segment_override [4];
logic        group_2_hint_branch_not_taken [4];
logic        group_2_hint_branch_taken [4];
logic        group_3_operand_size [4];
logic        group_4_address_size [4];
logic        group_1_is_present [4];
logic        group_2_is_present [4];
logic        group_3_is_present [4];
logic        group_4_is_present [4];
logic        is_present [4];
logic [ 2:0] segment_override_index [4];

wire  [ 2:0] sum_group_1 = ({2'b0, group_1_is_present[0]} + {2'b0, group_1_is_present[1]} + {2'b0, group_1_is_present[2]} + {2'b0, group_1_is_present[3]});
wire  [ 2:0] sum_group_2 = ({2'b0, group_2_is_present[0]} + {2'b0, group_2_is_present[1]} + {2'b0, group_2_is_present[2]} + {2'b0, group_2_is_present[3]});
wire  [ 2:0] sum_group_3 = ({2'b0, group_3_is_present[0]} + {2'b0, group_3_is_present[1]} + {2'b0, group_3_is_present[2]} + {2'b0, group_3_is_present[3]});
wire  [ 2:0] sum_group_4 = ({2'b0, group_4_is_present[0]} + {2'b0, group_4_is_present[1]} + {2'b0, group_4_is_present[2]} + {2'b0, group_4_is_present[3]});

wire         error_repeat_group_1 = (sum_group_1 > 1) ? 1'b1 : 1'b0;
wire         error_repeat_group_2 = (sum_group_2 > 1) ? 1'b1 : 1'b0;
wire         error_repeat_group_3 = (sum_group_3 > 1) ? 1'b1 : 1'b0;
wire         error_repeat_group_4 = (sum_group_4 > 1) ? 1'b1 : 1'b0;
wire         error_repeat         = error_repeat_group_1 | error_repeat_group_2 | error_repeat_group_3 | error_repeat_group_4;

// wire  [ 2:0] bytes_consumed    = is_present[0] + is_present[1] + is_present[2] + is_present[3];

assign o_group_1_lock_bus              = group_1_lock_bus[0] | group_1_lock_bus[1] | group_1_lock_bus[2] | group_1_lock_bus[3];
assign o_group_1_repeat_not_equal      = group_1_repeat_not_equal[0] | group_1_repeat_not_equal[1] | group_1_repeat_not_equal[2] | group_1_repeat_not_equal[3];
assign o_group_1_repeat_equal          = group_1_repeat_equal[0] | group_1_repeat_equal[1] | group_1_repeat_equal[2] | group_1_repeat_equal[3];
assign o_group_1_bound                 = group_1_bound[0] | group_1_bound[1] | group_1_bound[2] | group_1_bound[3];
assign o_group_2_segment_override      = group_2_segment_override[0] | group_2_segment_override[1] | group_2_segment_override[2] | group_2_segment_override[3];
assign o_group_2_hint_branch_not_taken = group_2_hint_branch_not_taken[0] | group_2_hint_branch_not_taken[1] | group_2_hint_branch_not_taken[2] | group_2_hint_branch_not_taken[3];
assign o_group_2_hint_branch_taken     = group_2_hint_branch_taken[0] | group_2_hint_branch_taken[1] | group_2_hint_branch_taken[2] | group_2_hint_branch_taken[3];
assign o_group_3_operand_size          = group_3_operand_size[0] | group_3_operand_size[1] | group_3_operand_size[2] | group_3_operand_size[3];
assign o_group_4_address_size          = group_4_address_size[0] | group_4_address_size[1] | group_4_address_size[2] | group_4_address_size[3];
assign o_group_1_is_present            = group_1_is_present[0] | group_1_is_present[1] | group_1_is_present[2] | group_1_is_present[3];
assign o_group_2_is_present            = group_2_is_present[0] | group_2_is_present[1] | group_2_is_present[2] | group_2_is_present[3];
assign o_group_3_is_present            = group_3_is_present[0] | group_3_is_present[1] | group_3_is_present[2] | group_3_is_present[3];
assign o_group_4_is_present            = group_4_is_present[0] | group_4_is_present[1] | group_4_is_present[2] | group_4_is_present[3];
assign o_segment_override_index        = segment_override_index[0] | segment_override_index[1] | segment_override_index[2] | segment_override_index[3];
// assign o_register_extension            = 1'b0; // Register EXtension(REX) IA-32e is ready!
// assign o_consume_bytes_prefix_0        = bytes_consumed == 3'h0;
// assign o_consume_bytes_prefix_1        = bytes_consumed == 3'h1;
// assign o_consume_bytes_prefix_2        = bytes_consumed == 3'h2;
// assign o_consume_bytes_prefix_3        = bytes_consumed == 3'h3;
// assign o_consume_bytes_prefix_4        = bytes_consumed == 3'h4;
assign o_consume_bytes_prefix_1 = (is_present == '{1'b1, 1'b0, 1'b0, 1'b0});
assign o_consume_bytes_prefix_2 = (is_present == '{1'b1, 1'b1, 1'b0, 1'b0});
assign o_consume_bytes_prefix_3 = (is_present == '{1'b1, 1'b1, 1'b1, 1'b0});
assign o_consume_bytes_prefix_4 = (is_present == '{1'b1, 1'b1, 1'b1, 1'b1});
assign o_error                         = error_repeat;

decode_prefix decode_prefix_in_stage_0_from_instruction_0 (
    .i_instruction                   ( i_instruction                [0] ),
    .o_group_1_lock_bus              ( group_1_lock_bus             [0] ),
    .o_group_1_repeat_not_equal      ( group_1_repeat_not_equal     [0] ),
    .o_group_1_repeat_equal          ( group_1_repeat_equal         [0] ),
    .o_group_1_bound                 ( group_1_bound                [0] ),
    .o_group_2_segment_override      ( group_2_segment_override     [0] ),
    .o_group_2_hint_branch_not_taken ( group_2_hint_branch_not_taken[0] ),
    .o_group_2_hint_branch_taken     ( group_2_hint_branch_taken    [0] ),
    .o_group_3_operand_size          ( group_3_operand_size         [0] ),
    .o_group_4_address_size          ( group_4_address_size         [0] ),
    .o_group_1_is_present            ( group_1_is_present           [0] ),
    .o_group_2_is_present            ( group_2_is_present           [0] ),
    .o_group_3_is_present            ( group_3_is_present           [0] ),
    .o_group_4_is_present            ( group_4_is_present           [0] ),
    .o_is_present                    ( is_present                   [0] ),
    .o_segment_override_index        ( segment_override_index       [0] )
);

decode_prefix decode_prefix_in_stage_0_from_instruction_1 (
    .i_instruction                   ( i_instruction                [1] ),
    .o_group_1_lock_bus              ( group_1_lock_bus             [1] ),
    .o_group_1_repeat_not_equal      ( group_1_repeat_not_equal     [1] ),
    .o_group_1_repeat_equal          ( group_1_repeat_equal         [1] ),
    .o_group_1_bound                 ( group_1_bound                [1] ),
    .o_group_2_segment_override      ( group_2_segment_override     [1] ),
    .o_group_2_hint_branch_not_taken ( group_2_hint_branch_not_taken[1] ),
    .o_group_2_hint_branch_taken     ( group_2_hint_branch_taken    [1] ),
    .o_group_3_operand_size          ( group_3_operand_size         [1] ),
    .o_group_4_address_size          ( group_4_address_size         [1] ),
    .o_group_1_is_present            ( group_1_is_present           [1] ),
    .o_group_2_is_present            ( group_2_is_present           [1] ),
    .o_group_3_is_present            ( group_3_is_present           [1] ),
    .o_group_4_is_present            ( group_4_is_present           [1] ),
    .o_is_present                    ( is_present                   [1] ),
    .o_segment_override_index        ( segment_override_index       [1] )
);

decode_prefix decode_prefix_in_stage_0_from_instruction_2 (
    .i_instruction                   ( i_instruction                [2] ),
    .o_group_1_lock_bus              ( group_1_lock_bus             [2] ),
    .o_group_1_repeat_not_equal      ( group_1_repeat_not_equal     [2] ),
    .o_group_1_repeat_equal          ( group_1_repeat_equal         [2] ),
    .o_group_1_bound                 ( group_1_bound                [2] ),
    .o_group_2_segment_override      ( group_2_segment_override     [2] ),
    .o_group_2_hint_branch_not_taken ( group_2_hint_branch_not_taken[2] ),
    .o_group_2_hint_branch_taken     ( group_2_hint_branch_taken    [2] ),
    .o_group_3_operand_size          ( group_3_operand_size         [2] ),
    .o_group_4_address_size          ( group_4_address_size         [2] ),
    .o_group_1_is_present            ( group_1_is_present           [2] ),
    .o_group_2_is_present            ( group_2_is_present           [2] ),
    .o_group_3_is_present            ( group_3_is_present           [2] ),
    .o_group_4_is_present            ( group_4_is_present           [2] ),
    .o_is_present                    ( is_present                   [2] ),
    .o_segment_override_index        ( segment_override_index       [2] )
);

decode_prefix decode_prefix_in_stage_0_from_instruction_3 (
    .i_instruction                   ( i_instruction                [3] ),
    .o_group_1_lock_bus              ( group_1_lock_bus             [3] ),
    .o_group_1_repeat_not_equal      ( group_1_repeat_not_equal     [3] ),
    .o_group_1_repeat_equal          ( group_1_repeat_equal         [3] ),
    .o_group_1_bound                 ( group_1_bound                [3] ),
    .o_group_2_segment_override      ( group_2_segment_override     [3] ),
    .o_group_2_hint_branch_not_taken ( group_2_hint_branch_not_taken[3] ),
    .o_group_2_hint_branch_taken     ( group_2_hint_branch_taken    [3] ),
    .o_group_3_operand_size          ( group_3_operand_size         [3] ),
    .o_group_4_address_size          ( group_4_address_size         [3] ),
    .o_group_1_is_present            ( group_1_is_present           [3] ),
    .o_group_2_is_present            ( group_2_is_present           [3] ),
    .o_group_3_is_present            ( group_3_is_present           [3] ),
    .o_group_4_is_present            ( group_4_is_present           [3] ),
    .o_is_present                    ( is_present                   [3] ),
    .o_segment_override_index        ( segment_override_index       [3] )
);

endmodule
