// ============================================================================
// ROM testbench — bios_rom_bootstub + generic sys_rom
// ============================================================================

module rom_tb;

    logic        clock;
    logic        reset;
    logic [13:0] wa_boot;
    logic [31:0] rd_boot;

    logic [14:0] wa_ext;
    logic [31:0] rd_ext;

    bios_rom_bootstub u_bios (
        .clock     ( clock ),
        .reset     ( reset ),
        .word_addr ( wa_boot ),
        .rdata     ( rd_boot )
    );

    sys_rom #(
        .WORD_ADDR_BITS ( 15 ),
        .FILL_NOP       ( 0 )
    ) u_empty (
        .clock     ( clock ),
        .reset     ( reset ),
        .word_addr ( wa_ext[14:0] ),
        .rdata     ( rd_ext )
    );

    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    initial begin
        reset   = 1'b1;
        wa_boot = 14'h0;
        wa_ext  = 15'h0;
        repeat (3) @(posedge clock);
        reset = 1'b0;

        wa_boot = 14'h3FFC;
        @(posedge clock);
        @(posedge clock);
        if (rd_boot !== {8'h66, 8'hB8, 8'h34, 8'h12}) begin
            $display("rom_tb FAIL bootstub 3FFC got %h", rd_boot);
            $finish;
        end

        wa_ext = 15'h0;
        @(posedge clock);
        @(posedge clock);
        if (rd_ext !== 32'h0) begin
            $display("rom_tb FAIL sys_rom zero got %h", rd_ext);
            $finish;
        end

        $display("rom_tb PASS");
        $finish;
    end

endmodule
