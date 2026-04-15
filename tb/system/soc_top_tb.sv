// ============================================================================
// openx86_soc_top smoke test — 复位后运行固定周期（w686_cpu + bus + SDRAM 窗口）
// ============================================================================

module soc_top_tb;

    logic clock;
    logic reset_n;
    logic        o_vga_hsync;
    logic        o_vga_vsync;
    logic [3:0]  o_vga_r;
    logic [3:0]  o_vga_g;
    logic [3:0]  o_vga_b;
    wire  [15:0] sdram_dq;
    wire         io_sdio_cmd;
    wire  [3:0]  io_sdio_dat;

    openx86_soc_top #(
        .USE_SDIO_DISK ( 1'b0 )
    ) dut (
        .i_clk_50m   ( clock ),
        .i_reset_n   ( reset_n ),
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

    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    initial begin
        $display("=== soc_top_tb ===");
        reset_n = 1'b0;
        #25;
        reset_n = 1'b1;

        int c = 0;
        while (c < 5000) begin
            @(posedge clock);
            c++;
        end

        $display("soc_top_tb PASS (ran %0d cycles)", c);
        $finish;
    end

endmodule
