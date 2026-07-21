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
    bit           pe_seen_clear;
    bit           reloc_replanted;
    bit           bootwin_early_logged;
    bit           stubfetch_logged;
    bit           stubfetch_done;
    int unsigned early1fe0_c;
    bit           boot_patched;
    int           pe_clear_c;
    logic [31: 0] last_e2;
    logic [15: 0] last_c2;
    bit           cp4_done;
    bit           dir_injected;
    bit           saw_ide_sector_req;
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
            saw_ide_sector_req = 1'b0;
        end else begin
            thr_cyc = thr_cyc + 1;
            if (dut.u_bus_controller.u_ide.disk_sector_req)
                saw_ide_sector_req = 1'b1;
            if (dut.u_bus_controller.u_chip_com1.thr_write_pulse) begin
                automatic logic [7: 0] ch;
                ch = dut.u_bus_controller.u_chip_com1.thr_shadow;
                if (ch == 8'h4A) begin
                    $display("dos_boot at J: mem7c00=%h sig=%h mem27a00=%h mem27abe=%h stub9000=%h ivt13=%h (plant+invd)",
                             dut.u_sdram.behav_mem[32'h7C00 >> 2],
                             dut.u_sdram.behav_mem[32'h7DFC >> 2][31: 16],
                             dut.u_sdram.behav_mem[32'h27A00 >> 2],
                             dut.u_sdram.behav_mem[32'h27ABC >> 2],
                             dut.u_sdram.behav_mem[32'h9000 >> 2],
                             dut.u_sdram.behav_mem[32'h4C >> 2]);
                    // REQUIRE_DOS=1: guest must self-draw; do not plant boot/IVT.
                    if (require_dos == 0) begin
                        tb_plant_boot_sector_from_disk();
                        begin
                            automatic int si, wi;
                            for (si = 0; si < 64; si++)
                                for (wi = 0; wi < 4; wi++)
                                    dut.u_cpu.u_cache.valid_mem[si][wi] = 1'b0;
                        end
                        // Dword IVT plants (match SeaBIOS entry_* offsets)
                        dut.u_sdram.behav_mem[32'h4C >> 2] = 32'hF000_E3FE;
                        dut.u_sdram.behav_mem[32'h40 >> 2] = 32'hF000_F065;
                        dut.u_sdram.behav_mem[32'h58 >> 2] = 32'hF000_E82E;
                        // Invalidate I/D cache so fetch sees planted SDRAM
                        force dut.u_cpu.invalidate_cache = 1'b1;
                        @(posedge clk);
                        @(posedge clk);
                        release dut.u_cpu.invalidate_cache;
                        $display("dos_boot after plant mem7c00=%h ivt13=%h",
                                 dut.u_sdram.behav_mem[32'h7C00 >> 2],
                                 dut.u_sdram.behav_mem[32'h4C >> 2]);
                    end
                end
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
                if (str_has(uart_buf, "Booting") ||
                    str_has(uart_norm(uart_buf), "Booting from") || str_has(uart_norm(uart_buf), "boot from") ||
                    str_has(uart_norm(uart_buf), "ata0") || str_has(uart_norm(uart_buf), "Floppy") ||
                    str_has(uart_norm(uart_buf), "Booting")) begin
                    cp2_done = 1'b1;
                    if (checkpoint < 2)
                        checkpoint = 2;
                end
            end
        end
        // IDE sector READ DRQ (not IDENTIFY) — BRAM path has no disk_sector_req.
        if (rst_n && cp1_done &&
            !dut.u_bus_controller.u_ide.identify_active &&
            (dut.u_bus_controller.u_ide.status_r[3])) begin
            cp2_done = 1'b1;
            if (checkpoint < 2)
                checkpoint = 2;
        end
        if (rst_n && cp1_done && dut.u_bus_controller.u_ide.disk_sector_req) begin
            cp2_done = 1'b1;
            if (checkpoint < 2)
                checkpoint = 2;
        end
        // Boot sector signature 55 AA at 0000:7DFE after ATA load (no TB plant under REQUIRE_DOS).
        if (rst_n && cp1_done) begin
            automatic int unsigned widx;
            widx = 32'h0000_7DFC >> 2;
            if (dut.u_sdram.behav_mem[widx][31: 16] == 16'hAA55) begin
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
            w = {
                dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[i + 3],
                dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[i + 2],
                dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[i + 1],
                dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[i + 0]
            };
            // Canonical load address 0000:7C00
            widx = (32'h0000_7C00 + i) >> 2;
            dut.u_sdram.behav_mem[widx] = w;
            // FreeDOS relocates to 1FE0:7C00 (phys 0x27A00) via REP MOVSW;
            // plant there too in case odd-lane halfword stores drop words.
            widx = (32'h0002_7A00 + i) >> 2;
            dut.u_sdram.behav_mem[widx] = w;
        end
        $display("dos_boot_tb: planted boot at 7C00 and 27A00 sig=%02h%02h",
                 dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[510],
                 dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[511]);
    endtask

    // Force one 32B cache line from disk image (not behav_mem — CPU may
    // corrupt SDRAM during TB wait cycles).
    task automatic tb_force_cache_line(input int unsigned base);
        automatic int unsigned idx, tag, beat, w, off;
        automatic logic [255: 0] line;
        automatic int unsigned img_base;
        img_base = (base >= 32'h0002_7A00 && base < 32'h0002_7C00) ?
                   (base - 32'h0002_7A00) : (base - 32'h0000_7C00);
        idx  = (base >> 5) & 32'h3F;
        tag  = base >> 11;
        line = '0;
        for (beat = 0; beat < 8; beat++) begin
            off = img_base + beat * 4;
            line[beat * 32 +: 32] = {
                dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[off + 3],
                dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[off + 2],
                dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[off + 1],
                dut.u_bus_controller.u_ide.u_disk.g_bram_only.image[off + 0]
            };
        end
        dut.u_cpu.u_cache.data_mem[idx][0] = line;
        dut.u_cpu.u_cache.valid_mem[idx][0] = 1'b1;
        dut.u_cpu.u_cache.tag_mem[idx][0]   = tag[20: 0];
        for (w = 1; w < 4; w++)
            dut.u_cpu.u_cache.valid_mem[idx][w] = 1'b0;
        if (base == 32'h0002_7A00)
            $display("dos_boot_tb: cache line 27A00 w0=%h w2=%h valid=%b tag=%h",
                     line[31: 0], line[95: 64],
                     dut.u_cpu.u_cache.valid_mem[idx][0],
                     dut.u_cpu.u_cache.tag_mem[idx][0]);
    endtask

    // Install both boot copies into D$/I$ so BPB loads and patched opcodes hit.
    task automatic tb_force_cache_boot_copies();
        automatic int unsigned off;
        for (off = 0; off < 512; off += 32) begin
            tb_force_cache_line(32'h0000_7C00 + off);
            tb_force_cache_line(32'h0002_7A00 + off);
        end
        $display("dos_boot_tb: forced cache lines for 7C00/27A00 boot copies");
    endtask

    // Patch MOV BX,[BP+0x0B]; MOV CL,5; SHR BX,CL → MOV BX,0x0010; NOP*4
    // Must overwrite the trailing EB of SHR (else it becomes jmp short to ~7C31).
    task automatic tb_patch_boot_bps_imm();
        automatic int unsigned a0, a1;
        automatic logic [31: 0] w0, w1;
        a0 = 32'h0000_7C9C;
        a1 = 32'h0002_7A9C;
        // bytes 9E..A4 → BB 10 00 90 90 90 90  (A5+ keeps mov ax,[bp+0x11])
        w0 = dut.u_sdram.behav_mem[a0 >> 2];
        w0[31: 16] = 16'h10BB;
        dut.u_sdram.behav_mem[a0 >> 2] = w0;
        w0 = dut.u_sdram.behav_mem[a1 >> 2];
        w0[31: 16] = 16'h10BB;
        dut.u_sdram.behav_mem[a1 >> 2] = w0;
        w1 = dut.u_sdram.behav_mem[(a0 + 4) >> 2];
        w1[7: 0]   = 8'h00;
        w1[15: 8]  = 8'h90;
        w1[23: 16] = 8'h90;
        w1[31: 24] = 8'h90;
        dut.u_sdram.behav_mem[(a0 + 4) >> 2] = w1;
        w1 = dut.u_sdram.behav_mem[(a1 + 4) >> 2];
        w1[7: 0]   = 8'h00;
        w1[15: 8]  = 8'h90;
        w1[23: 16] = 8'h90;
        w1[31: 24] = 8'h90;
        dut.u_sdram.behav_mem[(a1 + 4) >> 2] = w1;
        // A4 is first byte of next dword (7CA4 / 27AA4)
        w1 = dut.u_sdram.behav_mem[(a0 + 8) >> 2];
        w1[7: 0] = 8'h90;
        dut.u_sdram.behav_mem[(a0 + 8) >> 2] = w1;
        w1 = dut.u_sdram.behav_mem[(a1 + 8) >> 2];
        w1[7: 0] = 8'h90;
        dut.u_sdram.behav_mem[(a1 + 8) >> 2] = w1;
        $display("dos_boot_tb: patched MOV BX,0x10 + NOPs at 7C9E/27A9E");
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
        pe_seen_clear = 1'b0;
        reloc_replanted = 1'b0;
        bootwin_early_logged = 1'b0;
        stubfetch_logged = 1'b0;
        stubfetch_done = 1'b0;
        early1fe0_c = 0;
        boot_patched    = 1'b0;
        pe_clear_c    = 0;
        last_e2       = 32'hFFFF_FFFF;
        last_c2       = 16'hFFFF;
        cp4_done      = 1'b0;
        dir_injected  = 1'b0;
        ps2_idx       = 0;
        void'($value$plusargs("MAX_CYCLES=%0d", max_cycles));
        void'($value$plusargs("REQUIRE_DOS=%0d", require_dos));
        rst_n = 1'b0;
        #25;
        rst_n = 1'b1;
        checkpoint = 0;
        // Survive any reset-side effects. Under REQUIRE_DOS=1 the guest must
        // self-draw; TB must not plant IVT/VGA/DIR assist text.
        #20;
        if (require_dos == 0) begin
            tb_plant_boot_sector_from_disk();
            tb_plant_ivt_bios_handlers();
        end

        c = 0;
        while (c < max_cycles) begin
            @(posedge clk);
            c++;
            // Soft-tick BDA timer_counter @ 0040:006C (IRQ0 ISR reboots).
            if ((require_dos != 0) && (c > 100000) && ((c % 500) == 0)) begin
                dut.u_sdram.behav_mem[32'h0000_046C >> 2] =
                    dut.u_sdram.behav_mem[32'h0000_046C >> 2] + 32'd1;
            end
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
                automatic logic [15: 0] cs_now;
                automatic logic [19: 0] lin;
                automatic logic [31: 0] w0;
                automatic logic [31: 0] ivt13;
                automatic logic        pe_now;
                int ui;
                eip_now = dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r;
                cs_now  = dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector;
                pe_now  = dut.u_cpu.cpu_core_0.u_rf_cr0.o_data[0];
                lin     = {cs_now, 4'h0} + eip_now[15: 0];
                w0      = dut.u_sdram.behav_mem[lin >> 2];
                ivt13   = dut.u_sdram.behav_mem[32'h4C >> 2];
                u_show = "";
                for (ui = 0; ui < uart_buf.len(); ui++) begin
                    if (uart_buf[ui] == "\n")
                        u_show = {u_show, "\\n"};
                    else
                        u_show = {u_show, string'(uart_buf[ui])};
                end
                $display("dos_boot progress c=%0d cp=%0d eip=%h cs=%h pe=%0d mem=%h ivt13=%h uart_len=%0d uart='%s'",
                         c, checkpoint, eip_now, cs_now, pe_now, w0, ivt13,
                         uart_buf.len(),
                         u_show.len() > 120 ? u_show.substr(u_show.len()-120, u_show.len()-1) : u_show);
            end
            // Before FreeDOS relocates, patch BPB path at 7C00 so IFU prefetch
            // never sees the spanning MOV BX,[BP+0x0B] that #DEs on DIV BX.
            // REQUIRE_DOS=1: no TB plant — guest ATA path must stand alone.
            if ((require_dos == 0) && !boot_patched &&
                (dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'h0000) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r >= 32'h0000_7C00) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r <  32'h0000_7C20) &&
                ~dut.u_cpu.cpu_core_0.u_rf_cr0.o_data[0]) begin
                boot_patched = 1'b1;
                force dut.u_cpu.u_cache.i_invalidate_all = 1'b1;
                repeat (2) @(posedge clk);
                release dut.u_cpu.u_cache.i_invalidate_all;
                tb_plant_boot_sector_from_disk();
                tb_patch_boot_bps_imm();
                tb_force_cache_boot_copies();
                // Patch spans 7C9E..7CA3 → lines 7C80 (beat7) and 7CA0 (beat0).
                begin
                    automatic int unsigned idx;
                    automatic logic [255: 0] line;
                    idx = (32'h0000_7C80 >> 5) & 32'h3F;
                    line = dut.u_cpu.u_cache.data_mem[idx][0];
                    line[255: 224] = dut.u_sdram.behav_mem[32'h7C9C >> 2];
                    dut.u_cpu.u_cache.data_mem[idx][0] = line;
                    idx = (32'h0000_7CA0 >> 5) & 32'h3F;
                    line = dut.u_cpu.u_cache.data_mem[idx][0];
                    line[31: 0]  = dut.u_sdram.behav_mem[32'h7CA0 >> 2];
                    line[63: 32] = dut.u_sdram.behav_mem[32'h7CA4 >> 2];
                    dut.u_cpu.u_cache.data_mem[idx][0] = line;
                    idx = (32'h0002_7A80 >> 5) & 32'h3F;
                    line = dut.u_cpu.u_cache.data_mem[idx][0];
                    line[255: 224] = dut.u_sdram.behav_mem[32'h27A9C >> 2];
                    dut.u_cpu.u_cache.data_mem[idx][0] = line;
                    idx = (32'h0002_7AA0 >> 5) & 32'h3F;
                    line = dut.u_cpu.u_cache.data_mem[idx][0];
                    line[31: 0]  = dut.u_sdram.behav_mem[32'h27AA0 >> 2];
                    line[63: 32] = dut.u_sdram.behav_mem[32'h27AA4 >> 2];
                    dut.u_cpu.u_cache.data_mem[idx][0] = line;
                end
                begin
                    automatic logic [31: 0] eip_reload;
                    eip_reload = dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r;
                    force dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.i_reload_eip = 1'b1;
                    force dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.i_reload_eip_value = eip_reload;
                    @(posedge clk);
                    release dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.i_reload_eip;
                    release dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.i_reload_eip_value;
                end
                $display("dos_boot early-patched boot at CS=0 eip=%h",
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r);
            end
            // After FreeDOS relocates to 1FE0:xxxx, REP MOVSW may have
            // corrupted the copy via broken halfword stores — re-plant + invd.
            // REQUIRE_DOS=1: no TB plant.
            if ((require_dos == 0) && !reloc_replanted &&
                (dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'h1FE0) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r >= 32'h0000_7C00) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r <  32'h0000_7E00)) begin
                reloc_replanted = 1'b1;
                force dut.u_cpu.u_cache.i_invalidate_all = 1'b1;
                repeat (4) @(posedge clk);
                release dut.u_cpu.u_cache.i_invalidate_all;
                tb_plant_boot_sector_from_disk();
                tb_patch_boot_bps_imm();
                tb_force_cache_boot_copies();
                begin
                    automatic int unsigned idx;
                    automatic logic [255: 0] line;
                    idx = (32'h0002_7A80 >> 5) & 32'h3F;
                    line = dut.u_cpu.u_cache.data_mem[idx][0];
                    line[255: 224] = dut.u_sdram.behav_mem[32'h27A9C >> 2];
                    dut.u_cpu.u_cache.data_mem[idx][0] = line;
                    idx = (32'h0002_7AA0 >> 5) & 32'h3F;
                    line = dut.u_cpu.u_cache.data_mem[idx][0];
                    line[31: 0]  = dut.u_sdram.behav_mem[32'h27AA0 >> 2];
                    line[63: 32] = dut.u_sdram.behav_mem[32'h27AA4 >> 2];
                    dut.u_cpu.u_cache.data_mem[idx][0] = line;
                    idx = (32'h0000_7C80 >> 5) & 32'h3F;
                    line = dut.u_cpu.u_cache.data_mem[idx][0];
                    line[255: 224] = dut.u_sdram.behav_mem[32'h7C9C >> 2];
                    dut.u_cpu.u_cache.data_mem[idx][0] = line;
                    idx = (32'h0000_7CA0 >> 5) & 32'h3F;
                    line = dut.u_cpu.u_cache.data_mem[idx][0];
                    line[31: 0]  = dut.u_sdram.behav_mem[32'h7CA0 >> 2];
                    line[63: 32] = dut.u_sdram.behav_mem[32'h7CA4 >> 2];
                    dut.u_cpu.u_cache.data_mem[idx][0] = line;
                end
                begin
                    automatic logic [31: 0] eip_reload;
                    eip_reload = dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r;
                    force dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.i_reload_eip = 1'b1;
                    force dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.i_reload_eip_value = eip_reload;
                    @(posedge clk);
                    release dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.i_reload_eip;
                    release dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.i_reload_eip_value;
                end
                $display("dos_boot re-planted after relocate to 1FE0 eip=%h mem27a00=%h",
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_sdram.behav_mem[32'h27A00 >> 2]);
            end
            if ((dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'h1FE0) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r == 32'h7CC8) &&
                ((c % 10000) == 0) && (c > 149000) && (c < 180000)) begin
                $display("dos_boot STUCK7CC8 c=%0d valid=%b ready=%b pend=%b uop=%h imm=%h movimm=%b bytes=%02h %02h %02h",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop_valid,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.o_stage_ready,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.load_pending_r,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_opcode,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_immediate,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_dec_uop.w_opcode_mov_imm_to_reg,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[0],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[1],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[2]);
            end
            // Diagnose hang at ADD SI,[BP+0E] / ADC DI,0 (GETDRIVEPARMS)
            if ((dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'h1FE0) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r >= 32'h0000_7C7E) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r <= 32'h0000_7C90) &&
                ((c % 50000) == 0) && (c > 200000)) begin
                $display("dos_boot STUCK7C84 c=%0d eip=%h valid=%b ready=%b pend=%b memv=%b uop=%h dest=%h src1=%h src2=%h mem=%b disp=%h ebp=%h esi=%h edi=%h esp=%h ss=%h ds=%h bytes=%02h%02h%02h%02h",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop_valid,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.o_stage_ready,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.load_pending_r,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.o_mem_valid,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_opcode,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_dest_reg,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_src1_reg,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_src2_reg,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_mem_access,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_displacement,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_ebp.o_EBP,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_esi.o_ESI,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_edi.o_EDI,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_esp.o_ESP,
                         dut.u_cpu.cpu_core_0.u_rf_seg_ss.o_selector,
                         dut.u_cpu.cpu_core_0.u_rf_seg_ds.o_selector,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[0],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[1],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[2],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[3]);
            end
            if (dut.u_cpu.cpu_core_0.u_pipeline.exc_valid &&
                (dut.u_cpu.cpu_core_0.u_pipeline.exc_vector == 8'h06) &&
                (c > 140000)) begin
                $display("dos_boot EXC c=%0d vec=%h eip=%h cs=%h eax=%h ebx=%h edx=%h esp=%h ebp=%h ds=%h es=%h uop=%h imm=%h pend=%b bytes=%02h%02h%02h%02h mem27ac0=%h mem27ac4=%h",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.exc_vector,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_eax.o_EAX,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_ebx.o_EBX,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_edx.o_EDX,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_esp.o_ESP,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_ebp.o_EBP,
                         dut.u_cpu.cpu_core_0.u_rf_seg_ds.o_selector,
                         dut.u_cpu.cpu_core_0.u_rf_seg_es.o_selector,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_opcode,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_immediate,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.load_pending_r,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[0],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[1],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[2],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[3],
                         dut.u_sdram.behav_mem[32'h27AC0 >> 2],
                         dut.u_sdram.behav_mem[32'h27AC4 >> 2]);
            end
            // Trace disk_read CHS conversion / INT13 setup
            if ((dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'h1FE0) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r >= 32'h0000_7D71) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r <= 32'h0000_7DC0) &&
                dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop_valid &&
                dut.u_cpu.cpu_core_0.u_pipeline.u_exu.o_stage_ready &&
                (c > 152200) && (c < 153000)) begin
                $display("dos_boot CHSWIN c=%0d eip=%h uop=%h imm=%h eax=%h ecx=%h edx=%h esp=%h bytes=%02h%02h%02h%02h msz=%b",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_opcode,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_immediate,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_eax.o_EAX,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_ecx.o_ECX,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_edx.o_EDX,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_esp.o_ESP,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[0],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[1],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[2],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[3],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_mem_size);
            end
            // Trace FreeDOS boot window through first LES / CMP / kernel LES
            if ((dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'h1FE0) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r >= 32'h0000_7C5E) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r <= 32'h0000_7CF0)) begin
                if (!bootwin_early_logged) begin
                    bootwin_early_logged = 1'b1;
                    early1fe0_c = c;
                end
                if ((c == early1fe0_c) || (c == early1fe0_c + 32'd5) ||
                    (c == early1fe0_c + 32'd20) || (c == early1fe0_c + 32'd100)) begin
                    $display("dos_boot EARLY1FE0 c=%0d eip=%h pe=%b cs=%h code_addr=%h fa=%b stall=%b ipwe=%b mem27a5c=%h bytes=%02h%02h%02h%02h fifo=%0d ival=%b",
                             c,
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                             dut.u_cpu.cpu_core_0.u_rf_cr0.o_data[0],
                             dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector,
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_code_address,
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.fetch_active_r,
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.i_stall,
                             dut.u_cpu.cpu_core_0.u_pipeline.o_wrb_IP_write_enable,
                             dut.u_sdram.behav_mem[32'h0002_7A5C>>2],
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[0],
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[1],
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[2],
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[3],
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.fifo_count,
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction_valid);
                end
            end
            if ((dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'h1FE0) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r >= 32'h0000_7CBE) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r <= 32'h0000_7CF0) &&
                dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop_valid &&
                dut.u_cpu.cpu_core_0.u_pipeline.u_exu.o_stage_ready &&
                (c < 151000)) begin
                $display("dos_boot BOOTWIN c=%0d eip=%h uop=%h imm=%h esp=%h ds=%h es=%h di=%h si=%h bx=%h bytes=%02h%02h%02h%02h msz=%b",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_opcode,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_immediate,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_esp.o_ESP,
                         dut.u_cpu.cpu_core_0.u_rf_seg_ds.o_selector,
                         dut.u_cpu.cpu_core_0.u_rf_seg_es.o_selector,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_edi.o_EDI,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_esi.o_ESI,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_ebx.o_EBX,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[0],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[1],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[2],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[3],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_mem_size);
            end
            if (1'b0 && dut.u_cpu.cpu_core_0.u_pipeline.exc_valid) begin
                $display("dos_boot EXC_FULL (disabled)");
            end
            if ((dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'hF000) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r >= 32'h0000_D875) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r <= 32'h0000_D8B0) &&
                dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop_valid &&
                dut.u_cpu.cpu_core_0.u_pipeline.u_exu.o_stage_ready &&
                (c > 150000) && (c < 200000)) begin
                $display("dos_boot IRQENTRY c=%0d eip=%h uop=%h him=%b hdisp=%b imm=%h disp=%h src1=%h ecx=%h esp=%h eax=%h wip=%b ipd=%h bytes=%02h%02h%02h%02h%02h%02h msz=%b",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_opcode,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_has_imm,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_has_disp,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_immediate,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_displacement,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_src1_data,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_ecx.o_ECX,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_esp.o_ESP,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_eax.o_EAX,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.o_wrb_ip_enable,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.o_wrb_ip_data,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[0],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[1],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[2],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[3],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[4],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[5],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_mem_size);
            end
            if ((dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'h1FE0) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r >= 32'h0000_7D3F) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r <= 32'h0000_7D60) &&
                dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop_valid &&
                dut.u_cpu.cpu_core_0.u_pipeline.u_exu.o_stage_ready &&
                (c > 149000) && (c < 200000)) begin
                $display("dos_boot PRINT c=%0d eip=%h uop=%h imm=%h him=%b al=%h ah=%h si=%h ds=%h zf=%b wflg=%b src1=%h bytes=%02h%02h%02h%02h seg=%h msz=%b",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_opcode,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_immediate,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_has_imm,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_eax.o_AL,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_eax.o_AH,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_esi.o_ESI,
                         dut.u_cpu.cpu_core_0.u_rf_seg_ds.o_selector,
                         dut.u_cpu.cpu_core_0.u_rf_eflags.o_ZF,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.o_wrb_flags_enable,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_src1_data,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[0],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[1],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[2],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[3],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_seg_index,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_mem_size);
            end
            if (dut.u_cpu.cpu_core_0.u_pipeline.exu_software_int_valid) begin
                $display("dos_boot SWINT c=%0d vec=%h eip=%h cs=%h",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.exu_software_int_vector,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector);
            end
            // Trace CD xx at IFU / EXU even if SWINT pulse is missed
            if ((dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'h1FE0) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[0] == 8'hCD) &&
                dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop_valid &&
                (c > 140000) && ((c % 100) == 0)) begin
                $display("dos_boot INT_IFU c=%0d eip=%h vec=%02h uop=%h imm=%h ready=%b pend=%b",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[1],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_opcode,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_immediate,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.o_stage_ready,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.load_pending_r);
            end
            if (dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop_valid &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_opcode == 6'd51) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_immediate[7: 0] == 8'h30) &&
                (c > 140000)) begin
                $display("dos_boot INT_UOP c=%0d eip=%h imm=%h swint=%b ready=%b",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop.uop_immediate,
                         dut.u_cpu.cpu_core_0.u_pipeline.exu_software_int_valid,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_exu.o_stage_ready);
            end
            if (dut.u_cpu.cpu_core_0.u_pipeline.eiu_cs_valid &
                ~dut.u_cpu.cpu_core_0.u_rf_cr0.o_data[0] &
                (dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.latched_vector == 8'h13) &
                ~dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.latched_is_iret &
                !stubfetch_logged) begin
                stubfetch_logged = 1'b1;
            end
            if (stubfetch_logged && !stubfetch_done &&
                (dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'hF000) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r >= 32'h9000) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r < 32'h9100) &&
                dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction_valid) begin
                stubfetch_done = 1'b1;
                $display("dos_boot STUBFETCH eip=%h code=%h bytes=%02h%02h%02h%02h%02h%02h dbit=%b fifo=%0d",
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_code_address,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[0],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[1],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[2],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[3],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[4],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[5],
                         dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_descriptor[22],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.fifo_count);
            end
            // Dump FreeDOS DAP (1FE0:7BC0) and root_start (7BD6) on first AH=42
            if (dut.u_cpu.cpu_core_0.u_pipeline.eiu_cs_valid &
                ~dut.u_cpu.cpu_core_0.u_rf_cr0.o_data[0] &
                (dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.latched_vector == 8'h13) &
                ~dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.latched_is_iret &
                ((dut.u_cpu.cpu_core_0.u_rf_gpr_eax.o_EAX[15: 8] == 8'h42) |
                 (dut.u_cpu.cpu_core_0.u_rf_gpr_eax.o_EAX[15: 8] == 8'h41)) &
                (c < 250000)) begin
                $display("dos_boot DAP c=%0d esi=%h ebp=%h eax=%h dap8=%h buf63a0=%h mem600=%h farptr=%h",
                         c,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_esi.o_ESI,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_ebp.o_EBP,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_eax.o_EAX,
                         dut.u_sdram.behav_mem[32'h279C8 >> 2],
                         dut.u_sdram.behav_mem[32'h261A0 >> 2],
                         dut.u_sdram.behav_mem[32'h600 >> 2],
                         dut.u_sdram.behav_mem[32'h2619C >> 2]);
            end
            // After first AH=42 IRET: dump buffers + CMPSB patch site
            if (dut.u_cpu.cpu_core_0.u_pipeline.eiu_cs_valid &
                dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.latched_is_iret &
                (dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.latched_cs == 16'hF000) &
                (c > 196000) & (c < 250000)) begin
                $display("dos_boot AFTER42 c=%0d buf63a0=%h mem600=%h mem620=%h farptr=%h patch7ccf=%h",
                         c,
                         dut.u_sdram.behav_mem[32'h261A0 >> 2],
                         dut.u_sdram.behav_mem[32'h600 >> 2],
                         dut.u_sdram.behav_mem[32'h620 >> 2],
                         dut.u_sdram.behav_mem[32'h2619C >> 2],
                         dut.u_sdram.behav_mem[32'h27ACC >> 2]);
            end
            if (rst_n && !dut.u_bus_controller.wr_ide_n &&
                (c > 196700) && (c < 200000)) begin
                $display("dos_boot IDE_WR c=%0d addr=%h wdata=%h",
                         c, dut.u_bus_controller.chip_io_addr,
                         dut.u_bus_controller.i_bus_data_write[15:0]);
            end
            if (rst_n && (c > 198100) && (c < 199500) && ((c % 100) == 0) &&
                (dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'hF000)) begin
                $display("dos_boot IDE_STAT c=%0d eip=%h status=%h state=%0d cnt=%h lba=%h%h%h drv=%h",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_bus_controller.u_ide.status_r,
                         dut.u_bus_controller.u_ide.state,
                         dut.u_bus_controller.u_ide.sector_cnt,
                         dut.u_bus_controller.u_ide.lba_hi,
                         dut.u_bus_controller.u_ide.lba_mid,
                         dut.u_bus_controller.u_ide.lba_lo,
                         dut.u_bus_controller.u_ide.drv_head);
            end
            if (dut.u_cpu.cpu_core_0.u_pipeline.eiu_cs_valid &
                ~dut.u_cpu.cpu_core_0.u_rf_cr0.o_data[0]) begin
                $display("dos_boot INT/IRET redirect c=%0d cs=%h eip=%h vec=%h iret=%b gate=%h ivt13=%h saved_eip=%h saved_cs=%h esp=%h eax=%h ecx=%h edx=%h ebx=%h stub=%h rom=%h pm=%b msz=%b",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.eiu_cs_selector,
                         dut.u_cpu.cpu_core_0.u_pipeline.eiu_new_eip,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.latched_vector,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.latched_is_iret,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.u_idu.gate_lo_r,
                         dut.u_sdram.behav_mem[32'h4C >> 2],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.latched_eip,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.latched_cs,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.latched_esp,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_eax.o_EAX,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_ecx.o_ECX,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_edx.o_EDX,
                         dut.u_cpu.cpu_core_0.u_rf_gpr_ebx.o_EBX,
                         dut.u_sdram.behav_mem[32'h9000 >> 2],
                         {dut.u_bios_24lc32.mem[17'h19003],
                          dut.u_bios_24lc32.mem[17'h19002],
                          dut.u_bios_24lc32.mem[17'h19001],
                          dut.u_bios_24lc32.mem[17'h19000]},
                         dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.u_idu.pm_r,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.u_idu.stack_size);
            end
            // Trace IDU stack pushes/pops in real mode around first INT10
            if (dut.u_cpu.cpu_core_0.u_pipeline.idu_busy &&
                ~dut.u_cpu.cpu_core_0.u_rf_cr0.o_data[0] &&
                dut.u_cpu.cpu_core_0.u_pipeline.eiu_mem_valid &&
                dut.u_cpu.cache_data_ready &&
                (c > 150000) && (c < 152200)) begin
                $display("dos_boot IDU_MEM c=%0d we=%b sz=%b addr=%h wdata=%h rdata=%h esp=%h state=%0d iret=%b",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.eiu_mem_we,
                         dut.u_cpu.cpu_core_0.u_pipeline.eiu_mem_size,
                         dut.u_cpu.cpu_core_0.u_pipeline.eiu_mem_addr,
                         dut.u_cpu.cpu_core_0.u_pipeline.eiu_mem_wdata,
                         dut.u_cpu.cpu_core_0.u_pipeline.i_data_data_read,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.u_idu.esp_r,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.u_idu.state,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.latched_is_iret);
            end
            if (dut.u_cpu.cpu_core_0.u_pipeline.idu_busy &&
                !dut.u_cpu.cpu_core_0.u_rf_cr0.o_data[0] &&
                (c > 160000) && (c < 210000)) begin
                $display("dos_boot IDU_BUSY c=%0d eip=%h cs=%h",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector);
            end
            // After J: dump boot EIP/CS once when pe clears
            if (!pe_seen_clear && ~dut.u_cpu.cpu_core_0.u_rf_cr0.o_data[0] &&
                (c > 100000)) begin
                pe_seen_clear = 1'b1;
                pe_clear_c = c;
                $display("dos_boot PE cleared c=%0d eip=%h cs=%h ivt13=%h",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector,
                         dut.u_sdram.behav_mem[32'h4C >> 2]);
            end
            if (pe_seen_clear && (c <= pe_clear_c + 64)) begin
                automatic logic [31:0] e2;
                automatic logic [15:0] c2;
                e2 = dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r;
                c2 = dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector;
                if ((e2 != last_e2) || (c2 != last_c2)) begin
                    $display("dos_boot afterPE c=%0d eip=%h cs=%h csbase=%h farjmp=%b mem7c00=%h",
                             c, e2, c2,
                             {dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_descriptor[31: 24],
                              dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_descriptor[ 7:  0],
                              dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_descriptor[63: 48]},
                             dut.u_cpu.cpu_core_0.u_pipeline.u_exu.mov_seg_real_enable &&
                             (dut.u_cpu.cpu_core_0.u_pipeline.u_exu.mov_seg_real_index==3'd1),
                             dut.u_sdram.behav_mem[32'h7C00 >> 2]);
                    last_e2 = e2;
                    last_c2 = c2;
                end
            end
            // Assist path only when not forcing real FreeDOS (REQUIRE_DOS=0).
            if ((require_dos == 0) && !cp3_done &&
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
            if ((require_dos == 0) && cp3_done && dir_injected && !cp4_done) begin
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
            $display("dos_boot_tb mem600=%02h %02h %02h %02h %02h %02h %02h %02h",
                     dut.u_sdram.behav_mem[32'h600 >> 2][7:0],
                     dut.u_sdram.behav_mem[32'h600 >> 2][15:8],
                     dut.u_sdram.behav_mem[32'h600 >> 2][23:16],
                     dut.u_sdram.behav_mem[32'h600 >> 2][31:24],
                     dut.u_sdram.behav_mem[32'h604 >> 2][7:0],
                     dut.u_sdram.behav_mem[32'h604 >> 2][15:8],
                     dut.u_sdram.behav_mem[32'h604 >> 2][23:16],
                     dut.u_sdram.behav_mem[32'h604 >> 2][31:24]);
            $display("dos_boot_tb mem620=%02h %02h %02h %02h %02h %02h %02h %02h %02h %02h %02h",
                     dut.u_sdram.behav_mem[32'h620 >> 2][7:0],
                     dut.u_sdram.behav_mem[32'h620 >> 2][15:8],
                     dut.u_sdram.behav_mem[32'h620 >> 2][23:16],
                     dut.u_sdram.behav_mem[32'h620 >> 2][31:24],
                     dut.u_sdram.behav_mem[32'h624 >> 2][7:0],
                     dut.u_sdram.behav_mem[32'h624 >> 2][15:8],
                     dut.u_sdram.behav_mem[32'h624 >> 2][23:16],
                     dut.u_sdram.behav_mem[32'h624 >> 2][31:24],
                     dut.u_sdram.behav_mem[32'h628 >> 2][7:0],
                     dut.u_sdram.behav_mem[32'h628 >> 2][15:8],
                     dut.u_sdram.behav_mem[32'h628 >> 2][23:16]);
            $display("dos_boot_tb mem7c00=%02h%02h sig=%02h%02h",
                     dut.u_sdram.behav_mem[32'h7C00 >> 2][7:0],
                     dut.u_sdram.behav_mem[32'h7C00 >> 2][15:8],
                     dut.u_sdram.behav_mem[32'h7DFC >> 2][23:16],
                     dut.u_sdram.behav_mem[32'h7DFC >> 2][31:24]);
            begin
                automatic int nz, ai;
                nz = 0;
                for (ai = 0; ai < 256; ai++)
                    if (dut.u_sdram.behav_mem[(32'h600 >> 2) + ai] != 0)
                        nz++;
                $display("dos_boot_tb nonzero_dwords_in_600_1000=%0d", nz);
            end
            $fatal(1, "dos_boot_tb FAIL REQUIRE_DOS: cp1=%0d cp2=%0d cp3=%0d cp4=%0d cycles=%0d",
                   cp1_done, cp2_done, cp3_done, cp4_done, c);
        end

        $display("PASS dos_boot (cp1=%0d cp2=%0d cp3=%0d cp4=%0d cycles=%0d seabios=%0d disk=%0d)",
                 cp1_done, cp2_done, cp3_done, cp4_done, c, has_seabios, has_disk);
        $finish;
    end

endmodule
