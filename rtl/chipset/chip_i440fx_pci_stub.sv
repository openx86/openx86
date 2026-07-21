// ============================================================================
// Copyright (c) 2026 Chang Wei
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
// File : chip_i440fx_pci_stub.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : Minimal i440FX host-bridge config (CF8/CFC) for SeaBIOS PAM/QEMU detect
// ============================================================================

module chip_i440fx_pci_stub (
    input  logic         i_cs_n,
    input  logic         i_rd_n,
    input  logic         i_wr_n,
    input  logic         i_addr_n,   // 0=CF8 address, 1=CFC data
    input  logic [31: 0] i_d,
    output logic [31: 0] o_d,
    input  logic         clk,
    input  logic         rst_n
);

    localparam logic [15: 0] LP_VENDOR = 16'h8086;
    localparam logic [15: 0] LP_DEVICE = 16'h1237;
    localparam logic [15: 0] LP_SSVEN  = 16'h1AF4;
    localparam logic [15: 0] LP_SSID   = 16'h1100;

    logic [31: 0] cfg_addr;
    logic [ 7: 0] pam [0: 6];
    logic [ 7: 0] cfg_off;
    logic [31: 0] cfg_dword;
    logic         host_sel;

    assign host_sel = cfg_addr[31] && (cfg_addr[23: 16] == 8'h00) && (cfg_addr[15: 8] == 8'h00);
    assign cfg_off  = {cfg_addr[7: 2], 2'b00};

    always_comb begin
        cfg_dword = 32'hFFFF_FFFF;
        if (host_sel) begin
            unique case (cfg_off)
                8'h00: cfg_dword = {LP_DEVICE, LP_VENDOR};
                8'h08: cfg_dword = 32'h0600_0000; // class host bridge
                8'h0C: cfg_dword = 32'h0000_0000; // header type in byte 2
                8'h2C: cfg_dword = {LP_SSID, LP_SSVEN};
                8'h58: cfg_dword = {pam[2], pam[1], pam[0], 8'h00}; // 59=PAM0..5B=PAM2
                8'h5C: cfg_dword = {pam[6], pam[5], pam[4], pam[3]}; // 5C=PAM3..5F=PAM6
                default: cfg_dword = 32'h0000_0000;
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cfg_addr <= 32'h0;
            pam[0]   <= 8'h10; // PAM0: BIOS RAM present
            pam[1]   <= 8'h11;
            pam[2]   <= 8'h11;
            pam[3]   <= 8'h11;
            pam[4]   <= 8'h11;
            pam[5]   <= 8'h11;
            pam[6]   <= 8'h11;
            o_d      <= 32'hFFFF_FFFF;
        end else begin
            o_d <= 32'hFFFF_FFFF;
            if (~i_cs_n && ~i_wr_n && ~i_addr_n)
                cfg_addr <= {i_d[31: 2], 2'b00};
            if (~i_cs_n && ~i_wr_n && i_addr_n && host_sel) begin
                if (cfg_off == 8'h58) begin
                    pam[0] <= i_d[15: 8];
                    pam[1] <= i_d[23:16];
                    pam[2] <= i_d[31:24];
                end else if (cfg_off == 8'h5C) begin
                    pam[3] <= i_d[ 7: 0];
                    pam[4] <= i_d[15: 8];
                    pam[5] <= i_d[23:16];
                    pam[6] <= i_d[31:24];
                end
            end
            if (~i_cs_n && ~i_rd_n && ~i_addr_n)
                o_d <= cfg_addr;
            if (~i_cs_n && ~i_rd_n && i_addr_n)
                o_d <= cfg_dword;
        end
    end

endmodule
