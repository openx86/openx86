/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements soc_top_tb.
*/
// ============================================================================
// openx86_soc_top smoke test — 复位后运行固定周期（cpu + bus_controller + SDRAM 窗口）
// ============================================================================

module soc_top_tb;

    logic clk;
    logic rst_n;
    logic        o_vga_hsync;
    logic        o_vga_vsync;
    logic [ 3: 0] o_vga_r;
    logic [ 3: 0] o_vga_g;
    logic [ 3: 0] o_vga_b;
    logic  [15: 0] sdram_dq;
    logic         io_sdio_cmd;
    logic  [ 3: 0] io_sdio_dat;
    int          c;

    openx86_soc_top #(
        .USE_SDIO_DISK ( 1'b0 )
    ) dut (
        .clk   ( clk ),
        .rst_n   ( rst_n ),
        .o_vga_hsync ( o_vga_hsync ),
        .o_vga_vsync ( o_vga_vsync ),
        .o_vga_r     ( o_vga_r     ),
        .o_vga_g     ( o_vga_g     ),
        .o_vga_b     ( o_vga_b     ),
        .o_ps2_kbd_clk_out ( ),
        .o_ps2_kbd_clk_oe  ( ),
        .i_ps2_kbd_clk_in  ( 1'b1 ),
        .o_ps2_kbd_dat_out ( ),
        .o_ps2_kbd_dat_oe  ( ),
        .i_ps2_kbd_dat_in  ( 1'b1 ),
        .o_ps2_aux_clk_out ( ),
        .o_ps2_aux_clk_oe  ( ),
        .i_ps2_aux_clk_in  ( 1'b1 ),
        .o_ps2_aux_dat_out ( ),
        .o_ps2_aux_dat_oe  ( ),
        .i_ps2_aux_dat_in  ( 1'b1 ),
        .o_sdio_clk  ( ),
        .io_sdio_cmd ( io_sdio_cmd ),
        .io_sdio_dat ( io_sdio_dat ),
        .o_sdram_clk   ( ),
        .o_sdram_cke   ( ),
        .o_sdram_cs_n  ( ),
        .o_sdram_ras_n ( ),
        .o_sdram_cas_n ( ),
        .o_sdram_we_n  ( ),
        .o_sdram_ba    ( ),
        .o_sdram_a     ( ),
        .o_sdram_dqm   ( ),
        .io_sdram_dq   ( sdram_dq )
    );

    task automatic tb_load_bin_to_bios(input string path);
        integer fh, n;
        fh = $fopen(path, "rb");
        if (fh == 0) begin
            $display("soc_top_tb: cannot open SEABIOS_BIN %s", path);
            return;
        end
        n = $fread(dut.u_bios_24lc32.mem, fh);
        $fclose(fh);
        $display("soc_top_tb: SEABIOS_BIN loaded %0d bytes", n);
    endtask

    task automatic tb_load_bin_to_disk(input string path);
        integer fh, n;
        fh = $fopen(path, "rb");
        if (fh == 0) begin
            $display("soc_top_tb: cannot open DISK_BIN %s", path);
            return;
        end
        n = $fread(dut.u_bus_controller.g_disk_ram.u_disk_image.mem, fh);
        $fclose(fh);
        $display("soc_top_tb: DISK_BIN loaded %0d bytes", n);
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
            else if ($value$plusargs("SEABIOS_HEX=%s", p))
                $readmemh(p, dut.u_bios_24lc32.mem);
            else
                tb_apply_default_pc_bootstub();
        end

        begin
            automatic string p;
            if ($value$plusargs("DISK_BIN=%s", p))
                tb_load_bin_to_disk(p);
            else if ($value$plusargs("DISK_HEX=%s", p))
                $readmemh(p, dut.u_bus_controller.g_disk_ram.u_disk_image.mem);
            else begin
                dut.u_bus_controller.g_disk_ram.u_disk_image.mem[0] = 8'hA5;
                dut.u_bus_controller.g_disk_ram.u_disk_image.mem[1] = 8'h5A;
            end
        end
    end

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("=== soc_top_tb ===");
        rst_n = 1'b0;
        #25;
        rst_n = 1'b1;

        c = 0;
        while (c < 5000) begin
            @(posedge clk);
            c++;
        end

        $display("soc_top_tb PASS (ran %0d cycles)", c);
        $finish;
    end

endmodule
