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

module disp_imm (
    // 从位移起点开始的连续字节窗口（最多 8B，覆盖 disp+imm 组合）
    input  logic [ 7: 0][ 7: 0] i_instruction, // 输入信号
    input  logic          i_displacement_size_1, // 输入信号
    input  logic          i_displacement_size_2, // 输入信号
    input  logic          i_displacement_size_4, // 输入信号
    input  logic          i_immediate_size_1, // 输入信号
    input  logic          i_immediate_size_2, // 输入信号
    input  logic          i_immediate_size_4, // 输入信号
    input  logic          i_immediate_size_f, // 输入信号
    output logic [31: 0] o_displacement, // 输出信号
    output logic [31: 0] o_immediate, // 输出信号
    output logic [ 3: 0] o_consume_bytes, // 输出信号
    output logic         o_error // 输出信号
);

logic [ 7: 0] instruction_for_immediate [ 0: 3]; // 立即数字节相对位移后的切片

// 先根据位移宽度截取位移并调整立即数字节起点
always_comb begin
    case (1'b1)
        i_displacement_size_1: begin
            instruction_for_immediate[0] = i_instruction[1];
            instruction_for_immediate[1] = i_instruction[2];
            instruction_for_immediate[2] = i_instruction[3];
            instruction_for_immediate[3] = i_instruction[4];
            o_displacement = {24'b0, i_instruction[0][ 7: 0]};
        end
        i_displacement_size_2: begin
            instruction_for_immediate[0] = i_instruction[2];
            instruction_for_immediate[1] = i_instruction[3];
            instruction_for_immediate[2] = i_instruction[4];
            instruction_for_immediate[3] = i_instruction[5];
            o_displacement = {16'b0, i_instruction[1][ 7: 0], i_instruction[0][ 7: 0]};
        end
        i_displacement_size_4: begin
            instruction_for_immediate[0] = i_instruction[4];
            instruction_for_immediate[1] = i_instruction[5];
            instruction_for_immediate[2] = i_instruction[6];
            instruction_for_immediate[3] = i_instruction[7];
            o_displacement = {i_instruction[3][ 7: 0], i_instruction[2][ 7: 0], i_instruction[1][ 7: 0], i_instruction[0][ 7: 0]};
        end
        default: begin
            instruction_for_immediate[0] = i_instruction[0];
            instruction_for_immediate[1] = i_instruction[1];
            instruction_for_immediate[2] = i_instruction[2];
            instruction_for_immediate[3] = i_instruction[3];
            o_displacement = 32'b0;
        end
    endcase
end

// 立即数：1/2/4 字节零扩或拼 32b（full 模式同 4B）
always_comb begin
    case (1'b1)
        i_immediate_size_1: o_immediate = {24'b0, instruction_for_immediate[0][ 7: 0]};
        i_immediate_size_2: o_immediate = {16'b0, instruction_for_immediate[1][ 7: 0], instruction_for_immediate[0][ 7: 0]};
        i_immediate_size_4: o_immediate = {       instruction_for_immediate[3][ 7: 0], instruction_for_immediate[2][ 7: 0], instruction_for_immediate[1][ 7: 0], instruction_for_immediate[0][ 7: 0]};
        i_immediate_size_f: o_immediate = {       instruction_for_immediate[3][ 7: 0], instruction_for_immediate[2][ 7: 0], instruction_for_immediate[1][ 7: 0], instruction_for_immediate[0][ 7: 0]};
        default:               o_immediate = 32'b0;
    endcase
end

logic [ 3: 0] displacement_bytes;
// 统计位移占用字节数
always_comb begin
    case (1'b1)
        i_displacement_size_1: displacement_bytes = 4'h1;
        i_displacement_size_2: displacement_bytes = 4'h2;
        i_displacement_size_4: displacement_bytes = 4'h4;
        // i_displacement_size_full: displacement_bytes = 4'h4;
        default              : displacement_bytes = 4'h0;
    endcase
end

logic [ 3: 0] immediate_bytes;
// 统计立即数占用字节数
always_comb begin
    case (1'b1)
        i_immediate_size_1: immediate_bytes = 4'h1;
        i_immediate_size_2: immediate_bytes = 4'h2;
        i_immediate_size_4: immediate_bytes = 4'h4;
        i_immediate_size_f: immediate_bytes = 4'h4;
        default           : immediate_bytes = 4'h0;
    endcase
end

assign o_consume_bytes = displacement_bytes + immediate_bytes;
// 当前位移/立即数切片路径不产生独立错误码；占位为 0 供上游 OR 聚合
assign o_error          = 1'b0;

endmodule
