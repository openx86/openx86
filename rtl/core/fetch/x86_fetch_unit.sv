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
    // flat 128-bit instruction buffer (avoids iverilog "constant selects in always_*" issue)
    logic [127:0] instr_buf;

    // Drive output array from flat buffer (big-endian: byte 0 is MSB)
    assign o_instruction[ 0] = instr_buf[127:120];
    assign o_instruction[ 1] = instr_buf[119:112];
    assign o_instruction[ 2] = instr_buf[111:104];
    assign o_instruction[ 3] = instr_buf[103: 96];
    assign o_instruction[ 4] = instr_buf[ 95: 88];
    assign o_instruction[ 5] = instr_buf[ 87: 80];
    assign o_instruction[ 6] = instr_buf[ 79: 72];
    assign o_instruction[ 7] = instr_buf[ 71: 64];
    assign o_instruction[ 8] = instr_buf[ 63: 56];
    assign o_instruction[ 9] = instr_buf[ 55: 48];
    assign o_instruction[10] = instr_buf[ 47: 40];
    assign o_instruction[11] = instr_buf[ 39: 32];
    assign o_instruction[12] = instr_buf[ 31: 24];
    assign o_instruction[13] = instr_buf[ 23: 16];
    assign o_instruction[14] = instr_buf[ 15:  8];
    assign o_instruction[15] = instr_buf[  7:  0];

    // constant outputs for read-only instruction fetch
    assign o_bus_write_enable = 1'b0;
    assign o_bus_io_access    = 1'b0;
    assign o_bus_data_write   = 32'h0;

    // address formation
    assign base_addr = i_protected_mode ?
        (i_cs_base + i_eip) :
        ({i_cs, 4'h0} + {16'h0, i_eip[15:0]});
    assign o_fetch_linear_base = base_addr;

    // bus address increments by 4 bytes per beat
    assign o_bus_address = base_addr + {28'h0, beat, 2'b00};

    // state machine drives o_bus_valid and fills o_instruction
    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            state         <= ST_IDLE;
            beat          <= 2'd0;
            o_bus_valid   <= 1'b0;
            o_instr_ready <= 1'b0;
            instr_buf     <= 128'h0;
        end else begin
            o_instr_ready <= 1'b0;

            case (state)
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
                        // store dword into flat 128-bit buffer; big-endian byte order
                        case (beat)
                            2'd0: instr_buf[127:96] <= i_bus_data_read;
                            2'd1: instr_buf[ 95:64] <= i_bus_data_read;
                            2'd2: instr_buf[ 63:32] <= i_bus_data_read;
                            default: instr_buf[ 31: 0] <= i_bus_data_read;
                        endcase

                        beat <= beat + 2'd1;

                        if (beat == 2'd3) begin
                            o_bus_valid   <= 1'b0;
                            o_instr_ready <= 1'b1;
                            state         <= ST_IDLE;
                        end else begin
                            state <= state;
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

