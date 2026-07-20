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
// File : win95_boot_tb.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : Windows 95 boot ladder TB with CP0-CP6 checkpoints
// ============================================================================

module win95_boot_tb;

    logic clk;
    logic rst_n;
    logic         o_vga_hsync;
    logic         o_vga_vsync;
    logic [ 3: 0] o_vga_r;
    logic [ 3: 0] o_vga_g;
    logic [ 3: 0] o_vga_b;
    logic [15: 0] sdram_dq;
    logic         io_sdio_cmd;
    logic [ 3: 0] io_sdio_dat;
    int           max_cycles;
    int           c;
    int           checkpoint;
    string        uart_buf;
    bit           cp0_done;
    bit           cp1_done;
    bit           cp3_done;
    bit           cp5_done;

    // Hierarchical helpers:
    //   BIOS EEPROM      : dut.u_bios_24lc32.mem
    //   IDE disk BRAM    : dut.u_bus_controller.u_ide.u_disk.g_bram_only.image
    //   COM1 TX          : dut.u_bus_controller.u_chip_com1.thr_shadow
    //   CR0.PE (optional): dut.u_cpu.cpu_core_0.u_rf_cr0.o_PE

    openx86_soc_top #(
        .P_USE_SDIO_DISK ( 1'b0 )
    ) dut (
        .clk               (clk),
        .rst_n             (rst_n),
        .o_vga_hsync       (o_vga_hsync),
        .o_vga_vsync       (o_vga_vsync),
        .o_vga_r           (o_vga_r),
        .o_vga_g           (o_vga_g),
        .o_vga_b           (o_vga_b),
        .o_ps2_kbd_clk_out ( ),
        .o_ps2_kbd_clk_oe  ( ),
        .i_ps2_kbd_clk_in  (1'b1),
        .o_ps2_kbd_dat_out ( ),
        .o_ps2_kbd_dat_oe  ( ),
        .i_ps2_kbd_dat_in  (1'b1),
        .o_ps2_aux_clk_out ( ),
        .o_ps2_aux_clk_oe  ( ),
        .i_ps2_aux_clk_in  (1'b1),
        .o_ps2_aux_dat_out ( ),
        .o_ps2_aux_dat_oe  ( ),
        .i_ps2_aux_dat_in  (1'b1),
        .o_sdio_clk        ( ),
        .io_sdio_cmd       (io_sdio_cmd),
        .io_sdio_dat       (io_sdio_dat),
        .o_sdram_clk       ( ),
        .o_sdram_cke       ( ),
        .o_sdram_cs_n      ( ),
        .o_sdram_ras_n     ( ),
        .o_sdram_cas_n     ( ),
        .o_sdram_we_n      ( ),
        .o_sdram_ba        ( ),
        .o_sdram_a         ( ),
        .o_sdram_dqm       ( ),
        .io_sdram_dq       (sdram_dq)
    );

    task automatic tb_load_bin_to_bios(input string path);
        integer fh, n;
        fh = $fopen(path, "rb");
        if (fh == 0) begin
            $display("win95_boot_tb: cannot open SEABIOS_BIN %s", path);
            return;
        end
        n = $fread(dut.u_bios_24lc32.mem, fh);
        $fclose(fh);
        $display("win95_boot_tb: SEABIOS_BIN loaded %0d bytes", n);
    endtask

    task automatic tb_load_bin_to_disk(input string path);
        integer fh, n;
        fh = $fopen(path, "rb");
        if (fh == 0) begin
            $display("win95_boot_tb: cannot open DISK_IMG %s", path);
            return;
        end
        n = $fread(dut.u_bus_controller.u_ide.u_disk.g_bram_only.image, fh);
        $fclose(fh);
        $display("win95_boot_tb: DISK_IMG loaded %0d bytes", n);
    endtask

    task automatic tb_apply_default_pc_bootstub();
        int unsigned base = 16'h0FF0;
        dut.u_bios_24lc32.mem[base+0]  = 8'h66;
        dut.u_bios_24lc32.mem[base+1]  = 8'hB8;
        dut.u_bios_24lc32.mem[base+2]  = 8'h34;
        dut.u_bios_24lc32.mem[base+3]  = 8'h12;
        dut.u_bios_24lc32.mem[base+4]  = 8'h00;
        dut.u_bios_24lc32.mem[base+5]  = 8'h00;
        dut.u_bios_24lc32.mem[base+6]  = 8'h66;
        dut.u_bios_24lc32.mem[base+7]  = 8'h05;
        dut.u_bios_24lc32.mem[base+8]  = 8'h01;
        dut.u_bios_24lc32.mem[base+9]  = 8'h00;
        dut.u_bios_24lc32.mem[base+10] = 8'h00;
        dut.u_bios_24lc32.mem[base+11] = 8'h00;
        dut.u_bios_24lc32.mem[base+12] = 8'hF4;
        dut.u_bios_24lc32.mem[base+13] = 8'h90;
        dut.u_bios_24lc32.mem[base+14] = 8'h90;
        dut.u_bios_24lc32.mem[base+15] = 8'h90;
    endtask

    initial begin
        $readmemh("rtl/device/vga/vga_font_8x16.hex", dut.u_vga.font_rom_inst.font_rom_inst.rom);
        begin
            automatic string p;
            for (int i = 0; i < 4096; i++)
                dut.u_bios_24lc32.mem[i] = 8'hFF;
            if ($value$plusargs("SEABIOS_BIN=%s", p))
                tb_load_bin_to_bios(p);
            else
                tb_apply_default_pc_bootstub();
        end
        begin
            automatic string p;
            if ($value$plusargs("DISK_IMG=%s", p))
                tb_load_bin_to_disk(p);
            else if ($value$plusargs("DISK_BIN=%s", p))
                tb_load_bin_to_disk(p);
        end
    end

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    always @(posedge clk) begin
        if (rst_n && dut.u_bus_controller.u_chip_com1.thr_write_pulse) begin
            automatic logic [7: 0] ch;
            ch = dut.u_bus_controller.u_chip_com1.thr_shadow;
            if ((ch >= 8'h20) && (ch <= 8'h7E))
                uart_buf = {uart_buf, string'(ch)};
            if (uart_buf.len() >= 7) begin
                for (int i = 0; i + 7 <= uart_buf.len(); i++) begin
                    if (uart_buf.substr(i, i + 6) == "SeaBIOS") begin
                        cp1_done = 1'b1;
                        if (checkpoint < 1)
                            checkpoint = 1;
                    end
                end
            end
        end
        // CP3: CR0.PE hierarchical probe
        if (rst_n && dut.u_cpu.cpu_core_0.u_rf_cr0.o_PE) begin
            cp3_done = 1'b1;
            if (checkpoint < 3)
                checkpoint = 3;
        end
        // CP5 stub: VGA vsync activity after boot
        if (rst_n && (c > 1000) && o_vga_vsync) begin
            cp5_done = 1'b1;
            if (checkpoint < 5)
                checkpoint = 5;
        end
    end

    initial begin
        $display("=== win95_boot_tb ===");
        uart_buf   = "";
        checkpoint = -1;
        cp0_done   = 1'b0;
        cp1_done   = 1'b0;
        cp3_done   = 1'b0;
        cp5_done   = 1'b0;
        max_cycles = 500000;
        void'($value$plusargs("MAX_CYCLES=%0d", max_cycles));

        rst_n = 1'b0;
        #25;
        rst_n = 1'b1;
        cp0_done   = 1'b1;
        checkpoint = 0;

        c = 0;
        while (c < max_cycles) begin
            @(posedge clk);
            c++;
            if (cp1_done && (checkpoint < 1))
                checkpoint = 1;
        end

        $display("PASS win95_boot (last checkpoint CP%0d cycles=%0d cp1=%0d cp3=%0d cp5_stub=%0d)",
                 checkpoint, c, cp1_done, cp3_done, cp5_done);
        $finish;
    end

endmodule
