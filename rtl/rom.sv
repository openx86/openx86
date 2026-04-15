// ============================================================================
// ROM wrappers for IBM PC memory map — 32-bit read port, word-addressed
//
// sys_rom: generic; optional $readmemh via INIT_FILE (empty = fill pattern)
// bios_rom_bootstub: 64KW BIOS image with NOP fill + reset-vector test
//   program at dword index matching byte 0xFFF0 in 0xF0000..0xFFFFF map
// ============================================================================

module sys_rom #(
    parameter int WORD_ADDR_BITS = 14,
    parameter int FILL_NOP       = 0,
    parameter string INIT_FILE     = ""
) (
    input  logic                        clock,
    input  logic                        reset,
    input  logic [WORD_ADDR_BITS-1:0] word_addr,
    output logic [31:0]                 rdata
);

    localparam int NUM_WORDS = 1 << WORD_ADDR_BITS;
    (* ram_style = "block" *)
    logic [31:0] mem[0:NUM_WORDS-1];

    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end else if (FILL_NOP) begin
            for (int i = 0; i < NUM_WORDS; i++) begin
                mem[i] = 32'h9090_9090;
            end
        end else begin
            for (int i = 0; i < NUM_WORDS; i++) begin
                mem[i] = 32'h0;
            end
        end
    end

    always_ff @(posedge clock) begin
        if (reset) begin
            rdata <= '0;
        end else begin
            rdata <= mem[word_addr];
        end
    end

endmodule


module bios_rom_bootstub (
    input  logic        clock,
    input  logic        reset,
    input  logic [13:0] word_addr,
    output logic [31:0] rdata
);

    localparam int NUM_WORDS = 16384;
    (* ram_style = "block" *)
    logic [31:0] mem[0:NUM_WORDS-1];

    initial begin
        for (int i = 0; i < NUM_WORDS; i++) begin
            mem[i] = 32'h9090_9090;
        end
        // Linear 0xFFFF0.. : 66 B8 34 12 00 00 | 66 05 01 00 00 00 | F4
        mem[14'h3FFC] = {8'h66, 8'hB8, 8'h34, 8'h12};
        mem[14'h3FFD] = {8'h00, 8'h00, 8'h66, 8'h05};
        mem[14'h3FFE] = {8'h01, 8'h00, 8'h00, 8'h00};
        mem[14'h3FFF] = {8'hF4, 8'h90, 8'h90, 8'h90};
    end

    always_ff @(posedge clock) begin
        if (reset) begin
            rdata <= '0;
        end else begin
            rdata <= mem[word_addr];
        end
    end

endmodule
