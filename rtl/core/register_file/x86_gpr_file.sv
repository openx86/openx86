// ============================================================================
// x86 General Purpose Register File
// - 8 x 32-bit registers (EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI)
// - Two read ports, one write port
// - gpr array is exposed for hierarchical access in testbenches
// ============================================================================

module x86_gpr_file (
    // read port 0
    input  logic        i_rd0_en,
    input  logic [2:0]  i_rd0_idx,
    output logic [31:0] o_rd0_data,

    // read port 1
    input  logic        i_rd1_en,
    input  logic [2:0]  i_rd1_idx,
    output logic [31:0] o_rd1_data,

    // write port
    input  logic        i_wr_en,
    input  logic [2:0]  i_wr_idx,
    input  logic [31:0] i_wr_data,

    input  logic        i_clock,
    input  logic        i_reset
);

    logic [31:0] gpr [0:7];

    // write (synchronous)
    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            gpr[0] <= 32'h0;
            gpr[1] <= 32'h0;
            gpr[2] <= 32'h0;
            gpr[3] <= 32'h0;
            gpr[4] <= 32'h0;
            gpr[5] <= 32'h0;
            gpr[6] <= 32'h0;
            gpr[7] <= 32'h0;
        end else begin
            if (i_wr_en) begin
                gpr[i_wr_idx] <= i_wr_data;
            end
        end
    end

    // read (asynchronous)
    assign o_rd0_data = i_rd0_en ? gpr[i_rd0_idx] : 32'h0;
    assign o_rd1_data = i_rd1_en ? gpr[i_rd1_idx] : 32'h0;

endmodule
