// ============================================================================
// PC conventional RAM — 32-bit word storage, byte-aligned bus address
// Maps cpu/bus byte address [19:0] (640KB window) to word index addr[19:2]
// Synthesizable: block RAM inference; no testbench delays here
// ============================================================================

module sys_ram #(
    parameter int BYTE_ADDR_BITS = 20,
    parameter int DATA_WIDTH       = 32
) (
    input  logic                         clock,
    input  logic                         reset,
    input  logic                         we,
    input  logic [BYTE_ADDR_BITS-1:0]   byte_addr,
    input  logic [DATA_WIDTH-1:0]        wdata,
    output logic [DATA_WIDTH-1:0]        rdata
);

    localparam int WORD_SEL_BITS = BYTE_ADDR_BITS - 2;
    localparam int NUM_WORDS     = 1 << WORD_SEL_BITS;

    (* ram_style = "block" *)
    logic [DATA_WIDTH-1:0] mem[0:NUM_WORDS-1];

    logic [WORD_SEL_BITS-1:0] waddr;
    assign waddr = byte_addr[BYTE_ADDR_BITS-1:2];

    always_ff @(posedge clock) begin
        if (reset) begin
            rdata <= '0;
        end else begin
            if (we) begin
                mem[waddr] <= wdata;
            end
            rdata <= mem[waddr];
        end
    end

endmodule
