/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_pc_bios_eeprom.
*/
// 24LC32 后端镜像：扩展 ROM（128KB）与系统 BIOS（64KB）线性寻址后按 4KiB 取模映射到同一物理阵列。

module chip_pc_bios_eeprom (
	input  logic [15: 0] i_sys_bios_byte_off,   // 系统 BIOS 区（64KB）内字节偏移
	input  logic [16: 0] i_ext_bios_byte_off,  // 扩展 ROM 区（128KB）内字节偏移
	output logic [31: 0] o_sys_bios_rdata,       // 系统 BIOS 字读取（小端四字节）
	output logic [31: 0] o_ext_bios_rdata,       // 扩展 ROM 字读取（小端四字节）
	/* verilator lint_off UNUSEDSIGNAL */
	input  logic         rst_n,                // 异步低有效复位（保留接口）
	input  logic         clk                 // 系统时钟（本模型组合读，寄存器未用）
	/* verilator lint_on UNUSEDSIGNAL */
);

	// EEPROM 物理深度与扩展 ROM 线性尺寸（镜像用）
	localparam int unsigned EEPROM_BYTES   = 4096;
	localparam int unsigned EXT_BIOS_BYTES = 128 * 1024;

	logic [ 7: 0] mem [0:EEPROM_BYTES-1];

	// 将线性偏移折回 4KiB 物理索引。
	function automatic int unsigned map_off(input int unsigned off);
		map_off = off % EEPROM_BYTES;
	endfunction

	// 从 byte_off 起读 4 字节拼成 32 位字（小端）。
	function automatic logic [31: 0] read_word(input int unsigned byte_off);
		// map_off 结果落在 0..4095，用 12 位即可，避免 int unsigned 高位的 UNUSEDSIGNAL
		logic [11: 0] a0;
		logic [11: 0] a1;
		logic [11: 0] a2;
		logic [11: 0] a3;
		begin
			a0 = 12'(map_off(byte_off + 0));
			a1 = 12'(map_off(byte_off + 1));
			a2 = 12'(map_off(byte_off + 2));
			a3 = 12'(map_off(byte_off + 3));
			read_word = {mem[a3], mem[a2], mem[a1], mem[a0]};
		end
	endfunction

	// 组合读：两路端口独立译码，系统区在逻辑上接在扩展区之后做取模。
	// 经中间 int unsigned 扩展位宽（避免 Verilator 对 int unsigned'(…) 的解析问题）
	int unsigned r_ext_bios_byte_off;
	int unsigned r_sys_bios_byte_off;
	always_comb begin
		r_ext_bios_byte_off = 32'(i_ext_bios_byte_off);
		r_sys_bios_byte_off = 32'(i_sys_bios_byte_off);
		o_ext_bios_rdata    = read_word(r_ext_bios_byte_off);
		o_sys_bios_rdata    = read_word(EXT_BIOS_BYTES + r_sys_bios_byte_off);
	end

	integer i;
	// 上电默认擦除态（可由 TB 再写入镜像）。
	initial begin
		for (i = 0; i < EEPROM_BYTES; i = i + 1)
			mem[i] = 8'hFF;
	end

endmodule
