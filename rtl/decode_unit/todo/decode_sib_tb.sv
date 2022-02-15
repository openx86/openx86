// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: decode_sib_tb
// create at: 2021-12-27 01:07:00
// description: test decode_sib module

`timescale 1ns/1ns
`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_sib_tb #(
    // parameters
) (
    // ports
);

logic [ 7:0] instruction;
logic [ 1:0] mod;
logic [`info_reg_seg_len-1:0] info_segment_reg;
logic [`info_scale_len-1:0] info_scale;
logic [`info_reg_gpr_len-1:0] info_base_reg;
logic [`info_reg_gpr_len-1:0] info_index_reg;
logic [`info_displacement_len-1:0] info_displacement;

decode_sib decode_sib_inst (
    .instruction ( instruction ),
    .mod ( mod ),
    .info_segment_reg ( info_segment_reg ),
    .info_scale ( info_scale ),
    .info_base_reg ( info_base_reg ),
    .info_index_reg ( info_index_reg ),
    .info_displacement ( info_displacement )
);

reg [8:0] i;

initial begin
    instruction = 8'b0;
    mod = 2'b00;

    $monitor("%t: instruction=%h, mod=%h", $time, instruction, mod);
    $monitor("%t: info_segment_reg=%b", $time, info_segment_reg);
    $monitor("%t: info_scale=%b", $time, info_scale);
    $monitor("%t: info_base_reg=%b", $time, info_base_reg);
    $monitor("%t: info_index_reg=%b", $time, info_index_reg);
    $monitor("%t: info_displacement=%b", $time, info_displacement);

    #1;
    $display("66678B44F320 MOV EAX, [EBX + ESI*8 + 20H]");
    $display("0110 0110  0110 0111  1000 1011  0100 0100  1111 0011  0010 0000");
    instruction = 8'b1111_0011;
    mod = 2'b01;

    #16;
    $stop();
end

endmodule
