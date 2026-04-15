// ============================================================================
// x86_core_top
// ----------------------------------------------------------------------------
// A minimal x86 core wrapper used by soc_top.
//
// NOTE:
// - This is currently a bring-up core that can execute the default bootstub
//   installed by pc_bios_24lc32 when INSTALL_DEFAULT_BOOTSTUB=1.
// - It implements only a tiny subset of x86 needed by soc_top_tb:
//     - MOV r32, imm32 (B8+rd)
//     - ADD EAX, imm8  (83 C0 ib)
//     - HLT            (F4)
// - The bus is a simple valid/ready/busy handshake as defined in rtl/bus.sv.
// ============================================================================

module x86_core_top (
    // SoC bus interface
    output logic        o_bus_valid,
    input  logic        i_bus_ready,
    input  logic        i_bus_busy,
    output logic        o_bus_write_enable,
    output logic        o_bus_io_access,
    output logic [31:0] o_bus_address,
    input  logic [31:0] i_bus_data_read,
    output logic [31:0] o_bus_data_write,

    // Interrupt request (PIC INTR). Not handled in bring-up core yet.
    input  logic        i_intr,

    // External override (debug) for CR0
    input  logic        i_cr0_we,
    input  logic [31:0] i_cr0_wdata,

    output logic        o_halted,

    input  logic        i_clock,
    input  logic        i_reset
);

    // ------------------------------------------------------------
    // GPRs (for soc_top_tb visibility)
    // ------------------------------------------------------------
    // The testbench expects dut.u_cpu.u_gpr.gpr[0] to be EAX.
    // Keep this module name/field stable.
    x86_gpr_file u_gpr (
        .i_clock ( i_clock ),
        .i_reset ( i_reset ),
        .i_we    ( gpr_we ),
        .i_widx  ( gpr_widx ),
        .i_wdata ( gpr_wdata ),
        .o_r0    ( eax )
    );

    logic        gpr_we;
    logic [2:0]  gpr_widx;
    logic [31:0] gpr_wdata;
    logic [31:0] eax;

    // ------------------------------------------------------------
    // Minimal state machine + byte prefetch
    // ------------------------------------------------------------
    typedef enum logic [3:0] {
        S_RESET,
        S_PREFETCH_REQ,
        S_PREFETCH_WAIT,
        S_EXEC_FETCH_OP,
        S_EXEC_MOV_IMM,
        S_EXEC_ADD_IMM8,
        S_HALT
    } state_t;

    state_t state;

    logic [31:0] eip;

    // Prefetch buffer for instruction bytes
    logic [31:0] pf_word;
    logic [31:0] pf_addr_aligned;
    logic        pf_valid;
    logic [1:0]  pf_index;

    // Current opcode / operands
    logic [7:0] op;
    logic [7:0] modrm;
    logic [7:0] imm8;
    logic [31:0] imm32;
    logic [1:0]  imm32_count;

    // Bus regs (single driver)
    logic        bus_valid_r;
    logic        bus_we_r;
    logic        bus_io_r;
    logic [31:0] bus_addr_r;
    logic [31:0] bus_wdata_r;

    assign o_bus_valid        = bus_valid_r;
    assign o_bus_write_enable = bus_we_r;
    assign o_bus_io_access    = bus_io_r;
    assign o_bus_address      = bus_addr_r;
    assign o_bus_data_write   = bus_wdata_r;

    // Minimal CR0 storage (only to satisfy interface; not used yet)
    logic [31:0] cr0;

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            state   <= S_RESET;
            eip     <= 32'h000F_FFF0; // physical reset vector
            o_halted<= 1'b0;
            cr0     <= 32'h0;
            pf_word <= 32'h0;
            pf_addr_aligned <= 32'h0;
            pf_valid <= 1'b0;
            pf_index <= 2'b00;
            op <= 8'h00;
            modrm <= 8'h00;
            imm8 <= 8'h00;
            imm32 <= 32'h0;
            imm32_count <= 2'b00;
            bus_valid_r <= 1'b0;
            bus_we_r <= 1'b0;
            bus_io_r <= 1'b0;
            bus_addr_r <= 32'h0;
            bus_wdata_r <= 32'h0;
            gpr_we <= 1'b0;
            gpr_widx <= 3'd0;
            gpr_wdata <= 32'h0;
        end else begin
            if (i_cr0_we) begin
                cr0 <= i_cr0_wdata;
            end

            // defaults each cycle
            bus_valid_r <= 1'b0;
            bus_we_r    <= 1'b0;
            bus_io_r    <= 1'b0;
            bus_addr_r  <= bus_addr_r;
            bus_wdata_r <= 32'h0;
            gpr_we      <= 1'b0;

            unique case (state)
                S_RESET: begin
                    pf_valid <= 1'b0;
                    pf_index <= eip[1:0];
                    pf_addr_aligned <= {eip[31:2], 2'b00};
                    state <= S_PREFETCH_REQ;
                end

                S_PREFETCH_REQ: begin
                    // Request aligned 32-bit word at pf_addr_aligned
                    bus_valid_r <= 1'b1;
                    bus_addr_r  <= pf_addr_aligned;
                    state       <= S_PREFETCH_WAIT;
                end

                S_PREFETCH_WAIT: begin
                    bus_valid_r <= 1'b1;
                    bus_addr_r  <= pf_addr_aligned;
                    if (i_bus_ready && !i_bus_busy) begin
                        pf_word  <= i_bus_data_read;
                        pf_valid <= 1'b1;
                        state    <= S_EXEC_FETCH_OP;
                    end
                end

                S_EXEC_FETCH_OP: begin
                    // Extract next byte from prefetch word; if exhausted, refill.
                    if (!pf_valid) begin
                        pf_addr_aligned <= {eip[31:2], 2'b00};
                        pf_index <= eip[1:0];
                        state <= S_PREFETCH_REQ;
                    end else begin
                        unique case (pf_index)
                            2'd0: op <= pf_word[7:0];
                            2'd1: op <= pf_word[15:8];
                            2'd2: op <= pf_word[23:16];
                            2'd3: op <= pf_word[31:24];
                            default: op <= 8'h00;
                        endcase

                        // advance EIP by 1
                        eip <= eip + 32'd1;
                        pf_index <= pf_index + 2'd1;
                        if (pf_index == 2'd3) begin
                            pf_valid <= 1'b0;
                            pf_addr_aligned <= pf_addr_aligned + 32'd4;
                            pf_index <= 2'd0;
                        end

                        // Decode supported opcodes
                        if (op == 8'hF4) begin
                            o_halted <= 1'b1;
                            state <= S_HALT;
                        end else if (op == 8'hB8) begin
                            imm32 <= 32'h0;
                            imm32_count <= 2'd0;
                            state <= S_EXEC_MOV_IMM;
                        end else if (op == 8'h83) begin
                            state <= S_EXEC_ADD_IMM8;
                        end else begin
                            o_halted <= 1'b1;
                            state <= S_HALT;
                        end
                    end
                end

                S_EXEC_MOV_IMM: begin
                    // read 4 imm bytes (little-endian) from stream
                    if (!pf_valid) begin
                        pf_addr_aligned <= {eip[31:2], 2'b00};
                        pf_index <= eip[1:0];
                        state <= S_PREFETCH_REQ;
                    end else begin
                        logic [7:0] b;
                        unique case (pf_index)
                            2'd0: b = pf_word[7:0];
                            2'd1: b = pf_word[15:8];
                            2'd2: b = pf_word[23:16];
                            default: b = pf_word[31:24];
                        endcase

                        imm32 <= imm32 | (32'(b) << (imm32_count * 8));
                        imm32_count <= imm32_count + 2'd1;

                        // advance EIP and prefetch index
                        eip <= eip + 32'd1;
                        pf_index <= pf_index + 2'd1;
                        if (pf_index == 2'd3) begin
                            pf_valid <= 1'b0;
                            pf_addr_aligned <= pf_addr_aligned + 32'd4;
                            pf_index <= 2'd0;
                        end

                        if (imm32_count == 2'd3) begin
                            // Commit MOV EAX, imm32
                            gpr_we    <= 1'b1;
                            gpr_widx  <= 3'd0;
                            gpr_wdata <= imm32 | (32'(b) << 24);
                            state     <= S_EXEC_FETCH_OP;
                        end
                    end
                end

                S_EXEC_ADD_IMM8: begin
                    // Expect ModRM = C0 (ADD r/m32, imm8 with EAX)
                    if (!pf_valid) begin
                        pf_addr_aligned <= {eip[31:2], 2'b00};
                        pf_index <= eip[1:0];
                        state <= S_PREFETCH_REQ;
                    end else begin
                        // fetch ModRM
                        unique case (pf_index)
                            2'd0: modrm <= pf_word[7:0];
                            2'd1: modrm <= pf_word[15:8];
                            2'd2: modrm <= pf_word[23:16];
                            default: modrm <= pf_word[31:24];
                        endcase
                        eip <= eip + 32'd1;
                        pf_index <= pf_index + 2'd1;
                        if (pf_index == 2'd3) begin
                            pf_valid <= 1'b0;
                            pf_addr_aligned <= pf_addr_aligned + 32'd4;
                            pf_index <= 2'd0;
                        end

                        // If not C0, halt (unsupported)
                        if (modrm != 8'hC0) begin
                            o_halted <= 1'b1;
                            state <= S_HALT;
                        end else begin
                            // fetch imm8
                            if (!pf_valid) begin
                                pf_addr_aligned <= {eip[31:2], 2'b00};
                                pf_index <= eip[1:0];
                                state <= S_PREFETCH_REQ;
                            end else begin
                                unique case (pf_index)
                                    2'd0: imm8 <= pf_word[7:0];
                                    2'd1: imm8 <= pf_word[15:8];
                                    2'd2: imm8 <= pf_word[23:16];
                                    default: imm8 <= pf_word[31:24];
                                endcase
                                eip <= eip + 32'd1;
                                pf_index <= pf_index + 2'd1;
                                if (pf_index == 2'd3) begin
                                    pf_valid <= 1'b0;
                                    pf_addr_aligned <= pf_addr_aligned + 32'd4;
                                    pf_index <= 2'd0;
                                end

                                gpr_we    <= 1'b1;
                                gpr_widx  <= 3'd0;
                                gpr_wdata <= eax + {{24{imm8[7]}}, imm8};
                                state     <= S_EXEC_FETCH_OP;
                            end
                        end
                    end
                end

                S_HALT: begin
                    o_halted <= 1'b1;
                end

                default: begin
                    state <= S_HALT;
                    o_halted <= 1'b1;
                end
            endcase
        end
    end

endmodule

// Simple GPR file with a public array for testbench visibility.
module x86_gpr_file (
    input  logic        i_clock,
    input  logic        i_reset,
    input  logic        i_we,
    input  logic [2:0]  i_widx,
    input  logic [31:0] i_wdata,
    output logic [31:0] o_r0
);
    logic [31:0] gpr [0:7];

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            for (int i = 0; i < 8; i++) begin
                gpr[i] <= 32'h0;
            end
        end else if (i_we) begin
            gpr[i_widx] <= i_wdata;
        end
    end

    assign o_r0 = gpr[0];
endmodule

