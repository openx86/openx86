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
//  File        : bus_interface_unit.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : bus_interface_unit module
// ============================================================================

module bus_interface_unit (
    // =========================
    // MMU channel
    // =========================
    input  logic         i_mmu_valid,
    output logic         o_mmu_ready,
    input  logic [31: 0] i_mmu_address,
    output logic [31: 0] o_mmu_data_read,

    // =========================
    // instruction fetch channel
    // =========================
    input  logic         i_code_valid,
    output logic         o_code_ready,
    input  logic [31: 0] i_code_address,
    output logic [31: 0] o_code_data_read,

    // =========================
    // data access channel
    // =========================
    input  logic         i_data_valid,
    output logic         o_data_ready,
    input  logic         i_data_write_enable,
    input  logic         i_data_io_access,
    input  logic [31: 0] i_data_address,
    output logic [31: 0] o_data_data_read,
    input  logic [31: 0] i_data_data_write,

    // =========================
    // SoC bus interface
    // =========================
    output logic         o_bus_valid,
    input  logic         i_bus_ready,
    input  logic         i_bus_busy,
    output logic         o_bus_write_enable,
    output logic         o_bus_io_access,
    output logic [31: 0] o_bus_address,
    input  logic [31: 0] i_bus_data_read,
    output logic [31: 0] o_bus_data_write,

    // =========================
    // clock and reset
    // =========================
    input  logic         clk,
    input  logic         rst_n
);

    // ============================================================
    // three master ports share same read data bus (direct broadcast)
    // ============================================================
    assign o_mmu_data_read   = i_bus_data_read;
    assign o_code_data_read  = i_bus_data_read;
    assign o_data_data_read  = i_bus_data_read;

    // ============================================================
    // BIU arbitration state machine
    // ============================================================
    typedef enum logic [ 2: 0] {
        S_IDLE,
        S_MMU,
        S_CODE,
        S_DATA
    } biu_state_e;

    biu_state_e state;

    // ============================================================
    // fixed priority arbitration with single-transaction handshake
    // ============================================================
    always_ff @(posedge clk or negedge rst_n) begin : ff_biu_arbiter
    if (~rst_n) begin  // 异步复位：状态空闲，总线与各 ready 无效
        state <= S_IDLE;
        o_bus_vaild <= 1'b0;
        o_bus_write_enable <= 1'b0;
        o_bus_io_access <= 1'b0;
        o_bus_address <= 32'h0;
        o_bus_data_write <= 32'h0;
        o_mmu_ready <= 1'b0;
        o_code_ready <= 1'b0;
        o_data_ready <= 1'b0;
    end else begin
        // 默认：本周期不完成各子事务（由状态分支拉高对应 ready）
        o_mmu_ready <= 1'b0;
        o_code_ready <= 1'b0;
        o_data_ready <= 1'b0;

        unique case (state)
            S_IDLE: begin
                o_bus_valid <= 1'b0;
                if (i_mmu_valid) begin  // 最高优先：页表/MMU
                    state               <= S_MMU;
                    o_bus_valid         <= 1'b1;
                    o_bus_write_enable  <= 1'b0;
                    o_bus_io_access     <= 1'b0;
                    o_bus_address       <= i_mmu_address;
                    o_bus_data_write    <= 32'h0;
                end else if (i_code_valid) begin  // 次之：取指
                    state               <= S_CODE;
                    o_bus_valid         <= 1'b1;
                    o_bus_write_enable  <= 1'b0;
                    o_bus_io_access     <= 1'b0;
                    o_bus_address       <= i_code_address;
                    o_bus_data_write    <= 32'h0;
                end else if (i_data_valid) begin  // 最后：数据访存
                    state               <= S_DATA;
                    o_bus_valid         <= 1'b1;
                    o_bus_write_enable  <= i_data_write_enable;
                    o_bus_io_access     <= i_data_io_access;
                    o_bus_address       <= i_data_address;
                    o_bus_data_write    <= i_data_data_write;
                end
            end
            S_MMU: begin
                if (i_bus_ready) begin  // 总线完成：应答 MMU
                    o_mmu_ready  <= 1'b1;
                    o_bus_valid  <= 1'b0;
                    state        <= S_IDLE;
                end
            end
            S_CODE: begin
                if (i_bus_ready) begin  // 总线完成：应答取指
                    o_code_ready <= 1'b1;
                    o_bus_valid  <= 1'b0;
                    state        <= S_IDLE;
                end
            end
            S_DATA: begin
                if (i_bus_ready) begin  // 总线完成：应答数据端口
                    o_data_ready <= 1'b1;
                    o_bus_valid  <= 1'b0;
                    state        <= S_IDLE;
                end
            end
            default: state <= S_IDLE;  // 非法态回退空闲
        endcase
    end
end

endmodule
