/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: flags_register
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

module flags_register (
    // ports
    input  logic        write_enable,
    input  logic [31:0] write_data,
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
    output logic [31:0] EFLAGS,
    output logic [15:0] FLAGS,
    input  logic        clock, reset
);

reg [31:0] flags_reg;

always_ff @( posedge clock or negedge reset ) begin
    if (reset) begin
        flags_reg <= 32'b0;
    end else begin
        if (write_enable) begin
            flags_reg <= write_data;
        end else begin
            flags_reg <= flags_reg;
        end

    end
end

assign EFLAGS = flags_reg[31:0];
assign FLAGS  = flags_reg[15:0];

assign CF   = flags_reg[    0];
assign PF   = flags_reg[    2];
assign AF   = flags_reg[    4];
assign ZF   = flags_reg[    6];
assign SF   = flags_reg[    7];
assign TF   = flags_reg[    8];
assign IF   = flags_reg[    9];
assign DF   = flags_reg[   10];
assign OF   = flags_reg[   11];
assign IOPL = flags_reg[13:12];
assign NT   = flags_reg[   14];
assign RF   = flags_reg[   16];
assign VM   = flags_reg[   17];

endmodule
