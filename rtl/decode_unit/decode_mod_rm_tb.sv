// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: decode_mod_rm_tb
// create at: 2021-12-26 23:51:47
// description: test decode_mod_rm module

`timescale 1ns/1ns
`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_mod_rm_tb #(
    // parameters
) (
    // ports
);

logic [7:0] instruction;
logic       w;
logic [`info_bit_width_len-1:0] info_bit_width;
logic [`info_reg_seg_len-1:0] info_segment_reg;
logic [`info_reg_gpr_len-1:0] info_base_reg;
logic [`info_reg_gpr_len-1:0] info_index_reg;
logic [`info_displacement_len-1:0] info_displacement;
logic        sib_is_present;

wire [1:0] mod = instruction[7:6];
wire [2:0]  rm = instruction[2:0];

decode_mod_rm decode_mod_rm_inst (
    .mod ( mod ),
    .rm ( rm ),
    .w ( w ),
    .info_bit_width ( info_bit_width ),
    .info_segment_reg ( info_segment_reg ),
    .info_base_reg ( info_base_reg ),
    .info_index_reg ( info_index_reg ),
    .info_displacement ( info_displacement ),
    .sib_is_present ( sib_is_present )
);

reg [8:0] i;

initial begin
    instruction = 8'b0;
    info_bit_width = `info_bit_width_16;
    w = 0;

    $monitor("%t: instruction=%h, info_bit_width=%h, w=%h", $time, instruction, info_bit_width, w);
    $monitor("%t: info_segment_reg=%b", $time, info_segment_reg);
    $monitor("%t: info_base_reg=%b", $time, info_base_reg);
    $monitor("%t: info_index_reg=%b", $time, info_index_reg);
    $monitor("%t: info_displacement=%b", $time, info_displacement);
    $monitor("%t: sib_is_present=%b", $time, sib_is_present);

    #1;
    info_bit_width = `info_bit_width_16;
    w = 1;

    #1;
    info_bit_width = `info_bit_width_32;
    w = 0;

    #1;
    $display("66678B44F320 MOV EAX, [EBX + ESI*8 + 20H]");
    $display("0110 0110  0110 0111  1000 1011  0100 0100  1111 0011  0010 0000");
    instruction = 8'b0100_0100;
    info_bit_width = `info_bit_width_32;
    w = 1;

    #1;
    $display("3E8B4006 mov ax, ds:[bx+si+6]");
    $display("0011 1110  1000 1011  0100 0000  0000 0110");
    instruction = 8'b0100_0000;
    info_bit_width = `info_bit_width_16;
    w = 1;

    // #1;
    // w = 1;
    // info_bit_width = `info_bit_width_16;
    // for(i=0;i<256;i=i+1) begin
    //     instruction = i;
    //     #1;
    // end

    // #1;
    // w = 0;
    // info_bit_width = `info_bit_width_16;
    // for(i=0;i<256;i=i+1) begin
    //     instruction = i;
    //     #1;
    // end

    // #1;
    // w = 1;
    // info_bit_width = `info_bit_width_32;
    // for(i=0;i<256;i=i+1) begin
    //     instruction = i;
    //     #1;
    // end

    // #1;
    // w = 0;
    // info_bit_width = `info_bit_width_32;
    // for(i=0;i<256;i=i+1) begin
    //     instruction = i;
    //     #1;
    // end

    #16;
    $stop();
end

endmodule
