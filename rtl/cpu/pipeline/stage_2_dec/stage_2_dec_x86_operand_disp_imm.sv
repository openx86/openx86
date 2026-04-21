/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements disp_imm.
*/
/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: stage_2_dec_x86_operand_disp_imm
create at: 2022-02-25 04:29:04
description: decode the s-i-b means scale-index-base
*/

/* ref:
Intel486(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
6.2.3.4 ENCODING OF ADDRESS MODE
*/

`include "openx86_defs.h.sv"

module stage_2_dec_x86_operand_disp_imm (
    // 从位移起点开始的连续字节窗口（最多 8B，覆盖 disp+imm 组合）
    input  logic [ 7: 0][ 7: 0] i_instruction_bytes,
    input  logic          i_disp_size_1b,
    input  logic          i_disp_size_2b,
    input  logic          i_disp_size_4b,
    input  logic          i_imm_size_1b,
    input  logic          i_imm_size_2b,
    input  logic          i_imm_size_4b,
    input  logic          i_imm_size_full,
    output logic [31: 0] o_disp_value,
    output logic [31: 0] o_imm_value,
    output logic [ 3: 0] o_consume_byte_count,
    output logic         o_decode_error
);

logic [ 7: 0] instruction_for_immediate [ 0: 3]; // 立即数字节相对位移后的切片

// 先根据位移宽度截取位移并调整立即数字节起点
always_comb begin
    case (1'b1)
        i_disp_size_1b: begin
            instruction_for_immediate[0] = i_instruction_bytes[1];
            instruction_for_immediate[1] = i_instruction_bytes[2];
            instruction_for_immediate[2] = i_instruction_bytes[3];
            instruction_for_immediate[3] = i_instruction_bytes[4];
            o_disp_value = {24'b0, i_instruction_bytes[0][ 7: 0]};
        end
        i_disp_size_2b: begin
            instruction_for_immediate[0] = i_instruction_bytes[2];
            instruction_for_immediate[1] = i_instruction_bytes[3];
            instruction_for_immediate[2] = i_instruction_bytes[4];
            instruction_for_immediate[3] = i_instruction_bytes[5];
            o_disp_value = {16'b0, i_instruction_bytes[1][ 7: 0], i_instruction_bytes[0][ 7: 0]};
        end
        i_disp_size_4b: begin
            instruction_for_immediate[0] = i_instruction_bytes[4];
            instruction_for_immediate[1] = i_instruction_bytes[5];
            instruction_for_immediate[2] = i_instruction_bytes[6];
            instruction_for_immediate[3] = i_instruction_bytes[7];
            o_disp_value = {i_instruction_bytes[3][ 7: 0], i_instruction_bytes[2][ 7: 0], i_instruction_bytes[1][ 7: 0], i_instruction_bytes[0][ 7: 0]};
        end
        default: begin
            instruction_for_immediate[0] = i_instruction_bytes[0];
            instruction_for_immediate[1] = i_instruction_bytes[1];
            instruction_for_immediate[2] = i_instruction_bytes[2];
            instruction_for_immediate[3] = i_instruction_bytes[3];
            o_disp_value = 32'b0;
        end
    endcase
end

// 立即数：1/2/4 字节零扩或拼 32b（full 模式同 4B）
always_comb begin
    case (1'b1)
        i_imm_size_1b:  o_imm_value = {24'b0, instruction_for_immediate[0][ 7: 0]};
        i_imm_size_2b:  o_imm_value = {16'b0, instruction_for_immediate[1][ 7: 0], instruction_for_immediate[0][ 7: 0]};
        i_imm_size_4b:  o_imm_value = {       instruction_for_immediate[3][ 7: 0], instruction_for_immediate[2][ 7: 0], instruction_for_immediate[1][ 7: 0], instruction_for_immediate[0][ 7: 0]};
        i_imm_size_full: o_imm_value = {       instruction_for_immediate[3][ 7: 0], instruction_for_immediate[2][ 7: 0], instruction_for_immediate[1][ 7: 0], instruction_for_immediate[0][ 7: 0]};
        default:         o_imm_value = 32'b0;
    endcase
end

logic [ 3: 0] disp_byte_count;
// 统计位移占用字节数
always_comb begin
    case (1'b1)
        i_disp_size_1b: disp_byte_count = 4'h1;
        i_disp_size_2b: disp_byte_count = 4'h2;
        i_disp_size_4b: disp_byte_count = 4'h4;
        default         : disp_byte_count = 4'h0;
    endcase
end

logic [ 3: 0] imm_byte_count;
// 统计立即数占用字节数
always_comb begin
    case (1'b1)
        i_imm_size_1b:  imm_byte_count = 4'h1;
        i_imm_size_2b:  imm_byte_count = 4'h2;
        i_imm_size_4b:  imm_byte_count = 4'h4;
        i_imm_size_full: imm_byte_count = 4'h4;
        default          : imm_byte_count = 4'h0;
    endcase
end

assign o_consume_byte_count = disp_byte_count + imm_byte_count;
// 当前位移/立即数切片路径不产生独立错误码；占位为 0 供上游 OR 聚合
assign o_decode_error       = 1'b0;

endmodule
