// ============================================================================
// x86 instruction fetch unit (minimal)
// - Forms linear address from CS:IP (real mode) or CS.base+EIP (protected)
// - Fetches 16 bytes (4 dwords) to cover longest legacy instruction (15 bytes)
// - Raises o_instr_ready when buffer filled
// - Handshake: i_pc_valid starts a fetch; o_instr_ready pulses high for one cycle
// - clock/reset at end of port list
// ============================================================================

`include "rtl/core/x86_types.sv"

module x86_fetch_unit (
    // bus read channel (matches existing simple bus interface style)
    output logic        o_bus_valid,
    input  logic        i_bus_ready,
    output logic        o_bus_write_enable,
    output logic        o_bus_io_access,
    output logic [31:0] o_bus_address,
    input  logic [31:0] i_bus_data_read,
    output logic [31:0] o_bus_data_write,

    // control/state
    input  logic        i_pc_valid,
    input  logic [31:0] i_eip,
    input  logic [15:0] i_cs,
    input  logic [31:0] i_cs_base,
    input  logic        i_protected_mode,

    // output instruction bytes
    output logic [7:0]  o_instruction [0:15],
    output logic        o_instr_ready,
    output logic [31:0] o_fetch_linear_base,

    input  logic        i_clock,
    input  logic        i_reset
);

    typedef enum logic [1:0] {
        ST_IDLE  = 2'd0,
        ST_RD0   = 2'd1,
        ST_RD1   = 2'd2,
        ST_RD2_3 = 2'd3
    } state_t;

    state_t state;
    logic [1:0] beat;
    logic [31:0] base_addr;

    // constant outputs for read-only instruction fetch
    assign o_bus_write_enable = 1'b0;
    assign o_bus_io_access    = 1'b0;
    assign o_bus_data_write   = 32'h0;

    // address formation
    always_comb begin
        if (i_protected_mode) begin
            base_addr = i_cs_base + i_eip;
        end else begin
            // real mode: linear = (CS<<4) + IP (use EIP low16 as IP)
            base_addr = {i_cs, 4'h0} + {16'h0, i_eip[15:0]};
        end
    end
    assign o_fetch_linear_base = base_addr;

    // bus address increments by 4 bytes per beat
    always_comb begin
        o_bus_address = base_addr + {30'h0, beat, 2'b00};
    end

    // state machine drives o_bus_valid and fills o_instruction
    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            state         <= ST_IDLE;
            beat          <= 2'd0;
            o_bus_valid   <= 1'b0;
            o_instr_ready <= 1'b0;
            for (int i = 0; i < 16; i++) begin
                o_instruction[i] <= 8'h00;
            end
        end else begin
            o_instr_ready <= 1'b0;

            unique case (state)
                ST_IDLE: begin
                    beat        <= 2'd0;
                    o_bus_valid <= 1'b0;
                    if (i_pc_valid) begin
                        o_bus_valid <= 1'b1;
                        state       <= ST_RD0;
                    end
                end

                ST_RD0, ST_RD1, ST_RD2_3: begin
                    if (i_bus_ready && o_bus_valid) begin
                        // store current dword as 4 bytes, big-endian mapping consistent with existing bus_tb
                        o_instruction[{beat, 2'b00} + 0] <= i_bus_data_read[31:24];
                        o_instruction[{beat, 2'b00} + 1] <= i_bus_data_read[23:16];
                        o_instruction[{beat, 2'b00} + 2] <= i_bus_data_read[15: 8];
                        o_instruction[{beat, 2'b00} + 3] <= i_bus_data_read[ 7: 0];

                        beat <= beat + 2'd1;

                        if (beat == 2'd3) begin
                            // completed 4 beats => 16 bytes
                            o_bus_valid   <= 1'b0;
                            o_instr_ready <= 1'b1;
                            state         <= ST_IDLE;
                        end else begin
                            // continue next beat (keep valid asserted)
                            state <= state; // stay
                        end
                    end
                end
                default: begin
                    state <= ST_IDLE;
                end
            endcase
        end
    end

endmodule

