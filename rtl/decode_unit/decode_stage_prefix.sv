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
module decode_stage_prefix (
    input  logic [ 7:0] i_instruction[0:15],
    output logic        o_address_size,
    output logic        o_bus_lock,
    output logic        o_operand_size,
    output logic        o_segment_override,
    output logic [ 2:0] o_segment_override_index,
    output logic [ 2:0] o_register_extension,
    output logic        o_error,
    output logic [ 3:0] o_consumed_instruction_bytes
);

logic        address_size [4];
logic        bus_lock [4];
logic        operand_size [4];
logic        segment_override [4];
logic [ 2:0] segment_override_index [4];

wire  [ 2:0] sum_address_size              = (address_size[0] + address_size[1] + address_size[2] + address_size[3]);
wire  [ 2:0] sum_bus_lock                  = (bus_lock[0] + bus_lock[1] + bus_lock[2] + bus_lock[3]);
wire  [ 2:0] sum_operand_size              = (operand_size[0] + operand_size[1] + operand_size[2] + operand_size[3]);
wire  [ 2:0] sum_segment_override          = (segment_override[0] + segment_override[1] + segment_override[2] + segment_override[3]);

wire         error_repeat_address_size     = (sum_address_size > 1)     ? 1'b1 : 1'b0;
wire         error_repeat_bus_lock         = (sum_bus_lock > 1)         ? 1'b1 : 1'b0;
wire         error_repeat_operand_size     = (sum_operand_size > 1)     ? 1'b1 : 1'b0;
wire         error_repeat_segment_override = (sum_segment_override > 1) ? 1'b1 : 1'b0;
wire         error_repeat                  = error_repeat_address_size | error_repeat_bus_lock | error_repeat_operand_size | error_repeat_segment_override;

assign o_address_size               = address_size[0] | address_size[1] | address_size[2] | address_size[3];
assign o_bus_lock                   = bus_lock[0] | bus_lock[1] | bus_lock[2] | bus_lock[3];
assign o_operand_size               = operand_size[0] | operand_size[1] | operand_size[2] | operand_size[3];
assign o_segment_override           = segment_override[0] | segment_override[1] | segment_override[2] | segment_override[3];
assign o_segment_override_index     = segment_override_index[0] | segment_override_index[1] | segment_override_index[2] | segment_override_index[3];
assign o_register_extension         = 1'b0; // Register EXtension(REX) IA-32e is ready!
assign o_error                      = error_repeat;
assign o_consumed_instruction_bytes = o_address_size + o_bus_lock + o_operand_size + o_segment_override;

decode_prefix decode_prefix_in_stage_0_from_instruction_0 (
    .instruction ( i_instruction[0] ),
    .address_size ( address_size[0] ),
    .bus_lock ( bus_lock[0] ),
    .operand_size ( operand_size[0] ),
    .segment_override ( segment_override[0] ),
    .segment_override_index ( segment_override_index[0] )
);

decode_prefix decode_prefix_in_stage_0_from_instruction_1 (
    .instruction ( i_instruction[1] ),
    .address_size ( address_size[1] ),
    .bus_lock ( bus_lock[1] ),
    .operand_size ( operand_size[1] ),
    .segment_override ( segment_override[1] ),
    .segment_override_index ( segment_override_index[1] )
);

decode_prefix decode_prefix_in_stage_0_from_instruction_2 (
    .instruction ( i_instruction[2] ),
    .address_size ( address_size[2] ),
    .bus_lock ( bus_lock[2] ),
    .operand_size ( operand_size[2] ),
    .segment_override ( segment_override[2] ),
    .segment_override_index ( segment_override_index[2] )
);

decode_prefix decode_prefix_in_stage_0_from_instruction_3 (
    .instruction ( i_instruction[3] ),
    .address_size ( address_size[3] ),
    .bus_lock ( bus_lock[3] ),
    .operand_size ( operand_size[3] ),
    .segment_override ( segment_override[3] ),
    .segment_override_index ( segment_override_index[3] )
);

endmodule
