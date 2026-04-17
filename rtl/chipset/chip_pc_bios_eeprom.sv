/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_pc_bios_eeprom.
*/

module chip_pc_bios_eeprom (
	input  logic [15:  0] i_sys_bios_byte_off,
	input  logic [16:  0] i_ext_bios_byte_off,
	output logic [31:  0] o_sys_bios_rdata,
	output logic [31:  0] o_ext_bios_rdata,
	input  logic        reset_n,
	input  logic        clock);

	localparam int unsigned EEPROM_BYTES   = 4096;
	localparam int unsigned EXT_BIOS_BYTES = 128 * 1024;

	logic [ 7:  0] mem [0:EEPROM_BYTES-1];

	function automatic int unsigned map_off(input int unsigned off);
		map_off = off % EEPROM_BYTES;
	endfunction

	function automatic logic [31:  0] read_word(input int unsigned byte_off);
		int unsigned a0;
		int unsigned a1;
		int unsigned a2;
		int unsigned a3;
		begin
			a0 = map_off(byte_off + 0);
			a1 = map_off(byte_off + 1);
			a2 = map_off(byte_off + 2);
			a3 = map_off(byte_off + 3);
			read_word = {mem[a3], mem[a2], mem[a1], mem[a0]};
		end
	endfunction

	always_comb begin
		o_ext_bios_rdata = read_word(i_ext_bios_byte_off);
		o_sys_bios_rdata = read_word(EXT_BIOS_BYTES + i_sys_bios_byte_off);
	end

	integer i;
	initial begin
		for (i = 0; i < EEPROM_BYTES; i = i + 1)
			mem[i] = 8'hFF;
	end

endmodule
