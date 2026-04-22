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
    input  logic         i_mmu_valid,     // MMU/页表遍历请求有效
    output logic         o_mmu_ready,     // MMU 事务完成握手
    input  logic [31: 0] i_mmu_address,   // MMU 访存地址
    output logic [31: 0] o_mmu_data_read,  // MMU 读回数据（来自总线）

    input  logic         i_code_valid,    // 取指请求有效
    output logic         o_code_ready,    // 取指完成握手
    input  logic [31: 0] i_code_address,  // 指令取址
    output logic [31: 0] o_code_data_read, // 指令读回数据

    input  logic         i_data_valid,    // 数据访存请求有效
    output logic         o_data_ready,    // 数据事务完成握手
    input  logic         i_data_write_enable, // 数据写使能（store）
    input  logic         i_data_io_access,   // I/O 空间访问（与存储器访问区分）
    input  logic [31: 0] i_data_address,     // 数据地址
    output logic [31: 0] o_data_data_read,  // 数据读回
    input  logic [31: 0] i_data_data_write, // 数据写数据

    output logic         o_bus_valid,        // 对外总线请求有效
    input  logic         i_bus_ready,       // 总线从设备就绪（完成一拍）
    input  logic         i_bus_busy,        // 总线忙（与 ready 组合使用）
    output logic         o_bus_write_enable, // 总线写使能
    output logic         o_bus_io_access,    // 总线 I/O 访问指示
    output logic [31: 0] o_bus_address,      // 总线地址
    input  logic [31: 0] i_bus_data_read,    // 总线读数据输入
    output logic [31: 0] o_bus_data_write,   // 总线写数据输出

    input  logic         clk,               // 时钟信号
    input  logic         rst_n              // 复位信号
);

// 三主端口共享同一读数据总线（当前实现为直连广播）
assign o_mmu_data_read   = i_bus_data_read;
assign o_code_data_read  = i_bus_data_read;
assign o_data_data_read  = i_bus_data_read;

typedef enum logic [ 2: 0] {
    S_IDLE,   // 空闲：仲裁下一请求
    S_MMU,    // MMU 事务进行中
    S_CODE,   // 取指事务进行中
    S_DATA    // 数据事务进行中
} biu_state_e;

biu_state_e state;  // BIU 仲裁/握手状态

// 固定优先级仲裁 + 单事务握手：完成返回各通道 ready
always_ff @(posedge clk or negedge rst_n) begin
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
