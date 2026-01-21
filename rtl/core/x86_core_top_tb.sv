// ============================================================================
// Testbench: x86_core_top minimal bring-up
// - Provides a tiny "BIOS ROM" at 0x000F0000 (real-mode reset region)
// - Program at F000:FFF0:
//     B8 34 12 00 00    mov eax,0x00001234
//     05 01 00 00 00    add eax,0x00000001
//     F4                hlt
// - Verifies core writes EAX = 0x00001235 (via hierarchical peek)
// ============================================================================

module x86_core_top_tb;

    logic clock;
    logic reset;

    // core<->bus
    logic        bus_valid;
    logic        bus_ready;
    logic        bus_busy;
    logic        bus_we;
    logic        bus_io;
    logic [31:0] bus_addr;
    logic [31:0] bus_rdata;
    logic [31:0] bus_wdata;

    // control
    logic        cr0_we;
    logic [31:0] cr0_wdata;

    x86_core_top dut (
        .o_bus_valid        ( bus_valid ),
        .i_bus_ready        ( bus_ready ),
        .i_bus_busy         ( bus_busy ),
        .o_bus_write_enable ( bus_we ),
        .o_bus_io_access    ( bus_io ),
        .o_bus_address      ( bus_addr ),
        .i_bus_data_read    ( bus_rdata ),
        .o_bus_data_write   ( bus_wdata ),
        .i_cr0_we           ( cr0_we ),
        .i_cr0_wdata        ( cr0_wdata ),
        .i_clock            ( clock ),
        .i_reset            ( reset )
    );

    // clock
    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    // simple ROM: addressable by 32-bit linear address, returns dword (big-endian lanes like bus.sv usage)
    // We'll model read as single-cycle ready.
    logic [7:0] rom [0:65535]; // 64KB at 0xF0000..0xFFFFF

    initial begin
        for (int i = 0; i < 65536; i++) rom[i] = 8'h90; // NOP fill

        // reset vector offset within 0xF0000 segment: 0xFFF0
        int base = 16'hFFF0;
        // mov eax,0x1234
        rom[base + 0] = 8'hB8;
        rom[base + 1] = 8'h34;
        rom[base + 2] = 8'h12;
        rom[base + 3] = 8'h00;
        rom[base + 4] = 8'h00;
        // add eax,1
        rom[base + 5] = 8'h05;
        rom[base + 6] = 8'h01;
        rom[base + 7] = 8'h00;
        rom[base + 8] = 8'h00;
        rom[base + 9] = 8'h00;
        // hlt
        rom[base + 10] = 8'hF4;
    end

    // bus model: only supports memory reads, always ready when valid
    always_comb begin
        bus_busy  = 1'b0;
        bus_ready = bus_valid && !bus_we && !bus_io;
    end

    always_comb begin
        bus_rdata = 32'hFFFF_FFFF;
        if (bus_valid && !bus_we && !bus_io) begin
            if (bus_addr >= 32'h000F_0000 && bus_addr <= 32'h000F_FFFF) begin
                int o = bus_addr[15:0];
                // return dword with [31:24]=byte0 as fetch expects
                bus_rdata = {rom[o+0], rom[o+1], rom[o+2], rom[o+3]};
            end else begin
                bus_rdata = 32'h0000_0000;
            end
        end
    end

    initial begin
        $display("=== x86_core_top_tb start ===");
        reset    = 1'b1;
        cr0_we   = 1'b0;
        cr0_wdata= 32'h0;
        #30;
        reset = 1'b0;

        // run until halted or timeout
        int cycles = 0;
        while (cycles < 500) begin
            @(posedge clock);
            cycles++;
            if (dut.halted) begin
                $display("HALT observed at cycle=%0d", cycles);
                break;
            end
        end

        if (!dut.halted) begin
            $display("ERROR: timeout without halt");
            $finish;
        end

        // peek EAX (gpr[0]) through hierarchy
        logic [31:0] eax;
        eax = dut.u_gpr.gpr[0];
        $display("EAX=0x%08h (expect 0x00001235)", eax);
        if (eax !== 32'h0000_1235) begin
            $display("ERROR: EAX mismatch");
            $finish;
        end

        $display("PASS");
        $finish;
    end

endmodule

