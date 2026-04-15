// ============================================================================
// soc_top smoke test — same BIOS bring-up as x86_core_top_tb
// Integrates vga peripheral (VGA bus VRAM + I/O) and sdram_controller (0x0100_0000 window).
// ============================================================================

module soc_top_tb;

    logic clock;
    logic reset;
    logic        o_vga_hsync;
    logic        o_vga_vsync;
    logic [3:0]  o_vga_r;
    logic [3:0]  o_vga_g;
    logic [3:0]  o_vga_b;

    soc_top dut (
        .clock       ( clock ),
        .reset       ( reset ),
        .o_vga_hsync ( o_vga_hsync ),
        .o_vga_vsync ( o_vga_vsync ),
        .o_vga_r     ( o_vga_r     ),
        .o_vga_g     ( o_vga_g     ),
        .o_vga_b     ( o_vga_b     )
    );

    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    initial begin
        $display("=== soc_top_tb ===");
        reset = 1'b1;
        #25;
        reset = 1'b0;

        int c = 0;
        while (c < 3000) begin
            @(posedge clock);
            c++;
            if (dut.o_halted) begin
                $display("HALT cycle=%0d", c);
                break;
            end
        end

        if (!dut.o_halted) begin
            $display("FAIL timeout");
            $finish;
        end

        logic [31:0] eax;
        eax = dut.u_cpu.u_gpr.gpr[0];
        $display("EAX=0x%08h", eax);
        if (eax !== 32'h0000_1235) begin
            $display("FAIL EAX");
            $finish;
        end

        $display("soc_top_tb PASS");
        $finish;
    end

endmodule
