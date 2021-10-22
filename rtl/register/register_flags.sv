/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: register_flags
create at: 2021-10-22 22:23:28
description: define the flags register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
2.3.3 Flags Register
The Flags Register is a 32-bit register named
EFLAGS. The defined bits and bit fields within
EFLAGS, shown in Figure 2-3, control certain operations and indicate status of the Intel386 DX. The
lower 16 bits (bit 0-15) of EFLAGS contain the
16-bit flag register named FLAGS, which is most
useful when executing 8086 and 80286 code.
*/

module register_flags #(
    // parameters
) (
    // ports
    input  logic        write_enable,
    input  logic [ 4:0] write_index,
    input  logic        write_data,
    input  logic        write_IOPL_enable,
    input  logic [ 1:0] write_IOPL_data,
    output logic        CF,
    output logic        PF,
    output logic        AF,
    output logic        ZF,
    output logic        SF,
    output logic        TF,
    output logic        IF,
    output logic        DF,
    output logic        OF,
    output logic [ 1:0] IOPL,
    output logic        NT,
    output logic        RF,
    output logic        VM,
    output logic        EFLAGS,
    output logic        FLAGS,
    input  logic        clock, reset
);

reg   [31:0] EFLAGS_r;

always_ff @( posedge clock or negedge reset ) begin : ff_flags_register
    if (reset) begin
        EFLAGS_r <= 32'b0;
    end else begin
        if (write_enable) begin
            EFLAGS_r[write_index] <= write_data;
        end if (write_IOPL_enable) begin
            EFLAGS_r[13:12] <= write_IOPL_data;
        end else begin
            EFLAGS_r[write_index] <= EFLAGS_r[write_index];
        end

    end
end

assign EFLAGS = EFLAGS_r;
assign FLAGS = EFLAGS_r[15:0];

assign CF   = EFLAGS_r[    0];
assign PF   = EFLAGS_r[    2];
assign AF   = EFLAGS_r[    4];
assign ZF   = EFLAGS_r[    6];
assign SF   = EFLAGS_r[    7];
assign TF   = EFLAGS_r[    8];
assign IF   = EFLAGS_r[    9];
assign DF   = EFLAGS_r[   10];
assign OF   = EFLAGS_r[   11];
assign IOPL = EFLAGS_r[13:12];
assign NT   = EFLAGS_r[   14];
assign RF   = EFLAGS_r[   16];
assign VM   = EFLAGS_r[   17];

endmodule
