// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : chip_at24lc32_eeprom.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : models module
// ============================================================================

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
// - memory[] 不在本模块做上电/文件初始化；由 testbench 写入（如擦除态 0xFF）。
// ============================================================================

module chip_at24lc32_eeprom #(
    parameter logic [ 2: 0] P_A_PINS     = 3'b000,
    parameter int         P_NUM_BYTES  = 4096,
    parameter int         P_PAGE_BYTES = 32
) (
    // =========================
    // I2C bus pins
    // =========================
    input  logic i_scl,
    input  logic i_sda,
    output logic o_sda_oe,

    // =========================
    // clock and reset
    // =========================
    input  logic clk,
    input  logic rst_n
);

    localparam int AW = $clog2(P_NUM_BYTES);
    localparam logic [ 3: 0] DEV_TYPE = 4'b1010; // 24xx EEPROM family

    (* ramstyle = "M9K" *)
    logic [ 7: 0] mem[0:P_NUM_BYTES-1];

    // ============================================================
    // I2C input synchronization registers
    // ============================================================
    logic scl_q, sda_q;
    always_ff @(posedge clk) begin : ff_i2c_sync
        if (~rst_n) begin
            scl_q <= 1'b1;
            sda_q <= 1'b1;
        end else begin
            scl_q <= i_scl;
            sda_q <= i_sda;
        end
    end

    logic scl_rise;
    logic scl_fall;

    logic start_cond;  // START 条件
    logic stop_cond;   // STOP 条件

    // ============================================================
    // edge and start/stop condition detection
    // ============================================================
    always_comb begin : comb_edge_detection
        scl_rise   = (scl_q == 1'b0) && (i_scl == 1'b1);
        scl_fall   = (scl_q == 1'b1) && (i_scl == 1'b0);
        start_cond = (sda_q == 1'b1) && (i_sda == 1'b0) && (i_scl == 1'b1);
        stop_cond  = (sda_q == 1'b0) && (i_sda == 1'b1) && (i_scl == 1'b1);
    end

    // ============================================================
    // I2C state machine
    // ============================================================
    typedef enum logic [ 3: 0] {
        ST_IDLE,       // idle
        ST_RECV_CTRL,  // receive device address + RW
        ST_ACK_CTRL,   // control byte ACK phase
        ST_RECV_AH,    // receive word address high byte
        ST_ACK_AH,     // high address byte ACK
        ST_RECV_AL,    // receive word address low byte
        ST_ACK_AL,     // low address byte ACK
        ST_RECV_DATA,  // page write byte
        ST_ACK_DATA,
        ST_SEND_DATA,  // 读数据位移位输出
        ST_RECV_MACK   // 读字节后收主机 ACK
    } state_t;

    state_t state;  // I2C 位级 FSM

    logic [ 7: 0] shreg;   // 移位寄存器
    logic [ 2: 0] bitcnt;  // 位计数
    logic       rw;        // 当前事务读/写
    logic       addr_match;// 7 位地址匹配

    logic [15: 0] word_addr;  // 当前字地址指针
    logic [15: 0] write_base; // 页写基址（页回绕）

    logic [ 7: 0]  tx_byte; // 读事务待移出字节
    logic [ 2: 0]  tx_bit;  // 读位移位索引

    function automatic logic is_ctrl_match(input logic [ 7: 0] ctrl);
        logic [ 6: 0] a7;
        begin
            a7 = ctrl[ 7:  1];
            is_ctrl_match = (a7[ 6:  3] == DEV_TYPE) && (a7[ 2: 0] == A_PINS);
        end
    endfunction

    // 5.032：unpacked memory[] 在 NBA 中勿用函数返回值作下标；索引用 word_addr[AW-1:0]。

    // I2C 位/字节状态机：起停、ACK、读写与开漏 SDA 驱动。
    always_ff @(posedge clk) begin
        if (~rst_n) begin
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
                                addr_match <= is_ctrl_match({shreg[ 7:  1], i_sda});
                                rw         <= i_sda;
                                state      <= ST_ACK_CTRL;
                            end else if (state == ST_RECV_AH) begin
                                word_addr[15:  8] <= {shreg[ 7:  1], i_sda};
                                state           <= ST_ACK_AH;
                            end else if (state == ST_RECV_AL) begin
                                word_addr[ 7: 0] <= {shreg[ 7:  1], i_sda};
                                write_base <= {word_addr[15:  8], {shreg[ 7:  1], i_sda}} & ~(PAGE_BYTES-1);
                                state      <= ST_ACK_AL;
                            end else begin
                                if (addr_match) begin
                                    mem[word_addr[AW-1:0]] <= {shreg[ 7:  1], i_sda};
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
                            tx_byte   <= mem[word_addr[AW-1:0]];
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
                                tx_byte   <= mem[word_addr[AW-1:0]];
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
