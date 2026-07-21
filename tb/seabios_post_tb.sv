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
// File : seabios_post_tb.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : SeaBIOS POST SoC TB with UART capture and CP1 checkpoint
// ============================================================================

module seabios_post_tb;

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
    int           require_post;
    int           checkpoint;
    string        uart_buf;
    int           thr_count;
    bit           has_seabios;

    // Hierarchical helpers:
    //   BIOS : dut.u_bios_24lc32.mem
    //   COM1 : dut.u_bus_controller.u_chip_com1.thr_shadow / thr_write_pulse
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
            $display("seabios_post_tb: cannot open SEABIOS_BIN %s", path);
            return;
        end
        n = $fread(dut.u_bios_24lc32.mem, fh);
        $fclose(fh);
        has_seabios = 1'b1;
        $display("seabios_post_tb: SEABIOS_BIN loaded %0d bytes into 128KiB ROM", n);
        $display("seabios_post_tb: resetvec=%02h %02h %02h %02h %02h",
                 dut.u_bios_24lc32.mem[17'h1FFF0],
                 dut.u_bios_24lc32.mem[17'h1FFF1],
                 dut.u_bios_24lc32.mem[17'h1FFF2],
                 dut.u_bios_24lc32.mem[17'h1FFF3],
                 dut.u_bios_24lc32.mem[17'h1FFF4]);
    endtask

    task automatic tb_apply_default_pc_bootstub();
        // Reset vector at F000:FFF0 → ROM offset 0x1FFF0
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

    initial begin
        $readmemh("rtl/device/vga/vga_font_8x16.hex", dut.u_vga.font_rom_inst.font_rom_inst.rom);
        has_seabios = 1'b0;
        begin
            automatic string p;
            for (int i = 0; i < 131072; i++)
                dut.u_bios_24lc32.mem[i] = 8'hFF;
            if ($value$plusargs("SEABIOS_BIN=%s", p))
                tb_load_bin_to_bios(p);
            else
                tb_apply_default_pc_bootstub();
        end
    end

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    int           thr_cyc;
    int           thr_last_cyc;
    logic         thr_have_pending;
    always @(posedge clk) begin
        if (!rst_n) begin
            thr_cyc         = 0;
            thr_last_cyc    = 0;
            thr_have_pending = 1'b0;
        end else begin
            thr_cyc = thr_cyc + 1;
            if (dut.u_bus_controller.u_chip_com1.thr_write_pulse) begin
                automatic logic [7: 0] ch;
                thr_count = thr_count + 1;
                ch = dut.u_bus_controller.u_chip_com1.thr_shadow;
                if ((ch >= 8'h20) && (ch <= 8'h7E)) begin
                    // Pair strobe: only collapse identical char re-strobes
                    if (thr_have_pending && ((thr_cyc - thr_last_cyc) <= 32) &&
                        (uart_buf.len() > 0) &&
                        (uart_buf[uart_buf.len()-1] == string'(ch))) begin
                        ; // drop duplicate
                    end else begin
                        uart_buf = {uart_buf, string'(ch)};
                    end
                    thr_last_cyc     = thr_cyc;
                    thr_have_pending = 1'b1;
                    if (uart_buf.len() >= 7) begin
                        automatic string un;
                        un = "";
                        for (int j = 0; j < uart_buf.len(); j++) begin
                            if ((un.len() == 0) || (un[un.len()-1] != uart_buf[j]))
                                un = {un, string'(uart_buf[j])};
                        end
                        for (int i = 0; i + 7 <= un.len(); i++) begin
                            if (un.substr(i, i + 6) == "SeaBIOS")
                                checkpoint = (checkpoint < 1) ? 1 : checkpoint;
                        end
                    end
                end
            end
        end
    end

    initial begin
        $display("=== seabios_post_tb ===");
        uart_buf     = "";
        thr_count    = 0;
        checkpoint   = 0;
        require_post = 0;
        max_cycles   = 500000;
        void'($value$plusargs("MAX_CYCLES=%0d", max_cycles));
        void'($value$plusargs("REQUIRE_POST=%0d", require_post));
        rst_n = 1'b0;
        #25;
        rst_n = 1'b1;
        checkpoint = 0; // CP0 after reset release

        c = 0;
        while (c < max_cycles) begin
            @(posedge clk);
            c++;
            if ((c == 10000) || (c == 100000) || (c == 500000) || (c == 1000000)) begin
                $display("dbg c=%0d eip=%h uart_len=%0d uart='%s'",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         uart_buf.len(),
                         uart_buf);
            end
            if ((require_post != 0) && (checkpoint >= 1))
                break;
        end

        if (has_seabios && (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r == 32'h0000_FFF0)) begin
            $fatal(1, "seabios_post_tb FAIL: EIP stuck at FFF0 after %0d cycles", c);
        end

        if ((require_post != 0) && (checkpoint < 1)) begin
            $fatal(1, "seabios_post_tb FAIL CP1 (SeaBIOS UART) not reached; last CP=%0d uart='%s'",
                   checkpoint, uart_buf);
        end

        $display("PASS seabios_post (CP=%0d cycles=%0d seabios=%0d eip=%h thr=%0d uart='%s')",
                 checkpoint, c, has_seabios,
                 dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r, thr_count, uart_buf);
        $finish;
    end

endmodule
