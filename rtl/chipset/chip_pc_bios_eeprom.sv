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
//  Description : 128KiB BIOS ROM for E0000–FFFFF (+ C0000 alias)
// ============================================================================

// System/option BIOS: physical 128KiB covering E0000–FFFFF (SeaBIOS ROM_SIZE=128).
// Extended ROM window C0000–DFFFF aliases into the same array (low 17 bits).

module chip_pc_bios_eeprom (
    // =========================
    // system BIOS window interface (E0000–FFFFF, 17-bit offset)
    // =========================
    input  logic [16: 0] i_sys_bios_byte_off,
    output logic [31: 0] o_sys_bios_rdata,
    input  logic         i_sys_bios_we,
    input  logic [31: 0] i_sys_bios_wdata,
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

    localparam int unsigned EEPROM_BYTES = 131072;

    logic [ 7: 0] mem [0:EEPROM_BYTES-1];
    logic [16: 0] ext_a0;
    logic [16: 0] ext_a1;
    logic [16: 0] ext_a2;
    logic [16: 0] ext_a3;
    logic [16: 0] sys_a0;
    logic [16: 0] sys_a1;
    logic [16: 0] sys_a2;
    logic [16: 0] sys_a3;

    always_comb begin : comb_address_mapping
        ext_a0 = i_ext_bios_byte_off;
        ext_a1 = i_ext_bios_byte_off + 17'd1;
        ext_a2 = i_ext_bios_byte_off + 17'd2;
        ext_a3 = i_ext_bios_byte_off + 17'd3;
        sys_a0 = i_sys_bios_byte_off;
        sys_a1 = i_sys_bios_byte_off + 17'd1;
        sys_a2 = i_sys_bios_byte_off + 17'd2;
        sys_a3 = i_sys_bios_byte_off + 17'd3;
        o_ext_bios_rdata = {mem[ext_a3], mem[ext_a2], mem[ext_a1], mem[ext_a0]};
        o_sys_bios_rdata = {mem[sys_a3], mem[sys_a2], mem[sys_a1], mem[sys_a0]};
    end

    // ROM contents are loaded by the testbench / bitstream. Do not use an
    // initial mem[] fill here — it races with TB $fread and can wipe SeaBIOS.
    // Writes enabled for SeaBIOS shadow/PAM bring-up (HaveRunPost, reloc).
    always_ff @(posedge clk) begin
        if (rst_n && i_sys_bios_we) begin
            mem[sys_a0] <= i_sys_bios_wdata[ 7: 0];
            mem[sys_a1] <= i_sys_bios_wdata[15: 8];
            mem[sys_a2] <= i_sys_bios_wdata[23:16];
            mem[sys_a3] <= i_sys_bios_wdata[31:24];
        end
    end

endmodule
