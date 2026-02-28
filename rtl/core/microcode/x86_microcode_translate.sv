// ============================================================================
// x86 microcode translator (minimal)
// - Converts one macro-op into one or more uops
// - For bring-up, each supported macro maps to 1 uop
// - Handshake: i_macro_valid accepted when o_uop_valid && i_uop_ready? (simple)
// - clock/reset at end of port list
// ============================================================================

`include "rtl/core/x86_types.sv"

module x86_microcode_translate (
    input  logic               i_macro_valid,
    input  x86_macro_op_t      i_macro,
    output logic               o_uop_valid,
    output x86_uop_t           o_uop,
    input  logic               i_uop_ready,

    input  logic               i_clock,
    input  logic               i_reset
);

    x86_uop_t u;
    logic v;

    always_comb begin
        u = '0;
        v = i_macro_valid;
        u.valid = i_macro_valid;
        u.last  = 1'b1;
        case (i_macro.kind)
            `X86_MACRO_MOVI: begin
                u.kind    = `X86_UOP_WRITE_GPR;
                u.dst_gpr = i_macro.reg_idx;
                u.src_imm = i_macro.imm;
            end
            `X86_MACRO_ADDI: begin
                u.kind    = `X86_UOP_ALU_ADD;
                u.dst_gpr = i_macro.reg_idx; // EAX for now
                u.src_imm = i_macro.imm;
            end
            `X86_MACRO_HLT: begin
                u.kind    = `X86_UOP_HALT;
                u.dst_gpr = 3'd0;
                u.src_imm = 32'h0;
            end
            default: begin
                u.kind    = `X86_UOP_NONE;
                u.dst_gpr = 3'd0;
                u.src_imm = 32'h0;
            end
        endcase
    end

    // Simple valid/ready register slice
    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            o_uop_valid <= 1'b0;
            o_uop       <= '0;
        end else begin
            if (!o_uop_valid || i_uop_ready) begin
                o_uop_valid <= v;
                o_uop       <= u;
            end
        end
    end

endmodule

