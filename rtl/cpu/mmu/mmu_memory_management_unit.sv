/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements mmu_memory_management_unit.
*/
/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: mmu_memory_management_unit
create at: 2022-02-04 23:34:40
description: mmu_memory_management_unit
*/

module mmu_memory_management_unit #(
    parameter bit read_from_fetch = 1'b0
) (
    // ------------------------------------------------------------------------
    // Handshake（与上游地址请求握手）
    // ------------------------------------------------------------------------
    input  logic          i_vaild,          // 一次地址翻译请求有效
    output logic         o_ready,          // 翻译完成，o_physical_address 可用

    // ------------------------------------------------------------------------
    // Address translation context（段 + 分页输入）
    // ------------------------------------------------------------------------
    input  logic          i_protected_mode,                              // CR0.PE
    input  logic [ 5: 0][15: 0] i_segment_selector,                      // 段选择子
    input  logic [ 5: 0][63: 0] i_segment_descriptor,                    // 段描述符缓存
    input  logic [ 1: 0] i_current_privilege_level,                     // CPL
    input  logic [ 2: 0] i_segment_index,                               // 访问哪个段（CS/DS/...）
    input  logic [31: 0] i_effective_address,                           // 段内有效地址/偏移
    input  logic          i_write_enable,                                // 写访问（取指路径为 0）
    input  logic          i_paging_enable,                               // CR0.PG
    input  logic [31: 0] i_page_directory_base,                         // CR3：页目录物理基址
    output logic [31: 0] o_physical_address,                            // 最终物理地址
    output logic         o_segment_fault,                                // 段保护 fault

    // ------------------------------------------------------------------------
    // Bus for paging walks (used only when paging enabled)（两级页表读）
    // ------------------------------------------------------------------------
    output logic         o_bus_vaild,
    input  logic          i_bus_ready,
    output logic         o_bus_write_enable,
    output logic [31: 0] o_bus_address,
    input  logic [31: 0] i_bus_data_read,
    output logic [31: 0] o_bus_data_write,

    // ------------------------------------------------------------------------
    // Clock / reset
    // ------------------------------------------------------------------------
    input  logic          clk,
    input  logic          rst_n
);

logic [31: 0] linear_address;   // 段单元输出线性地址
logic [31: 0] physical_address; // 分页单元输出物理页基 + 页内偏移合成前保存在此

logic         paging_vaild;     // 启动分页 walk
logic         paging_ready;     // 分页 walk 完成
logic         seg_priv_err;     // 段检查失败

mmu_seg_segmentation_unit #(
    .read_from_fetch ( read_from_fetch )
) mmu_segmentation_unit (
    .i_protected_mode ( i_protected_mode ),
    .i_segment_selector ( i_segment_selector ),
    .i_segment_descriptor ( i_segment_descriptor ),
    .i_current_privilege_level ( i_current_privilege_level ),
    .i_segment_index ( i_segment_index ),
    .i_effective_address ( i_effective_address ),
    .i_write_enable ( i_write_enable ),
    .o_linear_address ( linear_address ),
    .o_segment_privilege_error ( seg_priv_err ),
    .clk ( clk ),
    .rst_n ( rst_n )
);

assign o_segment_fault = seg_priv_err;

mmu_pg_paging_unit mmu_paging_unit (
    .i_vaild ( paging_vaild ),
    .o_ready ( paging_ready ),
    .i_linear_address ( linear_address ),
    .i_page_directory_base ( i_page_directory_base ),
    .o_physical_address ( physical_address ),
    .o_bus_vaild ( o_bus_vaild ),
    .i_bus_ready ( i_bus_ready ),
    .o_bus_write_enable ( o_bus_write_enable ),
    .o_bus_address ( o_bus_address ),
    .i_bus_data_read ( i_bus_data_read ),
    .o_bus_data_write ( o_bus_data_write ),
    .clk ( clk ),
    .rst_n ( rst_n )
);


// MMU 组合状态：空闲 →（可选）等分页 → 输出物理或线性
enum logic [ 1: 0] {
    STATE_WAIT_FOR_PAGING_UNIT_READY = 2'h1, // 等待页表两级读完成
    STATE_OUTPUT_LINEAR_ADDRESS = 2'h2,      // 未分页：直接输出线性地址
    STATE_WAIT_FOR_VAILD = 2'h0              // 等待新请求
} state;

// 顺序控制：分页关闭时一拍完成；开启时委托 paging_unit
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= STATE_WAIT_FOR_VAILD;
        o_ready <= 0;
    end else begin
        unique case (state)
            STATE_WAIT_FOR_VAILD: begin
                if (i_vaild) begin
                    o_ready <= 0;
                    if (i_paging_enable) begin
                        state <= STATE_WAIT_FOR_PAGING_UNIT_READY;
                        paging_vaild <= 1;
                    end else begin
                        state <= STATE_OUTPUT_LINEAR_ADDRESS;
                        paging_vaild <= 0;
                    end
                end else begin
                    state <= STATE_WAIT_FOR_VAILD;
                    paging_vaild <= 0;
                end
            end
            STATE_WAIT_FOR_PAGING_UNIT_READY: begin
                if (paging_ready) begin
                    state <= STATE_WAIT_FOR_VAILD;
                    o_ready <= 1;
                    o_physical_address <= physical_address;
                end else begin
                    state <= STATE_WAIT_FOR_PAGING_UNIT_READY;
                    o_ready <= 0;
                    o_physical_address <= o_physical_address;
                end
            end
            STATE_OUTPUT_LINEAR_ADDRESS: begin
                state <= STATE_WAIT_FOR_VAILD;
                o_ready <= 1;
                o_physical_address <= linear_address;
            end
            default: begin
                state <= STATE_WAIT_FOR_VAILD;
            end
        endcase
    end
end

endmodule
