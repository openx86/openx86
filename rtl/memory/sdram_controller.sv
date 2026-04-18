/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements sdram_controller.
*/
// ============================================================================
// SDRAM Controller (real PHY) — minimal bring-up @ 50MHz
// ----------------------------------------------------------------------------
// - Host side: 32-bit word access with valid/ready/busy style handshake
// - SDRAM side: 16-bit SDR SDRAM (x16), single data rate
//
// This controller is intentionally minimal:
// - Fixed timing parameters suitable for a typical 50MHz board bring-up
// - Burst length = 2 (x16) so one READ/WRITE transfers one 32-bit word
// - Auto-refresh is supported with a simple periodic counter
//
// NOTE:
// - Address mapping assumes 16MB window and a simplified geometry:
//     row[12: 0] = halfword_addr[22: 10]
//     bank[ 1: 0] = halfword_addr[ 9:  8]
//     col[ 8: 0]  = {1'b0, halfword_addr[ 7: 0]}
// - This maps exactly 16MB: 2^13 rows * 4 banks * 256 cols * 2 bytes = 16MB
// ============================================================================

module sdram_controller #(
    // Clock frequency (Hz) used for init delay and refresh period
    parameter int CLK_HZ = 50_000_000,

    // SDRAM timing (in clock cycles @ CLK_HZ)
    parameter int T_RP  = 2,   // precharge time
    parameter int T_RCD = 2,   // activate to read/write
    parameter int T_RFC = 7,   // refresh cycle time
    parameter int T_MRD = 2,   // mode register set to command delay
    parameter int T_WR  = 2,   // write recovery
    parameter int CAS   = 2,   // CAS latency (2 or 3 typical)

    // Refresh period cycles (typical: 7.8us -> 390 cycles @ 50MHz)
    parameter int REFRESH_CYCLES = 390
) (
    input  logic          clk,
    input  logic          rst,

    // Host (SoC 中仅由 bus_controller 的 o_sdram_* 驱动；CPU 经 bus_controller 访问)
    input  logic          i_en,
    input  logic          i_we,
    input  logic [23: 0] i_addr_off,
    input  logic [31: 0] i_wdata,
    output logic [31: 0] o_rdata,
    output logic         o_ready,
    output logic         o_busy,

    // SDRAM PHY
    output logic         o_sdram_clk,
    output logic         o_sdram_cke,
    output logic         o_sdram_cs_n,
    output logic         o_sdram_ras_n,
    output logic         o_sdram_cas_n,
    output logic         o_sdram_we_n,
    output logic [ 1: 0] o_sdram_ba,
    output logic [12: 0] o_sdram_a,
    output logic [ 1: 0] o_sdram_dqm,
    output logic [15: 0] o_sdram_dq_out,
    output logic         o_sdram_dq_oe,
    input  logic [15: 0] i_sdram_dq_in
);

    // SDRAM clock is the same as system clock for bring-up
    assign o_sdram_clk = clk;
    assign o_sdram_cke = 1'b1;
    assign o_sdram_dqm = 2'b00;

    // ------------------------------------------------------------------------
    // Command encoding (active low)
    // ------------------------------------------------------------------------
    typedef enum logic [ 2: 0] {
        CMD_NOP,
        CMD_PRECHARGE_ALL,
        CMD_AUTO_REFRESH,
        CMD_LOAD_MODE,
        CMD_ACTIVE,
        CMD_READ_AP,
        CMD_WRITE_AP
    } cmd_t;

    cmd_t cmd;

    always_comb begin
        // Defaults: NOP (CS# asserted, RAS/CAS/WE deasserted)
        o_sdram_cs_n  = 1'b0;
        o_sdram_ras_n = 1'b1;
        o_sdram_cas_n = 1'b1;
        o_sdram_we_n  = 1'b1;

        unique case (cmd)
            CMD_NOP: begin end
            CMD_PRECHARGE_ALL: begin
                o_sdram_ras_n = 1'b0;
                o_sdram_cas_n = 1'b1;
                o_sdram_we_n  = 1'b0;
            end
            CMD_AUTO_REFRESH: begin
                o_sdram_ras_n = 1'b0;
                o_sdram_cas_n = 1'b0;
                o_sdram_we_n  = 1'b1;
            end
            CMD_LOAD_MODE: begin
                o_sdram_ras_n = 1'b0;
                o_sdram_cas_n = 1'b0;
                o_sdram_we_n  = 1'b0;
            end
            CMD_ACTIVE: begin
                o_sdram_ras_n = 1'b0;
                o_sdram_cas_n = 1'b1;
                o_sdram_we_n  = 1'b1;
            end
            CMD_READ_AP: begin
                o_sdram_ras_n = 1'b1;
                o_sdram_cas_n = 1'b0;
                o_sdram_we_n  = 1'b1;
            end
            CMD_WRITE_AP: begin
                o_sdram_ras_n = 1'b1;
                o_sdram_cas_n = 1'b0;
                o_sdram_we_n  = 1'b0;
            end
            default: begin end
        endcase
    end

    // ------------------------------------------------------------------------
    // Address mapping helpers
    // ------------------------------------------------------------------------
    logic [22: 0] halfword_addr = i_addr_off[23:  1]; // 16-bit addressed (byte_off >> 1)

    logic [12: 0] row  = halfword_addr[22: 10];
    logic [ 1: 0]  bank = halfword_addr[ 9:  8];
    logic [ 8: 0]  col  = {1'b0, halfword_addr[ 7: 0]}; // burst start col

    // ------------------------------------------------------------------------
    // Mode register value: BL=2, burst sequential, CAS=CAS, write burst=programmed
    // A[ 2: 0]=BL, A[3]=BT, A[ 6:  4]=CAS, A[9]=WB
    // ------------------------------------------------------------------------
    function automatic logic [12: 0] mode_reg_value(input int cas_lat);
        logic [12: 0] mr;
        begin
            mr = 13'b0;
            // BL=2
            mr[ 2: 0] = 3'b001;
            // BT=0 (sequential)
            mr[3]   = 1'b0;
            // CAS
            unique case (cas_lat)
                2: mr[ 6:  4] = 3'b010;
                3: mr[ 6:  4] = 3'b011;
                default: mr[ 6:  4] = 3'b010;
            endcase
            // WB=0 (programmed burst length)
            mr[9] = 1'b0;
            mode_reg_value = mr;
        end
    endfunction

    // ------------------------------------------------------------------------
    // Init + refresh + transaction FSM
    // ------------------------------------------------------------------------
    typedef enum logic [ 4: 0] {
        ST_INIT_WAIT,
        ST_INIT_PRE,
        ST_INIT_TRP,
        ST_INIT_AR1,
        ST_INIT_TRFC1,
        ST_INIT_AR2,
        ST_INIT_TRFC2,
        ST_INIT_MRS,
        ST_INIT_TMRD,
        ST_IDLE,
        ST_REFRESH,
        ST_REFRESH_TRFC,
        ST_ACTIVATE,
        ST_TRCD,
        ST_RW_CMD,
        ST_READ_WAIT,
        ST_READ_BEAT0,
        ST_READ_BEAT1,
        ST_WRITE_BEAT0,
        ST_WRITE_BEAT1,
        ST_TWR,
        ST_DONE
    } st_t;

    st_t st;
    int unsigned ctr;

    logic [23: 0] lat_addr;
    logic        lat_we;
    logic [31: 0] lat_wdata;

    logic refresh_due = (refresh_ctr >= REFRESH_CYCLES-1);
    int unsigned refresh_ctr;

    // dq output for writes
    logic [15: 0] dq_out_r;
    logic        dq_oe_r;
    assign o_sdram_dq_out = dq_out_r;
    assign o_sdram_dq_oe  = dq_oe_r;

    // Busy whenever not idle
    assign o_busy = (st != ST_IDLE);

    // Address pins default
    always_comb begin
        o_sdram_ba = 2'b00;
        o_sdram_a  = 13'b0;

        unique case (cmd)
            CMD_PRECHARGE_ALL: begin
                // A10=1 means precharge all banks
                o_sdram_a[10] = 1'b1;
            end
            CMD_LOAD_MODE: begin
                o_sdram_a  = mode_reg_value(CAS);
                o_sdram_ba = 2'b00;
            end
            CMD_ACTIVE: begin
                o_sdram_ba = bank;
                o_sdram_a  = row;
            end
            CMD_READ_AP,
            CMD_WRITE_AP: begin
                o_sdram_ba = bank;
                o_sdram_a[ 8: 0] = col;
                // Auto-precharge: A10=1
                o_sdram_a[10] = 1'b1;
            end
            default: begin end
        endcase
    end

    // Refresh schedule
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_ctr <= 0;
        end else begin
            if (st == ST_IDLE) begin
                if (refresh_ctr >= REFRESH_CYCLES-1)
                    refresh_ctr <= 0;
                else
                    refresh_ctr <= refresh_ctr + 1;
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            st       <= ST_INIT_WAIT;
            ctr      <= 0;
            cmd      <= CMD_NOP;
            o_ready  <= 1'b0;
            o_rdata  <= 32'h0;
            lat_addr <= 24'h0;
            lat_we   <= 1'b0;
            lat_wdata<= 32'h0;
            dq_out_r <= 16'h0;
            dq_oe_r  <= 1'b0;
        end else begin
            o_ready <= 1'b0;
            dq_oe_r <= 1'b0;
            cmd     <= CMD_NOP;

            unique case (st)
                // ----------------------------------------------------------------
                // Init: wait >= 200us after power-up before first command.
                // For reset-based bring-up, treat rst deassert as "power stable".
                // ----------------------------------------------------------------
                ST_INIT_WAIT: begin
                    if (ctr >= (CLK_HZ / 5_000)) begin // 200us
                        ctr <= 0;
                        st  <= ST_INIT_PRE;
                    end else begin
                        ctr <= ctr + 1;
                    end
                end
                ST_INIT_PRE: begin
                    cmd <= CMD_PRECHARGE_ALL;
                    ctr <= 0;
                    st  <= ST_INIT_TRP;
                end
                ST_INIT_TRP: begin
                    if (ctr >= T_RP-1) begin
                        ctr <= 0;
                        st  <= ST_INIT_AR1;
                    end else ctr <= ctr + 1;
                end
                ST_INIT_AR1: begin
                    cmd <= CMD_AUTO_REFRESH;
                    ctr <= 0;
                    st  <= ST_INIT_TRFC1;
                end
                ST_INIT_TRFC1: begin
                    if (ctr >= T_RFC-1) begin
                        ctr <= 0;
                        st  <= ST_INIT_AR2;
                    end else ctr <= ctr + 1;
                end
                ST_INIT_AR2: begin
                    cmd <= CMD_AUTO_REFRESH;
                    ctr <= 0;
                    st  <= ST_INIT_TRFC2;
                end
                ST_INIT_TRFC2: begin
                    if (ctr >= T_RFC-1) begin
                        ctr <= 0;
                        st  <= ST_INIT_MRS;
                    end else ctr <= ctr + 1;
                end
                ST_INIT_MRS: begin
                    cmd <= CMD_LOAD_MODE;
                    ctr <= 0;
                    st  <= ST_INIT_TMRD;
                end
                ST_INIT_TMRD: begin
                    if (ctr >= T_MRD-1) begin
                        ctr <= 0;
                        st  <= ST_IDLE;
                    end else ctr <= ctr + 1;
                end

                // ----------------------------------------------------------------
                // Idle: accept request or do refresh
                // ----------------------------------------------------------------
                ST_IDLE: begin
                    if (refresh_due) begin
                        st  <= ST_REFRESH;
                        ctr <= 0;
                    end else if (i_en) begin
                        lat_addr  <= i_addr_off;
                        lat_we    <= i_we;
                        lat_wdata <= i_wdata;
                        st        <= ST_ACTIVATE;
                        ctr       <= 0;
                    end
                end

                ST_REFRESH: begin
                    cmd <= CMD_AUTO_REFRESH;
                    ctr <= 0;
                    st  <= ST_REFRESH_TRFC;
                end
                ST_REFRESH_TRFC: begin
                    if (ctr >= T_RFC-1) begin
                        ctr <= 0;
                        st  <= ST_IDLE;
                    end else ctr <= ctr + 1;
                end

                // ----------------------------------------------------------------
                // Transaction: ACTIVE -> tRCD -> READ/WRITE (burst=2) -> done
                // ----------------------------------------------------------------
                ST_ACTIVATE: begin
                    cmd <= CMD_ACTIVE;
                    ctr <= 0;
                    st  <= ST_TRCD;
                end
                ST_TRCD: begin
                    if (ctr >= T_RCD-1) begin
                        ctr <= 0;
                        st  <= ST_RW_CMD;
                    end else ctr <= ctr + 1;
                end
                ST_RW_CMD: begin
                    if (lat_we) begin
                        cmd <= CMD_WRITE_AP;
                        st  <= ST_WRITE_BEAT0;
                    end else begin
                        cmd <= CMD_READ_AP;
                        ctr <= 0;
                        st  <= ST_READ_WAIT;
                    end
                end

                // Read path: wait CAS then sample 2 beats (16-bit each)
                ST_READ_WAIT: begin
                    if (ctr >= CAS-1) begin
                        st  <= ST_READ_BEAT0;
                        ctr <= 0;
                    end else ctr <= ctr + 1;
                end
                ST_READ_BEAT0: begin
                    // Lower 16 bits
                    o_rdata[15: 0] <= i_sdram_dq_in;
                    st <= ST_READ_BEAT1;
                end
                ST_READ_BEAT1: begin
                    // Upper 16 bits
                    o_rdata[31: 16] <= i_sdram_dq_in;
                    st <= ST_DONE;
                end

                // Write path: drive 2 beats then wait tWR
                ST_WRITE_BEAT0: begin
                    dq_out_r <= lat_wdata[15: 0];
                    dq_oe_r  <= 1'b1;
                    st       <= ST_WRITE_BEAT1;
                end
                ST_WRITE_BEAT1: begin
                    dq_out_r <= lat_wdata[31: 16];
                    dq_oe_r  <= 1'b1;
                    ctr      <= 0;
                    st       <= ST_TWR;
                end
                ST_TWR: begin
                    if (ctr >= T_WR-1) begin
                        ctr <= 0;
                        st  <= ST_DONE;
                    end else ctr <= ctr + 1;
                end

                ST_DONE: begin
                    o_ready <= 1'b1;
                    st      <= ST_IDLE;
                end

                default: st <= ST_IDLE;
            endcase
        end
    end

endmodule

