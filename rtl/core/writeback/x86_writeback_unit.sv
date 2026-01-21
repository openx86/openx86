// ============================================================================
// x86 writeback unit (minimal)
// - Commits execute results into GPR file
// - clock/reset at end of port list
// ============================================================================

module x86_writeback_unit (
    input  logic        i_wb_valid,
    input  logic [2:0]  i_wb_gpr_idx,
    input  logic [31:0] i_wb_gpr_data,

    output logic        o_gpr_wr_en,
    output logic [2:0]  o_gpr_wr_idx,
    output logic [31:0] o_gpr_wr_data,

    input  logic        i_clock,
    input  logic        i_reset
);

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            o_gpr_wr_en   <= 1'b0;
            o_gpr_wr_idx  <= 3'd0;
            o_gpr_wr_data <= 32'h0;
        end else begin
            o_gpr_wr_en   <= i_wb_valid;
            o_gpr_wr_idx  <= i_wb_gpr_idx;
            o_gpr_wr_data <= i_wb_gpr_data;
        end
    end

endmodule

