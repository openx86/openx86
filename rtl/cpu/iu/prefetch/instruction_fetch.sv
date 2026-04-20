/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements instruction_fetch.
*/
// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// create at: 2021-12-28 15:31:24
// description: instruction fetch module

`include "openx86_defs.h.sv"
module instruction_fetch (    // 取指总线（对 BIU/存储子系统）
    output logic         o_code_vaild,
    input  logic          i_code_ready,
    output logic [31: 0] o_code_address,
    input  logic [31: 0] i_code_data_read,
    // MMU 页表遍历总线（通常高于普通 code/data 优先级）
    output logic         o_mmu_bus_vaild,
    input  logic          i_mmu_bus_ready,
    output logic [31: 0] o_mmu_bus_addr,
    input  logic [31: 0] i_mmu_bus_rdata,
    // 段/分页上下文（来自 CPU 寄存器侧）
    input  logic          i_protected_mode,
    input  logic [ 5: 0][15: 0] i_segment_selector,
    input  logic [ 5: 0][63: 0] i_segment_descriptor,
    input  logic [ 1: 0]   i_current_privilege_level,
    input  logic          i_paging_enable,
    input  logic [31: 0] i_page_directory_base,
    // 执行单元：IP 更新完成后再取下一批
    input  logic          i_IP_vaild,
    // 输出到译码：16B 指令缓冲
    output logic [15: 0][ 7: 0] o_instruction,
    output logic         o_instruction_ready,
    output logic         o_segment_fault,
    // 指令指针
    input  logic [31: 0]  EIP,
    input  logic          clk,
    input  logic          rst_n
);

logic        i_vaild;           // MMU 请求门控（与 IP 有效对齐）
logic        o_ready;           // MMU 完成（本模块当前未扇出使用）
logic        if_mmu_bus_we;     // 取指路径不写内存（恒 0 语义由 MMU 封装）
logic [31: 0] if_mmu_bus_wdata; // 写数据占位
logic        if_seg_fault;      // 段单元报告的 fault

assign i_vaild = i_IP_vaild;

// 请求段转换：在 IP 有效时根据当前 EIP 计算物理取指地址

memory_management_unit #(
    .read_from_fetch ( 1'b1 )
) instruction_fetch_memory_management_unit (
    .i_vaild ( i_vaild ),
    .o_ready ( o_ready ),
    .i_protected_mode ( i_protected_mode ),
    .i_segment_selector ( i_segment_selector ),
    .i_segment_descriptor ( i_segment_descriptor ),
    .i_current_privilege_level ( i_current_privilege_level ),
    .i_segment_index ( `sreg_index_CS ),
    .i_effective_address ( EIP ),
    .i_write_enable ( 1'b0 ),
    .i_paging_enable ( i_paging_enable ),
    .i_page_directory_base ( i_page_directory_base ),
    .o_physical_address ( o_code_address ),
    .o_segment_fault ( if_seg_fault ),
    .o_bus_vaild ( o_mmu_bus_vaild ),
    .i_bus_ready ( i_mmu_bus_ready ),
    .o_bus_write_enable ( if_mmu_bus_we ),
    .o_bus_address ( o_mmu_bus_addr ),
    .i_bus_data_read ( i_mmu_bus_rdata ),
    .o_bus_data_write ( if_mmu_bus_wdata ),
    .clk ( clk ),
    .rst_n ( rst_n )
);

assign o_segment_fault = if_seg_fault;

// 取指小状态机：等 EIP 有效 → 拉取 4×32b 并拼装 16B → 再回等 IP
enum logic {
    STATE_WAIT_FOR_CODE_DATA_READY = 1'h1, // 等待存储返回并收齐 16 字节
    STATE_WAIT_FOR_IP_VALID = 1'h0         // 等待执行侧给出有效 IP
} state;

// 状态转移：与 bytes_index 配合完成 4 次 32b 读
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= STATE_WAIT_FOR_IP_VALID;
    end else begin
        unique case (state)
            STATE_WAIT_FOR_IP_VALID: begin
                if (i_IP_vaild) begin
                    state <= STATE_WAIT_FOR_CODE_DATA_READY;
                end else begin
                    state <= STATE_WAIT_FOR_IP_VALID;
                end
            end
            STATE_WAIT_FOR_CODE_DATA_READY: begin
                if (i_code_ready && (bytes_index == 2'h3)) begin
                    state <= STATE_WAIT_FOR_IP_VALID;
                end else begin
                    state <= STATE_WAIT_FOR_CODE_DATA_READY;
                end
            end
            default: begin
                state <= STATE_WAIT_FOR_IP_VALID;
            end
        endcase
    end
end

logic [ 1: 0] bytes_index; // 当前正在接收第几个 32b 槽（0..3）

// 输出握手与缓冲装载：按槽把 big-endian 32b 拆入 o_instruction
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        o_code_vaild <= 1'b0;
        bytes_index <= 2'b00;
    end else begin
        unique case (state)
            STATE_WAIT_FOR_IP_VALID: begin
                bytes_index <= 2'b00;
                if (i_IP_vaild) begin
                    o_code_vaild <= 1;
                end else begin
                    o_code_vaild <= 1'b0;
                end
            end
            STATE_WAIT_FOR_CODE_DATA_READY: begin
                if (i_code_ready) begin
                    bytes_index <= bytes_index + 2'd1;
                    if (bytes_index < 2'h3) begin
                        // 每个 i_code_ready 周期写入一个 32b 小端槽到 16B 缓冲
                        unique case (bytes_index)
                            2'h0: begin
                                o_instruction[0] <= i_code_data_read[31: 24];
                                o_instruction[1] <= i_code_data_read[23: 16];
                                o_instruction[2] <= i_code_data_read[15: 8];
                                o_instruction[3] <= i_code_data_read[ 7: 0];
                            end
                            2'h1: begin
                                o_instruction[4] <= i_code_data_read[31: 24];
                                o_instruction[5] <= i_code_data_read[23: 16];
                                o_instruction[6] <= i_code_data_read[15: 8];
                                o_instruction[7] <= i_code_data_read[ 7: 0];
                            end
                            2'h2: begin
                                o_instruction[ 8] <= i_code_data_read[31: 24];
                                o_instruction[ 9] <= i_code_data_read[23: 16];
                                o_instruction[10] <= i_code_data_read[15: 8];
                                o_instruction[11] <= i_code_data_read[ 7: 0];
                            end
                            2'h3: begin
                                o_instruction[12] <= i_code_data_read[31: 24];
                                o_instruction[13] <= i_code_data_read[23: 16];
                                o_instruction[14] <= i_code_data_read[15: 8];
                                o_instruction[15] <= i_code_data_read[ 7: 0];
                            end
                        endcase
                        // o_instruction[bytes_index*4:bytes_index*4+3] <= '{
                        //     i_code_data_read[31: 24],
                        //     i_code_data_read[23: 16],
                        //     i_code_data_read[15: 8],
                        //     i_code_data_read[ 7: 0]
                        // };
                        o_instruction_ready <= 1'b0;
                    end else begin
                        o_instruction_ready <= 1;
                    end
                end else begin
                    o_instruction_ready <= 1'b0;
                end
            end
            default: begin
            end
        endcase
    end
end

endmodule
