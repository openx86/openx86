`timescale 1ns/1ps
`include "rtl/definition.h.sv"

module decode_sib_tb;

    logic [7:0] i_sib;
    logic [1:0] i_mod;
    logic [1:0] o_scale_factor;
    logic [2:0] o_segment_reg_index;
    logic       o_index_reg_is_present;
    logic [2:0] o_index_reg_index;
    logic       o_base_reg_is_present;
    logic [2:0] o_base_reg_index;
    logic       o_displacement_size_1;
    logic       o_displacement_size_4;
    logic       o_effecitve_address_undefined;

    decode_sib dut (
        .i_sib                     (i_sib),
        .i_mod                     (i_mod),
        .o_scale_factor            (o_scale_factor),
        .o_segment_reg_index       (o_segment_reg_index),
        .o_index_reg_is_present    (o_index_reg_is_present),
        .o_index_reg_index         (o_index_reg_index),
        .o_base_reg_is_present     (o_base_reg_is_present),
        .o_base_reg_index          (o_base_reg_index),
        .o_displacement_size_1     (o_displacement_size_1),
        .o_displacement_size_4     (o_displacement_size_4),
        .o_effecitve_address_undefined(o_effecitve_address_undefined)
    );

    task show(string name);
        $display("[%s] sib=%02h mod=%b scale=%0d idx_p=%0d idx=%0d base_p=%0d base=%0d disp1=%0d disp4=%0d seg=%0d undef=%0d",
                 name, i_sib, i_mod, o_scale_factor,
                 o_index_reg_is_present, o_index_reg_index,
                 o_base_reg_is_present, o_base_reg_index,
                 o_displacement_size_1, o_displacement_size_4,
                 o_segment_reg_index, o_effecitve_address_undefined);
    endtask

    initial begin
        // mod=00, base=101 -> disp32, DS segment
        i_mod = 2'b00;
        i_sib = 8'b0000_0101; // scale=00, index=000 (EAX), base=101
        #1; show("mod00 base=101");

        // mod=01, base=100 (ESP) -> SS, disp8
        i_mod = 2'b01;
        i_sib = 8'b0000_0100; // scale=00, index=000, base=100
        #1; show("mod01 base=100");

        // mod=10, base=100 (ESP) -> SS, disp32
        i_mod = 2'b10;
        i_sib = 8'b0000_0100;
        #1; show("mod10 base=100");

        // No index case: index=100, ss!=00 => undefined effective address
        i_mod = 2'b00;
        i_sib = 8'b0101_0100; // scale=01, index=100 (no index, but ss!=00)
        #1; show("no index, ss!=00");

        $finish;
    end

endmodule

