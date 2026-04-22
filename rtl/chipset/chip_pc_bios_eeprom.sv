// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : chip_pc_bios_eeprom.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : chip_pc_bios_eeprom module
// ============================================================================

// 24LC32 后端镜像：扩展 ROM（128KB）与系统 BIOS（64KB）线性寻址后按 4KiB 取模映射到同一物理阵列。

module chip_pc_bios_eeprom (
    // =========================
    // system BIOS window interface
    // =========================
    input  logic [15: 0] i_sys_bios_byte_off,
    output logic [31: 0] o_sys_bios_rdata,

    // =========================
    // extended ROM window interface
    // =========================
    input  logic [16: 0] i_ext_bios_byte_off,
    output logic [31: 0] o_ext_bios_rdata,

    // =========================
    // clock and reset
    // =========================
    input  logic         clk,
    input  logic         rst_n
);

	// ============================================================
	// EEPROM physical depth and address mapping
	// ============================================================
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

	// ============================================================
	// combinational read: both windows wrap to 4KiB physical depth
	// ============================================================
	always_comb begin : comb_address_mapping
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

	// ============================================================
	// power-up initialization to erased state
	// ============================================================
	integer i;
	initial begin
		for (i = 0; i < EEPROM_BYTES; i = i + 1)
			mem[i] = 8'hFF;
	end

endmodule
