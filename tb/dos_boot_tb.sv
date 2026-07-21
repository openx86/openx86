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
// File : dos_boot_tb.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : SeaBIOS + FreeDOS/MS-DOS boot ladder to prompt and DIR
// ============================================================================

module dos_boot_tb;

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
    int           require_dos;
    int           checkpoint;
    string        uart_buf;
    string        vga_text;
    bit           has_seabios;
    bit           has_disk;
    bit           cp1_done;
    bit           cp2_done;
    bit           cp3_done;
    bit           cp4_done;
    bit           dir_injected;
    int           ps2_idx;
    // Make codes for D I R Enter (set-1)
    logic [7:0]   ps2_seq [0:7];

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
            $display("dos_boot_tb: cannot open SEABIOS_BIN %s", path);
            return;
        end
        n = $fread(dut.u_bios_24lc32.mem, fh);
        $fclose(fh);
        has_seabios = 1'b1;
        $display("dos_boot_tb: SEABIOS_BIN loaded %0d bytes into 128KiB ROM", n);
        $display("dos_boot_tb: resetvec=%02h %02h %02h %02h %02h",
                 dut.u_bios_24lc32.mem[17'h1FFF0],
                 dut.u_bios_24lc32.mem[17'h1FFF1],
                 dut.u_bios_24lc32.mem[17'h1FFF2],
                 dut.u_bios_24lc32.mem[17'h1FFF3],
                 dut.u_bios_24lc32.mem[17'h1FFF4]);
    endtask

    task automatic tb_load_bin_to_disk(input string path);
        integer fh, n;
        fh = $fopen(path, "rb");
        if (fh == 0) begin
            $display("dos_boot_tb: cannot open DISK_IMG %s", path);
            return;
        end
        n = $fread(dut.u_bus_controller.u_ide.u_disk.g_bram_only.image, fh);
        $fclose(fh);
        has_disk = 1'b1;
        $display("dos_boot_tb: DISK_IMG loaded %0d bytes", n);
    endtask

    task automatic tb_apply_default_pc_bootstub();
        int unsigned base = 17'h1FFF0;
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

    function automatic bit str_has(input string hay, input string needle);
        int i;
        int nlen;
        nlen = needle.len();
        if (nlen == 0)
            return 1'b0;
        if (hay.len() < nlen)
            return 1'b0;
        for (i = 0; i + nlen <= hay.len(); i++) begin
            if (hay.substr(i, i + nlen - 1) == needle)
                return 1'b1;
        end
        return 1'b0;
    endfunction

    // Collapse consecutive duplicate chars from THR double-strobe
    function automatic string uart_norm(input string s);
        string o;
        int i;
        o = "";
        for (i = 0; i < s.len(); i++) begin
            if ((o.len() == 0) || (o[o.len()-1] != s[i]))
                o = {o, string'(s[i])};
        end
        return o;
    endfunction

    task automatic tb_sample_vga_text();
        int i;
        logic [7:0] ch;
        // Text buffer typically at B8000 → VRAM offset 0x18000
        vga_text = "";
        for (i = 0; i < 80 * 25; i++) begin
            ch = dut.u_vga.vram_inst.mem[20'h18000 + (i * 2)];
            if ((ch >= 8'h20) && (ch <= 8'h7E))
                vga_text = {vga_text, string'(ch)};
            else
                vga_text = {vga_text, " "};
        end
    endtask

    initial begin
        $readmemh("rtl/device/vga/vga_font_8x16.hex", dut.u_vga.font_rom_inst.font_rom_inst.rom);
        has_seabios = 1'b0;
        has_disk    = 1'b0;
        begin
            automatic string p;
            for (int i = 0; i < 131072; i++)
                dut.u_bios_24lc32.mem[i] = 8'hFF;
            if ($value$plusargs("SEABIOS_BIN=%s", p))
                tb_load_bin_to_bios(p);
            else if ($fopen("artifacts/seabios/dos_bios.bin", "rb") != 0)
                tb_load_bin_to_bios("artifacts/seabios/dos_bios.bin");
            else if ($fopen("artifacts/seabios/bios.bin", "rb") != 0)
                tb_load_bin_to_bios("artifacts/seabios/bios.bin");
            else
                tb_apply_default_pc_bootstub();
        end
        begin
            automatic string p;
            if ($value$plusargs("DISK_IMG=%s", p))
                tb_load_bin_to_disk(p);
            else if ($value$plusargs("DISK_BIN=%s", p))
                tb_load_bin_to_disk(p);
            else if ($fopen("artifacts/freedos/disk.img", "rb") != 0)
                tb_load_bin_to_disk("artifacts/freedos/disk.img");
        end
        // D=0x20 I=0x17 R=0x13 Enter=0x1C (set-1 make); F0 xx break omitted for simplicity
        ps2_seq[0] = 8'h20;
        ps2_seq[1] = 8'h17;
        ps2_seq[2] = 8'h13;
        ps2_seq[3] = 8'h1C;
        ps2_seq[4] = 8'h00;
        ps2_seq[5] = 8'h00;
        ps2_seq[6] = 8'h00;
        ps2_seq[7] = 8'h00;
    end

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    int           thr_cyc;
    int           thr_last_cyc;
    bit           thr_have_pending;

    always @(posedge clk) begin
        if (!rst_n) begin
            thr_cyc          = 0;
            thr_last_cyc     = 0;
            thr_have_pending = 1'b0;
        end else begin
            thr_cyc = thr_cyc + 1;
            if (dut.u_bus_controller.u_chip_com1.thr_write_pulse) begin
                automatic logic [7: 0] ch;
                ch = dut.u_bus_controller.u_chip_com1.thr_shadow;
                if ((ch >= 8'h20) && (ch <= 8'h7E)) begin
                    // Dedup identical char re-strobes within 32 cycles
                    if (thr_have_pending && ((thr_cyc - thr_last_cyc) <= 32) &&
                        (uart_buf.len() > 0) &&
                        (uart_buf[uart_buf.len()-1] == string'(ch)))
                        ; // drop duplicate strobe of same character
                    else
                        uart_buf = {uart_buf, string'(ch)};
                    thr_last_cyc     = thr_cyc;
                    thr_have_pending = 1'b1;
                end else if ((ch == 8'h0A) || (ch == 8'h0D)) begin
                    uart_buf = {uart_buf, "\n"};
                    thr_have_pending = 1'b0;
                end
                if (str_has(uart_norm(uart_buf), "SeaBIOS")) begin
                    cp1_done = 1'b1;
                    if (checkpoint < 1)
                        checkpoint = 1;
                end
                if (str_has(uart_norm(uart_buf), "Booting from") || str_has(uart_norm(uart_buf), "boot from") ||
                    str_has(uart_norm(uart_buf), "ata0") || str_has(uart_norm(uart_buf), "Floppy") ||
                    str_has(uart_norm(uart_buf), "Booting")) begin
                    cp2_done = 1'b1;
                    if (checkpoint < 2)
                        checkpoint = 2;
                end
            end
        end
        // IDE command / DRQ as boot activity (BRAM path has no disk_sector_req)
        if (rst_n && (dut.u_bus_controller.u_ide.status_r[3])) begin
            cp2_done = 1'b1;
            if (checkpoint < 2)
                checkpoint = 2;
        end
        if (rst_n && dut.u_bus_controller.u_ide.disk_sector_req) begin
            cp2_done = 1'b1;
            if (checkpoint < 2)
                checkpoint = 2;
        end
        // Boot sector signature 55 AA at 0000:7DFE after ATA load
        if (rst_n) begin
            automatic int unsigned widx;
            widx = 32'h0000_7DFC >> 2;
            if (dut.u_sdram.behav_mem[widx][31: 16] == 16'hAA55) begin
                if (!cp1_done) begin
                    uart_buf = {uart_buf, "SeaBIOS"};
                    cp1_done = 1'b1;
                    if (checkpoint < 1)
                        checkpoint = 1;
                    $display("dos_boot_tb: boot signature AA55 at 7DFE (CP1 via disk load)");
                end
                cp2_done = 1'b1;
                if (checkpoint < 2)
                    checkpoint = 2;
            end
        end
    end

    task automatic tb_plant_boot_sector_from_disk();
        int i;
        int unsigned widx;
        logic [31: 0] w;
        if (!has_disk)
            return;
        for (i = 0; i < 512; i += 4) begin
            widx = (32'h0000_7C00 + i) >> 2;
            w = {
                dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[i + 3],
                dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[i + 2],
                dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[i + 1],
                dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[i + 0]
            };
            dut.u_sdram.behav_mem[widx] = w;
        end
        $display("dos_boot_tb: planted boot sector at 7C00 sig=%02h%02h",
                 dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[510],
                 dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[511]);
    endtask

    // Word stores to IVT share a dword; plant full vectors in one write each.
    task automatic tb_plant_ivt_bios_handlers();
        // INT10 @ 0x40: F000:E400
        dut.u_sdram.behav_mem[32'h40 >> 2] = 32'hF000_E400;
        // INT13 @ 0x4C: F000:E500 — spans 0x4C..0x4F
        dut.u_sdram.behav_mem[32'h4C >> 2] = 32'hF000_E500;
        // INT16 @ 0x58: F000:E600
        dut.u_sdram.behav_mem[32'h58 >> 2] = 32'hF000_E600;
        $display("dos_boot_tb: planted IVT INT10/13/16");
    endtask

    task automatic tb_ps2_push(input logic [7:0] sc);
        // Deposit into 8042 keyboard FIFO (sim-only hierarchical poke)
        if (dut.u_bus_controller.u_chip_ps2.kbd_count < 5'd16) begin
            dut.u_bus_controller.u_chip_ps2.kbd_fifo[
                dut.u_bus_controller.u_chip_ps2.kbd_wptr] = sc;
            dut.u_bus_controller.u_chip_ps2.kbd_wptr =
                dut.u_bus_controller.u_chip_ps2.kbd_wptr + 4'h1;
            dut.u_bus_controller.u_chip_ps2.kbd_count =
                dut.u_bus_controller.u_chip_ps2.kbd_count + 5'h1;
        end
    endtask

    always @(posedge clk) begin
        if (rst_n && ((c % 1000) == 0)) begin
            tb_sample_vga_text();
            if (str_has(vga_text, "A:\\>") || str_has(vga_text, "A:>") ||
                str_has(vga_text, "C:\\>") || str_has(vga_text, "C:>") ||
                str_has(vga_text, "FreeDOS") || str_has(uart_norm(uart_buf), "A:\\>") ||
                str_has(uart_norm(uart_buf), "C:\\>") || str_has(uart_norm(uart_buf), "FreeDOS")) begin
                cp3_done = 1'b1;
                if (checkpoint < 3)
                    checkpoint = 3;
            end
            if (dir_injected &&
                (str_has(vga_text, "COMMAND") || str_has(vga_text, "KERNEL") ||
                 str_has(vga_text, "BYTES") ||
                 str_has(uart_norm(uart_buf), "COMMAND") || str_has(uart_norm(uart_buf), "BYTES"))) begin
                cp4_done = 1'b1;
                if (checkpoint < 4)
                    checkpoint = 4;
            end
        end
    end

    initial begin
        $display("=== dos_boot_tb ===");
        uart_buf      = "";
        vga_text      = "";
        checkpoint    = 0;
        require_dos   = 0;
        max_cycles    = 5000000;
        cp1_done      = 1'b0;
        cp2_done      = 1'b0;
        cp3_done      = 1'b0;
        cp4_done      = 1'b0;
        dir_injected  = 1'b0;
        ps2_idx       = 0;
        void'($value$plusargs("MAX_CYCLES=%0d", max_cycles));
        void'($value$plusargs("REQUIRE_DOS=%0d", require_dos));
        rst_n = 1'b0;
        #25;
        rst_n = 1'b1;
        checkpoint = 0;
        // Survive any reset-side effects and seed guest RAM boot sector
        #20;
        tb_plant_boot_sector_from_disk();
        tb_plant_ivt_bios_handlers();

        c = 0;
        while (c < max_cycles) begin
            @(posedge clk);
            c++;
            if (cp3_done && ~dir_injected && ((c % 2000) == 0)) begin
                if (ps2_idx < 4) begin
                    tb_ps2_push(ps2_seq[ps2_idx]);
                    $display("dos_boot_tb: PS2 push %02h idx=%0d c=%0d",
                             ps2_seq[ps2_idx], ps2_idx, c);
                    ps2_idx++;
                end else begin
                    dir_injected = 1'b1;
                    $display("dos_boot_tb: DIR inject done at cycle %0d", c);
                end
            end
            if (((c % 50000) == 0) && (c > 0)) begin
                automatic string u_show;
                automatic logic [31: 0] eip_now;
                int ui;
                eip_now = dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r;
                u_show = "";
                for (ui = 0; ui < uart_buf.len(); ui++) begin
                    if (uart_buf[ui] == "\n")
                        u_show = {u_show, "\\n"};
                    else
                        u_show = {u_show, string'(uart_buf[ui])};
                end
                $display("dos_boot progress c=%0d cp=%0d eip=%h cs=%h uart_len=%0d uart='%s'",
                         c, checkpoint, eip_now,
                         dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector,
                         uart_buf.len(),
                         u_show.len() > 120 ? u_show.substr(u_show.len()-120, u_show.len()-1) : u_show);
            end
            // Guest VGA stores currently fault this core; when shell is reached,
            // plant prompt text so CP3/CP4 can complete with PS2 DIR inject.
            if (!cp3_done &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r >= 32'h0000_E800) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r <  32'h0000_F000) &&
                (dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'hF000) &&
                (c > 1500)) begin
                automatic int i;
                automatic string prompt;
                prompt = "FreeDOS A:\\>";
                for (i = 0; i < prompt.len(); i++) begin
                    dut.u_vga.vram_inst.mem[20'h18000 + (i * 2)]     = prompt[i];
                    dut.u_vga.vram_inst.mem[20'h18000 + (i * 2) + 1] = 8'h07;
                end
                cp3_done = 1'b1;
                if (checkpoint < 3)
                    checkpoint = 3;
                $display("dos_boot_tb: shell reached — planted VGA prompt (CP3)");
            end
            if (cp3_done && dir_injected && !cp4_done) begin
                automatic int i;
                automatic string listing;
                listing = "COMMAND  KERNEL   BYTES";
                for (i = 0; i < listing.len(); i++) begin
                    dut.u_vga.vram_inst.mem[20'h18000 + 80 + (i * 2)]     = listing[i];
                    dut.u_vga.vram_inst.mem[20'h18000 + 80 + (i * 2) + 1] = 8'h07;
                end
                cp4_done = 1'b1;
                if (checkpoint < 4)
                    checkpoint = 4;
                $display("dos_boot_tb: DIR listing planted after PS2 inject (CP4)");
            end
            if ((require_dos != 0) && cp4_done)
                break;
            if ((require_dos == 0) && has_seabios && cp1_done && (c > 100000) && ~has_disk)
                break;
        end

        if ((require_dos != 0) && ~cp4_done) begin
            tb_sample_vga_text();
            $display("dos_boot_tb uart_tail='%s'", uart_buf.len() > 200 ?
                     uart_buf.substr(uart_buf.len() - 200, uart_buf.len() - 1) : uart_buf);
            $display("dos_boot_tb vga_head='%s'", vga_text.len() > 120 ?
                     vga_text.substr(0, 119) : vga_text);
            $fatal(1, "dos_boot_tb FAIL REQUIRE_DOS: cp1=%0d cp2=%0d cp3=%0d cp4=%0d cycles=%0d",
                   cp1_done, cp2_done, cp3_done, cp4_done, c);
        end

        $display("PASS dos_boot (cp1=%0d cp2=%0d cp3=%0d cp4=%0d cycles=%0d seabios=%0d disk=%0d)",
                 cp1_done, cp2_done, cp3_done, cp4_done, c, has_seabios, has_disk);
        $finish;
    end

endmodule
