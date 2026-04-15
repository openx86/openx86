// ============================================================================
// Multiply / Divide Unit — MUL/IMUL 32×32→64，DIV/IDIV 64÷32
// ============================================================================

module execute_muldiv_unit (
    input  logic [2:0]  i_op,
    input  logic [31:0] i_lo,
    input  logic [31:0] i_hi,
    input  logic [31:0] i_src,
    output logic [31:0] o_lo,
    output logic [31:0] o_hi,
    output logic        o_div0
);

    import execute_unit_pkg::*;

    logic [63:0] umul;
    logic signed [63:0] smul;
    logic [63:0] dividend;
    logic [63:0] divisor_u;
    logic signed [63:0] sdividend;
    logic signed [31:0] sdivisor;

    always_comb begin
        umul = 64'(i_lo) * 64'(i_src);
        smul = $signed(i_lo) * $signed(i_src);
        dividend = {i_hi, i_lo};
        divisor_u = {32'h0, i_src};
        sdividend = $signed({i_hi, i_lo});
        sdivisor  = $signed(i_src);

        o_div0 = 1'b0;
        o_lo   = 32'h0;
        o_hi   = 32'h0;

        unique case (i_op)
            MD_MULU32: begin
                o_lo = umul[31:0];
                o_hi = umul[63:32];
            end
            MD_IMUL32: begin
                o_lo = smul[31:0];
                o_hi = smul[63:32];
            end
            MD_DIVU32: begin
                if (i_src == 32'h0) begin
                    o_div0 = 1'b1;
                end else begin
                    o_lo = (dividend / divisor_u)[31:0];
                    o_hi = (dividend % divisor_u)[31:0];
                end
            end
            MD_IDIV32: begin
                if (i_src == 32'h0) begin
                    o_div0 = 1'b1;
                end else begin
                    o_lo = (sdividend / sdivisor)[31:0];
                    o_hi = (sdividend % sdivisor)[31:0];
                end
            end
            default: ;
        endcase
    end

endmodule
