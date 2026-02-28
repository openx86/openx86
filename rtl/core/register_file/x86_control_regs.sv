// ============================================================================
// x86 Control Registers (CR0 – minimal bring-up)
// - Stores CR0; exposes PE (protected-mode enable = CR0[0])
// - Designed for use with x86_core_top
// ============================================================================

module x86_control_regs (
    input  logic        i_cr0_we,
    input  logic [31:0] i_cr0_wdata,
    output logic [31:0] o_cr0,
    output logic        o_protected_mode,  // CR0[0] = PE

    input  logic        i_clock,
    input  logic        i_reset
);

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            o_cr0 <= 32'h0;
        end else begin
            if (i_cr0_we) begin
                o_cr0 <= i_cr0_wdata;
            end
        end
    end

    assign o_protected_mode = o_cr0[0];

endmodule
