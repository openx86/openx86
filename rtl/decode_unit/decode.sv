/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode unit
create at: 2022-01-04 03:27:51
description: decode unit module
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"

module decode (
    input  logic [ 7:0] i_instruction [0:15],
    input  logic        i_default_operand_size,
    output logic [ 2:0] o_index_reg_gen [0:2],
    output logic [ 2:0] o_index_reg_seg,
    output logic [ 2:0] o_index_reg_base,
    output logic [ 2:0] o_index_reg_index,
    output logic [ 1:0] o_index_scale_factor,
    output logic [31:0] o_displacement,
    output logic [31:0] o_immediate,
    output logic        o_error
);

decode_opcode decode_decode_opcode (
);

decode_field decode_decode_field (
);

decode_mod_rm decode_decode_mod_rm (
);

decode_sib decode_decode_sib (
);

decode_disp_imm decode_decode_disp_imm (
);

endmodule
