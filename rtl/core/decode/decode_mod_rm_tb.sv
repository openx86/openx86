`timescale 1ns/1ps
`include "rtl/definition.h.sv"

module decode_mod_rm_tb;

    logic [1:0] i_mod;
    logic [2:0] i_rm;
    logic       i_w_is_present;
    logic       i_w;
    logic       i_default_operand_size;

    logic [2:0] o_segment_reg_index;
    logic       o_base_reg_is_present;
    logic [2:0] o_base_reg_index;
    logic       o_index_reg_is_present;
    logic [2:0] o_index_reg_index;
    logic       o_gen_reg_is_present;
    logic [2:0] o_gen_reg_index;
    logic [2:0] o_gen_reg_bit_width;
    logic       o_displacement_is_present;
    logic       o_displacement_size_8;
    logic       o_displacement_size_16;
    logic       o_displacement_size_32;
    logic       o_sib_is_present;

    decode_mod_rm dut (
        .i_mod                 (i_mod),
        .i_rm                  (i_rm),
        .i_w_is_present        (i_w_is_present),
        .i_w                   (i_w),
        .i_default_operand_size(i_default_operand_size),
        .o_segment_reg_index   (o_segment_reg_index),
        .o_base_reg_is_present (o_base_reg_is_present),
        .o_base_reg_index      (o_base_reg_index),
        .o_index_reg_is_present(o_index_reg_is_present),
        .o_index_reg_index     (o_index_reg_index),
        .o_gen_reg_is_present  (o_gen_reg_is_present),
        .o_gen_reg_index       (o_gen_reg_index),
        .o_gen_reg_bit_width   (o_gen_reg_bit_width),
        .o_displacement_is_present(o_displacement_is_present),
        .o_displacement_size_8 (o_displacement_size_8),
        .o_displacement_size_16(o_displacement_size_16),
        .o_displacement_size_32(o_displacement_size_32),
        .o_sib_is_present      (o_sib_is_present)
    );

    task show(string name);
        $display("[%s] mod=%b rm=%b def_size=%0d seg=%0d base_p=%0d base=%0d idx_p=%0d idx=%0d disp8=%0d disp16=%0d disp32=%0d sib=%0d",
                 name, i_mod, i_rm, i_default_operand_size,
                 o_segment_reg_index, o_base_reg_is_present, o_base_reg_index,
                 o_index_reg_is_present, o_index_reg_index,
                 o_displacement_size_8, o_displacement_size_16, o_displacement_size_32,
                 o_sib_is_present);
    endtask

    initial begin
        // 16-bit addressing, mod=00, rm=110 => disp16 only, SS base (BP), DS otherwise
        i_w_is_present        = 1'b1;
        i_w                   = 1'b1;

        i_default_operand_size = `default_operation_size_16;
        i_mod = 2'b00; i_rm = 3'b000; #1; show("16b mod00 rm000");
        i_mod = 2'b00; i_rm = 3'b110; #1; show("16b mod00 rm110");

        // 32-bit addressing, check DS/SS selection and displacement sizes
        i_default_operand_size = `default_operation_size_32;
        i_mod = 2'b01; i_rm = 3'b000; #1; show("32b mod01 rm000"); // base EAX -> DS, disp8
        i_mod = 2'b01; i_rm = 3'b101; #1; show("32b mod01 rm101"); // base EBP -> SS, disp8
        i_mod = 2'b10; i_rm = 3'b111; #1; show("32b mod10 rm111"); // base EDI -> DS, disp32

        // Register addressing (mod=11) should report general register only
        i_mod = 2'b11; i_rm = 3'b001; #1; show("mod11 rm001");

        $finish;
    end

endmodule

