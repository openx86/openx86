// ============================================================================
// x86 execute unit (minimal)
// - Executes uops using internal GPR read and produces writeback request
// - Supported uops:
//   - UOP_WRITE_GPR: write imm to GPR
//   - UOP_ALU_ADD:   dst = dst + imm
//   - UOP_HALT:      raise halted flag
// - clock/reset at end of port list
// ============================================================================

`include "rtl/core/x86_types.sv"

module x86_execute_unit (
    // uop input
    input  logic            i_uop_valid,
    input  x86_uop_t        i_uop,
    output logic            o_uop_ready,

    // gpr read port (dst operand read)
    output logic            o_gpr_rd_en,
    output logic [2:0]      o_gpr_rd_idx,
    input  logic [31:0]     i_gpr_rd_data,

    // writeback request
    output logic            o_wb_valid,
    output logic [2:0]      o_wb_gpr_idx,
    output logic [31:0]     o_wb_gpr_data,

    output logic            o_halted,

    input  logic            i_clock,
    input  logic            i_reset
);

    assign o_uop_ready  = 1'b1; // single-cycle execute for now
    assign o_gpr_rd_en  = i_uop_valid && (i_uop.kind == `X86_UOP_ALU_ADD);
    assign o_gpr_rd_idx = i_uop.dst_gpr;

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            o_wb_valid    <= 1'b0;
            o_wb_gpr_idx  <= 3'd0;
            o_wb_gpr_data <= 32'h0;
            o_halted      <= 1'b0;
        end else begin
            o_wb_valid <= 1'b0;

            if (i_uop_valid) begin
                case (i_uop.kind)
                    `X86_UOP_WRITE_GPR: begin
                        o_wb_valid    <= 1'b1;
                        o_wb_gpr_idx  <= i_uop.dst_gpr;
                        o_wb_gpr_data <= i_uop.src_imm;
                    end
                    `X86_UOP_ALU_ADD: begin
                        o_wb_valid    <= 1'b1;
                        o_wb_gpr_idx  <= i_uop.dst_gpr;
                        o_wb_gpr_data <= i_gpr_rd_data + i_uop.src_imm;
                    end
                    `X86_UOP_HALT: begin
                        o_halted <= 1'b1;
                    end
                    default: begin
                        // no-op
                    end
                endcase
            end
        end
    end

endmodule

