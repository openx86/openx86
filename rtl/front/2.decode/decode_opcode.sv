/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_opcode
create at: 2021-12-28 16:56:15
description: decode opcode from instruction
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_opcode #(
    // parameters
) (
    // ports
    input  logic [ 7:0] instruction[0:9],
    // output logic [ 1:0] used_instruction_count
    output logic [0:`info_opcode_len-1] info_opcode
);

// always_comb begin
//     unique casez (instruction[0])
//         8'b1000_100? : info_opcode <= `info_opcode_mov_reg_to_reg_mem;
//         8'b1000_101? : info_opcode <= `info_opcode_mov_reg_mem_to_reg;
//         8'b1100_011? : begin
//             unique casez (instruction[1][5:3])
//                 3'b000 : info_opcode <= `info_opcode_mov_imm_to_reg_mem;
//                 default : info_opcode <= `info_opcode_invalid;
//             endcase
//         end
//         8'b1011_???? : info_opcode <= `info_opcode_mov_imm_to_reg_short;
//         8'b1010_000? : info_opcode <= `info_opcode_mov_mem_to_acc;
//         8'b1010_001? : info_opcode <= `info_opcode_mov_acc_to_mem;
//         8'b1000_1110 : info_opcode <= `info_opcode_mov_reg_mem_to_sreg;
//         8'b1000_1100 : info_opcode <= `info_opcode_mov_sreg_to_reg_mem;

//         8'b0000_1111 : begin
//             unique casez (instruction[1])
//                 8'b1011_111? : info_opcode <= `info_opcode_movsx;
//                 8'b1011_011? : info_opcode <= `info_opcode_movzx;
//                 default : info_opcode <= `info_opcode_invalid;
//             endcase
//         end

//         8'b1111_1111 : begin
//             unique casez (instruction[1][5:3])
//                 3'b110 : info_opcode <= `info_opcode_push_reg_mem;
//                 default : info_opcode <= `info_opcode_invalid;
//             endcase
//         end
//         8'b0101_0??? :  info_opcode <= `info_opcode_push_reg_short;
//         8'b000?_?110 :  info_opcode <= `info_opcode_push_sreg_2;
//         8'b0000_1111 :  begin
//             unique casez (instruction[1])
//                 8'b10??_?000 : info_opcode <= `info_opcode_push_sreg_3;
//                 default : info_opcode <= `info_opcode_invalid;
//             endcase
//         end
//         8'b0110_10?0 :  info_opcode <= `info_opcode_push_imm;
//         8'b0110_0000 :  info_opcode <= `info_opcode_push_a;

//         8'b1000_1111 : begin
//             unique casez (instruction[1][5:3])
//                 3'b000 : info_opcode <= `info_opcode_pop_reg_mem;
//                 default : info_opcode <= `info_opcode_invalid;
//             endcase
//         end
//         8'b0101_1??? :  info_opcode <= `info_opcode_pop_reg_short;
//         8'b000?_?111 :  info_opcode <= `info_opcode_pop_sreg_2;
//         8'b0000_1111 :  begin
//             unique casez (instruction[1])
//                 8'b10??_?001 : info_opcode <= `info_opcode_pop_sreg_3;
//                 default : info_opcode <= `info_opcode_invalid;
//             endcase
//         end
//         8'b0110_0001 :  info_opcode <= `info_opcode_pop_a;

//         8'b0101_0??? :  info_opcode <= `info_opcode_push_reg_short;
//         default : info_opcode <= `info_opcode_invalid;
//     endcase
// end

// wire opcode_invalid                 = 0;
wire opcode_mov_reg_to_reg_mem      = (instruction[0][7:1] == 7'b1000_100);
wire opcode_mov_reg_mem_to_reg      = (instruction[0][7:1] == 7'b1000_101);
wire opcode_mov_imm_to_reg_mem      = (instruction[0][7:1] == 7'b1100_011) & (instruction[1][5:3] == 3'b000);
wire opcode_mov_imm_to_reg_short    = (instruction[0][7:4] == 4'b1011);
wire opcode_mov_mem_to_acc          = (instruction[0][7:1] == 7'b1010_000);
wire opcode_mov_acc_to_mem          = (instruction[0][7:1] == 7'b1010_001);
wire opcode_mov_reg_mem_to_sreg     = (instruction[0][7:0] == 8'b1000_1110);
wire opcode_mov_sreg_to_reg_mem     = (instruction[0][7:0] == 8'b1000_1100);
wire opcode_movsx                   = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:1] == 7'b1011_111);
wire opcode_movzx                   = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:1] == 7'b1011_011);
wire opcode_push_reg_mem            = (instruction[0][7:0] == 8'b1111_1111) & (instruction[1][5:3] == 3'b110);
wire opcode_push_reg_short          = (instruction[0][7:3] == 5'b0101_0);
wire opcode_push_sreg_2             = (instruction[0][7:5] == 3'b000) & (instruction[0][2:0] == 3'b110);
wire opcode_push_sreg_3             = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:6] == 2'b10) & (instruction[1][5] == 1'b1) & (instruction[1][2:0] == 3'b000);
wire opcode_push_imm                = (instruction[0][7:2] == 6'b0110_10) & (instruction[0][0] == 1'b0);
wire opcode_push_all                = (instruction[0][7:0] == 8'b0110_0000);
wire opcode_pop_reg_mem             = (instruction[0][7:0] == 8'b1000_1111) & (instruction[1][5:3] == 3'b000);
wire opcode_pop_reg_short           = (instruction[0][7:3] == 5'b0101_1);
wire opcode_pop_sreg_2              = (instruction[0][7:5] == 3'b000) & (instruction[0][4:3] != 2'b01) & (instruction[0][2:0] == 3'b111) & (instruction[1][5:3] != 3'b110) & (instruction[1][5:3] != 3'b111);
wire opcode_pop_sreg_3              = (instruction[0][7:0] == 8'b0000_1111) & (instruction[1][7:6] == 2'b10) & (instruction[1][5] == 1'b1) & (instruction[1][2:0] == 3'b001);
wire opcode_pop_all                 = (instruction[0][7:0] == 8'b0110_0001);
wire opcode_xchg_reg_mem_with_reg   = (instruction[0][7:1] == 7'b1000_011);
wire opcode_xchg_reg_with_acc_short = (instruction[0][7:3] == 5'b1001_0);
wire opcode_xchg_in_fix             = (instruction[0][7:1] == 7'b1110_010);
wire opcode_xchg_in_var             = (instruction[0][7:1] == 7'b1110_110);
wire opcode_xchg_out_fix            = (instruction[0][7:1] == 7'b1110_011);
wire opcode_xchg_out_var            = (instruction[0][7:1] == 7'b1110_111);

assign info_opcode = {
    opcode_mov_reg_to_reg_mem,
    opcode_mov_reg_mem_to_reg,
    opcode_mov_imm_to_reg_mem,
    opcode_mov_imm_to_reg_short,
    opcode_mov_mem_to_acc,
    opcode_mov_acc_to_mem,
    opcode_mov_reg_mem_to_sreg,
    opcode_mov_sreg_to_reg_mem,
    opcode_mov_sreg_to_reg_mem,
    opcode_movsx,
    opcode_movzx,
    opcode_push_reg_mem,
    opcode_push_reg_short,
    opcode_push_sreg_2,
    opcode_push_sreg_3,
    opcode_push_imm,
    opcode_push_all,
    opcode_pop_reg_mem,
    opcode_pop_reg_short,
    opcode_pop_sreg_2,
    opcode_pop_sreg_3,
    opcode_pop_all,
    opcode_xchg_reg_mem_with_reg,
    opcode_xchg_reg_with_acc_short,
    opcode_xchg_in_fix,
    opcode_xchg_in_var,
    opcode_xchg_out_fix,
    opcode_xchg_out_var
};

// logic [ 1:0] mod;
// logic [ 2:0] rm;
// logic        w;
// logic [ 1:0] segment;
// logic [24:0] base;
// logic [24:0] index;
// logic [24:0] scale;
// logic [ 3:0] imm;
// logic [ 7:0] instruction_mod_rm;
// logic        w;
// logic [`info_bit_width_len-1:0] info_bit_width = `info_bit_width_16;
// logic [`info_reg_seg_len-1:0] info_segment_reg;
// logic [`info_reg_gpr_len-1:0] info_base_reg;
// logic [`info_reg_gpr_len-1:0] info_index_reg;
// logic [`info_displacement_len-1:0] info_displacement;
// logic        sib_is_present;
// decode_mod_rm decode_mod_rm_inst (
//     // input
//     .instruction ( instruction_mod_rm ) ,
//     .w ( w ) ,
//     .info_bit_width ( info_bit_width ),
//     // output
//     .info_segment_reg ( info_segment_reg ),
//     .info_base_reg ( info_base_reg ),
//     .info_index_reg ( info_index_reg ),
//     .info_displacement ( info_displacement ),
//     .sib_is_present ( sib_is_present )
// );

// always_comb begin
//     unique casez (instruction[0])
//         8'b1000_100? : begin
//             info_opcode <= `info_opcode_mov_reg_to_reg_mem;
//             w <= instruction[0][0];
//             instruction_mod_rm <= instruction[0];
//         end
//         8'b1000_101? : begin
//             info_opcode <= `info_opcode_mov_reg_mem_to_reg;
//             w <= instruction[0][0];
//         end
//         8'b1100_011? : begin
//             unique casez (instruction[1][5:3])
//                 3'b000 : begin
//                     info_opcode <= `info_opcode_mov_imm_to_reg_mem;
//                     w <= instruction[0][0];
//                 end
//                 default: begin
//                     info_opcode <= `info_opcode_invalid;
//                 end
//             endcase
//         end
//         default: begin
//             info_opcode <= `info_opcode_invalid;
//         end
//     endcase
// end

// logic [7:0] instr_slice [4] = {
//     instruction[31:24],
//     instruction[23:16],
//     instruction[15: 8],
//     instruction[ 7: 0]
// };

// localparam
// i386_op_mov_r_to_rm = 3'b001 << 2,
// i386_op_mov_rm_to_r = 3'b001 << 1,
// i386_op_mov_imm_to_rm = 3'b001 << 0,
// i386_op_invalid = 3'b000
// ;

// always_comb begin
//     unique casez (op_info)
//         i386_op_mov_r_to_rm : begin
//             mod <= instr_slice[1][7:5];
//             rm <= instr_slice[1][2:0];
//         end
//         i386_op_mov_rm_to_r : begin
//             mod <= instr_slice[1][7:5];
//             rm <= instr_slice[1][2:0];
//         end
//         i386_op_mov_imm_to_rm : begin
//             mod <= instr_slice[1][7:5];
//             rm <= instr_slice[1][2:0];
//         end
//         default: begin
//             default_case
//         end
//     endcase
// end

endmodule