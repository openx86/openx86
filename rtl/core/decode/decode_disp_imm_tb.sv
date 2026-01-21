`timescale 1ns/1ps
`include "rtl/definition.h.sv"

module decode_disp_imm_tb;

    logic [7:0] i_instruction [0:7];
    logic       i_displacement_size_1;
    logic       i_displacement_size_2;
    logic       i_displacement_size_4;
    logic       i_immediate_size_1;
    logic       i_immediate_size_2;
    logic       i_immediate_size_4;
    logic       i_immediate_size_f;

    logic [31:0] o_displacement;
    logic [31:0] o_immediate;
    logic [3:0]  o_consume_bytes;
    logic        o_error;

    decode_disp_imm dut (
        .i_instruction       (i_instruction),
        .i_displacement_size_1(i_displacement_size_1),
        .i_displacement_size_2(i_displacement_size_2),
        .i_displacement_size_4(i_displacement_size_4),
        .i_immediate_size_1  (i_immediate_size_1),
        .i_immediate_size_2  (i_immediate_size_2),
        .i_immediate_size_4  (i_immediate_size_4),
        .i_immediate_size_f  (i_immediate_size_f),
        .o_displacement      (o_displacement),
        .o_immediate         (o_immediate),
        .o_consume_bytes     (o_consume_bytes),
        .o_error             (o_error)
    );

    task show(string name);
        $display("[%s] disp=%h imm=%h bytes=%0d (d1=%0d d2=%0d d4=%0d i1=%0d i2=%0d i4=%0d if=%0d)",
                 name, o_displacement, o_immediate, o_consume_bytes,
                 i_displacement_size_1, i_displacement_size_2, i_displacement_size_4,
                 i_immediate_size_1, i_immediate_size_2, i_immediate_size_4, i_immediate_size_f);
    endtask

    initial begin
        i_instruction = '{8'h11, 8'h22, 8'h33, 8'h44, 8'hAA, 8'hBB, 8'hCC, 8'hDD};

        // disp8, imm32
        i_displacement_size_1 = 1; i_displacement_size_2 = 0; i_displacement_size_4 = 0;
        i_immediate_size_1    = 0; i_immediate_size_2    = 0; i_immediate_size_4    = 1; i_immediate_size_f = 0;
        #1; show("disp8 imm32");

        // disp32, imm8
        i_displacement_size_1 = 0; i_displacement_size_2 = 0; i_displacement_size_4 = 1;
        i_immediate_size_1    = 1; i_immediate_size_2    = 0; i_immediate_size_4    = 0; i_immediate_size_f = 0;
        #1; show("disp32 imm8");

        // no disp, imm16
        i_displacement_size_1 = 0; i_displacement_size_2 = 0; i_displacement_size_4 = 0;
        i_immediate_size_1    = 0; i_immediate_size_2    = 1; i_immediate_size_4    = 0; i_immediate_size_f = 0;
        #1; show("no-disp imm16");

        $finish;
    end

endmodule

