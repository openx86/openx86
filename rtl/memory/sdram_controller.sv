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
    input  logic          clk,            // 控制器与 SDRAM 同频系统时钟
    input  logic          rst_n,          // 异步低有效复位：初始化 FSM 与输出

    // Host (SoC 中仅由 bus_controller 的 o_sdram_* 驱动；CPU 经 bus_controller 访问)
    input  logic          i_en,           // 主机请求：与握手配合发起一次 32b 访问
    input  logic          i_we,           // 1=写，0=读（在 i_en 有效时锁存）
    input  logic [23: 0] i_addr_off,      // 字节窗口内偏移（映射见文件头；半字地址由高位推导）
    input  logic [31: 0] i_wdata,         // 写数据（32b，分两拍 16b 下发到 DQ）
    output logic [31: 0] o_rdata,        // 读回数据（两拍 16b 拼成）
    output logic         o_ready,        // 单周期完成脉冲：事务结束可接受新请求
    output logic         o_busy,         // 非空闲：初始化/刷新/传输任一进行中

    // SDRAM PHY
    output logic         o_sdram_clk,    // 送至器件的时钟（本实现直连 clk）
    output logic         o_sdram_cke,    // 时钟使能（常 1）
    output logic         o_sdram_cs_n,   // 片选#（与 RAS/CAS/WE 组成命令）
    output logic         o_sdram_ras_n,  // 行地址选通#
    output logic         o_sdram_cas_n,  // 列地址选通#
    output logic         o_sdram_we_n,   // 写使能#
    output logic [ 1: 0] o_sdram_ba,     // Bank 选择
    output logic [12: 0] o_sdram_a,      // 地址/模式字段（含 A10 自动预充等语义）
    output logic [ 1: 0] o_sdram_dqm,    // 数据掩码（常 0 表示全字节有效）
    output logic [15: 0] o_sdram_dq_out, // 写驱动到 DQ 总线的数据
    output logic         o_sdram_dq_oe,  // DQ 输出使能（写节拍拉高）
    input  logic [15: 0] i_sdram_dq_in   // 从 DQ 总线采样（读数据）
);

    // SDRAM clk is the same as system clk for bring-up
    assign o_sdram_clk = clk;
    assign o_sdram_cke = 1'b1;
    assign o_sdram_dqm = 2'b00;

    // ------------------------------------------------------------------------
    // Command encoding (active low)
    // ------------------------------------------------------------------------
    typedef enum logic [ 2: 0] {
        CMD_NOP,             // 空操作：保持总线空闲
        CMD_PRECHARGE_ALL, // 全 Bank 预充电
        CMD_AUTO_REFRESH,  // 自动刷新
        CMD_LOAD_MODE,     // 加载模式寄存器
        CMD_ACTIVE,        // 行激活（打开行）
        CMD_READ_AP,       // 带自动预充的读命令
        CMD_WRITE_AP       // 带自动预充的写命令
    } cmd_t;

    // 当前周期下发到 SDRAM 的命令（组合译码到 RAS/CAS/WE/CS）
    cmd_t cmd;

    // 将逻辑命令译码为 SDRAM 引脚上的 RAS#/CAS#/WE# 组合（默认 NOP）
    always_comb begin
        // Defaults: NOP (CS# asserted, RAS/CAS/WE deasserted)
        o_sdram_cs_n  = 1'b0;
        o_sdram_ras_n = 1'b1;
        o_sdram_cas_n = 1'b1;
        o_sdram_we_n  = 1'b1;

        unique case (cmd)
            CMD_NOP: begin end // 无额外拉低
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
            CMD_READ_AP: begin // READ：CAS# 有效，WE# 读
                o_sdram_ras_n = 1'b1;
                o_sdram_cas_n = 1'b0;
                o_sdram_we_n  = 1'b1;
            end
            CMD_WRITE_AP: begin // WRITE：CAS#+WE# 同时有效
                o_sdram_ras_n = 1'b1;
                o_sdram_cas_n = 1'b0;
                o_sdram_we_n  = 1'b0;
            end
            default: begin end // 兜底保持 NOP 译码
        endcase
    end

    // ------------------------------------------------------------------------
    // Address mapping helpers
    // ------------------------------------------------------------------------
    logic [22: 0] halfword_addr; // 半字线性地址（字节偏移右移 1 位）

    logic [12: 0] row;   // 行地址（ACTIVE 用）
    logic [ 1: 0] bank;  // Bank 号
    logic [ 8: 0] col;   // 列地址起点（BL=2 突发首列）

    assign halfword_addr = i_addr_off[23:  1];
    assign row = halfword_addr[22: 10];
    assign bank = halfword_addr[ 9:  8];
    assign col = {1'b0, halfword_addr[ 7: 0]};

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
                2: mr[ 6:  4] = 3'b010; // CAS latency = 2
                3: mr[ 6:  4] = 3'b011; // CAS latency = 3
                default: mr[ 6:  4] = 3'b010; // 非法值回退到 2
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
        ST_INIT_WAIT,      // 上电/复位后等待 ≥200µs
        ST_INIT_PRE,       // 发全 Bank 预充
        ST_INIT_TRP,       // 等待 tRP
        ST_INIT_AR1,       // 第一次自刷新
        ST_INIT_TRFC1,     // 等待 tRFC（第一次刷新后）
        ST_INIT_AR2,       // 第二次自刷新
        ST_INIT_TRFC2,     // 等待 tRFC（第二次刷新后）
        ST_INIT_MRS,       // 加载模式寄存器
        ST_INIT_TMRD,      // 等待 tMRD
        ST_IDLE,           // 空闲：可接主机或调度刷新
        ST_REFRESH,        // 发周期性刷新
        ST_REFRESH_TRFC,   // 刷新后等待 tRFC
        ST_ACTIVATE,       // 行激活
        ST_TRCD,           // 等待 tRCD
        ST_RW_CMD,         // 发读或写（带自动预充）
        ST_READ_WAIT,      // 读：等待 CAS latency
        ST_READ_BEAT0,     // 读突发第 0 拍（低 16b）
        ST_READ_BEAT1,     // 读突发第 1 拍（高 16b）
        ST_WRITE_BEAT0,    // 写突发第 0 拍
        ST_WRITE_BEAT1,    // 写突发第 1 拍
        ST_TWR,            // 写恢复等待 tWR
        ST_DONE            // 事务完成，拉高 o_ready 一拍
    } st_t;

    // 主 FSM 当前状态
    st_t st;
    // 通用等待计数器（各状态复用）
    int unsigned ctr;

    logic [23: 0] lat_addr;   // 锁存的主机字节地址偏移
    logic        lat_we;      // 锁存的读写方向
    logic [31: 0] lat_wdata;  // 锁存的写数据

    logic refresh_due;        // 刷新计数到期，应在空闲时插入刷新
    int unsigned refresh_ctr; // 空闲周期累计的刷新节拍计数

    assign refresh_due = (refresh_ctr >= REFRESH_CYCLES-1);

    // 写路径：DQ 输出寄存与输出使能
    logic [15: 0] dq_out_r;
    logic        dq_oe_r;
    assign o_sdram_dq_out = dq_out_r;
    assign o_sdram_dq_oe  = dq_oe_r;

    // Busy whenever not idle
    assign o_busy = (st != ST_IDLE);

    // 按当前命令驱动 BA/A（默认全 0，各命令覆写相关位）
    always_comb begin
        o_sdram_ba = 2'b00;
        o_sdram_a  = 13'b0;

        unique case (cmd)
            CMD_PRECHARGE_ALL: begin
                // A10=1：全 Bank 预充语义
                o_sdram_a[10] = 1'b1;
            end
            CMD_LOAD_MODE: begin
                o_sdram_a  = mode_reg_value(CAS); // 模式字送上 A[12:0]
                o_sdram_ba = 2'b00;
            end
            CMD_ACTIVE: begin
                o_sdram_ba = bank;
                o_sdram_a  = row; // 行地址
            end
            CMD_READ_AP,
            CMD_WRITE_AP: begin
                o_sdram_ba = bank;
                o_sdram_a[ 8: 0] = col;
                // A10=1：本读写结束后自动预充关闭行
                o_sdram_a[10] = 1'b1;
            end
            default: begin end // 其他命令不改 BA/A
        endcase
    end

    // 仅在空闲态累加刷新间隔计数，到阈值由主 FSM 取走刷新
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
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

    // 主 FSM：上电初始化、周期刷新、主机读写突发（BL=2）与握手
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
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
                // For reset-based bring-up, treat rst_n deassert (1) as "power stable".
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
                    if (refresh_due) begin // 到时插入刷新，阻塞新事务
                        st  <= ST_REFRESH;
                        ctr <= 0;
                    end else if (i_en) begin // 主机请求：锁存参数并开行
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
                    if (lat_we) begin // 写事务：两拍 DQ 输出
                        cmd <= CMD_WRITE_AP;
                        st  <= ST_WRITE_BEAT0;
                    end else begin // 读事务：等待 CAS 后采两拍
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

