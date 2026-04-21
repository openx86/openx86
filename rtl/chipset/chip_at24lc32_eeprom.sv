/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_at24lc32_eeprom.
*/
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
    // ------------------------------------------------------------------------
    // I2C 总线引脚
    // ------------------------------------------------------------------------
    input  logic i_scl,    // I2C 串行时钟（输入采样）
    input  logic i_sda,    // I2C 串行数据
    output logic o_sda_oe, // 1=开漏拉低 SDA，0=释放由上拉决定

    // ------------------------------------------------------------------------
    // 仿真/集成用系统时钟与复位
    // ------------------------------------------------------------------------
    input  logic clk,      // 模块采样时钟
    input  logic rst_n     // 异步低有效复位
);

    localparam int AW = $clog2(P_NUM_BYTES);
    localparam logic [ 3: 0] DEV_TYPE = 4'b1010; // 24xx EEPROM family

    (* ramstyle = "M9K" *)
    logic [ 7: 0] mem[0:P_NUM_BYTES-1];

    logic scl_q, sda_q;  // SCL/SDA 输入同步寄存
    // 同步 I2C 输入，滤毛刺意图由外部保证。
    always_ff @(posedge clk) begin
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

    // 边沿与起停条件（相对同步后的前一拍）。
    always_comb begin
        scl_rise   = (scl_q == 1'b0) && (i_scl == 1'b1);
        scl_fall   = (scl_q == 1'b1) && (i_scl == 1'b0);
        start_cond = (sda_q == 1'b1) && (i_sda == 1'b0) && (i_scl == 1'b1);
        stop_cond  = (sda_q == 1'b0) && (i_sda == 1'b1) && (i_scl == 1'b1);
    end

    typedef enum logic [ 3: 0] {
        ST_IDLE,       // 空闲
        ST_RECV_CTRL,  // 收器件地址+RW
        ST_ACK_CTRL,   // 控制字节 ACK 相位
        ST_RECV_AH,    // 收字地址高字节
        ST_ACK_AH,     // 高地址字节 ACK
        ST_RECV_AL,    // 收字地址低字节
        ST_ACK_AL,     // 低地址字节 ACK
        ST_RECV_DATA,  // 页写字节
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
