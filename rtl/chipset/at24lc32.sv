// ============================================================================
// AT24LC32 / 24LC32 I2C EEPROM (32 Kbit = 4096 x 8) — behavioral model
//
// - 7-bit device address: 0b1010xxx (A2..A0 are "hardware address" pins)
// - 2-byte word address
// - Page write size: 32 bytes (writes wrap within page)
//
// This module models an I2C slave:
// - Samples SDA on SCL rising edges.
// - Drives SDA low (open-drain) on SCL low phases.
// - Detects START/STOP by SDA edge while SCL high.
//
// Notes:
// - This is intended for simulation / simple FPGA integration, not a timing-accurate
//   silicon model.
// - External pull-up is expected on SDA/SCL; in TB, drive '1' for released.
// - mem[] 不在本模块做上电/文件初始化；由 testbench 写入（如擦除态 0xFF）。
// ============================================================================

module at24lc32 #(
    parameter logic [2:0] A_PINS = 3'b000,
    parameter int         NUM_BYTES = 4096,
    parameter int         PAGE_BYTES = 32
) (
    input  logic i_clock,
    input  logic i_reset,

    input  logic i_scl,
    input  logic i_sda,
    output logic o_sda_oe   // 1 = drive low (0), 0 = release (Z)
);

    localparam int AW = $clog2(NUM_BYTES);
    localparam logic [3:0] DEV_TYPE = 4'b1010; // 24xx EEPROM family

    (* ram_style = "block" *)
    logic [7:0] mem[0:NUM_BYTES-1];

    logic scl_q, sda_q;
    always_ff @(posedge i_clock) begin
        if (i_reset) begin
            scl_q <= 1'b1;
            sda_q <= 1'b1;
        end else begin
            scl_q <= i_scl;
            sda_q <= i_sda;
        end
    end

    wire scl_rise = (scl_q == 1'b0) && (i_scl == 1'b1);
    wire scl_fall = (scl_q == 1'b1) && (i_scl == 1'b0);

    wire start_cond = (sda_q == 1'b1) && (i_sda == 1'b0) && (i_scl == 1'b1);
    wire stop_cond  = (sda_q == 1'b0) && (i_sda == 1'b1) && (i_scl == 1'b1);

    typedef enum logic [3:0] {
        ST_IDLE,
        ST_RECV_CTRL,
        ST_ACK_CTRL,
        ST_RECV_AH,
        ST_ACK_AH,
        ST_RECV_AL,
        ST_ACK_AL,
        ST_RECV_DATA,
        ST_ACK_DATA,
        ST_SEND_DATA,
        ST_RECV_MACK
    } state_t;

    state_t state;

    logic [7:0] shreg;
    logic [2:0] bitcnt;
    logic       rw;
    logic       addr_match;

    logic [15:0] word_addr;
    logic [15:0] write_base;

    logic [7:0]  tx_byte;
    logic [2:0]  tx_bit;

    function automatic logic is_ctrl_match(input logic [7:0] ctrl);
        logic [6:0] a7;
        a7 = ctrl[7:1];
        return (a7[6:3] == DEV_TYPE) && (a7[2:0] == A_PINS);
    endfunction

    function automatic logic [AW-1:0] idx(input logic [15:0] wa);
        return wa[AW-1:0];
    endfunction

    always_ff @(posedge i_clock) begin
        if (i_reset) begin
            o_sda_oe    <= 1'b0;
            state       <= ST_IDLE;
            shreg       <= 8'h00;
            bitcnt      <= 3'd0;
            rw          <= 1'b0;
            addr_match  <= 1'b0;
            word_addr   <= 16'h0000;
            write_base  <= 16'h0000;
            tx_byte     <= 8'hFF;
            tx_bit      <= 3'd7;
        end else begin
            if (start_cond) begin
                state      <= ST_RECV_CTRL;
                bitcnt     <= 3'd7;
                o_sda_oe   <= 1'b0;
            end

            if (stop_cond) begin
                state     <= ST_IDLE;
                o_sda_oe  <= 1'b0;
            end

            if (scl_rise) begin
                unique case (state)
                    ST_RECV_CTRL,
                    ST_RECV_AH,
                    ST_RECV_AL,
                    ST_RECV_DATA: begin
                        shreg[bitcnt] <= i_sda;
                        if (bitcnt == 0) begin
                            if (state == ST_RECV_CTRL) begin
                                addr_match <= is_ctrl_match({shreg[7:1], i_sda});
                                rw         <= i_sda;
                                state      <= ST_ACK_CTRL;
                            end else if (state == ST_RECV_AH) begin
                                word_addr[15:8] <= {shreg[7:1], i_sda};
                                state           <= ST_ACK_AH;
                            end else if (state == ST_RECV_AL) begin
                                word_addr[7:0] <= {shreg[7:1], i_sda};
                                write_base <= {word_addr[15:8], {shreg[7:1], i_sda}} & ~(PAGE_BYTES-1);
                                state      <= ST_ACK_AL;
                            end else begin
                                if (addr_match) begin
                                    mem[idx(word_addr)] <= {shreg[7:1], i_sda};
                                    if (((word_addr + 1) & (PAGE_BYTES-1)) == 0)
                                        word_addr <= write_base;
                                    else
                                        word_addr <= word_addr + 1;
                                end
                                state <= ST_ACK_DATA;
                            end
                            bitcnt <= 3'd7;
                        end else begin
                            bitcnt <= bitcnt - 1;
                        end
                    end

                    ST_RECV_MACK: begin
                        if (!addr_match) begin
                            state <= ST_IDLE;
                        end else if (i_sda == 1'b0) begin
                            tx_byte   <= mem[idx(word_addr)];
                            word_addr <= word_addr + 1;
                            tx_bit    <= 3'd7;
                            state     <= ST_SEND_DATA;
                        end else begin
                            state <= ST_IDLE;
                        end
                    end

                    default: begin
                    end
                endcase
            end

            if (scl_fall) begin
                unique case (state)
                    ST_ACK_CTRL: begin
                        o_sda_oe <= addr_match ? 1'b1 : 1'b0;
                        if (addr_match) begin
                            if (rw) begin
                                tx_byte   <= mem[idx(word_addr)];
                                word_addr <= word_addr + 1;
                                tx_bit    <= 3'd7;
                                state     <= ST_SEND_DATA;
                            end else begin
                                state <= ST_RECV_AH;
                            end
                        end else begin
                            state <= ST_IDLE;
                        end
                    end

                    ST_ACK_AH: begin
                        o_sda_oe <= addr_match ? 1'b1 : 1'b0;
                        state    <= ST_RECV_AL;
                    end

                    ST_ACK_AL: begin
                        o_sda_oe <= addr_match ? 1'b1 : 1'b0;
                        state    <= ST_RECV_DATA;
                    end

                    ST_ACK_DATA: begin
                        o_sda_oe <= addr_match ? 1'b1 : 1'b0;
                        state    <= ST_RECV_DATA;
                    end

                    ST_SEND_DATA: begin
                        if (!addr_match) begin
                            o_sda_oe <= 1'b0;
                            state    <= ST_IDLE;
                        end else begin
                            o_sda_oe <= (tx_byte[tx_bit] == 1'b0);
                            if (tx_bit == 0) begin
                                state  <= ST_RECV_MACK;
                            end else begin
                                tx_bit <= tx_bit - 1;
                            end
                        end
                    end

                    default: begin
                        o_sda_oe <= 1'b0;
                    end
                endcase
            end
        end
    end

endmodule
