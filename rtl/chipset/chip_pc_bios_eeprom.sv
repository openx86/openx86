/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_pc_bios_eeprom.
*/
// 24LC32 后端镜像：扩展 ROM（128KB）与系统 BIOS（64KB）线性寻址后按 4KiB 取模映射到同一物理阵列。

module chip_pc_bios_eeprom (
    input  logic [15: 0] i_sys_bios_byte_off, // 系统 BIOS 窗口内字偏移（0x0000–0x0FFF）
    input  logic [16: 0] i_ext_bios_byte_off, // 扩展 ROM 窗口内字节偏移（0x00000–0x1FFFF）
    output logic [31: 0] o_sys_bios_rdata,    // 系统 BIOS 窗口读回数据（字对齐）
    output logic [31: 0] o_ext_bios_rdata,    // 扩展 ROM 窗口读回数据
    input  logic         clk,                 // 时钟信号
    input  logic         rst_n                // 复位信号
);

	// EEPROM 物理深度与扩展 ROM 线性尺寸（镜像用）
	localparam int unsigned EEPROM_BYTES   = 4096;

	logic [ 7: 0] mem [0:EEPROM_BYTES-1];
	logic [11: 0] ext_a0;
	logic [11: 0] ext_a1;
	logic [11: 0] ext_a2;
	logic [11: 0] ext_a3;
	logic [11: 0] sys_a0;
	logic [11: 0] sys_a1;
	logic [11: 0] sys_a2;
	logic [11: 0] sys_a3;

	// 组合读：扩展 ROM / 系统 BIOS 都按 4KiB 物理深度回绕映射。
	always_comb begin
		ext_a0 = i_ext_bios_byte_off[11: 0];
		ext_a1 = i_ext_bios_byte_off[11: 0] + 12'd1;
		ext_a2 = i_ext_bios_byte_off[11: 0] + 12'd2;
		ext_a3 = i_ext_bios_byte_off[11: 0] + 12'd3;

		sys_a0 = i_sys_bios_byte_off[11: 0];
		sys_a1 = i_sys_bios_byte_off[11: 0] + 12'd1;
		sys_a2 = i_sys_bios_byte_off[11: 0] + 12'd2;
		sys_a3 = i_sys_bios_byte_off[11: 0] + 12'd3;

		o_ext_bios_rdata = {mem[ext_a3], mem[ext_a2], mem[ext_a1], mem[ext_a0]};
		o_sys_bios_rdata = {mem[sys_a3], mem[sys_a2], mem[sys_a1], mem[sys_a0]};
	end

	integer i;
	// 上电默认擦除态（可由 TB 再写入镜像）。
	initial begin
		for (i = 0; i < EEPROM_BYTES; i = i + 1)
			mem[i] = 8'hFF;
	end

endmodule
